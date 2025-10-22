import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/enum/dialog_type.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/custom_dialog.dart';
import 'package:job_connect/features/auth/viewmodel/auth_view_model.dart';
import 'package:provider/provider.dart';


class DialogUtils {
  static Future<void> showDialogMessage(
    BuildContext context, {
    required String message,
    String title = "Thông báo",
    DialogType type = DialogType.info,
    String buttonText = "OK",
  }) async {
    IconData icon;
    Color iconColor;

    switch (type) {
      case DialogType.success:
        icon = Icons.check_circle;
        iconColor = Colors.green;
        break;
      case DialogType.error:
        icon = Icons.error;
        iconColor = Colors.red;
        break;
      case DialogType.warning:
        icon = Icons.warning;
        iconColor = Colors.orange;
        break;
      default:
        icon = Icons.info;
        iconColor = Colors.blue;
        break;
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // bấm ra ngoài không tắt
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text(
                buttonText,
                style: TextStyle(color: iconColor),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Hiển thị dialog xác nhận logout
  static void showLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final authViewModel = context.read<AuthViewModel>();

    CustomDialog.show(
      context,
      title: "Đăng xuất?",
      message: "Bạn có chắc chắn muốn đăng xuất không?",
      icon: Icons.logout,
      iconColor: theme.colorScheme.error,
      confirmButtonColor: theme.colorScheme.error,
      backgroundColor: BackgroundColors.backgroundErrorPrimary,
      onConfirm: () async {
        await authViewModel.logout();

        if (!context.mounted) return;

        if (authViewModel.isSuccess) {
          context.go(
            '/auth/login', 
            extra: {
              'role': UserRole.candidate.name
            }
          );
        } else if (authViewModel.errorMessage != null) {
          // Hiển thị SnackBar nếu logout thất bại
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(authViewModel.errorMessage!)),
          );
          SnackbarApp.show(
            context,
            title: 'Thông báo',
            message: 'Đăng xuất thất bại: ${authViewModel.errorMessage!}',
            backgroundColor: BackgroundColors.backgroundErrorPrimary,
          );
        }
      },
    );
  }

  /// Hàm tiện ích chung để hiển thị dialog xác nhận với callback tùy ý
  static void showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    IconData? icon,
    Color? iconColor,
    Color? confirmButtonColor,
    Color? backgroundColor,
    required Future<void> Function() onConfirm,
  }) {
    final theme = Theme.of(context);

    CustomDialog.show(
      context,
      title: title,
      message: message,
      icon: icon ?? Icons.info,
      iconColor: iconColor ?? theme.colorScheme.primary,
      confirmButtonColor: confirmButtonColor ?? theme.colorScheme.primary,
      backgroundColor: backgroundColor ?? theme.colorScheme.primary,
      onConfirm: () async {
        await onConfirm();
      },
    );
  }
}

//DialogUtils.showLogoutDialog(context);

// DialogUtils.showConfirmationDialog(
//   context: context,
//   title: "Xóa dữ liệu?",
//   message: "Bạn có chắc chắn muốn xóa không?",
//   icon: Icons.delete,
//   iconColor: Colors.red,
//   confirmButtonColor: Colors.red,
//   onConfirm: () async {
//     await dataViewModel.deleteAll();
//     SnackbarApp.show(
//       context,
//       title: "Thông báo",
//       message: "Đã xóa dữ liệu",
//       backgroundColor: Colors.green,
//     );
//   },
// );
