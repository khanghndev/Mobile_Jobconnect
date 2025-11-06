import 'package:flutter/material.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/recruiter_app/services/job_application_service.dart';

class JobApplicationViewModel extends ChangeNotifier {
  final JobApplicationService _jobApplicationService = JobApplicationService();

  // STATE
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  List<JobApplicationModel> _applications = [];
  JobApplicationModel? _selectedJobApplication;

  // GETTERS
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  List<JobApplicationModel> get applications => _applications;
  JobApplicationModel? get selectedJobApplication => _selectedJobApplication;

  // PRIVATE STATE HANDLER
  void _setState({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<JobApplicationModel>? applications,
    JobApplicationModel? selectedJobApplication,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _errorMessage = errorMessage;
    _applications = applications ?? _applications;
    _selectedJobApplication = selectedJobApplication ?? _selectedJobApplication;
    notifyListeners();
  }

  Future<void> _handleApiCall<T>({
    required Future<T> Function() apiCall,
    void Function(T)? onSuccess,
  }) async {
    _setState(isLoading: true, isSuccess: false, errorMessage: null);
    try {
      final result = await apiCall();
      if (onSuccess != null) onSuccess(result);
      _setState(isSuccess: true, isLoading: false);
    } on ServerException catch (e) {
      _setState(errorMessage: e.err, isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } 
  }

  // GET: Lấy toàn bộ ứng tuyển
  Future<void> getAllJobApplications() async {
    await _handleApiCall<List<JobApplicationModel>>(
      apiCall: () => _jobApplicationService.getAllApplications(),
      onSuccess: (model) => _applications = model,
    );
  }

  // GET: Lấy ứng tuyển theo người dùng
  Future<void> getJobApplicationsByUser(String idUser) async {
    await _handleApiCall<List<JobApplicationModel>>(
      apiCall: () => _jobApplicationService.getApplicationsByUser(idUser: idUser),
      onSuccess: (model) => _applications = model,
    );
  }

  // GET: Lấy ứng tuyển theo bài đăng tuyển
  Future<void> getJobApplicationsByJobPost(String jobPostId) async {
    await _handleApiCall<List<JobApplicationModel>>(
      apiCall: () => _jobApplicationService.getApplicationsByJobPost(jobPostId: jobPostId),
      onSuccess: (model) => _applications = model,
    );
  }

  // GET: Lấy ứng tuyển cụ thể (jobPostId + userId)
  Future<JobApplicationModel?> getJobApplicationByKey(String jobPostId, String userId) async {
    JobApplicationModel? result;
    await _handleApiCall<JobApplicationModel?>(
      apiCall: () => _jobApplicationService.getApplicationById(jobPostId: jobPostId, userId: userId),
      onSuccess: (model) => result = model,
    );
    return result;
  }

  Future<void> getJobApplicationDetail(String jobPostId, String userId) async {
    await _handleApiCall<JobApplicationModel?>(
      apiCall: () => _jobApplicationService.getApplicationById(jobPostId: jobPostId, userId: userId),
      onSuccess: (model) => _selectedJobApplication = model,
    );
  }

  // POST: Tạo ứng tuyển mới
  Future<void> createJobApplication(JobApplicationModel model) async {
    await _handleApiCall<JobApplicationModel>(
      apiCall: () => _jobApplicationService.createApplication(model: model),
      onSuccess: (created) => _applications.add(created),
    );
  }

  // PUT: Cập nhật ứng tuyển
  Future<void> updateJobApplication(String jobPostId, String userId, JobApplicationModel model) async {
    await _handleApiCall<JobApplicationModel>(
      apiCall: () => _jobApplicationService.updateApplication(
        jobPostId: jobPostId,
        userId: userId,
        model: model,
      ),
      onSuccess: (updated) {
        final index = _applications.indexWhere(
          (a) => a.idJobPost == jobPostId && a.idUser  == userId,
        );
        if (index != -1) _applications[index] = updated;
      },
    );
  }

  // PUT: Cập nhật trạng thái ứng tuyển
  Future<void> updateJobApplicationStatus(String jobPostId, String userId, String newStatus) async {
    // await _handleApiCall<void>(
    //   apiCall: () => _jobApplicationService.updateApplication(
    //     jobPostId: jobPostId,
    //     userId: userId,
    //     // newStatus: newStatus,
    //   ),
    //   onSuccess: (_) {
    //     final index = _applications.indexWhere(
    //       (a) => a.idJobPost == jobPostId && a.idUser  == userId,
    //     );
    //     if (index != -1) {
    //       _applications[index] = _applications[index].copyWith(applicationStatus: newStatus);
    //     }
    //   },
    // );
  }

  // DELETE: Xoá ứng tuyển
  Future<void> deleteJobApplication(String jobPostId, String userId) async {
    await _handleApiCall<void>(
      apiCall: () => _jobApplicationService.deleteApplication(
        jobPostId: jobPostId,
        userId: userId,
      ),
      onSuccess: (_) {
        _applications.removeWhere(
          (a) => a.idJobPost == jobPostId && a.idUser == userId,
        );
      },
    );
  }

  // REFRESH (phục vụ UI)
  Future<void> refreshApplications({String? userId, String? jobPostId}) async {
    if (userId != null) {
      await getJobApplicationsByUser(userId);
    } else if (jobPostId != null) {
      await getJobApplicationsByJobPost(jobPostId);
    } else {
      await getAllJobApplications();
    }
  }

  // RESET STATE
  void resetState() {
    _setState(
      isLoading: false,
      isSuccess: false,
      errorMessage: null,
      applications: [],
    );
  }
}
