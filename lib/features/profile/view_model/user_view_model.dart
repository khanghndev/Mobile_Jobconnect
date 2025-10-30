import 'package:flutter/material.dart';
import 'package:job_connect/config/enum/shared_prefs_key.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/service/user_service.dart';

class UserViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

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

  // TODO: Lấy role name từ local (SharedPreferences)
  Future<void> loadRoleName() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString(SharedPrefsKey.roleName.getVal);
    _setState(roleName: savedRole);
  }

  // TODO: Cập nhật và lưu role name mới
  Future<void> updateRoleName(String newRole) async {
    _setState(roleName: newRole);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(SharedPrefsKey.roleName.getVal, newRole);
  }

  // TODO: Lấy user hiện tại
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

  // TODO: Lấy user khác (dùng cho SocialProfile)
  Future<void> getViewUser(String id) async {
    _setState(isDetailLoading: true, errorMessage: null);
    try {
      final detail = await _userService.getUserById(id: id);
      _setState(viewedUser: detail, isSuccess: true);
    } on ServerException catch (e) {
      _setState(errorMessage: e.err, isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } finally {
      _setState(isDetailLoading: false);
    }
  }

  // TODO: Tạo user
  Future<void> createUser(UserModel user) async {
    await _handleApiCall(
      apiCall: () async => [await _userService.createUser(user)],
      onSuccess: (data) => _setState(users: [..._users, ...data], isSuccess: true),
    );
  }

  // TODO: Cập nhật user
  Future<void> updateUser(String id, UserModel data) async {
    await _handleApiCall(
      apiCall: () async => [await _userService.updateUser(user: data)],
      onSuccess: (data) {
        final updated = data.first;
        final index = _users.indexWhere((u) => u.idUser == id);
        if (index >= 0) _users[index] = updated;
        _setState(users: _users, isSuccess: true);
      },
    );
  }

  // TODO: Xóa user
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
    } finally {
      _setState(isLoading: false);
    }
  }

  // TODO: Helper gọi API chung
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
    } finally {
      _setState(isLoading: false);
    }
  }

  // TODO: Làm mới user hiện tại
  Future<void> refreshCurrentUser() async {
    if (_currentUser != null) {
      await getCurrentUser(_currentUser!.idUser);
    }
  }

  // TODO: Xóa cache viewed user
  void clearViewedUser() {
    _setState(viewedUser: null);
  }

  // TODO: Reset toàn bộ state
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