import 'dart:async';

import 'package:flutter/material.dart';
import 'package:job_connect/config/enum/gender.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import 'package:job_connect/supabase/supabase_auth_service.dart';
import 'package:job_connect/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:job_connect/config/enum/shared_prefs_key.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/services/shared_prefs_service.dart';
import 'package:job_connect/config/utils/string_utils.dart';
import 'package:job_connect/features/profile/model/candidate_info_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/auth/service/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authApiService = AuthService();
  final UserService _userService = UserService();
  final SupabaseAuthService _supabaseAuthService = SupabaseAuthService();
  final SharedPrefsService _prefs;

  AuthViewModel({required SharedPrefsService prefs}) : _prefs = prefs;
  
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _isLoggedIn = false;
  bool _isLoggingOut = false;
  String? _errorMessage;

  UserModel? userModel;
  CandidateInfoModel? _candidateInfo;
  String? _idUser; // ID từ backend
  String? _idUserSupabase; // ID từ Supabase

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoggingOut => _isLoggingOut;
  String? get errorMessage => _errorMessage;
  String? get idUser => _idUser;
  String? get idUserSupabase => _idUserSupabase;
  CandidateInfoModel? get candidateInfo => _candidateInfo;

  void _setState({
    bool? isLoading,
    bool? isSuccess,
    bool? isLoggedIn,
    bool? isLoggingOut,
    String? errorMessage,
    String? idUser,
    String? idUserSupabase,
    CandidateInfoModel? candidateInfo,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _isLoggedIn = isLoggedIn ?? _isLoggedIn;
    _isLoggingOut = isLoggingOut ?? _isLoggingOut;
    _errorMessage = errorMessage;
    _idUser = idUser ?? _idUser;
    _idUserSupabase = idUserSupabase ?? _idUserSupabase;
    _candidateInfo = candidateInfo ?? _candidateInfo;
    notifyListeners();
  }

  // Đăng ký tài khoản mới (qua email/password)
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    _setState(isLoading: true, isSuccess: false, errorMessage: null);

    try {
      // Tạo user Supabase
      final response = await _supabaseAuthService.signUp(
        email: email,
        password: password,
      );
      final supabaseUser = response.user;
      if (supabaseUser == null) throw Exception("Đăng ký Supabase thất bại");

      try {
        // Gọi API backend tạo tài khoản user
        await _authApiService.register(
          name: name,
          email: email,
          phone: phone,
          password: password,
          confirmPassword: confirmPassword,
          supabaseIdUser: supabaseUser.id,
        );

        // Lưu thông tin vào SharedPrefs
        await _prefs.saveString(SharedPrefsKey.idUser, supabaseUser.id);
        await _prefs.saveString(SharedPrefsKey.idUserAppWrite, supabaseUser.id);
        await _prefs.saveString(
          SharedPrefsKey.roleName,
          StringUtils.capitalize(UserRole.candidate.name),
        );

        _setState(
          isLoading: false,
          isSuccess: true,
          isLoggedIn: true,
          idUser: idUser,
          idUserSupabase: supabaseUser.id,
        );
      } catch (backendError) {
        // Nếu BE lỗi -> rollback Supabase user
        // await _supabaseAuthService.deleteUser(supabaseUser.id);
        rethrow;
      }
    } on AuthException catch (e) {
      _setState(isLoading: false, errorMessage: e.message, isSuccess: false);
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString(), isSuccess: false);
    }
  }

  Future<void> loginWithGoogle() async {
    _setState(isLoading: true, isSuccess: false, errorMessage: null);
    StreamSubscription<AuthState>? subscription;
    try {
      await _supabaseAuthService.signInWithGoogle();
      subscription = SupabaseConfig.client.auth.onAuthStateChange.listen(
        (data) async {
          final session = data.session;
          final user = session?.user;
          if (user == null) return;
          final idUserSupabase = user.id;
          try {
            final existingUser = await _userService.getUserById(id: idUserSupabase);
            _setState(
              isLoading: false,
              isSuccess: true,
              isLoggedIn: true,
              idUser: existingUser.idUser,
              idUserSupabase: idUserSupabase,
            );
          } catch (e) {
            if (e.toString().contains('404') || e.toString().contains('User not found')) {
              final newUser = UserModel(
                idUser: idUserSupabase,
                userName: user.userMetadata?['name'] ?? 'Người dùng Google',
                email: user.email ?? '',
                phoneNumber: user.userMetadata?['phone'] ?? '',
                password: 'GOOGLE_AUTH_123456@#',
                idRole: 'role2',
                accountStatus: 'Active',
                gender: Gender.other.name,
                address: '',
                dateOfBirth: DateTime.now(),
                avatarUrl: user.userMetadata?['avatar_url'] ?? '',
                socialLogin: 'Google',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );

              await _userService.createUser(newUser);
            } else {
              rethrow;
            }
          }
          await _prefs.saveString(SharedPrefsKey.idUser, idUserSupabase);
          await _prefs.saveString(SharedPrefsKey.idUserAppWrite, idUserSupabase);
          await _prefs.saveString(
            SharedPrefsKey.roleName,
            StringUtils.capitalize(UserRole.candidate.name),
          );
          _setState(
            isLoading: false,
            isSuccess: true,
            isLoggedIn: true,
            idUser: idUserSupabase,
            idUserSupabase: idUserSupabase,
          );
          await subscription?.cancel();
        },
      );
    } catch (e) {
      _setState(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Đăng nhập bằng email/password
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _setState(isLoading: true, isSuccess: false, errorMessage: null);

    try {
      final response = await _supabaseAuthService.signIn(
        email: email,
        password: password,
      );

      final supabaseUser = response.user;
      if (supabaseUser == null) throw Exception("Không lấy được user từ Supabase");

      final loginData = await _authApiService.login(email: email, password: password);

      await _prefs.saveString(SharedPrefsKey.token, loginData.token);
      await _prefs.saveString(SharedPrefsKey.idUser, loginData.user.idUser);
      await _prefs.saveString(SharedPrefsKey.idUserAppWrite, supabaseUser.id);
      await _prefs.saveString(
        SharedPrefsKey.roleName,
        loginData.user.role?.roleName ?? 'Candidate',
      );

      _setState(
        isLoading: false,
        isSuccess: true,
        isLoggedIn: true,
        idUser: loginData.user.idUser,
        idUserSupabase: supabaseUser.id,
      );
    } on AuthException catch (e) {
      _setState(isLoading: false, errorMessage: e.message, isSuccess: false);
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString(), isSuccess: false);
    }
  }

  // Đăng xuất người dùng
  Future<void> logout() async {
    // bật loading ngay khi bắt đầu logout
    _setState(isLoading: true, isLoggingOut: true, isSuccess: false, errorMessage: null);

    try {
      await _supabaseAuthService.signOut();
      await _authApiService.logout();
      await _prefs.clearLocalData();

      // sau khi logout xong thì tắt loading và set trạng thái
      _setState(
        isLoading: false,
        isLoggingOut: false,
        isSuccess: true,
        isLoggedIn: false,
        idUser: null,
        idUserSupabase: null,
      );
    } catch (e) {
      _setState(
        isLoading: false,
        isLoggingOut: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
    }
  }
  
  // Kiểm tra trạng thái đăng nhập hiện tại
  Future<void> checkLoginStatus() async {
    _setState(isLoading: true, errorMessage: null);
    try {
      final user = _supabaseAuthService.currentUser;
      if (user != null) {
        final savedIdUser = _prefs.getString(SharedPrefsKey.idUser);
        _setState(
          isLoading: false,
          isSuccess: true,
          isLoggedIn: true,
          idUser: savedIdUser,
          idUserSupabase: user.id,
        );
      } else {
        _setState(isLoading: false, isSuccess: false, isLoggedIn: false);
      }
    } catch (e) {
      _setState(
        isLoading: false,
        isSuccess: false,
        isLoggedIn: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Gửi yêu cầu nhập OTP
  Future<void> enterOtp(String email) async {
    _setState(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await _authApiService.enterOtp(email: email);
      _setState(isLoading: false, isSuccess: true);
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString(), isSuccess: false);
    }
  }

    /// Gửi yêu cầu nhập OTP (quên mật khẩu)
  Future<void> forgotPassword(String email) async {
    _setState(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await _authApiService.forgotPassword(email: email);
      _setState(isLoading: false, isSuccess: true);
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString(), isSuccess: false);
    }
  }

  /// Xác thực mã OTP
  Future<void> verifyOtp({
    required String email,
    required String code,
  }) async {
    _setState(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await _authApiService.verifyOtp(email: email, code: code);
      _setState(isLoading: false, isSuccess: true);
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString(), isSuccess: false);
    }
  }

  Future<void> verifyOtpReset({
    required String email,
    required String code,
  }) async {
    _setState(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await _authApiService.verifyOtpReset(email: email, code: code);
      _setState(isLoading: false, isSuccess: true);
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString(), isSuccess: false);
    }
  }

  /// Gửi lại mã OTP
  Future<void> resendOtp(String email) async {
    _setState(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await _authApiService.resendOtp(email: email);
      _setState(isLoading: false, isSuccess: true);
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString(), isSuccess: false);
    }
  }

  /// Đặt lại mật khẩu mới
  Future<void> resetPassword({
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _setState(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await _authApiService.resetPassword(
        email: email,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      _setState(isLoading: false, isSuccess: true);
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString(), isSuccess: false);
    }
  }

}