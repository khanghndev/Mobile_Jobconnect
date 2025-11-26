import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/model/recruiter_info_model.dart';

class RecruiterService {
  final ApiService _apiService;

  RecruiterService() : _apiService = ApiService();

  //  Lấy thông tin recruiter theo id
  Future<RecruiterInfoModel?> getRecruiterById({
    required String id,
  }) async {
    try {
      final res = await _apiService.get(
        endpoint: '${ApiConstants.recruiterInfoEndpoint}/$id',
      );

      if (res == null) return null;

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (chi tiết recruiter)',
          type: ServerExceptionType.api,
        );
      }

      return RecruiterInfoModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tải thông tin recruiter: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //  Tạo recruiter mới (truyền model)
  Future<RecruiterInfoModel> createRecruiter({
    required RecruiterInfoModel recruiter,
  }) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.recruiterInfoEndpoint,
        body: recruiter.toJson(),
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (tạo recruiter)',
          type: ServerExceptionType.api,
        );
      }

      return RecruiterInfoModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tạo recruiter: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //  Cập nhật recruiter (truyền model luôn)
  Future<RecruiterInfoModel> updateRecruiter({
    required RecruiterInfoModel recruiter,
  }) async {
    try {
      final res = await _apiService.put(
        endpoint: '${ApiConstants.recruiterInfoEndpoint}/${recruiter.idUser}',
        body: recruiter.toJson(),
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (cập nhật recruiter)',
          type: ServerExceptionType.api,
        );
      }

      return RecruiterInfoModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi cập nhật recruiter: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //  Xóa recruiter theo id
  Future<void> deleteRecruiter({
    required String id,
  }) async {
    try {
      await _apiService.delete(
        endpoint: '${ApiConstants.recruiterInfoEndpoint}/$id',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi xóa recruiter: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }
}