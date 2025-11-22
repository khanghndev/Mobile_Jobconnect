import 'package:flutter/material.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/recruiter_app/features/interview/service/interview_schedule_service.dart';
import 'package:job_connect/model/interview_schedule_model.dart';

class InterviewScheduleViewModel extends ChangeNotifier {
  final InterviewScheduleService _service = InterviewScheduleService();

  bool _isLoading = false;
  bool _isSuccess = false;
  bool _isDetailLoading = false;
  String? _errorMessage;

  List<InterviewScheduleModel> _schedules = [];
  List<InterviewScheduleModel> _filteredSchedules = [];
  InterviewScheduleModel? _scheduleDetail;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  bool get isDetailLoading => _isDetailLoading;
  String? get errorMessage => _errorMessage;

  List<InterviewScheduleModel> get schedules => _schedules;
  List<InterviewScheduleModel> get filteredSchedules => _filteredSchedules;

  InterviewScheduleModel? get scheduleDetail => _scheduleDetail;

  // INTERNAL STATE UPDATER
  void _setState({
    bool? isLoading,
    bool? isSuccess,
    bool? isDetailLoading,
    String? errorMessage,
    List<InterviewScheduleModel>? schedules,
    List<InterviewScheduleModel>? filteredSchedules,
    InterviewScheduleModel? scheduleDetail,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _isDetailLoading = isDetailLoading ?? _isDetailLoading;

    // Error luôn cập nhật
    _errorMessage = errorMessage;

    if (schedules != null) _schedules = schedules;
    if (filteredSchedules != null) _filteredSchedules = filteredSchedules;

    if (scheduleDetail != null) _scheduleDetail = scheduleDetail;

    notifyListeners();
  }

  // COMMON API CALL HANDLER (INNER FUNCTION TO REDUCE DUPLICATION)
  Future<void> _handleApiCall<T>({
    required Future<T> Function() apiCall,
    required void Function(T data) onSuccess,
    bool isDetail = false,
  }) async {
    if (isDetail) {
      _setState(isDetailLoading: true, errorMessage: null, isSuccess: false);
    } else {
      _setState(isLoading: true, errorMessage: null, isSuccess: false);
    }

    try {
      final data = await apiCall();
      onSuccess(data);
      _setState(isSuccess: true);
    } on ServerException catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } finally {
      if (isDetail) {
        _setState(isDetailLoading: false);
      } else {
        _setState(isLoading: false);
      }
    }
  }

  // GET ALL SCHEDULES
  Future<void> getAllSchedules() async {
    await _handleApiCall<List<InterviewScheduleModel>>(
      apiCall: () => _service.getAllInterviewSchedules(),
      onSuccess: (data) {
        data.sort((a, b) => a.interviewDate.compareTo(b.interviewDate));
        _setState(
          schedules: data,
          filteredSchedules: data,
        );
      },
    );
  }

  // GET SCHEDULE BY ID
  Future<void> getScheduleDetail(String id) async {
    await _handleApiCall<InterviewScheduleModel>(
      apiCall: () => _service.getInterviewScheduleById(id: id),
      onSuccess: (detail) {
        _setState(scheduleDetail: detail);
      },
      isDetail: true,
    );
  }

  // GET SCHEDULE BY JOB ID
  Future<void> getSchedulesByJobId(String jobId) async {
    await _handleApiCall<List<InterviewScheduleModel>>(
      apiCall: () => _service.getInterviewScheduleByJobId(jobId: jobId),
      onSuccess: (data) {
        _setState(
          schedules: data,
          filteredSchedules: data,
        );
      },
    );
  }

  // CREATE NEW INTERVIEW SCHEDULE
  Future<void> createSchedule(InterviewScheduleModel schedule) async {
    await _handleApiCall<InterviewScheduleModel>(
      apiCall: () => _service.createInterviewSchedule(schedule: schedule),
      onSuccess: (created) {
        final updated = [..._schedules, created];
        updated.sort((a, b) => a.interviewDate.compareTo(b.interviewDate));
        _setState(
          schedules: updated,
          filteredSchedules: updated,
        );
      },
    );
  }

  // UPDATE INTERVIEW SCHEDULE
  Future<void> updateSchedule(InterviewScheduleModel schedule) async {
    await _handleApiCall<InterviewScheduleModel>(
      apiCall: () => _service.updateInterviewSchedule(schedule: schedule),
      onSuccess: (updatedSchedule) {
        final updatedList = _schedules.map((s) {
          return s.idSchedule == updatedSchedule.idSchedule ? updatedSchedule : s;
        }).toList();

        updatedList.sort((a, b) => a.interviewDate.compareTo(b.interviewDate));

        _setState(
          schedules: updatedList,
          filteredSchedules: updatedList,
        );
      },
    );
  }

  // DELETE INTERVIEW SCHEDULE
  Future<void> deleteSchedule(String id) async {
    await _handleApiCall<void>(
      apiCall: () => _service.deleteInterviewSchedule(id: id),
      onSuccess: (_) {
        final updated = _schedules.where((e) => e.idSchedule != id).toList();
        _setState(
          schedules: updated,
          filteredSchedules: updated,
        );
      },
    );
  }

  // FILTER
  void filterSchedules(String keyword) {
    if (keyword.trim().isEmpty) {
      _setState(filteredSchedules: _schedules);
      return;
    }

    final lower = keyword.toLowerCase();

    final filtered = _schedules.where((s) {
      final mode = s.interviewMode?.toLowerCase() ?? '';
      final interviewer = s.interviewer?.toLowerCase() ?? '';
      final note = s.note?.toLowerCase() ?? '';

      return mode.contains(lower) ||
          interviewer.contains(lower) ||
          note.contains(lower);
    }).toList();

    _setState(filteredSchedules: filtered);
  }

  // REFRESH
  Future<void> refresh() async => await getAllSchedules();

  // RESET STATE
  void reset() {
    _setState(
      isLoading: false,
      isDetailLoading: false,
      isSuccess: false,
      errorMessage: null,
      schedules: [],
      filteredSchedules: [],
      scheduleDetail: null,
    );
  }
}
