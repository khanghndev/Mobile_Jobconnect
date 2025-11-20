import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessageActionSheet extends StatelessWidget {
  final bool isPinned;
  final bool isOwnMessage;
  final VoidCallback onPinToggle;
  final VoidCallback? onRecall;
  final VoidCallback? onEdit;

  const MessageActionSheet({
    super.key,
    required this.isPinned,
    required this.isOwnMessage,
    required this.onPinToggle,
    this.onRecall,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues( alpha: 0.1),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pin / Unpin
            ListTile(
              leading: Icon(
                isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                color: Colors.orange,
                size: 28.w,
              ),
              title: Text(
                isPinned ? "Bỏ ghim tin nhắn" : "Ghim tin nhắn",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16.sp,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onPinToggle();
              },
            ),
            if (isOwnMessage) ...[
              Divider(height: 1.h),
              if (onRecall != null)
                ListTile(
                  leading: Icon(Icons.undo, color: Colors.red, size: 28.w),
                  title: Text(
                    "Thu hồi",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onRecall!();
                  },
                ),
              if (onEdit != null)
                ListTile(
                  leading: Icon(Icons.edit, color: Colors.blue, size: 28.w),
                  title: Text(
                    "Sửa",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onEdit!();
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  /// Helper để show modal bottom sheet
  static Future<void> show(
    BuildContext context, {
    required bool isPinned,
    required bool isOwnMessage,
    required VoidCallback onPinToggle,
    VoidCallback? onRecall,
    VoidCallback? onEdit,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => MessageActionSheet(
        isPinned: isPinned,
        isOwnMessage: isOwnMessage,
        onPinToggle: onPinToggle,
        onRecall: onRecall,
        onEdit: onEdit,
      ),
    );
  }
}
