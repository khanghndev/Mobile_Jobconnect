import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/auth/model/login_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';

class AuthService {
  final ApiService _apiService;

  AuthService() : _apiService = ApiService();

  /// Đăng ký người dùng mới
  Future<String> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String supabaseIdUser,
  }) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.registerEndpoint,
        body: {
          "userName": name,
          "email": email,
          "phoneNumber": phone,
          "password": password,
          "confirmPassword": confirmPassword,
          "roleName": "Candidate",
          "supabaseIdUser": supabaseIdUser,
        },
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ: $res',
          type: ServerExceptionType.api,
        );
      }

      return res["message"].toString();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(err: e.toString(), type: ServerExceptionType.unknown);
    }
  }

  /// Đăng nhập
  Future<LoginModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.loginEndpoint,
        body: {
          "email": email,
          "password": password,
        },
        requireAuth: false, // Login không cần token
      );

      if (res == null) {
        throw ServerException(
          err: 'API trả về null',
          type: ServerExceptionType.api,
        );
      }

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ: ${res.runtimeType} - $res',
          type: ServerExceptionType.api,
        );
      }

      // Kiểm tra các trường bắt buộc
      if (!res.containsKey('token')) {
        throw ServerException(
          err: 'Phản hồi thiếu token: $res',
          type: ServerExceptionType.api,
        );
      }

      if (!res.containsKey('user')) {
        throw ServerException(
          err: 'Phản hồi thiếu thông tin user: $res',
          type: ServerExceptionType.api,
        );
      }

      return LoginModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi đăng nhập: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    // try {
    //   await _apiService.get( endpoint: ApiConstants.logoutEndpoint,);
    // } on ServerException {
    //   rethrow;
    // } catch (e) {
    //   throw ServerException(err: e.toString(), type: ServerExceptionType.unknown);
    // }
  }

  /// Lấy thông tin người dùng theo id
  Future<UserModel> getUserById(String id) async {
    try {
      final res = await _apiService.get(
        endpoint: ApiConstants.getUserByIdEndpoint.replaceFirst("{id}", id),
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ: $res',
          type: ServerExceptionType.api,
        );
      }
      return UserModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(err: e.toString(), type: ServerExceptionType.unknown);
    }
  }

  /// Nhập OTP
  Future<String> enterOtp({ required String email}) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.enterOtp,
        body: {
          "email": email,
        }
      );
      return res["message"].toString();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(err: e.toString(), type: ServerExceptionType.unknown);
    }
  }

  Future<String> forgotPassword({ required String email}) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.forgotPassword,
        body: {
          "email": email,
        }
      );
      return res["message"].toString();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(err: e.toString(), type: ServerExceptionType.unknown);
    }
  }

  /// Xác thực OTP
  Future<String> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.verifyOtp,
        body: {
          "email": email,
          "code": code,
        },
      );
      return res["message"].toString();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(err: e.toString(), type: ServerExceptionType.unknown);
    }
  }

  Future<String> verifyOtpReset({
    required String email,
    required String code,
  }) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.verifyOtpReset,
        body: {
          "email": email,
          "code": code,
        },
      );
      return res["message"].toString();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(err: e.toString(), type: ServerExceptionType.unknown);
    }
  }

  /// Reset mật khẩu
  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _apiService.post(
        endpoint: ApiConstants.resetPassword,
        body: {
          "email": email,
          "newPassword": newPassword,
          "confirmPassword" : confirmPassword
        },
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(err: e.toString(), type: ServerExceptionType.unknown);
    }
  }

  /// Gửi lại OTP
  Future<void> resendOtp({required String email}) async {
    try {
      await _apiService.post(
        endpoint: ApiConstants.resendOtp,
        body: {
          "email": email,
        },
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(err: e.toString(), type: ServerExceptionType.unknown);
    }
  }
}
