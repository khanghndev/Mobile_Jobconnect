import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';

class ButtonPrimaryGradient extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final List<Color>? gradientColors;
  final double height;
  final double borderRadius;

  const ButtonPrimaryGradient({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradientColors,
    this.height = 55,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius.r),
        gradient: LinearGradient(
          colors: gradientColors ??
              const [Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color:
                BackgroundColors.backgroundBrandPrimary.withValues(alpha: 0.4),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius.r),
          ),
          padding: EdgeInsets.symmetric(vertical: 15.h),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: TextColors.textBrandOnbrand,
          ),
        ),
      ),
    );
  }
}
