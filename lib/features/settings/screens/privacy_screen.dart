import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppbarTitleLarge(title: "Chính Sách Bảo Mật"),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: AppStrings.privacyPolicyItems.map((item) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h,),
                    Text(
                      item['title']!,
                      style: TextStyle(
                        fontSize: item['title']!.startsWith(RegExp(r'\d+')) ? 18.sp : 24.sp,
                        fontWeight: item['title']!.startsWith(RegExp(r'\d+')) ? FontWeight.bold : FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      item['content']!,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}