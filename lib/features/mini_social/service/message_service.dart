import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/mini_social/model/message_model.dart';

class MessageService {
  final ApiService _apiService;

  MessageService() : _apiService = ApiService();

  //   Hàm tiện ích để wrap lỗi chung
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

  //  Tạo tin nhắn mới 
  Future<MessageModel> createMessage({
    required String idConversation,
    required String idSender,
    required String content,
    required String messageType,
    String? fileUrl,
    String? fileName,
    int? fileSize,
  }) async {
    return _handleApi(
      () async {
        final body = {
          "idConversation": idConversation,
          "idSender": idSender,
          "content": content,
          "messageType": messageType,
          "fileUrl": fileUrl,
          "fileName": fileName,
          "fileSize": fileSize ?? 0,
        };

        final res = await _apiService.post(
          endpoint: ApiConstants.createMessageEndpoint,
          body: body,
        );

        return MessageModel.fromJson(res);
      },
      'Lỗi khi tạo tin nhắn mới',
    );
  }

 //  Gửi tin nhắn 
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  }) async {
    return _handleApi(
      () async {
        final body = {
          "conversationId": conversationId,
          "senderId": senderId,
          "content": content,
        };

        final res = await _apiService.post(
          endpoint: ApiConstants.sendMessageEndpoint,
          body: body,
        );

        return MessageModel.fromJson(res);
      },
      'Lỗi khi gửi tin nhắn',
    );
  }

 //  Lấy danh sách tin nhắn theo conversationId, có hỗ trợ limit & offset
  Future<List<MessageModel>> getMessagesByConversationId({
    required String conversationId,
    int limit = 50,
    int offset = 0,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.getMessagesByConversationIdEndpoint.replaceAll('{conversationId}', conversationId);

        final queryParams = {
          'limit': limit.toString(),
          'offset': offset.toString(),
        };

        final res = await _apiService.get(
          endpoint: endpoint,
          queryParams: queryParams,
        );

        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => MessageModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (getMessagesByConversationId)',
        );
      },
      'Lỗi khi tải danh sách tin nhắn',
    );
  }

  //  Đánh dấu tin nhắn trong cuộc trò chuyện là đã đọc
  Future<void> markMessagesAsRead({
    required String conversationId,
    required String readerId,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.markMessagesAsReadEndpoint
            .replaceAll('{conversationId}', conversationId);

        // Gửi query parameter readerId
        await _apiService.post(
          endpoint: endpoint,
          queryParams: {
            'readerId': readerId,
          },
        );
      },
      'Lỗi khi đánh dấu tin nhắn đã đọc',
    );
  }

  //   Lấy tổng số tin nhắn chưa đọc của user
  Future<int> getUnreadMessageCount({ required String userId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.getUnreadMessageCountEndpoint.replaceAll('{userId}', userId);
        final res = await _apiService.get(endpoint: endpoint);

        if (res is Map<String, dynamic> && res.containsKey('count')) {
          return res['count'] ?? 0;
        } else if (res is int) {
          return res;
        } else {
          throw ServerException(
            err: 'Phản hồi không hợp lệ từ API (getUnreadMessageCount)',
            type: ServerExceptionType.unknown,
          );
        }
      },
      'Lỗi khi lấy số lượng tin nhắn chưa đọc',
    );
  }
}