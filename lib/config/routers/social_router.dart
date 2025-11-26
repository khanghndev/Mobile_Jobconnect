import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/navigation/app_navigation.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';
import 'package:job_connect/features/mini_social/screens/connects/social_create_group_screen.dart';
import 'package:job_connect/features/mini_social/screens/connects/social_managent_group_screen.dart';
import 'package:job_connect/features/mini_social/screens/connects/social_managent_post_group_screen.dart';
import 'package:job_connect/features/mini_social/screens/home/social_profile_screen.dart';
import 'package:job_connect/features/mini_social/screens/home/social_search_screen.dart';
import 'package:job_connect/features/mini_social/screens/messeger/social_call_screen.dart';
import 'package:job_connect/features/mini_social/screens/messeger/social_messenger_detail_screen.dart';
import 'package:job_connect/features/mini_social/screens/social_post/social_create_post_screen.dart';
import 'package:job_connect/features/mini_social/screens/connects/social_connects_screen.dart';
import 'package:job_connect/features/mini_social/screens/connects/social_group_screen.dart';
import 'package:job_connect/features/mini_social/screens/social_post/saved_posts_screen.dart';
import 'package:job_connect/features/mini_social/screens/social_post/social_detail_post_screen.dart';
import 'package:job_connect/features/mini_social/screens/report/social_help_screen.dart';
import 'package:job_connect/features/mini_social/screens/job_board/social_job_board_page.dart';
import 'package:job_connect/features/mini_social/screens/report/social_report_post_screem.dart';
import 'package:job_connect/features/mini_social/screens/report/social_scam_check_post_screen.dart';
import 'package:job_connect/features/mini_social/screens/social_post/social_edit_post_screen.dart';

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
          final idUser = extraData['idUser'];
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

          final socialPostModel = extraData['socialPostModel'] as SocialPostModel;
          final isLoggedIn = extraData['isLoggedIn'] as bool? ?? false;
          final idUser = extraData['idUser'] as String? ?? '';

          return buildPageWithSlideTransition(
            SocialDetailPostScreen(
              socialPostModel: socialPostModel,
              isLoggedIn: isLoggedIn,
              idUser: idUser,
            ),
            state,
          );
        },
      ),

      // Danh sách bài viết đã lưu
      GoRoute(
        path: 'saved-posts',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          final isLoggedIn = extraData['isLoggedIn'] as bool? ?? false;
          final idUser = extraData['idUser'] as String? ?? '';
          final folderName = extraData['folderName'] as String?;

          return buildPageWithSlideTransition(
            SavedPostsScreen(
              isLoggedIn: isLoggedIn,
              idUser: idUser,
              folderName: folderName,
            ),
            state,
          );
        },
      ),
      // Bảng việc làm
      GoRoute(
        path: 'job-board',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          final idUser = extraData['idUser'];
          return buildPageWithSlideTransition(
            SocialJobBoardPage(
              idUser: idUser,
            ),
            state,
          );
        }
      ),

      // Tìm kiếm
      GoRoute(
        path: 'search',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          final idUser = extraData['idUser'];
          return buildPageWithSlideTransition(
            SocialSearchScreen(
              idUser: idUser,
            ),
            state,
          );
        }
      ),

      // Tạo bài viết
      GoRoute(
        path: 'create-post',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          final idUser = extraData['idUser'] as String?;
          final groupId = extraData['groupId'] as String?;
          final groupName = extraData['groupName'] as String?;

          return buildPageWithSlideTransition(
            SocialCreatePostScreen(
              idUser: idUser ?? '',
              groupId: groupId,
              groupName: groupName,
            ),
            state,
          );
        },
      ),

      // Chỉnh sửa bài viết
      GoRoute(
        path: 'edit-post',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          final socialPostModel = extraData['socialPostModel'];
          return buildPageWithSlideTransition(
            SocialEditPostScreen(
              socialPostModel: socialPostModel,
            ),
            state,
          );
        }
      ),

      // Tạo nhóm
      GoRoute(
        path: 'create-group',
        pageBuilder: (context, state) => buildPageWithSlideTransition(
          SocialCreateGroupScreen(),
          state,
        ),
      ),

      // Kết nối bạn bè
      GoRoute(
        path: 'connections',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          final isLoggedIn = extraData['isLoggedIn'];
          final idUser = extraData['idUser'];
          return buildPageWithSlideTransition(
            SocialConnectsScreen(
              isLoggedIn: isLoggedIn,
              idUser: idUser,
            ),
          state, );
        },
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
          final userName = extraData['userName'];
          final authorName = extraData['authorName'];
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
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          final isLoggedIn = extraData['isLoggedIn'];
          final idUser = extraData['idUser'];
          final idGroup = extraData['idGroup'];
          return buildPageWithSlideTransition(
            SocialGroupScreen(
              isLoggedIn: isLoggedIn,
              idUser: idUser,
              idGroup: idGroup,
            ),
          state, );
        },
      ),

      GoRoute(
        path: 'manage-group',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          final idUser = extraData['idUser'];
          final idGroup = extraData['idGroup'];
          return buildPageWithSlideTransition(
            SocialManagentGroupScreen(
              idUser: idUser,
              idGroup: idGroup,
            ),
          state, );
        },
      ),

      GoRoute(
        path: 'manage-post-group',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          final idUser = extraData['idUser'] as String? ?? '';
          final idGroup = extraData['idGroup'] as String? ?? '';
          final isLoggedIn = extraData['isLoggedIn'] as bool? ?? false;

          return buildPageWithSlideTransition(
            SocialManagentPostGroupScreen(
              idUser: idUser,
              idGroup: idGroup,
              isLoggedIn: isLoggedIn,
            ),
            state,
          );
        },
      ),

      // Messenger chi tiết
      GoRoute(
        path: 'messenger-detail',
        pageBuilder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          final isLoggedIn = extraData['isLoggedIn'] ?? false;
          final idUser = extraData['idUser'];
          final otherUserId = extraData['otherUserId'];
          final conversationId = extraData['conversationId'];
          final otherUserName = extraData['otherUserName'];
          final otherUserAvatar = extraData['otherUserAvatar'];
          final currentUserAvatar = extraData['currentUserAvatar'];

          return buildPageWithSlideTransition(
            SocialMessengerDetailScreen(
              isLoggedIn: isLoggedIn,
              idUser: idUser,
              otherUserId: otherUserId,
              conversationId: conversationId,
              otherUserName: otherUserName,
              otherUserAvatar: otherUserAvatar,
              currentUserAvatar: currentUserAvatar,
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
          final avatarUrl = extraData['avatarUrl'];
          final userName = extraData['userName'];
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
