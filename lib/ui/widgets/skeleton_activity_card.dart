import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SkeletonActivityCard extends StatelessWidget {
  final Color cardColor;
  final Color borderColor;

  const SkeletonActivityCard({
    super.key,
    required this.cardColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: cardColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16.r),
        border: Border(
          left: BorderSide(
            color: borderColor.withOpacity(0.3),
            width: 4.w,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title skeleton
          Container(
            width: 60.w,
            height: 10.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              // Hours skeleton
              child: Container(
                width: 80.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4.r),
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
                  color: borderColor.withOpacity(0.3),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 6.w),
              // Completed text skeleton
              Container(
                width: 100.w,
                height: 8.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 