import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/profile/model/user_model.dart';

class UserService {
  final ApiService _apiService;

  UserService() : _apiService = ApiService();

  //   Lấy chi tiết người dùng theo ID
  Future<UserModel> getUserById({required String id}) async {
    try {
      final res = await _apiService.get(
        endpoint: '${ApiConstants.userEndpoint}/$id',
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (chi tiết người dùng)',
          type: ServerExceptionType.api,
        );
      }

      return UserModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tải chi tiết người dùng: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //   Thêm người dùng mới
  Future<UserModel> createUser(UserModel user) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.userEndpoint,
        body: user.toJson(),
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (tạo người dùng)',
          type: ServerExceptionType.api,
        );
      }

      return UserModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tạo người dùng mới: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //   Cập nhật người dùng theo ID
  Future<void> updateUser({required UserModel user}) async {
    try {
      await _apiService.put(
        endpoint: '${ApiConstants.userEndpoint}/${user.idUser}',
        body: {
          "idUser": user.idUser,
          "userName": user.userName,
          "email": user.email,
          "phoneNumber": user.phoneNumber,
          "password": user.password,
          "idRole": user.idRole,
          "accountStatus": user.accountStatus,
          "gender": user.gender,
          "address": user.address,
          "dateOfBirth": user.dateOfBirth?.toIso8601String(),
          "avatarUrl": user.avatarUrl,
          "socialLogin": user.socialLogin,
          "createdAt": user.createdAt.toIso8601String(),
          "updatedAt": DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi cập nhật người dùng: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //   Xóa người dùng theo ID
  Future<void> deleteUser({required String id}) async {
    try {
      await _apiService.delete(
        endpoint: '${ApiConstants.userEndpoint}/$id',
      );
    } on ServerException {  
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi xóa người dùng: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //   Lấy tất cả người dùng
  Future<List<UserModel>> getAllUsers() async {
    try {
      final res = await _apiService.get(
        endpoint: ApiConstants.userEndpoint,
      );

      if (res is! List) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (danh sách người dùng)',
          type: ServerExceptionType.api,
        );
      }

      // Chuyển List<dynamic> sang List<UserModel>
      return res.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tải danh sách người dùng: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }
}