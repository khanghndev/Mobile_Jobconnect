import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  /// Map WorkType từ UI format sang API enum format
  /// UI: "Full-time", "Part-time", "Temporary" -> API: "fulltime", "parttime", "temporary"
  String _mapWorkTypeToApiFormat(String workType) {
    final normalized = workType.trim().toLowerCase();
    
    // Map các giá trị phổ biến từ UI sang API enum format
    // API enum chỉ hỗ trợ: fulltime, parttime, freelancer, remote, internship, fresher, senior, junior
    final mapping = {
      'full-time': 'fulltime',
      'fulltime': 'fulltime',
      'part-time': 'parttime',
      'parttime': 'parttime',
      'temporary': 'parttime', // Temporary không có trong enum, map sang parttime
      'freelancer': 'freelancer',
      'remote': 'remote',
      'internship': 'internship',
      'fresher': 'fresher',
      'senior': 'senior',
      'junior': 'junior',
      'contract': 'parttime', // Contract không có trong enum, map sang parttime
    };
    
    // Nếu có trong mapping, trả về giá trị đã map
    if (mapping.containsKey(normalized)) {
      return mapping[normalized]!;
    }
    
    // Nếu không có, loại bỏ dấu gạch ngang và chuyển thành lowercase
    return normalized.replaceAll('-', '').replaceAll(' ', '');
  }

  //  Lấy tất cả job posting
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

  //  Lấy job posting nổi bật (featured)
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

  //  Lấy danh sách job posting theo companyId
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

  //  Tìm kiếm job posting theo từ khóa, vị trí, filter
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

  //  Lấy job posting gần vị trí người dùng (theo lat, lon, bán kính)
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

  //  Lấy job posting theo khu vực (city, district, province, ...)
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

  //  Lấy chi tiết job posting theo id
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

  //   Tạo mới job posting
  Future<JobPostingModel> createJobPosting({
    required JobPostingModel jobPosting,
    bool isUrgent = false,
    bool isSeasonal = false,
  }) async {
    return _handleApi(
      () async {
        // API sử dụng Newtonsoft.Json với default settings (PascalCase properties)
        // Nhưng có thể có vấn đề với deserialization, thử gửi trực tiếp với camelCase
        // vì Newtonsoft.Json có thể tự động map nếu có JsonProperty attributes
        
        // Build DTO với đảm bảo các trường bắt buộc không null/empty
        final dtoJson = jobPosting.toJson();
        
        // API sử dụng Newtonsoft.Json với default settings (PascalCase properties)
        // Nhưng không có ContractResolver, nên cần gửi với PascalCase
        // Đảm bảo tất cả các trường bắt buộc có giá trị và không null
        final title = (dtoJson['title'] as String?)?.trim() ?? '';
        final description = (dtoJson['description'] as String?)?.trim() ?? '';
        final location = (dtoJson['location'] as String?)?.trim() ?? '';
        final workTypeRaw = (dtoJson['workType'] as String?)?.trim() ?? '';
        final experienceLevel = (dtoJson['experienceLevel'] as String?)?.trim() ?? '';
        
        // Map WorkType từ UI format sang API enum format (lowercase, no hyphen)
        final workType = _mapWorkTypeToApiFormat(workTypeRaw);
        
        // Validate trước khi gửi
        if (title.isEmpty) {
          throw Exception('Title không được để trống');
        }
        if (description.isEmpty) {
          throw Exception('Description không được để trống');
        }
        if (location.isEmpty) {
          throw Exception('Location không được để trống');
        }
        if (workType.isEmpty) {
          throw Exception('WorkType không được để trống');
        }
        if (experienceLevel.isEmpty) {
          throw Exception('ExperienceLevel không được để trống');
        }
        
        // API sử dụng Newtonsoft.Json với default settings (PascalCase properties)
        // Không có ContractResolver, nên cần gửi với PascalCase
        // Đảm bảo tất cả các trường bắt buộc có giá trị và không null
        final dto = <String, dynamic>{
          'Title': title, // Đã được validate không empty
          'Description': description, // Đã được validate không empty
          'Requirements': dtoJson['requirements'],
          'Salary': dtoJson['salary'],
          'Location': location, // Đã được validate không empty
          'Latitude': dtoJson['latitude'],
          'Longitude': dtoJson['longitude'],
          'WorkType': workType, // Đã được map sang API format (lowercase, no hyphen)
          'ExperienceLevel': experienceLevel, // Đã được validate không empty
          'IdCompany': dtoJson['idCompany'],
          'IdUser': dtoJson['idUser'],
          'ApplicationDeadline': dtoJson['applicationDeadline'],
          'Benefits': dtoJson['benefits'],
          'IdCategory': dtoJson['idCategory'],
          'JobCategory': dtoJson['jobCategory'],
          'UrgencyLevel': dtoJson['urgencyLevel'] ?? 'normal',
          'WorkSchedule': dtoJson['workSchedule'],
          'MinHoursPerWeek': dtoJson['minHoursPerWeek'],
          'MaxHoursPerWeek': dtoJson['maxHoursPerWeek'],
          'WorkDaysPerWeek': dtoJson['workDaysPerWeek'],
          'ProjectDuration': dtoJson['projectDuration'],
          'SeasonalStartDate': dtoJson['seasonalStartDate'],
          'SeasonalEndDate': dtoJson['seasonalEndDate'],
          'HourlyRate': dtoJson['hourlyRate'],
          'DailyRate': dtoJson['dailyRate'],
          'ProjectBudget': dtoJson['projectBudget'],
          'IsSeasonal': dtoJson['isSeasonal'] ?? false,
          'IsUrgent': dtoJson['isUrgent'] ?? isUrgent,
        };

        // Debug: In ra dữ liệu sẽ gửi
        if (kDebugMode) {
          debugPrint('📤 Sending DTO (PascalCase): ${jsonEncode(dto)}');
          debugPrint('📤 Title value: "$title" (length: ${title.length}, isEmpty: ${title.isEmpty})');
          debugPrint('📤 Description value: "$description" (length: ${description.length}, isEmpty: ${description.isEmpty})');
          debugPrint('📤 Location value: "$location" (length: ${location.length}, isEmpty: ${location.isEmpty})');
          debugPrint('📤 WorkType (raw): "$workTypeRaw" -> (mapped): "$workType" (length: ${workType.length}, isEmpty: ${workType.isEmpty})');
          debugPrint('📤 ExperienceLevel value: "$experienceLevel" (length: ${experienceLevel.length}, isEmpty: ${experienceLevel.isEmpty})');
        }
        
        // API nhận CreateJobPostingDto trực tiếp từ [FromBody]
        // Gửi trực tiếp DTO với PascalCase (API expect PascalCase properties)
        final res = await _apiService.post(
          endpoint: ApiConstants.jobPostingEndpoint,
          body: dto,
          requireAuth: true,
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

  //  Cập nhật job posting theo ID
  Future<JobPostingModel> updateJobPosting({
    required String jobId,
    required JobPostingModel jobPosting,
  }) async {
    return _handleApi(
      () async {
        // API sử dụng Newtonsoft.Json với default settings (PascalCase properties)
        // Cần format dữ liệu giống như createJobPosting
        final dtoJson = jobPosting.toJson();
        
        // Validate và format các trường
        final title = (dtoJson['title'] as String?)?.trim() ?? '';
        final description = (dtoJson['description'] as String?)?.trim() ?? '';
        final location = (dtoJson['location'] as String?)?.trim() ?? '';
        final workTypeRaw = (dtoJson['workType'] as String?)?.trim() ?? '';
        final experienceLevel = (dtoJson['experienceLevel'] as String?)?.trim() ?? '';
        
        // Map WorkType từ UI format sang API enum format (lowercase, no hyphen)
        final workType = _mapWorkTypeToApiFormat(workTypeRaw);
        
        // Validate trước khi gửi
        if (title.isEmpty) {
          throw Exception('Title không được để trống');
        }
        if (description.isEmpty) {
          throw Exception('Description không được để trống');
        }
        if (location.isEmpty) {
          throw Exception('Location không được để trống');
        }
        if (workType.isEmpty) {
          throw Exception('WorkType không được để trống');
        }
        if (experienceLevel.isEmpty) {
          throw Exception('ExperienceLevel không được để trống');
        }
        
        // Format DTO với PascalCase như API expect
        final dto = <String, dynamic>{
          'IdJobPost': jobPosting.idJobPost,
          'Title': title,
          'Description': description,
          'Requirements': dtoJson['requirements'],
          'Salary': dtoJson['salary'],
          'Location': location,
          'Latitude': dtoJson['latitude'],
          'Longitude': dtoJson['longitude'],
          'WorkType': workType, // Đã được map sang API format
          'ExperienceLevel': experienceLevel,
          'IdCompany': dtoJson['idCompany'],
          'IdUser': dtoJson['idUser'],
          'ApplicationDeadline': dtoJson['applicationDeadline'],
          'Benefits': dtoJson['benefits'],
          'IdCategory': dtoJson['idCategory'],
          'JobCategory': dtoJson['jobCategory'],
          'UrgencyLevel': dtoJson['urgencyLevel'] ?? 'normal',
          'WorkSchedule': dtoJson['workSchedule'],
          'MinHoursPerWeek': dtoJson['minHoursPerWeek'],
          'MaxHoursPerWeek': dtoJson['maxHoursPerWeek'],
          'WorkDaysPerWeek': dtoJson['workDaysPerWeek'],
          'ProjectDuration': dtoJson['projectDuration'],
          'SeasonalStartDate': dtoJson['seasonalStartDate'],
          'SeasonalEndDate': dtoJson['seasonalEndDate'],
          'HourlyRate': dtoJson['hourlyRate'],
          'DailyRate': dtoJson['dailyRate'],
          'ProjectBudget': dtoJson['projectBudget'],
          'IsSeasonal': dtoJson['isSeasonal'] ?? false,
          'IsUrgent': dtoJson['isUrgent'] ?? false,
          'PostStatus': dtoJson['postStatus'] ?? 'open', // Thêm PostStatus vào DTO
        };

        // Debug: In ra dữ liệu sẽ gửi
        if (kDebugMode) {
          debugPrint('📤 Updating JobPosting (PascalCase): ${jsonEncode(dto)}');
          debugPrint('📤 WorkType (raw): "$workTypeRaw" -> (mapped): "$workType"');
        }

        final endpoint = ApiConstants.jobPostingByIdEndpoint.replaceFirst('{id}', jobId);
        final res = await _apiService.put(
          endpoint: endpoint,
          body: dto,
        );

        // Nếu API trả về 204 No Content, handleResponse sẽ trả về statusCode (số nguyên)
        // Trong trường hợp này, trả về jobPosting đã được cập nhật với updatedAt mới
        if (res is int && (res == 204 || res == 200)) {
          return jobPosting.copyWith(
            updatedAt: DateTime.now(),
          );
        }

        // Nếu response body rỗng hoặc null, cũng coi như thành công
        if (res == null || (res is String && res.isEmpty)) {
          return jobPosting.copyWith(
            updatedAt: DateTime.now(),
          );
        }

        // Nếu có response body là Map, parse như bình thường
        if (res is Map<String, dynamic>) {
          return ApiResponseParser.parseObject(
            res: res,
            fromJson: (json) => JobPostingModel.fromJson(json),
            errorMsg: 'Phản hồi không hợp lệ khi cập nhật job posting',
          );
        }

        // Nếu không phải Map, coi như thành công và trả về jobPosting đã cập nhật
        return jobPosting.copyWith(
          updatedAt: DateTime.now(),
        );
      },
      'Lỗi khi cập nhật job posting',
    );
  }

  //  Xoá job posting theo ID
  Future<void> deleteJobPosting({required String jobId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.jobPostingByIdEndpoint.replaceFirst('{id}', jobId);
        await _apiService.delete(endpoint: endpoint);
      },
      'Lỗi khi xoá job posting',
    );
  }

  //  Cập nhật trạng thái job posting (open, closed, waiting, editing)
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