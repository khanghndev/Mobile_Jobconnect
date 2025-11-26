import 'dart:io';

import 'package:flutter/material.dart';
import 'package:job_connect/config/constant/app_images.dart';

class ImageUtils {
  static ImageProvider getImageProvider(String? url, {String fallbackAsset = AppImages.logoApp}) {
    if (url != null && url.isNotEmpty) {
      final trimmedUrl = url.trim();
      
      // Xử lý URL bắt đầu bằng http/https
      if (trimmedUrl.startsWith('http://') || trimmedUrl.startsWith('https://')) {
        return NetworkImage(trimmedUrl);
      }
      
      // Xử lý file:// URL - bỏ qua vì không hợp lệ
      if (trimmedUrl.startsWith('file://')) {
        return AssetImage(fallbackAsset);
      }
      
      // Xử lý local file path
      try {
        final file = File(trimmedUrl);
        if (file.existsSync()) {
          return FileImage(file);
        }
      } catch (e) {
        // Nếu không phải file path hợp lệ, bỏ qua
      }
      
      // Xử lý path bắt đầu bằng /images/ - không hợp lệ, dùng fallback
      if (trimmedUrl.startsWith('/images/')) {
        return AssetImage(fallbackAsset);
      }
    }
    return AssetImage(fallbackAsset);
  }
}
