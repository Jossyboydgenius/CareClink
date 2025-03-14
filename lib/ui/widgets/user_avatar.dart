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
import 'package:cached_network_image/cached_network_image.dart';

class UserAvatar extends StatefulWidget {
  const UserAvatar({super.key});

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  String? _profileImage;
  String? _fullname;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    debugPrint('Loading user data for avatar');
    final userService = locator<UserService>();
    final userData = await userService.getCurrentUser();
    debugPrint('User data received: ${userData.toString()}');
    
    if (mounted) {
      setState(() {
        _profileImage = userData['profileImage'];
        _fullname = userData['fullname'];
        debugPrint('Avatar state updated - Profile Image: $_profileImage, Fullname: $_fullname');
      });
    }
  }

  void _handleSignOut() async {
    final userService = locator<UserService>();
    await userService.logout();
    _removeOverlay();
    NavigationService.pushReplacementNamed(AppRoutes.signInView);
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 140.w,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(0, 45.h),
          child: Material(
            elevation: 2,
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.grey),
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
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  String _getInitials() {
    if (_fullname == null || _fullname!.isEmpty) {
      debugPrint('No fullname available for initials');
      return '';
    }
    final names = _fullname!.split(' ');
    if (names.length >= 2) {
      final initials = '${names[0][0]}${names[1][0]}'.toUpperCase();
      debugPrint('Generated initials: $initials');
      return initials;
    }
    debugPrint('Single initial: ${names[0][0].toUpperCase()}');
    return names[0][0].toUpperCase();
  }

  Widget _buildAvatar() {
    debugPrint('Building avatar - Profile Image: $_profileImage');
    if (_profileImage != null && _profileImage!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          width: 40.w,
          height: 40.w,
          imageUrl: _profileImage!,
          fit: BoxFit.cover,
          placeholder: (context, url) {
            debugPrint('Loading profile image placeholder');
            return _buildInitialsAvatar();
          },
          errorWidget: (context, url, error) {
            debugPrint('Error loading profile image: $error');
            return _buildInitialsAvatar();
          },
        ),
      );
    }
    debugPrint('No profile image, using initials avatar');
    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    final initials = _getInitials();
    debugPrint('Building initials avatar: $initials');
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: AppColors.blue,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTextStyle.semibold14.copyWith(
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
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
    );
  }
} 