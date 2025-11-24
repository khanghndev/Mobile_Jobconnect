import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DrawerRecruiterLabel extends StatelessWidget {
  final String title;

  const DrawerRecruiterLabel({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    const recruiterPrimary = Color(0xFF1A237E);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 16.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  recruiterPrimary,
                  recruiterPrimary.withValues(alpha: 0.6),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: recruiterPrimary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

