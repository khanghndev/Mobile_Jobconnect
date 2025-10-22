import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButtonBorder extends StatelessWidget {
  final double? borderRadius;
  final String title;
  final IconData? icon;
  final double? width;
  final VoidCallback onPressed;

  const CustomButtonBorder({
    super.key,
    required this.title,
    this.icon,
    this.borderRadius,
    this.width,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return SizedBox(
      width: width ?? double.infinity,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: screenSize.height * 0.018,
            horizontal: screenSize.width * 0.04,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                theme.colorScheme.error.withValues(alpha: 0.08),
                theme.colorScheme.error.withValues(alpha: 0.03),
              ],
            ),
            borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
            border: Border.all(
              color: theme.colorScheme.error.withValues(alpha: 0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.error.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  color: theme.colorScheme.error,
                  size: 24.sp,
                ),
              if (icon != null) SizedBox(width: screenSize.width * 0.03),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
