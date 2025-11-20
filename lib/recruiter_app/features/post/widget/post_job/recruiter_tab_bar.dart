import 'package:flutter/material.dart';

class RecruiterTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final PageController pageController;

  const RecruiterTabBar({
    super.key,
    required this.tabController,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
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
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
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
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: Colors.white, width: 3.0),
            insets: EdgeInsets.symmetric(horizontal: 10.0),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          tabs: const [
            Tab(
              icon: Icon(Icons.work_outline, size: 20),
              text: "Tin tuyển dụng",
              iconMargin: EdgeInsets.only(bottom: 2.0),
            ),
            Tab(
              icon: Icon(Icons.history, size: 20),
              text: "Lịch sử",
              iconMargin: EdgeInsets.only(bottom: 2.0),
            ),
            Tab(
              icon: Icon(Icons.visibility_outlined, size: 20),
              text: "Đang hiển thị",
              iconMargin: EdgeInsets.only(bottom: 2.0),
            ),
            Tab(
              icon: Icon(Icons.pending_outlined, size: 20),
              text: "Chờ xác thực",
              iconMargin: EdgeInsets.only(bottom: 2.0),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60); // Chiều cao tab bar
}