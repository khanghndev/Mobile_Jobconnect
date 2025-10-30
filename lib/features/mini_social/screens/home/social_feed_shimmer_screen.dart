import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SocialFeedShimmerScreen extends StatelessWidget {
  const SocialFeedShimmerScreen({super.key});

  Widget _shimmerPost() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                width: 100.w,
                height: 12.h,
                color: Colors.white,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Content
          Container(
            width: double.infinity,
            height: 80.h,
            color: Colors.white,
          ),
          SizedBox(height: 8.h),
          // Image
          Container(
            width: double.infinity,
            height: 150.h,
            color: Colors.white,
          ),
          SizedBox(height: 8.h),
          // Actions row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (_) => Container(
              width: 50.w,
              height: 20.h,
              color: Colors.white,
            )),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            // Input tạo post
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Container(
                width: double.infinity,
                height: 60.h,
                color: Colors.white,
              ),
            ),
            ...List.generate(5, (_) => _shimmerPost()),
          ],
        ),
      ),
    );
  }
}