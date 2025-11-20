import 'package:flutter/material.dart';
import 'package:job_connect/features/mini_social/model/conversation_model.dart';
import 'package:job_connect/features/mini_social/service/conversation_service.dart';

class ConversationViewModel extends ChangeNotifier {
  final ConversationService _conversationService = ConversationService();

  // STATE
  bool _isLoading = false;
  String? _errorMessage;
  List<ConversationModel> _conversations = [];

  // GETTERS
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ConversationModel> get conversations => _conversations;

  // PRIVATE SET STATE
  void _setState({
    bool? isLoading,
    String? errorMessage,
    List<ConversationModel>? conversations,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _errorMessage = errorMessage;
    if (conversations != null) _conversations = conversations;
    notifyListeners();
  }

  // PRIVATE WRAPPER API CALL
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

  // FETCH CONVERSATIONS BY USER
  Future<void> fetchConversationsByUser({required String userId}) async {
    await _handleApiCall(
      apiCall: () => _conversationService.getConversationsByUser(userId: userId),
      onSuccess: (List<ConversationModel> list) {
        _setState(conversations: list);
      },
    );
  }

  // CREATE CONVERSATION (nếu chưa tồn tại)
  Future<ConversationModel?> createConversation({required List<String> memberIds}) async {
    // Kiểm tra xem conversation đã tồn tại chưa
    ConversationModel? existing;
    for (var c in _conversations) {
      if (c.members.toSet().containsAll(memberIds) &&
          memberIds.toSet().containsAll(c.members)) {
        existing = c;
        break;
      }
    }

    if (existing != null) return existing;

    ConversationModel? createdConvo;
    await _handleApiCall(
      apiCall: () => _conversationService.createConversation(memberIds: memberIds),
      onSuccess: (ConversationModel convo) {
        // Thêm vào đầu danh sách
        _setState(conversations: [convo, ..._conversations]);
        createdConvo = convo;
      },
    );

    return createdConvo;
  }

  // ADD MEMBER
  Future<void> addMembers({required String conversationId, required String userIds}) async {
    await _handleApiCall(
      apiCall: () => _conversationService.addMembers(conversationId: conversationId, userIds: userIds),
    );
  }

  // REMOVE MEMBER
  Future<void> removeMember({required String conversationId, required String userId}) async {
    await _handleApiCall(
      apiCall: () => _conversationService.removeMember(conversationId: conversationId, userId: userId),
      onSuccess: (_) {
        _setState(conversations: _conversations.where((c) => c.idConversation != conversationId).toList());
      },
    );
  }

  // REMOVE CONVERSATION LOCAL
  void removeConversation(String conversationId) {
    _setState(conversations: _conversations.where((c) => c.idConversation != conversationId).toList());
  }
}
