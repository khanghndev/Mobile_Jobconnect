// special_nav_bar_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpecialNavBarItem extends StatelessWidget {
  final bool isSelected;
  final IconData iconOutlined;
  final IconData iconFilled;
  final String label;
  final VoidCallback onTap;

  const SpecialNavBarItem({
    super.key,
    required this.isSelected,
    required this.iconOutlined,
    required this.iconFilled,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
        width: 64.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 42.h,
              width: 42.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF6A82FB), Color(0xFFFC5C7D)]),
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFC5C7D).withValues(alpha: 0.25),
                    blurRadius: 8.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  isSelected ? iconFilled : iconOutlined,
                  color: Colors.white,
                  size: 22.sp,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label.length > 10 ? '${label.substring(0, 9)}...' : label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFFC5C7D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}