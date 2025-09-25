import 'package:flutter/material.dart';

class SnackbarApp {
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    Color bgColor = Colors.black87,
    IconData icon = Icons.info_outline,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        // behavior: SnackBarBehavior.floating, // cao ngang floadting
        duration: duration,
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bgColor,
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
                      title,
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
}


// // báo lỗi
// SnackbarApp.show(
//   context,
//   title: "Thiếu thông tin",
//   message: "Vui lòng chọn lý do báo cáo",
//   bgColor: Colors.redAccent,
//   icon: Icons.error_outline,
// );

// // thông báo thành công
// SnackbarApp.show(
//   context,
//   title: "Thành công",
//   message: "Báo cáo đã được gửi",
//   bgColor: Colors.green,
//   icon: Icons.check_circle_outline,
// );

// // cảnh báo
// SnackbarApp.show(
//   context,
//   title: "Cảnh báo",
//   message: "Bạn sắp rời khỏi trang",
//   bgColor: Colors.orange,
//   icon: Icons.warning_amber_rounded,
// );
