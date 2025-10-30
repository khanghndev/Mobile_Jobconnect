import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class SocialProfileShimmer extends StatelessWidget {
  const SocialProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEAF4FF),
      body: SafeArea(
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16.h),

                // Username
                Container(
                  width: 180.w,
                  height: 20.h,
                  color: Colors.white,
                ),
                SizedBox(height: 24.h),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: 60.w,
                      height: 20.h,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Actions
                Container(
                  width: double.infinity,
                  height: 40.h,
                  color: Colors.white,
                ),
                SizedBox(height: 24.h),

                // Goals
                Container(
                  width: double.infinity,
                  height: 80.h,
                  color: Colors.white,
                ),
                SizedBox(height: 24.h),

                // Discover list shimmer
                Column(
                  children: List.generate(
                    3,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Container(
                        width: double.infinity,
                        height: 120.h,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}