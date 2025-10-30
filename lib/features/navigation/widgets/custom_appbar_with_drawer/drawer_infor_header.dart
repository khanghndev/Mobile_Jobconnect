import 'package:flutter/material.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/features/navigation/widgets/custom_appbar_with_drawer/profile_avatar.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class DrawerInforHeader extends StatelessWidget {
  final bool isLoggedIn;

  const DrawerInforHeader({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
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
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}