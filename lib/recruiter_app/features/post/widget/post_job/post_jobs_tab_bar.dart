import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostJobsTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final PageController pageController;
  final List<Tab> tabs;

  const PostJobsTabBar({
    super.key,
    required this.tabController,
    required this.pageController,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: TabBar(
          controller: tabController,
          onTap: (idx) {
            pageController.animateToPage(
              idx,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          },
          isScrollable: true,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: Colors.white, width: 3.w),
            insets: EdgeInsets.symmetric(horizontal: 10.w),
          ),
          labelColor: Colors.white,
          labelStyle: textTheme.labelSmall?.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
          labelPadding: EdgeInsets.symmetric(horizontal: 10.w),
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          unselectedLabelStyle: textTheme.labelSmall?.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
          tabs: tabs,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60.h);
}