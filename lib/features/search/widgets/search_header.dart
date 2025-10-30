import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/widgets/custom_search_bar_main.dart';

class SearchHeader extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback onFilterTap;
  final TabController tabController;

  const SearchHeader({
    super.key,
    required this.searchController,
    required this.onFilterTap,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10.h,
        bottom: 0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.85),
          ],
          stops: const [0.3, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Padding(
          //   padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             GestureDetector(
          //               onTap: () => context.pop(),
          //               child: Icon(
          //                 Icons.arrow_back_ios_new,
          //                 color: Colors.white,
          //                 size: 24.sp,
          //               ),
          //             ),
          //             SizedBox(height: 8.h),
          //             Text(
          //               'Khám Phá Việc Làm',
          //               style: theme.textTheme.headlineSmall?.copyWith(
          //                 color: Colors.white,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //             SizedBox(height: 6.h),
          //             Text(
          //               'Hàng ngàn việc làm đang chờ bạn.',
          //               style: theme.textTheme.bodyMedium?.copyWith(
          //                 color: Colors.white.withValues(alpha: 0.9),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          // SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: CustomSearchBarMain(
                  controller: searchController,
                  onChanged: (_) {},
                  onClear: searchController.clear,
                  hinText: "Tìm theo tên, ngành nghề, địa chỉ...",
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 4.h, right: 16.w),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: InkWell(
                    onTap: onFilterTap,
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Icon(
                        Icons.filter_list_rounded,
                        color: Colors.white,
                        size: 26.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Theme(
            data: theme.copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              tabBarTheme: TabBarThemeData(
                labelColor: Colors.white,
                unselectedLabelColor:
                    Colors.white.withValues(alpha: 0.75),
                indicatorSize: TabBarIndicatorSize.label,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: Colors.white, width: 3.w),
                  insets: EdgeInsets.symmetric(horizontal: 60.w),
                ),
                labelStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            child: TabBar(
              controller: tabController,
              tabs: const [
                Tab(text: "NỔI BẬT"),
                Tab(text: "MỚI NHẤT"),
                Tab(text: "ĐÃ LƯU"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
