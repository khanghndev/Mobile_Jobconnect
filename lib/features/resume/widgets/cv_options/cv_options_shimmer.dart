import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class CvOptionsShimmer extends StatelessWidget {
  const CvOptionsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: 5, // số lượng card shimmer hiển thị
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title line
                Container(
                  height: 18.h,
                  width: 180.w,
                  color: Colors.white,
                ),
                SizedBox(height: 8.h),

                // Subtitle line
                Container(
                  height: 14.h,
                  width: 120.w,
                  color: Colors.white,
                ),
                SizedBox(height: 12.h),

                // Content text lines
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    3,
                    (i) => Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Container(
                        height: 10.h,
                        width: i == 2 ? 180.w : double.infinity,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // List chip (kỹ năng)
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: List.generate(
                    3,
                    (i) => Container(
                      width: 60.w,
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Hai nút hành động
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Container(
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
