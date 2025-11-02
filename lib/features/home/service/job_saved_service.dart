import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/home/model/job_saved_model.dart';

class JobSavedService {
  final ApiService _apiService;

  JobSavedService() : _apiService = ApiService();

  // TODO: Hàm helper xử lý lỗi API chung cho tất cả các request
  Future<T> _handleApi<T>(Future<T> Function() action, String errorMsg) async {
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

  // TODO: Lấy tất cả việc làm đã lưu
  Future<List<JobSavedModel>> getAllSavedJobs() async {
    return _handleApi(() async {
      final res = await _apiService.get(endpoint: ApiConstants.jobSavedEndpoint);
      return ApiResponseParser.parseList(
        res: res,
        fromJson: (json) => JobSavedModel.fromJson(json),
        errorMsg: 'Phản hồi không hợp lệ khi lấy tất cả việc làm đã lưu',
      );
    }, 'Lỗi khi tải tất cả việc làm đã lưu');
  }

  // TODO: Lấy tất cả việc làm đã lưu của 1 user
  Future<List<JobSavedModel>> getSavedJobsByUser(String idUser) async {
    final endpoint = ApiConstants.jobSavedByUser.replaceAll('{idUser}', idUser);
    return _handleApi(() async {
      final res = await _apiService.get(endpoint: endpoint);
      return ApiResponseParser.parseList(
        res: res,
        fromJson: (json) => JobSavedModel.fromJson(json),
        errorMsg: 'Phản hồi không hợp lệ khi lấy việc làm đã lưu của user',
      );
    }, 'Lỗi khi tải việc làm đã lưu theo user');
  }

  // TODO: Lấy tất cả việc làm đã lưu theo jobPost
  Future<List<JobSavedModel>> getSavedJobsByJobPost(String jobPost) async {
    final endpoint = ApiConstants.jobSavedByJobPost.replaceAll('{jobPost}', jobPost);
    return _handleApi(() async {
      final res = await _apiService.get(endpoint: endpoint);
      return ApiResponseParser.parseList(
        res: res,
        fromJson: (json) => JobSavedModel.fromJson(json),
        errorMsg: 'Phản hồi không hợp lệ khi lấy việc làm đã lưu theo jobPost',
      );
    }, 'Lỗi khi tải việc làm đã lưu theo jobPost');
  }

  // TODO: Kiểm tra 1 job đã được lưu bởi user hay chưa
  Future<bool> checkJobSaved(String jobPost, String user) async {
    final endpoint = ApiConstants.jobSavedCheck
        .replaceAll('{jobPost}', jobPost)
        .replaceAll('{user}', user);
    return _handleApi(() async {
      final res = await _apiService.get(endpoint: endpoint);
      return res['isSaved'] ?? false;
    }, 'Lỗi khi kiểm tra việc làm đã lưu');
  }

  // TODO: Lưu 1 job cho user
  Future<void> saveJob(JobSavedModel jobSaved) async {
    return _handleApi(() async {
      await _apiService.post(
        endpoint: ApiConstants.jobSavedEndpoint,
        body: jobSaved.toJson(),
      );
    }, 'Lỗi khi lưu việc làm');
  }

  // TODO: Xóa 1 job đã lưu của user
  Future<void> deleteSavedJob(String jobPost, String user) async {
    final endpoint = ApiConstants.jobSavedDelete
        .replaceAll('{jobPost}', jobPost)
        .replaceAll('{user}', user);
    return _handleApi(() async {
      await _apiService.delete(endpoint: endpoint);
    }, 'Lỗi khi xóa việc làm đã lưu');
  }
}