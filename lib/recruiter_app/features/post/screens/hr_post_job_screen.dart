import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/enum/post_status.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/job/model/job_transaction_model.dart';
import 'package:job_connect/model/recruiter_info_model.dart';
import 'package:job_connect/model/subscription_package_model.dart';
import 'package:job_connect/features/company/model/company_model.dart';
import 'package:job_connect/features/company/service/company_service.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import '../../../services/job_application_service.dart';
import '../../../services/job_posting_service.dart';
import '../../../services/job_transaction_service.dart';
import '../../../services/recruiter_service.dart';
import '../../../services/subscriptionpackage_service.dart';
import '../../job/screens/hr_job_detail_screen.dart';
import 'dart:math';
import '../../payments/screens/hr_subscription_screen.dart';

class HrPostJobScreen extends StatefulWidget {
  final String recruiterId;
  const HrPostJobScreen({super.key, required this.recruiterId});

  @override
  // ignore: library_private_types_in_public_api
  _HrPostJobScreenState createState() => _HrPostJobScreenState();
}
class _HrPostJobScreenState extends State<HrPostJobScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final PageController _pageController;

  // Card tài khoản
  bool _isHidden = true;      // show/hide số dư

  final _formKey = GlobalKey<FormState>();
  final Random _random = Random();
  // Tiêu đề
  final TextEditingController _titleController = TextEditingController();
  // mô tả
  final TextEditingController _descriptionController = TextEditingController();
  // lương
  final TextEditingController _salaryController = TextEditingController();
  // yêu cầu
  final TextEditingController _requirementsController = TextEditingController();
  // quyền lợi
  final TextEditingController _benefitsController = TextEditingController();
  // địa điểm
  final TextEditingController _locationController = TextEditingController();
  // loại hình làm việc
  String _jobType = "fulltime";
  // kinh nghiệm
  String _experienceLevel = "Mới đi làm";
  // tỉnh thành
  String _location = "TP. Hồ Chí Minh";


  // Tìm kiếm trong lịch sử
  String _searchQuery     = '';
  // Tim tìm tin hoạt động
  String _activeSearch = '';
  final TextEditingController _searchController = TextEditingController();

  // Khởi tạo service
  final JobPostingService _jobPostingService = JobPostingService();
  final JobApplicationService _jobApplicationService = JobApplicationService();
  final RecruiterService _recruiterService = RecruiterService();
  final UserService _accountService = UserService();
  final CompanyService _companyService = CompanyService();
  final JobTransactionService _jobtransactionService = JobTransactionService();
  final SubscriptionPackageService _subscriptionpackageService = SubscriptionPackageService();

  // Khởi tạo biến lưu trữ
  UserModel? user;
  RecruiterInfoModel ? recruiterInfo;
  CompanyModel? companyInfo;
  List<JobPostingModel> jobPostingsList = [];
  List<JobApplicationModel> jobApplicationsList = [];
  JobTransactionModel ? transactions;
  SubscriptionPackageModel ? subscriptionPackage;

  // Biến trạng thái
  bool isLoading = true;
  String? error;
  // Trạng thái gấp
  bool _isUrgent = false;
  // Gói dịch vụ
  bool _isPremiumUser = false; 
  // Biến lọc
  String _selectedFilter = 'Tất cả';

    // Loại hình làm việc
  final List<String> _jobTypes = [
    "fulltime", "parttime", "freelancer",
    "remote", "internship", "fresher", "senior", "junior", "contract"
  ];

  // Kinh nghiệm
  final List<String> _experienceLevels = [
    "Mới đi làm",
    "1-2 năm kinh nghiệm",
    "3-5 năm kinh nghiệm",
    "Trên 5 năm kinh nghiệm",
    "Quản lý",
  ];
  
  final List<String> _locations = [
    'An Giang', 'Bà Rịa - Vũng Tàu', 'Bạc Liêu', 'Bắc Giang', 'Bắc Kạn', 'Bắc Ninh',
    'Bến Tre', 'Bình Dương', 'Bình Định', 'Bình Phước', 'Bình Thuận', 'Cà Mau', 'Cao Bằng',
    'Cần Thơ', 'Đà Nẵng', 'Đắk Lắk', 'Đắk Nông', 'Điện Biên', 'Đồng Nai', 'Đồng Tháp',
    'Gia Lai', 'Hà Giang', 'Hà Nam', 'Hà Nội', 'Hà Tĩnh', 'Hải Dương', 'Hải Phòng',
    'Hậu Giang', 'Hòa Bình', 'Hưng Yên', 'Khánh Hòa', 'Kiên Giang', 'Kon Tum', 'Lai Châu',
    'Lâm Đồng', 'Lạng Sơn', 'Lào Cai', 'Long An', 'Nam Định', 'Nghệ An', 'Ninh Bình',
    'Ninh Thuận', 'Phú Thọ', 'Phú Yên', 'Quảng Bình', 'Quảng Nam', 'Quảng Ngãi', 'Quảng Ninh',
    'Quảng Trị', 'Sóc Trăng', 'Sơn La', 'Tây Ninh', 'Thái Bình', 'Thái Nguyên', 'Thanh Hóa',
    'Thừa Thiên Huế', 'Tiền Giang', 'TP. Hồ Chí Minh', 'Trà Vinh', 'Tuyên Quang', 'Vĩnh Long', 'Vĩnh Phúc',
    'Yên Bái',
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
     _pageController = PageController();
    _loadAllData();
  }

  // Lấy thời gian
  DateTime? _selectedDeadline;
  final DateTime _defaultDeadline = DateTime.now().add(const Duration(days: 7));
  // Hàm gọi DatePicker
  Future<void> _pickDeadline() async {
    final today = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 1),
    );
    if (date == null) return;

    setState(() {
      _selectedDeadline = DateTime(
        date.year, date.month, date.day
      );
    });
  }

  Future<void> _loadAllData() async {
    try {
      // 1) Fetch recruiter info
      final recruiterInfo = await _recruiterService.getRecruiterById(id: widget.recruiterId);
      // 2) Fetch user account
      final user = await _accountService.getUserById(id: recruiterInfo!.idUser);
      // 3) Fetch company info (nếu có companyId)
      final companyInfo = await _companyService.getCompanyById(id: recruiterInfo.idCompany!);
      // 4) Lấy toàn bộ job thuộc công ty ứng vs hr
      List<JobPostingModel> jobPostingsList = [];
      if (recruiterInfo.idCompany != null && recruiterInfo.idCompany!.isNotEmpty) {
        jobPostingsList = await _jobPostingService.getJobPostingsByCompany(companyId: recruiterInfo.idCompany!);
      }
      // 5) Lấy toàn bộ job ứng viên đã ứng tuyển
      // final jobApplicationsList = <JobApplicationModel>[];
      // for (var job in jobPostingsList) {
      //   try {
      //     final apps = await _jobApplicationService.getJobApplicationsByJob(jobPostId: job.idJobPost);
      //     jobApplicationsList.addAll(apps);
      //   } on Exception catch (e) {
      //     if (e.toString().contains('[404]')) {
      //       continue;
      //     }
      //     rethrow;  
      //   }
      // }
          // 6) Lấy thông tin giao dịch
      final transactions = await _jobtransactionService.getTransactionsByUserId(userId:  widget.recruiterId);
      // Tìm giao dịch gần nhất
      if (transactions.isNotEmpty) {
        // Sắp xếp theo ngày giao dịch giảm dần
        transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      }
      // 7) Lấy thông tin gói dịch vụ
      final subscriptionPackage = await _subscriptionpackageService.fetchSubscriptionPackageById(packageId: transactions[0].idPackage,);
      // 8 ) Lấy thông tin bank của user
      
      setState(() {
        this.recruiterInfo = recruiterInfo;
        this.user = user;
        this.companyInfo = companyInfo;
        this.jobPostingsList = jobPostingsList;
        this.jobApplicationsList   = jobApplicationsList; 
        this.transactions = transactions[0]; // Lấy giao dịch gần nhất
        this.subscriptionPackage = subscriptionPackage;
        _isPremiumUser = _isPremiumPackage(subscriptionPackage.packageName);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
      );
    }
  }

  //Hàm xóa job
  Future<void> _deleteJobPosting(String jobId) async {
    try {
      await _jobPostingService.deleteJobPosting(jobId: jobId);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xóa tin tuyển dụng thành công!'), backgroundColor: Colors.green,),
      );
      _loadAllData(); 
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi xóa tin tuyển dụng: $e'), backgroundColor: Colors.red,),
      );
    }
  }

  // Hàm xử lý đăng tin tuyển dụng gấp
  int _isFeatured(){
    if (_isUrgent) {
      return 1;
    } else {
      return 0;
    }
  }

  // Hàm kiểm tra gói cơ bản hay gói premium
  bool _isPremiumPackage(String packageName) {
    return packageName != 'Gói Cơ bản';
  }

  // Tạo job với kiểm tra hạn mức trước
  Future<void> _createJobPosting() async {
    if (!_formKey.currentState!.validate()) return;

    // 1) Kiểm tra xem còn được đăng tin không
    if (!_canCreateJobPosting()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn đã hết hạn mức đăng tin trong gói hiện tại.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2) Xây dựng đối tượng JobPosting
    final now = DateTime.now();
    final deadline = _selectedDeadline ?? now;
    final newJobPosting = JobPostingModel(
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

    // 3) Gọi API
    try {
      await _jobPostingService.createJobPosting(jobPosting: newJobPosting);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng tuyển thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      _resetForm();

      // 4) Tải lại dữ liệu để cập nhật số lượng hiện tại
      await _loadAllData();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi đăng tuyển: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Kiểm tra hạn mức đăng tin
  bool _canCreateJobPosting() {
    if (subscriptionPackage == null) return false;
    final maxJobPostings = subscriptionPackage!.jobPostLimit;
    final currentJobPostings = jobPostingsList.length;
    // Cho phép tạo nếu số hiện tại < hạn mức
    return currentJobPostings < maxJobPostings;
  }

  // Đếm số lượng ứng viên cho một công việc
  int countApplicantsForJob(String jobId, List<JobApplicationModel> applications) {
    return applications
      .where((app) => app.idJobPost == jobId)
      .length;
  }

  String convertDoubleToCurrency(double value) {
    final formatter = NumberFormat("#,##0", "vi_VN");
    return formatter.format(value);
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
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(
        body: Center(child: Text("Lỗi: $error")),
      );
    }
    
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
         onRefresh: () async {
            await _loadAllData();
          },
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // Header: thông tin nhà tuyển dụng và nút thanh toán
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
                        Row(
                          children: [
                            // Avatar nhà tuyển dụng
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: user?.avatarUrl != null
                                    ? Image.network(
                                        user!.avatarUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(
                                          Icons.person,
                                          color: Color(0xFF2563EB),
                                          size: 30,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person,
                                        color: Color(0xFF2563EB),
                                        size: 30,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Thông tin nhà tuyển dụng
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.userName ?? 'Người dùng ${AppStrings.appName}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    companyInfo?.companyName ?? 'Chưa có công ty',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha:0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha:0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.badge_outlined,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "Mã NTD: ${user?.idUser}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          // ignore: deprecated_member_use
                                          color: const Color(0xFFFFD700).withValues(alpha:0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              color: Color(0xFFFFD700),
                                              size: 12,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              _isPremiumUser
                                                  ? subscriptionPackage!.packageName
                                                  : "Gói Cơ bản",
                                              style: const TextStyle(
                                                color: Color(0xFFFFD700),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Hiển thị card tài khoản
                        buildBalanceSection(
                          context,
                          _isHidden,
                          balance: 0,
                          onToggleVisibility: () {
                            setState(() {
                              _isHidden = !_isHidden;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        // Nút thanh toán dịch vụ đẩy tin
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HrSubscriptionScreen(
                                        idBank: '1',
                                        balance: 0,
                                        recruiterId: widget.recruiterId,
                                        currentPackageId: subscriptionPackage!.idPackage,
                                      )),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.black.withValues(alpha:0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Color(0xFF10B981),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Nâng cấp đăng tin",
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "MỚI",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // TabBar
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          // ignore: deprecated_member_use
                          color: Colors.black.withValues(alpha:0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Container(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        // ignore: deprecated_member_use
                        color: Colors.white.withValues(alpha:0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        onTap: (idx) {
                          _pageController.animateToPage(
                            idx,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        },
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: const UnderlineTabIndicator(
                          borderSide:
                              BorderSide(color: Colors.white, width: 3.0),
                          insets: EdgeInsets.symmetric(horizontal: 10.0),
                        ),
                        labelColor: Colors.white,
                        // ignore: deprecated_member_use
                        unselectedLabelColor: Colors.white.withValues(alpha:0.7),
                        labelStyle: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.work_outline, size: 20),
                            text: "Tin tuyển dụng",
                            iconMargin: EdgeInsets.only(bottom: 2.0),
                          ),
                          Tab(
                            icon: Icon(Icons.history, size: 20),
                            text: "Lịch sử",
                            iconMargin: EdgeInsets.only(bottom: 2.0),
                          ),
                          Tab(
                            icon: Icon(Icons.visibility_outlined, size: 20),
                            text: "Đang hiển thị",
                            iconMargin: EdgeInsets.only(bottom: 2.0),
                          ),
                          Tab(
                            icon: Icon(Icons.pending_outlined, size: 20),
                            text: "Chờ xác thực",
                            iconMargin: EdgeInsets.only(bottom: 2.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: PageView.builder(
              controller: _pageController,
              itemCount: 4,
              onPageChanged: (idx) => _tabController.index = idx,
              itemBuilder: (ctx, idx) {
                switch (idx) {
                  case 0:
                    return _buildRecruitmentForm();
                  case 1:
                    return _buildHistoryTab(jobPostingsList);
                  case 2:
                    return _buildActiveJobsTab(jobPostingsList);
                  case 3:
                    return _buildPendingJobsTab(jobPostingsList);
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),
      )
    );
  }
  //Tab1. Biểu mẫu đăng tin tuyển dụng
  Widget _buildRecruitmentForm() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: const Color(0xFF2563EB).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                  // ignore: deprecated_member_use
                  border: Border.all(
                    // ignore: deprecated_member_use
                    color: const Color(0xFF2563EB).withValues(alpha:0.3),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tạo tin tuyển dụng mới",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Điền đầy đủ thông tin để tìm được ứng viên phù hợp nhất",
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Thông tin cơ bản
              const Text(
                "THÔNG TIN CƠ BẢN",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),

              // Tiêu đề công việc
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Tiêu đề công việc",
                  hintText: "Ví dụ: Kỹ sư phần mềm Flutter",
                  prefixIcon: const Icon(
                    Icons.work_outline,
                    color: Color(0xFF2563EB),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF2563EB),
                      width: 2,
                    ),
                  ),
                  floatingLabelStyle: const TextStyle(color: Color(0xFF2563EB)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập tiêu đề công việc";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Mô tả công việc
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Mô tả công việc",
                  hintText:
                      "Mô tả chi tiết về công việc, trách nhiệm và kỳ vọng",
                  prefixIcon: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF2563EB),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF2563EB),
                      width: 2,
                    ),
                  ),
                  alignLabelWithHint: true,
                  floatingLabelStyle: const TextStyle(color: Color(0xFF2563EB)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập mô tả công việc";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Yêu cầu
              TextFormField(
                controller: _requirementsController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Yêu cầu ứng viên",
                  hintText: "Kỹ năng, bằng cấp, kinh nghiệm cần thiết",
                  prefixIcon: const Icon(
                    Icons.assignment_outlined,
                    color: Color(0xFF2563EB),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF2563EB),
                      width: 2,
                    ),
                  ),
                  alignLabelWithHint: true,
                  floatingLabelStyle: const TextStyle(color: Color(0xFF2563EB)),
                ),
              ),

              const SizedBox(height: 16),

              // Quyền lợi
              TextFormField(
                controller: _benefitsController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Quyền lợi",
                  hintText: "Chế độ bảo hiểm, thưởng, phúc lợi khác",
                  prefixIcon: const Icon(
                    Icons.card_giftcard_outlined,
                    color: Color(0xFF2563EB),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF2563EB),
                      width: 2,
                    ),
                  ),
                  alignLabelWithHint: true,
                  floatingLabelStyle: const TextStyle(color: Color(0xFF2563EB)),
                ),
              ),

              SizedBox(height: 16),
              // Ô hiển thị và bấm để chọn
              InkWell(
                onTap: _pickDeadline,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Hạn nộp',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text(
                    _selectedDeadline != null
                      ? DateFormat('yyyy-MM-dd – HH:mm').format(_selectedDeadline!)
                      : 'Chọn hạn nộp',
                    style: TextStyle(
                      color: _selectedDeadline != null ? Colors.black : Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
  
              // Thông tin chi tiết
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  "THÔNG TIN CHI TIẾT",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Thông tin chi tiết trong CardView
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Loại hình làm việc
                      const Text(
                        "Loại hình làm việc",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _jobType,
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                  items:
                                      _jobTypes.map((type) {
                                        return DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _jobType = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Mức lương
                      const Text(
                        "Mức lương",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _salaryController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          hintText: "VNĐ/tháng",
                          prefixIcon: const Icon(
                            Icons.monetization_on_outlined,
                            color: Color(0xFF2563EB),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Vui lòng nhập mức lương";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Kinh nghiệm
                      const Text(
                        "Kinh nghiệm",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.trending_up_outlined,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _experienceLevel,
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                  items:
                                      _experienceLevels.map((level) {
                                        return DropdownMenuItem(
                                          value: level,
                                          child: Text(level),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _experienceLevel = value!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Địa điểm làm việc
                      const Text(
                        "Địa điểm làm việc",
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _location,
                                  isExpanded: true,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                  items:
                                      _locations.map((type) {
                                        return DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        );
                                      }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _location = value!;
                                      _locationController.text = _location;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tuyển gấp
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: CheckboxListTile(
                  enabled: _isPremiumUser,
                  title: const Text(
                    "Đánh dấu là tin tuyển gấp",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Tin tuyển dụng sẽ được ưu tiên hiển thị"),
                      if (!_isPremiumUser) ...[
                        const SizedBox(height: 4),
                        Text(
                          "Cần đăng kí gói Premium",
                          style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  value: _isUrgent,
                  activeColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  // nếu không phải Premium thì onChanged = null (disabled)
                  onChanged: _isPremiumUser
                    ? (value) => setState(() => _isUrgent = value!)
                    : null,
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: const Color(0xFF2563EB).withValues(alpha:0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.priority_high,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Nút đăng và hủy
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetForm,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF2563EB)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Hủy",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _createJobPosting,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.publish_outlined, color: Colors.white,),
                          SizedBox(width: 8),
                          Text(
                            "Đăng tin tuyển dụng",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Tab3. Tin đang hiển thị
  Widget _buildActiveJobsTab(List<JobPostingModel> jobPostings) {
    // Danh sách tin tuyển dụng đang hiển thị
    // Chỉ hiển thị các tin tuyển dụng có trạng thái "open"
    final filtered = jobPostings.where((job) {
      final matchesStatus = job.postStatus == 'open';
      final matchesSearch = job.title!.toLowerCase().contains(_activeSearch.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();

    final List<Map<String, dynamic>> activeJobs = filtered
      .where((job) => job.postStatus == 'open')
      .map((job) {
        final now = DateTime.now();
        final daysDiff = job.applicationDeadline!.difference(now).inDays;
        final statusText = daysDiff >= 0
            ? 'Còn $daysDiff ngày'
            : 'Quá hạn ${-daysDiff} ngày';

        return {
          'idJobPost': job.idJobPost,
          'title': job.title,
          'location': job.location,
          'posted': DateFormat('dd/MM/yyyy').format(job.createdAt ?? DateTime.now()),
          'expires': DateFormat('dd/MM/yyyy').format(job.applicationDeadline?? DateTime.now()),
          'views': _random.nextInt(81) + 20,
          'status': statusText,
          'isUrgent': job.isFeatured == 1,
        };
      }).toList();

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Thanh tìm kiếm và bộ lọc
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: Colors.black.withValues(alpha:0.05),
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
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade100,
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm tin đăng',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey.shade600,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                      onChanged: (v) => setState(() => _activeSearch = v),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade100,
                  ),
                  child: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.filter_list, color: Colors.grey.shade700),
                    tooltip: 'Lọc tin đăng',
                  ),
                ),
              ],
            ),
          ),

          // Thống kê
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFFE6EFFF),
            child: Row(
              children: [
                const Icon(
                  Icons.visibility,
                  color: Color(0xFF2563EB),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${activeJobs.length} tin đang hiển thị',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const Text(
                      'Tin của bạn đang được người tìm việc xem',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Danh sách tin đăng
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: activeJobs.length,
              itemBuilder: (context, index) {
                final job = activeJobs[index];
                final applicantCount = jobApplicationsList
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
  
  // Card hiển thị thông tin công việc đang hiển thị
  Widget _buildActiveJobCard(Map<String, dynamic> job, int applicantCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: const Color(0xFF2563EB).withValues(alpha:0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      job['status'],
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (job['isUrgent'])
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.red.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.priority_high,
                              color: Colors.red,
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Gấp',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 8),
                    // Thêm nút xóa tin
                    InkWell(
                      onTap: () => _deleteJobPosting(job['idJobPost']),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.red.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 270,
                      child: Text(
                        job['location'],
                        maxLines: 4,
                        overflow: TextOverflow.visible, 
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildJobInfoChip(
                      Icons.calendar_today_outlined,
                      'Đăng: ${job['posted']}',
                    ),
                    const SizedBox(width: 16),
                    _buildJobInfoChip(
                      Icons.event_busy_outlined,
                      'Hạn: ${job['expires']}',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildJobInfoChip(
                      Icons.person_outline,
                      '$applicantCount ứng viên',
                    ),
                    const SizedBox(width: 16),
                    _buildJobInfoChip(
                      Icons.visibility_outlined,
                      '${job['views']} lượt xem',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: null,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Sửa tin'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color.fromARGB(255, 97, 97, 97)),
                          padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                          minimumSize: const Size.fromHeight(40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            await _jobPostingService.updateJobPostingStatus(jobId: job['idJobPost'],newStatus:  'closed');
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ẩn tin thành công'), backgroundColor: Colors.green,),
                            );
                          } catch (e) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red,),
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.visibility_off_outlined,
                          size: 16,
                        ),
                        label: const Text('Ẩn tin'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Expanded(
                    //   child: OutlinedButton.icon(
                    //     onPressed: () {
                    //       // Xử lý logic đẩy top tin tuyển dụng
                    //     },
                    //     icon: const Icon(Icons.trending_up, size: 16),
                    //     label: const Text('Đẩy top'),
                    //     style: OutlinedButton.styleFrom(
                    //       foregroundColor: const Color(0xFF10B981),
                    //       side: const BorderSide(color: Color(0xFF10B981)),
                    //       padding: const EdgeInsets.symmetric(vertical: 10),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab4. Tin chờ xác thực
  Widget _buildPendingJobsTab(List<JobPostingModel> jobPostings) {
    // Lọc danh sách công việc theo trạng thái "Đang chờ duyệt"
    final List<Map<String, dynamic>> pendingJobs = jobPostings
        .where((job) => job.postStatus == 'waiting')
        .map((job) => {
          'idJobPost': job.idJobPost,
          'title': job.title,
          'location': job.location,
          'submitted': DateFormat('dd/MM/yyyy').format(job.createdAt?? DateTime.now()),
          'status': job.postStatus == "waiting" ? "Chờ kiểm duyệt" : "Cần chỉnh sửa",
          //'reason': job.description,
          'reason': "Chờ kiểm duyệt nội dung",
        })
        .toList();

    return Container(
      color: Colors.white,
      child: pendingJobs.isEmpty
        ? _buildEmptyPendingState()
        : Column(
          children: [
            // Header thông tin
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFFFF4E6),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFED8936),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tin đăng chờ xác thực',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFFED8936),
                          ),
                        ),
                        Text(
                          'Bạn có ${pendingJobs.length} tin đang chờ xác thực. Tin sẽ được hiển thị sau khi được duyệt.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Danh sách tin chờ duyệt
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pendingJobs.length,
                itemBuilder: (context, index) {
                  final job = pendingJobs[index];
                  return _buildPendingJobCard(job);
                },
              ),
            ),
          ],
        ),
    );
  }
  // Card hiển thị thông tin công việc chờ xác thực
  Widget _buildPendingJobCard(Map<String, dynamic> job) {
    final bool needsEdit = job['status'] == 'Cần chỉnh sửa';
    final Color statusColor = needsEdit ? Colors.red : const Color(0xFFED8936);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: statusColor.withValues(alpha:0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  needsEdit
                      ? Icons.warning_amber_outlined
                      : Icons.pending_outlined,
                  color: statusColor,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  job['status'],
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 270,
                      child: Text(
                        job['location'],
                        maxLines: 4,
                        overflow: TextOverflow.visible, 
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Gửi ngày: ${job['submitted']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (job['reason'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: statusColor.withValues(alpha:0.05),
                      borderRadius: BorderRadius.circular(8),
                      // ignore: deprecated_member_use
                      border: Border.all(color: statusColor.withValues(alpha:0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: statusColor, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            job['reason'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed:null,
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Chỉnh sửa'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: statusColor,
                          // ignore: deprecated_member_use
                          backgroundColor: Colors.grey.withValues(alpha:0.2),
                          side: BorderSide(color: statusColor),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        //onPressed: () => _deleteJobPosting(job['idJobPost']),
                        onPressed: () async {
                          try {
                            await _jobPostingService.updateJobPostingStatus(jobId: job['idJobPost'], newStatus:  'closed');
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Hủy tin thành công'), backgroundColor: Colors.green,),
                            );
                          } catch (e) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red,),
                            );
                          }
                        },
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Hủy đăng'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade400),
                          padding: const EdgeInsets.symmetric(vertical: 10),
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
  // Trạng thái không có tin chờ xác thực
  Widget _buildEmptyPendingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Colors.green.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            "Không có tin đăng nào đang chờ xác thực",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tất cả tin đăng của bạn đã được phê duyệt",
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
  // Card hiển thị thông tin công việc
  Widget _buildJobInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
      ],
    );
  }

  // Tab2. Lịch sử đăng tin
  Widget _buildHistoryTab( List<JobPostingModel> jobPostings) {
   // 1) Lọc theo trạng thái và tìm kiếm theo title
    final filteredJobs = jobPostings.where((j) {
      final matchStatus = _selectedFilter == 'Tất cả' || j.postStatus == _selectedFilter;
      final matchSearch = j.title!.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchStatus && matchSearch;
    }).toList();

    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thanh tìm kiếm và bộ lọc
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withValues(alpha:0.05),
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
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade100,
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm theo tên công việc',
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                         onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade100,
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.filter_list, color: Colors.grey.shade700),
                      tooltip: 'Lọc tin đăng',
                    ),
                  ),
                ],
              ),
            ),

            // Thống kê / Filter
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF1F5F9),
              child: SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildHistoryFilterCard(
                      icon: Icons.article_outlined,
                      title: "Tất cả",
                      count: jobPostings.length.toString(),
                      color: const Color(0xFF3366FF),
                      selected: _selectedFilter == 'Tất cả',
                      onTap: () => setState(() => _selectedFilter = 'Tất cả'),
                    ),
                    const SizedBox(width: 12),
                    _buildHistoryFilterCard(
                      icon: Icons.check_circle_outline,
                      title: "Đang hoạt động",
                      count: jobPostings
                          .where((job) => job.postStatus == 'open')
                          .length
                          .toString(),
                      color: Colors.green,
                      selected: _selectedFilter == 'open',
                      onTap: () => setState(() => _selectedFilter = 'open'),
                    ),
                    const SizedBox(width: 12),
                    _buildHistoryFilterCard(
                      icon: Icons.access_time,
                      title: "Hết hạn",
                      count: jobPostings
                          .where((job) => job.postStatus == 'closed')
                          .length
                          .toString(),
                      color: Colors.grey,
                      selected: _selectedFilter == 'closed',
                      onTap: () => setState(() => _selectedFilter = 'closed'),
                    ),
                    const SizedBox(width: 12),
                    _buildHistoryFilterCard(
                      icon: Icons.hourglass_empty,
                      title: "Chờ xác nhận",
                      count: jobPostings
                          .where((job) => job.postStatus == 'waiting')
                          .length
                          .toString(),
                      color: Colors.orange,
                      selected: _selectedFilter == 'waiting',
                      onTap: () => setState(() => _selectedFilter = 'waiting'),
                    ),
                  ],
                ),
              ),
            ),

            // Danh sách tin đăng
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding:   const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredJobs.length,
              itemBuilder: (context, index) {
                final job = filteredJobs[index];
                // Tính số ứng viên cho job này
                final applicantCount = jobApplicationsList
                  .where((app) => app.idJobPost == job.idJobPost)
                  .length;
                return _buildHistoryJobCard(job, applicantCount);
              },
            ),
          ],
        ),
      ),
    );
  }
  // Card cho các bộ lọc trong lịch sử
  // Đang hoạt động, Hết hạn, Tất cả
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              // ignore: deprecated_member_use
              ? color.withValues(alpha:0.2)
              // ignore: deprecated_member_use
              : color.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHistoryJobCard(JobPostingModel job, int applyCount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    job.title ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: job.postStatus == "open" ? 
                                          // ignore: deprecated_member_use
                                          Colors.green.withValues(alpha:0.1) : 
                           job.postStatus == "closed" ?
                                          // ignore: deprecated_member_use
                                          Colors.grey.withValues(alpha:0.1) 
                                          :
                                          // ignore: deprecated_member_use
                                          Colors.orange.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    job.postStatus == "open" ? "Đang hoạt động" : 
                    job.postStatus == "closed" ? "Hết hạn" : "Chờ xác nhận",
                    style: TextStyle(
                      color:  job.postStatus == "open" ? 
                                          Colors.green : 
                              job.postStatus == "closed" ?
                                          Colors.grey :
                                          Colors.orange,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Đăng ngày:',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.person_outline,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  "$applyCount ứng viên",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(context, 
                        MaterialPageRoute(builder: (context)=> JobDetailScreen(job: job)));
                    },
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('Chi tiết'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF3366FF),
                      side: const BorderSide(color: Color(0xFF3366FF)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        await _jobPostingService.updateJobPostingStatus(jobId: job.idJobPost, newStatus:  'waiting');
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Cập nhật trạng thái thành công')),
                        );
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi: ${e.toString()}')),
                        );
                      }

                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Đăng lại'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          job.postStatus == 'closed'
                              ? Colors.amber.shade800
                              : Colors.grey.shade400,
                      side: BorderSide(
                        color:
                            job.postStatus == 'closed'
                              ? Colors.amber.shade800
                              : Colors.grey.shade400,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
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

  // Card tài khoản 
  Widget buildBalanceSection(
    BuildContext context,
    bool isHidden, {
    double? balance,
    required VoidCallback onToggleVisibility,
  }) {
    // Màu của card chứa số dư
    final Color cardBlue = const Color.fromARGB(255, 43, 100, 198);

    // Nếu isHidden = true, hiển thị mask, ngược lại hiển thị số thực (format tạm)
    final String balanceText = isHidden
      ? '*** ***'
      : (balance != null ? convertDoubleToCurrency(balance): '0');

    return Container(
      margin: EdgeInsets.fromLTRB(0, 16, 0, 0),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: cardBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cardBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dòng trên: "Tổng số dư VND" + mũi tên + icon eye
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Tổng số dư VND',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withValues(alpha:0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onToggleVisibility,
                        child: Icon(
                          isHidden
                              ? Icons.remove_red_eye_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Dòng dưới: "*** ***" hoặc số thực + "VND"
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        balanceText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        margin: EdgeInsets.only(bottom: 6),
                        child: const Text(
                          'VND',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}