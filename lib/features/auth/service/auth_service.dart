import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/auth/model/login_model.dart';

class AuthService {
  final ApiService _apiService;

  AuthService() : _apiService = ApiService();

  /// Đăng ký người dùng mới
  Future<String> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String comfirmPassword,
  }) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.registerEndpoint,
        body: {
          "userName": name,
          "email": email,
          "phoneNumber": phone,
          "password": password,
          // "comfirmPassword": comfirmPassword,
          "roleName": "Candidate", // Mặc định là Candidate luôn 
        }
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ: $res',
          type: ServerExceptionType.api,
        );
      }

      final idUser = res["idUser"];
      return idUser.toString();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: e.toString(),
        type: ServerExceptionType.unknown,
      );
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
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ: $res',
          type: ServerExceptionType.api,
        );
      }

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