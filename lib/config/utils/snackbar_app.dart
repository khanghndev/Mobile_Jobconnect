import 'package:flutter/material.dart';
import 'package:job_connect/config/constant/app_colors.dart';

class SnackbarApp {
  static void show(
    BuildContext context, {
    String? title,
    required String message,
    Color backgroundColor = BackgroundColors.backgroundInfoPrimary,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    icon ??= _getIconByColor(backgroundColor);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: duration,
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title ?? 'Thông báo',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _getIconByColor(Color color) {
    if (color == BackgroundColors.backgroundErrorPrimary ) {
      return Icons.error_outline;
    } else if (color == BackgroundColors.backgroundSuccessPrimary ) {
      return Icons.check_circle_outline;
    } else if (color == BackgroundColors.backgroundWarningPrimary) {
      return Icons.warning_amber_rounded;
    } else {
      return Icons.info_outline;
    }
  }
}

// // báo lỗi
// SnackbarApp.show(
//   context,
//   title: "Thiếu thông tin",
//   message: "Vui lòng chọn lý do báo cáo",
//   backgroundColor: Colors.redAccent,
//   icon: Icons.error_outline,
// );

// // thông báo thành công
// SnackbarApp.show(
//   context,
//   title: "Thành công",
//   message: "Báo cáo đã được gửi",
//   backgroundColor: Colors.green,
//   icon: Icons.check_circle_outline,
// );

// // cảnh báo
// SnackbarApp.show(
//   context,
//   title: "Cảnh báo",
//   message: "Bạn sắp rời khỏi trang",
//   backgroundColor: Colors.orange,
//   icon: Icons.warning_amber_rounded,
// );
