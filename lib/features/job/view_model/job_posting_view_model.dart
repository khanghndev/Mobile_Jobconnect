  import 'package:flutter/material.dart';
  import 'package:job_connect/config/enum/work_type.dart';
  import 'package:job_connect/config/error/server_exception.dart';
  import 'package:job_connect/features/job/model/job_posting_model.dart';
  import 'package:job_connect/features/job/service/job_posting_service.dart';

  class JobPostingViewModel extends ChangeNotifier {
    final JobPostingService _jobPostingService = JobPostingService();

    // STATE
    bool _isLoading = false;
    bool _isSuccess = false;
    String? _errorMessage;
    List<JobPostingModel> _jobPostings = [];
    JobPostingModel? _selectedJobPosting;

    // GETTERS
    bool get isLoading => _isLoading;
    bool get isSuccess => _isSuccess;
    String? get errorMessage => _errorMessage;
    List<JobPostingModel> get jobPostings => _jobPostings;
    JobPostingModel? get selectedJobPosting => _selectedJobPosting;

    // PRIVATE STATE HANDLER
    void _setState({
      bool? isLoading,
      bool? isSuccess,
      String? errorMessage,
      List<JobPostingModel>? jobPostings,
      JobPostingModel? selectedJobPosting,
    }) {
      _isLoading = isLoading ?? _isLoading;
      _isSuccess = isSuccess ?? _isSuccess;
      _errorMessage = errorMessage;
      _jobPostings = jobPostings ?? _jobPostings;
      _selectedJobPosting = selectedJobPosting ?? _selectedJobPosting;
      notifyListeners();
    }

    // GENERIC API HANDLER
    Future<void> _handleApiCall<T>({
      required Future<T> Function() apiCall,
      void Function(T)? onSuccess,
    }) async {
      _setState(isLoading: true, isSuccess: false, errorMessage: null);
      try {
        final result = await apiCall();
        if (onSuccess != null) onSuccess(result);
        _setState(isLoading: false, isSuccess: true, errorMessage: null);
      } on ServerException catch (e) {
        _setState(isLoading: false, isSuccess: false, errorMessage: e.err);
      } catch (e) {
        _setState(isLoading: false, isSuccess: false, errorMessage: e.toString());
      }
    }

    /// Lấy tất cả job postings
    Future<void> fetchAllJobPostings() async {
      await _handleApiCall<List<JobPostingModel>>(
        apiCall: () => _jobPostingService.getAllJobPostings(),
        onSuccess: (list) => _setState(jobPostings: list, errorMessage: null),
      );
    }

    // Lọc theo category
    void filterJobPostingsByCategory(String categoryName) {
      if (categoryName.toLowerCase() == 'tất cả') {
        // Nếu chọn "Tất cả", giữ nguyên danh sách hiện tại
        _setState(jobPostings: _jobPostings, errorMessage: null);
        return;
      }

      final filteredList = _jobPostings
          .where((job) =>
              job.category?.categoryName?.toLowerCase() ==
              categoryName.toLowerCase())
          .toList();

      _setState(
        jobPostings: filteredList,
        errorMessage: filteredList.isEmpty ? 'Không có tin tuyển dụng cho lựa chọn này' : null,
      );
    }

    /// Lấy tất cả job postings nhưng **loại bỏ** job có workType == 'FullTime'
    Future<void> fetchJobPostingsExcludeFullTime() async {
      await _handleApiCall<List<JobPostingModel>>(
        apiCall: () async {
          final allJobs = await _jobPostingService.getAllJobPostings();
          // Loại bỏ fulltime (case-insensitive)
          return allJobs
              .where((job) =>
                (job.workType.toLowerCase() != WorkType.fulltime.name &&
                  job.workType.toLowerCase() != 'full-time'))
              .toList();
        },
        onSuccess: (filteredList) {
          _setState(jobPostings: filteredList, errorMessage: null);
        },
      );
    }

    /// Lấy job postings nổi bật (featured)
    Future<void> fetchFeaturedJobPostings() async {
      await _handleApiCall<List<JobPostingModel>>(
        apiCall: () => _jobPostingService.getFeaturedJobPostings(),
        onSuccess: (list) => _setState(jobPostings: list, errorMessage: null),
      );
    }

    /// Lấy danh sách job posting theo companyId
    Future<void> fetchJobPostingsByCompany({required String companyId}) async {
      await _handleApiCall<List<JobPostingModel>>(
        apiCall: () => _jobPostingService.getJobPostingsByCompany(companyId: companyId),
        onSuccess: (list) => _setState(jobPostings: list, errorMessage: null),
      );
    }

    /// Tìm kiếm job postings với filter (body POST /search)
    Future<void> searchJobPostings(Map<String, dynamic> filters) async {
      await _handleApiCall<List<JobPostingModel>>(
        apiCall: () => _jobPostingService.searchJobPostings(filters),
        onSuccess: (list) => _setState(jobPostings: list, errorMessage: null),
      );
    }

    /// Lấy job postings gần vị trí
    Future<void> fetchNearbyJobPostings({
      required double latitude,
      required double longitude,
      double radiusKm = 10,
    }) async {
      await _handleApiCall<List<JobPostingModel>>(
        apiCall: () => _jobPostingService.getNearbyJobPostings(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
        ),
        onSuccess: (list) => _setState(jobPostings: list, errorMessage: null),
      );
    }

    /// Lấy job postings theo khu vực (POST /area)
    Future<void> fetchJobPostingsByArea({required String area}) async {
      await _handleApiCall<List<JobPostingModel>>(
        apiCall: () => _jobPostingService.getJobPostingsByArea(area: area),
        onSuccess: (list) => _setState(jobPostings: list, errorMessage: null),
      );
    }

    /// Lấy chi tiết job posting theo id
    Future<void> fetchJobPostingById({required String jobId}) async {
      await _handleApiCall<JobPostingModel?>(
        apiCall: () => _jobPostingService.getJobPostingById(jobId: jobId),
        onSuccess: (model) {
          if (model != null) _setState(selectedJobPosting: model, errorMessage: null);
        },
      );
    }

    /// Tạo mới job posting
    Future<void> createJobPosting({required JobPostingModel jobPosting}) async {
      await _handleApiCall<JobPostingModel>(
        apiCall: () => _jobPostingService.createJobPosting(jobPosting: jobPosting),
        onSuccess: (created) {
          final list = List<JobPostingModel>.from(_jobPostings)..insert(0, created);
          _setState(jobPostings: list, errorMessage: null);
        },
      );
    }

    /// Cập nhật job posting
    Future<void> updateJobPosting({
      required String jobId,
      required JobPostingModel jobPosting,
    }) async {
      await _handleApiCall<JobPostingModel>(
        apiCall: () => _jobPostingService.updateJobPosting(jobId: jobId, jobPosting: jobPosting),
        onSuccess: (updated) {
          final idx = _jobPostings.indexWhere((j) => j.idJobPost == jobId);
          if (idx != -1) {
            final list = List<JobPostingModel>.from(_jobPostings)..[idx] = updated;
            _setState(jobPostings: list, errorMessage: null);
          }
          if (_selectedJobPosting?.idJobPost == jobId) {
            _setState(selectedJobPosting: updated, errorMessage: null);
          }
        },
      );
    }

    /// Xoá job posting
    Future<void> deleteJobPosting({required String jobId}) async {
      await _handleApiCall<void>(
        apiCall: () => _jobPostingService.deleteJobPosting(jobId: jobId),
        onSuccess: (_) {
          final list = List<JobPostingModel>.from(_jobPostings)..removeWhere((j) => j.idJobPost == jobId);
          _setState(jobPostings: list, errorMessage: null);
          if (_selectedJobPosting?.idJobPost == jobId) _setState(selectedJobPosting: null, errorMessage: null);
        },
      );
    }

    /// Cập nhật trạng thái job posting
    Future<void> updateJobPostingStatus({required String jobId, required String newStatus}) async {
      await _handleApiCall<void>(
        apiCall: () => _jobPostingService.updateJobPostingStatus(jobId: jobId, newStatus: newStatus),
        onSuccess: (_) {
          final idx = _jobPostings.indexWhere((j) => j.idJobPost == jobId);
          if (idx != -1) {
            final updated = _jobPostings[idx].copyWith(postStatus: newStatus);
            final list = List<JobPostingModel>.from(_jobPostings)..[idx] = updated;
            _setState(jobPostings: list, errorMessage: null);
          }
          if (_selectedJobPosting?.idJobPost == jobId) {
            _setState(selectedJobPosting: _selectedJobPosting?.copyWith(postStatus: newStatus), errorMessage: null);
          }
        },
      );
    }

    // REFRESH helper
    Future<void> refresh({String? companyId}) async {
      if (companyId != null) {
        await fetchJobPostingsByCompany(companyId: companyId);
      } else {
        await fetchAllJobPostings();
      }
    }

    // RESET STATE
    void resetState() {
      _setState(
        isLoading: false,
        isSuccess: false,
        errorMessage: null,
        jobPostings: [],
        selectedJobPosting: null,
      );
    }
  }
