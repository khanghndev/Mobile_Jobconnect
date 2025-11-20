import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';

class PendingJobsTab extends StatelessWidget {
  final List<JobPostingModel> jobPostings;
  final Future<void> Function(String jobId) onCancelJob;
  final void Function(String jobId) onEditJob;

  const PendingJobsTab({
    super.key,
    required this.jobPostings,
    required this.onCancelJob,
    required this.onEditJob,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final pendingJobs = jobPostings
        .where((job) => job.postStatus == 'waiting')
        .toList();

    return Container(
      color: theme.colorScheme.background,
      child: pendingJobs.isEmpty
          ? _buildEmptyPendingState(theme)
          : Column(
              children: [
                _buildHeader(theme, pendingJobs.length),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.w),
                    itemCount: pendingJobs.length,
                    itemBuilder: (context, index) {
                      final job = pendingJobs[index];
                      return _buildPendingJobCard(context, theme, job);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(ThemeData theme, int count) {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: const Color(0xFFFFF4E6),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFFED8936),
            size: 24,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tin đăng chờ xác thực',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFED8936),
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Bạn có $count tin đang chờ xác thực. Tin sẽ được hiển thị sau khi được duyệt.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingJobCard(
      BuildContext context, ThemeData theme, JobPostingModel job) {
    final bool needsEdit = job.postStatus != 'waiting';
    final Color statusColor = needsEdit ? Colors.red : const Color(0xFFED8936);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  needsEdit
                      ? Icons.warning_amber_outlined
                      : Icons.pending_outlined,
                  color: statusColor,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  needsEdit ? 'Cần chỉnh sửa' : 'Chờ kiểm duyệt',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title ?? '',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        job.location ?? '',
                        maxLines: 4,
                        overflow: TextOverflow.visible,
                        softWrap: true,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Gửi ngày: ${DateFormat('dd/MM/yyyy').format(job.createdAt ?? DateTime.now())}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: statusColor, size: 16.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Chờ kiểm duyệt nội dung',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14.sp,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onEditJob(job.idJobPost!),
                        icon: Icon(Icons.edit_outlined, size: 16.sp),
                        label: const Text('Chỉnh sửa'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: statusColor,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          side: BorderSide(color: statusColor),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async => await onCancelJob(job.idJobPost!),
                        icon: Icon(Icons.delete_outline, size: 16.sp),
                        label: const Text('Hủy đăng'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPendingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80.sp,
            color: Colors.green.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            "Không có tin đăng nào đang chờ xác thực",
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Tất cả tin đăng của bạn đã được phê duyệt",
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
