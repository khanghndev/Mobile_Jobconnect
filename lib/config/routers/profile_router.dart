import 'package:go_router/go_router.dart';
import 'package:job_connect/config/navigation/app_navigation.dart';
import 'package:job_connect/features/profile/screens/edit_profile_screen.dart';
import 'package:job_connect/features/profile/screens/profile_screen.dart';

class ProfileRouter  {
  ProfileRouter._();

  static final GoRoute routers = GoRoute(
    path: '/profile',
    pageBuilder: (context, state) {
      final extraData = state.extra as Map<String, dynamic>;
      final idUser = extraData['idUser'];
      final isLoggedIn = extraData['isLoggedIn'];
      return buildPageWithSlideTransition(
        ProfilePageScreen(
          idUser: idUser,
          isLoggedIn: isLoggedIn,
        ), 
        state
      );
    },
    routes: [
      //   Trang profie 
      GoRoute(
        path: 'edit',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final idUser = extraData['idUser'];
          return buildPageWithSlideTransition(
            EditProfilePage(
              idUser: idUser,
            ), 
            state
          );
        },
      ),

    ],
  );
}
