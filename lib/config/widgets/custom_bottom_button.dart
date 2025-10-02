import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/widgets/custom_adaptive_button.dart';

class CustomBottomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  const CustomBottomButton({super.key, required this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: EdgeInsets.all(16.w),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              width: 0.5.w,
              color: BorderColors.borderSeparatorOpaque.withValues(alpha: 0.2)
            )
          )
        ),
        child: CustomAdaptiveButton(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          text: title,
          onPressed: onPressed
        ),
      ),
    );
  }
}