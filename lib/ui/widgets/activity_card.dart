import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 12/10,
              color: AppColors.grey,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${hours}hrs',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
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
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        height: 12/8,
                        color: borderColor,
                      ),
                    ),
                    TextSpan(
                      text: completedText,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
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