import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/config/widgets/login_required_dialog.dart';
import 'package:job_connect/features/navigation/widgets/custom_appbar_with_drawer/drawer_item_widget.dart';
import 'package:job_connect/features/navigation/widgets/custom_appbar_with_drawer/profile_avatar.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

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
    const recruiterPrimary = Color(0xFF1A237E);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 8,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _DrawerRecruiterHeaderWrapper(isLoggedIn: isLoggedIn),

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
            itemColor: selectedRoute == '/recruiter/candidates' ? recruiterPrimary : null,
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
            itemColor: selectedRoute == '/recruiter/jobs' ? recruiterPrimary : null,
          ),
          DrawerItem(
            icon: Icons.topic_outlined,
            title: 'Báo cáo',
            onTap: () {
              final userVM = context.read<UserViewModel>();
              final currentUserId = (idUser.isNotEmpty) 
                  ? idUser 
                  : (userVM.currentUser?.idUser ?? '');
              debugPrint('🔵 Report - idUser from drawer: "$idUser"');
              debugPrint('🔵 Report - currentUserId from VM: "${userVM.currentUser?.idUser}"');
              debugPrint('🔵 Report - final idUser to use: "$currentUserId"');
              if (currentUserId.isEmpty) {
                debugPrint('❌ Report - No idUser available!');
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Không tìm thấy thông tin người dùng. Vui lòng đăng nhập lại.'),
                  ),
                );
                return;
              }
              _checkLoginOrRouter(
                context: context,
                route: '/recruiter/report',
                extra: {'idUser': currentUserId},
              );
            },
            isSelected: selectedRoute == '/recruiter/report',
            itemColor: selectedRoute == '/recruiter/report' ? recruiterPrimary : null,
          ),
          // DrawerItem(
          //   icon: Icons.calendar_today_outlined,
          //   title: 'Lịch phỏng vấn',
          //   onTap: () => _checkLoginOrRouter(
          //     context: context,
          //     route: '/recruiter/interview-schedules',
          //     extra: {
          //       'idUser': idUser,
          //       'interviews': [],
          //       'jobPostingsList': [],
          //     },
          //   ),
          //   isSelected: selectedRoute == '/recruiter/interview-schedules',
          // ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.01),
            ),
          ),
          _LabelTitleSmallWrapper(title: AppStrings.appName),

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
            itemColor: selectedRoute == '/social/job-board' ? recruiterPrimary : null,
          ),
          DrawerItem(
            icon: Icons.person_outlined,
            title: 'Trang cá nhân',
            onTap: () => _checkLoginOrRouter(context: context, route: '/social/profile'),
            isSelected: selectedRoute == '/social/profile',
            itemColor: selectedRoute == '/social/profile' ? recruiterPrimary : null,
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
            itemColor: selectedRoute == '/social/create-post' ? recruiterPrimary : null,
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
            itemColor: selectedRoute == '/social/connections' ? recruiterPrimary : null,
          ),

          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.01),
            ),
          ),

          _LabelTitleSmallWrapper(title: 'Hệ thống'),

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
            itemColor: selectedRoute == '/setting' ? recruiterPrimary : null,
          ),
          DrawerItem(
            icon: Icons.support_agent_outlined,
            title: 'Trợ giúp & Hỗ trợ',
            onTap: () => _checkLoginOrRouter(
              context: context,
              route: '/setting/help',
            ),
            isSelected: selectedRoute == '/setting/help',
            itemColor: selectedRoute == '/setting/help' ? recruiterPrimary : null,
          ),
          DrawerItem(
            icon: Icons.policy_outlined,
            title: 'Chính sách',
            onTap: () => _checkLoginOrRouter(
              context: context,
              route: '/setting/policy',
            ),
            isSelected: selectedRoute == '/setting/policy',
            itemColor: selectedRoute == '/setting/policy' ? recruiterPrimary : null,
          ),

          Container(height: 16.w, color: Colors.grey.withValues(alpha: 0.01)),

          DrawerItem(
            icon: isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
            title: isLoggedIn ? 'Đăng xuất' : 'Đăng nhập',
            itemColor: isLoggedIn
                ? theme.colorScheme.error
                : recruiterPrimary,
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

    final finalExtra = extra ?? {'idUser': idUser};
    debugPrint('🔵 Navigating to $route with extra: $finalExtra');
    debugPrint('🔵 idUser value: $idUser');
    context.push(route, extra: finalExtra);
  }
}

// Wrapper để override màu header
class _DrawerRecruiterHeaderWrapper extends StatelessWidget {
  final bool isLoggedIn;

  const _DrawerRecruiterHeaderWrapper({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    const recruiterPrimary = Color(0xFF1A237E);
    const recruiterSecondary = Color(0xFF283593);
    
    final theme = Theme.of(context);
    final userVM = context.watch<UserViewModel>();
    final user = userVM.currentUser;

    return UserAccountsDrawerHeader(
      accountName: Text(
        isLoggedIn ? user?.userName ?? "Người dùng" : "Người dùng ${AppStrings.appName}",
        style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
      ),
      accountEmail: Text(
        isLoggedIn ? user?.email ?? "Chào mừng bạn quay trở lại" : "Vui lòng đăng nhập",
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
      ),
      currentAccountPicture: const ProfileAvatar(),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            recruiterPrimary,
            recruiterSecondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

// Wrapper để override màu label
class _LabelTitleSmallWrapper extends StatelessWidget {
  final String title;

  const _LabelTitleSmallWrapper({required this.title});

  @override
  Widget build(BuildContext context) {
    const recruiterPrimary = Color(0xFF1A237E);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: recruiterPrimary,
        ),
      ),
    );
  }
}
