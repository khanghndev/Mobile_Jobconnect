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

    Color backgroundColor;
    Color textColor;
    Color iconColor;

    if (isPrimary) {
      backgroundColor = theme.colorScheme.primary;
      textColor = theme.colorScheme.onPrimary;
      iconColor = theme.colorScheme.onPrimary;
    } else if (isDestructive) {
      backgroundColor = theme.colorScheme.background;
      textColor = theme.colorScheme.error;
      iconColor = theme.colorScheme.error;
    } else {
      backgroundColor = theme.colorScheme.background;
      textColor = theme.colorScheme.primary;
      iconColor = theme.colorScheme.primary;
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: BorderSide(
            color: isPrimary ? Colors.transparent : textColor.withValues(alpha: 0.3),
            width: 1.w,
          ),
        ),
        elevation: isPrimary ? 2 : 0,
        shadowColor: isPrimary ? textColor.withValues(alpha: 0.3) : Colors.transparent,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: iconRight
            ? [
                Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: textColor,
                  ),
                ),
                SizedBox(width: 8.w),
                Icon(icon, size: 20.sp, color: iconColor),
              ]
            : [
                Icon(icon, size: 20.sp, color: iconColor),
                SizedBox(width: 8.w),
                Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    color: textColor,
                  ),
                ),
              ],
      ),
    );
  }
}
