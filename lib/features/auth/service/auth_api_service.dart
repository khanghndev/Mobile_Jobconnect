import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/model/api_model.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/data/dto/auth_dto/auth_register_dto.dart';
import 'package:job_connect/features/auth/model/login_model.dart';

class AuthApiService {
  final ApiService _apiService;

  AuthApiService() : _apiService = ApiService();

  /// Đăng ký người dùng mới
  Future<String> register(RegisterDto dto) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.registerEndpoint,
        body: dto.toJson(),
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ: $res',
          type: ServerExceptionType.api,
        );
      }

      final msg = res["message"] ?? "Đăng ký thành công";
      return msg.toString();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: e.toString(),
        type: ServerExceptionType.unknown,
      );
    }
  }

  /// Đăng nhập, parse về LoginModel và lưu token + trạng thái login
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
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ: $res',
          type: ServerExceptionType.api,
        );
      }

      // Check theo status code trong JSON
      // final status = res["status"];
      // if (status != 200) {
      //   final errMsg = res["message"] ?? "Đăng nhập thất bại";
      //   throw ServerException(
      //     err: errMsg.toString(),
      //     type: ServerExceptionType.auth,
      //   );
      // }

      // Parse dữ liệu
      final loginData = LoginModel.fromJson(res);
      return loginData;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: e.toString(),
        type: ServerExceptionType.unknown,
      );
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    
  }

}
