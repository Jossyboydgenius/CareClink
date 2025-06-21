import 'package:careclink/shared/app_spacing.dart';
import 'package:careclink/ui/widgets/skeleton_timesheet_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dashboard/dashboard_bloc/dashboard_bloc.dart';
import 'dashboard/dashboard_bloc/dashboard_event.dart';
import 'dashboard/dashboard_bloc/dashboard_state.dart';
import '../widgets/activity_card.dart';
import '../widgets/skeleton_activity_card.dart';
import '../widgets/timesheet_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/user_avatar.dart';
import '../../shared/app_sizer.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_images.dart';
import '../../shared/app_toast.dart';
import '../../data/services/timesheet_service.dart';
import '../../app/navigation_state_manager.dart';
import '../../app/locator.dart';
import 'notification_view.dart';
import 'appointment_view.dart';
import '../../shared/app_error_handler.dart';

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
        setState(() {
          _timesheetService
              .clearTimesheets(); // Clear existing timesheets first
          final timesheets = response.data['timesheets'] as List;

          for (final timesheet in timesheets) {
            final clientData = timesheet['client'];
            String clientName = 'Unknown Client';
            if (clientData != null) {
              if (clientData is Map) {
                clientName =
                    clientData['fullname']?.toString() ?? 'Unknown Client';
              } else if (clientData is String) {
                clientName = clientData;
              }
            }

            _timesheetService.addTimesheet({
              'id': timesheet['_id'],
              'clientName': clientName,
              'clockIn': timesheet['clockIn'],
              'clockOut': timesheet['clockOut'],
              'duration': timesheet['duration']?.toString() ?? '0',
              'status': timesheet['clockOut'] == null ? 'clockin' : 'clockout',
            });
          }

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
    // Clear existing timesheets first
    setState(() {
      _timesheetService.clearTimesheets();
      _timesheetsLoaded = false;
      _lastTimesheetsRefresh = null;
      _noTimesheetsFound = false; // Reset flag on refresh
    });

    // Fetch new data with force refresh
    await Future.wait([
      _fetchTimesheets(),
      Future(() =>
          _dashboardBloc.add(const LoadDashboardSummaries(forceRefresh: true))),
    ]);

    // Mark in our state manager that we've refreshed
    _stateManager.markDashboardRefreshed();
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
              hours:
                  '${state.statusSummary?.pending ?? 0} ${(state.statusSummary?.pending ?? 0) <= 1 ? 'hr' : 'hrs'}',
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
          final bool canClockOut = !isLoading &&
              (timesheet['status'] == 'clockin' ||
                  timesheet['clockOut'] == null);

          return Column(
            children: [
              TimesheetCard(
                clientName: timesheet['clientName'],
                staffName: timesheet['clientName'],
                clockIn: timesheet['clockIn'],
                clockOut: timesheet['clockOut'],
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
    // Set loading state immediately
    setState(() {
      _loadingTimesheets.add(timesheetId);
    });

    try {
      // Use a separate future to prevent UI blocking
      final response = await Future(() async {
        return await _timesheetService.clockOut(timesheetId);
      });

      if (response.isSuccessful) {
        AppToast.showSuccess(
            context, response.message ?? 'Successfully clocked out');

        // Schedule the dashboard refresh as a microtask to prevent UI freezing
        Future.microtask(() async {
          await _refreshDashboard();
        });
      } else {
        AppToast.showError(context, response.message ?? 'Failed to clock out');
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
