import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/features/job/model/smart_schedule_model.dart';
import 'package:job_connect/config/widgets/info_chip.dart';

class SmartScheduleResultScreen extends StatelessWidget {
  final SmartScheduleModel schedule;

  const SmartScheduleResultScreen({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppbarTitleLarge(title: "Kết quả lịch thông minh"),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: ListView.builder(
          itemCount: schedule.clusters.length,
          itemBuilder: (context, clusterIndex) {
            final cluster = schedule.clusters[clusterIndex];

            return Container(
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: ExpansionTile(
                tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                collapsedBackgroundColor: theme.cardColor,
                backgroundColor: theme.cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Cluster label
                    Expanded(
                      child: Text(
                        cluster.label,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),

                    // Badge % từ description
                    Builder(builder: (_) {
                      // Lấy % từ description
                      final match = RegExp(r'(\d+)%').firstMatch(cluster.description);
                      int percent = match != null ? int.parse(match.group(1)!) : 0;

                      // Chọn màu theo % 
                      Color badgeColor;
                      if (percent > 70) {
                        badgeColor = Colors.green;
                      } else if (percent >= 50) {
                        badgeColor = Colors.yellow[700]!;
                      } else if (percent >= 30) {
                        badgeColor = Colors.blue;
                      } else {
                        badgeColor = Colors.redAccent;
                      }

                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(60.r),
                          border: Border.all(color: badgeColor, width: 1.5.w),
                        ),
                        child: Text(
                          "$percent%",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    cluster.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                children: cluster.jobs.map((clusterJob) {
                  final job = clusterJob.job;
                  final company = job.company;

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: theme.primaryColor.withValues(alpha:0.3)),
                      gradient: LinearGradient(
                        colors: [theme.primaryColor.withValues(alpha:0.05), theme.cardColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Job title
                        Text(
                          job.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        // Company info
                        Text(
                          company?.companyName ?? "Chưa có công ty",
                          style: theme.textTheme.bodyMedium,
                        ),
                        SizedBox(height: 8.h),

                        // Section: Job details
                        SectionTitle(
                          title: "Thông tin công việc",
                          icon: Icons.work_outline_rounded,
                          iconColor: Colors.black.withValues(alpha: 0.7),
                          textColor: Colors.black.withValues(alpha: 0.7),
                        ),
                        SizedBox(height: 8.h),
                        Table(
                          columnWidths: const {
                            0: FlexColumnWidth(1.5), // cột 1 rộng hơn
                            1: FlexColumnWidth(2),   // cột 2
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          border: TableBorder.all(
                            color: theme.primaryColor.withValues(alpha:0.3),
                            width: 1,
                          ),
                          children: [
                            TableRow(
                              decoration: BoxDecoration(color: theme.primaryColor.withValues(alpha:0.05)),
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                                  child: Text("Địa điểm:", style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                                  child: Text(job.location, style: theme.textTheme.bodySmall),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                                  child: Text("Khoảng cách:", style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                                  child: Text("${clusterJob.distanceKm?.toStringAsFixed(1) ?? 0} km", style: theme.textTheme.bodySmall),
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: BoxDecoration(color: theme.primaryColor.withValues(alpha:0.05)),
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                                  child: Text("Mức lương:", style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                                  child: Text("${job.salary} VNĐ", style: theme.textTheme.bodySmall),
                                ),
                              ],
                            ),
                            TableRow(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                                  child: Text("Loại công việc:", style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                                  child: Text(job.workType, style: theme.textTheme.bodySmall),
                                ),
                              ],
                            ),
                            TableRow(
                              decoration: BoxDecoration(color: theme.primaryColor.withValues(alpha:0.05)),
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                                  child: Text("Kinh nghiệm:", style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                                  child: Text(job.experienceLevel, style: theme.textTheme.bodySmall),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // Section: Scores
                        SectionTitle(
                          title: "Điểm đánh giá",
                          icon: Icons.star_rounded,
                          iconColor: Colors.black.withValues(alpha: 0.7),
                          textColor: Colors.black.withValues(alpha: 0.7),
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: [
                            InfoChip(
                              label: "Skill: ${clusterJob.skillScore.toStringAsFixed(1)}",
                              color: theme.primaryColor,
                              isHighlighted: true,
                            ),
                            InfoChip(
                              label: "Schedule: ${clusterJob.scheduleScore.toStringAsFixed(1)}",
                              color: theme.primaryColor,
                              isHighlighted: true,
                            ),
                            InfoChip(
                              label: "Geo: ${clusterJob.geoScore.toStringAsFixed(1)}",
                              color: theme.primaryColor,
                              isHighlighted: true,
                            ),
                            InfoChip(
                              label: "Final: ${clusterJob.finalScore.toStringAsFixed(1)}",
                              color: theme.primaryColor,
                              isHighlighted: true,
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // Section: Schedule summary
                        SectionTitle(
                          title: "Tóm tắt lịch làm việc",
                          icon: Icons.schedule_rounded,
                          iconColor: Colors.black.withValues(alpha: 0.7),
                          textColor: Colors.black.withValues(alpha: 0.7),
                        ),
                        SizedBox(height: 8.h),
                        InfoChip(
                              label: clusterJob.scheduleSummary,
                              color: theme.primaryColor,
                              isHighlighted: true,
                            ),
                        SizedBox(height: 8.h),

                        // Section: Matched skills
                        SectionTitle(
                          title: "Kỹ năng phù hợp",
                          icon: Icons.star_border_rounded,
                          iconColor: Colors.black.withValues(alpha: 0.7),
                          textColor: Colors.black.withValues(alpha: 0.7),
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: (job.matchedSkills ?? [])
                              .map((skill) => InfoChip(
                                    label: skill,
                                    color: theme.primaryColor,
                                    isHighlighted: true,
                                  ))
                              .toList(),
                        ),
                        SizedBox(height: 6.h),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
