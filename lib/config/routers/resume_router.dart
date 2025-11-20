import 'package:go_router/go_router.dart';
import 'package:job_connect/config/navigation/app_navigation.dart';
import 'package:job_connect/features/resume/screens/create_cv_screen.dart';
import 'package:job_connect/features/resume/screens/cv_analysis_screen.dart';
import 'package:job_connect/features/resume/screens/cv_management_screen.dart';
import 'package:job_connect/features/resume/screens/cv_options_screen.dart';
import 'package:job_connect/features/resume/screens/cv_preview_screen.dart';
import 'package:job_connect/features/resume/screens/cv_templates_screen.dart';
import 'package:job_connect/features/resume/screens/edit_cv_screen.dart';
import 'package:job_connect/features/resume/screens/file_viewer_screen.dart';

class ResumeRouter  {
  ResumeRouter._();

  static final GoRoute routers = GoRoute(
    path: '/resume',
    pageBuilder: (context, state) {
      final extraData = state.extra as Map<String, dynamic>;
      final idUser = extraData['idUser'];
      final isLoggedIn = extraData['isLoggedIn'];
      return buildPageWithSlideTransition(
        CVOptionsScreen(
          idUser: idUser,
          isLoggedIn: isLoggedIn
        ), 
        state
      );
    },
    routes: [
      // TODO: Trang file của bạn
      GoRoute(
        path: 'file',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final fileUrl = extraData['fileUrl'];
          final fileName = extraData['fileName'];
          return buildPageWithSlideTransition(
            FileViewerScreen(
              fileUrl: fileUrl,
              fileName: fileName,
            ),
            state
          );
        },
      ),

      GoRoute(
        path: 'template',
        pageBuilder: (context, state) {
          return buildPageWithSlideTransition(
            CVTemplatesScreen(),
            state
          );
        },
      ),

      GoRoute(
        path: 'create',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final template = extraData['template'];
          return buildPageWithSlideTransition(
            CreateCVScreen(
              template: template,
            ),
            state
          );
        },
      ),

      GoRoute(
        path: 'update',
        pageBuilder: (context, state) {
          return buildPageWithSlideTransition(
            EditCvScreen(
            ),
            state
          );
        },
      ),

      GoRoute(
        path: 'managent',
        pageBuilder: (context, state) {
          return buildPageWithSlideTransition(
            CvManagementScreen(
            ),
            state
          );
        },
      ),

      GoRoute(
        path: 'preview',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final templateId = extraData['templateId'];
          final cvData = extraData['cvData'];
          return buildPageWithSlideTransition(
            CVPreviewScreen(
              cvData: cvData,
              templateId: templateId,
            ),
            state
          );
        },
      ),

      GoRoute(
        path: 'analysis',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final idUser = extraData['idUser'];
          return buildPageWithSlideTransition(
            CvAnalysisScreen(
              idUser: idUser
            ),
            state
          );
        },
      ),
    ],
  );
}
