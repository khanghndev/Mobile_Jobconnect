import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompanyDetailShimmer extends StatelessWidget {
  const CompanyDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //   Banner/logo công ty
              Container(
                height: 180.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              SizedBox(height: 24.h),
        
              //   Tên công ty
              Container(
                height: 22.h,
                width: 200.w,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              SizedBox(height: 8.h),
        
              //   Địa chỉ
              Container(
                height: 14.h,
                width: 250.w,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              SizedBox(height: 32.h),
        
              //   "Giới thiệu công ty"
              Container(
                height: 18.h,
                width: 160.w,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              SizedBox(height: 12.h),
        
              // Mô tả giả
              Column(
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Container(
                      height: 12.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
        
              //   Thông tin liên hệ
              Container(
                height: 18.h,
                width: 180.w,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              SizedBox(height: 12.h),
        
              // Các dòng thông tin
              Column(
                children: List.generate(
                  4,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Row(
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Container(
                            height: 14.h,
                            decoration: BoxDecoration(
                              color: baseColor,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        
              SizedBox(height: 32.h),
        
              //   Danh sách việc làm
              Container(
                height: 18.h,
                width: 200.w,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              SizedBox(height: 16.h),
        
              // Các job card giả
              Column(
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Container(
                      height: 120.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
