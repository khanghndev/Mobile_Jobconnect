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

  // TODO: Lấy tất cả việc làm đã lưu của user
  Future<void> fetchSavedJobsByUser(String idUser) async {
    _setState(isLoading: true, isSuccess: false, errorMessage: null);
    try {
      final jobs = await _jobSavedService.getSavedJobsByUser(idUser);
      _setState(savedJobs: jobs, isSuccess: true);
    } on ServerException catch (e) {
      _setState(errorMessage: e.err, isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } finally {
      _setState(isLoading: false);
    }
  }

  // TODO: Kiểm tra job đã lưu
  Future<bool> isJobSaved(String jobPost, String user) async {
    try {
      return await _jobSavedService.checkJobSaved(jobPost, user);
    } catch (_) {
      return false;
    }
  }

  // TODO: Lưu job
  Future<void> saveJob(JobSavedModel job) async {
    _setState(isLoading: true, errorMessage: null);
    try {
      await _jobSavedService.saveJob(job);
      _setState(isSuccess: true);
    } on ServerException catch (e) {
      _setState(errorMessage: e.err, isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } finally {
      _setState(isLoading: false);
    }
  }

  // TODO: Xóa job đã lưu
  Future<void> deleteSavedJob(String jobPost, String user) async {
    _setState(isLoading: true, errorMessage: null);
    try {
      await _jobSavedService.deleteSavedJob(jobPost, user);
      // Cập nhật lại danh sách local sau khi xóa
      _savedJobs.removeWhere((job) => job.idJobPost == jobPost && job.idUser == user);
      _setState(isSuccess: true);
    } on ServerException catch (e) {
      _setState(errorMessage: e.err, isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } finally {
      _setState(isLoading: false);
    }
  }

  // TODO: Reset state
  void resetState() {
    _setState(
      isLoading: false,
      isSuccess: false,
      errorMessage: null,
      savedJobs: [],
    );
  }
}