import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/navigation/app_navigation.dart';
import 'package:job_connect/features/mini_social/screens/home/social_profile_screen.dart';
import 'package:job_connect/features/mini_social/screens/home/social_search_screen.dart';
import 'package:job_connect/features/mini_social/screens/messeger/social_call_screen.dart';
import 'package:job_connect/features/mini_social/screens/messeger/social_messenger_detail_screen.dart';
import 'package:job_connect/features/mini_social/screens/post/social_create_post_screen.dart';
import 'package:job_connect/features/mini_social/screens/group/social_connects_page.dart';
import 'package:job_connect/features/mini_social/screens/group/social_group_screen.dart';
import 'package:job_connect/features/mini_social/screens/post/social_post_detail_screen.dart';
import 'package:job_connect/features/mini_social/screens/report/social_help_screen.dart';
import 'package:job_connect/features/mini_social/screens/job_board/social_job_board_page.dart';
import 'package:job_connect/features/mini_social/screens/report/social_report_post_screem.dart';
import 'package:job_connect/features/mini_social/screens/report/social_scam_check_post_screen.dart';

class SocialRouter {
  SocialRouter._();

  static final GoRoute routers = GoRoute(
    path: '/social',
    pageBuilder: (context, state) {
      return buildPageWithSlideTransition(
       SizedBox.shrink(),
        state,
      );
    },
    routes: [
      // Hồ sơ người dùng
      GoRoute(
        path: 'profile',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          final idUser = extraData['idUser'] ?? '';
          return buildPageWithSlideTransition(
            SocialProfileScreen(
              idUser: idUser,
            ),
          state,
          );
        }
      ),

      GoRoute(
        path: 'detail-post',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};

          final socialPostModel = extraData['socialPostModel'];
          final onFollow = extraData['onFollow'];
          final onHide = extraData['onHide'];
          final onCopyLink = extraData['onCopyLink'];
          final onReport = extraData['onReport'];
          final onOpenProfile = extraData['onOpenProfile'];
          final isLiked = extraData['isLiked'];
          final isSaved = extraData['isSaved'];
          final onLike = extraData['onLike'];
          final onSave = extraData['onSave'];
          final onShare = extraData['onShare'];
          final onComment = extraData['onComment'];
          final onShowReactions = extraData['onShowReactions'];
          final roleName = extraData['roleName'];

          return buildPageWithSlideTransition(
            SocialPostDetailScreen(
              socialPostModel: socialPostModel,
              onFollow: onFollow,
              onHide: onHide,
              onCopyLink: onCopyLink,
              onReport: onReport,
              onOpenProfile: onOpenProfile,
              isLiked: isLiked,
              isSaved: isSaved,
              roleName: roleName,
              onLike: onLike,
              onSave: onSave,
              onShare: onShare,
              onComment: onComment,
              onShowReactions: onShowReactions,
            ),
            state,
          );
        },
      ),

      // Bảng việc làm
      GoRoute(
        path: 'job-board',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          JobBoardPage(),
          state,
        ),
      ),

      // Tìm kiếm
      GoRoute(
        path: 'search',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          SocialSearchScreen(),
          state,
        ),
      ),

      // Tạo bài viết
      GoRoute(
        path: 'create-post',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          SocialCreatePostScreen(),
          state,
        ),
      ),

      // Kết nối bạn bè
      GoRoute(
        path: 'connections',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          ConnectsPage(),
          state,
        ),
      ),

      // Trợ giúp
      GoRoute(
        path: 'help',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          HelpScreen(),
          state,
        ),
      ),

      // Báo cáo bài viết
      GoRoute(
        path: 'report',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          final userName = extraData['userName'] ?? '';
          final authorName = extraData['authorName'] ?? '';
          return buildPageWithSlideTransition(
            ReportPostScreen(
              userName: userName,
              authorName: authorName,
            ),
            state,
          );
        },
      ),

      // Kiểm tra lừa đảo
      GoRoute(
        path: 'check',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          ScamCheckPostScreen(),
          state,
        ),
      ),

      // Nhóm
      GoRoute(
        path: 'group',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          GroupScreen(),
          state,
        ),
      ),

      // Messenger chi tiết
      GoRoute(
        path: 'messenger-detail',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          final isLoggedIn = extraData['isLoggedIn'] ?? false;
          final idUser = extraData['idUser'];
          return buildPageWithSlideTransition(
            SocialMessengerDetailScreen(
              isLoggedIn: isLoggedIn,
              idUser: idUser,
            ),
            state,
          );
        },
      ),

      // Cuộc gọi
      GoRoute(
        path: 'call',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          final avatarUrl = extraData['avatarUrl'] ?? '';
          final userName = extraData['userName'] ?? '';
          return buildPageWithSlideTransition(
            SocialCallScreen(
              userName: userName,
              avatarUrl: avatarUrl,
            ),
            state,
          );
        },
      ),
    ],
  );
}
