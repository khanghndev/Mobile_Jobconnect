import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final Color? iconColor;
  final List<Widget> actions;
  final Widget? content;

  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.info_outline_rounded,
    this.iconColor,
    this.actions = const [],
    this.content,
  });

  /// Hàm static để hiển thị nhanh
  static Future<void> show(
    BuildContext context, {
    required String title,
    String? message,
    IconData icon = Icons.info_outline_rounded,
    Color? iconColor,
    List<Widget>? actions,
    Widget? content,
    bool dismissible = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (_) => AppDialog(
        title: title,
        message: message,
        icon: icon,
        iconColor: iconColor,
        actions: actions ?? [],
        content: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? theme.colorScheme.primary,
            size: 28.r,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: content ??
          (message != null
              ? Text(
                  message!,
                  style: theme.textTheme.bodyMedium,
                )
              : null),
      actionsPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
      actions: actions,
    );
  }
}