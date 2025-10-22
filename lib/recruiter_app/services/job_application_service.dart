import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/data/models/job_application_model.dart';

class JobApplicationService {
  final ApiService _apiService;

  JobApplicationService() : _apiService = ApiService();

  //TODO: Hàm nội bộ để tải danh sách Job Application từ API
  Future<List<JobApplicationModel>> _fetchJobApplicationList({
    required String endpoint,
    required String dataType,
  }) async {
    try {
      final res = await _apiService.get(endpoint: endpoint);

      if (res is! List) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API ($dataType): không phải là danh sách JSON',
          type: ServerExceptionType.api,
        );
      }

      return res
          .map((item) => JobApplicationModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi không xác định khi tải $dataType: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: Lấy tất cả Job Application
  Future<List<JobApplicationModel>> getAllJobApplications() async {
    return _fetchJobApplicationList(
      endpoint: ApiConstants.jobApplicationEndpoint,
      dataType: 'danh sách job application',
    );
  }

  //TODO: Lấy Job Application theo ID người dùng (idUser)
  Future<List<JobApplicationModel>> getJobApplicationsByUser({required String idUser}) async {
    return _fetchJobApplicationList(
      endpoint: '${ApiConstants.jobApplicationEndpoint}/user/$idUser',
      dataType: 'job application theo người dùng',
    );
  }

  //TODO: Lấy Job Application theo ID bài đăng tuyển (idJobPost)
  Future<List<JobApplicationModel>> getJobApplicationsByJob({required String jobPostId}) async {
    return _fetchJobApplicationList(
      endpoint: '${ApiConstants.jobApplicationEndpoint}/jobposting/$jobPostId',
      dataType: 'job application theo Job ID',
    );
  }

  //TODO: Lấy chi tiết Job Application theo khóa (jobPostId, userId)
  Future<JobApplicationModel?> getJobApplicationByKey({
    required String jobPostId,
    required String userId,
  }) async {
    try {
      final res = await _apiService.get(
        endpoint: '${ApiConstants.jobApplicationEndpoint}/$jobPostId/$userId',
      );

      if (res == null) return null;

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (chi tiết job application)',
          type: ServerExceptionType.api,
        );
      }

      return JobApplicationModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tải chi tiết job application: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: Tạo mới Job Application
  Future<JobApplicationModel> createJobApplication(Map<String, dynamic> data) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.jobApplicationEndpoint,
        body: data,
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (tạo job application)',
          type: ServerExceptionType.api,
        );
      }

      return JobApplicationModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tạo job application: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: Cập nhật Job Application theo (jobPostId, userId)
  Future<JobApplicationModel> updateJobApplication({
    required String jobPostId,
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final res = await _apiService.put(
        endpoint: '${ApiConstants.jobApplicationEndpoint}/$jobPostId/$userId',
        body: data,
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (cập nhật job application)',
          type: ServerExceptionType.api,
        );
      }

      return JobApplicationModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi cập nhật job application: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: Xoá Job Application theo (jobPostId, userId)
  Future<void> deleteJobApplication({
    required String jobPostId,
    required String userId,
  }) async {
    try {
      await _apiService.delete(
        endpoint: '${ApiConstants.jobApplicationEndpoint}/$jobPostId/$userId',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi xoá job application: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: Cập nhật trạng thái Job Application (applicationStatus)
  Future<void> updateJobApplicationStatus({
    required String jobPostId,
    required String userId,
    required String newStatus,
  }) async {
    try {
      await _apiService.put(
        endpoint: '${ApiConstants.jobApplicationEndpoint}/$jobPostId/$userId/status',
        body: {'applicationStatus': newStatus},
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi cập nhật trạng thái job application: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }
}