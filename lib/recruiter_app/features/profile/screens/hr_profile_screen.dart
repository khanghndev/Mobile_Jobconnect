import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/model/recruiter_info_model.dart';
import 'package:job_connect/features/company/model/company_model.dart';
import 'package:job_connect/features/company/service/company_service.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import '../../../services/job_application_service.dart';
import '../../../services/job_posting_service.dart';
import '../../../services/recruiter_service.dart';
import '../../candidate/screens/hr_candidate_management_screen.dart';
import 'hr_edit_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

import 'package:url_launcher/url_launcher.dart';

class RecruiterProfilePage extends StatefulWidget {
  final String recruiterId;
  const RecruiterProfilePage({super.key, required this.recruiterId, required UserModel account});

  @override
  State<RecruiterProfilePage> createState() => _RecruiterProfilePageState();
}

class _RecruiterProfilePageState extends State<RecruiterProfilePage> {
  final UserService accountService = UserService();
  final RecruiterService recruiterService = RecruiterService();
  final CompanyService companyService = CompanyService();
  final JobPostingService jobPostingService = JobPostingService();
  final JobApplicationService jobApplicationService = JobApplicationService();

 UserModel? user;
  RecruiterInfoModel? recruiterInfo;
  CompanyModel? companyInfo;

  List<JobPostingModel>? jobPostingsList;
  List<List<JobApplicationModel>> jobApplicationsList = [];
  bool isLoading = true;
  String? error;
  
  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      // 1) Fetch recruiter info
      final rec = await recruiterService.getRecruiterById(id: widget.recruiterId);
      // 2) Fetch user account
      final acc = await accountService.getUserById(id: rec!.idUser);
      // 3) Fetch company info (nếu có companyId)
      final comp = await companyService.getCompanyById(id: rec.idCompany!);
      // 4) Lấy toàn bộ job thuộc công ty ứng vs hr
      List<JobPostingModel>? jobPostings;
      if (rec.idCompany != null && rec.idCompany!.isNotEmpty) {
        jobPostings = await jobPostingService.getJobPostingsByCompany(companyId: rec.idCompany!);
      }
      // 5) Lấy toàn bộ jobapp ứng với jobpost có trạng thái đã nhận
      List<JobApplicationModel>? jobApplications;
      // for(int i = 0; i < jobPostings!.length; i++) {
      //   if (jobPostings.isNotEmpty) {
      //     jobApplications = await jobApplicationService.getJobApplicationsByJob(jobPostId: jobPostings[i].idJobPost);
      //     for(int j = 0; j < jobApplications.length; j++){
      //       if(jobApplications[j].applicationStatus == "accepted"){
      //         jobApplicationsList.add(jobApplications);
      //       }
      //     }
      //   }
      // }
      setState(() {
        recruiterInfo = rec;
        user = acc;
        companyInfo = comp;
        jobPostingsList = jobPostings;
        jobApplicationsList = jobApplicationsList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
      );
    }
  }

  //Lấy số vị trí đã tuyển từ jobpostting
  int getPosisionPost(){
    List<String> posisionPost = [];
    for(int i = 0; i < jobPostingsList!.length; i++){
      posisionPost.add(jobPostingsList?[i].title ?? '');
    }
    List<String> posisionPostUnique = posisionPost.toSet().toList();
    return posisionPostUnique.length;
  }

  // Copy nội dung
  Future<void> copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép vào clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Hàm mở link web
  Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không mở được link: $url')),
      );
    }
  }

  //Modal đăng xuất
  void _logout(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder:
          (context, animation1, animation2) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withValues(alpha:0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with gradient
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          // Animated icon
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.elasticOut,
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: Colors.white.withValues(alpha:0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.logout_rounded,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Đăng xuất",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          const Text(
                            "Bạn có chắc chắn muốn đăng xuất khỏi tài khoản hiện tại?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[200],
                                    foregroundColor: Colors.black87,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    "Hủy",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.clear();
                                    if (context.mounted) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/login',
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D47A1),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    "Đăng xuất",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
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
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Scaffold(body: Center(child: Text('Lỗi: $error')));
    }
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null) {
      return Scaffold(body: Center(child: Text('Lỗi: $error')));
    }

    if (user == null || recruiterInfo == null) {
      return const Scaffold(
        body: Center(child: Text('Không có dữ liệu')),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RefreshIndicator(
       onRefresh: () async {
          await _loadAllData();
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              expandedHeight: 260.0,
              floating: false,
              pinned: true,
              backgroundColor: const Color(0xFF1565C0),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF1976D2), Color(0xFF0D47A1)],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            //Ảnh đại diện 
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: Colors.white,
                              backgroundImage: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                                  ? NetworkImage(user!.avatarUrl!)
                                  : NetworkImage(AppImages.defaultAvatar),
                            ),
                            
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(4.0),
                                child: InkWell(
                                  onTap:() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: 
                                      (context) => HrEditProfileScreen(
                                        account: user!,
                                        company: companyInfo!,
                                        recruiterInfo: recruiterInfo!,
                                      )),
                                    );
                                  },
                                  child: Icon(
                                    Icons.business_center,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Tên nhà tuyển dụng
                        Text(
                          user!.userName, 
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Chức vụ - Nhà tuyển dụng mặc định
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "Nhà tuyển dụng",
                            style: TextStyle(
                              color: Color(0xFF1565C0),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Tên công ty tiêu đề
                        Text(
                          "Công ty ${companyInfo!.companyName}" ,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Thống kê
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, 0),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Số tin tuyển dụng
                        _buildStatItem(
                          context,
                          jobPostingsList?.length.toString() ?? "0",
                          "Tin tuyển dụng",
                          Colors.blue,
                        ),
                        _buildVerticalDivider(),
                        // Số hồ sơ đã nhận
                        _buildStatItem(
                          context,
                          jobApplicationsList.length.toString(),
                          "Hồ sơ đã nhận",
                          Colors.green,
                        ),
                        _buildVerticalDivider(),
                        //Số vị trí đã tuyển
                        _buildStatItem(
                          context,
                          getPosisionPost().toString(),
                          "Vị trí đã tuyển",
                          Colors.orange,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Thông tin liên hệ
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, 2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Card(
                    elevation: 2,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tiêu đề thông tin liên hệ
                          Container(
                            margin: EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: const Color(0xFF0D47A1).withValues(alpha:0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.contact_phone_rounded,
                                    color: Color(0xFF0D47A1),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Thông tin liên hệ",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D47A1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          
                          // Email 
                          _buildContactItem(
                            icon: Icons.email_rounded,
                            title: "Email",
                            subtitle: user!.email,
                            hasCopy: true,
                          ),
                          
                          // Số điện thoại
                          _buildContactItem(
                            icon: Icons.phone_rounded,
                            title: "Số điện thoại",
                            subtitle: user!.phoneNumber ?? "Chưa có số điện thoại",
                            hasCopy: true,
                          ),

                          //Địa điểm
                          _buildContactItem(
                            icon: Icons.location_on_rounded,
                            title: "Địa điểm",
                            subtitle: companyInfo!.address,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Thông tin công ty
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Card(
                    elevation: 2,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Tiêu đề thông tin công ty
                          Container(
                            margin: EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: const Color(0xFF0D47A1).withValues(alpha:0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.apartment,
                                    color: Color(0xFF0D47A1),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "Thông tin công ty",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D47A1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          // Tên công ty
                          _buildContactItem(
                            icon: Icons.business_rounded,
                            title: "Công ty",
                            subtitle: companyInfo!.companyName,
                          ),
                          
                          // Quy mô
                          _buildContactItem(
                            icon: Icons.people_rounded,
                            title: "Quy mô",
                            subtitle:companyInfo!.scale,
                          ),

                          // Link website
                          _buildContactItem(
                            icon: Icons.public_rounded,
                            title: "Website",
                            subtitle: companyInfo!.websiteUrl ?? "Chưa có website",
                            hasLink: true,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Hoạt động tuyển dụng
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -25),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Card(
                    elevation: 2,
                    shadowColor: Colors.black12,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20,),
                          // Tiêu đề hoạt động tuyển dụng
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  // ignore: deprecated_member_use
                                  color: const Color(0xFF0D47A1).withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.analytics_rounded,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Hoạt động tuyển dụng",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D47A1),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              // Tin tuyển dụng
                              Expanded(
                                child: _buildAnalyticsCard(
                                  context,
                                  icon: Icons.description_rounded,
                                  title: "Tin tuyển dụng",
                                  value: jobPostingsList?.length.toString() ?? "0",
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Hồ sơ đã nhận
                              Expanded(
                                child: _buildAnalyticsCard(
                                  context,
                                  icon: Icons.people_alt_rounded,
                                  title: "Hồ sơ đã nhận",
                                  value: jobApplicationsList.length.toString(),
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Đã tuyển
                              Expanded(
                                child: _buildAnalyticsCard(
                                  context,
                                  icon: Icons.check_circle_rounded,
                                  title: "Đã tuyển",
                                  value: getPosisionPost().toString(),
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Lượt xem
                              Expanded(
                                child: _buildAnalyticsCard(
                                  context,
                                  icon: Icons.remove_red_eye_rounded,
                                  title: "Lượt xem",
                                  value: "210",
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Các nút hành động
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -15),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      // Nút tạo tin tuyển dụng mới
                      _buildActionButton(
                        context,
                        text: "Chỉnh sửa hồ sơ",
                        icon: Icons.add_circle_outline_rounded,
                        isPrimary: true,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: 
                            (context) => HrEditProfileScreen(
                              account: user!,
                              company: companyInfo!,
                              recruiterInfo: recruiterInfo!,
                            )),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      // Nút quản lý hồ sơ
                      _buildActionButton(
                        context,
                        text: "Quản lý hồ sơ ứng viên",
                        icon: Icons.people_rounded,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:(context) => 
                              HrCandidateManagementScreen(recruiterId: widget.recruiterId),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      // Đăng xuất
                      _buildActionButton(
                        context,
                        text: "Đăng xuất",
                        icon: Icons.logout_rounded,
                        isDestructive: true,
                        onPressed: () => _logout(context),
                      ),
                      const SizedBox(height: 0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      )
      
      
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF666666)),
        ),
      ],
    );
  }

  // Đường kẻ dọc
  Widget _buildVerticalDivider() {
    // ignore: deprecated_member_use
    return Container(height: 40, width: 1, color: Colors.grey.withValues(alpha:0.3));
  }

  // Item thông tin
  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool hasCopy = false,
    bool hasLink = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0D47A1), size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
              if (hasCopy)
                IconButton(
                  icon: const Icon(
                    Icons.content_copy,
                    size: 20,
                    color: Color(0xFF0D47A1),
                  ),
                  onPressed: () async {
                    await copyText(subtitle);
                  },
                ),
              if (hasLink)
                IconButton(
                  icon: const Icon(
                    Icons.open_in_new,
                    size: 20,
                    color: Color(0xFF0D47A1),
                  ),
                  onPressed: () {
                    launchURL(subtitle);
                    // launchURL("https://www.facebook.com/");
                  },
                ),
            ],
          ),
          if (!isLast) 
            Container(
              margin: EdgeInsets.fromLTRB(0, 8, 0, 8,),
              child: Divider(height: 1),
            ),
        ],
      ),
    );
  }

  // Item ô hoạt động
  Widget _buildAnalyticsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.grey.withValues(alpha:0.1)),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF666666),
            ),
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
    
        ],
      )
    
    );
  }

  // Nút xử lý
  Widget _buildActionButton(
    BuildContext context, {
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = false,
    bool isDestructive = false,
  }) {
    Color backgroundColor;
    Color textColor;
    Color iconColor;

    if (isPrimary) {
      backgroundColor = const Color(0xFF0D47A1);
      textColor = Colors.white;
      iconColor = Colors.white;
    } else if (isDestructive) {
      backgroundColor = Colors.white;
      textColor = Colors.redAccent;
      iconColor = Colors.redAccent;
    } else {
      backgroundColor = Colors.white;
      textColor = const Color(0xFF0D47A1);
      iconColor = const Color(0xFF0D47A1);
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color:
                // ignore: deprecated_member_use
                isPrimary ? Colors.transparent : Colors.grey.withValues(alpha:0.3),
            width: 1,
          ),
        ),
        elevation: isPrimary ? 2 : 0,
        shadowColor:
            isPrimary
                // ignore: deprecated_member_use
                ? const Color(0xFF0D47A1).withValues(alpha:0.3)
                : Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
