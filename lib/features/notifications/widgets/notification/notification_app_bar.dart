import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoading;
  final bool selectMode;
  final int unreadCount;
  final int selectedCount;
  final int totalCount;

  final VoidCallback onBack;
  final VoidCallback onToggleSelectMode;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDeleteSelected;

  const NotificationAppBar({
    super.key,
    required this.isLoading,
    required this.selectMode,
    required this.unreadCount,
    required this.selectedCount,
    required this.totalCount,
    required this.onBack,
    required this.onToggleSelectMode,
    this.onMarkAsRead,
    this.onDeleteSelected,
  });

  @override
  Size get preferredSize => Size.fromHeight(60.h);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0.8,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
      centerTitle: true,
      title: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Thông Báo',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color:theme.colorScheme.onSurface,
              fontSize: 22.sp,
            ),
          ),
          if (unreadCount > 0 && !selectMode)
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Text(
                '$unreadCount tin nhắn mới',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
      leading: selectMode
          ? IconButton(
              icon: Icon(
                Icons.close_rounded,
                color: theme.colorScheme.onSurface,
                size: 24.r,
              ),
              tooltip: 'Hủy chọn',
              onPressed: onToggleSelectMode,
            )
          : IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: theme.colorScheme.onSurface,
                size: 22.r,
              ),
              onPressed: onBack,
            ),
      actions: [
        if (selectMode) ...[
          //   HIỂN THỊ SỐ LƯỢNG ITEM ĐÃ CHỌN
          // Padding(
          //   padding: EdgeInsets.only(right: 8.w),
          //   child: Text(
          //     '$selectedCount đã chọn',
          //     style: theme.textTheme.bodyMedium?.copyWith(
          //       color: theme.colorScheme.onSurfaceVariant,
          //     ),
          //   ),
          // ),
          IconButton(
            icon: Icon(
              Icons.mark_chat_read_outlined,
              color: theme.colorScheme.primary,
              size: 24.r,
            ),
            tooltip: 'Đánh dấu đã đọc',
            onPressed: selectedCount > 0 ? onMarkAsRead : null,
          ),
          IconButton(
            icon: Icon(
              Icons.delete_sweep_outlined,
              color: theme.colorScheme.error,
              size: 24.r,
            ),
            tooltip: 'Xóa thông báo',
            onPressed: selectedCount > 0 ? onDeleteSelected : null,
          ),
        ] else if (!isLoading && totalCount > 0)
          IconButton(
            icon: Icon(
              Icons.checklist_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 24.r,
            ),
            tooltip: 'Quản lý thông báo',
            onPressed: onToggleSelectMode,
          ),
        SizedBox(width: 8.w),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(0.8.h),
        child: Divider(
          height: 0.8.h,
          thickness: 0.8.h,
          color: theme.dividerColor.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}