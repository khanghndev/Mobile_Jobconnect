import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/status_helper.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/widgets/job_history/stat_item.dart';

class StatsSummary extends StatelessWidget {
  final List<JobApplicationModel> applications;
  final String? selectedFilter;
  final String closedGroupFilterKey;
  final void Function(String?) onFilterSelected;

  const StatsSummary({
    super.key,
    required this.applications,
    required this.selectedFilter,
    required this.closedGroupFilterKey,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int totalApplications = applications.length;
    int pendingApplications =
        applications.where((job) => job.applicationStatus == AppStatus.pending).length;
    int acceptedApplications =
        applications.where((job) => job.applicationStatus == AppStatus.accepted).length;
    int closedApplications =
        applications
            .where((job) =>
                job.applicationStatus == AppStatus.rejected ||
                job.applicationStatus == AppStatus.viewed ||
                job.applicationStatus == AppStatus.interview)
            .length;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF1E1E1E)
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 15.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              StatItem(
                count: totalApplications.toString(),
                label: 'Tất Cả',
                icon: Icons.all_inbox_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                filterKey: null,
                isSelected: selectedFilter == null,
                onTap: onFilterSelected,
              ),
              SizedBox(width: 12.w),
              StatItem(
                count: pendingApplications.toString(),
                label: 'Đang Chờ',
                icon: Icons.hourglass_top_rounded,
                color: AppStatus.getTextColor(AppStatus.pending),
                filterKey: AppStatus.pending,
                isSelected: selectedFilter == AppStatus.pending,
                onTap: onFilterSelected,
              ),
              SizedBox(width: 12.w),
              StatItem(
                count: acceptedApplications.toString(),
                label: 'Chấp Nhận',
                icon: Icons.verified_user_outlined,
                color: AppStatus.getTextColor(AppStatus.accepted),
                filterKey: AppStatus.accepted,
                isSelected: selectedFilter == AppStatus.accepted,
                onTap: onFilterSelected,
              ),
              SizedBox(width: 12.w),
              StatItem(
                count: closedApplications.toString(),
                label: 'Đã Đóng',
                icon: Icons.inventory_2_outlined,
                color: Colors.red.shade600,
                filterKey: closedGroupFilterKey,
                isSelected: selectedFilter == closedGroupFilterKey,
                onTap: onFilterSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}