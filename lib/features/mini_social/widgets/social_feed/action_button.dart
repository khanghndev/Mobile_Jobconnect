import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool active;

  const ActionButton({
    super.key,
    this.icon,
    required this.label,
    required this.onTap,
    this.onLongPress,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.pinkAccent : Colors.black87;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20.sp, color: color),
              SizedBox(height: 2.h),
              Text(
                label,
                style: TextStyle(fontSize: 13.sp, color: color),
              ),
            ] else
              Text(
                label,
                style: TextStyle(fontSize: 20.sp, color: color),
              ),
          ],
        ),
      ),
    );
  }
}