import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecentActivitiesSection extends StatelessWidget {
  final List<Map<String, dynamic>> Function() getRecentActivities;
  final Widget Function(Map<String, dynamic>) detailScreenBuilder;

  const RecentActivitiesSection({
    super.key,
    required this.getRecentActivities,
    required this.detailScreenBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final recentActivities = getRecentActivities();
    final textTheme = Theme.of(context).textTheme;
    const recruiterPrimary = Color(0xFF1A237E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: recruiterPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    size: 20.sp,
                    color: recruiterPrimary,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  'Hoạt động gần đây',
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: recruiterPrimary,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => _RecentActivityListScreen(
                      activities: recentActivities,
                      detailScreenBuilder: detailScreenBuilder,
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Xem tất cả',
                    style: textTheme.bodyMedium?.copyWith(
                      color: recruiterPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14.sp,
                    color: recruiterPrimary,
                  ),
                ],
              ),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        // Card List
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10.r,
                offset: Offset(0, 4.h),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.1),
              width: 1.w,
            ),
          ),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: recentActivities.length > 3 ? 3 : recentActivities.length,
            separatorBuilder: (_, __) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Divider(
                height: 1.h,
                color: Colors.grey.withValues(alpha: 0.1),
              ),
            ),
            itemBuilder: (context, index) {
              final activity = recentActivities[index];
              return _ActivityItem(
                activity: activity,
                detailScreenBuilder: detailScreenBuilder,
              );
            },
          ),
        ),
      ],
    );
  }
}

//
// ------------------------
// ITEM ACTIVITY
// ------------------------
//
class _ActivityItem extends StatelessWidget {
  final Map<String, dynamic> activity;
  final Widget Function(Map<String, dynamic>) detailScreenBuilder;

  const _ActivityItem({
    required this.activity,
    required this.detailScreenBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final title = activity['title'] ?? 'Không có tiêu đề';
    final time = activity['time'] ?? '';
    final icon = activity['icon'] ?? Icons.info_outline;
    final color = activity['color'] ?? Colors.blue;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => detailScreenBuilder(activity)),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 4.r,
                    offset: Offset(0, 2.h),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 22.sp,
                color: color,
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    time,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18.sp,
              color: const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}

// SCREEN: XEM TẤT CẢ HOẠT ĐỘNG
class _RecentActivityListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> activities;
  final Widget Function(Map<String, dynamic>) detailScreenBuilder;

  const _RecentActivityListScreen({
    required this.activities,
    required this.detailScreenBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hoạt động gần đây",
          style: textTheme.titleLarge?.copyWith(fontSize: 18.sp),
        ),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16.r),
        itemCount: activities.length,
        separatorBuilder: (_, __) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _ActivityItem(
            activity: activity,
            detailScreenBuilder: detailScreenBuilder,
          );
        },
      ),
    );
  }
}