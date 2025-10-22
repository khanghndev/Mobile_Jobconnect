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

class DrawerRecruiterSection extends StatelessWidget {
  final bool isLoggedIn;
  final String idUser;

  const DrawerRecruiterSection({
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

          /// --- DANH MỤC CHÍNH ---
          DrawerItem(
            icon: Icons.people_outline,
            title: 'Quản lý ứng viên',
            onTap: () => _checkLoginOrRouter(
              context: context,
              route: '/recruiter/candidates',
              extra: {'idUser': idUser},
            ),
          ),
          DrawerItem(
            icon: Icons.work_outline,
            title: 'Danh sách công việc',
            onTap: () => _checkLoginOrRouter(
              context: context,
              route: '/recruiter/jobs',
              extra: {'idUser': idUser},
            ),
          ),
          DrawerItem(
            icon: Icons.topic_outlined,
            title: 'Báo cáo',
            onTap: () => _checkLoginOrRouter(
              context: context,
              route: '/recruiter/report',
            ),
          ),
          DrawerItem(
            icon: Icons.calendar_today_outlined,
            title: 'Lịch phỏng vấn',
            onTap: () => _checkLoginOrRouter(
              context: context,
              route: '/recruiter/interview-schedules',
            ),
          ),

          Container(height: 12.h, color: Colors.grey.withValues(alpha: 0.03)),
          _buildSectionTitle(context, 'Hệ thống'),

          DrawerItem(
            icon: Icons.settings_outlined,
            title: 'Cài đặt',
            onTap: () => _checkLoginOrRouter(
              context: context,
              route: '/setting',
              extra: {
                'isLoggedIn': isLoggedIn,
                'idUser': idUser,
              },
            ),
          ),
          DrawerItem(
            icon: Icons.support_agent_outlined,
            title: 'Trợ giúp & Hỗ trợ',
            onTap: () => _checkLoginOrRouter(
              context: context,
              route: '/setting/help',
            ),
          ),
          DrawerItem(
            icon: Icons.policy_outlined,
            title: 'Chính sách',
            onTap: () => _checkLoginOrRouter(
              context: context,
              route: '/setting/policy',
            ),
          ),

          Container(height: 16.w, color: Colors.grey.withValues(alpha: 0.01)),

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
                  extra: {'role': UserRole.recruiter.name},
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
