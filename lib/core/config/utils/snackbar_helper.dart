import 'package:flutter/material.dart';
import 'package:job_connect/core/config/enum/enum.dart';


class SnackbarHelper {
  static void show(
    BuildContext context,
    String message, {
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final color = _getColor(type);
    final icon = _getIcon(type);

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: color,
      duration: duration,
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static Color _getColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Colors.green;
      case SnackbarType.error:
        return Colors.red;
      case SnackbarType.warning:
        return Colors.orange;
      case SnackbarType.info:
        return Colors.blue;
    }
  }

  static IconData _getIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle_outline;
      case SnackbarType.error:
        return Icons.error_outline;
      case SnackbarType.warning:
        return Icons.warning_amber_outlined;
      case SnackbarType.info:
        return Icons.info_outline;
    }
  }
}

// Cách sử dụng

// SnackbarHelper.show(context, 'Đăng nhập thành công!',
//     type: SnackbarType.success);

// SnackbarHelper.show(context, 'Sai mật khẩu!',
//     type: SnackbarType.error);

// SnackbarHelper.show(context, 'Thiếu thông tin!',
//     type: SnackbarType.warning);

// SnackbarHelper.show(context, 'Bạn đang ở bản thử nghiệm',
//     type: SnackbarType.info);
