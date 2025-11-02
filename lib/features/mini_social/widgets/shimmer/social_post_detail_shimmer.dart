import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class SocialPostDetailShimmer extends StatelessWidget {
  final bool isPostLoading;
  final bool isCommentLoading;

  const SocialPostDetailShimmer({
    super.key,
    this.isPostLoading = false,
    this.isCommentLoading = false,
  });

  Widget _buildPostShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avatar + name
            Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120.w, height: 14.h, color: Colors.white),
                    SizedBox(height: 6.h),
                    Container(width: 80.w, height: 12.h, color: Colors.white),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Content lines
            Container(width: double.infinity, height: 14.h, color: Colors.white),
            SizedBox(height: 8.h),
            Container(width: double.infinity, height: 14.h, color: Colors.white),
            SizedBox(height: 8.h),
            Container(width: 200.w, height: 14.h, color: Colors.white),
            SizedBox(height: 16.h),
            // Action bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                3,
                (_) => Container(
                  width: 60.w,
                  height: 20.h,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(8, (index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 100.w, height: 12.h, color: Colors.white),
                      SizedBox(height: 6.h),
                      Container(width: double.infinity, height: 14.h, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isPostLoading) _buildPostShimmer(),
        if (isCommentLoading) _buildCommentShimmer(),
      ],
    );
  }
}