import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SocialFeedShimmer extends StatelessWidget {
  const SocialFeedShimmer({super.key});

  Widget _box({double? w, double? h, double radius = 12}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _shimmerPost() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              _box(w: 40.w, h: 40.w, radius: 40), // avatar
              SizedBox(width: 8.w),
              _box(w: 100.w, h: 12.h, radius: 8),
            ],
          ),
          SizedBox(height: 8.h),

          /// Content text
          _box(w: double.infinity, h: 80.h, radius: 12),
          SizedBox(height: 8.h),

          /// Image placeholder
          _box(w: double.infinity, h: 150.h, radius: 12),
          SizedBox(height: 8.h),

          /// Actions row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              3,
              (_) => _box(w: 50.w, h: 20.h, radius: 20),
            ),
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
            /// Input tạo post
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: _box(w: double.infinity, h: 60.h, radius: 16),
            ),

            /// 5 posts shimmer
            ...List.generate(5, (_) => _shimmerPost()),
          ],
        ),
      ),
    );
  }
}
