import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';

class AuthFirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Đăng ký bằng email & password
  Future<UserCredential> signupWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw ServerException(
        err: _mapFirebaseError(e),
        type: ServerExceptionType.auth,
      );
    } catch (e) {
      throw ServerException(err: 'Unexpected error: $e');
    }
  }

  /// Đăng nhập bằng email & password
  Future<UserCredential> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw ServerException(
        err: _mapFirebaseError(e),
        type: ServerExceptionType.auth,
      );
    } catch (e) {
      throw ServerException(err: 'Unexpected error: $e');
    }
  }

  /// Đăng nhập với Google
  Future<UserCredential> authGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw ServerException(
          err: 'Google sign-in was cancelled',
          type: ServerExceptionType.cancelled,
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw ServerException(
        err: 'Error during Google sign-in: $e',
        type: ServerExceptionType.auth,
      );
    }
  }

  /// Đăng nhập bằng số điện thoại
  Future<UserCredential?> authPhone({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String verificationId) onCodeAutoRetrievalTimeout,
    String? smsCode,
  }) async {
    UserCredential? userCredential;

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            userCredential = await _auth.signInWithCredential(credential);
            onVerificationCompleted(credential);
          } catch (e) {
            throw ServerException(
              err: 'Error during verification completed: $e',
              type: ServerExceptionType.auth,
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          onVerificationFailed(e);
          throw ServerException(
            err: _mapFirebaseError(e),
            type: ServerExceptionType.auth,
          );
        },
        codeSent: (String verificationId, int? resendToken) async {
          onCodeSent(verificationId, resendToken);
          if (smsCode != null) {
            try {
              final credential = PhoneAuthProvider.credential(
                verificationId: verificationId,
                smsCode: smsCode,
              );
              userCredential = await _auth.signInWithCredential(credential);
            } catch (e) {
              throw ServerException(
                err: 'Invalid SMS code: $e',
                type: ServerExceptionType.auth,
              );
            }
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          onCodeAutoRetrievalTimeout(verificationId);
        },
      );
    } catch (e) {
      throw ServerException(
        err: 'Phone authentication error: $e',
        type: ServerExceptionType.auth,
      );
    }

    return userCredential;
  }

  /// Lấy user hiện tại
  Future<User?> getCurrentUser() async {
    try {
      return _auth.currentUser;
    } catch (e) {
      throw ServerException(
        err: 'Error getting current user: $e',
        type: ServerExceptionType.unknown,
      );
    }
  }

  /// Reset mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw ServerException(
        err: _mapFirebaseError(e),
        type: ServerExceptionType.auth,
      );
    } catch (e) {
      throw ServerException(
        err: 'Error during password reset: $e',
        type: ServerExceptionType.unknown,
      );
    }
  }

  /// Xoá tài khoản
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      } else {
        throw ServerException(err: 'No user is currently signed in.');
      }
    } catch (e) {
      throw ServerException(
        err: 'Error during account deletion: $e',
        type: ServerExceptionType.auth,
      );
    }
  }

  /// Update profile
  Future<void> updateProfile(String displayName, String photoURL) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateProfile(displayName: displayName, photoURL: photoURL);
        await user.reload();
      } else {
        throw ServerException(err: 'No user is currently signed in.');
      }
    } catch (e) {
      throw ServerException(
        err: 'Error during profile update: $e',
        type: ServerExceptionType.auth,
      );
    }
  }

  /// Update email
  Future<void> updateEmail(String email) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateEmail(email);
        await user.reload();
      } else {
        throw ServerException(err: 'No user is currently signed in.');
      }
    } catch (e) {
      throw ServerException(
        err: 'Error during email update: $e',
        type: ServerExceptionType.auth,
      );
    }
  }

  /// Update password
  Future<void> updatePassword(String password) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(password);
        await user.reload();
      } else {
        throw ServerException(err: 'No user is currently signed in.');
      }
    } catch (e) {
      throw ServerException(
        err: 'Error during password update: $e',
        type: ServerExceptionType.auth,
      );
    }
  }

  /// Đăng xuất
  Future<void> signout() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
    } catch (e) {
      throw ServerException(
        err: 'Error during sign out: $e',
        type: ServerExceptionType.unknown,
      );
    }
  }

  /// Map lỗi FirebaseAuth sang string
  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists with that email.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Invalid password provided.';
      default:
        return e.message ?? 'Unknown FirebaseAuth error';
    }
  }
}
