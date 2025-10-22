// bottom_nav_bar.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/recruiter_app/features/job/navigation_recruiter/model_ui/tab_item_data.dart';
import 'nav_bar_item.dart';
import 'special_nav_bar_item.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<TabItemData> tabItems;
  final Function(int) onTabTapped;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.tabItems,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF9FAFC)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.06),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha:0.03),
            blurRadius: 4.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(tabItems.length, (index) {
              final item = tabItems[index];
              if (item.isSpecial) {
                return SpecialNavBarItem(
                  isSelected: currentIndex == index,
                  iconOutlined: item.iconOutlined,
                  iconFilled: item.iconFilled,
                  label: item.label,
                  onTap: () => onTabTapped(index),
                );
              }
              return NavBarItem(
                isSelected: currentIndex == index,
                iconOutlined: item.iconOutlined,
                iconFilled: item.iconFilled,
                label: item.label,
                color: _getColorForIndex(index),
                onTap: () => onTabTapped(index),
              );
            }),
          ),
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    switch (index) {
      case 0:
        return const Color(0xFF1E88E5);
      case 1:
        return const Color(0xFF26A69A);
      case 2:
        return const Color(0xFFFC5C7D);
      case 3:
        return const Color(0xFF7E57C2);
      case 4:
        return const Color(0xFF5C6BC0);
      default:
        return const Color(0xFF1E88E5);
    }
  }
}