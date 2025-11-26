import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:job_connect/appwrite/storage_appwrite_service.dart';
import 'package:job_connect/config/enum/shared_prefs_key.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/shared_prefs_service.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';
import 'package:job_connect/features/mini_social/service/social_post_service.dart';
import 'package:job_connect/features/mini_social/service/social_save_post_service.dart';
import 'package:job_connect/features/profile/service/user_service.dart';

class SocialPostViewModel extends ChangeNotifier {
  final SocialPostService _socialPostService = SocialPostService();
  final UserService _userService = UserService();
  final SocialSavePostService _savePostService = SocialSavePostService();
  final StorageAppwriteService _storageAppwriteService = StorageAppwriteService();
  final SharedPrefsService _prefs;

  SocialPostViewModel({required SharedPrefsService prefs}) : _prefs = prefs;

  //  STATE
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  int _totalLikes = 0;
  int _totalShared = 0;
  int _totalFollows = 0;
  
  List<SocialPostModel> _posts = [];
  List<SocialPostModel> _postsOfGroup = [];

  final Set<String> _selectedPosts = {};
  bool _selectMode = false;


  //  LIKE STATE
  final Set<String> _likedPosts = {};
  final Set<String> _savedPosts = {};
  
  // Cache để tránh gọi API nhiều lần
  final Map<String, String> _userRoleCache = {};
  final Map<String, List<String>> _postLikesCache = {};

  //  GETTERS
  String get currentUserId => _prefs.getString(SharedPrefsKey.idUser) ?? '';

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  List<SocialPostModel> get posts => _posts.where((p) => p.visibility == 'public').toList();
  List<SocialPostModel> get postsOfGroup => _postsOfGroup.where((p) => p.visibility == 'public').toList();
  Set<String> get selectedPosts => _selectedPosts;
  bool get selectMode => _selectMode;
  bool isPostLiked(String postId) => _likedPosts.contains(postId);
  bool isPostSaved(String postId) => _savedPosts.contains(postId);
  int get totalLikes => _totalLikes;
  int get totalShared => _totalShared;
  int get totalFollows => _totalFollows;

