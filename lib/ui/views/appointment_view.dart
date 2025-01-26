import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_spacing.dart';
import '../../app/routes/app_routes.dart';
import '../../data/services/navigator_service.dart';
import '../widgets/appointment_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/app_button.dart';
import '../widgets/manual_clock_entry_dialog.dart';

class AppointmentView extends StatefulWidget {
  const AppointmentView({super.key});

  @override
  State<AppointmentView> createState() => _AppointmentViewState();
}

class _AppointmentViewState extends State<AppointmentView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _selectedAppointmentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Logo',
                        style: AppTextStyle.semibold24.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        ' Company',
                        style: AppTextStyle.regular24.copyWith(
                          color: AppColors.grey300,
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
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today Appointment',
                        style: AppTextStyle.semibold24,
                      ),
                      AppSpacing.v8(),
                      Text(
                        'Select the appointment you will like to clock in.',
                        style: AppTextStyle.regular14.copyWith(
                          color: AppColors.grey300,
                        ),
                      ),
                      AppSpacing.v16(),
                      // Search bar
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.grey200),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: AppColors.grey300,
                              size: 24.w,
                            ),
                            AppSpacing.h8(),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search Appointment ID...',
                                  hintStyle: AppTextStyle.regular14.copyWith(
                                    color: AppColors.grey300,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppSpacing.v16(),
                      // Appointment cards
                      AppointmentCard(
                        appointmentId: '10001',
                        dateTime: '2025-01-14 10:00 - 11:00 AM',
                        status: AppointmentStatus.pending,
                        isSelected: _selectedAppointmentId == '10001',
                        onTap: () {
                          setState(() {
                            _selectedAppointmentId = '10001';
                          });
                        },
                      ),
                      AppSpacing.v12(),
                      AppointmentCard(
                        appointmentId: '10002',
                        dateTime: '2025-01-15 10:00 - 11:00 AM',
                        isSelected: _selectedAppointmentId == '10002',
                        onTap: () {
                          setState(() {
                            _selectedAppointmentId = '10002';
                          });
                        },
                      ),
                      AppSpacing.v12(),
                      AppointmentCard(
                        appointmentId: '10003',
                        dateTime: '2025-01-15 10:00 - 11:00 AM',
                        isSelected: _selectedAppointmentId == '10003',
                        onTap: () {
                          setState(() {
                            _selectedAppointmentId = '10003';
                          });
                        },
                      ),
                      AppSpacing.v12(),
                      AppointmentCard(
                        appointmentId: '10004',
                        dateTime: '2025-01-15 10:00 - 11:00 AM',
                        isSelected: _selectedAppointmentId == '10004',
                        onTap: () {
                          setState(() {
                            _selectedAppointmentId = '10004';
                          });
                        },
                      ),
                      AppSpacing.v12(),
                      AppointmentCard(
                        appointmentId: '10005',
                        dateTime: '2025-01-15 10:00 - 11:00 AM',
                        status: AppointmentStatus.reschedule,
                        isSelected: _selectedAppointmentId == '10005',
                        onTap: () {
                          setState(() {
                            _selectedAppointmentId = '10005';
                          });
                        },
                      ),
                      AppSpacing.v24(),
                    ],
                  ),
                ),
              ),
            ),
            // Clock In button
            Padding(
              padding: EdgeInsets.all(24.w),
              child: AppButton(
                text: 'Clock In',
                onPressed: _handleClockIn,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index != 2) {
            NavigationService.pushNamed(AppRoutes.dashboardView);
          }
        },
      ),
    );
  }

  void _handleClockIn() {
    showDialog(
      context: context,
      builder: (context) => ManualClockEntryDialog(
        appointmentId: '10001',
        dateTime: '2025-01-14 10:00 - 11:00 AM',
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 