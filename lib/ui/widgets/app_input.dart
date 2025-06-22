import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';

class AppInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final Function(String)? onChanged;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? initialValue;
  final bool readOnly;
  final VoidCallback? onTap;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final AutovalidateMode? autovalidateMode;
  final TextCapitalization textCapitalization;

  const AppInput({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.suffixIcon,
    this.prefixIcon,
    this.initialValue,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.borderRadius,
    this.contentPadding,
    this.autovalidateMode,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: AppTextStyle.medium14,
          ),
          SizedBox(height: 8.h),
        ],
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          style: AppTextStyle.regular14,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          readOnly: readOnly,
          onTap: onTap,
          maxLines: maxLines,
          minLines: minLines,
          enabled: enabled,
          focusNode: focusNode,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          autovalidateMode: autovalidateMode,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyle.regular14.copyWith(
              color: AppColors.grey300,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            isDense: true, // This helps to reduce the height
            contentPadding: contentPadding ??
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: AppColors.grey400,
                width: 1.w,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: AppColors.grey400,
                width: 1.w,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 1.w,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: AppColors.red,
                width: 1.w,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: AppColors.red,
                width: 1.w,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
