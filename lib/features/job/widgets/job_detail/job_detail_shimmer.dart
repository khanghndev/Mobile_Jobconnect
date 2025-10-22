import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class JobDetailShimmer extends StatelessWidget {
  const JobDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Shimmer.fromColors(
      baseColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.3),
      highlightColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.1),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 18.h,
                        width: 180.w,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 14.h,
                        width: 140.w,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: List.generate(3, (index) {
                return Container(
                  width: 100.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                );
              }),
            ),
            SizedBox(height: 24.h),

            _buildSectionShimmer(titleWidth: 100.w, lines: 5),
            _buildSectionShimmer(titleWidth: 120.w, lines: 4),
            _buildSectionShimmer(titleWidth: 80.w, lines: 3),

            SizedBox(height: 24.h),

            Row(
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 140.w, height: 16.h, color: Colors.grey[300]),
                    SizedBox(height: 6.h),
                    Container(width: 100.w, height: 14.h, color: Colors.grey[300]),
                  ],
                ),
              ],
            ),
            SizedBox(height: 32.h),

            _buildSectionShimmer(titleWidth: 120.w, lines: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionShimmer({required double titleWidth, int lines = 3}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: titleWidth,
            height: 18.h,
            color: Colors.grey[300],
          ),
          SizedBox(height: 12.h),
          Column(
            children: List.generate(lines, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Container(
                  height: 12.h,
                  width: double.infinity,
                  color: Colors.grey[300],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}