import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class HrHomeShimmer extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final int recentActivitiesCount;
  final int upcomingInterviewsCount;
  final int featuredFriendsCount;

  const HrHomeShimmer({
    super.key,
    this.padding = const EdgeInsets.all(16),
    this.recentActivitiesCount = 3,
    this.upcomingInterviewsCount = 3,
    this.featuredFriendsCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: double.infinity,
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Statistics section shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(3, (index) => Container(
                width: (MediaQuery.of(context).size.width - 48.w)/3,
                height: 80.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              )),
            ),
          ),
          SizedBox(height: 16.h),

          // Recent activities shimmer
          Column(
            children: List.generate(recentActivitiesCount, (index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: double.infinity,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            )),
          ),
          SizedBox(height: 16.h),

          // Upcoming interviews shimmer
          Column(
            children: List.generate(upcomingInterviewsCount, (index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  width: double.infinity,
                  height: 70.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            )),
          ),
          SizedBox(height: 16.h),

          // Featured friends shimmer
          Column(
            children: List.generate(featuredFriendsCount, (index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20.r,
                      backgroundColor: Colors.white,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Container(
                        height: 20.h,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }
}