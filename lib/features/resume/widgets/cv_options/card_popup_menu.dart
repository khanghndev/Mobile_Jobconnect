import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CVCardPopupMenu extends StatelessWidget {
  final VoidCallback onEditName;
  final VoidCallback onShare;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const CVCardPopupMenu({
    super.key,
    required this.onEditName,
    required this.onShare,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha:0.8),
        size: 24.sp,
      ),
      tooltip: 'Tùy chọn CV',
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      elevation: 2,
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'edit_name',
          child: Row(
            children: [
              Icon(
                Icons.edit_note_rounded,
                color: theme.colorScheme.primary,
                size: 22.sp,
              ),
              SizedBox(width: 14.w),
              Text(
                'Chỉnh sửa tên',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'share',
          child: Row(
            children: [
              Icon(
                Icons.share_rounded,
                color: theme.colorScheme.primary,
                size: 22.sp,
              ),
              SizedBox(width: 14.w),
              Text(
                'Chia sẻ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'download',
          child: Row(
            children: [
              Icon(
                Icons.download_for_offline_rounded,
                color: theme.colorScheme.primary,
                size: 22.sp,
              ),
              SizedBox(width: 14.w),
              Text(
                'Tải xuống',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 0.5),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: theme.colorScheme.error,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Xóa CV',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (String value) {
        switch (value) {
          case 'edit_name':
            onEditName();
            break;
          case 'share':
            onShare();
            break;
          case 'download':
            onDownload();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
    );
  }
}