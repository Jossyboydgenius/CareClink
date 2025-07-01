import 'package:careclink/shared/app_spacing.dart';
import 'package:careclink/ui/widgets/skeleton_timesheet_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:typed_data';
import 'dashboard/dashboard_bloc/dashboard_bloc.dart';
import 'dashboard/dashboard_bloc/dashboard_event.dart';
import 'dashboard/dashboard_bloc/dashboard_state.dart';
import '../widgets/activity_card.dart';
import '../widgets/skeleton_activity_card.dart';
import '../widgets/timesheet_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/user_avatar.dart';
import '../widgets/signature_pad_dialog.dart';
import '../../shared/app_sizer.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_images.dart';
import '../../shared/app_toast.dart';
import '../../data/services/timesheet_service.dart';
import '../../data/services/signature_service.dart';
import '../../app/navigation_state_manager.dart';
import '../../app/locator.dart';
import 'notification_view.dart';
import 'appointment_view.dart';
import '../../shared/app_error_handler.dart';
import '../../data/utils/timesheet_helper.dart';

class Dashboard extends StatefulWidget {
  final Map<String, dynamic>? recentTimesheet;

  const Dashboard({
    super.key,
    this.recentTimesheet,
  });

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;
  final List<Widget> _pages = [];
  final PageController _pageController = PageController();
  final TimesheetService _timesheetService = TimesheetService();
  late final DashboardBloc _dashboardBloc;
  final NavigationStateManager _stateManager =
      locator<NavigationStateManager>();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final Set<String> _loadingTimesheets = {};
  bool _isInitialLoading = true;
  bool _timesheetsLoaded = false;
  DateTime? _lastTimesheetsRefresh;
  bool _noTimesheetsFound = false;

