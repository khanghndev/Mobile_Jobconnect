import 'package:flutter/material.dart';
import 'package:job_connect/data/models/account_model.dart';
import 'package:job_connect/features/mini_social/widgets/social_drawer/social_drawer_header.dart';
import 'package:job_connect/features/mini_social/widgets/social_drawer/social_drawer_item.dart';
import 'package:job_connect/features/mini_social/widgets/social_drawer/social_drawer_footer.dart';

class SocialDrawer extends StatelessWidget {
  final bool isLoggedIn;
  final String idUser;
  final Account? account;
  final VoidCallback onLogout;

  const SocialDrawer({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
    required this.account,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          SocialDrawerHeader(isLoggedIn: isLoggedIn, account: account),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 4),

                _buildSectionTitle(context, "Mạng xã hội"),
                SocialDrawerItem.board(context),
                SocialDrawerItem.profile(context, isLoggedIn),
                SocialDrawerItem.createPost(context, isLoggedIn),
                SocialDrawerItem.connections(context, isLoggedIn),

                const Divider(indent: 16, endIndent: 16),

                _buildSectionTitle(context, "Hệ thống"),
                SocialDrawerItem.check(context),
                SocialDrawerItem.help(context),
                SocialDrawerItem.home(context),
              ],
            ),
          ),

          // --- FOOTER: LOGIN / LOGOUT ---
          SocialDrawerFooter(isLoggedIn: isLoggedIn, onLogout: onLogout),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Theme.of(context).colorScheme.outline,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
