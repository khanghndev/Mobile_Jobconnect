import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/config/widgets/info_chip.dart';
import 'package:job_connect/data/models/job_posting_model.dart';

class JobOverviewCard extends StatelessWidget {
  final JobPostingModel jobPosting;
  final int applicantCount;

  const JobOverviewCard({
    super.key,
    required this.jobPosting,
    required this.applicantCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildDetailItem({
      required IconData icon,
      required String title,
      required String value,
      required Color color,
    }) {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1.5.w,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 26.w,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Card(
      elevation: 4,
      shadowColor: theme.shadowColor.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      color: theme.cardColor,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionTitle(
              title: "Tổng quan công ty",
              icon: Icons.location_city,
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                InfoChip(
                  icon: Icons.location_pin,
                  label: jobPosting.location,
                  color: theme.colorScheme.secondary,
                  isHighlighted: true,
                ),
                InfoChip(
                  icon: Icons.calendar_month_rounded,
                  label: FormatUtils.formattedDateTime(jobPosting.createdAt),
                  color: theme.colorScheme.tertiary,
                ),
                InfoChip(
                  icon: Icons.work_history_outlined,
                  label: jobPosting.workType,
                  color: theme.colorScheme.tertiary,
                ),
                InfoChip(
                  icon: Icons.leaderboard_outlined,
                  label: jobPosting.experienceLevel,
                  color: theme.colorScheme.tertiary,
                ),
              ],
            ),
            Divider(
              height: 35.h,
              thickness: 0.8.w,
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: buildDetailItem(
                    icon: Icons.payments_rounded,
                    title: "Mức Lương",
                    value: FormatUtils.formatSalary(jobPosting.salary ?? 0),
                    color: theme.colorScheme.secondary,
                  ),
                ),
                Container(
                  height: 50.h,
                  width: 1.w,
                  color: theme.dividerColor.withValues(alpha: 0.4),
                ),
                Expanded(
                  child: buildDetailItem(
                    icon: Icons.groups_2_outlined,
                    title: "Ứng Viên",
                    value: '$applicantCount',
                    color: theme.colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
