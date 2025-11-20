import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';

class HistoryTab extends StatefulWidget {
  final List<JobPostingModel> jobPostings;
  final List<JobApplicationModel> jobApplicationsList;

  /// Callback khi bấm "Đăng lại"
  final Future<void> Function(String jobId) onRepostJob;

  const HistoryTab({
    super.key,
    required this.jobPostings,
    required this.jobApplicationsList,
    required this.onRepostJob, // truyền callback từ ngoài
  });

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Tất cả';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredJobs = widget.jobPostings.where((job) {
      final matchStatus =
          _selectedFilter == 'Tất cả' || job.postStatus == _selectedFilter;
      final matchSearch =
          job.title!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchStatus && matchSearch;
    }).toList();

    return Container(
      color: theme.colorScheme.background,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchAndFilter(theme),
            SizedBox(height: 12.h),
            _buildFilterStats(theme),
            SizedBox(height: 12.h),
            _buildJobList(filteredJobs, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: Colors.grey.shade100,
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tên công việc',
                  prefixIcon: Icon(Icons.search,
                      color: Colors.grey.shade600, size: 20.sp),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              color: Colors.grey.shade100,
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.filter_list,
                  color: Colors.grey.shade700, size: 20.sp),
              tooltip: 'Lọc tin đăng',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterStats(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: const Color(0xFFF1F5F9),
      height: 144.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildHistoryFilterCard(
            icon: Icons.article_outlined,
            title: "Tất cả",
            count: widget.jobPostings.length.toString(),
            color: theme.primaryColor,
            selected: _selectedFilter == 'Tất cả',
            onTap: () => setState(() => _selectedFilter = 'Tất cả'),
          ),
          SizedBox(width: 12.w),
          _buildHistoryFilterCard(
            icon: Icons.check_circle_outline,
            title: "Đang hoạt động",
            count: widget.jobPostings
                .where((job) => job.postStatus == 'open')
                .length
                .toString(),
            color: Colors.green,
            selected: _selectedFilter == 'open',
            onTap: () => setState(() => _selectedFilter = 'open'),
          ),
          SizedBox(width: 12.w),
          _buildHistoryFilterCard(
            icon: Icons.access_time,
            title: "Hết hạn",
            count: widget.jobPostings
                .where((job) => job.postStatus == 'closed')
                .length
                .toString(),
            color: Colors.grey,
            selected: _selectedFilter == 'closed',
            onTap: () => setState(() => _selectedFilter = 'closed'),
          ),
          SizedBox(width: 12.w),
          _buildHistoryFilterCard(
            icon: Icons.hourglass_empty,
            title: "Chờ xác nhận",
            count: widget.jobPostings
                .where((job) => job.postStatus == 'waiting')
                .length
                .toString(),
            color: Colors.orange,
            selected: _selectedFilter == 'waiting',
            onTap: () => setState(() => _selectedFilter = 'waiting'),
          ),
        ],
      ),
    );
  }

  Widget _buildJobList(List<JobPostingModel> jobs, ThemeData theme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: jobs.length,
      itemBuilder: (context, index) {
        final job = jobs[index];
        final applicantCount = widget.jobApplicationsList
            .where((app) => app.idJobPost == job.idJobPost)
            .length;
        return _buildHistoryJobCard(job, applicantCount, theme);
      },
    );
  }

  Widget _buildHistoryFilterCard({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 100.w,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 4.h),
            Text(
              count,
              style: TextStyle(
                  fontSize: 18.sp, fontWeight: FontWeight.bold, color: color),
            ),
            SizedBox(height: 2.h),
            Text(
              title,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryJobCard(
      JobPostingModel job, int applicantCount, ThemeData theme) {
    Color statusColor;
    String statusText;
    switch (job.postStatus) {
      case 'open':
        statusColor = Colors.green;
        statusText = "Đang hoạt động";
        break;
      case 'closed':
        statusColor = Colors.grey;
        statusText = "Hết hạn";
        break;
      default:
        statusColor = Colors.orange;
        statusText = "Chờ xác nhận";
    }

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
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job.title ?? '',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.bold, fontSize: 16.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    statusText,
                    style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        color: statusColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            // Info
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14.sp, color: Colors.grey.shade600),
                SizedBox(width: 4.w),
                Text(
                  'Đăng ngày:',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontSize: 13.sp, color: Colors.grey.shade600),
                ),
                SizedBox(width: 16.w),
                Icon(Icons.person_outline,
                    size: 14.sp, color: Colors.grey.shade600),
                SizedBox(width: 4.w),
                Text(
                  "$applicantCount ứng viên",
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontSize: 13.sp, color: Colors.grey.shade600),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to detail page
                    },
                    icon: Icon(Icons.visibility_outlined, size: 16.sp),
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
                    onPressed: () async {
                      try {
                        await widget.onRepostJob(job.idJobPost!);
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Cập nhật trạng thái thành công')),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi: ${e.toString()}')),
                        );
                      }
                    },
                    icon: Icon(Icons.refresh, size: 16.sp),
                    label: Text('Đăng lại'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: job.postStatus == 'closed'
                          ? Colors.amber.shade800
                          : Colors.grey.shade400,
                      side: BorderSide(
                        color: job.postStatus == 'closed'
                            ? Colors.amber.shade800
                            : Colors.grey.shade400,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
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
