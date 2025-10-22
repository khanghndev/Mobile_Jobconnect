import 'package:flutter/material.dart';
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
  UserModel? _userDetail;
  String? _roleName;

  // Getters
  bool get isLoading => _isLoading;
  bool get isDetailLoading => _isDetailLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;

  List<UserModel> get users => _users;
  UserModel? get userDetail => _userDetail;
  String? get roleName => _roleName;

  // Private: cập nhật state và notify
  void _setState({
    bool? isLoading,
    bool? isDetailLoading,
    bool? isSuccess,
    String? errorMessage,
    List<UserModel>? users,
    UserModel? userDetail,
    String? roleName,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _isDetailLoading = isDetailLoading ?? _isDetailLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _errorMessage = errorMessage;
    _users = users ?? _users;
    _userDetail = userDetail ?? _userDetail;
    _roleName = roleName ?? _roleName;
    notifyListeners();
  }

  // Lấy chi tiết người dùng theo ID
  Future<void> getUserDetail(String id) async {
    _setState(isDetailLoading: true, errorMessage: null);
    try {
      final detail = await _userService.getUserById(id: id);
      _setState(userDetail: detail, isSuccess: true, roleName: detail.role?.roleName,);
    } on ServerException catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } finally {
      _setState(isDetailLoading: false);
    }
  }

  // Tạo người dùng mới
  Future<void> createUser(UserModel user) async {
    await _handleApiCall(
      apiCall: () async => [await _userService.createUser(user)],
      onSuccess: (data) {
        // Thêm user vừa tạo vào danh sách
        _setState(users: [..._users, ...data], isSuccess: true);
      },
    );
  }

  // Cập nhật người dùng
  Future<void> updateUser(String id, UserModel data) async {
    await _handleApiCall(
      apiCall: () async => [await _userService.updateUser(user: data)],
      onSuccess: (data) {
        final updatedUser = data.first;
        final index = _users.indexWhere((u) => u.idUser == id);
        if (index >= 0) {
          _users[index] = updatedUser;
        }
        _setState(users: _users, isSuccess: true);
      },
    );
  }

  // Xóa người dùng
  Future<void> deleteUser(String id) async {
    _setState(isLoading: true, errorMessage: null);
    try {
      await _userService.deleteUser(id: id);
      _users.removeWhere((u) => u.idUser == id);
      _setState(users: _users, isSuccess: true);
    } on ServerException catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } finally {
      _setState(isLoading: false);
    }
  }

  // Hàm xử lý API chung (giảm lặp code)
  Future<void> _handleApiCall({
    required Future<List<UserModel>> Function() apiCall,
    required void Function(List<UserModel>) onSuccess,
  }) async {
    _setState(isLoading: true, errorMessage: null, isSuccess: false);

    try {
      final data = await apiCall();
      onSuccess(data);
    } on ServerException catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } finally {
      _setState(isLoading: false);
    }
  }

  // Làm mới danh sách
  Future<void> refreshUsers() async => await getUserDetail(_userDetail!.idUser);

  // Reset toàn bộ state
  void reset() {
    _setState(
      isLoading: false,
      isDetailLoading: false,
      isSuccess: false,
      errorMessage: null,
      users: [],
      userDetail: null,
    );
  }
}
