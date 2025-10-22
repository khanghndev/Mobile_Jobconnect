import 'package:go_router/go_router.dart';
import 'package:job_connect/config/navigation/app_navigation.dart';
import 'package:job_connect/recruiter_app/features/hr/screens/hr_home_screen.dart';
import 'package:job_connect/recruiter_app/features/job/navigation_recruiter/screen/navigation_recruiter_screen.dart';

class RecruiterRouter  {
  RecruiterRouter._();

  static final GoRoute routers = GoRoute(
    path: '/recruiter',
    pageBuilder: (context, state) {
      final extraData = state.extra as Map<String, dynamic>;
      final isLoggedIn = extraData['isLoggedIn'];
      final userAccount = extraData['userAccount'];
      final currentIndex = extraData['currentIndex'];
      return buildPageWithSlideTransition(
        NavigationRecruiterScreen(
          isLoggedIn: isLoggedIn,
          userAccount: userAccount,
          currentIndex: currentIndex,
        ), 
        state
      );
    },
    routes: [
      // TODO: Trang home recruiter
      GoRoute(
        path: 'home',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final userAccount = extraData['userAccount'];
          return buildPageWithSlideTransition(
            HRHomeScreen(
              userAccount: userAccount,
            ), 
            state
          );
        },
      ),

    ],
  );
}
