import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/job/model/home_page_public.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/job/model/skill_model.dart';
import 'package:job_connect/features/job/model/smart_schedule_model.dart';

class JobRecommendationService {
  final ApiService _apiService;

  JobRecommendationService() : _apiService = ApiService();

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

  /// Lấy danh sách job recommendation cá nhân hóa với filter
  Future<List<JobPostingModel>> getPersonalizedJobs({
    String? preferredLocation,
    double maxDistanceKm = 50,
    double? minSalary,
    double? maxSalary,
    String? preferredWorkType,
    String? preferredExperienceLevel,
    String? preferredSkills,
    int limit = 10,
  }) async {
    return _handleApi(
      () async {
        final queryParams = <String, dynamic>{
          if (preferredLocation != null) 'preferredLocation': preferredLocation,
          'maxDistanceKm': maxDistanceKm,
          if (minSalary != null) 'minSalary': minSalary,
          if (maxSalary != null) 'maxSalary': maxSalary,
          if (preferredWorkType != null) 'preferredWorkType': preferredWorkType,
          if (preferredExperienceLevel != null) 'preferredExperienceLevel': preferredExperienceLevel,
          if (preferredSkills != null) 'preferredSkills': preferredSkills,
          'limit': limit,
        };

        final res = await _apiService.get(
          endpoint: ApiConstants.jobRecommendationPersonalized,
          queryParams : queryParams,
          requireAuth: true,
        );

        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => JobPostingModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi lấy job recommendation cá nhân hóa',
        );
      },
      'Lỗi khi tải job recommendation cá nhân hóa',
    );
  }

  /// Lấy danh sách job recommendation cho homepage
  Future<List<JobPostingModel>> getHomepageJobs() async {
    return _handleApi(
      () async {
        final res = await _apiService.get(
          endpoint: ApiConstants.jobRecommendationHomepage,
          requireAuth: true,
        );

        // Lấy recommendedJobs, nếu trống thì lấy featuredJobs
        List<dynamic> jobsJson = res['recommendedJobs'] ?? [];
        if (jobsJson.isEmpty) {
          jobsJson = res['featuredJobs'] ?? [];
        }

        return jobsJson
            .map<JobPostingModel>((json) => JobPostingModel.fromJson(json))
            .toList();
      },
      'Lỗi khi tải job homepage',
    );
  }

  /// Lấy danh sách trending skills
  Future<List<String>> getTrendingSkills({int limit = 10}) async {
    return _handleApi(
      () async {
        final queryParams = {'limit': limit};

        final res = await _apiService.get(
          endpoint: ApiConstants.jobRecommendationTrendingSkills,
          queryParams: queryParams,
        );

        if (res != null && res is List) {
          return List<String>.from(res);
        }

        return <String>[];
      },
      'Lỗi khi tải trending skills',
    );
  }

  /// Lấy popular locations
  Future<List<SkillModel>> getPopularLocations({int limit = 10}) async {
    return _handleApi(
      () async {
        final queryParams = {
          'limit': limit,
        };

        final res = await _apiService.get(
          endpoint: ApiConstants.jobRecommendationPopularLocations,
          queryParams: queryParams,
        );

        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => SkillModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi lấy trending skills',
        );
      },
      'Lỗi khi tải trending skills',
    );
  }

  /// Lấy điểm match với một jobId cụ thể
  Future<double> getMatchScore({required String jobId}) async {
    return _handleApi(
      () async {
        // Thay {jobId} trong endpoint bằng giá trị thực tế
        final endpoint = ApiConstants.jobRecommendationMatchScore.replaceFirst('{jobId}', jobId);

        final res = await _apiService.get(
          endpoint: endpoint,
        );

        return ApiResponseParser.parseDouble(
          res: res,
          errorMsg: 'Phản hồi không hợp lệ khi lấy match score',
        );
      },
      'Lỗi khi tải match score',
    );
  }

  /// Lấy job recommendation homepage public
  Future<HomePagePublic> getHomepagePublicJobs() async {
    return _handleApi(
      () async {
        final res = await _apiService.get(
          endpoint: ApiConstants.jobRecommendationHomepagePublic,
        );

        return HomePagePublic.fromJson(res);
      },
      'Lỗi khi tải homepage public jobs',
    );
  }

  /// Smart schedule POST
  Future<SmartScheduleModel> createSmartSchedule({
    required String userId,
    List<String> preferredScheduleTypes = const [],
    List<String> preferredWorkingDays = const [],
    double preferredMinHoursPerWeek = 0,
    double preferredMaxHoursPerWeek = 0,
    List<String> preferredAreas = const [],
    List<String> preferredSkills = const [],
    double maxDistanceKm = 0,
    int clusterCount = 0,
    int takePerCluster = 0,
    String anchorLocation = '',
    bool includeFeaturedFirst = true,
  }) async {
    final body = {
      'userId': userId,
      'preferredScheduleTypes': preferredScheduleTypes,
      'preferredWorkingDays': preferredWorkingDays,
      'preferredMinHoursPerWeek': preferredMinHoursPerWeek,
      'preferredMaxHoursPerWeek': preferredMaxHoursPerWeek,
      'preferredAreas': preferredAreas,
      'preferredSkills': preferredSkills,
      'maxDistanceKm': maxDistanceKm,
      'clusterCount': clusterCount,
      'takePerCluster': takePerCluster,
      'anchorLocation': anchorLocation,
      'includeFeaturedFirst': includeFeaturedFirst,
    };

    return _handleApi<SmartScheduleModel>(() async {
      final response = await _apiService.post(
        endpoint: ApiConstants.jobRecommendationSmartSchedule,
        body: body,
        requireAuth: true
      );
      if (response == null) {
        throw Exception('API trả về null');
      }
      return SmartScheduleModel.fromJson(response);
    }, 'Lỗi khi tạo smart schedule');
  }

}
