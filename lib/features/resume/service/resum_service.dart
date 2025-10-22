import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/resume/model/resume_model.dart';

class ResumeService {
  final ApiService _apiService;

  ResumeService() : _apiService = ApiService();

  // TODO: Lấy tất cả CV (GET: /api/resume)
  Future<List<ResumeModel>> getAllResumes() async {
    return _fetchResumeList(
      endpoint: ApiConstants.resumeEndpoint,
      dataType: 'Danh sách tất cả CV',
    );
  }

  // TODO: Lấy danh sách CV theo idUser (GET: /api/resume/{idUser})
  Future<List<ResumeModel>> getResumesByUser({ required String idUser }) async {
    return _fetchResumeList(
      endpoint: "${ApiConstants.resumeEndpoint}/$idUser",
      dataType: 'CV của user',
    );
  }

  // TODO: Lấy CV mặc định để hiển thị (GET: /api/resume/by-user/{candidateId})
  Future<ResumeModel?> getDefaultResume({ required String candidateId }) async {
    try {
      final res = await _apiService.get(
        endpoint: "${ApiConstants.resumeEndpoint}/by-user/$candidateId",
      );
      if (res == null || res.isEmpty) return null;
      return ResumeModel.fromJson(res);
    } catch (e) {
      throw ServerException(
        err: 'Không thể lấy CV mặc định: ${e.toString()}',
        type: ServerExceptionType.api,
      );
    }
  }

  // TODO: Lấy tất cả CV của 1 user (GET: /api/resume/user/{userId})
  Future<List<ResumeModel>> getResumesForUserProfile({ required String userId }) async {
    return _fetchResumeList(
      endpoint: "${ApiConstants.resumeEndpoint}/user/$userId",
      dataType: 'CV của user',
    );
  }

  // TODO: Tạo CV mới (POST: /api/resume)
  Future<ResumeModel> createResume(ResumeModel resume) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.resumeEndpoint,
        body: {
          "idUser": resume.idUser,
          "fileUrl": resume.fileUrl,
          "fileName": resume.fileName,
          "fileId": resume.fileId,
          "fileSizeKB": resume.fileSizeKB,
          "isDefault": resume.isDefault,
        },
      );

      return ResumeModel.fromJson(res);
    } catch (e) {
      throw ServerException(
        err: 'Không thể tạo CV: ${e.toString()}',
        type: ServerExceptionType.api,
      );
    }
  }

  // TODO: Cập nhật CV (PUT: /api/resume/{id})
  Future<void> updateResume({ required String id, required ResumeModel updated }) async {
    try {
      await _apiService.put(
        endpoint: "${ApiConstants.resumeEndpoint}/$id",
        body: {
          "fileUrl": updated.fileUrl,
          "fileName": updated.fileName,
          "fileSizeKB": updated.fileSizeKB,
          "isDefault": updated.isDefault,
        },
      );
    } catch (e) {
      throw ServerException(
        err: 'Không thể cập nhật CV: ${e.toString()}',
        type: ServerExceptionType.api,
      );
    }
  }

  // TODO: Xóa CV (DELETE: /api/resume/{id})
  Future<void> deleteResume({ required String idResume}) async {
    try {
      await _apiService.delete(
        endpoint: "${ApiConstants.resumeEndpoint}/$idResume",
      );
    } catch (e) {
      throw ServerException(
        err: 'Không thể xóa CV: ${e.toString()}',
        type: ServerExceptionType.api,
      );
    }
  }

  // TODO: Đặt CV làm mặc định (POST: /api/resume/set-default)
  Future<void> setDefaultResume({
    required String userId,
    required String fileId,
  }) async {
    try {
      await _apiService.post(
        endpoint: "${ApiConstants.resumeEndpoint}/set-default",
        body: {
          "userId": userId,
          "fileId": fileId,
        },
      );
    } catch (e) {
      throw ServerException(
        err: 'Không thể đặt CV mặc định: ${e.toString()}',
        type: ServerExceptionType.api,
      );
    }
  }

  // TODO: Tải xuống CV (GET: /api/resume/download/{userId}/{fileId})
  Future<Map<String, dynamic>> downloadResume({
    required String userId,
    required String fileId,
  }) async {
    try {
      final res = await _apiService.get(
        endpoint: "${ApiConstants.resumeEndpoint}/download/$userId/$fileId",
      );
      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi tải file không hợp lệ',
          type: ServerExceptionType.api,
        );
      }
      return res;
    } catch (e) {
      throw ServerException(
        err: 'Không thể tải CV: ${e.toString()}',
        type: ServerExceptionType.api,
      );
    }
  }

  // TODO:  nội bộ xử lý fetch list (chuẩn hóa)
  Future<List<ResumeModel>> _fetchResumeList({
    required String endpoint,
    required String dataType,
  }) async {
    try {
      final res = await _apiService.get(endpoint: endpoint);

      if (res is! List) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API ($dataType): không phải danh sách JSON',
          type: ServerExceptionType.api,
        );
      }

      final resumes = res
          .map((item) => ResumeModel.fromJson(item as Map<String, dynamic>))
          .toList();

      return resumes;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi không xác định khi tải $dataType: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }
}