import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class JobHistoryShimmer extends StatelessWidget {
  final int listItemCount;
  final Color baseColor;
  final Color highlightColor;

  const JobHistoryShimmer({
    super.key,
    this.listItemCount = 6,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: [
          // Shimmer cho AppBar
          Container(
            height: kToolbarHeight.h + MediaQuery.of(context).padding.top,
            color: baseColor,
          ),
          SizedBox(height: 8.h),

          // Shimmer cho StatsSummary
          Container(
            height: 100.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 8.h),

          // Shimmer cho list items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: listItemCount,
              itemBuilder: (_, index) {
                return Container(
                  height: 90.h,
                  margin: EdgeInsets.symmetric(vertical: 6.h),
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
