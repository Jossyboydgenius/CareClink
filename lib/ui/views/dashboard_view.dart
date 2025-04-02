import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.recentTimesheet != null) {
      // Check if timesheet already exists before adding
      final existingTimesheet = _timesheetService.getTimesheet(widget.recentTimesheet!['id']);
      if (existingTimesheet == null) {
        _timesheetService.addTimesheet(widget.recentTimesheet!);
      }
    }
    
    // Initialize pages with keeping state
    _pages.addAll([
      _buildDashboardContent(),
      const NotificationView(),
      const AppointmentView(),
    ]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleClockOut(String appointmentId) {
    final now = TimeOfDay.now();
    final timesheet = _timesheetService.getTimesheet(appointmentId);
    if (timesheet != null) {
      final clockInTime = timesheet['clockIn'].split(':');
      final clockInHour = int.parse(clockInTime[0]);
      final clockInMinute = int.parse(clockInTime[1]);
      
      // Calculate duration in minutes
      final durationInMinutes = ((now.hour - clockInHour) * 60 + (now.minute - clockInMinute));
      
      final updatedTimesheet = {
        ...timesheet,
        'clockOut': '${now.hour}:${now.minute.toString().padLeft(2, '0')}',
        'duration': '${durationInMinutes}min',
        'status': 'clockout',
      };
      _timesheetService.updateTimesheet(appointmentId, updatedTimesheet);
      setState(() {}); // Trigger rebuild to reflect changes
      AppToast.showSuccess(context, 'Successfully clocked out');
    }
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
    return BlocProvider(
      create: (context) => DashboardBloc()..add(const LoadDashboardSummaries()),
      child: Column(
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

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
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
                        if (_timesheetService.recentTimesheets.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 32.h),
                              child: Text(
                                'No recent timesheets',
                                style: AppTextStyle.regular14.copyWith(
                                  color: AppColors.grey300,
                                ),
                              ),
                            ),
                          )
                        else
                          ...List.generate(_timesheetService.recentTimesheets.length, (index) {
                            final timesheet = _timesheetService.recentTimesheets[index];
                            return Column(
                              children: [
                                TimesheetCard(
                                  clientName: timesheet['clientName'],
                                  staffName: timesheet['clientName'],
                                  clockIn: timesheet['clockIn'],
                                  clockOut: timesheet['clockOut'],
                                  duration: timesheet['duration'],
                                  status: timesheet['status'],
                                  onClockOut: () => _handleClockOut(timesheet['id']),
                                  onExpandDetails: () {},
                                ),
                                if (index != _timesheetService.recentTimesheets.length - 1)
                                  SizedBox(height: AppDimension.getHeight(16)),
                              ],
                            );
                          }),
                        // Add bottom padding to ensure content doesn't get hidden behind bottom nav
                        SizedBox(height: AppDimension.getHeight(80)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
