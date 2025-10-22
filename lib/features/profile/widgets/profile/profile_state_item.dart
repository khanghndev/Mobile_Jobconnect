import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileStateItem extends StatelessWidget {
  final double count;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isPercentage;

  const ProfileStateItem({
    super.key,
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28.sp),
            SizedBox(height: 8.w),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: count),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                final displayValue = isPercentage
                  ? "${value.toStringAsFixed(0)}%"
                  : value.toStringAsFixed(0);
                return Text(
                  displayValue,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                );
              },
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
