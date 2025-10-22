import 'package:dio/dio.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

Future<void> downloadResumeFile({
    required BuildContext context,
    required String fileUrl,
    required String fileName,
  }) async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final savePath = '${dir.path}/$fileName';

    final dio = Dio();
    await dio.download(fileUrl, savePath);

    await OpenFilex.open(savePath);

    if(context.mounted){
      SnackbarApp.show(
        context,
        title: 'Thành công',
        message: 'Tải xuống thành công: $fileName',
        backgroundColor: BackgroundColors.backgroundSuccessPrimary,
      );
    }
  } catch (e) {
    if(context.mounted){
      SnackbarApp.show(
        context,
        title: 'Lỗi',
        message: 'Không thể tải xuống file. Vui lòng thử lại!',
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
    }
  }
}
