import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/notifications/model/notification_model.dart';
import 'package:job_connect/api/api_response_parser.dart';

class NotificationService {
  final ApiService _apiService;

  NotificationService() : _apiService = ApiService();

  /// Hàm helper xử lý API và bắt lỗi
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

  /// Lấy danh sách thông báo
  Future<List<NotificationModel>> getNotifications() async {
    return _handleApi(
      () async {
        final res = await _apiService.get(endpoint: ApiConstants.notificationEndpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => NotificationModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi lấy danh sách thông báo',
        );
      },
      'Lỗi khi tải danh sách thông báo',
    );
  }

  Future<List<NotificationModel>> getNotificationsByIdUser() async {
    return _handleApi(
      () async {
        final res = await _apiService.get(endpoint: ApiConstants.notificationEndpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => NotificationModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi lấy danh sách thông báo',
        );
      },
      'Lỗi khi tải danh sách thông báo',
    );
  }

  /// Lấy chi tiết thông báo theo ID
  Future<NotificationModel> getNotificationById({required String id}) async {
    return _handleApi(
      () async {
        final res = await _apiService.get(endpoint: '${ApiConstants.notificationEndpoint}/$id');
        if (res is! Map<String, dynamic>) {
          throw ServerException(
            err: 'Phản hồi không hợp lệ khi lấy chi tiết thông báo',
            type: ServerExceptionType.api,
          );
        }
        return NotificationModel.fromJson(res);
      },
      'Lỗi khi tải chi tiết thông báo',
    );
  }

  /// Thêm thông báo mới
  Future<NotificationModel> createNotification(NotificationModel notification) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.notificationEndpoint,
          body: notification.toJson(),
        );
        if (res is! Map<String, dynamic>) {
          throw ServerException(
            err: 'Phản hồi không hợp lệ khi tạo thông báo mới',
            type: ServerExceptionType.api,
          );
        }
        return NotificationModel.fromJson(res);
      },
      'Lỗi khi tạo thông báo mới',
    );
  }

  /// Cập nhật thông báo theo ID
  Future<NotificationModel> updateNotification({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    return _handleApi(
      () async {
        final res = await _apiService.put(
          endpoint: '${ApiConstants.notificationEndpoint}/$id',
          body: data,
        );
        if (res is! Map<String, dynamic>) {
          throw ServerException(
            err: 'Phản hồi không hợp lệ khi cập nhật thông báo',
            type: ServerExceptionType.api,
          );
        }
        return NotificationModel.fromJson(res);
      },
      'Lỗi khi cập nhật thông báo',
    );
  }

  /// Xóa thông báo theo ID
  Future<void> deleteNotification({required String id}) async {
    return _handleApi(
      () async {
        await _apiService.delete(endpoint: '${ApiConstants.notificationEndpoint}/$id');
      },
      'Lỗi khi xóa thông báo',
    );
  }
}
