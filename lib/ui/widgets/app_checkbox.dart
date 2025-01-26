import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';

class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: value ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: value ? AppColors.primary : AppColors.grey400,
            width: 1.5,
          ),
        ),
        child: value
            ? Icon(
                Icons.check,
                size: 16.w,
                color: Colors.white,
              )
            : null,
      ),
    );
  }
} 