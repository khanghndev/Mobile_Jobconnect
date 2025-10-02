import 'package:flutter/material.dart';
import 'package:job_connect/config/enum/dialog_type.dart';


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
}
