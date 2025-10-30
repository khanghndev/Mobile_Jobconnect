import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:job_connect/appwrite/auth_appwrite_service.dart';
import 'package:job_connect/config/enum/shared_prefs_key.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/shared_prefs_service.dart';
import 'package:job_connect/config/utils/string_utils.dart';
import 'package:job_connect/features/profile/model/candidate_info_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/auth/model/login_model.dart';
import 'package:job_connect/features/auth/service/auth_service.dart';
import 'package:job_connect/features/profile/service/candidate_info_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authApiService = AuthService();
  final AuthAppwriteService _authAppwriteService = AuthAppwriteService();
  final CandidateInfoService _candidateInfoService = CandidateInfoService();
  final SharedPrefsService _prefs;

  AuthViewModel({required SharedPrefsService prefs}) : _prefs = prefs;

  bool _isLoading = false;
  String? _errorMessage;
  LoginModel? _loginModel;
  UserModel? userModel;
  User? _userAppwrite;
  String? _idUser;
  String? _idUserAppWrite;
  bool _isLoggedIn = false;
  bool _isSuccess = false;
  CandidateInfoModel? _candidateInfo;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  bool get isSuccess => _isSuccess;
  LoginModel? get loginModel => _loginModel;
  String? get idUser => _idUser;
  User? get userAppwrite => _userAppwrite;
  String? get idUserAppWrite => _idUserAppWrite;
  CandidateInfoModel? get candidateInfo => _candidateInfo;

  void _setState({
    bool? isLoading,
    bool? isSuccess,
    bool? isLoggedIn,
    String? errorMessage,
    User? userAppwrite,
    LoginModel? loginModel,
    String? idUser,
    String? idUserAppWrite,
    CandidateInfoModel? candidateInfo,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _isLoggedIn = isLoggedIn ?? _isLoggedIn;
    _errorMessage = errorMessage;
    _userAppwrite = userAppwrite ?? _userAppwrite;
    _loginModel = loginModel ?? _loginModel;
    _idUser = idUser ?? _idUser;
    _idUserAppWrite = idUserAppWrite ?? _idUserAppWrite;
    _candidateInfo = candidateInfo ?? _candidateInfo;

    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String comfirmPassword,
  }) async {
    _setState(isLoading: true, errorMessage: null, isSuccess: false);

    try {
      // 1. Đăng ký backend trước
      final idUser = await _authApiService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        comfirmPassword: comfirmPassword,
      );

      // 2. Nếu backend thành công, đăng ký Appwrite
      final user = await _authAppwriteService.signUp(
        email: email,
        password: password,
        name: name,
      );

      // 3. Tạo ứng viên mới
      final candidate = CandidateInfoModel(
        idUser: idUser,
        workPosition: "",
        ratingScore: 0.0,
        universityName: "",
        educationLevel: "",
        experienceYears: 0,
        skills: "",
      );

      final newCandidate = await _candidateInfoService.createCandidate(candidate);

      // 4. Cập nhật state thành công
      _setState(
        isLoading: false,
        isSuccess: true,
        userAppwrite: user,
        idUser: idUser,
        candidateInfo: newCandidate,
      );

    } on ServerException catch (e) {
      _setState(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
    } catch (e) {
      _setState(
        isLoading: false,
        errorMessage: e.toString(),
        isSuccess: false,
      );
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _setState(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      // Kiểm tra session Appwrite
      User? currentUser;
      try {
        currentUser = await _authAppwriteService.getCurrentUser();
      } catch (_) {
        currentUser = null;
      }

      Session? session;
      if (currentUser == null) {
        session = await _authAppwriteService.login(email: email, password: password);
        currentUser = await _authAppwriteService.getCurrentUser();
      }

      // Backend login
      final data = await _authApiService.login(email: email, password: password);

      // Lưu SharedPrefs
      await _prefs.saveString(SharedPrefsKey.token, data.token);
      await _prefs.saveString(SharedPrefsKey.idUserAppWrite, currentUser?.$id ?? "");
      await _prefs.saveString(SharedPrefsKey.idUser, data.user.idUser);
      await _prefs.saveString(SharedPrefsKey.roleName, data.user.role?.roleName ?? StringUtils.capitalize(UserRole.candidate.name));

      if (session != null) {
        await _prefs.saveString(SharedPrefsKey.sessionId, session.$id);
      }

      _setState(
        isLoading: false,
        isSuccess: true,
        isLoggedIn: true,
        errorMessage: null,
        userAppwrite: currentUser,
        loginModel: data,
        idUser: data.user.idUser,
        idUserAppWrite: currentUser?.$id,
      );
    } on ServerException catch (e) {
      _setState(isLoading: false, isSuccess: false, isLoggedIn: false, errorMessage: e.toString());
    } catch (e) {
      _setState(isLoading: false, isSuccess: false, isLoggedIn: false, errorMessage: e.toString());
    }
  }

  Future<void> loginWithGoogle() async {
    _setState(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      // OAuth2 Appwrite
      await _authAppwriteService.loginWithGoogle();

      // Lấy user
      final user = await _authAppwriteService.getCurrentUser();

      _setState(
        isLoading: false,
        isSuccess: true,
        isLoggedIn: true,
        userAppwrite: user,
      );
    } on ServerException catch (e) {
      _setState(isLoading: false, isSuccess: false, isLoggedIn: false, errorMessage: e.toString());
    } catch (e) {
      _setState(isLoading: false, isSuccess: false, isLoggedIn: false, errorMessage: e.toString());
    }
  }

  Future<void> logout() async {
    _setState(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      await _authApiService.logout();
      await _authAppwriteService.logout();
      await _prefs.clearLocalData();

      _setState(
        isLoading: false,
        isSuccess: true,
        isLoggedIn: false,
        userAppwrite: null,
        loginModel: null,
        idUser: null,
        idUserAppWrite: null,
        errorMessage: null,
      );
    } on ServerException catch (e) {
      _setState(isLoading: false, isSuccess: false, errorMessage: e.toString());
    } catch (e) {
      _setState(isLoading: false, isSuccess: false, isLoggedIn: false, errorMessage: e.toString());
    }
  }

  Future<void> checkLoginStatus() async {
    _setState(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      final token = _prefs.getString(SharedPrefsKey.token);
      if (token == null || token.isEmpty) {
        _setState(isLoading: false, isLoggedIn: false, isSuccess: false);
        return;
      }

      final user = await _authAppwriteService.getCurrentUser();
      if (user != null) {
        final savedIdUser = _prefs.getString(SharedPrefsKey.idUser);
        _setState(
          isLoading: false,
          isLoggedIn: true,
          isSuccess: true,
          userAppwrite: user,
          idUser: savedIdUser,
        );
      } else {
        await _prefs.remove(SharedPrefsKey.token);
        await _prefs.remove(SharedPrefsKey.sessionId);
        await _prefs.remove(SharedPrefsKey.idUser);
        _setState(isLoading: false, isLoggedIn: false, isSuccess: false);
      }
    } on ServerException catch (e) {
      _setState(isLoading: false, isLoggedIn: false, isSuccess: false, errorMessage: e.toString());
    } catch (e) {
      _setState(isLoading: false, isLoggedIn: false, isSuccess: false, errorMessage: e.toString());
    }
  }
}