  //  PRIVATE SET STATE
  void _setState({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<SocialPostModel>? posts,
    List<SocialPostModel>? postsOfGroup,
    bool? selectMode,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _errorMessage = errorMessage;
    _posts = posts ?? _posts;
    _postsOfGroup = postsOfGroup ?? _postsOfGroup;
    _selectMode = selectMode ?? _selectMode;
    notifyListeners();
  }

  //  HELPER API CALL
  Future<void> _handleApiCall<T>({
    required Future<T> Function() apiCall,
    void Function(T)? onSuccess,
  }) async {
    _setState(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      final result = await apiCall();
      if (onSuccess != null) onSuccess(result);
      _setState(isSuccess: true);
    } on ServerException catch (e) {
      _setState(errorMessage: e.err, isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } finally {
      _setState(isLoading: false);
    }
  }

  int getPostCountByUser(String userId) {
    return _posts.where((p) => p.idUser == userId && p.visibility == 'public').length;
  }

  void _calculateTotalLikes() {
    _totalLikes = 0;
    for (var post in _posts) {
      _totalLikes += post.likesCount;
    }
    notifyListeners();
  }

  void _calculateTotalShared() {
    _totalShared = 0;
    for (var post in _posts) {
      if (post.isSaved) {
        _totalShared += 1;
      }
    }
    notifyListeners();
  }

  // THÊM HÀM TÍNH TỔNG FOLLOWS
  Future<void> _calculateTotalFollows(String userId) async {
    // try {
    //   final user = await _userService.getUserById(id: userId);
    //   _totalFollows = user.followers?.length ?? 0;
    //   notifyListeners();
    // } catch (e) {
    //   print('Error fetching followers: $e');
    //   _totalFollows = 0;
    // }
  }

  //  TOGGLE LIKE
  Future<void> onToggleLike(String postId) async {
    final isLiked = _likedPosts.contains(postId);
    
    // 1. Cập nhật local ngay
    final index = _posts.indexWhere((p) => p.idPost == postId);
    if (index != -1) {
      final post = _posts[index];
      final likesCount = isLiked ? post.likesCount - 1 : post.likesCount + 1;
      _posts[index] = post.copyWith(likesCount: likesCount);
      if (isLiked) {
        _likedPosts.remove(postId);
      } else {
        _likedPosts.add(postId);
      }
      _calculateTotalLikes();
      notifyListeners();
    }

    // 2. Gọi API không ảnh hưởng UI
    try {
      if (isLiked) {
        await _socialPostService.unlikePost(id: postId, userId: currentUserId);
      } else {
        await _socialPostService.likePost(id: postId, userId: currentUserId);
      }
    } catch (e) {
      // Rollback nếu thất bại
      if (index != -1) {
        final post = _posts[index];
        final likesCount = isLiked ? post.likesCount + 1 : post.likesCount - 1;
        _posts[index] = post.copyWith(likesCount: likesCount);
        if (isLiked) {
          _likedPosts.add(postId);
        } else {
          _likedPosts.remove(postId);
        }
        _calculateTotalLikes();
        notifyListeners();
      }
    }
  }

  //  TOGGLE SAVE
  Future<void> onToggleSave(String postId) async {
    final isSaved = _savedPosts.contains(postId);

    await _handleApiCall<void>(
      apiCall: () => isSaved
          ? _socialPostService.unsavePost(id: postId, userId: currentUserId)
          : _socialPostService.savePost(id: postId, userId: currentUserId),
      onSuccess: (_) {
        final index = _posts.indexWhere((p) => p.idPost == postId);
        if (index != -1) {
          final post = _posts[index];
          _posts[index] = post.copyWith(isSaved: !isSaved);
        }

        if (isSaved) {
          _savedPosts.remove(postId);
        } else {
          _savedPosts.add(postId);
        }

        // CẬP NHẬT TỔNG SAVES
        _calculateTotalShared();
        notifyListeners();
      },
    );
  }

  void updateLocalSavedState(String idPost, bool isSaved) {
    final index = _posts.indexWhere((p) => p.idPost == idPost);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(isSaved: isSaved);
      notifyListeners();
    }
  }

  void incrementCommentCount(String idPost) {
    final index = _posts.indexWhere((p) => p.idPost == idPost);
    if (index != -1) {
      final currentCount = _posts[index].commentsCount;
      _posts[index] = _posts[index].copyWith(commentsCount: currentCount + 1);
      notifyListeners();
    }
  }

  void incrementShareCount(String idPost) {
    final index = _posts.indexWhere((p) => p.idPost == idPost);
    if (index != -1) {
      final currentCount = _posts[index].sharesCount;
      _posts[index] = _posts[index].copyWith(sharesCount: currentCount + 1);
      notifyListeners();
    }
  }

  Future<List<String>> uploadImages(List<String> imagePaths) async {
    if (imagePaths.isEmpty) return [];
    final bucketId = dotenv.env['APPWRITE_BUCKET_ID_IMAGE'] ?? '';
    _setState(isLoading: true, errorMessage: null);
    try {
      final urls = await Future.wait(
        imagePaths.map((path) async {
          final file = File(path);
          final uploadedFile = await _storageAppwriteService.uploadFile(file, bucketId: bucketId);
          return _storageAppwriteService.getFileViewUrl(uploadedFile.$id, bucketId: bucketId);
        }),
      );
      _setState(isLoading: false);
      return urls;
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  /// Xóa nhiều ảnh trên Appwrite dựa trên list URL trả về từ getFileViewUrl(...)
  Future<List<String>> deleteImagesByUrls(List<String> imageUrls) async {
    if (imageUrls.isEmpty) return [];

    final bucketId = dotenv.env['APPWRITE_BUCKET_ID_IMAGE'] ?? '';
    if (bucketId.isEmpty) {
      final err = 'APPWRITE_BUCKET_ID_IMAGE chưa cấu hình';
      _setState(isLoading: false, errorMessage: err);
      throw Exception(err);
    }
    _setState(isLoading: true, errorMessage: null);
    String? extractFileId(String url) {
      try {
        final uri = Uri.parse(url);
        final segments = uri.pathSegments;
        final filesIndex = segments.indexOf('files');
        if (filesIndex != -1 && filesIndex + 1 < segments.length) {
          return segments[filesIndex + 1];
        }
        // fallback: try regex
        final match = RegExp(r'/files/([^/]+)/view').firstMatch(url);
        if (match != null && match.groupCount >= 1) return match.group(1);
      } catch (_) {}
      return null;
    }

    try {
      final fileIds = imageUrls.map((u) => extractFileId(u)).where((id) => id != null).cast<String>().toList();
      if (fileIds.isEmpty) {
        _setState(isLoading: false);
        return [];
      }

      final results = await Future.wait(fileIds.map((fileId) async {
        try {
          await _storageAppwriteService.deleteFile(fileId, bucketId: bucketId);
          return fileId; 
        } catch (e) {
          return null;
        }
      }));

      final deleted = results.where((r) => r != null).cast<String>().toList();

      _setState(isLoading: false);
      return deleted;
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<String> _getUserRole(String userId) async {
    // Sử dụng cache nếu đã có
    if (_userRoleCache.containsKey(userId)) {
      return _userRoleCache[userId]!;
    }
    final user = await _userService.getUserById(id: userId);
    final roleName = user.role?.roleName ?? UserRole.candidate.name;
    _userRoleCache[userId] = roleName;
    return roleName;
  }
  
  // Batch get user roles để giảm số lượng API calls
  Future<Map<String, String>> _getUserRolesBatch(List<String> userIds) async {
    final Map<String, String> roles = {};
    final List<String> uncachedIds = userIds.where((id) => !_userRoleCache.containsKey(id)).toList();
    
    // Lấy từ cache trước
    for (final id in userIds) {
      if (_userRoleCache.containsKey(id)) {
        roles[id] = _userRoleCache[id]!;
      }
    }
    
    // Batch load các user chưa có trong cache
    if (uncachedIds.isNotEmpty) {
      await Future.wait(uncachedIds.map((userId) async {
        try {
          final role = await _getUserRole(userId);
          roles[userId] = role;
        } catch (e) {
          roles[userId] = UserRole.candidate.name;
        }
      }));
    }
    
    return roles;
  }

  Future<void> getAllPosts() async {
    await _handleApiCall<List<SocialPostModel>>(
      apiCall: () async {
        final posts = await _socialPostService.getAllPosts();
        try {
          final saved = await _savePostService.getSavedPostsByUser(currentUserId);
          final savedIds = saved.map((s) => s.idPost).toSet();
          final merged = posts
            .map((p) => p.copyWith(isSaved: savedIds.contains(p.idPost)))
            .toList();
          return merged;
        } catch (e) {
          return posts;
        }
      },
      onSuccess: (data) async {
        data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _posts = data;
        
        // Batch load likes thay vì gọi từng cái một
        final postIds = _posts.map((p) => p.idPost).toList();
        await Future.wait(postIds.map((postId) async {
          try {
            // Kiểm tra cache trước
            if (_postLikesCache.containsKey(postId)) {
              final likes = _postLikesCache[postId]!;
              if (likes.contains(currentUserId)) {
                _likedPosts.add(postId);
              }
            } else {
              final likes = await _socialPostService.getPostLikes(id: postId);
              _postLikesCache[postId] = likes;
              if (likes.contains(currentUserId)) {
                _likedPosts.add(postId);
              }
            }
          } catch (e) {
            // Bỏ qua lỗi, tiếp tục với post khác
          }
        }));
      },
    );
  }

  /// Lấy danh sách bài viết của nhóm hiện tại theo tên groupName
   List<SocialPostModel> getPostsOfCurrentGroupByName(String groupName) {
    if (groupName.isEmpty) return [];
    return _posts.where((post) => post.groupName == groupName && post.visibility == 'public').toList();
  }

   Future<void> getAllPostsOfGroup({required String groupId, required String currentUserId}) async {
    await _handleApiCall<List<SocialPostModel>>(
      apiCall: () => _socialPostService.getAllPostsOfGroup(
        groupId: groupId,
        currentUserId: currentUserId,
      ),
      onSuccess: (data) async {
        data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _postsOfGroup = data;

        //  Lấy danh sách user đã like từng post
        for (var postOfGroup in _postsOfGroup) {
          final likes = await _socialPostService.getPostLikes(id: postOfGroup.idPost);
          if (likes.contains(currentUserId)) {
            _likedPosts.add(postOfGroup.idPost);
          }
        }
      },
    );
  }
  
  Future<void> getPostsByRole({required String roleName}) async {
    _setState(isLoading: true, errorMessage: null);

    await _handleApiCall<List<SocialPostModel>>(
      apiCall: () async {
        final posts = await _socialPostService.getAllPosts();
        
        // Load saved posts để merge trạng thái isSaved
        try {
          final saved = await _savePostService.getSavedPostsByUser(currentUserId);
          final savedIds = saved.map((s) => s.idPost).toSet();
          return posts
              .map((p) => p.copyWith(isSaved: savedIds.contains(p.idPost)))
              .toList();
        } catch (e) {
          // Nếu lỗi khi load saved posts, vẫn trả về posts bình thường
          return posts;
        }
      },
      onSuccess: (data) async {
        data.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Lấy tất cả unique user IDs
        final userIds = data.map((p) => p.idUser).toSet().toList();
        
        // Batch load user roles một lần thay vì từng cái
        final userRoles = await _getUserRolesBatch(userIds);
        
        // Filter posts dựa trên role đã cache
        final List<SocialPostModel> filteredPosts = data.where((post) {
          final userRole = userRoles[post.idUser] ?? UserRole.candidate.name;
          return userRole == roleName;
        }).toList();
        
        // Load likes cho các posts đã filter (batch)
        final postIds = filteredPosts.map((p) => p.idPost).toList();
        await Future.wait(postIds.map((postId) async {
          try {
            if (!_postLikesCache.containsKey(postId)) {
              final likes = await _socialPostService.getPostLikes(id: postId);
              _postLikesCache[postId] = likes;
            }
            final likes = _postLikesCache[postId]!;
            if (likes.contains(currentUserId)) {
              _likedPosts.add(postId);
            }
          } catch (e) {
            // Bỏ qua lỗi
          }
        }));
        
        _setState(isLoading: false, isSuccess: true, posts: filteredPosts);
      },
    );
  }

  void updatePostSavedStatus(String postId, bool isSaved) {
    final index = _posts.indexWhere((p) => p.idPost == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(isSaved: isSaved);
      notifyListeners();
    }
  }

  //  CREATE, UPDATE, DELETE POST
  Future<void> createPost(SocialPostModel postModel) async {
    await _handleApiCall<SocialPostModel>(
      apiCall: () => _socialPostService.createPost(postModel),
      onSuccess: (newPost) {
        _posts.insert(0, newPost);
        notifyListeners();
      },
    );
  }

  Future<void> updatePost(SocialPostModel post) async {
    await _handleApiCall<void>(
      apiCall: () => _socialPostService.updatePost(id: post.idPost, post: post),
      onSuccess: (_) {
        final index = _posts.indexWhere((p) => p.idPost == post.idPost);
        if (index != -1) {
          _posts[index] = post;
        } else {
          _posts.insert(0, post);
        }
      },
    );
  }

  Future<void> deletePost(String postId) async {
    await _handleApiCall<void>(
      apiCall: () async {
        await _socialPostService.deletePost(id: postId);
        _posts.removeWhere((p) => p.idPost == postId);
        _selectedPosts.remove(postId);
        if (_selectedPosts.isEmpty) _selectMode = false;
      },
    );
  }

  //  FOLLOW / SAVE / SHARE
  Future<void> onToggleFollow(String userId, bool isFollowing) async {
    await _handleApiCall<void>(
      apiCall: () => isFollowing
          ? _socialPostService.unfollowUser(userId: userId)
          : _socialPostService.followUser(userId: userId),
    );
  }

  Future<void> onSharePost(String postId) async {
    // await _handleApiCall<void>(
    //   apiCall: () => _socialPostService.sharePost(id: postId),
    // );
  }

  Future<void> onCommentPost(String postId) async {
    // await _handleApiCall<void>(
    //   apiCall: () => _socialPostService.sharePost(id: postId),
    // );
  }
  

  //  HIDE POST
  Future<void> onHidePost(String postId) async {
    await _handleApiCall<void>(
      apiCall: () async {
        final index = _posts.indexWhere((p) => p.idPost == postId);
        if (index == -1) return;
        // Đổi visibility thành 'private' để ẩn bài viết
        final post = _posts[index].copyWith(visibility: 'private');
        _posts[index] = post;
        await _socialPostService.updatePost(id: postId, post: post);
        notifyListeners(); // Cập nhật UI
      },
    );
  }

  //  GET POSTS BY USER
  Future<void> getPostsByUserId(String userId) async {
    await _handleApiCall<List<SocialPostModel>>(
      apiCall: () => _socialPostService.getFeedUserId(userId: userId),
      onSuccess: (data) {
        // Filter chỉ lấy bài viết của userId này
        final filteredPosts = data.where((post) => post.idUser == userId).toList();
        filteredPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _posts = filteredPosts;
      },
    );
  }

  //  GET POST LIKES
  Future<List<String>> getPostLikes(String postId) async {
    List<String> likes = [];
    await _handleApiCall<List<String>>(
      apiCall: () => _socialPostService.getPostLikes(id: postId),
      onSuccess: (data) {
        likes = data;
      },
    );
    return likes;
  }

  //  MULTI SELECT
  void onToggleSelectMode() {
    _selectMode = !_selectMode;
    if (!_selectMode) _selectedPosts.clear();
    notifyListeners();
  }

  void onToggleSelect(String postId) {
    if (_selectedPosts.contains(postId)) {
      _selectedPosts.remove(postId);
    } else {
      _selectedPosts.add(postId);
    }
    notifyListeners();
  }

  //  RESET
  void onResetState() {
    _setState(
      isLoading: false,
      isSuccess: false,
      errorMessage: null,
      posts: [],
      selectMode: false,
    );
    _selectedPosts.clear();
    _likedPosts.clear();
  }

  //  REFRESH
  Future<void> refreshPosts({required String roleName}) async {
    await getPostsByRole(roleName: roleName);
  }

  void clearPosts() {
    _posts.clear();
    _postsOfGroup.clear();
    _selectedPosts.clear();
    _likedPosts.clear();
    _savedPosts.clear();
    _selectMode = false;
    _totalLikes = 0;
    _totalShared = 0;
    _totalFollows = 0;
    _isLoading = false;
    _isSuccess = false;
    _errorMessage = null;
    notifyListeners();
  }
}