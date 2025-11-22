import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/job/model/home_page_public.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
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
  /// API: GET /api/JobRecommendation/personalized
  /// Nếu không truyền idUser, API sẽ tự lấy từ JWT token
  Future<List<JobPostingModel>> getPersonalizedJobs({
    String? idUser,
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
          if (idUser != null) 'idUser': idUser,
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
  /// API: GET /api/JobRecommendation/homepage
  /// Nếu không truyền idUser, API sẽ tự lấy từ JWT token
  Future<List<JobPostingModel>> getHomepageJobs({String? idUser}) async {
    return _handleApi(
      () async {
        final queryParams = <String, dynamic>{
          if (idUser != null) 'idUser': idUser,
        };
        
        final res = await _apiService.get(
          endpoint: ApiConstants.jobRecommendationHomepage,
          queryParams: queryParams.isNotEmpty ? queryParams : null,
          requireAuth: true,
        );

        // API trả về PersonalizedHomepageDto với cấu trúc:
        // { recommendedJobs: [...], featuredJobs: [...], ... }
        if (res == null) {
          return <JobPostingModel>[];
        }

        // Đảm bảo res là Map
        if (res is! Map<String, dynamic>) {
          throw ServerException(
            err: 'Phản hồi không hợp lệ từ API homepage',
            type: ServerExceptionType.unknown,
          );
        }

        // Lấy recommendedJobs, nếu trống thì lấy featuredJobs
        List<dynamic> jobsJson = [];
        if (res.containsKey('recommendedJobs') && res['recommendedJobs'] != null) {
          jobsJson = res['recommendedJobs'] is List 
              ? res['recommendedJobs'] as List<dynamic>
              : [];
        }
        
        if (jobsJson.isEmpty && res.containsKey('featuredJobs') && res['featuredJobs'] != null) {
          jobsJson = res['featuredJobs'] is List 
              ? res['featuredJobs'] as List<dynamic>
              : [];
        }

        return jobsJson
            .whereType<Map<String, dynamic>>()
            .map<JobPostingModel>((json) => JobPostingModel.fromJson(json))
            .toList();
      },
      'Lỗi khi tải job homepage',
    );
  }

  /// Lấy danh sách trending skills
  /// API: GET /api/JobRecommendation/trending-skills
  /// [AllowAnonymous] - Không cần authentication
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
  /// API: GET /api/JobRecommendation/popular-locations
  /// API trả về List<string>, không phải List<SkillModel>
  /// [AllowAnonymous] - Không cần authentication
  Future<List<String>> getPopularLocations({int limit = 10}) async {
    return _handleApi(
      () async {
        final queryParams = {
          'limit': limit,
        };

        final res = await _apiService.get(
          endpoint: ApiConstants.jobRecommendationPopularLocations,
          queryParams: queryParams,
        );

        // API trả về List<string> trực tiếp
        if (res != null && res is List) {
          return List<String>.from(res);
        }

        return <String>[];
      },
      'Lỗi khi tải popular locations',
    );
  }

  /// Lấy điểm match với một jobId cụ thể
  /// API: GET /api/JobRecommendation/match-score/{jobId}
  /// API trả về: { JobId, UserId, MatchScore, MatchPercentage }
  /// Nếu không truyền idUser, API sẽ tự lấy từ JWT token
  Future<double> getMatchScore({
    required String jobId,
    String? idUser,
  }) async {
    return _handleApi(
      () async {
        // Thay {jobId} trong endpoint bằng giá trị thực tế
        final endpoint = ApiConstants.jobRecommendationMatchScore.replaceFirst('{jobId}', jobId);

        final queryParams = <String, dynamic>{
          if (idUser != null) 'idUser': idUser,
        };

        final res = await _apiService.get(
          endpoint: endpoint,
          queryParams: queryParams.isNotEmpty ? queryParams : null,
          requireAuth: true,
        );

        // API trả về object: { JobId, UserId, MatchScore, MatchPercentage }
        if (res == null) {
          throw ServerException(
            err: 'Phản hồi không hợp lệ khi lấy match score',
            type: ServerExceptionType.unknown,
          );
        }

        if (res is Map<String, dynamic>) {
          final matchScore = res['matchScore'];
          if (matchScore != null) {
            return (matchScore as num).toDouble();
          }
        }

        throw ServerException(
          err: 'Phản hồi không hợp lệ khi lấy match score: không tìm thấy matchScore',
          type: ServerExceptionType.unknown,
        );
      },
      'Lỗi khi tải match score',
    );
  }

  /// Lấy job recommendation homepage public
  /// API: GET /api/JobRecommendation/homepage/public
  /// [AllowAnonymous] - Không cần authentication
  /// Trả về: { TrendingSkills, PopularLocations, Message }
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
  /// API: POST /api/JobRecommendation/smart-schedule
  /// [Authorize] - Cần authentication
  /// API tự lấy userId từ JWT token, nhưng vẫn cần truyền trong body
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
