import 'package:go_router/go_router.dart';
import 'package:job_connect/config/navigation/app_navigation.dart';
import 'package:job_connect/features/job/screens/apply_job_screen.dart';
import 'package:job_connect/features/job/screens/apply_job_success_screen.dart';
import 'package:job_connect/features/job/screens/job_application_detail_screen.dart';
import 'package:job_connect/features/job/screens/job_detail_screen.dart';
import 'package:job_connect/features/job/screens/job_history_screen.dart';
import 'package:job_connect/features/job/screens/job_matching_screen.dart';
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
        SearchScreen(
          isLoggedIn: isLoggedIn,
          idUser: idUser,
        ), 
        state
      );
    },
    routes: [
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

      GoRoute(
        path: 'apply-success',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final jobTitle = extraData['jobTitle'];
          final companyName = extraData['companyName'];
          final cvName = extraData['cvName'];
          final idUser = extraData['idUser'];
          return buildPageWithSlideTransition(
            ApplyJobSuccessScreen(
              jobTitle: jobTitle,
              companyName: companyName,
              cvName: cvName,
              idUser: idUser,
            ),
            state
          );
        },
      ),

    ],
  );
}
