import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/notifications/model/notification_model.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final bool selectMode;
  final bool isSelected;
  final ThemeData theme;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final IconData iconData;
  final Color iconColor;
  final String timeAgo;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.selectMode,
    required this.isSelected,
    required this.theme,
    required this.onTap,
    required this.onLongPress,
    required this.iconData,
    required this.iconColor,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = notification.isRead == 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: selectMode
            ? (isSelected
                ? theme.primaryColor.withValues(alpha: 0.15)
                : theme.cardColor)
            : (isUnread
                ? theme.colorScheme.primary.withValues(alpha: 0.07)
                : theme.cardColor),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.15),
          width: 0.6,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: onTap,
        onLongPress: onLongPress,
        splashColor: theme.primaryColor.withValues(alpha: 0.1),
        highlightColor: theme.primaryColor.withValues(alpha: 0.05),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //TODO: Checkbox khi ở select mode
              if (selectMode)
                Padding(
                  padding: EdgeInsets.only(right: 10.w, top: 8.h),
                  child: IgnorePointer(
                    child: Checkbox(
                      value: isSelected,
                      onChanged: null,
                      activeColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: BorderSide(
                        color: theme.primaryColor.withValues(alpha: 0.7),
                        width: 1.5,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),

              //TODO: Icon bên trái
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(iconData, color: iconColor, size: 24.sp),
              ),

              SizedBox(width: 12.w),

              //TODO: Nội dung chính
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //TODO: Dòng tiêu đề + thời gian
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Thông báo",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight:
                                  isUnread ? FontWeight.w700 : FontWeight.w500,
                              color: theme.colorScheme.onSurface,
                              fontSize: 15.sp,
                              height: 1.3,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          timeAgo,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 6.h),

                    //TODO: Nội dung phụ
                    Text(
                      notification.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.75),
                        fontSize: 13.5.sp,
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    //TODO: Label "Đã đọc" / "Chưa đọc"
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: isUnread
                              ? theme.colorScheme.primary.withValues(alpha: 0.12)
                              : theme.colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8.r),
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
                    ),
                  ],
                ),
              ),

              if (isUnread && !selectMode)
                Padding(
                  padding: EdgeInsets.only(left: 8.w, top: 4.h),
                  child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
