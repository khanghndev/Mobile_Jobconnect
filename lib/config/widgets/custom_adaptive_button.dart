import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';

class CustomAdaptiveButton extends StatelessWidget {
  const CustomAdaptiveButton({
    super.key,
    this.width,
    this.height,
    required this.onPressed,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.radius,
    this.borderColor = Colors.transparent,
    this.borderWidth,
    this.preffixWidget,
    this.suffixWidget,
    this.alignment,
    this.fontSize,
    this.isPositionTitle = false,
    this.isOpacity,
    this.fontWeight,
    this.boxShadow
  });

  final double? width;
  final double? height;
  final VoidCallback onPressed;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? radius;
  final Color borderColor;
  final double? borderWidth;
  final Widget? suffixWidget;
  final Widget? preffixWidget;

  final AlignmentGeometry? alignment;
  final double? fontSize;
  final bool? isPositionTitle;
  final bool? isOpacity;
  final FontWeight? fontWeight;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    // If current platform is iOS
    if (isIOS) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? 12.r),
          border: Border.all(width: borderWidth ?? 1.w, color: borderColor),
          boxShadow: boxShadow
        ),
        child: CupertinoButton(
          color: backgroundColor ?? BackgroundColors.backgroundButtonPrimary,
          alignment: alignment ?? Alignment.center,
          minSize: 0,
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          borderRadius: BorderRadius.circular(radius ?? 12.r),
          onPressed: onPressed,
          pressedOpacity: isOpacity == true ? 1.0 : null,
          child: Row(
            mainAxisAlignment: isPositionTitle == true
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            mainAxisSize:
                isPositionTitle == true ? MainAxisSize.max : MainAxisSize.min,
            spacing: 3.w,
            children: [
              if (preffixWidget != null) ...[
                preffixWidget!,
                SizedBox(width: 4.w),
              ],
              Text(
                text,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontSize: fontSize ?? 17.sp,
                  fontWeight: fontWeight ?? FontWeight.w400,
                  letterSpacing: -0.43,
                  height: 17/22,
                  color: textColor ?? TextColors.textButtonPrimary,
                ),
              ),
              if (suffixWidget != null) ...[
                SizedBox(width: 2.w),
                suffixWidget!,
              ],
            ],
          ),
        ),
      );
    }

    // If current platform is android
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        boxShadow: boxShadow
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          overlayColor: isOpacity == true ? Colors.transparent : null,
          alignment: alignment,
          backgroundColor: backgroundColor ?? BackgroundColors.backgroundButtonPrimary,
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius ?? 12.r),
            side: BorderSide(width: borderWidth ?? 1.w, color: borderColor),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize:
              isPositionTitle == true ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: isPositionTitle == true
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          spacing: 3.w,
          children: [
            if (preffixWidget != null) ...[
              preffixWidget!,
              SizedBox(width: 4.w),
            ],
            Text(
              text,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontSize: fontSize ?? 17.sp,
                fontWeight: fontWeight ?? FontWeight.w400,
                letterSpacing: -0.43,
                color: textColor ?? TextColors.textButtonPrimary,
              ),
            ),
            if (suffixWidget != null) ...[
              SizedBox(width: 2.w),
              suffixWidget!,
            ],
          ],
        ),
      ),
    );
  }
}
