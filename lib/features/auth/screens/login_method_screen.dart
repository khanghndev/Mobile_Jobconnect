import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/services/biometric_auth_service.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/features/auth/viewmodel/auth_view_model.dart';
import 'package:job_connect/features/notifications/viewmodel/notification_view_model.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

/// Màn hình chọn phương thức đăng nhập
/// - Đăng nhập bằng mật khẩu
/// - Đăng nhập bằng sinh trắc học
class LoginMethodScreen extends StatefulWidget {
  const LoginMethodScreen({super.key});

  @override
  State<LoginMethodScreen> createState() => _LoginMethodScreenState();
}

class _LoginMethodScreenState extends State<LoginMethodScreen> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  bool _isAuthenticating = false;
  String _biometricTypeName = 'Sinh trắc học';

  @override
  void initState() {
    super.initState();
    _loadBiometricInfo();
  }

  Future<void> _loadBiometricInfo() async {
    final name = await _biometricService.getPrimaryBiometricName();
    if (mounted) {
      setState(() {
        _biometricTypeName = name;
      });
    }
  }

  /// Đăng nhập bằng sinh trắc học
  Future<void> _loginWithBiometric() async {
    if (_isAuthenticating) return;

    setState(() => _isAuthenticating = true);

    try {
      // Kiểm tra xem đã có session hợp lệ chưa (silent mode để tránh notifyListeners)
      final authVM = context.read<AuthViewModel>();
      await authVM.checkLoginStatus(silent: true);

      // Nếu đã đăng nhập và có session hợp lệ → chỉ cần xác thực sinh trắc học
      if (authVM.isLoggedIn && authVM.idUser != null) {
        // Xác thực bằng sinh trắc học
        final authenticated = await _biometricService.authenticate(
          reason: 'Sử dụng $_biometricTypeName để mở khóa ứng dụng',
          useErrorDialogs: true,
          stickyAuth: true,
        );

        if (!authenticated) {
          if (mounted) {
            setState(() => _isAuthenticating = false);
          }
          return;
        }

        // Đã xác thực thành công → vào thẳng app
        if (mounted) {
          await _navigateToApp(authVM);
        }
        return;
      }

      // Nếu chưa có session → cần đăng nhập lại bằng mật khẩu
      final email = await _biometricService.getSavedEmail();
      
      if (email == null || email.isEmpty) {
        if (mounted) {
          setState(() => _isAuthenticating = false);
          SnackbarApp.show(
            context,
            title: 'Thông báo',
            message: 'Chưa có thông tin đăng nhập. Vui lòng đăng nhập bằng mật khẩu để lưu thông tin.',
            backgroundColor: BackgroundColors.backgroundWarningPrimary,
          );
          // Đi đến login screen
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            await _goToPasswordLogin();
          }
        }
        return;
      }

      // Xác thực bằng sinh trắc học
      final authenticated = await _biometricService.authenticate(
        reason: 'Sử dụng $_biometricTypeName để đăng nhập',
        useErrorDialogs: true,
        stickyAuth: true,
      );

      if (!authenticated) {
        if (mounted) {
          setState(() => _isAuthenticating = false);
        }
        return;
      }

      // Hiển thị dialog để nhập password
      if (mounted) {
        _showPasswordDialog(email);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAuthenticating = false);
        SnackbarApp.show(
          context,
          title: 'Lỗi',
          message: e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: BackgroundColors.backgroundErrorPrimary,
        );
      }
    }
  }

  /// Điều hướng vào app sau khi xác thực thành công
  Future<void> _navigateToApp(AuthViewModel authVM) async {
    if (!mounted) return;

    final userVM = context.read<UserViewModel>();
    final notificationVM = context.read<NotificationViewModel>();

    try {
      await userVM.getCurrentUser(authVM.idUser!).timeout(const Duration(seconds: 5));
      await notificationVM.getUnreadCount(authVM.idUser!).timeout(const Duration(seconds: 5));
    } catch (e) {
      // Ignore errors, vẫn navigate
    }

    if (!mounted) return;

    final role = userVM.roleName?.trim().toLowerCase();
    
    if (role == 'candidate') {
      context.go('/home', extra: {
        'isLoggedIn': authVM.isLoggedIn,
        'idUser': authVM.idUser,
      });
    } else if (role == 'recruiter') {
      context.go('/recruiter', extra: {
        'userAccount': userVM.currentUser,
        'isLoggedIn': authVM.isLoggedIn,
        'currentIndex': 0,
      });
    } else {
      context.go('/auth/role');
    }

    if (mounted) {
      setState(() => _isAuthenticating = false);
      SnackbarApp.show(
        context,
        title: 'Thông báo',
        message: 'Đăng nhập thành công',
        backgroundColor: BackgroundColors.backgroundSuccessPrimary,
      );
    }
  }

  /// Hiển thị dialog để nhập password
  void _showPasswordDialog(String email) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(
              Icons.fingerprint_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 28.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                'Xác thực thành công',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vui lòng nhập mật khẩu để hoàn tất đăng nhập',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _handleLogin(email, passwordController.text, formKey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _isAuthenticating = false);
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => _handleLogin(email, passwordController.text, formKey),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: const Text('Đăng nhập'),
          ),
        ],
      ),
    );
  }

  /// Xử lý đăng nhập với email và password
  Future<void> _handleLogin(String email, String password, GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;

    Navigator.of(context).pop(); // Đóng dialog

    final authVM = context.read<AuthViewModel>();
    
    // Đăng nhập
    await authVM.loginWithEmail(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (authVM.errorMessage != null) {
      setState(() => _isAuthenticating = false);
      SnackbarApp.show(
        context,
        title: "Thất bại",
        message: authVM.errorMessage ?? "Đăng nhập thất bại.",
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
      return;
    }

    if (authVM.idUser != null) {
      final idUser = authVM.idUser!;
      final userVM = context.read<UserViewModel>();
      final notificationVM = context.read<NotificationViewModel>();

      await userVM.getCurrentUser(idUser);
      await notificationVM.getUnreadCount(idUser);

      if (!mounted) return;

      final role = userVM.roleName?.trim().toLowerCase();
      
      if (role == 'candidate') {
        context.go('/home', extra: {
          'isLoggedIn': authVM.isLoggedIn,
          'idUser': idUser,
        });
      } else if (role == 'recruiter') {
        context.go('/recruiter', extra: {
          'userAccount': userVM.currentUser,
          'isLoggedIn': authVM.isLoggedIn,
          'currentIndex': 0,
        });
      } else {
        context.go('/auth/role');
      }

      // Lưu email vào secure storage để lần sau sử dụng
      try {
        final isBiometricEnabled = await _biometricService.isBiometricEnabled();
        if (isBiometricEnabled && email.isNotEmpty) {
          await _biometricService.saveCredentials(email);
        }
      } catch (e) {
        // Ignore errors when saving credentials
        print('[DEBUG] Error saving credentials: $e');
      }

      if (mounted) {
        SnackbarApp.show(
          context,
          title: 'Thông báo',
          message: 'Đăng nhập thành công',
          backgroundColor: BackgroundColors.backgroundSuccessPrimary,
        );
      }
    }
  }

  /// Đi đến màn hình đăng nhập bằng mật khẩu
  Future<void> _goToPasswordLogin() async {
    // Lấy email đã lưu để điền sẵn
    final savedEmail = await _biometricService.getSavedEmail();
    
    context.push('/auth/login', extra: {
      'prefillEmail': savedEmail ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.primary.withValues(alpha: 0.8),
                theme.colorScheme.secondary.withValues(alpha: 0.6),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 120.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20.r,
                          spreadRadius: 2.r,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(60.r),
                      child: Image.asset(
                        AppImages.logoApp,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.business,
                          size: 60.sp,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  
                  // Title
                  Text(
                    'Chào mừng trở lại!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Chọn phương thức đăng nhập',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  SizedBox(height: 48.h),

                  // Button đăng nhập bằng sinh trắc học
                  _buildBiometricButton(theme),
                  SizedBox(height: 16.h),

                  // Button đăng nhập bằng mật khẩu
                  _buildPasswordButton(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isAuthenticating ? null : _loginWithBiometric,
        icon: _isAuthenticating
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(
                _biometricTypeName.contains('Face') 
                    ? Icons.face_rounded 
                    : Icons.fingerprint_rounded,
                size: 24.sp,
              ),
        label: Text(
          _isAuthenticating 
              ? 'Đang xác thực...' 
              : 'Đăng nhập bằng $_biometricTypeName',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: theme.colorScheme.primary,
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  Widget _buildPasswordButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _goToPasswordLogin,
        icon: Icon(Icons.lock_outline, size: 24.sp),
        label: Text(
          'Đăng nhập bằng mật khẩu',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white, width: 2.w),
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }
}

