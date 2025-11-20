import 'package:go_router/go_router.dart';
import 'package:job_connect/config/navigation/app_navigation.dart';
import 'package:job_connect/features/company/screens/company_screen.dart';
import 'package:job_connect/features/home/screens/nearby_jobs_map_screen.dart';
import 'package:job_connect/features/home/screens/podcast_screen.dart';
import 'package:job_connect/features/home/screens/smart_schedule_request_screen.dart';
import 'package:job_connect/features/home/screens/smart_schedule_screen.dart';
import 'package:job_connect/features/navigation/screens/navigation_page.dart';
import 'package:job_connect/features/resume/screens/cv_options_screen.dart';
import 'package:job_connect/features/search/screens/search_screen.dart';

class HomeRouter {
  HomeRouter._();

  static final GoRoute routers = GoRoute(
    path: '/home',
    pageBuilder: (context, state) {
      final extraData = state.extra as Map<String, dynamic>;
      final isLoggedIn = extraData['isLoggedIn'];
      final idUser = extraData['idUser'];
      return buildPageWithSlideTransition(
        NavigationPage(
          isLoggedIn: isLoggedIn,
          idUser: idUser,
        ), 
        state
      );
    },
    routes: [
      // TODO: Trang công việc gần bạn
      GoRoute(
        path: 'near-job',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final isLoggedIn = extraData['isLoggedIn'];
          final idUser = extraData['idUser'];
          return buildPageWithSlideTransition(
            NearbyJobsMapScreen(
              isLoggedIn: isLoggedIn,
              idUser: idUser,
            ), 
            state
          );
        },
      ),

      // TODO: Trang các doanh nghiệp
      GoRoute(
        path: 'company',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final idUser = extraData['idUser'];
          return buildPageWithSlideTransition(
            CompanyScreen(
              idUser: idUser,
            ), 
            state
          );
        },
      ),

      // TODO: Trang tìm kiếm công việc
      GoRoute(
        path: 'search',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final isLoggedIn = extraData['isLoggedIn'];
          final idUser = extraData['idUser'];
          final initialTabIndex = extraData['initialTabIndex'];
          return buildPageWithSlideTransition(
            SearchScreen(
              isLoggedIn: isLoggedIn,
              idUser: idUser,
              initialTabIndex: initialTabIndex
            ), 
          state
          );
        }
      ),

      // TODO: Trang podcast
      GoRoute(
        path: 'podcast',
        pageBuilder: (context, state) {
          return buildPageWithSlideTransition(
            PodcastScreen(),
            state
          );
        },
      ),

      GoRoute(
        path: 'cv',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final isLoggedIn = extraData['isLoggedIn'];
          final idUser = extraData['idUser'];
          return buildPageWithSlideTransition(
            CVOptionsScreen(
              isLoggedIn: isLoggedIn,
              idUser: idUser,
            ), 
            state
          );
        },
      ),

      GoRoute(
        path: 'smart-shedule',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final userId = extraData['userId'];
          return buildPageWithSlideTransition(
            SmartScheduleScreen(
              userId: userId,
            ), 
            state
          );
        },
      ),

      GoRoute(
        path: 'request-smart-shedule',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final schedule = extraData['schedule'];
          return buildPageWithSlideTransition(
            SmartScheduleResultScreen(
              schedule: schedule,
            ), 
            state
          );
        },
      ),
    ],
  );
}
