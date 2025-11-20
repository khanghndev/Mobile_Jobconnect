import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';

class ActiveJobsTab extends StatefulWidget {
  final List<JobPostingModel> jobPostings;
  final List<JobApplicationModel> jobApplicationsList;

  const ActiveJobsTab({
    super.key,
    required this.jobPostings,
    required this.jobApplicationsList,
  });

  @override
  State<ActiveJobsTab> createState() => _ActiveJobsTabState();
}

class _ActiveJobsTabState extends State<ActiveJobsTab> {
  final Random _random = Random();
  String _activeSearch = '';

  Widget _buildJobInfoChip(IconData icon, String label) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: Colors.grey.shade600),
        SizedBox(width: 4.w),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 12.sp, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filtered = widget.jobPostings.where((job) {
      final matchesStatus = job.postStatus == 'open';
      final matchesSearch = job.title!.toLowerCase().contains(_activeSearch.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();

    final activeJobs = filtered.map((job) {
      final now = DateTime.now();
      final daysDiff = job.applicationDeadline!.difference(now).inDays;
      final statusText = daysDiff >= 0 ? 'Còn $daysDiff ngày' : 'Quá hạn ${-daysDiff} ngày';

      return {
        'idJobPost': job.idJobPost,
        'title': job.title,
        'location': job.location,
        'posted': DateFormat('dd/MM/yyyy').format(job.createdAt ?? now),
        'expires': DateFormat('dd/MM/yyyy').format(job.applicationDeadline ?? now),
        'views': _random.nextInt(81) + 20,
        'status': statusText,
        'isUrgent': job.isFeatured == 1,
      };
    }).toList();

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Search
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: Colors.grey.shade100,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm tin đăng',
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade600, size: 20.sp),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      onChanged: (v) => setState(() => _activeSearch = v),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stats
          Container(
            padding: EdgeInsets.all(16.w),
            color: const Color(0xFFE6EFFF),
            child: Row(
              children: [
                Icon(Icons.visibility, color: const Color(0xFF2563EB), size: 24.sp),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${activeJobs.length} tin đang hiển thị',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    Text(
                      'Tin của bạn đang được người tìm việc xem',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Job list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: activeJobs.length,
              itemBuilder: (context, index) {
                final job = activeJobs[index];
                final applicantCount = widget.jobApplicationsList
                    .where((app) => app.idJobPost == job['idJobPost'])
                    .length;
                return _buildActiveJobCard(job, applicantCount);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveJobCard(Map<String, dynamic> job, int applicantCount) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, color: const Color(0xFF2563EB), size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      job['status'],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
                if (job['isUrgent'])
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.priority_high, color: Colors.red, size: 12.sp),
                        SizedBox(width: 4.w),
                        Text(
                          'Gấp',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              job['title'],
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14.sp, color: Colors.grey.shade600),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    job['location'],
                    maxLines: 4,
                    overflow: TextOverflow.visible,
                    style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 14.sp, color: Colors.grey.shade600),
                  ),
                )
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _buildJobInfoChip(Icons.calendar_today_outlined, 'Đăng: ${job['posted']}'),
                SizedBox(width: 16.w),
                _buildJobInfoChip(Icons.event_busy_outlined, 'Hạn: ${job['expires']}'),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _buildJobInfoChip(Icons.person_outline, '$applicantCount ứng viên'),
                SizedBox(width: 16.w),
                _buildJobInfoChip(Icons.visibility_outlined, '${job['views']} lượt xem'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
