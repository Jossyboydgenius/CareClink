import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';
import 'app_text_style.dart';

class AppToast {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  static void _showToast(BuildContext context, String message, bool isSuccess) {
    if (_isVisible) {
      _overlayEntry?.remove();
      _isVisible = false;
    }

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
              color: isSuccess 
                  ? AppColors.toastSuccessBackground 
                  : AppColors.toastErrorBackground,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSuccess 
                    ? AppColors.toastSuccessBorder 
                    : AppColors.toastErrorBorder,
                width: 1.w,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    message,
                    style: AppTextStyle.regular14.copyWith(
                      color: Colors.black87,
                    ),
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
                    size: 20.w,
                    color: isSuccess 
                        ? AppColors.toastSuccessBorder 
                        : AppColors.toastErrorBorder,
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
    _showToast(context, message, true);
  }

  static void showError(BuildContext context, String message) {
    _showToast(context, message, false);
  }
}