import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/job/model/job_category_model.dart';

class JobCategoryService {
  final ApiService _apiService;

  JobCategoryService() : _apiService = ApiService();

  /// Hàm tiện ích để wrap lỗi
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

  //  Lấy danh sách tất cả category
  Future<List<JobCategoryModel>> getAllCategories() async {
    return _handleApi(
      () async {
        final res = await _apiService.get(endpoint: ApiConstants.jobCategoryAll);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => JobCategoryModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (JobCategory/all)',
        );
      },
      'Lỗi khi tải danh sách JobCategory',
    );
  }

  //  Lấy category theo ID
  Future<JobCategoryModel?> getCategoryById(String id) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.jobCategoryById.replaceFirst('{id}', id);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => JobCategoryModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (JobCategory/$id)',
        );
      },
      'Lỗi khi tải JobCategory theo ID',
    );
  }

  //  Lấy category theo code
  Future<JobCategoryModel?> getCategoryByCode(String code) async {
    return _handleApi(
      () async {
        final endpoint =
            ApiConstants.jobCategoryByCode.replaceFirst('{code}', code);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => JobCategoryModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (JobCategory/code/$code)',
        );
      },
      'Lỗi khi tải JobCategory theo code',
    );
  }

  //  Lấy danh sách category đang active
  Future<List<JobCategoryModel>> getActiveCategories() async {
    final all = await getAllCategories();
    return all.where((e) => e.isActive == true).toList();
  }
}
