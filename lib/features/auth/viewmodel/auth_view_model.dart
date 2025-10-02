import 'package:flutter/material.dart';
import 'package:job_connect/config/enum/shared_prefs_key.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/shared_prefs_service.dart';
import 'package:job_connect/data/dto/auth_dto/auth_register_dto.dart';
import 'package:job_connect/features/auth/model/login_model.dart';
import 'package:job_connect/features/auth/service/auth_api_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthApiService _authApiService = AuthApiService();
  final SharedPrefsService _prefs;

  AuthViewModel({required SharedPrefsService prefs}) : _prefs = prefs;

  bool _isLoading = false;
  String? _errorMessage;
  LoginModel? _loginModel;
  bool _isLoggedIn = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  LoginModel? get loginModel => _loginModel;

  /// Đăng ký
  Future<void> register(RegisterDto dto) async {
    _setLoading(true);
    try {
      final message = await _authApiService.register(dto);
      _errorMessage = null;
      debugPrint("Đăng ký thành công: $message");
    } on ServerException catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Đăng nhập
  Future<void> login({required String email, required String password}) async {
    _setLoading(true);
    try {
      final data = await _authApiService.login(email: email, password: password);
      _loginModel = data;
      _errorMessage = null;
      _isLoggedIn = true;

      // Lưu token và trạng thái login vào SharedPreferences
      await _prefs.saveString(SharedPrefsKey.token, data.token);
      await _prefs.saveBool(SharedPrefsKey.isLoggedIn, true);

      debugPrint("Đăng nhập thành công, token đã lưu");
   } on ServerException catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Đăng xuất
  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authApiService.logout();
      _loginModel = null;
      _errorMessage = null;
      _isLoggedIn = false;

      // Xóa token và trạng thái login
      await _prefs.remove(SharedPrefsKey.token);
      await _prefs.saveBool(SharedPrefsKey.isLoggedIn, false);

      debugPrint("Đăng xuất thành công, token đã xóa");
    } on ServerException{
      rethrow;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
