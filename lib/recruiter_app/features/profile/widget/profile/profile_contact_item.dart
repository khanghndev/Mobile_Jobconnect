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
    const recruiterPrimary = Color(0xFF1A237E);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: recruiterPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: recruiterPrimary.withValues(alpha: 0.2),
                    width: 1.w,
                  ),
                ),
                child: Icon(icon, color: recruiterPrimary, size: 20.sp),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasCopy)
                Container(
                  margin: EdgeInsets.only(left: 8.w),
                  decoration: BoxDecoration(
                    color: recruiterPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.content_copy_rounded, size: 18.sp, color: recruiterPrimary),
                    onPressed: onCopy,
                    padding: EdgeInsets.all(8.r),
                  ),
                ),
              if (hasLink)
                Container(
                  margin: EdgeInsets.only(left: 8.w),
                  decoration: BoxDecoration(
                    color: recruiterPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.open_in_new_rounded, size: 18.sp, color: recruiterPrimary),
                    onPressed: onOpenLink,
                    padding: EdgeInsets.all(8.r),
                  ),
                ),
            ],
          ),
          if (!isLast)
            Container(
              margin: EdgeInsets.only(top: 14.h),
              height: 1.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    recruiterPrimary.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}