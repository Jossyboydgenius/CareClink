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
  final List<Map<String, dynamic>> _appointments = [
    {
      'id': '10001',
      'dateTime': '2025-01-14 10:00AM - 11:00AM',
      'status': AppointmentStatus.pending,
    },
    {
      'id': '10002',
      'dateTime': '2025-01-15 10:00AM - 11:00AM',
      'status': AppointmentStatus.none,
    },
    {
      'id': '10003',
      'dateTime': '2025-01-15 10:00AM - 11:00AM',
      'status': AppointmentStatus.none,
    },
    {
      'id': '10004',
      'dateTime': '2025-01-15 10:00AM - 11:00AM',
      'status': AppointmentStatus.none,
    },
    {
      'id': '10005',
      'dateTime': '2025-01-15 10:00AM - 11:00AM',
      'status': AppointmentStatus.reschedule,
    },
  ];

  void _addNewAppointment(String appointmentId, DateTime date, TimeOfDay clockIn, TimeOfDay clockOut) {
    final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final formattedClockIn = '${clockIn.hourOfPeriod == 0 ? 12 : clockIn.hourOfPeriod}:${clockIn.minute.toString().padLeft(2, '0')}${clockIn.period == DayPeriod.am ? 'AM' : 'PM'}';
    final formattedClockOut = '${clockOut.hourOfPeriod == 0 ? 12 : clockOut.hourOfPeriod}:${clockOut.minute.toString().padLeft(2, '0')}${clockOut.period == DayPeriod.am ? 'AM' : 'PM'}';
    
    setState(() {
      _appointments.add({
        'id': appointmentId,
        'dateTime': '$formattedDate $formattedClockIn - $formattedClockOut',
        'status': AppointmentStatus.pending,
      });
    });
  }

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
                      ..._appointments.map((appointment) => Column(
                        children: [
                          AppointmentCard(
                            appointmentId: appointment['id'],
                            dateTime: appointment['dateTime'],
                            status: appointment['status'],
                            isSelected: _selectedAppointmentId == appointment['id'],
                            onTap: () {
                              setState(() {
                                _selectedAppointmentId = appointment['id'];
                              });
                            },
                          ),
                          if (appointment != _appointments.last) AppSpacing.v12(),
                        ],
                      )).toList(),
                      AppSpacing.v12(),
                    ],
                  ),
                ),
              ),
            ),
            // Clock In button
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(
                  top: BorderSide(color: AppColors.grey200),
                ),
              ),
              padding: EdgeInsets.all(16.w),
              child: AppButton(
                text: 'Clock In',
                onPressed: _handleClockIn,
                isLoading: _isLoading,
                enabled: _selectedAppointmentId != null,
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
    final nextId = (int.parse(_appointments.last['id']) + 1).toString();
    showDialog(
      context: context,
      builder: (context) => ManualClockEntryDialog(
        appointmentId: nextId,
        dateTime: _appointments.last['dateTime'],
        onSave: (date, clockIn, clockOut) {
          _addNewAppointment(nextId, date, clockIn, clockOut);
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 