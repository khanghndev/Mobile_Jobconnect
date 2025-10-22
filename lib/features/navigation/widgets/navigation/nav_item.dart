import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final IconData iconOutlined;
  final IconData iconFilled;
  final String label;
  final ThemeData theme;
  final VoidCallback onTap;
  final bool isSpecial;

  const NavItem({
    super.key,
    required this.index,
    required this.currentIndex,
    required this.iconOutlined,
    required this.iconFilled,
    required this.label,
    required this.theme,
    required this.onTap,
    this.isSpecial = false,
  });

  @override
  Widget build(BuildContext context) {
    final selected = currentIndex == index;
    final selectedColor = theme.colorScheme.primary;
    final unselectedColor = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7);

    if (isSpecial) {
      final specialColor = theme.colorScheme.onPrimary;
      final specialInactive = theme.colorScheme.onSecondaryContainer;

      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                width: selected ? 64.w : 58.w,
                height: selected ? 42.h : 38.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: selected
                        ? [selectedColor, selectedColor.withValues(alpha: 0.7)]
                        : [
                            theme.colorScheme.secondary,
                            theme.colorScheme.secondary.withValues(alpha: 0.7)
                          ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: (selected
                              ? selectedColor
                              : theme.colorScheme.secondary)
                          .withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  selected ? iconFilled : iconOutlined,
                  color: selected ? specialColor : specialInactive,
                  size: selected ? 26.sp : 24.sp,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected ? selectedColor : unselectedColor,
                  fontSize: 10.5.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale:
                    CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                selected ? iconFilled : iconOutlined,
                key: ValueKey(selected),
                color: selected ? selectedColor : unselectedColor,
                size: selected ? 26.sp : 23.sp,
              ),
            ),
            SizedBox(height: 5.h),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: theme.textTheme.labelSmall!.copyWith(
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                color: selected ? selectedColor : unselectedColor,
                fontSize: 10.5.sp,
              ),
              child: Text(label,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}