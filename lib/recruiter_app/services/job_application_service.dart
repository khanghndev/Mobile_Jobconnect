import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';

class JobApplicationService {
  final ApiService _apiService;

  JobApplicationService() : _apiService = ApiService();

  Future<T> _handleApi<T>(
    Future<T> Function() action,
    String errorMsg,
  ) async {
    try {
      return await action();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: '$errorMsg: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  // GET /api/JobApplication - Lấy tất cả job applications
  Future<List<JobApplicationModel>> getAllApplications() async {
    return _handleApi(
      () async {
        final res = await _apiService.get(endpoint: ApiConstants.jobApplicationEndpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => JobApplicationModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (danh sách job application)',
        );
      },
      'Lỗi khi tải danh sách job application',
    );
  }

  // GET /api/JobApplication/user/{idUser} - Lấy job applications theo người dùng
  Future<List<JobApplicationModel>> getApplicationsByUser({required String idUser}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.jobApplicationByUserEndpoint.replaceFirst('{idUser}', idUser);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => JobApplicationModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (job application theo người dùng)',
        );
      },
      'Lỗi khi tải job application theo người dùng',
    );
  }

  // GET /api/JobApplication/jobposting/{jobPost} - Lấy job applications theo bài đăng
  Future<List<JobApplicationModel>> getApplicationsByJobPost({required String jobPostId}) async {
    return _handleApi(
      () async {
        final endpoint =
            ApiConstants.jobApplicationByJobPostEndpoint.replaceFirst('{jobPost}', jobPostId);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => JobApplicationModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (job application theo jobPost)',
        );
      },
      'Lỗi khi tải job application theo jobPost',
    );
  }

  // GET /api/JobApplication/{jobPost}/{user} - Lấy job application cụ thể
  Future<JobApplicationModel> getApplicationById({
    required String jobPostId,
    required String userId,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.jobApplicationByIdEndpoint
            .replaceFirst('{jobPost}', jobPostId)
            .replaceFirst('{user}', userId);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => JobApplicationModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (job application cụ thể)',
        );
      },
      'Lỗi khi tải chi tiết job application',
    );
  }

  // POST /api/JobApplication - Tạo mới job application
  Future<JobApplicationModel> createApplication({required JobApplicationModel model}) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.jobApplicationEndpoint,
          body: model.toJson(),
        );
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => JobApplicationModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (tạo job application)',
        );
      },
      'Lỗi khi tạo job application',
    );
  }

  // PUT /api/JobApplication/{jobPost}/{user} - Cập nhật job application
  Future<JobApplicationModel> updateApplication({
    required String jobPostId,
    required String userId,
    required JobApplicationModel model,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.jobApplicationByIdEndpoint
            .replaceFirst('{jobPost}', jobPostId)
            .replaceFirst('{user}', userId);
        final res = await _apiService.put(endpoint: endpoint, body: model.toJson());
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => JobApplicationModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (cập nhật job application)',
        );
      },
      'Lỗi khi cập nhật job application',
    );
  }

  // DELETE /api/JobApplication/{jobPost}/{user} - Xóa job application
  Future<void> deleteApplication({
    required String jobPostId,
    required String userId,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.jobApplicationByIdEndpoint
            .replaceFirst('{jobPost}', jobPostId)
            .replaceFirst('{user}', userId);
        await _apiService.delete(endpoint: endpoint);
      },
      'Lỗi khi xóa job application',
    );
  }
}
