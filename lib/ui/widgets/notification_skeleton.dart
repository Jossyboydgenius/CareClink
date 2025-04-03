import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../shared/app_colors.dart';
import '../../shared/app_spacing.dart';

class NotificationSkeleton extends StatelessWidget {
  const NotificationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.grey200,
        highlightColor: AppColors.grey100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildShimmer(18, 18, radius: 9),
                AppSpacing.h8(),
                Expanded(
                  child: _buildShimmer(80, 12),
                ),
                AppSpacing.h8(),
                _buildShimmer(14, 14, radius: 7),
                AppSpacing.h4(),
                _buildShimmer(60, 12),
              ],
            ),
            AppSpacing.v12(),
            _buildShimmer(150, 16),
            AppSpacing.v8(),
            _buildShimmer(double.infinity, 14),
            AppSpacing.v4(),
            _buildShimmer(double.infinity, 14),
            AppSpacing.v4(),
            _buildShimmer(200, 14),
            AppSpacing.v12(),
            Align(
              alignment: Alignment.centerRight,
              child: _buildShimmer(100, 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmer(double width, double height, {double? radius}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius ?? 4),
      ),
    );
  }
}

class NotificationListSkeleton extends StatelessWidget {
  final int itemCount;

  const NotificationListSkeleton({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: itemCount,
      separatorBuilder: (context, index) => AppSpacing.v16(),
      itemBuilder: (context, index) => const NotificationSkeleton(),
    );
  }
}
