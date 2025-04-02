import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_icons.dart';
import '../../shared/app_spacing.dart';
import '../../data/services/user_service.dart';
import '../../app/locator.dart';
import '../../app/routes/app_routes.dart';
import '../../data/services/navigator_service.dart';

class UserAvatar extends StatefulWidget {
  const UserAvatar({super.key});

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> with RouteAware {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  String? _profileImage;
  String? _fullname;
  bool _isLoading = true;
  bool _imageError = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _unsubscribeFromRoute();
    _subscribeToRoute();
  }

  void _subscribeToRoute() {
    final route = ModalRoute.of(context);
    if (route != null) {
      NavigationService.routeObserver.subscribe(this, route);
    }
  }

  void _unsubscribeFromRoute() {
    NavigationService.routeObserver.unsubscribe(this);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _removeOverlay();
    _unsubscribeFromRoute();
    super.dispose();
  }

  @override
  void didPushNext() {
    if (!_isDisposed) {
      _removeOverlay();
    }
    super.didPushNext();
  }

  @override
  void didPopNext() {
    if (!_isDisposed) {
      _removeOverlay();
    }
    super.didPopNext();
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    
    if (!_isDisposed && mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  void _showOverlay() {
    if (!mounted || _isDisposed) return;
    
    _removeOverlay();

    final overlay = Overlay.of(context, rootOverlay: true);
    if (overlay == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeOverlay,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: Offset(-16.w, -8.h),
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 140.w,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.grey400),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: _handleSignOut,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sign Out',
                          style: AppTextStyle.regular14.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        AppIcons(
                          icon: AppIconData.logOut,
                          size: 16,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (!_isDisposed) {
      overlay.insert(_overlayEntry!);
      if (mounted) {
        setState(() {
          _isOpen = true;
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    if (!mounted || _isDisposed) return;
    
    debugPrint('Loading user data for avatar');
    try {
      final userService = locator<UserService>();
      final userData = await userService.getCurrentUser();
      debugPrint('User data received: ${userData.toString()}');
      
      if (!_isDisposed && mounted) {
        setState(() {
          _profileImage = userData['profileImage'];
          _fullname = userData['fullname'];
          _isLoading = false;
          debugPrint('Avatar state updated - Profile Image: $_profileImage, Fullname: $_fullname');
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
          _imageError = true;
        });
      }
    }
  }

  void _handleSignOut() async {
    if (_isDisposed) return;
    
    try {
      final userService = locator<UserService>();
      await userService.logout();
      _removeOverlay();
      NavigationService.pushReplacementNamed(AppRoutes.signInView);
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  Future<bool> onWillPop() async {
    if (_isOpen) {
      _removeOverlay();
      return false;
    }
    return true;
  }

  String _getInitials() {
    if (_fullname == null || _fullname!.trim().isEmpty) return '';
    
    final names = _fullname!.trim().split(' ').where((name) => name.isNotEmpty).toList();
    if (names.isEmpty) return '';
    
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return names[0][0].toUpperCase();
  }

  Widget _buildAvatar() {
    if (_isLoading) {
      return _buildLoadingAvatar();
    }

    if (_profileImage != null && _profileImage!.isNotEmpty && !_imageError) {
      return ClipOval(
        child: Stack(
          children: [
            _buildInitialsAvatar(), // Show initials as fallback
            Image.network(
              _profileImage!,
              width: 40.w,
              height: 40.w,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildLoadingAvatar();
              },
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error loading image: $error');
                return _buildInitialsAvatar();
              },
            ),
          ],
        ),
      );
    }

    return _buildInitialsAvatar();
  }

  Widget _buildLoadingAvatar() {
    return Stack(
      children: [
        _buildInitialsAvatar(),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInitialsAvatar() {
    final initials = _getInitials();
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: AppColors.blue,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: AppTextStyle.semibold14.copyWith(
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: GestureDetector(
          onTap: () {
            if (_isOpen) {
              _removeOverlay();
            } else {
              _showOverlay();
            }
          },
          child: Container(
            padding: EdgeInsets.all(8.w),
            child: Row(
              children: [
                _buildAvatar(),
                AppSpacing.h4(),
                Icon(
                  _isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.textPrimary,
                  size: 20.w,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 