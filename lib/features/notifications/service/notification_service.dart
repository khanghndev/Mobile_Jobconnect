import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/notifications/model/notification_model.dart';

class NotificationService {
  final ApiService _apiService;

  NotificationService() : _apiService = ApiService();

  // TODO: Hàm nội bộ xử lý gọi API và parse danh sách
  Future<List<NotificationModel>> _fetchNotificationList({
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
          .map((item) => NotificationModel.fromJson(item as Map<String, dynamic>))
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

  // TODO: Lấy danh sách thông báo
  Future<List<NotificationModel>> getNotifications() async {
    return _fetchNotificationList(
      endpoint: ApiConstants.notificationEndpoint,
      dataType: 'thông báo',
    );
  }

  // TODO: Lấy chi tiết thông báo theo ID
  Future<NotificationModel> getNotificationById({required String id}) async {
    try {
      final res = await _apiService.get(
        endpoint: '${ApiConstants.notificationEndpoint}/$id',
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (chi tiết thông báo)',
          type: ServerExceptionType.api,
        );
      }

      return NotificationModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tải chi tiết thông báo: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  // TODO: Thêm thông báo mới
  Future<NotificationModel> createNotification(NotificationModel notification) async {
    try {
      final res = await _apiService.post(
        endpoint: ApiConstants.notificationEndpoint,
        body: notification.toJson(),
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (tạo thông báo)',
          type: ServerExceptionType.api,
        );
      }

      return NotificationModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi tạo thông báo mới: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  // TODO: Cập nhật thông báo theo ID
  Future<NotificationModel> updateNotification({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final res = await _apiService.put(
        endpoint: '${ApiConstants.notificationEndpoint}/$id',
        body: data,
      );

      if (res is! Map<String, dynamic>) {
        throw ServerException(
          err: 'Phản hồi không hợp lệ từ API (cập nhật thông báo)',
          type: ServerExceptionType.api,
        );
      }

      return NotificationModel.fromJson(res);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi cập nhật thông báo: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  // TODO: Xóa thông báo theo ID
  Future<void> deleteNotification({required String id}) async {
    try {
      await _apiService.delete(
        endpoint: '${ApiConstants.notificationEndpoint}/$id',
      );
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: 'Lỗi khi xóa thông báo: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }
}
