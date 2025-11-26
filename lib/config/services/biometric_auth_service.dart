import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service chuyên nghiệp để xử lý đăng nhập bằng sinh trắc học
class BiometricAuthService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Kiểm tra thiết bị có hỗ trợ sinh trắc học không
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  /// Lấy danh sách các phương thức sinh trắc học khả dụng
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Lấy tên phương thức sinh trắc học (tiếng Việt)
  String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Vân tay';
      case BiometricType.strong:
        return 'sinh trắc học';
      case BiometricType.weak:
        return 'Xác thực yếu';
      case BiometricType.iris:
        return 'Mống mắt';
    }
  }

  /// Lấy tên phương thức chính (cho hiển thị)
  Future<String> getPrimaryBiometricName() async {
    final available = await getAvailableBiometrics();
    if (available.isEmpty) return 'Sinh trắc học';
    
    // Ưu tiên Face ID, sau đó là vân tay
    if (available.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (available.contains(BiometricType.fingerprint)) {
      return 'Vân tay';
    } else if (available.contains(BiometricType.strong)) {
      return 'sinh trắc học';
    }
    
    return getBiometricTypeName(available.first);
  }

  /// Kiểm tra đăng nhập sinh trắc học có được bật không
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('biometric_enabled') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Bật/tắt đăng nhập sinh trắc học
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('biometric_enabled', enabled);
      
      // Nếu tắt, xóa credentials đã lưu
      if (!enabled) {
        await clearSavedCredentials();
      }
    } catch (e) {
      throw Exception('Không thể lưu cài đặt: $e');
    }
  }

  /// Xác thực bằng sinh trắc học
  /// [reason] - Lý do xác thực (hiển thị cho user)
  Future<bool> authenticate({
    String reason = 'Vui lòng xác thực để tiếp tục',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      // Kiểm tra thiết bị có hỗ trợ không
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        throw PlatformException(
          code: 'NOT_SUPPORTED',
          message: 'Thiết bị này không hỗ trợ sinh trắc học',
        );
      }

      // Kiểm tra có phương thức nào khả dụng không
      final available = await getAvailableBiometrics();
      if (available.isEmpty) {
        throw PlatformException(
          code: 'NO_BIOMETRICS',
          message: 'Vui lòng cài đặt ít nhất một phương thức sinh trắc học trong Cài đặt hệ thống',
        );
      }

      // Thực hiện xác thực
      try {
        final authenticated = await _localAuth.authenticate(
          localizedReason: reason,
          options: AuthenticationOptions(
            useErrorDialogs: useErrorDialogs,
            stickyAuth: stickyAuth,
            biometricOnly: true,
          ),
        );

        return authenticated;
      } catch (e) {
        // Nếu lỗi về FragmentActivity, throw exception rõ ràng hơn
        if (e.toString().contains('FragmentActivity')) {
          throw PlatformException(
            code: 'FRAGMENT_ACTIVITY_REQUIRED',
            message: 'Vui lòng rebuild ứng dụng để sử dụng tính năng sinh trắc học',
          );
        }
        rethrow;
      }
    } on PlatformException catch (e) {
      // Xử lý các lỗi cụ thể
      switch (e.code) {
        case 'NOT_AVAILABLE':
          throw Exception('Sinh trắc học không khả dụng');
        case 'NOT_SUPPORTED':
          throw Exception('Thiết bị không hỗ trợ sinh trắc học');
        case 'NOT_ENROLLED':
          throw Exception('Chưa cài đặt sinh trắc học. Vui lòng cài đặt trong Cài đặt hệ thống');
        case 'LOCKED_OUT':
          throw Exception('Sinh trắc học đã bị khóa. Vui lòng thử lại sau');
        case 'PASSCODE_NOT_SET':
          throw Exception('Chưa thiết lập mã PIN. Vui lòng thiết lập trong Cài đặt hệ thống');
        case 'PERMANENTLY_LOCKED_OUT':
          throw Exception('Sinh trắc học đã bị khóa vĩnh viễn');
        case 'FRAGMENT_ACTIVITY_REQUIRED':
          throw Exception('Vui lòng rebuild ứng dụng để sử dụng tính năng sinh trắc học');
        default:
          throw Exception('Xác thực thất bại: ${e.message ?? "Lỗi không xác định"}');
      }
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    }
  }

  /// Lưu thông tin đăng nhập (email) vào secure storage
  Future<void> saveCredentials(String email) async {
    try {
      await _storage.write(key: 'saved_email', value: email);
    } catch (e) {
      throw Exception('Không thể lưu thông tin đăng nhập: $e');
    }
  }

  /// Lấy email đã lưu
  Future<String?> getSavedEmail() async {
    try {
      return await _storage.read(key: 'saved_email');
    } catch (e) {
      return null;
    }
  }

  /// Xóa thông tin đăng nhập đã lưu
  Future<void> clearSavedCredentials() async {
    try {
      await _storage.delete(key: 'saved_email');
    } catch (e) {
      // Ignore errors when clearing
    }
  }

  /// Kiểm tra có thông tin đăng nhập đã lưu không
  Future<bool> hasSavedCredentials() async {
    try {
      final email = await getSavedEmail();
      return email != null && email.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Đăng nhập tự động bằng sinh trắc học
  /// Trả về email nếu xác thực thành công, null nếu thất bại
  Future<String?> quickLogin() async {
    try {
      // Kiểm tra đã bật chưa
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        return null;
      }

      // Kiểm tra có credentials đã lưu không
      final hasCredentials = await hasSavedCredentials();
      if (!hasCredentials) {
        return null;
      }

      // Xác thực bằng sinh trắc học
      final biometricName = await getPrimaryBiometricName();
      final authenticated = await authenticate(
        reason: 'Sử dụng $biometricName để đăng nhập',
        useErrorDialogs: true,
        stickyAuth: true,
      );

      if (authenticated) {
        return await getSavedEmail();
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Kiểm tra và hiển thị thông tin về sinh trắc học
  Future<BiometricStatus> getBiometricStatus() async {
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) {
        return BiometricStatus.notSupported;
      }

      final available = await getAvailableBiometrics();
      if (available.isEmpty) {
        return BiometricStatus.notEnrolled;
      }

      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        return BiometricStatus.disabled;
      }

      return BiometricStatus.ready;
    } catch (e) {
      return BiometricStatus.error;
    }
  }
}

/// Trạng thái của sinh trắc học
enum BiometricStatus {
  /// Thiết bị không hỗ trợ
  notSupported,
  
  /// Chưa cài đặt sinh trắc học
  notEnrolled,
  
  /// Đã tắt trong app
  disabled,
  
  /// Sẵn sàng sử dụng
  ready,
  
  /// Lỗi
  error,
}

extension BiometricStatusExtension on BiometricStatus {
  String get message {
    switch (this) {
      case BiometricStatus.notSupported:
        return 'Thiết bị không hỗ trợ sinh trắc học';
      case BiometricStatus.notEnrolled:
        return 'Chưa cài đặt sinh trắc học. Vui lòng cài đặt trong Cài đặt hệ thống';
      case BiometricStatus.disabled:
        return 'Đăng nhập sinh trắc học đã được tắt';
      case BiometricStatus.ready:
        return 'Sẵn sàng sử dụng';
      case BiometricStatus.error:
        return 'Có lỗi xảy ra';
    }
  }
}

