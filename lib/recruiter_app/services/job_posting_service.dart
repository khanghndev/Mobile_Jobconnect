import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/data/models/job_posting_model.dart';

class JobPostingService {
  final ApiService _apiService;

  JobPostingService() : _apiService = ApiService();

  //TODO: Hàm nội bộ dùng chung để lấy danh sách job posting
  Future<List<JobPostingModel>> _fetchJobPostingList({
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
          .map((item) => JobPostingModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tải $dataType: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: Lấy danh sách job posting theo companyId
  Future<List<JobPostingModel>> getJobPostingsByCompany({
    required String companyId,
  }) async {
    return _fetchJobPostingList(
      endpoint: '${ApiConstants.jobPostingEndpoint}/company/$companyId',
      dataType: 'job posting theo công ty',
    );
  }

  //TODO: Lấy chi tiết job posting theo id
  Future<JobPostingModel?> getJobPostingById({
    required String jobId,
  }) async {
    try {
      final res = await _apiService.get(
        endpoint: '${ApiConstants.jobPostingEndpoint}/$jobId',
      );

      if (res == null) return null;

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (chi tiết job posting)',
          type: ServerExceptionType.api,
        );
      }

      return JobPostingModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tải chi tiết job posting: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: Tạo mới job posting (truyền model)
  Future<JobPostingModel> createJobPosting({
    required JobPostingModel jobPosting,
  }) async {
    try {
      final res = await _apiService.post(
        endpoint: '${ApiConstants.jobPostingEndpoint}/simple',
        body: jobPosting.toJson(),
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (tạo job posting)',
          type: ServerExceptionType.api,
        );
      }

      return JobPostingModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tạo job posting: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: Cập nhật job posting theo id (truyền model)
  Future<JobPostingModel> updateJobPosting({
    required String jobId,
    required JobPostingModel jobPosting,
  }) async {
    try {
      final res = await _apiService.put(
        endpoint: '${ApiConstants.jobPostingEndpoint}/$jobId',
        body: jobPosting.toJson(),
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (cập nhật job posting)',
          type: ServerExceptionType.api,
        );
      }

      return JobPostingModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi cập nhật job posting: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: Xoá job posting theo id
  Future<void> deleteJobPosting({
    required String jobId,
  }) async {
    try {
      await _apiService.delete(
        endpoint: '${ApiConstants.jobPostingEndpoint}/$jobId',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi xoá job posting: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //TODO: Cập nhật trạng thái job posting (open, closed, waiting, editing)
  Future<void> updateJobPostingStatus({
    required String jobId,
    required String newStatus,
  }) async {
    try {
      await _apiService.patch(
        endpoint: '${ApiConstants.jobPostingEndpoint}/$jobId/status',
        body: {'status': newStatus},
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi cập nhật trạng thái job posting: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }
}