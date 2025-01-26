import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/activity_card.dart';
import '../widgets/timesheet_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../shared/app_sizer.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_colors.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimension.getWidth(24),
              vertical: AppDimension.getHeight(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Logo',
                          style: TextStyle(
                            fontSize: AppDimension.getFontSize(24),
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          ' Company',
                          style: TextStyle(
                            fontSize: AppDimension.getFontSize(24),
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                    Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppColors.green200,
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
                SizedBox(height: AppDimension.getHeight(32)),
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
                SizedBox(height: AppDimension.getHeight(8)),
                Text(
                  'Check your activities summary',
                  style: AppTextStyle.activitiesSummary,
                ),
                SizedBox(height: AppDimension.getHeight(24)),
                // Activity cards grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth =
                        (constraints.maxWidth - AppDimension.getWidth(16)) / 2;
                    final cardHeight = cardWidth * 0.9;

                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: AppDimension.isTablet ? 4 : 2,
                      mainAxisSpacing: AppDimension.getHeight(16),
                      crossAxisSpacing: AppDimension.getWidth(16),
                      childAspectRatio: cardWidth / cardHeight,
                      children: const [
                        ActivityCard(
                          title: 'Daily',
                          hours: '2',
                          completedText: '3 appointment',
                          cardColor: AppColors.activityPurple,
                          borderColor: AppColors.activityPurpleBorder,
                        ),
                        ActivityCard(
                          title: 'Weekly',
                          hours: '25',
                          completedText: '21 appointment',
                          cardColor: AppColors.activityGreen,
                          borderColor: AppColors.activityGreenBorder,
                        ),
                        ActivityCard(
                          title: 'Monthly',
                          hours: '250',
                          completedText: '84 appointment',
                          cardColor: AppColors.activityOrange,
                          borderColor: AppColors.activityOrangeBorder,
                        ),
                        ActivityCard(
                          title: 'Pending Appointment',
                          hours: '2',
                          completedText: '84/120',
                          cardColor: AppColors.activityRed,
                          borderColor: AppColors.activityRedBorder,
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: AppDimension.getHeight(32)),
                // Timesheet section
                Text(
                  'Monthly Timesheet',
                  style: AppTextStyle.activitiesSummary,
                ),
                SizedBox(height: AppDimension.getHeight(16)),
                TimesheetCard(
                  visitId: 'VST 1001',
                  clockIn: '10:00',
                  showClockOut: true,
                  onClockOut: () {},
                  onExpandDetails: () {},
                ),
                SizedBox(height: AppDimension.getHeight(16)),
                TimesheetCard(
                  visitId: 'VST 1001',
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
