import 'package:flutter/material.dart';
import 'package:job_connect/config/enum/shared_prefs_key.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/shared_prefs_service.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';
import 'package:job_connect/features/mini_social/service/social_post_service.dart';
import 'package:job_connect/features/profile/service/user_service.dart';

class SocialPostViewModel extends ChangeNotifier {
  final SocialPostService _socialPostService = SocialPostService();
  final UserService _userService = UserService();
  final SharedPrefsService _prefs;

  SocialPostViewModel({required SharedPrefsService prefs}) : _prefs = prefs;

  //TODO: STATE
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  List<SocialPostModel> _posts = [];
  final Set<String> _selectedPosts = {};
  bool _selectMode = false;


  //TODO: LIKE STATE
  final Set<String> _likedPosts = {}; //TODO: postId mà user đã like
  final Set<String> _savedPosts = {}; //TODO: postId mà user đã like

  //TODO: GETTERS
  String get currentUserId => _prefs.getString(SharedPrefsKey.idUser) ?? '';

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  List<SocialPostModel> get posts => _posts.where((p) => p.visibility != 'hidden').toList();
  Set<String> get selectedPosts => _selectedPosts;
  bool get selectMode => _selectMode;
  bool isPostLiked(String postId) => _likedPosts.contains(postId);
  bool isPostSaved(String postId) => _savedPosts.contains(postId);

  //TODO: PRIVATE SET STATE
  void _setState({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<SocialPostModel>? posts,
    bool? selectMode,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _errorMessage = errorMessage;
    _posts = posts ?? _posts;
    _selectMode = selectMode ?? _selectMode;
    notifyListeners();
  }

  //TODO: HELPER API CALL
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

  Future<String> _getUserRole(String userId) async {
    final user = await _userService.getUserById(id: userId);
    return user.role?.roleName ?? UserRole.candidate.name;
  }

  Future<void> getAllPosts() async {
    await _handleApiCall<List<SocialPostModel>>(
      apiCall: () => _socialPostService.getAllPosts(),
      onSuccess: (data) async {
        data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _posts = data;

        //TODO: Lấy danh sách user đã like từng post
        for (var post in _posts) {
          final likes = await _socialPostService.getPostLikes(id: post.idPost);
          if (likes.contains(currentUserId)) {
            _likedPosts.add(post.idPost);
          }
        }
      },
    );
  }
  
  Future<void> getPostsByRole({required String roleName}) async {
    _setState(isLoading: true, errorMessage: null);

    await _handleApiCall<List<SocialPostModel>>(
      apiCall: () => _socialPostService.getAllPosts(),
      onSuccess: (data) async {
        data.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        final List<SocialPostModel> filteredPosts = [];

        for (final post in data) {
          try {
            final userRole = await _getUserRole(post.idUser);
            if (userRole == roleName) {
              filteredPosts.add(post);
            }
          } catch (e) {
            continue;
          }
        }

        _setState(isLoading: false, isSuccess: true, posts: filteredPosts);
      },
    );
  }

  //TODO: TOGGLE LIKE
  Future<void> onToggleLike(String postId) async {
    final isLiked = _likedPosts.contains(postId);

    await _handleApiCall<void>(
      apiCall: () => isLiked
          ? _socialPostService.unlikePost(id: postId, userId: currentUserId)
          : _socialPostService.likePost(id: postId, userId: currentUserId),
      onSuccess: (_) {
        final index = _posts.indexWhere((p) => p.idPost == postId);
        if (index != -1) {
          final post = _posts[index];
          final likesCount = isLiked ? post.likesCount - 1 : post.likesCount + 1;
          _posts[index] = post.copyWith(likesCount: likesCount);
        }

        if (isLiked) {
          _likedPosts.remove(postId);
        } else {
          _likedPosts.add(postId);
        }

        notifyListeners();
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

  Future<void> onToggleSave(String postId) async {
    final isLiked = _likedPosts.contains(postId);

    await _handleApiCall<void>(
      apiCall: () => isLiked
          ? _socialPostService.savePost(id: postId, userId: currentUserId)
          : _socialPostService.unsavePost(id: postId, userId: currentUserId),
      onSuccess: (_) {
        final index = _posts.indexWhere((p) => p.idPost == postId);
        if (index != -1) {
          final post = _posts[index];
          final likesCount = isLiked ? post.likesCount - 1 : post.likesCount + 1;
          _posts[index] = post.copyWith(likesCount: likesCount);
        }

        if (isLiked) {
          _likedPosts.remove(postId);
        } else {
          _likedPosts.add(postId);
        }

        notifyListeners();
      },
    );
  }

  //TODO: CREATE, UPDATE, DELETE POST
  Future<void> createPost({
    required String idUser,
    required String idGroup,
    required String content,
    String imageUrl = '',
    String videoUrl = '',
    String visibility = 'public',
    String postType = 'text',
    List<String> hashtags = const [],
  }) async {
    await _handleApiCall<SocialPostModel>(
      apiCall: () => _socialPostService.createPost(
        idUser: idUser,
        idGroup: idGroup,
        content: content,
        imageUrl: imageUrl,
        videoUrl: videoUrl,
        visibility: visibility,
        postType: postType,
        hashtags: hashtags,
      ),
      onSuccess: (newPost) {
        _posts.insert(0, newPost);
        notifyListeners();
      },
    );
  }

  Future<void> updatePost(SocialPostModel post) async {
    await _handleApiCall<SocialPostModel>(
      apiCall: () => _socialPostService.updatePost(id: post.idPost, post: post),
      onSuccess: (updated) {
        final index = _posts.indexWhere((p) => p.idPost == updated.idPost);
        if (index != -1) _posts[index] = updated;
      },
    );
  }

  Future<void> deletePosts(List<String> ids) async {
    await _handleApiCall<void>(
      apiCall: () async {
        final futures = ids.map((id) => _socialPostService.deletePost(id: id));
        await Future.wait(futures);
        _posts.removeWhere((p) => ids.contains(p.idPost));
        _selectedPosts.clear();
        _selectMode = false;
      },
    );
  }

  //TODO: FOLLOW / SAVE / SHARE
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
  

  //TODO: HIDE POST
  Future<void> onHidePost(String postId) async {
    await _handleApiCall<void>(
      apiCall: () async {
        final index = _posts.indexWhere((p) => p.idPost == postId);
        if (index == -1) return;
        final post = _posts[index].copyWith(visibility: 'hidden');
        _posts[index] = post;
        await _socialPostService.updatePost(id: postId, post: post);
      },
    );
  }

  //TODO: GET POSTS BY USER
  Future<void> getPostsByUserId(String userId) async {
    await _handleApiCall<List<SocialPostModel>>(
      apiCall: () => _socialPostService.getFeedUserId(userId: userId),
      onSuccess: (data) {
        data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _posts = data;
      },
    );
  }

  //TODO: GET POST LIKES
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

  //TODO: MULTI SELECT
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

  //TODO: RESET
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

  //TODO: REFRESH
  Future<void> refreshPosts({required String roleName}) async {
    await getPostsByRole(roleName: roleName);
  }
}