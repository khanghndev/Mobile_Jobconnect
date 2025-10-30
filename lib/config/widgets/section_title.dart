import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? iconColor;
  final Color? textColor;
  final bool? isToUpperCase;
  final double? fontSize;
  final bool? isCenter;
  final FontWeight? fontWeight;

  const SectionTitle({
    super.key,
    required this.title,
    this.icon, 
    this.iconColor, 
    this.textColor, 
    this.isToUpperCase = false, 
    this.fontSize, 
    this.isCenter = false,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: isCenter == true ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if(icon == null)...[
          Icon(
            icon,
            color:iconColor ?? theme.primaryColor,
            size: 22.sp,
          ),
        ],
        SizedBox(width: 10.w),
        Text(
          isToUpperCase == true ? title.toUpperCase() : title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: fontWeight ?? FontWeight.bold,
            color: textColor ?? theme.textTheme.titleLarge?.color,
            fontSize: fontSize ?? 18.sp,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
