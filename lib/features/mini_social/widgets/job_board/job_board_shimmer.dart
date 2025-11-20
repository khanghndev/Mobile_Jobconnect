import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobBoardShimmer extends StatelessWidget {
  const JobBoardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Category Chips
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SizedBox(
              height: 36.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, __) => Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    width: 80.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // 2. Carousel / Job Cards
          Column(
            children: List.generate(3, (_) => _shimmerJobCard()),
          ),
        ],
      ),
    );
  }

  Widget _shimmerJobCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card container
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row: image + title
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 12.h,
                              color: Colors.white,
                            ),
                            SizedBox(height: 8.h),
                            Container(
                              width: 150.w,
                              height: 12.h,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Sub-content / description
                  Container(
                    width: double.infinity,
                    height: 12.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    width: double.infinity,
                    height: 12.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 12.h),

                  // Badges / chips row
                  Row(
                    children: List.generate(
                      3,
                      (_) => Padding(
                        padding: EdgeInsets.only(right: 6.w),
                        child: Container(
                          width: 60.w,
                          height: 20.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Container(
                          height: 36.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
