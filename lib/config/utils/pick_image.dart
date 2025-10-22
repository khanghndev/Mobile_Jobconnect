import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_connect/config/enum/dialog_type.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:permission_handler/permission_handler.dart';

Future<Uint8List?> pickImage(
  BuildContext context, {
  ImageSource imageSource = ImageSource.gallery,
}) async {
  try {
    final ImagePicker picker = ImagePicker();
    XFile? pickedFile;

    if (imageSource == ImageSource.gallery) {
      late PermissionStatus result;
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt <= 32) {
          result = await Permission.storage.request();
        } else {
          result = await Permission.photos.request();
        }
      } else {
        result = await Permission.photos.request();
      }

      if (context.mounted) {
        switch (result) {
          case PermissionStatus.denied:
          case PermissionStatus.restricted:
          case PermissionStatus.limited:
          case PermissionStatus.permanentlyDenied:
          case PermissionStatus.provisional:
          DialogUtils.showDialogMessage(
            context,
            message: "Bạn cần cấp quyền để truy cập thư viện!",
            title: "'Thông báo",
            type: DialogType.error,
            buttonText: "Đóng",
          );
          case PermissionStatus.granted:
            // Pick an image.
            pickedFile = await picker.pickImage(source: ImageSource.gallery);
            return await pickedFile?.readAsBytes();
        }
      }
    } else if (imageSource == ImageSource.camera) {
      PermissionStatus result = await Permission.camera.request();

      if (context.mounted) {
        switch (result) {
          case PermissionStatus.denied:
          case PermissionStatus.restricted:
          case PermissionStatus.limited:
          case PermissionStatus.permanentlyDenied:
          case PermissionStatus.provisional:
            DialogUtils.showDialogMessage(
              context,
              message: "Bạn cần cấp quyền để truy cập máy ảnh!",
              title: "'Thông báo",
              type: DialogType.error,
              buttonText: "Đóng",
            );
          case PermissionStatus.granted:
            // Capture a photo.
            pickedFile = await picker.pickImage(source: ImageSource.camera);
            return await pickedFile?.readAsBytes();
        }
      }
    }

    return null;
  } catch (e) {
    return null;
  }
}

// Future<void> _onPickImage(ImageSource source) async {
//   final Uint8List? bytes = await pickImage(context, imageSource: source);
//   if (bytes != null) {
//     final tempDir = await getTemporaryDirectory();
//     final file = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
//     await file.writeAsBytes(bytes);

//     setState(() => _images.add(file));
//   }
// }