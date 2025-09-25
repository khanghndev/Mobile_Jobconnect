import 'package:flutter/material.dart';
import 'package:job_connect/config/constant/app_string.dart';
import 'package:job_connect/data/models/account_model.dart';

class SocialDrawerHeader extends StatelessWidget {
  final bool isLoggedIn;
  final Account? account;

  const SocialDrawerHeader({
    super.key,
    required this.isLoggedIn,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return UserAccountsDrawerHeader(
      accountName: Text(
        isLoggedIn ? (account?.userName ?? "Người dùng ${AppStrings.appName}") : "Khách Truy Cập",
        style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      accountEmail: Text(
        isLoggedIn ? (account?.email ?? "Chào mừng bạn đến với UniJob !") : "Vui lòng đăng nhập để trải nghiệm",
        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white.withOpacity(0.9),
        backgroundImage: isLoggedIn && account?.avatarUrl?.isNotEmpty == true
            ? NetworkImage(account!.avatarUrl!)
            : null,
        child: isLoggedIn && (account?.avatarUrl?.isEmpty ?? true)
            ? Text(
                account?.userName.substring(0, 1).toUpperCase() ?? "H",
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
