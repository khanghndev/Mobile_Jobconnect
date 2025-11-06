import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CardMain extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double elevation;
  final Color? color;
  final Color? shadowColor;

  const CardMain({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 12,
    this.elevation = 1.5,
    this.color,
    this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: elevation,
      shadowColor: shadowColor ?? theme.shadowColor.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
      color: color ?? theme.cardColor,
      child: Padding(
        padding: padding ?? EdgeInsets.all(16.w),
        child: child,
      ),
    );
  }
}