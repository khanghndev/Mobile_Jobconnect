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
    const recruiterPrimary = Color(0xFF1A237E);
    const recruiterSecondary = Color(0xFF283593);
    
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
                  gradient: LinearGradient(
                    colors: isSelected
                        ? [
                            recruiterPrimary,
                            recruiterSecondary,
                            recruiterPrimary.withValues(alpha: 0.8),
                          ]
                        : [
                            recruiterPrimary.withValues(alpha: 0.6),
                            recruiterSecondary.withValues(alpha: 0.6),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: recruiterPrimary.withValues(alpha: isSelected ? 0.35 : 0.2),
                      blurRadius: isSelected ? 14.r : 8.r,
                      offset: Offset(0, isSelected ? 5.h : 3.h),
                      spreadRadius: 0,
                    ),
                    if (isSelected)
                      BoxShadow(
                        color: recruiterPrimary.withValues(alpha: 0.2),
                        blurRadius: 6.r,
                        offset: Offset(0, 2.h),
                        spreadRadius: 0,
                      ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isSelected ? iconFilled : iconOutlined,
                    color: Colors.white,
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
                            color: recruiterPrimary,
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