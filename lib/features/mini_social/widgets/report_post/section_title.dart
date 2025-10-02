import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SectionTitle extends StatelessWidget {
  final IconData icon;
  final String text;

  const SectionTitle({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha:0.2),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: Colors.white, size: 20.sp),
        ),
        SizedBox(width: 10.w),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
