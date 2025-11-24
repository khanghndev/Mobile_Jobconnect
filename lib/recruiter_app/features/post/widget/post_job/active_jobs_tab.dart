import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/recruiter_app/features/post/screens/hr_detail_post_job_screen.dart';

class ActiveJobsTab extends StatefulWidget {
  final List<JobPostingModel> jobPostings;
  final List<JobApplicationModel> jobApplicationsList;

  /// Callback khi bấm "Ngưng tuyển"
  final Future<void> Function(String jobId) onStopRecruiting;

  /// Callback để refresh dữ liệu
  final Future<void> Function()? onRefresh;

  const ActiveJobsTab({
    super.key,
    required this.jobPostings,
    required this.jobApplicationsList,
    required this.onStopRecruiting,
    this.onRefresh,
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
        Icon(icon, size: 16.sp, color: Colors.grey.shade600),
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
      final matchesSearch = job.title.toLowerCase().contains(_activeSearch.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();

    return RefreshIndicator(
      onRefresh: widget.onRefresh ?? () async {},
      color: const Color(0xFF2563EB),
      child: Container(
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
                  Icon(Icons.visibility, color: const Color(0xFF2563EB), size: 22.sp),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${filtered.length} tin đang hiển thị',
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
                physics: const AlwaysScrollableScrollPhysics(), // Cho phép pull-to-refresh
                padding: EdgeInsets.all(16.w),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final job = filtered[index];
                  final applicantCount = widget.jobApplicationsList
                      .where((app) => app.idJobPost == job.idJobPost)
                      .length;
                  return _buildActiveJobCard(job, applicantCount);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate đến màn hình chi tiết
  void _navigateToDetail(JobPostingModel job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HrDetailPostJobScreen(jobPosting: job),
      ),
    );
  }

  /// Xử lý ngưng tuyển
  Future<void> _handleStopRecruiting(String jobId) async {
    // Hiển thị dialog xác nhận
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận ngưng tuyển'),
        content: const Text('Bạn có chắc chắn muốn ngưng tuyển dụng cho tin đăng này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ngưng tuyển'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.onStopRecruiting(jobId);
        if (!mounted) return;
        // Refresh dữ liệu sau khi ngưng tuyển
        await widget.onRefresh?.call();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã ngưng tuyển dụng thành công'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildActiveJobCard(JobPostingModel job, int applicantCount) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final daysDiff = job.applicationDeadline?.difference(now).inDays ?? 0;
    final statusText = daysDiff >= 0 ? 'Còn $daysDiff ngày' : 'Quá hạn ${-daysDiff} ngày';
    final isUrgent = job.isFeatured == 1;

    return InkWell(
      onTap: () => _navigateToDetail(job),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
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
                      Icon(Icons.access_time, color: const Color(0xFF2563EB), size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        statusText,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF2563EB),
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  if (isUrgent)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.priority_high, color: Colors.red, size: 14.sp),
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
                job.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16.sp, color: Colors.grey.shade600),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      job.location,
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
                  _buildJobInfoChip(
                    Icons.calendar_today_outlined,
                    'Đăng: ${DateFormat('dd/MM/yyyy').format(job.createdAt)}',
                  ),
                  SizedBox(width: 16.w),
                  _buildJobInfoChip(
                    Icons.event_busy_outlined,
                    'Hạn: ${job.applicationDeadline != null ? DateFormat('dd/MM/yyyy').format(job.applicationDeadline!) : 'N/A'}',
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  _buildJobInfoChip(Icons.person_outline, '$applicantCount ứng viên'),
                  SizedBox(width: 16.w),
                  _buildJobInfoChip(Icons.visibility_outlined, '${_random.nextInt(81) + 20} lượt xem'),
                ],
              ),
              SizedBox(height: 16.h),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _navigateToDetail(job),
                      icon: Icon(Icons.visibility_outlined, size: 18.sp),
                      label: Text('Chi tiết'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.primaryColor,
                        side: BorderSide(color: theme.primaryColor),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleStopRecruiting(job.idJobPost),
                      icon: Icon(Icons.stop_circle_outlined, size: 18.sp),
                      label: Text('Ngưng tuyển'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
