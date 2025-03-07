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
import '../../shared/app_sizer.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_images.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardBloc()..add(const LoadDashboardSummaries()),
      child: Scaffold(
        body: SafeArea(
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
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          'JD',
                          style: AppTextStyle.semibold14.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
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
                              'Monthly Timesheet',
                              style: AppTextStyle.activitiesSummary,
                            ),
                            SizedBox(height: AppDimension.getHeight(16)),
                            TimesheetCard(
                              appointmentId: '1001',
                              name: 'Jane Cooper',
                              clockIn: '10:00',
                              showClockOut: true,
                              onClockOut: () {},
                              onExpandDetails: () {},
                            ),
                            SizedBox(height: AppDimension.getHeight(16)),
                            TimesheetCard(
                              appointmentId: '1002',
                              name: 'Wade Warren',
                              clockIn: '10:00',
                              clockOut: '10:30',
                              duration: '30min',
                              showClockOut: false,
                              onClockOut: () {},
                              onExpandDetails: () {},
                            ),
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
