import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/enum/post_status.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/background_error_state.dart';
import 'package:job_connect/features/company/model/company_model.dart';
import 'package:job_connect/features/company/service/company_service.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/job/model/job_transaction_model.dart';
import 'package:job_connect/features/job/service/job_application_service.dart';
import 'package:job_connect/features/job/service/job_posting_service.dart';
import 'package:job_connect/features/job/service/job_transaction_service.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import 'package:job_connect/model/recruiter_info_model.dart';
import 'package:job_connect/model/subscription_package_model.dart';
import 'package:job_connect/recruiter_app/features/job/screens/hr_job_detail_screen.dart';
import 'package:job_connect/recruiter_app/features/payments/screens/hr_subscription_screen.dart';
import 'package:job_connect/recruiter_app/features/post/widget/post_job/active_jobs_tab.dart';
import 'package:job_connect/recruiter_app/features/post/widget/post_job/history_tab.dart';
import 'package:job_connect/recruiter_app/features/post/widget/post_job/pending_jobs_tab.dart';
import 'package:job_connect/recruiter_app/features/post/widget/post_job/recruiter_info_row.dart';
import 'package:job_connect/recruiter_app/features/post/widget/post_job/recruiter_tab_bar.dart';
import 'package:job_connect/recruiter_app/features/post/widget/post_job/recruitment_tab.dart';
import 'package:job_connect/recruiter_app/features/post/widget/post_job/upgrade_posting_button.dart';
import 'package:job_connect/recruiter_app/services/recruiter_service.dart';
import 'package:job_connect/recruiter_app/services/subscriptionpackage_service.dart';

class HrPostJobScreen extends StatefulWidget {
  final String recruiterId;
  const HrPostJobScreen({super.key, required this.recruiterId});

  @override
  _HrPostJobScreenState createState() => _HrPostJobScreenState();
}

