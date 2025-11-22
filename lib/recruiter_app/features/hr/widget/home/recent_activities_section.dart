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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hoạt động gần đây',
              style: textTheme.titleLarge?.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
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
              child: Text(
                'Xem tất cả',
                style: textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF3366FF),
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // Card List
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: recentActivities.length > 3 ? 3 : recentActivities.length,
            separatorBuilder: (_, __) => Divider(height: 1.h),
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
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 8.h,
        ),
        leading: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            icon,
            size: 22.sp, // 🔥 chuẩn hóa icon size
            color: color,
          ),
        ),
        title: Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          time,
          style: textTheme.bodySmall?.copyWith(
            fontSize: 13.sp,
            color: Colors.black54,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Colors.black45,
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