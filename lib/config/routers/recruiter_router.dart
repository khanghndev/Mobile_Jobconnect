import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/navigation/app_navigation.dart';
import 'package:job_connect/recruiter_app/features/candidate/screens/hr_candidate_management_screen.dart';
import 'package:job_connect/recruiter_app/features/hr/screen/hr_home_screen.dart';
import 'package:job_connect/recruiter_app/features/interview/screens/hr_calendar_interview_schedule.dart';
import 'package:job_connect/recruiter_app/features/job/navigation_recruiter/screen/navigation_recruiter_screen.dart';
import 'package:job_connect/recruiter_app/features/report/screens/hr_report_screen.dart';
import 'package:job_connect/recruiter_app/features/search/screens/hr_search_screen.dart';
import 'package:job_connect/recruiter_app/features/job/screens/hr_jobs_dashboard_screen.dart';

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
      //  Trang chủ
      GoRoute(
        path: 'home',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final userAccount = extraData['userAccount'];
          return buildPageWithSlideTransition(
            HrHomeScreen(userAccount: userAccount),
            state,
          );
        },
      ),

      //  Tìm kiếm ứng viên
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

      //  Quản lý ứng viên
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

      //  Danh sách công việc - Dashboard
      GoRoute(
        path: 'jobs',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>?;
          final idUser = extraData?['idUser'] as String? ?? '';
          return buildPageWithSlideTransition(
            HrJobsDashboardScreen(
              idUser: idUser,
            ),
            state,
          );
        },
      ),

      //  Báo cáo
      GoRoute(
        path: 'report',
        pageBuilder: (context, state) {
          debugPrint('🔵 Report route - state.extra type: ${state.extra.runtimeType}');
          debugPrint('🔵 Report route - state.extra: ${state.extra}');
          debugPrint('🔵 Report route - state.uri: ${state.uri}');
          debugPrint('🔵 Report route - state.fullPath: ${state.fullPath}');
          
          Map<String, dynamic>? extraData;
          if (state.extra != null) {
            if (state.extra is Map<String, dynamic>) {
              extraData = state.extra as Map<String, dynamic>;
            } else {
              debugPrint('❌ Report route - state.extra is not Map<String, dynamic>');
            }
          } else {
            debugPrint('❌ Report route - state.extra is null');
          }
          
          debugPrint('🔵 Report route - extraData: $extraData');
          final recruiterId = extraData?['idUser'] as String?;
          final companyId = extraData?['companyId'] as String?;
          debugPrint('🔵 Report route - recruiterId: $recruiterId, companyId: $companyId');
          
          return buildPageWithSlideTransition(
            HrReportScreen(
              recruiterId: recruiterId,
              companyId: companyId,
            ),
            state,
          );
        },
      ),

      //  Lịch phỏng vấn
      GoRoute(
        path: 'interview-schedules',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final idUser = extraData['idUser'];
          final interviews = extraData['interviews'];
          final jobPostingsList = extraData['jobPostingsList'];
          return buildPageWithSlideTransition(
            HrCalendarInterviewSchedule(
              interviews: interviews,
              idUser: idUser,
              jobPostingsList: jobPostingsList,
            ),
            state,
          );
        },
      ),
    ],
  );
}