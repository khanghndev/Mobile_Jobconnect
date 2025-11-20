import 'dart:io';

import 'package:flutter/material.dart';
import 'package:job_connect/config/constant/app_images.dart';

class ImageUtils {
  static ImageProvider getImageProvider(String? url, {String fallbackAsset = AppImages.logoApp}) {
    if (url != null && url.isNotEmpty) {
      final trimmedUrl = url.trim();
      if (trimmedUrl.startsWith('http')) {
        return NetworkImage(trimmedUrl);
      }
      if (File(trimmedUrl).existsSync()) {
        return FileImage(File(trimmedUrl));
      }
      if (trimmedUrl.startsWith('/images/')) {
        return AssetImage(fallbackAsset);
      }
    }
    return AssetImage(fallbackAsset);
  }
}
