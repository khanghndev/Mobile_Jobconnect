import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'appwrite_client.dart';

class AuthAppwriteService {
  final AppwriteClient _appwrite = AppwriteClient();

  /// Đăng ký tài khoản mới
  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = await _appwrite.account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      // Xác thực email
      // await _appwrite.account.createVerification(
      //   url: 'jobconnect://email-verification-callback',
      // );

      return user;
    } on AppwriteException catch (e) {
      throw ServerException(
        err: e.message ?? "Appwrite signUp error",
        type: ServerExceptionType.appwrite,
      );
    } catch (e) {
      throw ServerException(
        err: e.toString(),
        type: ServerExceptionType.unknown,
      );
    }
  }

  /// Đăng nhập với email & password
  Future<Session?> login({
    required String email,
    required String password,
  }) async {
    try {
      // //Lấy user trước
      // final user = await _appwrite.account.get();
      // //Xác thực email chưa
      // if (!user.emailVerification) {
      //   throw ServerException(
      //     err: "Vui lòng xác thực email trước khi đăng nhập",
      //     type: ServerExceptionType.appwrite,
      //   );
      // }
      final session = await _appwrite.account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      return session;
    } on AppwriteException catch (e) {
      throw ServerException(
        err: e.message ?? "Appwrite login error",
        type: ServerExceptionType.appwrite,
      );
    } catch (e) {
      throw ServerException(
        err: e.toString(),
        type: ServerExceptionType.unknown,
      );
    }
  }

  Future<User> loginWithGoogle() async {
    // final success = "appwrite://oauth-callback";
    // final failure = "appwrite://oauth-callback";

    try {
      await _appwrite.account.createOAuth2Session(
        provider: OAuthProvider.google,
        // success: success,
        // failure: failure,
        scopes: ['repo', 'user']
      );

      // Sau khi redirect về app -> Appwrite SDK đã lưu session trong cookie
      final user = await _appwrite.account.get();
      return user;
    } on AppwriteException catch (e) {
      throw ServerException(
        err: e.message ?? "Appwrite Google login error",
        type: ServerExceptionType.appwrite,
      );
    } catch (e) {
      throw ServerException(
        err: e.toString(),
        type: ServerExceptionType.unknown,
      );
    }
  }

  /// Lấy thông tin user hiện tại
  Future<User?> getCurrentUser() async {
    try {
      final user = await _appwrite.account.get();
      return user;
    } on AppwriteException catch (e) {
      throw ServerException(
        err: e.message ?? "Appwrite getUser error",
        type: ServerExceptionType.appwrite,
      );
    } catch (e) {
      throw ServerException(
        err: e.toString(),
        type: ServerExceptionType.unknown,
      );
    }
  }

  /// Đăng xuất user hiện tại
  Future<void> logout() async {
    try {
      await _appwrite.account.deleteSessions();
    } on AppwriteException catch (e) {
      throw ServerException(
        err: e.message ?? "Appwrite logout error",
        type: ServerExceptionType.appwrite,
      );
    } catch (e) {
      throw ServerException(
        err: e.toString(),
        type: ServerExceptionType.unknown,
      );
    }
  }
}