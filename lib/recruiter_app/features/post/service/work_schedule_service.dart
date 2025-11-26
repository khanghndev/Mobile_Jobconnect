import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';

class WorkScheduleService {
  final ApiService _apiService = ApiService();

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

  /// Lấy danh sách các work schedule types từ API
  /// Nếu không có endpoint riêng, sẽ lấy từ các job postings hiện có
  Future<List<String>> getWorkScheduleTypes() async {
    return _handleApi(
      () async {
        try {
          // Thử lấy từ endpoint riêng nếu có (có thể tạo sau)
          // Hiện tại sử dụng các giá trị constant dựa trên hình ảnh
          // Các giá trị: "Theo giờ", "Theo ngày", "Theo tuần", "Theo tháng", "Linh hoạt", "Theo dự án"
          return [
            'Theo giờ',
            'Theo ngày',
            'Theo tuần',
            'Theo tháng',
            'Linh hoạt',
            'Theo dự án',
          ];
        } catch (e) {
          // Fallback: trả về danh sách mặc định
          return [
            'Theo giờ',
            'Theo ngày',
            'Theo tuần',
            'Theo tháng',
            'Linh hoạt',
            'Theo dự án',
          ];
        }
      },
      'Lỗi khi tải danh sách lịch làm việc',
    );
  }

  /// Lấy distinct work schedule types từ các job postings hiện có
  Future<List<String>> getWorkScheduleTypesFromJobs() async {
    return _handleApi(
      () async {
        try {
          // Lấy tất cả job postings
          final res = await _apiService.get(endpoint: ApiConstants.jobPostingAllEndpoint);
          final jobs = ApiResponseParser.parseList(
            res: res,
            fromJson: (json) => json,
            errorMsg: 'Phản hồi không hợp lệ',
          );

          // Lấy distinct workSchedule từ các jobs
          final scheduleTypes = <String>{};
          for (var job in jobs) {
            // Lấy từ workSchedule field
            if (job['workSchedule'] != null && job['workSchedule'].toString().isNotEmpty) {
              scheduleTypes.add(job['workSchedule'].toString());
            }
            // Lấy từ workSchedules array
            if (job['workSchedules'] != null && job['workSchedules'] is List) {
              final schedules = job['workSchedules'] as List;
              for (var schedule in schedules) {
                if (schedule is Map && schedule['scheduleType'] != null) {
                  scheduleTypes.add(schedule['scheduleType'].toString());
                }
              }
            }
          }

          // Nếu không có gì, trả về danh sách mặc định
          if (scheduleTypes.isEmpty) {
            return [
              'Theo giờ',
              'Theo ngày',
              'Theo tuần',
              'Theo tháng',
              'Linh hoạt',
              'Theo dự án',
            ];
          }

          // Sắp xếp và trả về
          final sorted = scheduleTypes.toList()..sort();
          return sorted;
        } catch (e) {
          // Fallback: trả về danh sách mặc định
          return [
            'Theo giờ',
            'Theo ngày',
            'Theo tuần',
            'Theo tháng',
            'Linh hoạt',
            'Theo dự án',
          ];
        }
      },
      'Lỗi khi tải danh sách lịch làm việc từ jobs',
    );
  }
}

