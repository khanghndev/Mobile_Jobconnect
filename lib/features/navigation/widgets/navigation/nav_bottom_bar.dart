import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'nav_item.dart'; 

class NavBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const NavBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 75.h,
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            color: Colors.white.withValues(alpha: 0.6),
            child: Row(
              children: [
                NavItem(
                  index: 0,
                  currentIndex: currentIndex,
                  iconOutlined: Icons.home_outlined,
                  iconFilled: Icons.home_rounded,
                  label: 'Trang Chủ',
                  theme: theme,
                  onTap: () => onTap(0),
                ),
                // NavItem(
                //   index: 1,
                //   currentIndex: currentIndex,
                //   iconOutlined: Icons.file_copy_outlined,
                //   iconFilled: Icons.file_copy_rounded,
                //   label: 'Hồ sơ',
                //   theme: theme,
                //   onTap: () => onTap(1),
                // ),
                NavItem(
                  index: 1,
                  currentIndex: currentIndex,
                  iconOutlined: Icons.search_outlined,
                  iconFilled: Icons.search,
                  label: 'Tìm việc',
                  theme: theme,
                  onTap: () => onTap(1),
                ),
                NavItem(
                  index: 2,
                  currentIndex: currentIndex,
                  iconOutlined: Icons.local_fire_department_outlined,
                  iconFilled: Icons.local_fire_department_rounded,
                  label: AppStrings.appName,
                  theme: theme,
                  onTap: () => onTap(2),
                  isSpecial: true,
                ),
                NavItem(
                  index: 3,
                  currentIndex: currentIndex,
                  iconOutlined: Icons.chat_bubble_outline_rounded,
                  iconFilled: Icons.chat_bubble_rounded,
                  label: 'Tin nhắn',
                  theme: theme,
                  onTap: () => onTap(3),
                ),
                NavItem(
                  index: 4,
                  currentIndex: currentIndex,
                  iconOutlined: Icons.person_outline_rounded,
                  iconFilled: Icons.person_rounded,
                  label: 'Cá Nhân',
                  theme: theme,
                  onTap: () => onTap(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}