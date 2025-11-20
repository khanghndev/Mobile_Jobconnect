import 'package:flutter/material.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/features/home/service/job_saved_service.dart';
import 'package:job_connect/features/home/model/job_saved_model.dart';

class JobSavedViewModel extends ChangeNotifier {
  final JobSavedService _jobSavedService = JobSavedService();

  // STATE
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  List<JobSavedModel> _savedJobs = [];

  // GETTERS
  List<JobSavedModel> get savedJobs => _savedJobs;
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;

  // PRIVATE SET STATE
  void _setState({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<JobSavedModel>? savedJobs,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _errorMessage = errorMessage;
    _savedJobs = savedJobs ?? _savedJobs;
    notifyListeners();
  }

  // PRIVATE API HANDLER
  Future<void> _handleApiCall<T>({
    required Future<T> Function() apiCall,
    void Function(T)? onSuccess,
    bool updateLoading = true,
  }) async {
    if (updateLoading) _setState(isLoading: true, errorMessage: null);
    try {
      final result = await apiCall();
      if (onSuccess != null) onSuccess(result);
      if (updateLoading) _setState(isLoading: false);
    } on ServerException catch (e) {
      _setState(isLoading: false, errorMessage: e.err);
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString());
    }
  }

  // Lấy danh sách công việc đã lưu
  Future<void> fetchSavedJobsByUser(String idUser) async {
    await _handleApiCall<List<JobSavedModel>>(
      apiCall: () => _jobSavedService.getSavedJobsByUser(idUser),
      onSuccess: (jobs) => _setState(savedJobs: jobs, isSuccess: true),
    );
  }

  // Kiểm tra job đã lưu
  Future<bool> isJobSaved(String jobPost, String user) async {
    try {
      return await _jobSavedService.checkJobSaved(jobPost, user);
    } catch (_) {
      return false;
    }
  }

  // Lưu job
  Future<void> saveJob(JobSavedModel job) async {
    await _handleApiCall(
      apiCall: () => _jobSavedService.saveJob(job),
      onSuccess: (_) {
        // Cập nhật danh sách local ngay
        final exists = _savedJobs.any(
            (j) => j.idJobPost == job.idJobPost && j.idUser == job.idUser);
        if (!exists) {
          _savedJobs = [..._savedJobs, job];
        }
        _setState(isSuccess: true);
      },
    );
  }

  // Xóa job đã lưu
  Future<void> deleteSavedJob(String jobPost, String user) async {
    await _handleApiCall(
      apiCall: () => _jobSavedService.deleteSavedJob(jobPost, user),
      onSuccess: (_) {
        _savedJobs.removeWhere(
            (job) => job.idJobPost == jobPost && job.idUser == user);
        _setState(isSuccess: true);
      },
    );
  }

  // Reset state
  void resetState() {
    _setState(
      isLoading: false,
      isSuccess: false,
      errorMessage: null,
      savedJobs: [],
    );
  }
}
