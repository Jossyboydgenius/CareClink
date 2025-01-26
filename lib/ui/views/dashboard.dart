import 'package:flutter/material.dart';
import '../widgets/activity_card.dart';
import '../widgets/timesheet_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../../shared/app_sizer.dart';
import '../../shared/app_text_style.dart';

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
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Text(
                          ' Company',
                          style: TextStyle(
                            fontSize: AppDimension.getFontSize(24),
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: AppDimension.getWidth(40),
                      height: AppDimension.getWidth(40),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C48C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'JD',
                          style: TextStyle(
                            fontSize: AppDimension.getFontSize(14),
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
                    final cardWidth = (constraints.maxWidth - AppDimension.getWidth(16)) / 2;
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
                          cardColor: Color(0xFF6C63FF),
                          borderColor: Color(0xFFE8E6FF),
                        ),
                        ActivityCard(
                          title: 'Weekly',
                          hours: '25',
                          completedText: '21 appointment',
                          cardColor: Color(0xFF00C48C),
                          borderColor: Color(0xFFE6FAF5),
                        ),
                        ActivityCard(
                          title: 'Monthly',
                          hours: '250',
                          completedText: '84 appointment',
                          cardColor: Color(0xFFFF9500),
                          borderColor: Color(0xFFFFF5E5),
                        ),
                        ActivityCard(
                          title: 'Pending Appointment',
                          hours: '2',
                          completedText: '84/120',
                          cardColor: Color(0xFFFF3B30),
                          borderColor: Color(0xFFFFE5E5),
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
                  onClockOut: () {},
                  onExpandDetails: () {},
                ),
                SizedBox(height: AppDimension.getHeight(16)),
                TimesheetCard(
                  visitId: 'VST 1001',
                  clockIn: '10:00',
                  clockOut: '10:30',
                  duration: '30min',
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