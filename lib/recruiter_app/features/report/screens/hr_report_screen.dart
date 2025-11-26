import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/job/service/job_application_service.dart';
import 'package:job_connect/features/job/service/job_posting_service.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:job_connect/recruiter_app/services/recruiter_service.dart';
import 'package:provider/provider.dart';

class HrReportScreen extends StatefulWidget {
  final String? recruiterId;
  final String? companyId;

  const HrReportScreen({
    super.key,
    this.recruiterId,
    this.companyId,
  });

  @override
  State<HrReportScreen> createState() => _HrReportScreenState();
}

class _HrReportScreenState extends State<HrReportScreen> {
  final JobPostingService _jobPostingService = JobPostingService();
  final JobApplicationService _jobApplicationService = JobApplicationService();
  final RecruiterService _recruiterService = RecruiterService();

  List<JobPostingModel> _jobPostings = [];
  List<JobApplicationModel> _jobApplications = [];
  bool _isLoading = true;
  String? _error;
  String _selectedPeriod = 'Tháng này';
  String _selectedChartType = 'Ứng viên';

  @override
  void initState() {
    super.initState();
    debugPrint('🔵 HrReportScreen initState - recruiterId: ${widget.recruiterId}');
    debugPrint('🔵 HrReportScreen initState - companyId: ${widget.companyId}');
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      debugPrint('📊 Loading report data...');
      debugPrint('📊 RecruiterId from widget: ${widget.recruiterId}');
      debugPrint('📊 CompanyId from widget: ${widget.companyId}');

      // Lấy recruiterId từ widget hoặc từ UserViewModel
      String? recruiterId = widget.recruiterId;
      if (recruiterId == null || recruiterId.isEmpty) {
        try {
          final userVM = context.read<UserViewModel>();
          recruiterId = userVM.currentUser?.idUser;
          debugPrint('📊 RecruiterId from UserViewModel: $recruiterId');
        } catch (e) {
          debugPrint('❌ Error reading UserViewModel: $e');
        }
      }

      String? companyId = widget.companyId;

      // Nếu không có companyId, lấy từ recruiterId
      if ((companyId == null || companyId.isEmpty) && 
          recruiterId != null && recruiterId.isNotEmpty) {
        try {
          debugPrint('📊 Fetching recruiter info for: $recruiterId');
          final recruiter = await _recruiterService.getRecruiterById(id: recruiterId);
          companyId = recruiter?.idCompany;
          debugPrint('📊 Fetched companyId: $companyId');
        } catch (e) {
          debugPrint('❌ Error fetching recruiter: $e');
          // Bỏ qua lỗi
        }
      }

      List<JobPostingModel> jobPostings = [];
      List<JobApplicationModel> jobApplications = [];

      if (companyId != null && companyId.isNotEmpty) {
        debugPrint('📊 Fetching job postings for company: $companyId');
        jobPostings = await _jobPostingService.getJobPostingsByCompany(
          companyId: companyId,
        );
        debugPrint('📊 Fetched ${jobPostings.length} job postings');

        // Lấy tất cả job applications cho các job postings (song song)
        final jobAppFutures = jobPostings
            .where((job) => job.idJobPost.isNotEmpty)
            .map((job) => _jobApplicationService
                .getApplicationsByJobPost(jobPostId: job.idJobPost)
                .catchError((e) {
                  debugPrint('❌ Error fetching applications for job ${job.idJobPost}: $e');
                  return <JobApplicationModel>[];
                }))
            .toList();

        debugPrint('📊 Fetching applications for ${jobAppFutures.length} jobs...');
        final jobAppResults = await Future.wait(jobAppFutures);
        jobApplications = jobAppResults.expand((list) => list).toList();
        debugPrint('📊 Fetched ${jobApplications.length} applications');
      } else {
        debugPrint('⚠️ No companyId available. Cannot fetch data.');
        setState(() {
          _error = 'Không tìm thấy thông tin công ty. Vui lòng kiểm tra lại.';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _jobPostings = jobPostings;
        _jobApplications = jobApplications;
        _isLoading = false;
      });
      debugPrint('✅ Report data loaded successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading report data: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      setState(() {
        _error = 'Lỗi khi tải dữ liệu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  // Tính toán thống kê
  Map<String, dynamic> _calculateStatistics() {
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final lastMonthStart = DateTime(now.year, now.month - 1, 1);

    // Lọc theo thời gian
    List<JobApplicationModel> filteredApplications = _jobApplications;
    if (_selectedPeriod == 'Tháng này') {
      filteredApplications = _jobApplications.where((app) {
        final appDate = app.submittedAt;
        return appDate.isAfter(thisMonthStart) || appDate.isAtSameMomentAs(thisMonthStart);
      }).toList();
    } else if (_selectedPeriod == 'Tháng trước') {
      filteredApplications = _jobApplications.where((app) {
        final appDate = app.submittedAt;
        return appDate.isAfter(lastMonthStart) && appDate.isBefore(thisMonthStart);
      }).toList();
    }

    // Thống kê
    final totalApplications = filteredApplications.length;
    final pendingApps = filteredApplications.where((app) => app.applicationStatus == 'pending').length;
    final viewedApps = filteredApplications.where((app) => app.applicationStatus == 'viewed').length;
    final interviewApps = filteredApplications.where((app) => app.applicationStatus == 'interview').length;
    final acceptedApps = filteredApplications.where((app) => app.applicationStatus == 'accepted').length;
    final rejectedApps = filteredApplications.where((app) => app.applicationStatus == 'rejected').length;

    final activeJobs = _jobPostings.where((job) => job.postStatus == 'open').length;
    final closedJobs = _jobPostings.where((job) => job.postStatus == 'closed').length;
    final totalJobs = _jobPostings.length;

    // Tính tỷ lệ chuyển đổi
    final conversionRate = totalApplications > 0
        ? ((acceptedApps / totalApplications) * 100).toStringAsFixed(1)
        : '0.0';

    return {
      'totalApplications': totalApplications,
      'pendingApps': pendingApps,
      'viewedApps': viewedApps,
      'interviewApps': interviewApps,
      'acceptedApps': acceptedApps,
      'rejectedApps': rejectedApps,
      'activeJobs': activeJobs,
      'closedJobs': closedJobs,
      'totalJobs': totalJobs,
      'conversionRate': conversionRate,
    };
  }

  // Dữ liệu cho biểu đồ
  List<Map<String, dynamic>> _getChartData() {
    final stats = _calculateStatistics();
    
    if (_selectedChartType == 'Ứng viên') {
      return [
        {'label': 'Chờ xử lý', 'value': stats['pendingApps'], 'color': Colors.orange},
        {'label': 'Đã xem', 'value': stats['viewedApps'], 'color': Colors.blue},
        {'label': 'Phỏng vấn', 'value': stats['interviewApps'], 'color': Colors.purple},
        {'label': 'Đã chấp nhận', 'value': stats['acceptedApps'], 'color': Colors.green},
        {'label': 'Đã từ chối', 'value': stats['rejectedApps'], 'color': Colors.red},
      ];
    } else {
      return [
        {'label': 'Đang tuyển', 'value': stats['activeJobs'], 'color': Colors.green},
        {'label': 'Đã đóng', 'value': stats['closedJobs'], 'color': Colors.grey},
      ];
    }
  }

  // Dữ liệu cho bảng
  List<Map<String, dynamic>> _getTableData() {
    final stats = _calculateStatistics();
    return [
      {
        'metric': 'Tổng số đơn ứng tuyển',
        'value': stats['totalApplications'].toString(),
        'icon': Icons.description_outlined,
        'color': Colors.blue,
      },
      {
        'metric': 'Đơn đang chờ xử lý',
        'value': stats['pendingApps'].toString(),
        'icon': Icons.hourglass_empty,
        'color': Colors.orange,
      },
      {
        'metric': 'Đơn đã được xem',
        'value': stats['viewedApps'].toString(),
        'icon': Icons.visibility_outlined,
        'color': Colors.blue,
      },
      {
        'metric': 'Đang phỏng vấn',
        'value': stats['interviewApps'].toString(),
        'icon': Icons.record_voice_over_outlined,
        'color': Colors.purple,
      },
      {
        'metric': 'Đã chấp nhận',
        'value': stats['acceptedApps'].toString(),
        'icon': Icons.check_circle_outline,
        'color': Colors.green,
      },
      {
        'metric': 'Đã từ chối',
        'value': stats['rejectedApps'].toString(),
        'icon': Icons.cancel_outlined,
        'color': Colors.red,
      },
      {
        'metric': 'Tỷ lệ chuyển đổi',
        'value': '${stats['conversionRate']}%',
        'icon': Icons.trending_up,
        'color': Colors.teal,
      },
      {
        'metric': 'Công việc đang tuyển',
        'value': stats['activeJobs'].toString(),
        'icon': Icons.work_outline,
        'color': Colors.green,
      },
      {
        'metric': 'Công việc đã đóng',
        'value': stats['closedJobs'].toString(),
        'icon': Icons.block,
        'color': Colors.grey,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Báo cáo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Làm mới',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'export') {
                _exportReport();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 8),
                    Text('Xuất báo cáo'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'Lỗi: $_error',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPeriodFilter(theme),
                        SizedBox(height: 16.h),
                        _buildSummaryCards(theme),
                        SizedBox(height: 24.h),
                        _buildChartSection(theme),
                        SizedBox(height: 24.h),
                        _buildDataTable(theme),
                        SizedBox(height: 24.h),
                        _buildTopJobsSection(theme),
                        SizedBox(height: 24.h),
                        _buildTopCandidatesSection(theme),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildPeriodFilter(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, size: 20.sp, color: Colors.grey.shade600),
          SizedBox(width: 8.w),
          Text(
            'Kỳ báo cáo:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedPeriod,
              isExpanded: true,
              underline: const SizedBox(),
              items: ['Tháng này', 'Tháng trước', '3 tháng gần đây', 'Năm nay']
                  .map((period) => DropdownMenuItem(
                        value: period,
                        child: Text(period),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPeriod = value;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(ThemeData theme) {
    final stats = _calculateStatistics();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12.w,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'Tổng đơn ứng tuyển',
          stats['totalApplications'].toString(),
          Icons.description_outlined,
          Colors.blue,
          theme,
        ),
        _buildStatCard(
          'Đang phỏng vấn',
          stats['interviewApps'].toString(),
          Icons.record_voice_over_outlined,
          Colors.purple,
          theme,
        ),
        _buildStatCard(
          'Đã chấp nhận',
          stats['acceptedApps'].toString(),
          Icons.check_circle_outline,
          Colors.green,
          theme,
        ),
        _buildStatCard(
          'Tỷ lệ chuyển đổi',
          '${stats['conversionRate']}%',
          Icons.trending_up,
          Colors.teal,
          theme,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 24.sp),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 28.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontSize: 12.sp,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Biểu đồ thống kê',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: DropdownButton<String>(
                  value: _selectedChartType,
                  underline: const SizedBox(),
                  items: ['Ứng viên', 'Công việc']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type, style: TextStyle(fontSize: 12.sp)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedChartType = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _buildBarChart(theme),
        ],
      ),
    );
  }

  Widget _buildBarChart(ThemeData theme) {
    final chartData = _getChartData();
    final maxValue = chartData.isEmpty
        ? 1
        : chartData.map((e) => e['value'] as int).reduce((a, b) => a > b ? a : b);

    return SizedBox(
      height: 250.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: chartData.map((data) {
          final value = data['value'] as int;
          final label = data['label'] as String;
          final color = data['color'] as Color;
          final height = maxValue > 0 ? (value / maxValue) * 200.h : 0.0;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: double.infinity,
                    height: height,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.r),
                        topRight: Radius.circular(8.r),
                      ),
                    ),
                    child: Center(
                      child: value > 0
                          ? Text(
                              value.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : const SizedBox(),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDataTable(ThemeData theme) {
    final tableData = _getTableData();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bảng thống kê chi tiết',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          ...tableData.map((row) => _buildTableRow(row, theme)),
        ],
      ),
    );
  }

  Widget _buildTableRow(Map<String, dynamic> row, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: (row['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              row['icon'] as IconData,
              color: row['color'] as Color,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              row['metric'] as String,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            row['value'] as String,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: row['color'] as Color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopJobsSection(ThemeData theme) {
    final topJobs = _jobPostings
        .where((job) => job.postStatus == 'open')
        .take(5)
        .toList();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top công việc đang tuyển',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (topJobs.length > 5)
                TextButton(
                  onPressed: () {},
                  child: Text('Xem tất cả', style: TextStyle(fontSize: 12.sp)),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          if (topJobs.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.h),
                child: Text(
                  'Chưa có công việc nào',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            ...topJobs.asMap().entries.map((entry) {
              final index = entry.key;
              final job = entry.value;
              final applicantCount = _jobApplications
                  .where((app) => app.idJobPost == job.idJobPost)
                  .length;

              return Padding(
                padding: EdgeInsets.only(bottom: index < topJobs.length - 1 ? 12.h : 0),
                child: Row(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A237E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A237E),
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '$applicantCount ứng viên',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      onPressed: () {
                        // Navigate to job detail
                      },
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTopCandidatesSection(ThemeData theme) {
    final topCandidates = _jobApplications
        .where((app) => app.applicationStatus == 'accepted')
        .take(5)
        .toList();

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ứng viên đã chấp nhận',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (topCandidates.length > 5)
                TextButton(
                  onPressed: () {},
                  child: Text('Xem tất cả', style: TextStyle(fontSize: 12.sp)),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          if (topCandidates.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.h),
                child: Text(
                  'Chưa có ứng viên nào được chấp nhận',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            )
          else
            ...topCandidates.asMap().entries.map((entry) {
              final index = entry.key;
              final app = entry.value;
              final job = _jobPostings.firstWhere(
                (j) => j.idJobPost == app.idJobPost,
                orElse: () => _jobPostings.first,
              );

              return Padding(
                padding: EdgeInsets.only(bottom: index < topCandidates.length - 1 ? 12.h : 0),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.green,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ứng viên ${index + 1}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            job.title,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                              fontSize: 12.sp,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        'Đã chấp nhận',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  void _exportReport() {
    //   Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng xuất báo cáo đang được phát triển'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
