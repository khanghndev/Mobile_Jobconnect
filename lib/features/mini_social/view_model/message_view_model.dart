import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:job_connect/appwrite/storage_appwrite_service.dart';
import 'package:job_connect/config/enum/shared_prefs_key.dart';
import 'package:job_connect/config/services/shared_prefs_service.dart';
import 'package:job_connect/features/mini_social/model/message_model.dart';
import 'package:job_connect/features/mini_social/service/message_service.dart';
import 'package:job_connect/features/mini_social/service/chat_hub_service.dart';

class MessageViewModel extends ChangeNotifier {
  final MessageService _messageService = MessageService();
  final SharedPrefsService _prefs;
  final StorageAppwriteService _storageAppwriteService = StorageAppwriteService();
  late final ChatHubService _chatHubService;

  // STATE
  bool _isLoading = false;
  String? _errorMessage;
  int _unreadCount = 0;

  // Lưu messages theo conversationId
  final Map<String, List<MessageModel>> _messagesByConversation = {};

  // Stream subscription cho realtime
  StreamSubscription<Map<String, dynamic>>? _realtimeSub;

  bool _disposed = false;

  // GETTERS
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount => _unreadCount;

  List<MessageModel> getMessages(String conversationId) =>
      _messagesByConversation[conversationId] ?? [];

  MessageViewModel({required SharedPrefsService prefs}) : _prefs = prefs {
    final userId = _prefs.getString(SharedPrefsKey.idUser);
    _chatHubService = ChatHubService(userId: userId!);
    _initSignalR();
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    _chatHubService.disconnect();
    _disposed = true;
    super.dispose();
  }

  // PRIVATE SET STATE
  void _setState({
    bool? isLoading,
    String? errorMessage,
    int? unreadCount,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _errorMessage = errorMessage ?? _errorMessage;
    if (unreadCount != null) _unreadCount = unreadCount;
    if (!_disposed) notifyListeners();
  }

  // PRIVATE API WRAPPER
  Future<void> _handleApiCall<T>({
    required Future<T> Function() apiCall,
    void Function(T)? onSuccess,
  }) async {
    _setState(isLoading: true, errorMessage: null);
    try {
      final result = await apiCall();
      if (onSuccess != null) onSuccess(result);
      _setState(isLoading: false);
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString());
    }
  }

  // ==========================
  // SignalR
  // ==========================
  Future<void> _initSignalR() async {
    try {
      await _chatHubService.initConnection();
      _realtimeSub = _chatHubService.messagesStream.listen((data) {
        final msg = MessageModel.fromMap(data);
        addMessage(msg.idConversation, msg);
      });
    } catch (e) {
      _setState(errorMessage: 'SignalR error: $e');
    }
  }

  Future<void> joinConversation(String conversationId) async {
    await _chatHubService.joinConversation(conversationId);
  }

  Future<void> leaveConversation(String conversationId) async {
    await _chatHubService.leaveConversation(conversationId);
  }

  Future<void> sendMessageViaSignalR({
    required String conversationId,
    required String content,
    String messageType = 'text',
    String? fileUrl,
    String? fileName,
    int? fileSize,
  }) async {
    await _chatHubService.sendMessage(
      conversationId: conversationId,
      content: content,
      messageType: messageType,
      fileUrl: fileUrl,
      fileName: fileName,
      fileSize: fileSize,
    );
  }

  // ==========================
  // Local message management
  // ==========================
  void addMessage(String conversationId, MessageModel msg) {
    final list = _messagesByConversation[conversationId] ?? [];
    if (!list.any((m) => m.idMessage == msg.idMessage)) {
      _messagesByConversation[conversationId] = [...list, msg];
      if (!_disposed) notifyListeners();
    }
  }

  void updateMessage(String conversationId, int index, MessageModel msg) {
    final list = _messagesByConversation[conversationId] ?? [];
    if (index < 0 || index >= list.length) return;
    final newList = [...list];
    newList[index] = msg;
    _messagesByConversation[conversationId] = newList;
    if (!_disposed) notifyListeners();
  }

  void removeMessage(String conversationId, int index) {
    final list = _messagesByConversation[conversationId] ?? [];
    if (index < 0 || index >= list.length) return;
    final newList = [...list]..removeAt(index);
    _messagesByConversation[conversationId] = newList;
    if (!_disposed) notifyListeners();
  }

  void clearMessages(String conversationId) {
    _messagesByConversation.remove(conversationId);
    if (!_disposed) notifyListeners();
  }

  // ==========================
  // API calls
  // ==========================
  Future<void> fetchMessages({
    required String conversationId,
    int limit = 50,
    int offset = 0,
  }) async {
    await _handleApiCall(
      apiCall: () => _messageService.getMessagesByConversationId(
        conversationId: conversationId,
        limit: limit,
        offset: offset,
      ),
      onSuccess: (List<MessageModel> list) {
        _messagesByConversation[conversationId] = list;
        if (!_disposed) notifyListeners();
      },
    );
  }

  Future<void> markMessagesAsRead({
    required String conversationId,
    required String readerId,
  }) async {
    await _handleApiCall(
      apiCall: () => _messageService.markMessagesAsRead(
        conversationId: conversationId,
        readerId: readerId,
      ),
    );
  }

  Future<void> fetchUnreadCount({required String userId}) async {
    await _handleApiCall(
      apiCall: () => _messageService.getUnreadMessageCount(userId: userId),
      onSuccess: (int count) => _setState(unreadCount: count),
    );
  }

  Future<void> createMessage({
    required String idConversation,
    required String idSender,
    required String content,
    required String messageType,
    String? fileUrl,
    String? fileName,
    int? fileSize,
  }) async {
    await _handleApiCall(
      apiCall: () => _messageService.createMessage(
        idConversation: idConversation,
        idSender: idSender,
        content: content,
        messageType: messageType,
        fileUrl: fileUrl,
        fileName: fileName,
        fileSize: fileSize,
      ),
      onSuccess: (msg) => addMessage(idConversation, msg),
    );
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  }) async {
    await _handleApiCall(
      apiCall: () => _messageService.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        content: content,
      ),
      onSuccess: (msg) => addMessage(conversationId, msg),
    );
  }

  Future<String?> uploadFile({
    required File file,
    required String messageType,
  }) async {
    if (file.path.isEmpty) return null;

    final bucketId = messageType == "image"
        ? dotenv.env['APPWRITE_BUCKET_ID_IMAGE'] ?? ''
        : dotenv.env['APPWRITE_BUCKET_ID_RESUME'] ?? '';

    _setState(isLoading: true, errorMessage: null);

    try {
      // Validate extension
      final ext = file.path.split('.').last.toLowerCase();
      final allowedExtensions = messageType == "image"
          ? ['jpg', 'jpeg', 'png']
          : ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'];

      if (!allowedExtensions.contains(ext)) {
        throw Exception('File extension not allowed: .$ext');
      }

      // Upload file
      final uploadedFile = await _storageAppwriteService.uploadFile(
        file,
        bucketId: bucketId,
      );

      final fileUrl = _storageAppwriteService.getFileViewUrl(
        uploadedFile.$id,
        bucketId: bucketId,
      );

      _setState(isLoading: false);
      return fileUrl;
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }
}
