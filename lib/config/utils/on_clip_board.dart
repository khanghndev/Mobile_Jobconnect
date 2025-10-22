import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';

class OnClipBoard {
  static void copyToClipboard({
    required BuildContext context,
    required String titleCopy,
    required String subtitleCopy,
  }) {
    if (titleCopy.isEmpty) return;

    Clipboard.setData(ClipboardData(text: titleCopy));
    
    SnackbarApp.show(
      context, 
      title: 'Thông báo', 
      message: 'Đã sao chép $subtitleCopy!',
      backgroundColor: BackgroundColors.backgroundSuccessPrimary,
    );
  }
}
