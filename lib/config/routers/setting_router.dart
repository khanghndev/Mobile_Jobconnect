import 'package:go_router/go_router.dart';
import 'package:job_connect/config/navigation/app_navigation.dart';
import 'package:job_connect/features/help/screens/help_screen.dart';
import 'package:job_connect/features/payments/screens/payment_screen.dart';
import 'package:job_connect/features/settings/screens/about_screen.dart';
import 'package:job_connect/features/settings/screens/privacy_screen.dart';
import 'package:job_connect/features/settings/screens/security_screen.dart';
import 'package:job_connect/features/settings/screens/settings_screen.dart';

class SettingRouter {
  SettingRouter._();

  static final GoRoute routers = GoRoute(
    path: '/setting',
    pageBuilder: (context, state) {
      final extraData = state.extra as Map<String, dynamic>;
      final isLoggedIn = extraData['isLoggedIn'];
      final idUser = extraData['idUser'];
      return buildPageWithSlideTransition(
          SettingScreen(
          isLoggedIn: isLoggedIn, 
          idUser: idUser
        ),
        state
      );
    },
    routes: [

      // TODO: Trang giúp đỡ
      GoRoute(
        path: 'help',
        pageBuilder: (context, state) {
          return buildPageWithSlideTransition(
            HelpScreen(),
            state
          );
        },
      ),

      // TODO: Trang chính sách
      GoRoute(
        path: 'policy',
        pageBuilder: (context, state) {
          return buildPageWithSlideTransition(
            PrivacyScreen(),
            state
          );
        },
      ),

      // TODO: Trang về chúng tôi
      GoRoute(
        path: 'about',
        pageBuilder: (context, state) {
          return buildPageWithSlideTransition(
            AboutScreen(),
            state
          );
        },
      ),

      // TODO: Trang bảo mật
      GoRoute(
        path: 'payment',
        pageBuilder: (context, state) {
          return buildPageWithSlideTransition(
            PaymentPage(),
            state
          );
        },
      ),

      // TODO: Trang bảo mật
      GoRoute(
        path: 'security',
        pageBuilder: (context, state) {
          return buildPageWithSlideTransition(
            SecurityScreen(),
            state
          );
        },
      ),
    ],
  );
}
