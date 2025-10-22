import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/config/enum/job_application_status.dart';
import 'package:job_connect/data/models/job_application_model.dart';
import 'package:job_connect/data/models/job_posting_model.dart';
import 'package:job_connect/features/profile/model/candidate_info_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/service/candidate_info_service.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import 'package:job_connect/recruiter_app/services/job_application_service.dart';
import 'package:job_connect/recruiter_app/services/job_posting_service.dart';
import 'package:job_connect/recruiter_app/services/recruiter_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CandidateCombined {
  final CandidateInfoModel candidate;
  final UserModel account;
  final JobApplicationModel jobApplication;

  CandidateCombined({
    required this.candidate,
    required this.account,
    required this.jobApplication,
  });
}

class CandidateManagementScreen extends StatefulWidget {
  final String recruiterId;

  const CandidateManagementScreen({
    super.key,
    required this.recruiterId,
  });

  @override
  State<CandidateManagementScreen> createState() =>
      _CandidateManagementScreenState();
}

class _CandidateManagementScreenState extends State<CandidateManagementScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();

  // Danh sách filter options (bao gồm "Tất cả")
  // ignore: unused_field
  final List<String> _filters = [
    'Tất cả', // All
    'pending',
    'viewed',
    'interview',
    'accepted',
    'rejected',
  ];
  String _selectedFilter = 'Tất cả';

  // Dữ liệu gốc và đã filter
  List<CandidateCombined> _candidates = [];
  bool _isLoading = true;
  // ignore: unused_field
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCandidates();
    _searchController.addListener(() {
      setState(() {}); // rebuild khi search thay đổi
    });
  }

  Future<void> _loadCandidates() async {
    // setState(() {
    //   _isLoading = true;
    //   _errorMessage = '';
    // });

    // try {
    //   final recruiterService = RecruiterService();
    //   final jobPostingService = JobPostingService();
    //   final jobApplicationService = JobApplicationService();
    //   final candidateService = CandidateInfoService();
    //   final accountService = UserService();

    //   // 1) Lấy thông tin recruiter để có companyId
    //   final recruiterInfo =
    //       await recruiterService.getRecruiterById(id: widget.recruiterId);
    //   final String? companyId = recruiterInfo!.idCompany;
    //   if (companyId == null) throw Exception('Recruiter chưa có công ty.');

    //   // 2) Lấy list job postings của company
    //   final List<JobPostingModel> jobPostings =
    //       await jobPostingService.getJobPostingsByCompany(companyId: companyId);

    //   final List<CandidateCombined> enriched = [];

    //   // 3) Với mỗi job, lấy ứng viên đã ứng tuyển
    //   for (final job in jobPostings) {
    //     final List<JobApplicationModel> jobApps =
    //         await jobApplicationService.getJobApplicationsByJob(jobPostId: job.idJobPost);

    //     // 4) Với mỗi jobApp, lấy CandidateInfo và Account
    //     for (final jobApp in jobApps) {
    //       final CandidateInfoModel candidate =
    //           await candidateService.getCandidateById(id:jobApp.idUser);
    //       final UserModel account =
    //           await accountService.getUserById(id: jobApp.idUser);

    //       enriched.add(CandidateCombined(
    //         candidate: candidate,
    //         account: account,
    //         jobApplication: jobApp,
    //       ));
    //     }
    //   }

    //   _candidates = enriched;
    //   setState(() {
    //     _isLoading = false;
    //   });
    // } catch (e) {
    //   setState(() {
    //     _errorMessage = 'Lỗi khi tải dữ liệu: $e';
    //     _isLoading = false;
    //   });
    // }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Chuẩn hóa ngày
  String formatDate(DateTime datetime) {
    return DateFormat('dd/MM/yyyy').format(datetime);
  }

  // Chuẩn hóa rating
  double roundToOneDecimal(double value) {
    return (value * 10).round() / 10;
  }

  /// Kết hợp search + filter theo applicationStatus
  List<CandidateCombined> get _filteredCandidates {
    final query = _searchController.text.trim().toLowerCase();

    // 1) Filter theo search (name, workPosition, skills)
    List<CandidateCombined> filtered = _candidates.where((item) {
      final name = (item.account.userName ?? '').toLowerCase();
      final position = (item.candidate.workPosition ?? '').toLowerCase();
      final skillsStr = item.candidate.skills ?? '';
      final skills = skillsStr
          .split(',')
          .map((s) => s.trim().toLowerCase())
          .toList();

      if (query.isEmpty) return true;
      if (name.contains(query) || position.contains(query)) return true;
      return skills.any((skill) => skill.contains(query));
    }).toList();

    // 2) Filter theo trạng thái ứng tuyển (applicationStatus)
    if (_selectedFilter != 'Tất cả') {
      final lowerFilter = _selectedFilter.toLowerCase();
      filtered = filtered.where((item) {
        final status = (item.jobApplication.applicationStatus).toLowerCase();
        return status == lowerFilter;
      }).toList();
    }

    return filtered;
  }

  // Chuẩn hóa từ accepted thành đã nhận việc

  String normalizeJobApplicationStatus(String status) {
    switch (status) {
      case 'viewed':
        return 'Đã xem';
      case 'interview':
        return 'Đang phỏng vấn';  
      case 'accepted':
        return 'Đã nhận việc';
      case 'rejected':
        return 'Đã từ chối';
      case 'pending':
        return 'Mới nộp hồ sơ';
      default:
        return 'Không xác định';
    }
  }

  // Lấy màu theo trạng thái
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.blue;
      case 'viewed':
        return Colors.grey;
      case 'interview':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
  // Lấy icon theo trạng 
  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return const Icon(Icons.file_present, size: 20, color: Colors.blue);
      case 'viewed':
        return const Icon(Icons.pending_actions, size: 20, color: Colors.grey);
      case 'interview':
        return const Icon(Icons.check_circle_outline, size: 20, color: Colors.orange);
      case 'accepted':
        return const Icon(Icons.task_alt, size: 20, color: Colors.green);
      case 'rejected':
        return const Icon(Icons.cancel_outlined, size: 20, color: Colors.red);
      default:
        return const Icon(Icons.person, size: 20, color: Colors.grey);
    }
  }
  // Hàm cập nhật trạng thái khi bấm nút "Chấp nhận"
  Future<void> _acceptApplication(CandidateCombined item) async {
    try {
      final jobApplicationService = JobApplicationService();
      await jobApplicationService.updateJobApplicationStatus(
        jobPostId: item.jobApplication.idJobPost,
        userId: item.jobApplication.idUser,
        newStatus: "interview",
      );
      
       // ignore: use_build_context_synchronously
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật trạng thái thành công')),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật trạng thái: $e')),
      );
    }
  }

  // Hàm cập nhật trạng thái khi bấm nút "Từ chối"
  Future<void> _rejectApplication(CandidateCombined item) async {
    try {
      final jobApplicationService = JobApplicationService();
      await jobApplicationService.updateJobApplicationStatus(
        jobPostId: item.jobApplication.idJobPost,
        userId: item.jobApplication.idUser,
        newStatus: "rejected",
      );
      
       // ignore: use_build_context_synchronously
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cập nhật trạng thái thành công')),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi cập nhật trạng thái: $e')),
      );
    }
  }

  /// Mở ứng dụng email mặc định với địa chỉ đích.
  Future<void> _launchEmail(String email) async {
    // Tạo một URI dạng mailto: someone@example.com
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    // Kiểm tra có thể mở URI không
    if (!await canLaunchUrl(emailUri)) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở ứng dụng email.')),
      );
      return;
    }

    await launchUrl(
      emailUri,
      mode: LaunchMode.externalApplication,
    );
  }

  /// Mở ứng dụng gọi điện với số điện thoại
  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );

    if (!await canLaunchUrl(phoneUri)) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở ứng dụng gọi điện.')),
      );
      return;
    }

    await launchUrl(
      phoneUri,
      mode: LaunchMode.externalApplication,
    );
  }



  void _showCandidateDetails(CandidateCombined item) {
    final account = item.account;
    final skills = item.candidate.skills != null
        ? item.candidate.skills!.split(',').map((s) => s.trim()).toList()
        : <String>[];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chi tiết ứng viên',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Profile header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: account.avatarUrl != null
                        ? NetworkImage(account.avatarUrl!)
                        : null,
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(width: 20),
                  // Tên + vị trí
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.candidate.workPosition ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: _getStatusColor(item.jobApplication.applicationStatus).withValues(alpha:0.3),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                normalizeJobApplicationStatus(item.jobApplication.applicationStatus),
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 40),
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  '${roundToOneDecimal(item.candidate.ratingScore ?? 0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Contact information
              const Text(
                'Thông tin liên hệ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _contactInfoItem(Icons.email_outlined, account.email),
              _contactInfoItem(Icons.phone_outlined, account.phoneNumber ?? ''),
              const SizedBox(height: 10),

              const Text(
                'Thông tin chuyên môn',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _infoItem('Vị trí ứng tuyển', item.candidate.workPosition ?? ''),
              _infoItem(
                'Kinh nghiệm',
                item.candidate.experienceYears != null
                    ? '${item.candidate.experienceYears} năm'
                    : '',
              ),
              _infoItem('Trường/Học',
                  item.candidate.universityName ?? ''),
              const SizedBox(height: 10),

              // Skills
              const Text(
                'Kỹ năng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills.map((skill) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const Spacer(),
              // Action buttons: chỉ hiển thị nếu trạng thái là 'pending' hoặc 'viewed'
              if (item.jobApplication.applicationStatus == 'pending' || item.jobApplication.applicationStatus == 'viewed')
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _acceptApplication(item),
                        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                        label: const Text('Chấp nhận'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _rejectApplication(item),
                        icon: const Icon(Icons.cancel_outlined, color: Colors.white),
                        label: const Text('Từ chối'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for contact info
  Widget _contactInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.content_copy, size: 18),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã sao chép vào clipboard'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            color: Colors.grey[600],
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // Helper for info row
  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Quản lý ứng viên',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black54),
            onPressed: () {},
          ),
          // IconButton(
          //   icon: const Icon(Icons.person_outline, color: Colors.black54),
          //   onPressed: () {},
          // ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // 1) Card "Tất cả"
                  _buildStatsCard(
                    icon: Icons.person,
                    title: 'Tất cả',
                    value: _candidates.length.toString(),
                    color: _selectedFilter == 'Tất cả' ? Colors.blue : Colors.grey,
                    onTap: () {
                      setState(() {
                        _selectedFilter = 'Tất cả';
                      });
                    },
                  ),

                  // 2) Card "Mới nộp hồ sơ"
                  _buildStatsCard(
                    icon: Icons.file_present,
                    title: 'Mới nộp hồ sơ',
                    value: _candidates
                        .where((c) =>
                            c.jobApplication.applicationStatus == JobApplicationStatus.pending.name)
                        .length
                        .toString(),
                    color: _selectedFilter == JobApplicationStatus.pending.name
                        ? Colors.blue
                        : Colors.grey,
                    onTap: () {
                      setState(() {
                        _selectedFilter = JobApplicationStatus.pending.name;
                      });
                    },
                  ),

                  // 3) Card "Đang phỏng vấn"
                  _buildStatsCard(
                    icon: Icons.pending_actions,
                    title: 'Đã xem',
                    value: _candidates
                        .where((c) =>
                            c.jobApplication.applicationStatus == JobApplicationStatus.viewed.name)
                        .length
                        .toString(),
                    color: _selectedFilter == JobApplicationStatus.viewed.name
                        ? Colors.orange
                        : Colors.grey,
                    onTap: () {
                      setState(() {
                        _selectedFilter = JobApplicationStatus.viewed.name;
                      });
                    },
                  ),

                  // 4) Card "Đang phỏng vấn"
                  _buildStatsCard(
                    icon: Icons.check_circle_outline,
                    title: 'Đang phỏng vấn',
                    value: _candidates
                        .where((c) =>
                            c.jobApplication.applicationStatus == JobApplicationStatus.interview.name)
                        .length
                        .toString(),
                    color: _selectedFilter == JobApplicationStatus.interview.name
                        ? Colors.purple
                        : Colors.grey,
                    onTap: () {
                      setState(() {
                        _selectedFilter = JobApplicationStatus.interview.name;
                      });
                    },
                  ),

                  // 5) Card "Đã nhận việc"
                  _buildStatsCard(
                    icon: Icons.task_alt,
                    title: 'Đã nhận việc',
                    value: _candidates
                        .where((c) =>
                            c.jobApplication.applicationStatus == JobApplicationStatus.accepted.name)
                        .length
                        .toString(),
                    color: _selectedFilter == JobApplicationStatus.accepted.name
                        ? Colors.green
                        : Colors.grey,
                    onTap: () {
                      setState(() {
                        _selectedFilter = JobApplicationStatus.accepted.name;
                      });
                    },
                  ),

                  // 6) Card "Đã từ chối"
                  _buildStatsCard(
                    icon: Icons.cancel_outlined,
                    title: 'Đã từ chối',
                    value: _candidates
                        .where((c) => 
                        c.jobApplication.applicationStatus == JobApplicationStatus.rejected.name)
                        .length
                        .toString(),
                    color: _selectedFilter == JobApplicationStatus.rejected.name
                        ? Colors.red
                        : Colors.grey,
                    onTap: () {
                      setState(() {
                        _selectedFilter = JobApplicationStatus.rejected.name;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm ứng viên...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Hiển thị trạng thái filter hiện tại dưới dạng icon
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _selectedFilter == 'Tất cả'
                      ? const Icon(Icons.list, size: 20, color: Colors.blue)
                      : _getStatusIcon(_selectedFilter),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Candidate List
          Expanded(
            child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredCandidates.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 56,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không tìm thấy ứng viên',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredCandidates.length,
                      itemBuilder: (context, index) {
                        final item = _filteredCandidates[index];
                        final account = item.account;
                        final skills = item.candidate.skills != null
                            ? item.candidate.skills!
                                .split(',')
                                .map((s) => s.trim())
                                .toList()
                            : <String>[];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => _showCandidateDetails(item),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Hàng đầu: Avatar + Tên + Rating + Trường/Học + Vị trí
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundImage:
                                            account.avatarUrl != null
                                                ? NetworkImage(account.avatarUrl!)
                                                : null,
                                        backgroundColor: Colors.grey[200],
                                      ),
                                      const SizedBox(width: 16),

                                      // Expanded chứa Tên và Trường
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // 1) Tên
                                            Text(
                                              account.userName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            // 2) Vị trí
                                            Text(
                                              item.candidate.workPosition ?? " ",
                                              // maxLines: 1,
                                              // overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 16),

                                      // Cột phải: Rating 
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          // 3) Rating
                                          Row(
                                            children: [
                                              const Icon(Icons.star,
                                                  color: Colors.amber,
                                                  size: 16
                                                ),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${roundToOneDecimal(item.candidate.ratingScore ?? 0)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                                                                          ],
                                          ),
                                          const SizedBox(height: 4),
                                          // // 4) Ngày ứng tuyển
                                          // Text(
                                          //   formatDate(item.jobApplication.submittedAt),
                                          //   maxLines: 1,
                                          //   overflow: TextOverflow.ellipsis,
                                          //   style: TextStyle(
                                          //     color: Colors.grey[600],
                                          //     fontSize: 12,
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Hàng 2: Skills 
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children: skills.map((skill) {
                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                skill,
                                                style: TextStyle(
                                                  color: Colors.blue[700],
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Hàng 3: Action buttons (email, phone) + status
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(item.jobApplication.applicationStatus).withValues(alpha:0.3),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          normalizeJobApplicationStatus(item.jobApplication.applicationStatus),
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      const SizedBox(width: 60),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.email_outlined),
                                            color: Colors.blue,
                                            iconSize: 20,
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              final email = item.account.email;
                                              if (email.isNotEmpty) {
                                                _launchEmail(email);
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Không có địa chỉ email để gửi.')),
                                                );
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.phone_outlined),
                                            color: Colors.green,
                                            iconSize: 20,
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              final phone = item.account.phoneNumber;
                                              if (phone != null && phone.isNotEmpty) {
                                                _launchPhone(phone);
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Không có số điện thoại để gọi.')),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  /// Widget cho mỗi stats card. Nếu được chọn (isActive=true), border
  /// và màu icon/text sẽ đậm hơn.
  Widget _buildStatsCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    final bool isActive = color != Colors.grey;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        width: 140,
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha:0.2) : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? color : Colors.grey.withValues(alpha:0.2),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isActive ? color : Colors.grey, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isActive ? color : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: isActive ? color.withValues(alpha:0.9) : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
