import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomActionBar extends StatelessWidget {
  final ThemeData theme;
  final bool isSaved;
  final VoidCallback onToggleSave;
  final VoidCallback onButtonPressed;
  final String buttonText;
  final IconData mainButtonIcon;
  final IconData? leftIcon;
  final IconData? rightIcon;

  const CustomActionBar({
    super.key,
    required this.theme,
    required this.isSaved,
    required this.onToggleSave,
    required this.onButtonPressed,
    required this.buttonText,
    required this.mainButtonIcon,
    this.leftIcon,
    this.rightIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: theme.bottomAppBarTheme.color ?? theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(
              alpha: theme.brightness == Brightness.dark ? 0.2 : 0.1,
            ),
            spreadRadius: 1,
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (leftIcon != null) ...[
              InkWell(
                onTap: onToggleSave,
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: theme.primaryColor.withValues(
                        alpha: isSaved ? 0.7 : 0.3,
                      ),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    leftIcon,
                    color: theme.primaryColor,
                    size: 28.sp,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
            ],
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 3,
                ),
                icon: Icon(mainButtonIcon, size: 20.sp),
                label: Text(
                  buttonText,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            if (rightIcon != null) ...[
              SizedBox(width: 16.w),
              InkWell(
                onTap: onToggleSave,
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: theme.primaryColor.withValues(
                        alpha: isSaved ? 0.7 : 0.3,
                      ),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    rightIcon,
                    color: theme.primaryColor,
                    size: 28.sp,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
