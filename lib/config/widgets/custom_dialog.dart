import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final String cancelText;
  final String confirmText;
  final Color? confirmButtonColor;
  final Color? backgroundColor;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final FontWeight? fontWeight;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    this.iconColor,
    this.cancelText = "Hủy",
    this.confirmText = "Xác nhận",
    this.confirmButtonColor,
    this.onConfirm,
    this.onCancel, 
    this.backgroundColor, 
    this.fontWeight,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    IconData icon = Icons.help_outline_rounded,
    Color? iconColor,
    String cancelText = "Hủy",
    String confirmText = "Xác nhận",
    Color? confirmButtonColor,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Color? backgroundColor, 
    FontWeight? fontWeight,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        cancelText: cancelText,
        confirmText: confirmText,
        confirmButtonColor: confirmButtonColor,
        onConfirm: onConfirm,
        onCancel: onCancel,
        backgroundColor: backgroundColor,
        fontWeight: fontWeight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  backgroundColor ?? theme.colorScheme.primary,
                  backgroundColor != null 
                    ? backgroundColor!.withValues(alpha: 0.8)
                    : theme.colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8.r,
                        offset: Offset(0, 3.h),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? theme.colorScheme.primary,
                    size: 38.sp,
                  ),
                ),
                SizedBox(height: 18.h),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.45,
                    fontSize: 16.sp,
                    fontWeight: fontWeight ?? FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 28.h),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.pop();
                          onCancel?.call();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSurfaceVariant,
                          side: BorderSide(
                            color: theme.dividerColor.withValues(alpha: 0.7),
                            width: 1.5.w,
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          cancelText,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.pop();
                          onConfirm?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              confirmButtonColor ?? theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          confirmText,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onError,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}