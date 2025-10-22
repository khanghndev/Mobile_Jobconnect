// nav_bar_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavBarItem extends StatelessWidget {
  final bool isSelected;
  final IconData iconOutlined;
  final IconData iconFilled;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const NavBarItem({
    super.key,
    required this.isSelected,
    required this.iconOutlined,
    required this.iconFilled,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 42.h,
            width: 42.w,
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha:0.12) : Colors.transparent,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha:0.18),
                        blurRadius: 10.r,
                        offset: Offset(0, 2.h),
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                isSelected ? iconFilled : iconOutlined,
                color: isSelected ? color : Colors.grey.shade500,
                size: isSelected ? 24.sp : 22.sp,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label.length > 10 ? '${label.substring(0, 9)}...' : label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? color : Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}