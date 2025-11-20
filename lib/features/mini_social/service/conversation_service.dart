import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/mini_social/model/conversation_model.dart';
import 'package:job_connect/features/mini_social/model/message_model.dart';

class ConversationService {
  final ApiService _apiService;

  ConversationService() : _apiService = ApiService();

  // TODO: m tiện ích để wrap lỗi chung
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

  // TODO: Tạo cuộc trò chuyện mới
  Future<ConversationModel> createConversation({required List<String> memberIds}) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.createConversationEndpoint,
          body: {
            'memberIds': memberIds,
          },
        );
        return ConversationModel.fromJson(res);
      },
      'Lỗi khi tạo cuộc trò chuyện',
    );
  }

  // TODO: Thêm thành viên vào cuộc trò chuyện
  Future<void> addMembers({ required String conversationId, required String userIds}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.addMemberToConversationEndpoint
            .replaceAll('{conversationId}', conversationId);
        await _apiService.post(
          endpoint: endpoint,
          body: {'userIds': userIds},
        );
      },
      'Lỗi khi thêm thành viên vào cuộc trò chuyện',
    );
  }

  // TODO: Xóa thành viên khỏi cuộc trò chuyện
  Future<void> removeMember({required String conversationId, required String userId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.removeMemberFromConversationEndpoint
            .replaceAll('{conversationId}', conversationId)
            .replaceAll('{userId}', userId);
        await _apiService.delete(endpoint: endpoint);
      },
      'Lỗi khi xóa thành viên khỏi cuộc trò chuyện',
    );
  }

  // TODO: Lấy danh sách cuộc trò chuyện theo userId
  Future<List<ConversationModel>> getConversationsByUser({ required String userId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.getConversationsByUserEndpoint
            .replaceAll('{userId}', userId);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => ConversationModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (getConversationsByUser)',
        );
      },
      'Lỗi khi tải danh sách cuộc trò chuyện',
    );
  }

  // TODO: Lấy danh sách tin nhắn trong một cuộc trò chuyện
  Future<List<MessageModel>> getConversationMessages({ required String conversationId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.getConversationMessagesEndpoint.replaceAll('{conversationId}', conversationId);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => MessageModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (getConversationMessages)',
        );
      },
      'Lỗi khi tải danh sách tin nhắn trong cuộc trò chuyện',
    );
  }
}
