import 'package:go_router/go_router.dart';
import 'package:job_connect/config/navigation/app_navigation.dart';
import 'package:job_connect/features/chat/screens/ai_chat_screen.dart';
import 'package:job_connect/features/company/screens/company_screen.dart';

class ChatRouter  {
  ChatRouter._();

  static final GoRoute routers = GoRoute(
    path: '/chat',
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
    routes: [
      // TODO: Trang công việc gần bạn
      GoRoute(
        path: 'ai',
        pageBuilder: (context, state) {
          return buildPageWithSlideTransition(
            AIChatScreen(), 
            state
          );
        },
      ),

    ],
  );
}
