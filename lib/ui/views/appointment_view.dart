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
import '../widgets/appointment_skeleton.dart';
import '../../shared/app_images.dart';
import '../../shared/app_toast.dart';
import '../../data/services/timesheet_service.dart';
import '../../app/locator.dart';
import '../../data/models/appointment_model.dart';
import '../../data/services/appointment_service.dart';

class AppointmentView extends StatefulWidget {
  const AppointmentView({super.key});

  @override
  State<AppointmentView> createState() => _AppointmentViewState();
}

class _AppointmentViewState extends State<AppointmentView> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String? _selectedAppointmentId;
  List<AppointmentModel> _appointments = [];
  List<AppointmentModel> _filteredAppointments = [];
  List<Map<String, dynamic>> _recentTimesheet = [];
  final TimesheetService _timesheetService = TimesheetService();
  final AppointmentService _appointmentService = locator<AppointmentService>();

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() => _isLoading = true);
    try {
      final appointments = await _appointmentService.getAppointments();
      setState(() {
        _appointments = appointments;
    _filteredAppointments = List.from(_appointments);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading appointments: $e');
      setState(() => _isLoading = false);
      AppToast.showError(context, 'Failed to load appointments');
    }
  }

  void _filterAppointments(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAppointments = List.from(_appointments);
      } else {
        _filteredAppointments = _appointments
            .where((appointment) =>
                appointment.clientName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  bool _isAppointmentElapsed(DateTime timestamp) {
    // Only pending appointments can be considered as elapsed
    final selectedAppointment = _appointments.firstWhere(
      (appointment) => appointment.timestamp == timestamp,
      orElse: () => AppointmentModel(
        id: '',
        clientName: '',
        dateTime: '',
        timestamp: DateTime.now(),
        status: AppointmentStatus.none,
      ),
    );
    
    return selectedAppointment.status == AppointmentStatus.pending;
  }

  bool _canInteractWithAppointment(AppointmentStatus status) {
    // Only scheduled and pending appointments can be interacted with
    switch (status) {
      case AppointmentStatus.scheduled:
        return true;
      case AppointmentStatus.pending:
        return true;
      case AppointmentStatus.completed:
      case AppointmentStatus.reschedule:
      default:
        return false;
    }
  }

  void _handleClockIn() async {
    if (_selectedAppointmentId == null) return;

    final selectedAppointment = _appointments.firstWhere(
      (appointment) => appointment.id == _selectedAppointmentId,
    );

    // Check if appointment can be interacted with
    if (!_canInteractWithAppointment(selectedAppointment.status)) {
      AppToast.showError(context, 'This appointment cannot be clocked in');
      return;
    }

    final isElapsed = _isAppointmentElapsed(selectedAppointment.timestamp);

    if (isElapsed) {
      // Show manual clock entry dialog for pending appointments
      showDialog(
        context: context,
        builder: (context) => ManualClockEntryDialog(
          appointmentId: selectedAppointment.id,
          clientName: selectedAppointment.clientName,
          dateTime: DateTime.parse(selectedAppointment.dateTime),
          status: selectedAppointment.status,
          onSave: (date, clockIn, clockOut, reason) async {
            try {
              final clockInDateTime = DateTime(
                date.year,
                date.month,
                date.day,
                clockIn.hour,
                clockIn.minute,
              );

              final response = await _appointmentService.manualClockIn(
                appointmentId: selectedAppointment.id,
                date: date,
                clockIn: clockInDateTime,
                reason: reason,
              );

              if (!mounted) return;

              if (response.isSuccessful) {
                final timesheet = response.data['timesheet'];
                _moveToRecentTimesheet(selectedAppointment, clockInTime: clockIn, timesheetData: timesheet);
                NavigationService.goBack();
                AppToast.showSuccess(context, response.message ?? 'Successfully clocked in');
              } else {
                AppToast.showError(context, response.message ?? 'Failed to clock in');
              }
            } catch (e) {
              debugPrint('Error during manual clock in: $e');
              if (!mounted) return;
              AppToast.showError(context, 'Failed to clock in: $e');
            }
          },
        ),
      );
    } else {
      // Direct clock in for scheduled appointments
      try {
        setState(() => _isLoading = true);
        
        final response = await _appointmentService.clockIn(
          appointmentId: selectedAppointment.id,
          date: DateTime.now(),
        );

        if (!mounted) return;

        if (response.isSuccessful) {
          final timesheet = response.data['timesheet'];
          final now = TimeOfDay.now();
          _moveToRecentTimesheet(selectedAppointment, clockInTime: now, timesheetData: timesheet);
          AppToast.showSuccess(context, response.message ?? 'Successfully clocked in');
        } else {
          AppToast.showError(context, response.message ?? 'Failed to clock in');
        }
      } catch (e) {
        debugPrint('Error during clock in: $e');
        if (!mounted) return;
        AppToast.showError(context, 'Failed to clock in: $e');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _moveToRecentTimesheet(AppointmentModel appointment, {
    TimeOfDay? clockInTime,
    Map<String, dynamic>? timesheetData,
  }) async {
    if (!mounted) return;

    final now = DateTime.now();
    final clockIn = clockInTime ?? TimeOfDay.fromDateTime(now);
    
    // Use the timesheet data from the API response if available
    final timesheetEntry = timesheetData ?? {
      'id': appointment.id,
      'clientName': appointment.clientName,
      'clockIn': '${clockIn.hour}:${clockIn.minute.toString().padLeft(2, '0')}',
      'clockOut': '',
      'duration': '',
      'status': 'clockin',
    };

    // Show success message first
    AppToast.showSuccess(context, 'Successfully clocked in');

    // Update state before navigating
    setState(() {
      // Remove from appointments list
      _appointments.removeWhere((a) => a.id == appointment.id);
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
        ? _appointments.firstWhere((a) => a.id == _selectedAppointmentId)
        : null;
    
    final isElapsed = selectedAppointment != null 
        ? _isAppointmentElapsed(selectedAppointment.timestamp)
        : false;

    final canInteract = selectedAppointment != null 
        ? _canInteractWithAppointment(selectedAppointment.status)
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
              child: RefreshIndicator(
                onRefresh: _loadAppointments,
              child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                        if (_appointments.isNotEmpty)
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
                        if (_isLoading)
                          Column(
                            children: List.generate(3, (index) => Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: const AppointmentSkeleton(),
                            )),
                          )
                        else if (_appointments.isEmpty)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 32.h),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 48.w,
                                    color: AppColors.grey300,
                                  ),
                                  AppSpacing.v16(),
                                  Text(
                                    'No Appointments Available',
                                    style: AppTextStyle.regular14.copyWith(
                                      color: AppColors.grey300,
                                    ),
                                  ),
                                  AppSpacing.v8(),
                                  Text(
                                    'Pull to refresh to check for new appointments',
                                    style: AppTextStyle.regular12.copyWith(
                                      color: AppColors.grey300,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                      ..._filteredAppointments.map((appointment) => Column(
                        children: [
                          AppointmentCard(
                                clientName: appointment.clientName,
                                dateTime: appointment.dateTime,
                                status: appointment.status,
                                isSelected: _selectedAppointmentId == appointment.id,
                            onTap: () {
                              setState(() {
                                    _selectedAppointmentId = appointment.id;
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
                onPressed: canInteract ? _handleClockIn : null,
                isLoading: _isLoading,
                enabled: _selectedAppointmentId != null && canInteract,
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