import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/background_error_state.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/company/model/company_model.dart';
import 'package:job_connect/features/company/service/company_service.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/job/model/job_transaction_model.dart';
import 'package:job_connect/features/job/service/job_posting_service.dart';
import 'package:job_connect/features/job/service/job_transaction_service.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import 'package:job_connect/model/recruiter_info_model.dart';
import 'package:job_connect/model/subscription_package_model.dart';
import 'package:job_connect/recruiter_app/features/payments/screens/hr_subscription_screen.dart';
import 'package:job_connect/recruiter_app/features/post/widget/post_job/active_jobs_tab.dart';
import 'package:job_connect/recruiter_app/features/post/widget/post_job/history_tab.dart';
import 'package:job_connect/recruiter_app/features/post/widget/post_job/pending_jobs_tab.dart';
import 'package:job_connect/recruiter_app/features/post/widget/post_job/post_jobs_tab_bar.dart';
import 'package:job_connect/recruiter_app/features/post/widget/post_job/recruitment_tab.dart';
import 'package:job_connect/recruiter_app/features/post/widget/post_job/recruiter_info_row.dart';
import 'package:job_connect/recruiter_app/features/post/widget/post_job/temporary_jobs_tab.dart';
import 'package:job_connect/recruiter_app/features/post/widget/post_job/upgrade_posting_button.dart';
import 'package:job_connect/recruiter_app/services/recruiter_service.dart';
import 'package:job_connect/recruiter_app/services/subscriptionpackage_service.dart';
import 'package:job_connect/recruiter_app/features/post/screens/hr_edit_detail_post_job_screen.dart';
import 'package:job_connect/features/job/view_model/job_category_view_model.dart';
import 'package:job_connect/features/job/model/job_category_model.dart';
import 'package:job_connect/recruiter_app/features/post/service/work_schedule_service.dart';

class HrPostJobScreen extends StatefulWidget {
  final String recruiterId;
  const HrPostJobScreen({super.key, required this.recruiterId});

  @override
  _HrPostJobScreenState createState() => _HrPostJobScreenState();
}

