import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_text_style.dart';

class ActivityCard extends StatelessWidget {
  final String title;
  final String hours;
  final String completedText;
  final Color cardColor;
  final Color borderColor;

  const ActivityCard({
    super.key,
    required this.title,
    required this.hours,
    required this.completedText,
    required this.cardColor,
    required this.borderColor,
  });

  TextStyle get _titleStyle => AppTextStyle.medium12.copyWith(
        color: Colors.grey,
      );

  TextStyle get _hoursStyle => AppTextStyle.semibold24;

  TextStyle get _completedTextStyle => AppTextStyle.medium12;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight - 24.h;
          final contentHeight = availableHeight / 3;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: contentHeight,
                child: Text(
                  title,
                  style: _titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                height: contentHeight,
                child: Text(
                  '${hours}hrs',
                  style: _hoursStyle,
                ),
              ),
              SizedBox(
                height: contentHeight,
                child: Row(
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: cardColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'Completed: $completedText',
                        style: _completedTextStyle.copyWith(color: cardColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 