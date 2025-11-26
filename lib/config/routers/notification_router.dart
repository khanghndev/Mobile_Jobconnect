import 'package:go_router/go_router.dart';
import 'package:job_connect/config/navigation/app_navigation.dart';
import 'package:job_connect/features/notifications/model/notification_model.dart';
import 'package:job_connect/features/notifications/screens/notification_detail_screen.dart';
import 'package:job_connect/features/notifications/screens/notification_screen.dart';

class NotificationRouter  {
  NotificationRouter._();

  static final GoRoute routers = GoRoute(
    path: '/notification',
    pageBuilder: (context, state) {
      final extraData = state.extra as Map<String, dynamic>;
      final idUser = extraData['idUser'];
      return buildPageWithSlideTransition(
        NotificationScreen(
          idUser: idUser,
        ), 
        state
      );
    },
    routes: [
      //   Trang công việc gần bạn
      GoRoute(
        path: 'detail',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final notification = extraData['notification'] as NotificationModel;
          final iconData = extraData['iconData'];
          final iconColor = extraData['iconColor'];
          return buildPageWithSlideTransition(
            NotificationDetailScreen(
              notification: notification,
              iconData: iconData,
              iconColor: iconColor,
            ),
            state
          );
        },
      ),

    ],
  );
}
