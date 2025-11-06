import 'package:flutter/material.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/features/mini_social/model/social_comment_model.dart';
import 'package:job_connect/features/mini_social/service/social_comment_service.dart';

class SocialCommentViewModel extends ChangeNotifier {
  final SocialCommentService _commentService = SocialCommentService();

  // STATE
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  List<SocialCommentModel> _comments = [];

  // GETTERS
  List<SocialCommentModel> get comments => _comments;
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;

  // PRIVATE SET STATE
  void _setState({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<SocialCommentModel>? comments,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _errorMessage = errorMessage;
    _comments = comments ?? _comments;
    notifyListeners();
  }

  // API HANDLER (giữ nguyên logic của bạn)

  Future<void> _handleApiCall<T>({
    required Future<T> Function() apiCall,
    void Function(T)? onSuccess,
  }) async {
    _setState(isLoading: true, isSuccess: false, errorMessage: null);
    try {
      final result = await apiCall();
      if (onSuccess != null) onSuccess(result);
      _setState(isSuccess: true);
    } on ServerException catch (e) {
      _setState(errorMessage: e.err, isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    }  
  }

  // GET COMMENTS BY POST
  Future<void> getCommentsByPost({required String postId}) async {
    await _handleApiCall<List<SocialCommentModel>>(
      apiCall: () => _commentService.getCommentsByPost(postId: postId),
      onSuccess: (data) {
        data.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // mới nhất trước
        _comments = data;
      },
    );
  }

  // GET REPLIES BY PARENT
  Future<void> getRepliesByParent({required String parentId}) async {
    await _handleApiCall<List<SocialCommentModel>>(
      apiCall: () => _commentService.getRepliesByParent(parentId: parentId),
      onSuccess: (data) {
        _comments = data;
      },
    );
  }

  // CREATE COMMENT
  Future<void> createComment({required SocialCommentModel newComment}) async {
    await _handleApiCall<SocialCommentModel>(
      apiCall: () => _commentService.createComment(comment: newComment),
      onSuccess: (created) {
        _comments.insert(0, created); // thêm vào đầu danh sách
      },
    );
  }

  // DELETE COMMENT
  Future<void> deleteComment({required String id}) async {
    await _handleApiCall<void>(
      apiCall: () => _commentService.deleteComment(id: id),
      onSuccess: (_) {
        _comments.removeWhere((c) => c.idComment == id);
      },
    );
  }

  // REFRESH COMMENTS
  Future<void> refreshComments({required String postId}) async {
    await getCommentsByPost(postId: postId);
  }

  // RESET STATE
  void resetState() {
    _setState(
      isLoading: false,
      isSuccess: false,
      errorMessage: null,
      comments: [],
    );
  }
}
