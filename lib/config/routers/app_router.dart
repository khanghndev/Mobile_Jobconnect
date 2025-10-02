import 'package:go_router/go_router.dart';
import 'package:job_connect/config/navigation/app_navigation.dart';
import 'package:job_connect/config/routers/auth_router.dart';
import 'package:job_connect/config/routers/home_router.dart';
import 'package:job_connect/features/auth/screens/login_screen.dart';
import 'package:job_connect/features/mini_social/screens/messeger/social_call_screen.dart';
import 'package:job_connect/features/mini_social/screens/messeger/social_messenger_detail_screen.dart';
import 'package:job_connect/features/mini_social/screens/post/social_create_post_screen.dart';
import 'package:job_connect/features/mini_social/screens/social_connects_page.dart';
import 'package:job_connect/features/mini_social/screens/group/social_group_screen.dart';
import 'package:job_connect/features/mini_social/screens/report/social_help_screen.dart';
import 'package:job_connect/features/mini_social/screens/job_board/social_job_board_page.dart';
import 'package:job_connect/features/mini_social/screens/social_profile_screen.dart';
import 'package:job_connect/features/mini_social/screens/report/social_report_post_screem.dart';
import 'package:job_connect/features/mini_social/screens/report/social_scam_check_post_screen.dart';
import 'package:job_connect/features/search/screens/search_screen.dart';

class RouterModule {
  RouterModule._(); // constructor private
  static final GoRouter routers = GoRouter(

    // Khi app khởi động, nó sẽ mở màn hình có đường dẫn đầu tiên.
    initialLocation: '/',
    // danh sách các route
    routes: [
      // Router vào trang chủ
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => buildPageWithSlideTransition(LoginScreen(), state)
      ),

      // Auth
      AuthRouter.routers,

      // Home
      HomeRouter.routers,
      // Search
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final isLoggedIn = extraData['isLoggedIn'];
          final idUser = extraData['idUser'];
            return buildPageWithSlideTransition(SearchPage(
            isLoggedIn: isLoggedIn,
            idUser: idUser,
          ), 
          state
          );}
        ),

       GoRoute(
        path: '/job-board',
        pageBuilder: (context, state) => buildPageWithSlideTransition(JobBoardPage(), state)
      ),

      GoRoute(
        path: '/create-post',
        pageBuilder: (context, state) => buildPageWithSlideTransition(CreatePostScreen(), state)
      ),

      GoRoute(
        path: '/connections',
        pageBuilder: (context, state) => buildPageWithSlideTransition(ConnectsPage(), state)
      ),

      GoRoute(
        path: '/help',
        pageBuilder: (context, state) => buildPageWithSlideTransition(HelpScreen(), state)
      ),

      GoRoute(
        path: '/report',
        pageBuilder: (context, state) => buildPageWithSlideTransition(ReportPostScreen(
          userName: 'aaa',
          authorName: 'bbb',
        ), state)
      ),

      GoRoute(
        path: '/check',
        pageBuilder: (context, state) => buildPageWithSlideTransition(ScamCheckPostScreen(), state)
      ),

      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => buildPageWithSlideTransition(SocialProfileScreen(), state)
      ),

      GoRoute(
        path: '/group',
        pageBuilder: (context, state) => buildPageWithSlideTransition(GroupScreen(), state)
      ),
      
      // Messenger
      GoRoute(
        path: '/messenger-detail',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final isLoggedIn = extraData['isLoggedIn'];
          final idUser = extraData['idUser'];
          return buildPageWithSlideTransition(SocialMessengerDetailScreen(
            isLoggedIn: isLoggedIn,
            idUser: idUser,
          )
          , state);
        }
      ),
      // Messenger
      GoRoute(
        path: '/call',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final avatarUrl = extraData['avatarUrl'];
          final userName = extraData['userName'];
          return buildPageWithSlideTransition(SocialCallScreen(
            userName: userName,
            avatarUrl: avatarUrl,
          )
          , state);
        }
      ),
    ],
  );
}
