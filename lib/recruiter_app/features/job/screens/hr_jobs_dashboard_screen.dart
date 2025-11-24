import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/job/service/job_application_service.dart';
import 'package:job_connect/features/job/service/job_posting_service.dart';
import 'package:job_connect/recruiter_app/services/recruiter_service.dart';
import 'hr_job_detail_screen.dart';
import 'hr_job_list_screen.dart';

class HrJobsDashboardScreen extends StatefulWidget {
  final String idUser;

  const HrJobsDashboardScreen({
    super.key,
    required this.idUser,
  });

  @override
  State<HrJobsDashboardScreen> createState() => _HrJobsDashboardScreenState();
}

class _HrJobsDashboardScreenState extends State<HrJobsDashboardScreen> {
  static const recruiterPrimary = Color(0xFF1A237E);
  static const recruiterSecondary = Color(0xFF283593);

  bool _isLoading = true;
  List<JobPostingModel> _jobPostings = [];
  List<JobApplicationModel> _jobApplications = [];
  List<JobApplicationModel> _upcomingInterviews = [];
  List<JobPostingModel> _expiringJobs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final recruiterService = RecruiterService();
      final jobPostingService = JobPostingService();
      final jobApplicationService = JobApplicationService();

      // 1) Lấy thông tin recruiter để có companyId
      final recruiterInfo = await recruiterService.getRecruiterById(id: widget.idUser);
      if (recruiterInfo == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final companyId = recruiterInfo.idCompany;
      if (companyId == null || companyId.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // 2) Load job postings
      final jobPostings = await jobPostingService.getJobPostingsByCompany(companyId: companyId);

      // 3) Load job applications song song
      final jobAppFutures = jobPostings.where((job) => job.idJobPost.isNotEmpty).map((job) => 
        jobApplicationService.getApplicationsByJobPost(jobPostId: job.idJobPost)
          .catchError((e) => <JobApplicationModel>[])
      ).toList();
      
      final jobAppResults = await Future.wait(jobAppFutures);
      final jobApplications = jobAppResults.expand((list) => list).toList();

      // 4) Lọc lịch phỏng vấn sắp tới (trong 7 ngày tới)
      final now = DateTime.now();
      final sevenDaysLater = now.add(const Duration(days: 7));
      final upcomingInterviews = jobApplications.where((app) {
        if (app.applicationStatus != 'interview') return false;
        // Giả sử có field interviewDate, nếu không thì dùng submittedAt + 3 ngày
        final submittedAt = app.submittedAt;
        final interviewDate = submittedAt.add(const Duration(days: 3));
        return interviewDate.isAfter(now) && interviewDate.isBefore(sevenDaysLater);
      }).toList();

      // 5) Lọc tin đăng sắp hết hạn (trong 7 ngày tới)
      final expiringJobs = jobPostings.where((job) {
        final deadline = job.applicationDeadline;
        if (deadline == null) return false;
        if (job.postStatus != 'open') return false;
        return deadline.isAfter(now) &&
            deadline.isBefore(sevenDaysLater);
      }).toList();

      setState(() {
        _jobPostings = jobPostings;
        _jobApplications = jobApplications;
        _upcomingInterviews = upcomingInterviews;
        _expiringJobs = expiringJobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải dữ liệu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: recruiterPrimary, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Danh sách công việc',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: recruiterPrimary,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: recruiterPrimary, size: 22.sp),
            onPressed: _loadData,
          ),
        ],
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(recruiterPrimary),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: recruiterPrimary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Cards
                    _buildStatisticsSection(),

                    // Upcoming Interviews
                    if (_upcomingInterviews.isNotEmpty) _buildUpcomingInterviewsSection(),

                    // Expiring Jobs
                    if (_expiringJobs.isNotEmpty) _buildExpiringJobsSection(),

                    // All Jobs Button
                    _buildAllJobsSection(),

                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatisticsSection() {
    final totalJobs = _jobPostings.length;
    final openJobs = _jobPostings.where((j) => j.postStatus == 'open').length;
    final totalApplications = _jobApplications.length;
    final pendingApplications = _jobApplications.where((a) => a.applicationStatus == 'pending').length;

    return Container(
      margin: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: recruiterPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.work_outline,
                  title: 'Tổng tin đăng',
                  value: totalJobs.toString(),
                  color: recruiterPrimary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.check_circle_outline,
                  title: 'Đang tuyển',
                  value: openJobs.toString(),
                  color: Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people_outline,
                  title: 'Ứng viên',
                  value: totalApplications.toString(),
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.pending_actions,
                  title: 'Chờ xử lý',
                  value: pendingApplications.toString(),
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingInterviewsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lịch phỏng vấn sắp tới',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: recruiterPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to interview schedule
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: recruiterPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...(_upcomingInterviews.take(3).map((app) => _buildInterviewCard(app))),
        ],
      ),
    );
  }

  Widget _buildInterviewCard(JobApplicationModel app) {
    final interviewDate = app.submittedAt.add(const Duration(days: 3));
    JobPostingModel? job;
    try {
      if (app.idJobPost.isNotEmpty) {
        job = _jobPostings.firstWhere((j) => j.idJobPost == app.idJobPost);
      }
    } catch (e) {
      // Job not found
    }
    
    if (job == null) {
      if (_jobPostings.isEmpty) {
        return const SizedBox.shrink();
      }
      job = _jobPostings.first;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: recruiterPrimary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: recruiterPrimary.withValues(alpha: 0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [recruiterPrimary, recruiterSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.calendar_today, color: Colors.white, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title.isNotEmpty ? job.title : 'Công việc',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: recruiterPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14.sp, color: Colors.grey.shade600),
                    SizedBox(width: 4.w),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(interviewDate),
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: recruiterPrimary),
            onPressed: () {
              // Navigate to interview detail
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringJobsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tin đăng sắp hết hạn',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: recruiterPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobListScreen(
                        jobpostingList: _jobPostings,
                        jobApplications: _jobApplications,
                      ),
                    ),
                  );
                },
                child: Text(
                  'Xem tất cả',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: recruiterPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...(_expiringJobs.take(3).map((job) => _buildExpiringJobCard(job))),
        ],
      ),
    );
  }

  Widget _buildExpiringJobCard(JobPostingModel job) {
    final deadline = job.applicationDeadline;
    if (deadline == null) return const SizedBox.shrink();
    final daysLeft = deadline.difference(DateTime.now()).inDays;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.1),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailScreen(job: job),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title.isNotEmpty ? job.title : 'Công việc',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: recruiterPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.event_busy, size: 14.sp, color: Colors.orange),
                      SizedBox(width: 4.w),
                      Text(
                        'Còn $daysLeft ngày - ${DateFormat('dd/MM/yyyy').format(deadline)}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: recruiterPrimary),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JobDetailScreen(job: job),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllJobsSection() {
    return Container(
      margin: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quản lý công việc',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: recruiterPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [recruiterPrimary, recruiterSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: recruiterPrimary.withValues(alpha: 0.3),
                  blurRadius: 12.r,
                  offset: Offset(0, 4.h),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobListScreen(
                        jobpostingList: _jobPostings,
                        jobApplications: _jobApplications,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(16.r),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.work_outline, color: Colors.white, size: 28.sp),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xem tất cả công việc',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              '${_jobPostings.length} tin đăng',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20.sp),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

