import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileButtonLogout extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String title;
  final Color backgroundColor;
  final Color iconColor;
  final Color titleColor;
  final double iconSize;
  final double borderRadius;
  final double elevation;

  const ProfileButtonLogout({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.title,
    this.backgroundColor = Colors.blue,
    this.iconColor = Colors.white,
    this.titleColor = Colors.white,
    this.iconSize = 22,
    this.borderRadius = 20,
    this.elevation = 6,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      icon: Icon(
        icon,
        color: iconColor,
        size: iconSize.sp,
      ),
      label: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          color: titleColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
    );
  }
}
