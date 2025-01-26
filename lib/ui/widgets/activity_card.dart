import 'package:flutter/material.dart';
import '../../shared/app_sizer.dart';
import '../../shared/app_text_style.dart';
import '../../shared/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimension.getWidth(12)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.maxHeight - AppDimension.getHeight(24);
          final contentHeight = availableHeight / 3;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: contentHeight,
                child: Text(
                  title,
                  style: AppTextStyle.activityTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(
                height: contentHeight,
                child: Text(
                  '${hours}hrs',
                  style: AppTextStyle.activityHours,
                ),
              ),
              SizedBox(
                height: contentHeight,
                child: Row(
                  children: [
                    Container(
                      width: AppDimension.getWidth(6),
                      height: AppDimension.getWidth(6),
                      decoration: BoxDecoration(
                        color: cardColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: AppDimension.getWidth(6)),
                    Expanded(
                      child: Text(
                        'Completed: $completedText',
                        style: AppTextStyle.activityCompleted.copyWith(color: cardColor),
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