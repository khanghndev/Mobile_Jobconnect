import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final bool automaticallyImplyLeading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Widget? leading;
  final bool? isDivider;
  final Color? iconColor;

  const CustomAppbar({
    super.key,
    this.title,
    this.automaticallyImplyLeading = true,
    this.actions,
    this.backgroundColor,
    this.leading,
    this.isDivider = true,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final finalIconColor = iconColor ?? Theme.of(context).appBarTheme.iconTheme?.color;
    return AppBar(
      surfaceTintColor: backgroundColor ?? BackgroundColors.backgroundDefaultPrimary,
      backgroundColor: backgroundColor ?? BackgroundColors.backgroundBrandPrimary,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: title,
      centerTitle: true,
      leading: leading,
      scrolledUnderElevation: 4,
      iconTheme: IconThemeData(
        color: finalIconColor,
      ),
      actionsIconTheme: IconThemeData(
        color: finalIconColor,
      ),
      actions: actions,
      bottom: isDivider == true
        ? PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(
                height: 1.h,
                color: BorderColors.borderDefaultDefault.withValues(alpha: 0.1)),
          )
        : null
      );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
