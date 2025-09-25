import 'package:flutter/material.dart';

class SocialAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLeadingPressed;
  final VoidCallback? onActionsPressed;
  final List<Widget>? actions;
  final Icon? leadingIcon;
  final Icon? actionIcon;
  final Color? backgroundColor;
  final bool centerTitle;
  final bool showLeadingIcon;
  final bool showActionIcon;
  final double? titleFontSize;
  final Color? titleColor;

  const SocialAppBar({
    super.key,
    required this.title,
    this.onLeadingPressed,
    this.onActionsPressed,
    this.actions,
    this.leadingIcon,
    this.actionIcon,
    this.backgroundColor,
    this.centerTitle = true,
    this.showLeadingIcon = true,
    this.showActionIcon = true,
    this.titleFontSize = 18, 
    this.titleColor
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0.8,

      leading: showLeadingIcon
        ? Builder(
            builder: (context) => IconButton(
              icon: leadingIcon ?? const Icon(Icons.menu, color: Colors.black),
              onPressed: onLeadingPressed ?? () {
                Scaffold.of(context).openDrawer();
              },
            ),
          )
        : null,

      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontSize: titleFontSize, 
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,

      actions: showActionIcon
        ? actions ??
            [
              IconButton(
                icon: actionIcon ?? const Icon(Icons.search, color: Colors.black),
                onPressed: onActionsPressed ?? () {},
              ),
            ]
        : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
