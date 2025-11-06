import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatItem extends StatelessWidget {
  final String count;
  final String label;
  final IconData icon;
  final Color color;
  final String? filterKey;
  final bool isSelected;
  final void Function(String?)? onTap;

  const StatItem({
    super.key,
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
    this.filterKey,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onTap?.call(filterKey),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.12)
              : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16.r),
          border: isSelected
              ? Border.all(color: color.withOpacity(0.8), width: 1.8.w)
              : Border.all(color: theme.dividerColor.withOpacity(0.5)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.15),
                    blurRadius: 8.r,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        constraints: BoxConstraints(minWidth: 100.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26.sp),
            SizedBox(height: 8.h),
            Text(
              count,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 20.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? color
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.9),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13.sp,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}