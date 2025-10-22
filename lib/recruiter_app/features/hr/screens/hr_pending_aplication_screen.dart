import 'package:flutter/material.dart';
import 'package:job_connect/data/models/job_application_model.dart';
import 'package:job_connect/data/models/job_posting_model.dart';
import 'package:job_connect/data/models/role_model.dart';
import 'package:job_connect/features/profile/model/candidate_info_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/service/candidate_info_service.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import '../../../services/job_application_service.dart';
import '../../../services/job_posting_service.dart';
import '../../candidate/screens/detail_candidate_of_hr.dart';

class PendingApplicationsScreen extends StatefulWidget {
  final List<JobApplicationModel> pendingApplications;

  const PendingApplicationsScreen({
    super.key,
    required this.pendingApplications,
  });

  @override
  State<PendingApplicationsScreen> createState() => _PendingApplicationsScreenState();
}

class _PendingApplicationsScreenState extends State<PendingApplicationsScreen> {
  final UserService _accountService = UserService();
  final CandidateInfoService _candidateInfoService = CandidateInfoService();
  final JobApplicationService _jobApplicationService = JobApplicationService();
  final JobPostingService _jobPostingService = JobPostingService();

  List<UserModel> accounts = [];
  List<CandidateInfoModel> candidates = [];
  List<JobPostingModel> jobs = [];
  bool isLoading = true;
  List<JobApplicationModel> localApplications = [];

  @override
  void initState() {
    super.initState();
    localApplications = List<JobApplicationModel>.from(widget.pendingApplications);
    loadData();
  }

  Future<void> loadData() async {
    try {
      final List<UserModel> loadedAccounts = [];
      final List<CandidateInfoModel> loadedCandidates = [];
      final List<JobPostingModel> loadedJobs = [];

      for (var application in widget.pendingApplications) {
        final account = await _accountService.getUserById(id: application.idUser);
        loadedAccounts.add(account);

        final candidate = await _candidateInfoService.getCandidateById(id:application.idUser);
        loadedCandidates.add(candidate);

        final job = await _jobPostingService.getJobPostingById(jobId: application.idJobPost);
        loadedJobs.add(job!);
      }

      setState(() {
        accounts = loadedAccounts;
        candidates = loadedCandidates;
        jobs = loadedJobs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải dữ liệu: $e')),
      );
    }
  }

  Future<void> rejectApplication(JobApplicationModel application) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận từ chối'),
        content: const Text('Bạn có chắc chắn muốn từ chối hồ sơ này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _jobApplicationService.updateJobApplicationStatus(
        jobPostId: application.idJobPost,
        userId: application.idUser,
        newStatus: "rejected",
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã từ chối hồ sơ thành công.')),
      );

     setState(() {
        localApplications.removeWhere((app) =>
            app.idJobPost == application.idJobPost &&
            app.idUser == application.idUser);
        accounts.removeWhere((a) => a.idUser == application.idUser);
        candidates.removeWhere((c) => c.idUser == application.idUser);
        jobs.removeWhere((j) => j.idJobPost == application.idJobPost);
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi từ chối hồ sơ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ đang chờ đánh giá'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: localApplications.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final application = localApplications[index];

                final account = accounts.firstWhere(
                  (acc) => acc.idUser == application.idUser,
                  orElse: () => UserModel(
                    idUser: application.idUser,
                    userName: 'Ẩn danh',
                    email: '',
                    idRole: 'R02',
                    accountStatus: 'inactive',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    gender: 'Khác',
                    role: RoleModel(idRole: 'R02', roleName: 'Candidate'),
                  ),
                );

                final candidate = candidates.firstWhere(
                  (cand) => cand.idUser == application.idUser,
                  orElse: () => CandidateInfoModel(
                    idUser: application.idUser,
                    workPosition: 'Chưa cập nhật',
                  ),
                );

                final job = jobs.firstWhere(
                  (j) => j.idJobPost == application.idJobPost,
                  orElse: () => JobPostingModel(
                    idJobPost: application.idJobPost,
                    title: 'Không rõ vị trí',
                    salary: 0,
                    location: '',
                    workType: '',
                    experienceLevel: '',
                    idCompany: '',
                    description: '',
                    requirements: '',
                    applicationDeadline: DateTime.now(),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    isFeatured: 0,
                    postStatus: 'draft',
                  ),
                );

                return Card(
                  elevation: 6,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: Avatar và tên ứng viên
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue.withValues(alpha:0.2),
                              child: Text(
                                account.userName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    account.userName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    candidate.workPosition ?? 'Chưa cập nhật vị trí',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Thông tin chi tiết
                        Row(
                          children: [
                            const Icon(Icons.school_outlined, color: Colors.blue, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                candidate.universityName ?? 'Chưa cập nhật trường đại học',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star_outline, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Điểm đánh giá: ${candidate.ratingScore?.toStringAsFixed(1) ?? 'Chưa có'}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.work_outline, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Kinh nghiệm: ${candidate.experienceYears ?? 0} năm',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_history, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 260,
                              child: Text(
                                'Vị trí mong muốn: ${candidate.workPosition}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Danh sách kỹ năng
                        Text(
                          'Kỹ năng:',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (candidate.skills ?? 'Chưa cập nhật')
                              .split(',')
                              .map((skill) => Chip(
                                    label: Text(skill.trim()),
                                    backgroundColor: Colors.blue.withValues(alpha:0.1),
                                    labelStyle: const TextStyle(color: Colors.blue),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 16),

                        // Thông báo ngày ứng tuyển kèm tên job
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Ứng viên đã ứng tuyển vào ngày ${application.submittedAt.toLocal().toString().split(' ')[0]} cho vị trí ${job.title}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Nút hành động
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CandidateDetailScreen(candidate: candidate, account: account)),
                                );
                              },
                              icon: const Icon(Icons.visibility_outlined, size: 16, color: Colors.white),
                              label: const Text('Xem chi tiết'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3366FF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => rejectApplication(application),
                              icon: const Icon(Icons.close, size: 16, color: Colors.red),
                              label: const Text('Từ chối'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}