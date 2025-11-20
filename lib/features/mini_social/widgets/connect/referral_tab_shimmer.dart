import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ReferralTabShimmer extends StatelessWidget {
  const ReferralTabShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),

          Expanded(
            child: Column(
              children: [
                // Image shimmer
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 200.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // Title shimmer
                _shimmerLine(width: 260.w, height: 18.h),
                SizedBox(height: 20.h),

                // Referral code box shimmer
                Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _shimmerLine(width: 120.w, height: 18.h),
                      _shimmerLine(width: 60.w, height: 14.h),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Info items shimmer
                _shimmerLine(width: 240.w, height: 16.h),
                SizedBox(height: 12.h),
                _shimmerLine(width: 260.w, height: 16.h),
              ],
            ),
          ),

          // Button shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 48.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmerLine({required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}