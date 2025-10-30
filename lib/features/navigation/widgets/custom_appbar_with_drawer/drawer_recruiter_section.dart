import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/config/utils/label_title_small.dart';
import 'package:job_connect/config/widgets/login_required_dialog.dart';
import 'package:job_connect/features/navigation/widgets/custom_appbar_with_drawer/drawer_infor_header.dart';
import 'package:job_connect/features/navigation/widgets/custom_appbar_with_drawer/drawer_item_widget.dart';

class DrawerRecruiterSection extends StatelessWidget {
  final bool isLoggedIn;
  final String idUser;
  final String? selectedRoute;

  const DrawerRecruiterSection({
    super.key,
    required this.isLoggedIn,
    required this.idUser, 
    this.selectedRoute,
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
          DrawerInforHeader(isLoggedIn: isLoggedIn,),

          DrawerItem(
            icon: Icons.people_outline,
            title: 'Quản lý ứng viên',
            onTap: () => _checkLoginOrRouter(
              context: context,
              route: '/recruiter/candidates-management',
              extra: {
                'recruiterId': idUser
              },
            ),
            isSelected: selectedRoute == '/recruiter/candidates',
          ),
          DrawerItem(
            icon: Icons.work_outline,
            title: 'Danh sách công việc',
            onTap: () => _checkLoginOrRouter(
              context: context,
              route: '/recruiter/jobs',
              extra: {'idUser': idUser},
            ),
            isSelected: selectedRoute == '/recruiter/jobs',
          ),
          DrawerItem(
            icon: Icons.topic_outlined,
            title: 'Báo cáo',
            onTap: () => _checkLoginOrRouter(
              context: context,
              route: '/recruiter/report',
            ),
            isSelected: selectedRoute == '/recruiter/report',
          ),
          DrawerItem(
            icon: Icons.calendar_today_outlined,
            title: 'Lịch phỏng vấn',
            onTap: () => _checkLoginOrRouter(
              context: context,
              route: '/recruiter/interview-schedules',
            ),
            isSelected: selectedRoute == '/recruiter/interview-schedules',
          ),

          LabelTitleSmall(title: 'Hệ thống',),

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
            isSelected: selectedRoute == '/setting',
          ),
          DrawerItem(
            icon: Icons.support_agent_outlined,
            title: 'Trợ giúp & Hỗ trợ',
            onTap: () => _checkLoginOrRouter(
              context: context,
              route: '/setting/help',
            ),
            isSelected: selectedRoute == '/setting/help',
          ),
          DrawerItem(
            icon: Icons.policy_outlined,
            title: 'Chính sách',
            onTap: () => _checkLoginOrRouter(
              context: context,
              route: '/setting/policy',
            ),
            isSelected: selectedRoute == '/setting/policy',
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
            isSelected: false,
          ),
        ],
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
