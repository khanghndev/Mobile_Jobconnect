import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/home/widgets/home/wave_clipper.dart';
import 'package:shimmer/shimmer.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header + Banner
              ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 80.h),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 24.h, width: 150.w, color: Colors.white, margin: EdgeInsets.symmetric(vertical: 4.h)),
                      SizedBox(height: 8.h),
                      Container(height: 32.h, width: 200.w, color: Colors.white, margin: EdgeInsets.symmetric(vertical: 4.h)),
                      SizedBox(height: 24.h),
                      Container(height: 150.h, width: double.infinity, color: Colors.white, margin: EdgeInsets.symmetric(vertical: 4.h)),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              // Button
              Container(height: 48.h, width: double.infinity, color: Colors.white, margin: EdgeInsets.symmetric(horizontal: 16.w)),
              SizedBox(height: 40.h),
              // Section header + list (Companies)
              Container(height: 24.h, width: 120.w, color: Colors.white, margin: EdgeInsets.symmetric(horizontal: 16.w)),
              SizedBox(height: 16.h),
              Container(height: 100.h, width: double.infinity, color: Colors.white, margin: EdgeInsets.symmetric(horizontal: 16.w)),
              SizedBox(height: 16.h),
              // Section header + list (Jobs)
              Container(height: 24.h, width: 120.w, color: Colors.white, margin: EdgeInsets.symmetric(horizontal: 16.w)),
              SizedBox(height: 16.h),
              Container(height: 120.h, width: double.infinity, color: Colors.white, margin: EdgeInsets.symmetric(horizontal: 16.w)),
              SizedBox(height: 16.h),
              // Section header + list (Podcasts)
              Container(height: 24.h, width: 140.w, color: Colors.white, margin: EdgeInsets.symmetric(horizontal: 16.w)),
              SizedBox(height: 16.h),
              Container(height: 100.h, width: double.infinity, color: Colors.white, margin: EdgeInsets.symmetric(horizontal: 16.w)),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}