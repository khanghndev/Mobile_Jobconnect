import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/utils/string_utils.dart';
import 'package:job_connect/features/auth/viewmodel/auth_view_model.dart';
import 'package:job_connect/features/notifications/viewmodel/notification_view_model.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startSplashSequence();
  }

  void _initAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..forward();

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0),
      ),
    );
  }

  void _startSplashSequence() {
    Timer(const Duration(seconds: 3), _checkLogin);
  }

  Future<void> _checkLogin() async {
    final authVM = context.read<AuthViewModel>();
    final userVM = context.read<UserViewModel>();
    final notifVM = context.read<NotificationViewModel>();

    try {
      // Thêm timeout để tránh bị treo nếu BE không phản hồi
      await authVM.checkLoginStatus().timeout(const Duration(seconds: 5));

      if (authVM.isLoggedIn && authVM.idUser != null) {
        await userVM.getUserDetail(authVM.idUser!).timeout(const Duration(seconds: 5));
        await notifVM.getUnreadCount(authVM.idUser!).timeout(const Duration(seconds: 5));

        if (!mounted) return;

        // Kiểm tra role
        if (userVM.roleName == StringUtils.capitalize(UserRole.candidate.name)) {
          context.go(
            '/home',
            extra: {
              'isLoggedIn': authVM.isLoggedIn,
              'idUser': authVM.idUser,
            },
          );
        } else if (userVM.roleName == StringUtils.capitalize(UserRole.recruiter.name)) {
          context.go(
            '/recruiter',
            extra: {
              'userAccount': userVM.userDetail,
              'isLoggedIn': authVM.isLoggedIn,
              'currentIndex': 0,
            },
          );
        }
      } else {
        if (!mounted) return;
        context.go('/auth/role');
      }
    } on TimeoutException {
      if (!mounted) return;
      SnackbarApp.show(
        context,
        message: 'Không thể kết nối đến máy chủ, vui lòng thử lại sau.',
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
      context.go('/auth/role');
    } catch (e) {
      if (!mounted) return;
      SnackbarApp.show(
        context,
        message: 'Đã xảy ra lỗi, vui lòng thử lại.',
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
      ('Đã xảy ra lỗi, vui lòng thử lại.');
      context.go('/auth/role');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D47A1),
              const Color(0xFF1976D2),
              theme.colorScheme.primary.withValues(alpha: 0.9),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        spreadRadius: 2.r,
                        blurRadius: 15.r,
                        offset: Offset(0, 5.h),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60.r),
                    child: Image.asset(
                      AppImages.logoApp,
                      fit: BoxFit.cover,
                      width: 100.w,
                      height: 100.h,
                      errorBuilder: (_, __, ___) => DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: theme.colorScheme.surface,
                        ),
                        child: Icon(
                          Icons.business,
                          size: 70.sp,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    Text(
                      AppStrings.appName,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 5.r,
                            color: Colors.black12,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Kết nối tài năng, khai phá cơ hội",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}