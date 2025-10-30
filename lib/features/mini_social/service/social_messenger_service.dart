import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/mini_social/model/social_message_model.dart';

class SocialMessengerService {
  final ApiService _apiService;

  SocialMessengerService() : _apiService = ApiService();

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

  //TODO: POST /api/SocialMessages/send - Gửi tin nhắn
  Future<SocialMessageModel> sendMessage({required SocialMessageModel message}) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.socialMessagesSendEndpoint,
          body: message.toJson(),
        );
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => SocialMessageModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi gửi tin nhắn',
        );
      },
      'Lỗi khi gửi tin nhắn',
    );
  }

  //TODO: GET /api/SocialMessages/thread - Lấy luồng tin nhắn giữa 2 người
  Future<List<SocialMessageModel>> getThread({
    required String userId1,
    required String userId2,
  }) async {
    return _handleApi(
      () async {
        final endpoint = '${ApiConstants.socialMessagesThreadEndpoint}?user1=$userId1&user2=$userId2';
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => SocialMessageModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi tải luồng tin nhắn',
        );
      },
      'Lỗi khi tải luồng tin nhắn',
    );
  }

  //TODO: POST /api/SocialMessages/mark-read - Đánh dấu tin nhắn đã đọc
  Future<void> markRead({required SocialMessageModel message}) async {
    return _handleApi(
      () async {
        await _apiService.post(
          endpoint: ApiConstants.socialMessagesMarkReadEndpoint,
          body: message.toJson(),
        );
      },
      'Lỗi khi đánh dấu tin nhắn đã đọc',
    );
  }

  //TODO: GET /api/SocialMessages/unread-count/{userId} - Lấy số lượng tin nhắn chưa đọc
  Future<int> getUnreadCount({required String userId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.socialMessagesUnreadCountEndpoint.replaceFirst('{userId}', userId);
        final res = await _apiService.get(endpoint: endpoint);
        if (res is int) return res;
        if (res is Map<String, dynamic> && res['count'] != null) return res['count'] as int;
        throw ServerException(
          err: 'Phản hồi không hợp lệ khi lấy số tin nhắn chưa đọc',
          type: ServerExceptionType.api,
        );
      },
      'Lỗi khi lấy số tin nhắn chưa đọc',
    );
  }
}