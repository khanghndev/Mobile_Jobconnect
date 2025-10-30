import 'package:go_router/go_router.dart';
import 'package:job_connect/config/navigation/app_navigation.dart';
import 'package:job_connect/recruiter_app/features/candidate/screens/hr_candidate_management_screen.dart';
import 'package:job_connect/recruiter_app/features/hr/screens/hr_home_screen.dart';
import 'package:job_connect/recruiter_app/features/hr/screens/hr_interview_schedule.dart';
import 'package:job_connect/recruiter_app/features/job/navigation_recruiter/screen/navigation_recruiter_screen.dart';
import 'package:job_connect/recruiter_app/features/report/screens/hr_report_screen.dart';
import 'package:job_connect/recruiter_app/features/search/screens/hr_search_screen.dart';
import 'package:job_connect/recruiter_app/features/post/screens/hr_post_job_screen.dart';

class RecruiterRouter {
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
        state,
      );
    },
    routes: [
      //TODO: Trang chủ
      GoRoute(
        path: 'home',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final userAccount = extraData['userAccount'];
          return buildPageWithSlideTransition(
            HRHomeScreen(userAccount: userAccount),
            state,
          );
        },
      ),

      //TODO: Tìm kiếm ứng viên
      GoRoute(
        path: 'search-candidate',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final recruiterId = extraData['recruiterId'];
          return buildPageWithSlideTransition(
            HrSearchScreen(recruiterId: recruiterId),
            state,
          );
        },
      ),

      //TODO: Quản lý ứng viên
      GoRoute(
        path: 'candidates-management',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final recruiterId = extraData['recruiterId'];
          return buildPageWithSlideTransition(
            HrCandidateManagementScreen(
              recruiterId: recruiterId
            ),
            state,
          );
        },
      ),

      //TODO: Danh sách công việc
      GoRoute(
        path: 'jobs',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final idUser = extraData['idUser'];
          return buildPageWithSlideTransition(
            HrPostJobScreen(
              recruiterId: idUser
            ),
            state,
          );
        },
      ),

      //TODO: Báo cáo
      GoRoute(
        path: 'report',
        pageBuilder: (context, state) {
          return buildPageWithSlideTransition(
            HrReportScreen(),
            state,
          );
        },
      ),

      //TODO: Lịch phỏng vấn
      GoRoute(
        path: 'interview-schedules',
        pageBuilder: (context, state) {
          return buildPageWithSlideTransition(
            HrInterviewSchedule(),
            state,
          );
        },
      ),
    ],
  );
}