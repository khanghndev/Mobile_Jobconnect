import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/navigation/app_navigation.dart';
import 'package:job_connect/features/auth/screens/enter_otp_page.dart';
import 'package:job_connect/features/auth/screens/forgot_password_screen.dart';
import 'package:job_connect/features/auth/screens/login_screen.dart';
import 'package:job_connect/features/auth/screens/register_screen.dart';
import 'package:job_connect/features/auth/screens/reset_password_screen.dart';

class AuthRouter {
  AuthRouter._();

  static final GoRoute routers = GoRoute(
    path: '/auth',
    pageBuilder: (context, state) =>
        buildPageWithSlideTransition(SizedBox(), state),
    routes: [
      GoRoute(
        path: 'login',
        pageBuilder: (context, state) =>
            buildPageWithSlideTransition(LoginScreen(), state),
      ),
      GoRoute(
        path: 'signup',
        pageBuilder: (context, state) =>
            buildPageWithSlideTransition(RegisterScreen(), state),
      ),
      GoRoute(
        path: 'enter-otp',
        pageBuilder: (context, state) {
          final extraData = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : {};
          return buildPageWithSlideTransition(
            EnterOtpPage(
              title: extraData['title'] ?? '',
              email: extraData['email'] ?? '',
            ),
            state,
          );
        },
      ),
      GoRoute(
        path: 'forgot-pass',
        pageBuilder: (context, state) {
          return buildPageWithSlideTransition(
            ForgotPasswordScreen(),
            state,
          );
        },
      ),
      GoRoute(
        path: 'reset-pass',
        pageBuilder: (context, state) {
          return buildPageWithSlideTransition(
              ResetPasswordScreen(), state);
        },
      ),
    ],
  );
}
