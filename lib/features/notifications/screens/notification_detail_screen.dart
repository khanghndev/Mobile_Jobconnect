import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/config/widgets/custom_appbar_title_large.dart';
import 'package:job_connect/features/notifications/model/notification_model.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationModel notification;
  final Color iconColor;
  final IconData iconData;

  const NotificationDetailScreen({
    super.key,
    required this.notification,
    required this.iconColor,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('HH:mm - dd/MM/yyyy');
    final isUnread = notification.isRead == 0;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppbarTitleLarge(title: "Chi tiết thông báo"),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(iconData, color: iconColor, size: 28.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    notification.type,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isUnread
                        ? theme.colorScheme.primary.withValues(alpha: 0.12)
                        : theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    isUnread ? "Chưa đọc" : "Đã đọc",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isUnread
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          isUnread ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 11.5.sp,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            // Tiêu đề thông báo
            Text(
              notification.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
                height: 1.3,
              ),
            ),

            SizedBox(height: 10.h),

            // Ngày giờ tạo
            Row(
              children: [
                Icon(Icons.access_time_rounded,
                    color: theme.colorScheme.onSurfaceVariant, size: 16.sp),
                SizedBox(width: 6.w),
                Text(
                  dateFormat.format(notification.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
            SizedBox(height: 22.h),
          ],
        ),
      ),
    );
  }
}