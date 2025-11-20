import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileContactItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool hasCopy;
  final bool hasLink;
  final bool isLast;
  final VoidCallback? onCopy;
  final VoidCallback? onOpenLink;

  const ProfileContactItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.hasCopy = false,
    this.hasLink = false,
    this.isLast = false,
    this.onCopy,
    this.onOpenLink,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary, size: 22.sp),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 14.sp,
                        color: theme.hintColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasCopy)
                IconButton(
                  icon: Icon(Icons.content_copy, size: 20.sp, color: theme.colorScheme.primary),
                  onPressed: onCopy,
                ),
              if (hasLink)
                IconButton(
                  icon: Icon(Icons.open_in_new, size: 20.sp, color: theme.colorScheme.primary),
                  onPressed: onOpenLink,
                ),
            ],
          ),
          if (!isLast)
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.h),
              child: Divider(height: 1),
            ),
        ],
      ),
    );
  }
}