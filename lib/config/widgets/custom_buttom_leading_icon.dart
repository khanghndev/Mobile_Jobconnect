import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';

class CustomButtomLeadingIcon extends StatelessWidget {
  final VoidCallback onPressed;
  final String? text;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final Color iconColor;
  final bool hasBorder;
  final double? width;
  final double? borderRadius;

  const CustomButtomLeadingIcon({
    super.key,
    required this.onPressed,
    this.text,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    required this.iconColor,
    this.hasBorder = false, 
    this.width, 
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: 50.h, 
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.3),
            blurRadius: 8.h,
            offset: Offset(0, 4.h), 
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: iconColor,
          size: 20.sp,
        ),
        label: text == null 
          ? SizedBox.shrink()
          : Text(
              text!,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: textColor,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
            side: hasBorder
                ? BorderSide(color: BorderColors.borderDefaultDefault.withValues(alpha: 0.3), width: 1.w) 
                : BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }
}
