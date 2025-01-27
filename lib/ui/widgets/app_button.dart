import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';

class AppButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;
  final TextStyle? style;
  final bool enabled;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.style,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 48.h,
      child: ElevatedButton(
        onPressed: isLoading || !enabled || onPressed == null ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          disabledBackgroundColor: AppColors.grey200,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
        ),
        child: isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    backgroundColor ?? AppColors.primary,
                  ),
                ),
              )
            : Text(
                text,
                style: style ??
                    AppTextStyle.semibold16.copyWith(
                      color: textColor ?? Colors.white,
                    ),
              ),
      ),
    );
  }
} 