import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';

class SocialDrawerItem {
  static Widget build({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onTap();
          context.pop(); 
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: color ?? theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 20),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color ?? theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Về lại trang chủ
  static Widget home(BuildContext context) => build(
    context: context,
    icon: Icons.arrow_back_ios_new,
    title: "Quay lại",
    onTap: () {
      context.pop();
    },
  );
  
  /// Trang cá nhân 
  static Widget profile(BuildContext context, bool isLoggedIn) => build(
    context: context,
    icon: Icons.person_outlined,
    title: "Trang cá nhân",
    onTap: () {
      if (!isLoggedIn){
        SnackbarApp.show(
          context,
          title: "Bạn chưa đăng nhập",
          message: "Vui lòng đăng nhập để thực hiện",
          bgColor: Colors.redAccent,
          icon: Icons.error_outline,
        );  
        context.go('/social-feed');
      } 
      else {
         // TODO: Navigate to social feed
        context.push('/profile');
      }
    },
  );

  /// Bảng tin việc làm
  static Widget board(BuildContext context) => build(
    context: context,
    icon: Icons.home_outlined,
    title: "Bảng tin",
    onTap: () {
      // TODO: Navigate to social feed
      context.push('/job-board');
    },
  );

  /// Tạo bài viết
  static Widget createPost(BuildContext context, bool isLoggedIn) => build(
    context: context,
    icon: Icons.edit_note_outlined,
    title: "Tạo bài viết",
    onTap: () {
      if (!isLoggedIn){
        SnackbarApp.show(
          context,
          title: "Bạn chưa đăng nhập",
          message: "Vui lòng đăng nhập để thực hiện",
          bgColor: Colors.redAccent,
          icon: Icons.error_outline,
        );  
        context.go('/social-feed');
      } 
      else {
        // TODO: Navigate to create post screen
        context.push('/create-post');
      }
    },
  );

  /// Kết nối với người dùng khác
  static Widget connections(BuildContext context, bool isLoggedIn) => build(
    context: context,
    icon: Icons.people_outline,
    title: "Kết nối",
    onTap: () {
      if (!isLoggedIn){
        SnackbarApp.show(
          context,
          title: "Bạn chưa đăng nhập",
          message: "Vui lòng đăng nhập để thực hiện",
          bgColor: Colors.redAccent,
          icon: Icons.error_outline,
        ); 
        context.go('/social-feed');
      } else {
        // TODO: Navigate to connections screen
        context.push('/connections');
      }
    },
  );

  /// Trợ giúp & hỗ trợ
  static Widget help(BuildContext context) => build(
    context: context,
    icon: Icons.support_agent_outlined,
    title: "Trợ giúp & hỗ trợ",
    onTap: () {
      // TODO: Open help screen
      context.push('/help');
    },
  );

  /// Góp ý hệ thống
  static Widget check(BuildContext context) => build(
    context: context,
    icon: Icons.feedback_outlined,
    title: "Kiểm tra hành vi",
    onTap: () {
      // TODO: Open feedback form
      context.push('/check');
    },
  );
  static Widget report(BuildContext context) => build(
    context: context,
    icon: Icons.feedback_outlined,
    title: "Báo cáo hành vi",
    onTap: () {
      // TODO: Open feedback form
    },
  );

}
