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
import 'notification_view.dart';
import 'appointment_view.dart';

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
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final Set<String> _loadingTimesheets = {};
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _dashboardBloc = DashboardBloc()..add(const LoadDashboardSummaries());
    
    if (widget.recentTimesheet != null) {
      // Check if timesheet already exists before adding
      final existingTimesheet = _timesheetService.getTimesheet(widget.recentTimesheet!['appointmentId']);
      if (existingTimesheet == null) {
        final clientData = widget.recentTimesheet!['client'];
        String clientName = 'Unknown Client';
        if (clientData != null) {
          if (clientData is Map) {
            clientName = clientData['fullname']?.toString() ?? 'Unknown Client';
          } else if (clientData is String) {
            clientName = clientData;
          }
        }
        
        _timesheetService.addTimesheet({
          'id': widget.recentTimesheet!['appointmentId'],
          'clientName': clientName,
          'clockIn': widget.recentTimesheet!['clockIn'],
          'clockOut': widget.recentTimesheet!['clockOut'],
          'duration': widget.recentTimesheet!['duration']?.toString() ?? '0',
          'status': 'clockin',
        });
      }
    }
    
    // Initialize pages with keeping state
    _pages.addAll([
      _buildDashboardContent(),
      const NotificationView(),
      const AppointmentView(),
    ]);

    // Immediately fetch timesheets when mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialLoad();
    });
  }

  @override
  void dispose() {
    _dashboardBloc.close();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initialLoad() async {
    setState(() {
      _isInitialLoading = true;
    });
    await _fetchTimesheets();
    setState(() {
      _isInitialLoading = false;
    });
  }

  Future<void> _fetchTimesheets() async {
    final response = await _timesheetService.getTimesheets();
    if (response.isSuccessful && response.data != null) {
      setState(() {
        _timesheetService.clearTimesheets();
        final timesheets = response.data['timesheets'] as List;
        for (final timesheet in timesheets) {
          final clientData = timesheet['client'];
          String clientName = 'Unknown Client';
          if (clientData != null) {
            if (clientData is Map) {
              clientName = clientData['fullname']?.toString() ?? 'Unknown Client';
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
            'status': timesheet['clockOut'] == null ? 'clockin' : 'clockout',  // Set status based on clockOut
          });
        }
      });
    } else {
      AppToast.showError(context, response.message ?? 'Failed to fetch timesheets');
    }
  }

  Future<void> _refreshDashboard() async {
    // Clear existing timesheets first
    setState(() {
      _timesheetService.clearTimesheets();
    });
    
    // Fetch new data
    await Future.wait([
      _fetchTimesheets(),
      Future(() => _dashboardBloc.add(const LoadDashboardSummaries())),
    ]);
  }

  Widget _buildActivityCards(BuildContext context, DashboardState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - AppDimension.getWidth(16)) / 2;
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
              completedText: state.monthlySummary?.completed ?? '0 appointments',
              cardColor: AppColors.activityOrange,
              borderColor: AppColors.activityOrangeBorder,
            ),
            ActivityCard(
              title: 'Pending Appointment',
              hours: '${state.statusSummary?.pending ?? 0} ${(state.statusSummary?.pending ?? 0) <= 1 ? 'hr' : 'hrs'}',
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
    if (_isInitialLoading || _timesheetService.recentTimesheets.isEmpty) {
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

    return Column(
      children: [
        ..._timesheetService.recentTimesheets.map((timesheet) {
          final String timesheetId = timesheet['id'];
          final bool isLoading = _loadingTimesheets.contains(timesheetId);
          final bool canClockOut = !isLoading && (timesheet['status'] == 'clockin' || timesheet['clockOut'] == null);
          
          return Column(
            children: [
              TimesheetCard(
                clientName: timesheet['clientName'],
                staffName: timesheet['clientName'],
                clockIn: timesheet['clockIn'],
                clockOut: timesheet['clockOut'],
                duration: timesheet['duration'],
                status: timesheet['status'],
                onClockOut: canClockOut ? () => _handleClockOut(timesheetId) : null,
                onExpandDetails: () {},
                isClockingOut: isLoading,
              ),
              if (timesheet != _timesheetService.recentTimesheets.last)
                AppSpacing.v16(),
            ],
          );
        }).toList(),
      ],
    );
  }

  Future<void> _handleClockOut(String timesheetId) async {
    // Set loading state immediately
    setState(() {
      _loadingTimesheets.add(timesheetId);
    });

    try {
      final response = await _timesheetService.clockOut(timesheetId);
      if (response.isSuccessful) {
        AppToast.showSuccess(context, response.message ?? 'Successfully clocked out');
        // Refresh everything
        await _refreshDashboard();
      } else {
        AppToast.showError(context, response.message ?? 'Failed to clock out');
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
          child: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
