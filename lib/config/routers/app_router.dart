import 'package:go_router/go_router.dart';
import 'package:job_connect/config/navigation/app_navigation.dart';
import 'package:job_connect/config/routers/chat_router.dart';
import 'package:job_connect/config/routers/recruiter_router.dart';
import 'package:job_connect/config/routers/auth_router.dart';
import 'package:job_connect/config/routers/company_router.dart';
import 'package:job_connect/config/routers/home_router.dart';
import 'package:job_connect/config/routers/job_router.dart';
import 'package:job_connect/config/routers/notification_router.dart';
import 'package:job_connect/config/routers/profile_router.dart';
import 'package:job_connect/config/routers/resume_router.dart';
import 'package:job_connect/config/routers/setting_router.dart';
import 'package:job_connect/config/routers/social_router.dart';
import 'package:job_connect/splash_screen.dart';

class RouterModule {
  RouterModule._(); // constructor private
  static final GoRouter routers = GoRouter(

    // Khi app khởi động, nó sẽ mở màn hình có đường dẫn đầu tiên.
    initialLocation: '/',
    // Danh sách các router
    routes: [
      // Router vào trang chủ
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => buildPageWithSlideTransition(SplashScreen(), state)
      ),

      // Auth
      AuthRouter.routers,

      // Home
      HomeRouter.routers,

      // Job
      JobRouter.routers,

      // Company
      CompanyRouter.routers,

      // Notification
      NotificationRouter.routers,

      // Profile
      ProfileRouter.routers,

      // Resum file
      ResumeRouter.routers,

      // Setting 
      SettingRouter.routers,

      // Social
      SocialRouter.routers,

      // Recruiter
      RecruiterRouter.routers,

      // Chat
      ChatRouter.routers,
    ],
  );
}
