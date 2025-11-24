import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TabItem {
  final IconData icon;
  final String text;

  const TabItem({
    required this.icon,
    required this.text,
  });
}

class PostJobsTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final PageController pageController;
  final List<TabItem> tabItems;

  PostJobsTabBar({
    super.key,
    required this.tabController,
    required this.pageController,
    required List<Tab> tabs,
  }) : tabItems = tabs.map((tab) {
          IconData icon = Icons.circle;
          String text = '';
          
          if (tab.icon != null) {
            if (tab.icon is Icon) {
              icon = (tab.icon as Icon).icon!;
            } else if (tab.icon is IconData) {
              icon = tab.icon as IconData;
            }
          }
          
          if (tab.text != null) {
            text = tab.text!;
          }
          
          return TabItem(icon: icon, text: text);
        }).toList();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const recruiterPrimary = Color(0xFF1A237E);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A237E),
            Color(0xFF283593),
            Color(0xFF3949AB),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: recruiterPrimary.withValues(alpha: 0.2),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        padding: EdgeInsets.all(3.r),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.w,
          ),
        ),
        child: AnimatedBuilder(
          animation: tabController,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(tabItems.length, (index) {
                final tabItem = tabItems[index];
                final isSelected = tabController.index == index;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      // Cập nhật ngay lập tức để phản hồi nhanh
                      tabController.animateTo(index);
                      pageController.jumpToPage(index);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.25)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 6.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tabItem.icon,
                            color: isSelected
                                ? recruiterPrimary
                                : Colors.white.withValues(alpha: 0.85),
                            size: isSelected ? 22.sp : 20.sp,
                          ),
                          if (isSelected) ...[
                            SizedBox(height: 4.h),
                            Text(
                              tabItem.text,
                              style: textTheme.labelSmall?.copyWith(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: recruiterPrimary,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(52.h);
}