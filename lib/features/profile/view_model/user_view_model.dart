  import 'dart:io';

  import 'package:flutter/material.dart';
  import 'package:flutter_dotenv/flutter_dotenv.dart';
  import 'package:job_connect/appwrite/storage_appwrite_service.dart';
  import 'package:job_connect/config/enum/shared_prefs_key.dart';
  import 'package:shared_preferences/shared_preferences.dart';
  import 'package:job_connect/config/error/server_exception.dart';
  import 'package:job_connect/features/profile/model/user_model.dart';
  import 'package:job_connect/features/profile/service/user_service.dart';

  class UserViewModel extends ChangeNotifier {
    final UserService _userService = UserService();
    final StorageAppwriteService _storageService = StorageAppwriteService();
    final String _bucketId = dotenv.env['APPWRITE_BUCKET_ID_IMAGE'] ?? '';

    bool _isLoading = false;
    bool _isDetailLoading = false;
    bool _isSuccess = false;
    String? _errorMessage;

    List<UserModel> _users = [];
    UserModel? _currentUser;
    UserModel? _viewedUser;
    String? _roleName;

    // Getters
    bool get isLoading => _isLoading;
    bool get isDetailLoading => _isDetailLoading;
    bool get isSuccess => _isSuccess;
    String? get errorMessage => _errorMessage;
    bool get hasError => _errorMessage != null && _errorMessage!.isNotEmpty;

    List<UserModel> get users => _users;
    UserModel? get currentUser => _currentUser;
    UserModel? get viewedUser => _viewedUser;
    String? get roleName => _roleName;

    // Hàm cập nhật state
    void _setState({
      bool? isLoading,
      bool? isDetailLoading,
      bool? isSuccess,
      String? errorMessage,
      List<UserModel>? users,
      UserModel? currentUser,
      UserModel? viewedUser,
      String? roleName,
    }) {
      _isLoading = isLoading ?? _isLoading;
      _isDetailLoading = isDetailLoading ?? _isDetailLoading;
      _isSuccess = isSuccess ?? _isSuccess;
      _errorMessage = errorMessage;
      _users = users ?? _users;
      _currentUser = currentUser ?? _currentUser;
      _viewedUser = viewedUser ?? _viewedUser;
      _roleName = roleName ?? _roleName;
      notifyListeners();
    }

    //   Lấy role name từ local (SharedPreferences)
    Future<void> loadRoleName() async {
      final prefs = await SharedPreferences.getInstance();
      final savedRole = prefs.getString(SharedPrefsKey.roleName.getVal);
      _setState(roleName: savedRole);
    }

    //   Cập nhật và lưu role name mới
    Future<void> updateRoleName(String newRole) async {
      _setState(roleName: newRole);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(SharedPrefsKey.roleName.getVal, newRole);
    }

    Future<UserModel?> fetchUserViewerById(String id) async {
      try {
        final detail = await _userService.getUserById(id: id);
        return detail;
      } catch (e) {
        return null;
      }
    }

    //   Lấy user hiện tại
    Future<void> getCurrentUser(String id) async {
      _setState(isDetailLoading: true, errorMessage: null);
      try {
        final detail = await _userService.getUserById(id: id);
        _setState(
          currentUser: detail,
          isSuccess: true,
          roleName: detail.role?.roleName,
        );
      } on ServerException catch (e) {
        _setState(errorMessage: e.err, isSuccess: false);
      } catch (e) {
        _setState(errorMessage: e.toString(), isSuccess: false);
      } finally {
        _setState(isDetailLoading: false);
      }
    }

    //   Lấy user khác (dùng cho SocialProfile)
    Future<UserModel?> getViewUser(String id) async {
      _setState(isDetailLoading: true, errorMessage: null, isSuccess: null);
      try {
        final detail = await _userService.getUserById(id: id);
        _setState(viewedUser: detail, isSuccess: true, errorMessage: null);
        return detail; // trả về user khi thành công
      } on ServerException catch (e) {
        _setState(errorMessage: e.err, isSuccess: false);
        return null;
      } catch (e) {
        _setState(errorMessage: e.toString(), isSuccess: false);
        return null;
      } finally {
        _setState(isDetailLoading: false);
      }
    }

  //   Lấy tất cả user từ server
  Future<void> fetchAllUsers() async {
    await _handleApiCall(
      apiCall: () => _userService.getAllUsers(),
      onSuccess: (data) => _setState(users: data, isSuccess: true),
    );
  }

  //   Tìm kiếm user theo từ khóa
    Future<void> searchUsers(String keyword) async {
      final lowerKeyword = keyword.toLowerCase();
      final filtered = _users.where((u) {
        final name = u.userName.toLowerCase();
        final email = u.email.toLowerCase();
        return name.contains(lowerKeyword) || email.contains(lowerKeyword);
      }).toList();

      _setState(users: filtered);
    }

    //   Tạo user
    Future<void> createUser(UserModel user) async {
      await _handleApiCall(
        apiCall: () async => [await _userService.createUser(user)],
        onSuccess: (data) => _setState(users: [..._users, ...data], isSuccess: true),
      );
    }

    //   Cập nhật user
    Future<void> updateUser(String id, UserModel data, {File? newAvatar}) async {
      _setState(isLoading: true, errorMessage: null, isSuccess: false);

      try {
        UserModel updatedUser = data;

        // Nếu có avatar mới → upload lên Appwrite
        if (newAvatar != null) {
          if (_bucketId.isEmpty) throw Exception('BucketId chưa cấu hình');

          final uploadedFile = await _storageService.uploadFile(
            newAvatar,
            bucketId: _bucketId,
          );

          final avatarUrl = _storageService.getFileViewUrl(
            uploadedFile.$id,
            bucketId: _bucketId,
          );

          updatedUser = data.copyWith(avatarUrl: avatarUrl);
        }

        // Gọi API cập nhật user
        await _userService.updateUser(user: updatedUser);

        // Cập nhật state local
        final index = _users.indexWhere((u) => u.idUser == id);
        if (index >= 0) _users[index] = updatedUser;
        _setState(users: _users, currentUser: updatedUser, isSuccess: true);

      } on ServerException catch (e) {
        _setState(errorMessage: e.err, isSuccess: false);
      } catch (e) {
        _setState(errorMessage: e.toString(), isSuccess: false);
      }  
    }

    //   Xóa user
    Future<void> deleteUser(String id) async {
      _setState(isLoading: true, errorMessage: null);
      try {
        await _userService.deleteUser(id: id);
        _users.removeWhere((u) => u.idUser == id);
        _setState(users: _users, isSuccess: true);
      } on ServerException catch (e) {
        _setState(errorMessage: e.err, isSuccess: false);
      } catch (e) {
        _setState(errorMessage: e.toString(), isSuccess: false);
      }  
    }

    //   Helper gọi API chung
    Future<void> _handleApiCall({
      required Future<List<UserModel>> Function() apiCall,
      required void Function(List<UserModel>) onSuccess,
    }) async {
      _setState(isLoading: true, errorMessage: null, isSuccess: false);
      try {
        final data = await apiCall();
        onSuccess(data);
      } on ServerException catch (e) {
        _setState(errorMessage: e.err, isSuccess: false);
      } catch (e) {
        _setState(errorMessage: e.toString(), isSuccess: false);
      }  
    }

    //   Làm mới user hiện tại
    Future<void> refreshCurrentUser() async {
      if (_currentUser != null) {
        await getCurrentUser(_currentUser!.idUser);
      }
    }

    //   Xóa cache viewed user
    void clearViewedUser() {
      _setState(viewedUser: null);
    }

    //   Reset toàn bộ state
    void reset() {
      _setState(
        isLoading: false,
        isDetailLoading: false,
        isSuccess: false,
        errorMessage: null,
        users: [],
        currentUser: null,
        viewedUser: null,
        roleName: null,
      );
    }
  }