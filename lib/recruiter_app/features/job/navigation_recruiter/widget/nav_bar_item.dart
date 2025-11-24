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
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                height: 40.h,
                width: 40.w,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            color,
                            color.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.3),
                            blurRadius: 12.r,
                            offset: Offset(0, 4.h),
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: color.withValues(alpha: 0.15),
                            blurRadius: 6.r,
                            offset: Offset(0, 2.h),
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    isSelected ? iconFilled : iconOutlined,
                    color: isSelected ? Colors.white : Colors.grey.shade500,
                    size: isSelected ? 22.sp : 20.sp,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.3),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOut,
                      )),
                      child: child,
                    ),
                  );
                },
                child: isSelected
                    ? Padding(
                        key: ValueKey(label),
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: color,
                            letterSpacing: 0.3,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : SizedBox(key: ValueKey('empty'), height: 0.h),
              ),
            ],
          ),
        ),
      ),
    );
  }
}