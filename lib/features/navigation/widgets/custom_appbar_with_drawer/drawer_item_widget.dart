import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? itemColor;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.isSelected = false,
    this.itemColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = itemColor ??
        (isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant);

    return Material(
      color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.08) : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.r),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24.sp),
              SizedBox(width: 20.w),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}