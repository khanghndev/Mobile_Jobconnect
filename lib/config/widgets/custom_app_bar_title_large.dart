import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/utils/get_adaptive_back_icon.dart';

class CustomAppbarTitleLarge extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final bool centerTitle;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final double? iconSize;
  final double? fontSize;
  final IconData? leadingIcon;
  final Color? textColor;
  final bool? isShape;
  final Color? iconColor;

  const CustomAppbarTitleLarge({
    super.key,
    required this.title,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0.8,
    this.systemOverlayStyle,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBack, 
    this.actions, 
    this.iconSize, 
    this.fontSize, 
    this.leadingIcon, 
    this.textColor, 
    this.isShape = false, 
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      elevation: elevation,
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      foregroundColor: foregroundColor ?? theme.colorScheme.onSurface,
      leading: showBackButton
          ? GestureDetector(
              onTap: onBack ?? () => context.pop(),
              child: Icon(
                leadingIcon ?? getAdaptiveBackIcon(context),
                size: iconSize ?? 20.sp,
                color: iconColor ?? theme.colorScheme.onSurface,
              ),
            )
          : null,
      actions: actions,
      title: Text(
        title,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: textColor ?? theme.colorScheme.onSurface,
          fontSize: fontSize ?? 22.sp
        ),
      ),
      centerTitle: centerTitle,
      systemOverlayStyle: systemOverlayStyle ?? SystemUiOverlayStyle.dark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(isShape == true ? 20.r : 0)),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
