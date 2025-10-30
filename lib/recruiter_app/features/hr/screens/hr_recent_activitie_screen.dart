import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/recruiter_app/features/hr/screens/hr_detail_recent_activitie_screen.dart';

class HrRecentActivitieScreen extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const HrRecentActivitieScreen({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hoạt động gần đây',
          style: tt.titleLarge?.copyWith(color: cs.onSurface),
        ),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: activities.isEmpty
          ? Center(
              child: Text(
                'Không có hoạt động nào gần đây.',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            )
          : ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: activities.length,
              separatorBuilder: (context, index) =>
                  Divider(height: 1, color: cs.outlineVariant),
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ListTile(
                  leading: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: (activity['color'] as Color).withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      activity['icon'] as IconData,
                      size: 24.sp,
                      color: activity['color'] as Color,
                    ),
                  ),
                  title: Text(
                    activity['title'] as String,
                    style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    activity['time'] as String,
                    style:
                        tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios,
                      size: 16.sp, color: cs.onSurfaceVariant),
                  
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HrDetailRecentActivitieScreen(
                          title: activity['title'] as String,
                          time: activity['time'] as String,
                          description: activity['description'] ??'Không có mô tả chi tiết.',
                          icon: activity['icon'] as IconData,
                          color: activity['color'] as Color,
                          details: activity['details'] as List<String>?,
                          attachments: activity['attachments'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}