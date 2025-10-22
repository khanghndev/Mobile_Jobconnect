import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/navigation/app_navigation.dart';
import 'package:job_connect/features/auth/screens/enter_otp_page.dart';
import 'package:job_connect/features/auth/screens/forgot_password_screen.dart';
import 'package:job_connect/features/auth/screens/login_screen.dart';
import 'package:job_connect/features/auth/screens/register_screen.dart';
import 'package:job_connect/features/auth/screens/reset_password_screen.dart';
import 'package:job_connect/features/auth/screens/role_selection_screen.dart';

class AuthRouter {
  AuthRouter._();

  static final GoRoute routers = GoRoute(
    path: '/auth',
    pageBuilder: (context, state) =>
        buildPageWithSlideTransition(SizedBox(), state),
    routes: [
      GoRoute(
        path: 'role',
        pageBuilder: (context, state) => buildPageWithSlideTransition(RoleSelectionScreen(), state)
      ),
      
      GoRoute(
        path: 'login',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final role = extraData['role'] ?? '';
          return buildPageWithSlideTransition(
            LoginScreen(
              role: role
            ), 
            state
          );
        }
            
      ),
      GoRoute(
        path: 'signup',
        pageBuilder: (context, state) =>buildPageWithSlideTransition(RegisterScreen(), state),
      ),
      GoRoute(
        path: 'enter-otp',
        pageBuilder: (context, state) {
          final extraData = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : {};
          final title = extraData['title'] ?? '';
          final email = extraData['email'] ?? '';
          return buildPageWithSlideTransition(
            EnterOtpPage(
              title: title,
              email: email,
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
