import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/services/biometric_auth_service.dart';
import 'package:job_connect/features/auth/screens/login_method_screen.dart';
import 'package:job_connect/features/auth/viewmodel/auth_view_model.dart';
import 'package:job_connect/features/notifications/viewmodel/notification_view_model.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

/// Màn hình kiểm tra xác thực khi vào app
/// - Nếu chưa đăng nhập → đi đến chọn role
/// - Nếu đã đăng nhập và bật sinh trắc học → hiển thị màn hình chọn phương thức
/// - Nếu đã đăng nhập và không bật sinh trắc học → vào thẳng app
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  bool _isChecking = true;
  bool _isBiometricSupported = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    if (!mounted) return;

    try {
      final authVM = context.read<AuthViewModel>();

      // Kiểm tra đăng nhập
      await authVM.checkLoginStatus().timeout(const Duration(seconds: 5));

      // Nếu chưa đăng nhập, đi thẳng ra chọn role
      if (!authVM.isLoggedIn || authVM.idUser == null) {
        if (mounted) {
          context.go('/auth/role');
        }
        return;
      }

      // Kiểm tra thiết bị có hỗ trợ sinh trắc học không
      _isBiometricSupported = await _biometricService.isDeviceSupported();
      
      // Kiểm tra có bật sinh trắc học không
      final isBiometricEnabled = await _biometricService.isBiometricEnabled();

      if (!mounted) return;

      // Nếu bật sinh trắc học → hiển thị màn hình chọn phương thức
      if (isBiometricEnabled && _isBiometricSupported) {
        setState(() => _isChecking = false);
        // Không navigate, để hiển thị màn hình chọn phương thức
        return;
      }

      // Nếu không bật sinh trắc học → vào thẳng app
      await _navigateToApp(authVM);
    } on TimeoutException {
      if (mounted) {
        context.go('/auth/role');
      }
    } catch (e) {
      if (mounted) {
        context.go('/auth/role');
      }
    }
  }

  Future<void> _navigateToApp(AuthViewModel authVM) async {
    if (!mounted) return;

    final userVM = context.read<UserViewModel>();
    final notifVM = context.read<NotificationViewModel>();

    try {
      await userVM.getCurrentUser(authVM.idUser!).timeout(const Duration(seconds: 5));
      await notifVM.getUnreadCount(authVM.idUser!).timeout(const Duration(seconds: 5));
    } catch (e) {
      // Ignore errors, vẫn navigate
    }

    if (!mounted) return;

    final role = userVM.roleName;
    if (role?.toLowerCase() == 'candidate') {
      context.go('/home', extra: {
        'isLoggedIn': authVM.isLoggedIn,
        'idUser': authVM.idUser,
      });
    } else if (role?.toLowerCase() == 'recruiter') {
      context.go('/recruiter', extra: {
        'userAccount': userVM.currentUser,
        'isLoggedIn': authVM.isLoggedIn,
        'currentIndex': 0,
      });
    } else {
      context.go('/auth/role');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Nếu đang check, hiển thị loading
    if (_isChecking) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }

    // Nếu đã check xong và cần chọn phương thức đăng nhập
    return const LoginMethodScreen();
  }
}

