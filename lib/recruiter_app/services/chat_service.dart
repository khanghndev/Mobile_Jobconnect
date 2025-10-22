// lib/core/services/chat_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:job_connect/config/constant/api_constants.dart';
import '../../data/models/message_model.dart';

class ChatService {
  final http.Client _client;

  ChatService([http.Client? client]) : _client = client ?? http.Client();


  ///    GET /api/chat/threads/{threadId}/messages
  Future<List<MessageModel>> fetchMessages(String threadId) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.chatMessagesEndpoint}/$threadId/messages',
    );
    final resp = await _client.get(uri, headers: {
      'Content-Type': 'application/json',
    });
    if (resp.statusCode != 200) {
      throw Exception('Không tải được messages: ${resp.statusCode}');
    }
    final List<dynamic> data = jsonDecode(resp.body);
    return data.map((e) => MessageModel.fromJson(e)).toList();
  }

  /// 6) Gửi tin nhắn vào thread
  ///    POST /api/chat/threads/{threadId}/messages
  Future<MessageModel> sendMessage({
    required String threadId,
    required String senderId,
    required String content,
    required bool isRead,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.chatMessagesEndpoint}/$threadId/messages',
    );
    final body = jsonEncode({
      'idSender': senderId,
      'content': content,
      'isRead': isRead,
    });
    final resp = await _client.post(uri, headers: {
      'Content-Type': 'application/json',
    }, body: body);
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw Exception('Gửi message thất bại: ${resp.statusCode}');
    }
    return MessageModel.fromJson(jsonDecode(resp.body));
  }

  /// 7) Đánh dấu message đã đọc
  ///    PUT /api/chat/threads/{threadId}/messages/{messageId}/read
  Future<void> markAsRead({
    required String threadId,
    required String messageId,
  }) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.chatMessagesEndpoint}/'
      '$threadId/messages/$messageId/read',
    );
    final resp = await _client.put(uri, headers: {
      'Content-Type': 'application/json',
    });
    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception('Đánh dấu đã đọc thất bại: ${resp.statusCode}');
    }
  }
}
