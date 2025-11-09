import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final double iconSize;
  final TextStyle? textStyle;

  const InfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor = Colors.orange,
    this.iconSize = 20,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: iconColor,
          size: iconSize.sp,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: textStyle ?? Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
