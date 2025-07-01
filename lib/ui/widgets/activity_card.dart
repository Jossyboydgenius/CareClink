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

  // Parse hours string to create styled text with smaller minute text
  Widget _buildStyledHours() {
    // Handle formats like "0h 49m", "1h 2m", "0 hr", etc.
    final hoursText = hours.trim();

    // Check if it contains both h and m (like "0h 49m")
    if (hoursText.contains('h') && hoursText.contains('m')) {
      final parts = hoursText.split(' ');
      if (parts.length >= 2) {
        final hourPart = parts[0]; // "0h"
        final minutePart = parts[1]; // "49m"

        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: hourPart,
                style: AppTextStyle.semibold24.copyWith(
                  color: Colors.black,
                ),
              ),
              TextSpan(
                text: ' $minutePart',
                style: AppTextStyle.regular16.copyWith(
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );
      }
    }

    // Fallback to regular styling for other formats
    return Text(
      hoursText,
      style: AppTextStyle.semibold24.copyWith(
        color: Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 4.w,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyle.medium10.copyWith(
              color: AppColors.grey,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildStyledHours(),
            ),
          ),
          Row(
            children: [
              Container(
                width: 6.w,
                height: 6.w,
                decoration: BoxDecoration(
                  color: borderColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 6.w),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Completed: ',
                      style: AppTextStyle.activityCompleted.copyWith(
                        color: borderColor,
                      ),
                    ),
                    TextSpan(
                      text: completedText,
                      style: AppTextStyle.activityCompleted.copyWith(
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
