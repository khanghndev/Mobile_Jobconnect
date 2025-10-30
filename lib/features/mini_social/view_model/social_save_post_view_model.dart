import 'package:flutter/material.dart';
import 'package:job_connect/config/enum/shared_prefs_key.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/shared_prefs_service.dart';
import 'package:job_connect/features/mini_social/model/save_post_model.dart';
import 'package:job_connect/features/mini_social/service/social_save_post_service.dart';

class SocialSavePostViewModel extends ChangeNotifier {
  final SocialSavePostService _service = SocialSavePostService();
  final SharedPrefsService _prefs;

  SocialSavePostViewModel({required SharedPrefsService prefs}) : _prefs = prefs;

  // STATE
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  List<SavedPostModel> _savedPosts = [];
  Map<String, int> _folderSavedCount = {};

  // GETTERS
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  List<SavedPostModel> get savedPosts => _savedPosts;
  String get currentUserId => _prefs.getString(SharedPrefsKey.idUser) ?? '';
  Map<String, int> get folderSavedCount => _folderSavedCount;

  // PRIVATE SET STATE
  void _setState({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<SavedPostModel>? savedPosts,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _errorMessage = errorMessage;
    _savedPosts = savedPosts ?? _savedPosts;
    notifyListeners();
  }

  void incrementFolderCount(String folderName) {
    folderSavedCount[folderName] = (folderSavedCount[folderName] ?? 0) + 1;
    notifyListeners();
  }

  bool isPostSaved(String idPost) {
    return _savedPosts.any((p) => p.idPost == idPost);
  }

  Future<void> toggleSavePostWithFolder({
    required String idPost,
    String? selectedFolder,
  }) async {
    if (isPostSaved(idPost)) {
      // Nếu đã lưu → xóa bài
      final folderName = _savedPosts.firstWhere((p) => p.idPost == idPost,
              orElse: () => SavedPostModel(idPost: '', idUser: '', folderName: 'Bài viết yêu thích', savedAt: DateTime.now(), note: 'Yêu thích của tôi'))
          .folderName;

      await _service.deleteSavedPost(idPost: idPost, idUser: currentUserId);
      _savedPosts.removeWhere((p) => p.idPost == idPost);

      // Update folder count
      if (_folderSavedCount[folderName] != null) {
        _folderSavedCount[folderName] =
            (_folderSavedCount[folderName]! - 1).clamp(0, double.infinity).toInt();
      }

      notifyListeners();
    } else {
      // Nếu chưa lưu → lưu bài
      final folders = await getSavedFolders();
      final folderToSave = selectedFolder ?? (folders.isNotEmpty ? folders.first : 'Bộ sưu tập ưu thích');

      final savedPost = await _service.createSavedPost(
        idPost: idPost,
        idUser: currentUserId,
        folderName: folderToSave,
        note: ""
      );

      _savedPosts.add(savedPost);
      _folderSavedCount[folderToSave] = (_folderSavedCount[folderToSave] ?? 0) + 1;

      notifyListeners();
    }
  }

  // HELPER API CALL
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

  // LẤY DANH SÁCH BÀI VIẾT ĐÃ LƯU
  Future<void> getSavedPosts() async {
    await _handleApiCall<List<SavedPostModel>>(
      apiCall: () => _service.getSavedPostsByUser(currentUserId),
      onSuccess: (data) => _savedPosts = data,
    );
  }

  // LẤY DANH SÁCH FOLDER
  Future<List<String>> getSavedFolders() async {
    return await _service.getSavedPostsFolders(currentUserId);
  }

  // LƯU BÀI VIẾT
  Future<void> savePost({
    required String idPost,
    String folderName = 'Bài viết yêu thích',
    String note = '',
  }) async {
    await _handleApiCall<SavedPostModel>(
      apiCall: () => _service.createSavedPost(
        idPost: idPost,
        idUser: currentUserId,
        folderName: folderName,
        note: note,
      ),
      onSuccess: (savedPost) => _savedPosts.add(savedPost),
    );
  }

  // CẬP NHẬT BÀI VIẾT ĐÃ LƯU
  Future<void> updateSavedPost({
    required String idPost,
    required String folderName,
    String note = '',
  }) async {
    await _handleApiCall<SavedPostModel>(
      apiCall: () => _service.updateSavedPost(
        idPost: idPost,
        idUser: currentUserId,
        folderName: folderName,
        note: note,
      ),
      onSuccess: (updatedPost) {
        final index = _savedPosts.indexWhere((p) => p.idPost == updatedPost.idPost);
        if (index != -1) _savedPosts[index] = updatedPost;
      },
    );
  }

  // XOÁ BÀI VIẾT ĐÃ LƯU
  Future<void> deleteSavedPost(String idPost) async {
    await _handleApiCall<void>(
      apiCall: () => _service.deleteSavedPost(idPost: idPost, idUser: currentUserId),
      onSuccess: (_) => _savedPosts.removeWhere((p) => p.idPost == idPost),
    );
  }

  // RESET STATE
  void reset() {
    _setState(
      isLoading: false,
      isSuccess: false,
      errorMessage: null,
      savedPosts: [],
    );
  }
}
