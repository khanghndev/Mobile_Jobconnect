import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/model/interview_schedule_model.dart';

class InterviewScheduleService {
  final ApiService _apiService;

  InterviewScheduleService() : _apiService = ApiService();

  //  Hàm nội bộ để tải danh sách lịch phỏng vấn từ API
  Future<List<InterviewScheduleModel>> _fetchInterviewScheduleList({
    required String endpoint,
    required String dataType,
  }) async {
    try {
      final res = await _apiService.get(endpoint: endpoint);

      if (res is! List) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API ($dataType): không phải là danh sách JSON',
          type: ServerExceptionType.api,
        );
      }

      return res
          .map((item) => InterviewScheduleModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi không xác định khi tải $dataType: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //  Lấy tất cả lịch phỏng vấn
  Future<List<InterviewScheduleModel>> getAllInterviewSchedules() async {
    return _fetchInterviewScheduleList(
      endpoint: ApiConstants.interviewScheduleEndpoint,
      dataType: 'danh sách lịch phỏng vấn',
    );
  }

  //  Lấy lịch phỏng vấn theo ID
  Future<InterviewScheduleModel> getInterviewScheduleById({
    required String id,
  }) async {
    try {
      final res = await _apiService.get(
        endpoint: '${ApiConstants.interviewScheduleEndpoint}/$id',
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (chi tiết lịch phỏng vấn)',
          type: ServerExceptionType.api,
        );
      }

      return InterviewScheduleModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tải chi tiết lịch phỏng vấn: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //  Lấy lịch phỏng vấn theo ID bài tuyển dụng (idJobPost)
  Future<List<InterviewScheduleModel>> getInterviewScheduleByJobId({
    required String jobId,
  }) async {
    return _fetchInterviewScheduleList(
      endpoint: '${ApiConstants.interviewScheduleEndpoint}/jobposting/$jobId',
      dataType: 'lịch phỏng vấn theo Job ID',
    );
  }

  //  Tạo mới lịch phỏng vấn
  Future<InterviewScheduleModel> createInterviewSchedule({
    required InterviewScheduleModel schedule,
  }) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.interviewScheduleEndpoint,
        body: schedule.toJson(),
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (tạo lịch phỏng vấn)',
          type: ServerExceptionType.api,
        );
      }

      return InterviewScheduleModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tạo lịch phỏng vấn mới: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //  Cập nhật lịch phỏng vấn
  Future<InterviewScheduleModel> updateInterviewSchedule({
    required InterviewScheduleModel schedule,
  }) async {
    try {
      final res = await _apiService.put(
        endpoint: '${ApiConstants.interviewScheduleEndpoint}/${schedule.idSchedule}',
        body: schedule.toJson(),
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (cập nhật lịch phỏng vấn)',
          type: ServerExceptionType.api,
        );
      }

      return InterviewScheduleModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi cập nhật lịch phỏng vấn: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  //  Xoá lịch phỏng vấn theo ID
  Future<void> deleteInterviewSchedule({
    required String id,
  }) async {
    try {
      await _apiService.delete(
        endpoint: '${ApiConstants.interviewScheduleEndpoint}/$id',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi xoá lịch phỏng vấn: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }
}