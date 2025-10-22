import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isHighlighted;

  const InfoChip({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: isHighlighted
            ? color.withValues(alpha:0.15)
            : theme.dividerColor.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: isHighlighted
          ? Border.all(color: color.withValues(alpha:0.4), width: 1.w)
          : Border.all(color: color.withValues(alpha:0.4), width: 1.w),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15.sp,
            color: isHighlighted
              ? color
              : theme.colorScheme.onSurfaceVariant.withValues(alpha:0.7),
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              label,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isHighlighted
                  ? color
                  : theme.colorScheme.onSurfaceVariant.withValues(alpha:0.9),
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}