import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class SocialGroupShimmer extends StatelessWidget {
  const SocialGroupShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bìa nhóm
            Container(
              height: 160.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(height: 16.h),

            // Tên nhóm + mô tả
            Container(
              height: 22.h,
              width: 180.w,
              color: Colors.white,
            ),
            SizedBox(height: 8.h),
            Container(
              height: 18.h,
              width: 100.w,
              color: Colors.white,
            ),
            SizedBox(height: 20.h),

            // Ô đăng bài (giả lập)
            Row(
              children: [
                Container(
                  height: 40.w,
                  width: 40.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Container(
                    height: 40.h,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Bộ lọc
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                3,
                (_) => Container(
                  height: 30.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Danh sách bài viết giả lập
            ...List.generate(3, (_) {
              return Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header bài viết (avatar + tên)
                    Row(
                      children: [
                        Container(
                          height: 40.w,
                          width: 40.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 14.h,
                              width: 120.w,
                              color: Colors.white,
                            ),
                            SizedBox(height: 6.h),
                            Container(
                              height: 10.h,
                              width: 80.w,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),

                    // Nội dung bài viết
                    Container(
                      height: 14.h,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      height: 14.h,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    SizedBox(height: 12.h),

                    // Ảnh bài viết
                    Container(
                      height: 180.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Icon like / comment / share
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(
                        3,
                        (_) => Container(
                          height: 24.w,
                          width: 24.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