  @override
  void initState() {
    super.initState();
    _dashboardBloc = DashboardBloc()..add(const LoadDashboardSummaries());

    // Add timesheet from appointment if provided
    if (widget.recentTimesheet != null) {
      // Check if timesheet already exists before adding
      final String? timesheetId = widget.recentTimesheet!['id'] as String?;

      if (timesheetId != null) {
        final existingTimesheet = _timesheetService.getTimesheet(timesheetId);
        if (existingTimesheet == null) {
          _timesheetService.addTimesheet(widget.recentTimesheet!);
        }
      }
    }

    // Initialize pages with keeping state
    _pages.addAll([
      _buildDashboardContent(),
      const NotificationView(),
      const AppointmentView(),
    ]);

    // Immediately fetch timesheets when mounted but only if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialLoadIfNeeded();
    });
  }

  @override
  void dispose() {
    _dashboardBloc.close();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initialLoadIfNeeded() async {
    // Only load timesheets if they haven't been loaded or if it's time to refresh
    if (!_timesheetsLoaded || _shouldRefreshTimesheets()) {
      await _initialLoad();
    } else {
      // Still update UI to show we're done loading
      setState(() {
        _isInitialLoading = false;
      });
    }
  }

  bool _shouldRefreshTimesheets() {
    if (_lastTimesheetsRefresh == null) return true;
    // Use the same threshold as other services (5 minutes)
    return DateTime.now().difference(_lastTimesheetsRefresh!).inMinutes >
        NavigationStateManager.refreshThresholdMinutes;
  }

  Future<void> _initialLoad() async {
    setState(() {
      _isInitialLoading = true;
      _noTimesheetsFound = false; // Reset flag on initial load
    });
    await _fetchTimesheets();
    setState(() {
      _isInitialLoading = false;
      _timesheetsLoaded = true;
    });
  }

  Future<void> _fetchTimesheets() async {
    if (!mounted) return;

    try {
      final response = await _timesheetService.getTimesheets();

      if (response.isSuccessful && response.data != null) {
        final timesheets = response.data['timesheets'] as List;

        // Use the correct processing method that handles role-specific fields
        await _timesheetService.processTimesheetsFromResponse(timesheets);

        setState(() {
          _noTimesheetsFound = _timesheetService.recentTimesheets.isEmpty;
          _lastTimesheetsRefresh = DateTime.now();
        });
      } else {
        // Handle case when no timesheets are found or other errors
        setState(() {
          _timesheetService.clearTimesheets(); // Clear any previous timesheets
          _noTimesheetsFound = true;
          _lastTimesheetsRefresh = DateTime.now();
        });

        if (mounted &&
            response.message?.contains('No timesheets found') == true) {
          // This is an expected scenario - no need to show an error toast
          debugPrint('No timesheets found for current user');
        } else if (mounted) {
          // For actual errors, show error toast
          AppErrorHandler.handleError(context, response);
        }
      }
    } catch (e) {
      setState(() {
        _timesheetService
            .clearTimesheets(); // Also clear timesheets on exception
        _noTimesheetsFound = true;
      });

      if (mounted) {
        // Skip showing authentication error toasts during normal logout/login flow
        String errorMsg = e.toString().toLowerCase();
        if (!errorMsg.contains('token') &&
            !errorMsg.contains('unauthorized') &&
            !errorMsg.contains('session') &&
            !errorMsg.contains('authentication')) {
          AppErrorHandler.handleError(context, e);
        } else {
          // Just log auth errors during logout without showing toast
          debugPrint('Skipping auth error during logout/login flow: $e');
        }
      }
    }
  }

  Future<void> _refreshDashboard() async {
    if (!mounted) return;

    // Always fetch fresh data, ignoring any cache
    setState(() {
      _isInitialLoading = true;
    });

    try {
      // Reset the dashboard block for latest data
      _dashboardBloc.add(const LoadDashboardSummaries());

      // Force fetch new timesheets from API
      final response = await _timesheetService.getTimesheets();

      if (response.isSuccessful && response.data != null) {
        final timesheets = response.data['timesheets'] as List;
        // Process the timesheets directly using the enhanced method
        await _timesheetService.processTimesheetsFromResponse(timesheets);

        // Add debug logging for all timesheets
        debugPrint(
            'Refreshed timesheets (${_timesheetService.recentTimesheets.length}):');
        for (var ts in _timesheetService.recentTimesheets) {
          debugPrint(
              '  ID: ${ts['id']}, status: ${ts['status']}, clockOut: ${ts['clockOut']}');
          debugPrint(
              '  canClockOut: ${TimesheetHelper.canClockOut(status: ts['status'], clockOut: ts['clockOut'])}');
        }

        setState(() {
          _noTimesheetsFound = _timesheetService.recentTimesheets.isEmpty;
          _lastTimesheetsRefresh = DateTime.now();
          _timesheetsLoaded = true;
        });
      } else {
        setState(() {
          _noTimesheetsFound = true;
        });
      }
    } catch (e) {
      debugPrint('Error refreshing dashboard: $e');
      if (mounted) {
        AppErrorHandler.handleError(context, e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
    }
  }

  Widget _buildActivityCards(BuildContext context, DashboardState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth - AppDimension.getWidth(16)) / 2;
        final cardHeight = cardWidth * 0.7;

        if (state.isLoading) {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: AppDimension.isTablet ? 4 : 2,
            mainAxisSpacing: AppDimension.getHeight(16),
            crossAxisSpacing: AppDimension.getWidth(16),
            childAspectRatio: cardWidth / cardHeight,
            children: [
              SkeletonActivityCard(
                cardColor: AppColors.activityPurple,
                borderColor: AppColors.activityPurpleBorder,
              ),
              SkeletonActivityCard(
                cardColor: AppColors.activityGreen,
                borderColor: AppColors.activityGreenBorder,
              ),
              SkeletonActivityCard(
                cardColor: AppColors.activityOrange,
                borderColor: AppColors.activityOrangeBorder,
              ),
              SkeletonActivityCard(
                cardColor: AppColors.activityPink,
                borderColor: AppColors.activityPinkBorder,
              ),
            ],
          );
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: AppDimension.isTablet ? 4 : 2,
          mainAxisSpacing: AppDimension.getHeight(16),
          crossAxisSpacing: AppDimension.getWidth(16),
          childAspectRatio: cardWidth / cardHeight,
          children: [
            ActivityCard(
              title: 'Daily',
              hours: state.dailySummary?.hours ?? '0 hr',
              completedText: state.dailySummary?.completed ?? '0 appointments',
              cardColor: AppColors.activityPurple,
              borderColor: AppColors.activityPurpleBorder,
            ),
            ActivityCard(
              title: 'Bi-Weekly',
              hours: state.weeklySummary?.hours ?? '0 hr',
              completedText: state.weeklySummary?.completed ?? '0 appointments',
              cardColor: AppColors.activityGreen,
              borderColor: AppColors.activityGreenBorder,
            ),
            ActivityCard(
              title: 'Monthly',
              hours: state.monthlySummary?.hours ?? '0 hr',
              completedText:
                  state.monthlySummary?.completed ?? '0 appointments',
              cardColor: AppColors.activityOrange,
              borderColor: AppColors.activityOrangeBorder,
            ),
            ActivityCard(
              title: 'Pending Appointment',
              hours: '${state.statusSummary?.pending ?? 0}',
              completedText: state.statusSummary?.completed ?? '0 / 0',
              cardColor: AppColors.activityPink,
              borderColor: AppColors.activityPinkBorder,
            ),
          ],
        );
      },
    );
  }

  Widget _buildDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed Header Section
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimension.getWidth(24),
            vertical: AppDimension.getHeight(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AppImages(
                    imagePath: AppImageData.careclinkLogo,
                    height: 60,
                    width: 160,
                  ),
                ],
              ),
              const UserAvatar(),
            ],
          ),
        ),
        // Scrollable Content
        Expanded(
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state.error != null) {
                return Center(child: Text(state.error!));
              }

              return RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _refreshDashboard,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimension.getWidth(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: AppDimension.getHeight(2)),
                        // Welcome text
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Welcome Back ',
                                style: AppTextStyle.welcomeBack,
                              ),
                              TextSpan(
                                text: '👋',
                                style: AppTextStyle.welcomeBack,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: AppDimension.getHeight(2)),
                        Text(
                          'Check your activities summary',
                          style: AppTextStyle.activitiesSummary,
                        ),
                        SizedBox(height: AppDimension.getHeight(16)),
                        // Activity cards with skeleton loading
                        _buildActivityCards(context, state),
                        SizedBox(height: AppDimension.getHeight(32)),
                        // Timesheet section
                        Text(
                          'Recent Timesheet',
                          style: AppTextStyle.activitiesSummary,
                        ),
                        SizedBox(height: AppDimension.getHeight(16)),
                        // Recent timesheet list
                        _buildTimesheetSection(),
                        // Add bottom padding to ensure content doesn't get hidden behind bottom nav
                        SizedBox(height: AppDimension.getHeight(80)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimesheetSection() {
    // Initial loading state, show skeleton
    if (_isInitialLoading && !_noTimesheetsFound) {
      return Column(
        children: [
          AppSpacing.v16(),
          const SkeletonTimesheetCard(),
          AppSpacing.v16(),
          const SkeletonTimesheetCard(),
          AppSpacing.v16(),
          const SkeletonTimesheetCard(),
        ],
      );
    }

    // No timesheets found message
    if (_noTimesheetsFound ||
        (_timesheetsLoaded && _timesheetService.recentTimesheets.isEmpty)) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: AppDimension.getHeight(16)),
        padding: EdgeInsets.all(AppDimension.getWidth(16)),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(AppDimension.getWidth(12)),
          border: Border.all(color: AppColors.grey200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: AppDimension.getWidth(48),
              color: AppColors.grey300,
            ),
            AppSpacing.v16(),
            Text(
              'No timesheets found',
              style: AppTextStyle.medium16.copyWith(
                color: AppColors.grey300,
              ),
            ),
            AppSpacing.v8(),
            Text(
              'Clock in an appointment to create a timesheet',
              textAlign: TextAlign.center,
              style: AppTextStyle.regular14.copyWith(
                color: AppColors.grey300,
              ),
            ),
            AppSpacing.v24(),
            ElevatedButton(
              onPressed: _refreshDashboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimension.getWidth(24),
                  vertical: AppDimension.getHeight(12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimension.getWidth(8)),
                ),
              ),
              child: Text(
                'Refresh',
                style: AppTextStyle.medium14.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show actual timesheet data
    return Column(
      children: [
        ..._timesheetService.recentTimesheets.map((timesheet) {
          final String timesheetId = timesheet['id'];
          final bool isLoading = _loadingTimesheets.contains(timesheetId);

          // Log timesheet data for debugging
          TimesheetHelper.logTimesheetData('Timesheet', timesheet);

          // Use the helper method to determine if the timesheet can be clocked out
          // Use rawClockOut for proper validation, fallback to clockOut if not available
          final rawClockOutValue =
              timesheet['rawClockOut'] ?? timesheet['clockOut'];
          final bool canClockOut = TimesheetHelper.canClockOut(
              status: timesheet['status']?.toString() ?? '',
              clockOut: rawClockOutValue,
              isLoading: isLoading);

          // Add debug logging to help diagnose issues
          debugPrint(
              'Timesheet visibility check: ID=${timesheet['id']}, status=${timesheet['status']}, '
              'clockOut=${timesheet['clockOut']}, canClockOut=$canClockOut');

          return Column(
            children: [
              TimesheetCard(
                clientName: timesheet['clientName'],
                staffName: timesheet['clientName'],
                clockIn: timesheet['clockIn'],
                clockOut: timesheet['clockOut'],
                rawClockOut: timesheet['rawClockOut'],
                duration: timesheet['duration'],
                status: timesheet['status'],
                onClockOut:
                    canClockOut ? () => _handleClockOut(timesheetId) : null,
                onExpandDetails: () {},
                isClockingOut: isLoading,
              ),
              if (timesheet != _timesheetService.recentTimesheets.last)
                AppSpacing.v16(),
            ],
          );
        }),
      ],
    );
  }

  Future<void> _handleClockOut(String timesheetId) async {
    // Find the timesheet to get client name for the signature dialog
    final timesheet = _timesheetService.recentTimesheets.firstWhere(
      (ts) => ts['id'] == timesheetId,
      orElse: () => <String, dynamic>{},
    );

    final clientName = timesheet['clientName'] ?? 'Unknown Client';

    // Show signature pad dialog first
    _showSignaturePadForClockOut(timesheetId, clientName);
  }

  void _showSignaturePadForClockOut(String timesheetId, String clientName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SignaturePadDialog(
        title: 'Clock Out Confirmation',
        subtitle: 'Please sign to confirm clocking out for $clientName',
        actionButtonText: 'Clock Out',
        onCancel: () {
          Navigator.of(context).pop();
        },
        onConfirm: (signatureBytes) async {
          Navigator.of(context).pop();
          await _performClockOut(timesheetId, signatureBytes);
        },
      ),
    );
  }

  Future<void> _performClockOut(
      String timesheetId, Uint8List signatureBytes) async {
    // Set loading state immediately
    setState(() {
      _loadingTimesheets.add(timesheetId);
    });

    debugPrint('Starting clock out process for timesheet: $timesheetId');

    try {
      // Save signature first
      final signaturePath = await SignatureService.saveSignatureAsImage(
        signatureBytes,
        fileName:
            'clock_out_${timesheetId}_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      if (signaturePath == null) {
        AppToast.showError(
            context, 'Failed to save signature. Please try again.');
        return;
      }

      debugPrint('Signature saved at: $signaturePath');

      // First, update the timesheet locally right away for better UX
      final now = DateTime.now().toIso8601String();

      // Find and update the timesheet in the local list
      bool timesheetFound = false;
      setState(() {
        for (int i = 0; i < _timesheetService.recentTimesheets.length; i++) {
          final timesheet = _timesheetService.recentTimesheets[i];
          if (timesheet['id'] == timesheetId) {
            timesheetFound = true;

            // Update status and clockOut in the local timesheet copy
            _timesheetService.recentTimesheets[i]['status'] = 'clockout';
            _timesheetService.recentTimesheets[i]['clockOut'] = now;

            // Log that we've updated the status
            debugPrint(
                'IMMEDIATELY updated timesheet $timesheetId status to clockout with time $now');
            break;
          }
        }
      });

      if (!timesheetFound) {
        debugPrint(
            'WARNING: Could not find timesheet $timesheetId to update locally');
      }

      // Use a separate future to prevent UI blocking
      final response = await Future(() async {
        return await _timesheetService.clockOut(timesheetId);
      });

      if (response.isSuccessful) {
        AppToast.showSuccess(
            context, response.message ?? 'Successfully clocked out');

        // Force reset all timesheet cache to ensure next refresh gets fresh data
        _lastTimesheetsRefresh = null;

        // Schedule the dashboard refresh as a microtask to prevent UI freezing
        Future.microtask(() async {
          // Small delay to ensure UI updates first
          await Future.delayed(const Duration(milliseconds: 500));

          // Then do a full refresh from API
          if (mounted) {
            debugPrint('Performing full refresh after successful clock out');
            await _refreshDashboard();
          }
        });
      } else {
        // Revert our optimistic update if the API call failed
        debugPrint(
            'Clock out failed, reverting optimistic update: ${response.message}');
        AppToast.showError(context, response.message ?? 'Failed to clock out');

        // Delete the signature since clock out failed
        await SignatureService.deleteSignature(signaturePath);

        setState(() {
          for (int i = 0; i < _timesheetService.recentTimesheets.length; i++) {
            final timesheet = _timesheetService.recentTimesheets[i];
            if (timesheet['id'] == timesheetId) {
              // Restore previous status (assuming it was 'clockin')
              _timesheetService.recentTimesheets[i]['status'] = 'clockin';
              _timesheetService.recentTimesheets[i]['clockOut'] = null;
              break;
            }
          }
        });
      }
    } catch (e) {
      debugPrint('Error during clock out: $e');
      if (mounted) {
        AppToast.showError(context, 'Error during clock out: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingTimesheets.remove(timesheetId);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dashboardBloc,
      child: Scaffold(
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _pages[_currentIndex],
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            // If switching to appointments tab, refresh appointments
            if (index == 2 && _currentIndex != 2) {
              // Force refresh appointments when navigating to appointment tab
              _stateManager.forceRefreshAppointments();
            }

            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
