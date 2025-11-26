import 'package:go_router/go_router.dart';
import 'package:job_connect/config/navigation/app_navigation.dart';
import 'package:job_connect/features/company/screens/company_detail_screen.dart';
import 'package:job_connect/features/company/screens/company_screen.dart';

class CompanyRouter  {
  CompanyRouter._();

  static final GoRoute routers = GoRoute(
    path: '/company',
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
      //   Trang công việc gần bạn
      GoRoute(
        path: 'detail',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>;
          final company = extraData['company'];
          final idUser = extraData['idUser'];
          return buildPageWithSlideTransition(
            CompanyDetailsScreen(
              company: company,
              idUser: idUser,
            ), 
            state
          );
        },
      ),

    ],
  );
}
