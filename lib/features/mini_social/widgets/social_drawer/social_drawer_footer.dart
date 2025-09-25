import 'package:flutter/material.dart';
import 'package:job_connect/features/auth/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SocialDrawerFooter extends StatelessWidget {
  final bool isLoggedIn;
  final VoidCallback onLogout;

  const SocialDrawerFooter({
    super.key,
    required this.isLoggedIn,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: isLoggedIn
          ? _logoutButton(context)
          : _loginButton(context),
    );
  }

  Widget _logoutButton(BuildContext context) {
    return _buildItem(context, Icons.logout_rounded, "Đăng xuất", () async {
      final confirm = await _confirmLogoutDialog(context);
      if (confirm) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', false);
        await prefs.setString('userId', "");
        onLogout();
      }
    }, color: Theme.of(context).colorScheme.error);
  }

  Widget _loginButton(BuildContext context) {
    return _buildItem(context, Icons.login_rounded, "Đăng nhập", () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    });
  }

  Widget _buildItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {Color? color}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color ?? theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 20),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color ?? theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmLogoutDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Xác nhận đăng xuất"),
            content: const Text("Bạn có chắc chắn muốn đăng xuất?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Huỷ")),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Đăng xuất")),
            ],
          ),
        ) ??
        false;
  }
}
