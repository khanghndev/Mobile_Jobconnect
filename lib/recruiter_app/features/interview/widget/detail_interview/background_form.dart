import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';

import 'package:job_connect/config/constant/app_colors.dart';

class BackgroundForm extends StatelessWidget {
  final Widget child;
  final String titleForm;
  final double? titleSize;
  final bool? isMarginTitle;
  final double? isOpacity;
  const BackgroundForm(
      {super.key,
      required this.child,
      required this.titleForm,
      this.titleSize,
      this.isMarginTitle = true,
      this.isOpacity});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.6),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titleForm,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: TextColors.textDefaultPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: titleSize ?? 28.sp,
                      ),
                ),
                SizedBox(height: isMarginTitle == true ? 24.h : 0),
                child
              ],
            ),
          ),
        ),
      ),
    );
  }
}