import 'package:go_router/go_router.dart';
import 'package:job_connect/config/navigation/app_navigation.dart';
import 'package:job_connect/features/job/screens/apply_job_screen.dart';
import 'package:job_connect/features/job/screens/job_application_detail_screen.dart';
import 'package:job_connect/features/job/screens/job_detail_screen.dart';
import 'package:job_connect/features/job/screens/job_history_screen.dart';
import 'package:job_connect/features/job/screens/job_matching_screen.dart';
import 'package:job_connect/features/job/screens/saved_jobs_screen.dart';
import 'package:job_connect/features/search/screens/search_screen.dart';

class JobRouter {
  JobRouter._();

  static final GoRoute routers = GoRoute(
    path: '/job',
    pageBuilder: (context, state) {
      final extraData = state.extra as Map<String, dynamic>;
      final isLoggedIn = extraData['isLoggedIn'];
      final idUser = extraData['idUser'];
      return buildPageWithSlideTransition(
        SearchPage(
          isLoggedIn: isLoggedIn,
          idUser: idUser,
        ), 
        state
      );
    },
    routes: [
      // TODO: Trang công việc chi tiết
      GoRoute(
        path: 'detail',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final jobPosting = extraData['jobPosting'];
          final idUser = extraData['idUser'];
          return buildPageWithSlideTransition(
            JobDetailScreen(
              jobPosting: jobPosting,
              idUser: idUser,
            ), 
            state
          );
        },
      ),

      // TODO: Trang công việc đã lưu
      GoRoute(
        path: 'saved',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final idUser = extraData['idUser'];
          return buildPageWithSlideTransition(
            SavedJobsScreen(
              idUser : idUser,
            ),
            state
          );
        },
      ),

      GoRoute(
        path: 'matching',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final idUser = extraData['idUser'];
          return buildPageWithSlideTransition(
            JobMatchingScreen(
              idUser : idUser,
            ),
            state
          );
        },
      ),

      GoRoute(
        path: 'history',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final idUser = extraData['idUser'];
          return buildPageWithSlideTransition(
            JobHistoryScreen(
              idUser : idUser,
            ),
            state
          );
        },
      ),

      GoRoute(
        path: 'apply',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final jobId = extraData['jobId'];
          final idUser = extraData['idUser'];
          final jobTitle = extraData['jobTitle'];
          final companyName = extraData['companyName'];
          return buildPageWithSlideTransition(
            ApplyJobScreen(
              jobId: jobId,
              jobTitle: jobTitle,
              companyName: companyName,
              idUser : idUser,
            ),
            state
          );
        },
      ),

      GoRoute(
        path: 'apply-detail',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final idUser = extraData['idUser'];
          final idJobPost = extraData['idJobPost'];
          return buildPageWithSlideTransition(
            JobApplicationDetailScreen(
              idUser : idUser,
              idJobPost: idJobPost,
            ),
            state
          );
        },
      ),

    ],
  );
}
