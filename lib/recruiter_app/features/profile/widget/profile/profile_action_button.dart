import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isDestructive;
  final bool iconRight;

  const ProfileActionButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
    this.isDestructive = false,
    this.iconRight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const recruiterPrimary = Color(0xFF1A237E);
    const recruiterSecondary = Color(0xFF283593);

    Color backgroundColor = Colors.white;
    Color textColor;
    Color iconColor;
    Gradient? gradient;

    if (isPrimary) {
      gradient = const LinearGradient(
        colors: [recruiterPrimary, recruiterSecondary],
      );
      textColor = Colors.white;
      iconColor = Colors.white;
    } else if (isDestructive) {
      backgroundColor = Colors.white;
      textColor = Colors.red;
      iconColor = Colors.red;
    } else {
      backgroundColor = Colors.white;
      textColor = recruiterPrimary;
      iconColor = recruiterPrimary;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? backgroundColor : null,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isPrimary
              ? Colors.transparent
              : isDestructive
                  ? Colors.red.withValues(alpha: 0.3)
                  : recruiterPrimary.withValues(alpha: 0.3),
          width: 1.5.w,
        ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: recruiterPrimary.withValues(alpha: 0.3),
                  blurRadius: 12.r,
                  offset: Offset(0, 6.h),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                  spreadRadius: 0,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8.r,
                  offset: Offset(0, 2.h),
                  spreadRadius: 0,
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: iconRight
                  ? [
                      Text(
                        text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                          color: textColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Icon(icon, size: 20.sp, color: iconColor),
                    ]
                  : [
                      Icon(icon, size: 20.sp, color: iconColor),
                      SizedBox(width: 10.w),
                      Text(
                        text,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                          color: textColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}
