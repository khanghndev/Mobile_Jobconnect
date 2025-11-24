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
    const recruiterPrimary = Color(0xFF1A237E);
    
    return Container(
      height: 76.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: recruiterPrimary.withValues(alpha: 0.1),
          width: 1.5.w,
        ),
        boxShadow: [
          BoxShadow(
            color: recruiterPrimary.withValues(alpha: 0.08),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(tabItems.length, (index) {
            final item = tabItems[index];
            final isSelected = (currentIndex == index);
            if (item.isSpecial) {
              return SpecialNavBarItem(
                isSelected: isSelected,
                iconOutlined: item.iconOutlined,
                iconFilled: item.iconFilled,
                label: item.label,
                onTap: () => onTabTapped(index),
              );
            }
            return NavBarItem(
              isSelected: isSelected,
              iconOutlined: item.iconOutlined,
              iconFilled: item.iconFilled,
              label: item.label,
              color: recruiterPrimary,
              onTap: () => onTabTapped(index),
            );
          }),
        ),
      ),
    );
  }
}