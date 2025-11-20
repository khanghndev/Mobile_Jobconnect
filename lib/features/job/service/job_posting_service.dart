import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';

class JobPostingService {
  final ApiService _apiService;

  JobPostingService() : _apiService = ApiService();

  /// Hàm tiện ích xử lý lỗi dùng chung
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

  //TODO: Lấy tất cả job posting
  Future<List<JobPostingModel>> getAllJobPostings() async {
    return _handleApi(
      () async {
        final res = await _apiService.get(endpoint: ApiConstants.jobPostingAllEndpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => JobPostingModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi lấy tất cả job posting',
        );
      },
      'Lỗi khi tải tất cả job posting',
    );
  }

  //TODO: Lấy job posting nổi bật (featured)
  Future<List<JobPostingModel>> getFeaturedJobPostings() async {
    return _handleApi(
      () async {
        final res = await _apiService.get(endpoint: ApiConstants.jobPostingFeaturedEndpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => JobPostingModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi lấy job posting nổi bật',
        );
      },
      'Lỗi khi tải job posting nổi bật',
    );
  }

  //TODO: Lấy danh sách job posting theo companyId
  Future<List<JobPostingModel>> getJobPostingsByCompany({
    required String companyId,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.jobPostingByCompanyEndpoint.replaceFirst('{companyId}', companyId);
        final res = await _apiService.get(endpoint: endpoint);

        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => JobPostingModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi lấy job posting theo công ty',
        );
      },
      'Lỗi khi tải job posting theo công ty',
    );
  }

  //TODO: Tìm kiếm job posting theo từ khóa, vị trí, filter
  Future<List<JobPostingModel>> searchJobPostings(Map<String, dynamic> filters) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.jobPostingSearchEndpoint,
          body: filters,
        );

        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => JobPostingModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi tìm kiếm job posting',
        );
      },
      'Lỗi khi tìm kiếm job posting',
    );
  }

  //TODO: Lấy job posting gần vị trí người dùng (theo lat, lon, bán kính)
  Future<List<JobPostingModel>> getNearbyJobPostings({
    required double latitude,
    required double longitude,
    double radiusKm = 10,
  }) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.jobPostingNearbyEndpoint,
          body: {
            'latitude': latitude,
            'longitude': longitude,
            'radiusKm': radiusKm,
          },
        );

        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => JobPostingModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi lấy job posting gần đây',
        );
      },
      'Lỗi khi tải job posting gần đây',
    );
  }

  //TODO: Lấy job posting theo khu vực (city, district, province, ...)
  Future<List<JobPostingModel>> getJobPostingsByArea({
    required String area,
  }) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.jobPostingAreaEndpoint,
          body: {'area': area},
        );

        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => JobPostingModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi lấy job posting theo khu vực',
        );
      },
      'Lỗi khi tải job posting theo khu vực',
    );
  }

  //TODO: Lấy chi tiết job posting theo id
  Future<JobPostingModel?> getJobPostingById({required String jobId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.jobPostingByIdEndpoint.replaceFirst('{id}', jobId);
        final res = await _apiService.get(endpoint: endpoint);

        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => JobPostingModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi lấy chi tiết job posting',
        );
      },
      'Lỗi khi tải chi tiết job posting',
    );
  }

  //TODO: Tạo mới job posting
  Future<JobPostingModel> createJobPosting({
    required JobPostingModel jobPosting,
  }) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.jobPostingEndpoint,
          body: jobPosting.toJson(),
        );

        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => JobPostingModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi tạo job posting',
        );
      },
      'Lỗi khi tạo job posting',
    );
  }

  //TODO: Cập nhật job posting theo ID
  Future<JobPostingModel> updateJobPosting({
    required String jobId,
    required JobPostingModel jobPosting,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.jobPostingByIdEndpoint.replaceFirst('{id}', jobId);
        final res = await _apiService.put(
          endpoint: endpoint,
          body: jobPosting.toJson(),
        );

        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => JobPostingModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi cập nhật job posting',
        );
      },
      'Lỗi khi cập nhật job posting',
    );
  }

  //TODO: Xoá job posting theo ID
  Future<void> deleteJobPosting({required String jobId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.jobPostingByIdEndpoint.replaceFirst('{id}', jobId);
        await _apiService.delete(endpoint: endpoint);
      },
      'Lỗi khi xoá job posting',
    );
  }

  //TODO: Cập nhật trạng thái job posting (open, closed, waiting, editing)
  Future<void> updateJobPostingStatus({
    required String jobId,
    required String newStatus,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.jobPostingStatusEndpoint.replaceFirst('{id}', jobId);
        await _apiService.patch(endpoint: endpoint, body: {'status': newStatus});
      },
      'Lỗi khi cập nhật trạng thái job posting',
    );
  }
}