class _HrPostJobScreenState extends State<HrPostJobScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final PageController _pageController;

  final _formKey = GlobalKey<FormState>();
  final Random _random = Random();

  // Controllers cho form đăng job
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _benefitsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Lọc & tìm kiếm
  String _jobType = "fulltime";
  String _experienceLevel = "Mới đi làm";
  String _location = "TP. Hồ Chí Minh";
  bool _isUrgent = false;

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tất cả';

  // Services
  final JobPostingService _jobPostingService = JobPostingService();
  final JobApplicationService _jobApplicationService = JobApplicationService();
  final RecruiterService _recruiterService = RecruiterService();
  final UserService _accountService = UserService();
  final CompanyService _companyService = CompanyService();
  final JobTransactionService _jobTransactionService = JobTransactionService();
  final SubscriptionPackageService _subscriptionPackageService = SubscriptionPackageService();

  // Data
  UserModel? user;
  RecruiterInfoModel? recruiterInfo;
  CompanyModel? companyInfo;
  List<JobPostingModel> jobPostingsList = [];
  List<JobApplicationModel> jobApplicationsList = [];
  JobTransactionModel? transaction;
  SubscriptionPackageModel? subscriptionPackage;

  // Trạng thái
  bool isLoading = true;
  String? error;
  bool _isPremiumUser = false;

  // DatePicker
  DateTime? _selectedDeadline;
  final DateTime _defaultDeadline = DateTime.now().add(const Duration(days: 7));

  // Danh sách cố định
  final List<String> _jobTypes = [
    "fulltime", "parttime", "freelancer",
    "remote", "internship", "fresher", "senior", "junior", "contract"
  ];

  final List<String> _experienceLevels = [
    "Mới đi làm",
    "1-2 năm kinh nghiệm",
    "3-5 năm kinh nghiệm",
    "Trên 5 năm kinh nghiệm",
    "Quản lý",
  ];

  final List<String> _locations = [
    'An Giang','Bà Rịa - Vũng Tàu','Bạc Liêu','Bắc Giang','Bắc Kạn','Bắc Ninh',
    'Bến Tre','Bình Dương','Bình Định','Bình Phước','Bình Thuận','Cà Mau','Cao Bằng',
    'Cần Thơ','Đà Nẵng','Đắk Lắk','Đắk Nông','Điện Biên','Đồng Nai','Đồng Tháp',
    'Gia Lai','Hà Giang','Hà Nam','Hà Nội','Hà Tĩnh','Hải Dương','Hải Phòng',
    'Hậu Giang','Hòa Bình','Hưng Yên','Khánh Hòa','Kiên Giang','Kon Tum','Lai Châu',
    'Lâm Đồng','Lạng Sơn','Lào Cai','Long An','Nam Định','Nghệ An','Ninh Bình',
    'Ninh Thuận','Phú Thọ','Phú Yên','Quảng Bình','Quảng Nam','Quảng Ngãi','Quảng Ninh',
    'Quảng Trị','Sóc Trăng','Sơn La','Tây Ninh','Thái Bình','Thái Nguyên','Thanh Hóa',
    'Thừa Thiên Huế','Tiền Giang','TP. Hồ Chí Minh','Trà Vinh','Tuyên Quang','Vĩnh Long','Vĩnh Phúc',
    'Yên Bái',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _pageController = PageController();
    _loadAllData();
  }

  Future<void> _pickDeadline() async {
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 1),
    );
    if (date == null) return;
    setState(() => _selectedDeadline = DateTime(date.year, date.month, date.day));
  }

  Future<void> _loadAllData() async {
    try {
      final recruiter = await _recruiterService.getRecruiterById(id: widget.recruiterId);
      final account = await _accountService.getUserById(id: recruiter!.idUser);
      final company = await _companyService.getCompanyById(id: recruiter.idCompany!);

      List<JobPostingModel> jobs = [];
      if (recruiter.idCompany != null && recruiter.idCompany!.isNotEmpty) {
        jobs = await _jobPostingService.getJobPostingsByCompany(companyId: recruiter.idCompany!);
      }

      final transactions = await _jobTransactionService.getTransactionsByUserId(userId: widget.recruiterId);
      transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      final subscription = await _subscriptionPackageService.fetchSubscriptionPackageById(
        packageId: transactions[0].idPackage,
      );

      setState(() {
        recruiterInfo = recruiter;
        user = account;
        companyInfo = company;
        jobPostingsList = jobs;
        transaction = transactions[0];
        subscriptionPackage = subscription;
        _isPremiumUser = subscription.packageName != 'Gói Cơ bản';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      SnackbarApp.show(
        context,
        message: 'Lỗi khi tải dữ liệu: $e',
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
    }
  }

  Future<void> _deleteJobPosting(String jobId) async {
    try {
      await _jobPostingService.deleteJobPosting(jobId: jobId);
      SnackbarApp.show(
        context,
        message: 'Xóa tin tuyển dụng thành công!',
        backgroundColor: BackgroundColors.backgroundSuccessPrimary,
      );
      _loadAllData();
    } catch (e) {
      SnackbarApp.show(
        context,
        message: 'Lỗi khi xóa tin tuyển dụng: $e',
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
    }
  }

  int _isFeatured() => _isUrgent ? 1 : 0;

  Future<void> _createJobPosting() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_canCreateJobPosting()) {
      SnackbarApp.show(
        context,
        message: 'Bạn đã hết hạn mức đăng tin trong gói hiện tại.',
        backgroundColor: BackgroundColors.backgroundWarningPrimary,
      );
      return;
    }

    final now = DateTime.now();
    final deadline = _selectedDeadline ?? now;

    final newJob = JobPostingModel(
      idJobPost: "auto-generated-id",
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      requirements: _requirementsController.text.trim(),
      salary: double.tryParse(_salaryController.text) ?? 0.0,
      location: _location,
      workType: _jobType,
      experienceLevel: _experienceLevel,
      idCompany: companyInfo?.idCompany ?? "",
      applicationDeadline: deadline,
      benefits: _benefitsController.text.trim(),
      createdAt: now,
      updatedAt: now,
      isFeatured: _isFeatured(),
      postStatus: PostStatus.waiting.name,
    );

    try {
      await _jobPostingService.createJobPosting(jobPosting: newJob);
      SnackbarApp.show(
        context,
        message: 'Đăng tuyển thành công!',
        backgroundColor: BackgroundColors.backgroundSuccessPrimary,
      );
      _resetForm();
      await _loadAllData();
    } catch (e) {
      SnackbarApp.show(
        context,
        message: 'Lỗi khi đăng tuyển: $e',
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
    }
  }

  bool _canCreateJobPosting() => subscriptionPackage != null &&
      jobPostingsList.length < subscriptionPackage!.jobPostLimit;

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _salaryController.clear();
    _requirementsController.clear();
    _benefitsController.clear();
    _locationController.clear();
    setState(() {
      _jobType = "fulltime";
      _experienceLevel = "Mới đi làm";
      _selectedDeadline = _defaultDeadline;
      _isUrgent = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _requirementsController.dispose();
    _benefitsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(
        body: Center(
          child: BackgroundErrorState(
            title: "Hệ thống đang gặp sự cố\nVui lòng thử lại sau.",
            onRetry: _loadAllData,
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadAllData,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    children: [
                      RecruiterInfoRow(
                        user: user,
                        companyInfo: companyInfo,
                        isPremiumUser: _isPremiumUser,
                        packageName: subscriptionPackage?.packageName,
                      ),
                      const SizedBox(height: 12),
                      UpgradePostingButton(
                        onTap: () {
                          if (subscriptionPackage == null) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => HrSubscriptionScreen(
                                idBank: '1',
                                balance: 0,
                                recruiterId: widget.recruiterId,
                                currentPackageId: subscriptionPackage!.idPackage,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: RecruiterTabBar(
                  tabController: _tabController,
                  pageController: _pageController,
                ),
              ),
            ],
            body: PageView(
              controller: _pageController,
              onPageChanged: (idx) => _tabController.index = idx,
              children: [
                RecruitmentTab(isPremiumUser: true),
                HistoryTab(
                  jobPostings: jobPostingsList,
                  jobApplicationsList: jobApplicationsList,
                  onRepostJob: (jobId) async {
                    await _jobPostingService.updateJobPostingStatus(jobId: jobId, newStatus: 'waiting');
                  },
                ),
                ActiveJobsTab(jobPostings: jobPostingsList, jobApplicationsList: jobApplicationsList),
                PendingJobsTab(
                  jobPostings: jobPostingsList,
                  onEditJob: (idJob) {},
                  onCancelJob: (idJob) async {
                    await _jobPostingService.updateJobPostingStatus(jobId: idJob, newStatus: 'closed');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
