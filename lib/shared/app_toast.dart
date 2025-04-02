import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';
import 'app_text_style.dart';
import 'app_icons.dart';

class AppToast {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  static void _showToast(
    BuildContext context, {
    required String title,
    required String message,
    required bool isSuccess,
    required Widget icon,
  }) {
    if (_isVisible) {
      _overlayEntry?.remove();
      _isVisible = false;
    }

    final Color backgroundColor = isSuccess 
        ? AppColors.toastSuccessBackground 
        : AppColors.toastErrorBackground;
    final Color borderColor = isSuccess 
        ? AppColors.toastSuccessBorder 
        : AppColors.toastErrorBorder;
    final Color iconColor = isSuccess 
        ? AppColors.green 
        : AppColors.red;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16.h,
        left: 16.w,
        right: 16.w,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: borderColor,
                width: 1.w,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon,
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyle.regular14.copyWith(
                          color: iconColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        message,
                        style: AppTextStyle.regular12.copyWith(
                          color: iconColor,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () {
                    _overlayEntry?.remove();
                    _isVisible = false;
                  },
                  child: Icon(
                    Icons.close,
                    size: 16.w,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    _isVisible = true;
    Overlay.of(context).insert(_overlayEntry!);

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (_isVisible) {
        _overlayEntry?.remove();
        _isVisible = false;
      }
    });
  }

  static void showSuccess(BuildContext context, String message) {
    _showToast(
      context,
      title: 'Success',
      message: message,
      isSuccess: true,
      icon: AppIcons(
        icon: AppIconData.roundCheck,
        size: 20.w,
        color: AppColors.green,
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    _showToast(
      context,
      title: 'Error',
      message: message,
      isSuccess: false,
      icon: Icon(
        Icons.info_outline,
        size: 20.w,
        color: AppColors.red,
      ),
    );
  }

  static void showAppointmentCompleted(BuildContext context, String clientName) {
    _showToast(
      context,
      title: 'Appointment Marked as Completed',
      message: 'The appointment with $clientName was successfully completed',
      isSuccess: true,
      icon: AppIcons(
        icon: AppIconData.calendar,
        size: 20.w,
        color: AppColors.green,
      ),
    );
  }

  static void showTimesheetRejected(BuildContext context, String dateRange) {
    _showToast(
      context,
      title: 'Timesheet Rejected',
      message: 'Your timesheet for $dateRange has been Rejected',
      isSuccess: false,
      icon: Icon(
        Icons.info_outline,
        size: 20.w,
        color: AppColors.red,
      ),
    );
  }

  static void showMissedClockIn(BuildContext context, String date) {
    _showToast(
      context,
      title: 'Missed Clock-In',
      message: 'You did not clock in for your appointment on $date. Please update your timesheet.',
      isSuccess: false,
      icon: Icon(
        Icons.info_outline,
        size: 20.w,
        color: AppColors.red,
      ),
    );
  }
}