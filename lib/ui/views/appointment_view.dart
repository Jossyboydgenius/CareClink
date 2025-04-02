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
import '../widgets/user_avatar.dart';
import '../../shared/app_images.dart';
import '../../shared/app_toast.dart';
import '../../data/services/timesheet_service.dart';

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
      'clientName': 'Sarah Johnson',
      'dateTime': '2025-01-14 10:00 - 11:00 AM',
      'timestamp': DateTime(2025, 1, 14, 10, 0),
      'status': AppointmentStatus.scheduled,
    },
    {
      'id': '10002',
      'clientName': 'Michael Chen',
      'dateTime': '2025-01-15 10:00 - 11:00 AM',
      'timestamp': DateTime(2025, 1, 15, 10, 0),
      'status': AppointmentStatus.completed,
    },
    {
      'id': '10003',
      'clientName': 'Emily Rodriguez',
      'dateTime': '2025-01-15 11:30 - 12:30 PM',
      'timestamp': DateTime(2025, 1, 15, 11, 30),
      'status': AppointmentStatus.scheduled,
    },
    {
      'id': '10004',
      'clientName': 'David Thompson',
      'dateTime': '2025-01-15 2:00 - 3:00 PM',
      'timestamp': DateTime(2025, 1, 15, 14, 0),
      'status': AppointmentStatus.pending,
    },
    {
      'id': '10005',
      'clientName': 'Maria Garcia',
      'dateTime': '2025-01-15 3:30 - 4:30 PM',
      'timestamp': DateTime(2025, 1, 15, 15, 30),
      'status': AppointmentStatus.reschedule,
    },
    {
      'id': '10006',
      'clientName': 'James Wilson',
      'dateTime': '2025-01-15 5:00 - 6:00 PM',
      'timestamp': DateTime(2025, 1, 15, 17, 0),
      'status': AppointmentStatus.scheduled,
    },
  ];

  List<Map<String, dynamic>> _filteredAppointments = [];
  List<Map<String, dynamic>> _recentTimesheet = [];
  final TimesheetService _timesheetService = TimesheetService();

  @override
  void initState() {
    super.initState();
    _filteredAppointments = List.from(_appointments);
  }

  void _filterAppointments(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAppointments = List.from(_appointments);
      } else {
        _filteredAppointments = _appointments
            .where((appointment) =>
                appointment['clientName'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  bool _isAppointmentElapsed(DateTime timestamp) {
    // For testing purposes, we'll consider appointments with status 'completed' as elapsed
    final selectedAppointment = _appointments.firstWhere(
      (appointment) => appointment['timestamp'] == timestamp,
      orElse: () => {'status': AppointmentStatus.none},
    );
    
    return selectedAppointment['status'] == AppointmentStatus.completed;
  }

  void _handleClockIn() {
    if (_selectedAppointmentId == null) return;

    final selectedAppointment = _appointments.firstWhere(
      (appointment) => appointment['id'] == _selectedAppointmentId,
    );

    final isElapsed = _isAppointmentElapsed(selectedAppointment['timestamp']);

    if (isElapsed) {
      // Show manual clock entry dialog for elapsed appointments
      showDialog(
        context: context,
        builder: (context) => ManualClockEntryDialog(
          appointmentId: selectedAppointment['id'],
          clientName: selectedAppointment['clientName'],
          dateTime: selectedAppointment['dateTime'],
          status: selectedAppointment['status'],
          onSave: (date, clockIn, clockOut) {
            _moveToRecentTimesheet(selectedAppointment, clockInTime: clockIn);
            NavigationService.goBack();
          },
        ),
      );
    } else {
      // Direct clock in for current/future appointments
      final now = TimeOfDay.now();
      _moveToRecentTimesheet(selectedAppointment, clockInTime: now);
    }
  }

  void _moveToRecentTimesheet(Map<String, dynamic> appointment, {TimeOfDay? clockInTime}) async {
    if (!mounted) return;

    final now = DateTime.now();
    final clockIn = clockInTime ?? TimeOfDay.fromDateTime(now);
    
    // Check if timesheet already exists
    final existingTimesheet = await _timesheetService.getTimesheet(appointment['id']);
    if (existingTimesheet != null) {
      AppToast.showError(context, 'Timesheet already exists for this appointment');
      return;
    }
    
    final timesheetEntry = {
      'id': appointment['id'],
      'clientName': appointment['clientName'],
      'clockIn': '${clockIn.hour}:${clockIn.minute.toString().padLeft(2, '0')}',
      'clockOut': '',
      'duration': '',
      'status': 'clockin',
    };

    _timesheetService.addTimesheet(timesheetEntry);

    // Show success message first
    AppToast.showSuccess(context, 'Successfully clocked in');

    // Update state before navigating
    setState(() {
      // Remove from appointments list
      _appointments.removeWhere((a) => a['id'] == appointment['id']);
      _filteredAppointments = List.from(_appointments);
      _selectedAppointmentId = null;
    });

    // Navigate to dashboard with the timesheet data
    if (mounted) {
      await NavigationService.pushReplacementNamed(
        AppRoutes.dashboardView,
        arguments: timesheetEntry,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedAppointment = _selectedAppointmentId != null 
        ? _appointments.firstWhere((a) => a['id'] == _selectedAppointmentId)
        : null;
    
    final isElapsed = selectedAppointment != null 
        ? _isAppointmentElapsed(selectedAppointment['timestamp'])
        : false;

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
                  AppImages(
                    imagePath: AppImageData.careclinkLogo,
                    height: 60,
                    width: 160,
                  ),
                  const UserAvatar(),
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
                          vertical: 8.h,
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
                                onChanged: _filterAppointments,
                                decoration: InputDecoration(
                                  hintText: 'Search Client Name...',
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
                      ..._filteredAppointments.map((appointment) => Column(
                        children: [
                          AppointmentCard(
                            clientName: appointment['clientName'],
                            dateTime: appointment['dateTime'],
                            status: appointment['status'],
                            isSelected: _selectedAppointmentId == appointment['id'],
                            onTap: () {
                              setState(() {
                                _selectedAppointmentId = appointment['id'];
                              });
                            },
                          ),
                          if (appointment != _filteredAppointments.last) AppSpacing.v12(),
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
                text: isElapsed ? 'Manual Clock In' : 'Clock In',
                onPressed: _handleClockIn,
                isLoading: _isLoading,
                enabled: _selectedAppointmentId != null,
                backgroundColor: AppColors.green,
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
} 