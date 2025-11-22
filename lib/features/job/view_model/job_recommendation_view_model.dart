import 'package:flutter/material.dart';
import 'package:job_connect/features/job/model/home_page_public.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/job/model/smart_schedule_model.dart';
import 'package:job_connect/features/job/service/job_recommendation_service.dart';

class JobRecommendationViewModel extends ChangeNotifier {
  final JobRecommendationService _service = JobRecommendationService();

  // STATE
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  // DATA
  List<JobPostingModel> _personalizedJobs = [];
  List<JobPostingModel> _homepageJobs = [];
  List<String> _trendingSkills = [];
  List<String> _popularLocations = [];
  HomePagePublic? _homepagePublic;
  SmartScheduleModel? _smartSchedule;

  // GETTERS
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;

  List<JobPostingModel> get personalizedJobs => _personalizedJobs;
  List<JobPostingModel> get homepageJobs => _homepageJobs;
  List<String> get trendingSkills => _trendingSkills;
  List<String> get popularLocations => _popularLocations;
  HomePagePublic? get homepagePublic => _homepagePublic;
  SmartScheduleModel? get smartSchedule => _smartSchedule;

  // PRIVATE STATE MANAGEMENT
  void _setState({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<JobPostingModel>? personalizedJobs,
    List<JobPostingModel>? homepageJobs,
    List<String>? trendingSkills,
    List<String>? popularLocations,
    HomePagePublic? homepagePublic,
    SmartScheduleModel? smartSchedule,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _errorMessage = errorMessage;
    if (personalizedJobs != null) _personalizedJobs = personalizedJobs;
    if (homepageJobs != null) _homepageJobs = homepageJobs;
    if (trendingSkills != null) _trendingSkills = trendingSkills;
    if (popularLocations != null) _popularLocations = popularLocations;
    if (homepagePublic != null) _homepagePublic = homepagePublic;
    if (smartSchedule != null) _smartSchedule = smartSchedule;
    notifyListeners();
  }

  // GENERIC API CALL HANDLER
  Future<void> _handleApiCall<T>({
    required Future<T> Function() apiCall,
    required void Function(T) onSuccess,
    String? errorMsg,
  }) async {
    _setState(isLoading: true, isSuccess: false, errorMessage: null);
    try {
      final result = await apiCall();
      onSuccess(result);
      _setState(isLoading: false, isSuccess: true);
    } catch (e) {
      _setState(isLoading: false, isSuccess: false, errorMessage: e.toString());
    }
  }

  // API METHODS

  /// Load personalized jobs
  Future<void> loadPersonalizedJobs({
    String? preferredLocation,
    double maxDistanceKm = 50,
    double? minSalary,
    double? maxSalary,
    String? preferredWorkType,
    String? preferredExperienceLevel,
    String? preferredSkills,
    int limit = 10,
  }) async {
    await _handleApiCall<List<JobPostingModel>>(
      apiCall: () => _service.getPersonalizedJobs(
        preferredLocation: preferredLocation,
        maxDistanceKm: maxDistanceKm,
        minSalary: minSalary,
        maxSalary: maxSalary,
        preferredWorkType: preferredWorkType,
        preferredExperienceLevel: preferredExperienceLevel,
        preferredSkills: preferredSkills,
        limit: limit,
      ),
      onSuccess: (res) => _setState(personalizedJobs: res),
      errorMsg: 'Lỗi khi tải job recommendation cá nhân hóa',
    );
  }

  /// Load homepage jobs
  Future<void> loadHomepageJobs() async {
    await _handleApiCall<List<JobPostingModel>>(
      apiCall: () => _service.getHomepageJobs(),
      onSuccess: (res) => _setState(homepageJobs: res),
      errorMsg: 'Lỗi khi tải homepage jobs',
    );
  }

  /// Load trending skills
  Future<void> loadTrendingSkills({int limit = 10}) async {
    await _handleApiCall<List<String>>(
      apiCall: () => _service.getTrendingSkills(limit: limit),
      onSuccess: (res) => _setState(trendingSkills: res),
      errorMsg: 'Lỗi khi tải trending skills',
    );
  }

  /// Load popular locations
  Future<void> loadPopularLocations({int limit = 10}) async {
    await _handleApiCall<List<String>>(
      apiCall: () => _service.getPopularLocations(limit: limit),
      onSuccess: (res) => _setState(popularLocations: res),
      errorMsg: 'Lỗi khi tải popular locations',
    );
  }

  /// Load homepage public data
  Future<void> loadHomepagePublic() async {
    await _handleApiCall<HomePagePublic>(
      apiCall: () => _service.getHomepagePublicJobs(),
      onSuccess: (res) => _setState(homepagePublic: res),
      errorMsg: 'Lỗi khi tải homepage public',
    );
  }

  /// Create smart schedule
  Future<void> createSmartSchedule({
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
    await _handleApiCall<SmartScheduleModel>(
      apiCall: () => _service.createSmartSchedule(
        userId: userId,
        preferredScheduleTypes: preferredScheduleTypes,
        preferredWorkingDays: preferredWorkingDays,
        preferredMinHoursPerWeek: preferredMinHoursPerWeek,
        preferredMaxHoursPerWeek: preferredMaxHoursPerWeek,
        preferredAreas: preferredAreas,
        preferredSkills: preferredSkills,
        maxDistanceKm: maxDistanceKm,
        clusterCount: clusterCount,
        takePerCluster: takePerCluster,
        anchorLocation: anchorLocation,
        includeFeaturedFirst: includeFeaturedFirst,
      ),
      onSuccess: (smartSchedule) {
        _setState(smartSchedule: smartSchedule);
      },
      errorMsg: 'Lỗi khi tạo smart schedule',
    );
  }
}
