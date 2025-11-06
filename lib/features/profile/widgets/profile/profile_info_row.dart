import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/on_clip_board.dart';

class ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showArrow;

  const ProfileInfoRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.only(bottom: 24.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon đầu
            Container(
              padding: EdgeInsets.all(8.h),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.colorScheme.secondary, size: 20.sp),
            ),
            SizedBox(width: 16.w),

            // Nội dung text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(height: 6.h),
                  ],
                  Text(
                    title.isNotEmpty ? title : "Chưa cập nhật",
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // Nút copy (nếu cần)
            InkWell(
              onTap: () => OnClipBoard.copyToClipboard(
                context: context,
                titleCopy: title,
                subtitleCopy: subtitle ?? "",
              ),
              borderRadius: BorderRadius.circular(20.r),
              child: Padding(
                padding: EdgeInsets.all(8.r),
                child: Icon(
                  Icons.copy_rounded,
                  size: 20.sp,
                  color: theme.colorScheme.outline.withValues(alpha: 0.8),
                ),
              ),
            ),

            // Mũi tên
            if (showArrow)
              Icon(
                Icons.chevron_right_rounded,
                size: 22.sp,
                color: theme.colorScheme.outline.withValues(alpha: 0.8),
              ),
          ],
        ),
      ),
    );
  }
}