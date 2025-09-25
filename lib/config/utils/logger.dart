import 'package:flutter/foundation.dart';

class AppLogger {
  static void info(String message) {
    if (kDebugMode) {
      print('[INFO] $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('[WARNING] ⚠️ $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[ERROR] ❌ $message');
      if (error != null) print('  Error: $error');
      if (stackTrace != null) print('  StackTrace:\n$stackTrace');
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      print('[DEBUG] 🛠️ $message');
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      print('[SUCCESS] ✅ $message');
    }
  }
}


// Cách sử dụng
// AppLogger.info('Ứng dụng đã khởi động');
// AppLogger.debug('Giá trị biến x: $x');
// AppLogger.success('Tải dữ liệu thành công');
// AppLogger.warning('Thiếu trường email trong form');
// AppLogger.error('Lỗi khi gửi request', e, stackTrace);
