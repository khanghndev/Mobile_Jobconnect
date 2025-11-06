import 'package:job_connect/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _client = SupabaseConfig.client;

  // AUTHEN CƠ BẢN //

  /// Đăng ký bằng email & password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'io.supabase.flutter://login-callback/', // Deep link callback
    );
  }

  /// Đăng nhập bằng email & password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Đăng xuất
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Lấy user hiện tại
  User? get currentUser => _client.auth.currentUser;

  // GOOGLE LOGIN //

  /// Đăng nhập bằng Google OAuth
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback/',
    );
  }

  // PASSWORD / VERIFY //

  /// Gửi email reset password
  Future<void> resetPassword({required String email}) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.flutter://reset-password/',
    );
  }

  /// Cập nhật mật khẩu sau khi reset
  Future<UserResponse> updatePassword(String newPassword) async {
    return await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Gửi lại email xác thực
  Future<void> resendVerificationEmail(String email) async {
    await _client.auth.resend(
      email: email,
      type: OtpType.email
    );
  }

  // LẮNG NGHE AUTH STATE //

  /// Stream lắng nghe thay đổi trạng thái người dùng
  Stream<AuthStatus> get onAuthStateChange =>
      _client.auth.onAuthStateChange.map((event) => event.session != null
          ? AuthStatus.loggedIn
          : AuthStatus.loggedOut);

  /// Kiểm tra trạng thái hiện tại
  bool get isLoggedIn => _client.auth.currentUser != null;

  // USER PROFILE //

  /// Lấy profile chi tiết từ bảng "profiles" (nếu có)
  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return response;
  }
}

/// Enum hỗ trợ xử lý trạng thái đăng nhập
enum AuthStatus { loggedIn, loggedOut }
