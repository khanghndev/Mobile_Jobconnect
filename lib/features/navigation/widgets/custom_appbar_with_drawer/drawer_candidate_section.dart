import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/config/widgets/login_required_dialog.dart';
import 'package:job_connect/features/navigation/widgets/custom_appbar_with_drawer/profile_avatar.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:job_connect/features/navigation/widgets/custom_appbar_with_drawer/drawer_item_widget.dart';
import 'package:provider/provider.dart';

class DrawerCandidateSection extends StatelessWidget {
  final bool isLoggedIn;
  final String idUser;

  const DrawerCandidateSection({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 8,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context, theme),
          DrawerItem(
            icon: Icons.home_filled,
            title: 'Trang chủ',
            isSelected: true,
          ),
          DrawerItem(
            icon: Icons.document_scanner_outlined,
            title: 'Phân tích CV',
            onTap: () => _checkLoginOrRouter(context: context, route: '/resume/analysis'),
          ),
          DrawerItem(
            icon: Icons.bookmark_added_outlined,
            title: 'Công việc đã lưu',
            onTap: () => _checkLoginOrRouter(
              context: context, 
              route: '/home/search',
              extra: {
                'isLoggedIn': isLoggedIn,
                'idUser': idUser,
                'initialTabIndex' : 2,
              }
            ),
          ),
          DrawerItem(
            icon: Icons.history_edu_outlined,
            title: 'Lịch sử ứng tuyển',
            onTap: () => _checkLoginOrRouter(context: context, route: '/job/history'),
          ),
          DrawerItem(
            icon: Icons.recommend_outlined,
            title: 'Gợi ý công việc',
            onTap: () => _checkLoginOrRouter(context: context, route: '/job/matching'),
          ),

          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.01),
            ),
          ),
          _buildSectionTitle(context, 'UniJobs'),

          DrawerItem(
            icon: Icons.home_outlined,
            title: 'Bảng tin',
            onTap: () => _checkLoginOrRouter(context: context, route: '/social/job-board'),
          ),
          DrawerItem(
            icon: Icons.person_outlined,
            title: 'Trang cá nhân',
            onTap: () => _checkLoginOrRouter(context: context, route: '/social/profile'),
          ),
          DrawerItem(
            icon: Icons.edit_note_outlined,
            title: 'Tạo bài viết',
            onTap: () => _checkLoginOrRouter(context: context, route: '/social/create-post'),
          ),
          DrawerItem(
            icon: Icons.people_outline,
            title: 'Kết nối',
            onTap: () => _checkLoginOrRouter(context: context, route: '/social/connections'),
          ),

          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.01),
            ),
          ),
          _buildSectionTitle(context, 'Hệ thống'),

          DrawerItem(
            icon: Icons.feedback_outlined,
            title: 'Kiểm tra hành vi',
            onTap: () => _checkLoginOrRouter(context: context, route: '/social/check'),
          ),
          DrawerItem(
            icon: Icons.settings_outlined,
            title: 'Cài đặt',
            onTap: () => _checkLoginOrRouter(
              context: context, 
              route: '/setting',
              extra: {
                'isLoggedIn': isLoggedIn,
                'idUser': idUser,
              }
            ),
          ),
          DrawerItem(
            icon: Icons.support_agent_outlined,
            title: 'Trợ giúp & Hỗ trợ',
            onTap: () => _checkLoginOrRouter(context: context, route: '/setting/help'),
          ),

          DrawerItem(
            icon: Icons.policy_outlined,
            title: 'Chính sách',
            onTap: () => _checkLoginOrRouter(context: context, route: '/setting/policy'),
          ),

          Container(
            height: 16.w,
            color: Colors.grey.withValues(alpha: 0.01),
          ),

          DrawerItem(
            icon: isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
            title: isLoggedIn ? 'Đăng xuất' : 'Đăng nhập',
            itemColor: isLoggedIn
                ? theme.colorScheme.error
                : theme.colorScheme.primary,
            onTap: () {
              if (isLoggedIn) {
                DialogUtils.showLogoutDialog(context);
              } else {
                context.push(
                  '/auth/login', 
                  extra: {
                    'role': UserRole.candidate.name
                  }
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    final userVM = context.watch<UserViewModel>();
    final user = userVM.userDetail;
    return UserAccountsDrawerHeader(
      accountName: Text(
        isLoggedIn ? user!.userName : "Người dùng ${AppStrings.appName}",
        style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
      ),
      accountEmail: Text(
        isLoggedIn ? "Chào mừng bạn quay lại!" : "Vui lòng đăng nhập",
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
      ),
      currentAccountPicture: ProfileAvatar(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  void _checkLoginOrRouter({
    required BuildContext context,
    required String route,
    Map<String, dynamic>? extra,
  }) {
    if (!isLoggedIn) {
      LoginRequiredDialog.show(context, isLoggedIn: false);
      return;
    }

    context.push(route, extra: extra ?? {'idUser': idUser});
  }
}