class _HrPostJobScreenState extends State<HrPostJobScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final PageController _pageController;

  // Form keys
  final _recruitmentFormKey = GlobalKey<FormState>();
  final _temporaryFormKey = GlobalKey<FormState>();

  // Controllers for RecruitmentTab
  final TextEditingController _recTitleController = TextEditingController();
  final TextEditingController _recDescriptionController = TextEditingController();
  final TextEditingController _recRequirementsController = TextEditingController();
  final TextEditingController _recBenefitsController = TextEditingController();
  final TextEditingController _recSalaryController = TextEditingController();
  final TextEditingController _recLocationController = TextEditingController();

  // Controllers for TemporaryJobsFormTab
  final TextEditingController _tempTitleController = TextEditingController();
  final TextEditingController _tempDescriptionController = TextEditingController();
  final TextEditingController _tempRequirementsController = TextEditingController();
  final TextEditingController _tempHourlyRateController = TextEditingController();
  final TextEditingController _tempDailyRateController = TextEditingController();
  final TextEditingController _tempLocationController = TextEditingController();
  final TextEditingController _tempMinHoursController = TextEditingController();
  final TextEditingController _tempMaxHoursController = TextEditingController();
  final TextEditingController _tempWorkDaysController = TextEditingController();
  final TextEditingController _workDaysController = TextEditingController();

  // Dropdown / checkbox state for RecruitmentTab
  String _recSelectedWorkType = 'Full-time';
  String _recSelectedExperience = 'Không yêu cầu';
  String _recSelectedLocation = 'Hà Nội';
  DateTime? _recApplicationDeadline;
  bool _recIsUrgent = false;

  // Dropdown / checkbox state for TemporaryJobsFormTab
  String _tempSelectedWorkType = 'Full-time';
  String? _tempSelectedWorkSchedule; // Sẽ set từ API
  String? _tempSelectedCategoryId; // Lưu idCategory thay vì tên
  String _tempSelectedExperience = 'Không yêu cầu';
  DateTime? _tempSeasonalStart;
  DateTime? _tempSeasonalEnd;
  DateTime? _tempApplicationDeadline;
  bool _tempIsUrgent = false;
  
  // Location coordinates
  double? _recLatitude;
  double? _recLongitude;
  double? _tempLatitude;
  double? _tempLongitude;

  // Dropdown options
  final List<String> workTypes = ['Full-time', 'Part-time', 'Temporary'];
  List<String> _workSchedules = []; // Sẽ load từ API
  final List<String> experienceLevels = ['Không yêu cầu', 'Mới tốt nghiệp', '1-3 năm', '3-5 năm'];
  
  // Job categories từ API
  List<JobCategoryModel> _jobCategories = [];
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

  // Services
  final JobPostingService _jobPostingService = JobPostingService();
  final RecruiterService _recruiterService = RecruiterService();
  final UserService _accountService = UserService();
  final CompanyService _companyService = CompanyService();
  final JobTransactionService _jobTransactionService = JobTransactionService();
  final SubscriptionPackageService _subscriptionPackageService = SubscriptionPackageService();
  final WorkScheduleService _workScheduleService = WorkScheduleService();

  // Data
  UserModel? user;
  RecruiterInfoModel? recruiterInfo;
  CompanyModel? companyInfo;
  List<JobPostingModel> jobPostingsList = [];
  List<JobApplicationModel> jobApplicationsList = [];
  JobTransactionModel? transaction;
  SubscriptionPackageModel? subscriptionPackage;

  // Loading / Error
  bool isLoading = true;
  String? error;
  bool _isPremiumUser = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _pageController = PageController();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      final recruiter = await _recruiterService.getRecruiterById(id: widget.recruiterId);
      final account = await _accountService.getUserById(id: recruiter!.idUser);
      
      // Lấy company với xử lý lỗi
      CompanyModel? company;
      if (recruiter.idCompany != null && recruiter.idCompany!.isNotEmpty) {
        try {
          company = await _companyService.getCompanyById(id: recruiter.idCompany!);
        } catch (e) {
          // Bỏ qua lỗi, để company = null
          company = null;
        }
      }

      List<JobPostingModel> jobs = [];
      if (recruiter.idCompany != null && recruiter.idCompany!.isNotEmpty) {
        try {
          jobs = await _jobPostingService.getJobPostingsByCompany(companyId: recruiter.idCompany!);
        } catch (e) {
          jobs = [];
        }
      }

      List<JobTransactionModel> transactions = [];
      try {
        transactions = await _jobTransactionService.getTransactionsByUserId(userId: widget.recruiterId);
      } catch (e) {
        transactions = [];
      }
      transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      final subscription = await _subscriptionPackageService.fetchSubscriptionPackageById(
        packageId: transactions[0].idPackage,
      );

      // Load job categories từ API
      List<JobCategoryModel> categories = [];
      try {
        final categoryVm = JobCategoryViewModel();
        await categoryVm.fetchAllCategories();
        categories = categoryVm.activeCategories;
        // Sắp xếp theo displayOrder nếu có
        categories.sort((a, b) => (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));
      } catch (e) {
        // Nếu lỗi, để categories rỗng
        categories = [];
      }

      // Load work schedules từ API
      List<String> workSchedules = [];
      try {
        workSchedules = await _workScheduleService.getWorkScheduleTypes();
      } catch (e) {
        // Fallback: sử dụng danh sách mặc định
        workSchedules = [
          'Theo giờ',
          'Theo ngày',
          'Theo tuần',
          'Theo tháng',
          'Linh hoạt',
          'Theo dự án',
        ];
      }

      setState(() {
        recruiterInfo = recruiter;
        user = account;
        companyInfo = company;
        jobPostingsList = jobs;
        transaction = transactions[0];
        subscriptionPackage = subscription;
        _isPremiumUser = subscription.packageName != 'Gói Cơ bản';
        _jobCategories = categories;
        _workSchedules = workSchedules;
        // Set category mặc định nếu có
        if (_tempSelectedCategoryId == null && categories.isNotEmpty) {
          _tempSelectedCategoryId = categories.first.idCategory;
        }
        // Set workSchedule mặc định nếu có
        if ((_tempSelectedWorkSchedule == null || _tempSelectedWorkSchedule!.isEmpty) && workSchedules.isNotEmpty) {
          _tempSelectedWorkSchedule = workSchedules.first;
        }
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

  void _resetRecruitmentForm() {
    _recTitleController.clear();
    _recDescriptionController.clear();
    _recRequirementsController.clear();
    _recBenefitsController.clear();
    _recSalaryController.clear();
    _recLocationController.clear();
    _workDaysController.clear();
    setState(() {
      _recSelectedWorkType = workTypes.first;
      _recSelectedExperience = experienceLevels.first;
      _recIsUrgent = false;
      _recApplicationDeadline = null;
      _recLatitude = null;
      _recLongitude = null;
    });
  }

  void _resetTemporaryForm() {
    _tempTitleController.clear();
    _tempDescriptionController.clear();
    _tempRequirementsController.clear();
    _tempHourlyRateController.clear();
    _tempDailyRateController.clear();
    _tempLocationController.clear();
    _tempMinHoursController.clear();
    _tempMaxHoursController.clear();
    _tempWorkDaysController.clear();
    setState(() {
      _tempSelectedWorkType = workTypes.first;
      _tempSelectedWorkSchedule = _workSchedules.isNotEmpty ? _workSchedules.first : null;
      _tempSelectedCategoryId = _jobCategories.isNotEmpty ? _jobCategories.first.idCategory : null;
      _tempSelectedExperience = experienceLevels.first;
      _tempSeasonalStart = null;
      _tempSeasonalEnd = null;
      _tempApplicationDeadline = null;
      _tempIsUrgent = false;
      _tempLatitude = null;
      _tempLongitude = null;
    });
  }

  Future<void> _pickTemporarySeasonalStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _tempSeasonalStart ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _tempSeasonalStart = date);
  }

  Future<void> _pickTemporarySeasonalEnd() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _tempSeasonalEnd ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _tempSeasonalEnd = date);
  }

  Future<void> _createTemporaryJob() async {
    if (!_temporaryFormKey.currentState!.validate()) return;

    final newJob = JobPostingModel(
      idJobPost: '',
      title: _tempTitleController.text.trim(),
      description: _tempDescriptionController.text.trim(),
      requirements: _tempRequirementsController.text.trim(),
      salary: double.tryParse(_tempHourlyRateController.text) ?? 0,
      location: _tempLocationController.text.trim(),
      latitude: _tempLatitude,
      longitude: _tempLongitude,
      workType: _tempSelectedWorkType,
      experienceLevel: _tempSelectedExperience,
      idCompany: companyInfo?.idCompany ?? '',
      idCategory: _tempSelectedCategoryId, // Lưu idCategory
      applicationDeadline: _tempApplicationDeadline ?? DateTime.now().add(const Duration(days: 7)),
      benefits: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isFeatured: _tempIsUrgent ? 1 : 0,
      postStatus: 'waiting',
      hourlyRate: double.tryParse(_tempHourlyRateController.text),
      dailyRate: double.tryParse(_tempDailyRateController.text),
      minHoursPerWeek: int.tryParse(_tempMinHoursController.text),
      maxHoursPerWeek: int.tryParse(_tempMaxHoursController.text),
      workDaysPerWeek: int.tryParse(_tempWorkDaysController.text),
      workSchedule: _tempSelectedWorkSchedule,
      seasonalStartDate: _tempSeasonalStart,
      seasonalEndDate: _tempSeasonalEnd,
      isSeasonal: _tempSelectedWorkType == 'Temporary',
      isUrgent: _tempIsUrgent,
    );

    try {
      await _jobPostingService.createJobPosting(
        jobPosting: newJob,
        isUrgent: _tempIsUrgent,
        isSeasonal: false,
      );
      SnackbarApp.show(
        context,
        message: 'Đăng công việc thành công!',
        backgroundColor: BackgroundColors.backgroundSuccessPrimary,
      );
      _resetTemporaryForm();
      await _loadAllData();
    } catch (e) {
      SnackbarApp.show(
        context,
        message: 'Lỗi khi đăng tuyển: $e',
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
    }
  }

  Future<void> _createRecruitmentJob() async {
    // Validate form trước (đã được validate trong widget, nhưng double check)
    if (!_recruitmentFormKey.currentState!.validate()) {
      return; // Validation errors đã được hiển thị trên các field
    }

    // Lấy title sau khi đã validate
    final title = _recTitleController.text.trim();

    // Kiểm tra company
    if (companyInfo?.idCompany == null || (companyInfo?.idCompany ?? '').isEmpty) {
      SnackbarApp.show(
        context,
        message: 'Vui lòng cập nhật thông tin công ty trước khi đăng tin',
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
      return;
    }

    // Đảm bảo tất cả các trường bắt buộc đều có giá trị
    final description = _recDescriptionController.text.trim();
    final location = _recLocationController.text.trim().isNotEmpty 
        ? _recLocationController.text.trim() 
        : _recSelectedLocation;
    
    if (description.isEmpty) {
      SnackbarApp.show(
        context,
        message: 'Vui lòng nhập mô tả công việc',
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
      return;
    }
    
    if (location.isEmpty) {
      SnackbarApp.show(
        context,
        message: 'Vui lòng chọn địa điểm làm việc',
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
      return;
    }

    final newJob = JobPostingModel(
      idJobPost: '',
      title: title, // Đã được validate ở trên
      description: description,
      requirements: _recRequirementsController.text.trim(),
      salary: double.tryParse(_recSalaryController.text.replaceAll(',', '').replaceAll('.', '')) ?? 0,
      location: location,
      latitude: _recLatitude,
      longitude: _recLongitude,
      workType: _recSelectedWorkType,
      experienceLevel: _recSelectedExperience,
      idCompany: companyInfo?.idCompany ?? '',
      applicationDeadline: _recApplicationDeadline ?? DateTime.now().add(const Duration(days: 7)),
      benefits: _recBenefitsController.text.trim(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isFeatured: _recIsUrgent ? 1 : 0,
      postStatus: 'waiting',
      workDaysPerWeek: int.tryParse(_workDaysController.text),
      isUrgent: _recIsUrgent,
    );

    try {
      await _jobPostingService.createJobPosting(
        jobPosting: newJob,
        isUrgent: _recIsUrgent,
      );
      if (!mounted) return;
      SnackbarApp.show(
        context,
        message: 'Đăng công việc thành công!',
        backgroundColor: BackgroundColors.backgroundSuccessPrimary,
      );
      _resetRecruitmentForm();
      await _loadAllData();
    } catch (e) {
      if (!mounted) return;
      // Parse error message để hiển thị rõ ràng hơn
      String errorMessage = 'Lỗi khi đăng tuyển';
      if (e.toString().contains('Title') || e.toString().contains('title')) {
        errorMessage = 'Vui lòng nhập tiêu đề công việc';
      } else if (e.toString().contains('Company') || e.toString().contains('company')) {
        errorMessage = 'Vui lòng cập nhật thông tin công ty';
      } else if (e.toString().contains('required') || e.toString().contains('bắt buộc')) {
        errorMessage = 'Vui lòng điền đầy đủ thông tin bắt buộc';
      } else {
        errorMessage = 'Lỗi khi đăng tuyển: ${e.toString().replaceAll('Exception: ', '').replaceAll('ServerException: ', '')}';
      }
      
      SnackbarApp.show(
        context,
        message: errorMessage,
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    // Recruitment controllers
    _recTitleController.dispose();
    _recDescriptionController.dispose();
    _recRequirementsController.dispose();
    _recBenefitsController.dispose();
    _recSalaryController.dispose();
    _recLocationController.dispose();
    _workDaysController.dispose();
    // Temporary controllers
    _tempTitleController.dispose();
    _tempDescriptionController.dispose();
    _tempRequirementsController.dispose();
    _tempHourlyRateController.dispose();
    _tempDailyRateController.dispose();
    _tempLocationController.dispose();
    _tempMinHoursController.dispose();
    _tempMaxHoursController.dispose();
    _tempWorkDaysController.dispose();

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

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: UnfocusWidget(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadAllData,
            color: const Color(0xFF1A237E),
            child: NestedScrollView(
              headerSliverBuilder: (_, __) => [
                SliverToBoxAdapter(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1A237E), // Indigo
                          Color(0xFF283593), // Indigo 800
                          Color(0xFF3949AB), // Indigo 700
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A237E).withValues(alpha: 0.3),
                          blurRadius: 20.r,
                          offset: Offset(0, 8.h),
                          spreadRadius: 2.r,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
                    child: Column(
                      children: [
                        RecruiterInfoRow(
                          user: user,
                          companyInfo: companyInfo,
                          isPremiumUser: _isPremiumUser,
                          packageName: subscriptionPackage?.packageName,
                        ),
                        SizedBox(height: 12.h),
                        UpgradePostingButton(
                          onTap: () {
                            if (subscriptionPackage == null) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => HrSubscriptionScreen(
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
                  child: PostJobsTabBar(
                    tabController: _tabController,
                    pageController: _pageController,
                    tabs: const [
                      Tab(icon: Icon(Icons.work_outline), text: "Tin tuyển dụng"),
                      Tab(icon: Icon(Icons.work_history_outlined), text: "Tin thời vụ"),
                      Tab(icon: Icon(Icons.history), text: "Lịch sử"),
                      Tab(icon: Icon(Icons.visibility_outlined), text: "Đang hiển thị"),
                      Tab(icon: Icon(Icons.edit_outlined), text: "Chỉnh sửa"),
                    ],
                  ),
                ),
              ],
              body: PageView(
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                onPageChanged: (idx) {
                  if (_tabController.index != idx) {
                    _tabController.index = idx;
                  }
                },
                children: [
                  RecruitmentTab(
                    isPremiumUser: _isPremiumUser,
                    titleController: _recTitleController,
                    descriptionController: _recDescriptionController,
                    requirementsController: _recRequirementsController,
                    benefitsController: _recBenefitsController,
                    salaryController: _recSalaryController,
                    locationController: _recLocationController,
                    workDaysController: _workDaysController,
                    jobType: _recSelectedWorkType,
                    experienceLevel: _recSelectedExperience,
                    location: _recSelectedLocation,
                    jobTypes: workTypes,
                    experienceLevels: experienceLevels,
                    locations: _locations,
                    selectedDeadline: _recApplicationDeadline ?? DateTime.now(),
                    isUrgent: _recIsUrgent,
                    onPickDeadline: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _recApplicationDeadline ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _recApplicationDeadline = picked);
                    },
                    onJobTypeChanged: (v) => setState(() => _recSelectedWorkType = v),
                    onExperienceChanged: (v) => setState(() => _recSelectedExperience = v),
                    onLocationChanged:  (v) => setState(() => _recSelectedLocation = v),
                    onUrgentChanged: (v) => setState(() => _recIsUrgent = v),
                    onResetForm: _resetRecruitmentForm,
                    onCreateJob: _createRecruitmentJob,
                    formKey: _recruitmentFormKey,
                    onLocationObtained: (lat, lng) {
                      setState(() {
                        _recLatitude = lat;
                        _recLongitude = lng;
                      });
                    },
                  ),
                  TemporaryJobsFormTab(
                    isPremiumUser: _isPremiumUser,
                    titleController: _tempTitleController,
                    descriptionController: _tempDescriptionController,
                    requirementsController: _tempRequirementsController,
                    hourlyRateController: _tempHourlyRateController,
                    dailyRateController: _tempDailyRateController,
                    locationController: _tempLocationController,
                    minHoursController: _tempMinHoursController,
                    maxHoursController: _tempMaxHoursController,
                    workDaysController: _tempWorkDaysController,
                    workType: _tempSelectedWorkType,
                    workSchedule: _tempSelectedWorkSchedule,
                    categoryId: _tempSelectedCategoryId,
                    experienceLevel: _tempSelectedExperience,
                    seasonalStart: _tempSeasonalStart,
                    seasonalEnd: _tempSeasonalEnd,
                    applicationDeadline: _tempApplicationDeadline,
                    isUrgent: _tempIsUrgent,
                    onCreateJob: _createTemporaryJob,
                    onResetForm: _resetTemporaryForm,
                    onPickSeasonalStart: _pickTemporarySeasonalStart,
                    onPickSeasonalEnd: _pickTemporarySeasonalEnd,
                    onPickDeadline: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _tempApplicationDeadline ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _tempApplicationDeadline = picked);
                    },
                    onWorkTypeChanged: (v) => setState(() => _tempSelectedWorkType = v),
                    onWorkScheduleChanged: (v) => setState(() => _tempSelectedWorkSchedule = v),
                    onCategoryChanged: (v) => setState(() => _tempSelectedCategoryId = v),
                    onExperienceChanged: (v) => setState(() => _tempSelectedExperience = v),
                    onUrgentChanged: (v) => setState(() => _tempIsUrgent = v),
                    formKey: _temporaryFormKey,
                    workTypes: workTypes,
                    workSchedules: _workSchedules,
                    categories: _jobCategories,
                    experienceLevels: experienceLevels,
                    onLocationObtained: (lat, lng) {
                      setState(() {
                        _tempLatitude = lat;
                        _tempLongitude = lng;
                      });
                    },
                  ),
                  HistoryTab(
                    jobPostings: jobPostingsList,
                    jobApplicationsList: jobApplicationsList,
                    onRepostJob: (job) async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HrEditDetailPostJobScreen(
                            jobPosting: job,
                            onJobUpdated: () {
                              // Refresh danh sách sau khi update
                              _loadAllData();
                            },
                          ),
                        ),
                      );
                      // Refresh sau khi quay lại từ màn hình edit
                      _loadAllData();
                    },
                    onStopRecruiting: (jobId) async {
                      await _jobPostingService.updateJobPostingStatus(jobId: jobId, newStatus: 'closed');
                      // Refresh danh sách sau khi ngưng tuyển
                      _loadAllData();
                    },
                    onRefresh: _loadAllData,
                  ),
                  ActiveJobsTab(
                    jobPostings: jobPostingsList,
                    jobApplicationsList: jobApplicationsList,
                    onStopRecruiting: (jobId) async {
                      await _jobPostingService.updateJobPostingStatus(jobId: jobId, newStatus: 'closed');
                      // Refresh danh sách sau khi ngưng tuyển
                      _loadAllData();
                    },
                    onRefresh: _loadAllData,
                  ),
                  PendingJobsTab(
                    jobPostings: jobPostingsList,
                    onEditJob: (idJob) async {
                      // Tìm job cần chỉnh sửa
                      final job = jobPostingsList.firstWhere((j) => j.idJobPost == idJob);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HrEditDetailPostJobScreen(
                            jobPosting: job,
                            onJobUpdated: () {
                              // Refresh danh sách sau khi update
                              _loadAllData();
                            },
                          ),
                        ),
                      );
                      // Refresh sau khi quay lại từ màn hình edit
                      _loadAllData();
                    },
                    onCancelJob: (idJob) async {
                      // Hiển thị dialog xác nhận
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận hủy đăng bài'),
                          content: const Text('Bạn có chắc chắn muốn hủy đăng bài này?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: const Text('Hủy đăng bài'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await _jobPostingService.updateJobPostingStatus(jobId: idJob, newStatus: 'closed');
                        // Refresh danh sách sau khi hủy
                        _loadAllData();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã hủy đăng bài thành công'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
