import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomButtonIconSimple extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double? size;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const CustomButtonIconSimple({
    super.key,
    required this.icon,
    required this.onTap,
    this.size,
    this.color,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: padding ?? EdgeInsets.all(6.r),
        child: Icon(
          icon,
          size: size ?? 22.sp,
          color: color ?? theme.iconTheme.color,
        ),
      ),
    );
  }
}