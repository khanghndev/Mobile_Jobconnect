import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/config/utils/label_title_small.dart';
import 'package:job_connect/config/widgets/login_required_dialog.dart';
import 'package:job_connect/features/navigation/screens/navigation_page.dart';
import 'package:job_connect/features/navigation/widgets/custom_appbar_with_drawer/drawer_infor_header.dart';
import 'package:job_connect/features/navigation/widgets/custom_appbar_with_drawer/drawer_item_widget.dart';

class DrawerCandidateSection extends StatelessWidget {
  final bool isLoggedIn;
  final String idUser;
  final String? selectedRoute;

  const DrawerCandidateSection({
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
          DrawerInforHeader(isLoggedIn: isLoggedIn),
          DrawerItem(
            icon: Icons.home_filled,
            title: 'Trang chủ',
            isSelected: selectedRoute == '/home',
          ),
          DrawerItem(
            icon: Icons.file_copy,
            title: 'Quản lý CV',
            onTap: () => _checkLoginOrRouter(
              context: context, 
              route: '/home/cv',
              extra: {
                'isLoggedIn': isLoggedIn,
                'idUser': idUser,
              }
            ),
            isSelected: selectedRoute == '/home/cv',
          ),
          DrawerItem(
            icon: Icons.document_scanner_outlined,
            title: 'Phân tích CV',
            onTap: () => _checkLoginOrRouter(
              context: context, 
              route: '/resume/analysis',
              extra: {
                'idUser': idUser,
              }
            ),
            isSelected: selectedRoute == '/resume/analysis',
          ),
          DrawerItem(
            icon: Icons.bookmark_added_outlined,
            title: 'Công việc đã lưu',
            onTap: () => NavigationPage.goToSavedJobsTab(context),
            isSelected: selectedRoute == '/home/search',
          ),
          DrawerItem(
            icon: Icons.history_edu_outlined,
            title: 'Lịch sử ứng tuyển',
            onTap: () => _checkLoginOrRouter(context: context, route: '/job/history'),
            isSelected: selectedRoute == '/job/history',
          ),
          DrawerItem(
            icon: Icons.recommend_outlined,
            title: 'Gợi ý công việc',
            onTap: () => _checkLoginOrRouter(context: context, route: '/job/matching'),
            isSelected: selectedRoute == '/job/matching',
          ),

          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.01),
            ),
          ),
          LabelTitleSmall(title: AppStrings.appName,),

          DrawerItem(
            icon: Icons.home_outlined,
            title: 'Bảng tin',
            onTap: () => _checkLoginOrRouter(
              context: context, 
              route: '/social/job-board',
              extra: {
                'idUser': idUser,
              }
            ),
            isSelected: selectedRoute == '/social/job-board',
          ),
          DrawerItem(
            icon: Icons.person_outlined,
            title: 'Trang cá nhân',
            onTap: () => _checkLoginOrRouter(context: context, route: '/social/profile'),
            isSelected: selectedRoute == '/social/profile',
          ),
          DrawerItem(
            icon: Icons.edit_note_outlined,
            title: 'Tạo bài viết',
            onTap: () => _checkLoginOrRouter(
              context: context, 
              route: '/social/create-post',
              extra: {
                'idUser': idUser,
              }
            ),
            isSelected: selectedRoute == '/social/create-post',
          ),
          DrawerItem(
            icon: Icons.people_outline,
            title: 'Kết nối',
            onTap: () => _checkLoginOrRouter(
              context: context, 
              route: '/social/connections',
              extra: {
                'isLoggedIn': isLoggedIn,
                'idUser': idUser,
              }
            ),
            isSelected: selectedRoute == '/social/connections',
          ),

          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.01),
            ),
          ),
          LabelTitleSmall(title: 'Hệ thống'),

          DrawerItem(
            icon: Icons.feedback_outlined,
            title: 'Kiểm tra hành vi',
            onTap: () => _checkLoginOrRouter(context: context, route: '/social/check'),
            isSelected: selectedRoute == '/social/check',
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
            isSelected: selectedRoute == '/setting',
          ),
          DrawerItem(
            icon: Icons.support_agent_outlined,
            title: 'Trợ giúp & Hỗ trợ',
            onTap: () => _checkLoginOrRouter(context: context, route: '/setting/help'),
            isSelected: selectedRoute == '/setting/help',
          ),

          DrawerItem(
            icon: Icons.policy_outlined,
            title: 'Chính sách',
            onTap: () => _checkLoginOrRouter(context: context, route: '/setting/policy'),
            isSelected: selectedRoute == '/setting/policy',
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
            isSelected: selectedRoute == '/auth/login',
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