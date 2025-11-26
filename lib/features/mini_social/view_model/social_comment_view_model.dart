import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:job_connect/appwrite/storage_appwrite_service.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/features/mini_social/model/social_comment_model.dart';
import 'package:job_connect/features/mini_social/service/social_comment_service.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';

class SocialCommentViewModel extends ChangeNotifier {
  final SocialCommentService _commentService = SocialCommentService();
  final StorageAppwriteService _storageAppwriteService = StorageAppwriteService();

  // STATE
  bool _isLoading = false;
  String? _errorMessage;
  List<SocialCommentModel> _comments = [];
  final Map<String, UserModel> userCache = {}; // Cache user info

  // GETTERS
  List<SocialCommentModel> get comments => _comments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String resolveUsername(String id) => userCache[id]?.userName ?? "Người dùng $id";
  String resolveUserAvatar(String id) => userCache[id]?.avatarUrl ?? AppImages.defaultAvatar;

  // PRIVATE SET STATE
  void _setState({
    bool? isLoading,
    String? errorMessage,
    List<SocialCommentModel>? comments,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _errorMessage = errorMessage;
    _comments = comments ?? _comments;
    notifyListeners();
  }

  // API HANDLER
  Future<void> _handleApiCall<T>({
    required Future<T> Function() apiCall,
    void Function(T)? onSuccess,
  }) async {
    _setState(isLoading: true, errorMessage: null);
    try {
      final result = await apiCall();
      if (onSuccess != null) onSuccess(result);
      _setState(isLoading: false);
    } on ServerException catch (e) {
      _setState(isLoading: false, errorMessage: e.err);
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString());
    }
  }

  // GET COMMENTS BY POST
  Future<void> getCommentsByPost({required String postId}) async {
    await _handleApiCall<List<SocialCommentModel>>(
      apiCall: () => _commentService.getCommentsByPost(postId: postId),
      onSuccess: (data) {
        data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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

  // UPLOAD IMAGE
  Future<String?> uploadImage(String imagePath) async {
    try {
      final bucketId = dotenv.env['APPWRITE_BUCKET_ID_IMAGE'] ?? '';
      if (bucketId.isEmpty) {
        throw Exception('APPWRITE_BUCKET_ID_IMAGE chưa cấu hình');
      }
      
      final file = File(imagePath);
      final uploadedFile = await _storageAppwriteService.uploadFile(file, bucketId: bucketId);
      return _storageAppwriteService.getFileViewUrl(uploadedFile.$id, bucketId: bucketId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // CREATE COMMENT
  Future<void> createComment({
    required SocialCommentModel newComment,
    UserViewModel? userVm,
    String? imagePath,
    String? icon,
  }) async {
    // Không set isLoading để tránh hiển thị loading state khi tạo comment
    // Comment sẽ được thêm vào danh sách ngay lập tức
    try {
      String? imageUrl;
      
      // Upload ảnh nếu có
      if (imagePath != null && imagePath.isNotEmpty) {
        imageUrl = await uploadImage(imagePath);
      }
      
      // Tạo comment với imageUrl và icon
      final commentToCreate = newComment.copyWith(
        imageUrl: imageUrl,
        icon: icon,
      );
      
      final created = await _commentService.createComment(comment: commentToCreate);
      _comments.insert(0, created); // thêm vào đầu danh sách
      
      // Load user info cho comment mới nếu chưa có trong cache
      if (userVm != null && !userCache.containsKey(created.idUser)) {
        // Nếu là current user, sử dụng currentUser luôn
        if (userVm.currentUser?.idUser == created.idUser && userVm.currentUser != null) {
          userCache[created.idUser] = userVm.currentUser!;
          notifyListeners(); // Rebuild UI với user info mới
        } else {
          // Nếu không phải current user, load từ API (async, không block UI)
          _loadUserInfoForComment(created.idUser, userVm);
        }
      } else {
        // Nếu đã có user info, chỉ cần notify để rebuild UI
        notifyListeners();
      }
    } catch (e) {
      // Nếu lỗi, vẫn giữ nguyên danh sách comments hiện tại
      // Có thể show snackbar hoặc dialog để thông báo lỗi nếu cần
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Helper method để load user info cho comment
  Future<void> _loadUserInfoForComment(String userId, UserViewModel userVm) async {
    try {
      final user = await userVm.getViewUser(userId);
      if (user != null) {
        userCache[userId] = user;
        notifyListeners(); // Rebuild UI với user info mới
      }
    } catch (e) {
      // Bỏ qua lỗi, sẽ hiển thị "Người dùng $id" nếu không load được
    }
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
      errorMessage: null,
      comments: [],
    );
    userCache.clear();
  }

  /// Load comments và cache user info, UI sẽ rebuild dần
  Future<void> loadCommentsWithUsers({required String postId, required UserViewModel userVm}) async {
    _setState(isLoading: true);

    try {
      final data = await _commentService.getCommentsByPost(postId: postId);
      data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _comments = data;
      notifyListeners(); // rebuild ngay với danh sách comment

      // Load user info từng comment
      for (var comment in _comments) {
        if (!userCache.containsKey(comment.idUser)) {
          await userVm.getViewUser(comment.idUser);
          if (userVm.viewedUser != null) {
            userCache[comment.idUser] = userVm.viewedUser!;
            notifyListeners(); // rebuild mỗi khi có user info mới
          }
        }
      }
    } catch (e) {
      _setState(errorMessage: e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}