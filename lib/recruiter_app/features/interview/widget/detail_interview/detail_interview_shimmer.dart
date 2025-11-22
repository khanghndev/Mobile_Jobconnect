import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class DetailInterviewShimmer extends StatelessWidget {
  const DetailInterviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          Container(
            height: 28.h,
            width: 220.w,
            decoration: _box,
          ),
          SizedBox(height: 20.h),

          // DATE (subtitle)
          Center(
            child: Container(
              height: 20.h,
              width: 160.w,
              decoration: _box,
            ),
          ),
          SizedBox(height: 20.h),

          // SLOGAN
          Container(
            height: 16.h,
            width: 260.w,
            decoration: _box,
          ),
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 16.h,
              width: 120.w,
              decoration: _box,
            ),
          ),

          SizedBox(height: 30.h),

          // 3 shimmer interview cards
          ...List.generate(3, (_) => _shimmerCard()),
        ],
      ),
    );
  }

  BoxDecoration get _box => BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8.r),
      );

  Widget _shimmerCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE
          Container(height: 18.h, width: 200.w, decoration: _box),
          SizedBox(height: 16.h),

          // User row
          Row(
            children: [
              Container(
                height: 40.r,
                width: 40.r,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14.h, width: 120.w, decoration: _box),
                  SizedBox(height: 8.h),
                  Container(height: 12.h, width: 160.w, decoration: _box),
                ],
              )
            ],
          ),
          SizedBox(height: 16.h),

          // TIME
          Container(height: 14.h, width: 120.w, decoration: _box),
          SizedBox(height: 10.h),

          // LOCATION
          Container(height: 14.h, width: 180.w, decoration: _box),
          SizedBox(height: 10.h),

          // INTERVIEWER
          Container(height: 14.h, width: 160.w, decoration: _box),
          SizedBox(height: 10.h),

          // NOTE
          Container(height: 14.h, width: 220.w, decoration: _box),
        ],
      ),
    );
  }
}