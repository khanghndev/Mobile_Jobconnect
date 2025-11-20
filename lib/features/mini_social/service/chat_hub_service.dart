import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:signalr_netcore/signalr_client.dart';

class ChatHubService {
  late final String hubUrl;
  late HubConnection _hubConnection;

  final StreamController<Map<String, dynamic>> _messageController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get messagesStream => _messageController.stream;

  ChatHubService({required String userId}) {
    final baseUrl = dotenv.env['SIGNALR_HUB_URL'] ?? '';
    if (baseUrl.isEmpty) {
      throw ServerException(
        err: 'SIGNALR_HUB_URL not found in .env',
        type: ServerExceptionType.unknown,
      );
    }

    // Thêm userId vào query string tương ứng với backend
    hubUrl = '$baseUrl?userId=$userId';
  }

  Future<void> initConnection() async {
    return _safeAction(
      action: () async {
        _hubConnection = HubConnectionBuilder().withUrl(hubUrl).build();

        // Lắng nghe ReceiveMessage từ server
        _hubConnection.on('ReceiveMessage', (arguments) {
          if (arguments != null && arguments.isNotEmpty) {
            final msg = arguments[0] as Map<String, dynamic>;
            _messageController.add(msg);
          }
        });

        // Lắng nghe AckMessage để xác nhận message sender
        _hubConnection.on('AckMessage', (arguments) {
          if (arguments != null && arguments.isNotEmpty) {
            final ack = arguments[0] as Map<String, dynamic>;
            _messageController.add(ack);
          }
        });

        await _hubConnection.start();
        print('SignalR Connected! ($hubUrl)');
      },
      errorMsg: 'Failed to connect to SignalR Hub',
    );
  }

  /// Tham gia conversation group
  Future<void> joinConversation(String conversationId) async {
    return _safeAction(
      action: () async {
        if (_hubConnection.state == HubConnectionState.Connected) {
          await _hubConnection.invoke('JoinConversation', args: [conversationId]);
        } else {
          throw ServerException(
            err: 'Hub not connected',
            type: ServerExceptionType.unknown,
          );
        }
      },
      errorMsg: 'Failed to join conversation',
    );
  }

  /// Rời conversation group
  Future<void> leaveConversation(String conversationId) async {
    return _safeAction(
      action: () async {
        if (_hubConnection.state == HubConnectionState.Connected) {
          await _hubConnection.invoke('LeaveConversation', args: [conversationId]);
        } else {
          throw ServerException(
            err: 'Hub not connected',
            type: ServerExceptionType.unknown,
          );
        }
      },
      errorMsg: 'Failed to leave conversation',
    );
  }

  /// Gửi message tương thích backend C# ChatHub
  Future<void> sendMessage({
    required String conversationId,
    required String content,
    String messageType = 'text',
    String? fileUrl,
    String? fileName,
    int? fileSize,
  }) async {
    return _safeAction(
      action: () async {
        if (_hubConnection.state == HubConnectionState.Connected) {
          // args phải đúng thứ tự với backend:
          // SendMessageToConversation(string conversationId, string? content, string messageType = "text", string? fileUrl = null, string? fileName = null, long? fileSize = null)
          await _hubConnection.invoke('SendMessageToConversation', args: [
            conversationId,
            content,
            messageType,
            fileUrl ?? '',
            fileName ?? '',
            fileSize ?? 0,
          ]);
        } else {
          throw ServerException(
            err: 'Hub not connected',
            type: ServerExceptionType.unknown,
          );
        }
      },
      errorMsg: 'Failed to send message',
    );
  }

  /// Ngắt kết nối
  Future<void> disconnect() async {
    return _safeAction(
      action: () async {
        await _hubConnection.stop();
        await _messageController.close();
      },
      errorMsg: 'Failed to disconnect SignalR Hub',
    );
  }

  /// Wrapper try-catch
  Future<T> _safeAction<T>({
    required Future<T> Function() action,
    required String errorMsg,
  }) async {
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
}
