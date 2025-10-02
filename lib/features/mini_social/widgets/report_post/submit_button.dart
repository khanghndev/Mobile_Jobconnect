import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubmitButton extends StatelessWidget {
  final String text;
  final bool loading;
  final IconData? icon;
  final VoidCallback? onPressed;

  const SubmitButton({
    super.key,
    required this.text,
    required this.loading,
    required this.onPressed, 
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: loading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha:0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha:0.35),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? SizedBox(
                  height: 22.w,
                  width: 22.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon ?? Icons.send_rounded, color: Colors.white),
                    SizedBox(width: 8.w),
                    Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
