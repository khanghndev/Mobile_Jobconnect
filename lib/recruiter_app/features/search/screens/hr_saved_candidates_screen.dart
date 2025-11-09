import 'package:flutter/material.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/features/profile/model/candidate_info_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/service/candidate_info_service.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import '../../../services/save_candidate_service.dart';
import '../../candidate/screens/detail_candidate_of_hr.dart';

class HrSavedCandidatesScreen extends StatefulWidget {
  final List<String> savedCandidateIds;
  String recruiterId;

  HrSavedCandidatesScreen({
    super.key,
    required this.savedCandidateIds,
    required this.recruiterId,
  });

  @override
  State<HrSavedCandidatesScreen> createState() => _HrSavedCandidatesScreenState();
}

class _HrSavedCandidatesScreenState extends State<HrSavedCandidatesScreen> {
  // Khởi tạo service
  final CandidateInfoService candidateInfoService = CandidateInfoService();
  final UserService accountService = UserService();
  final SaveCandidateService saveCandidateService = SaveCandidateService();
  List<CandidateInfoModel> savedCandidates = [];
  List<UserModel> savedUsers = [];

  @override
  void initState() {
    super.initState();
    loadSavedCandidates();
  }

  Future<void> loadSavedCandidates() async {
    try {
      List<CandidateInfoModel> tempCandidates = [];
      List<UserModel> tempUsers = [];

      // Lặp qua từng ID trong danh sách savedCandidateIds
      for (String candidateId in widget.savedCandidateIds) {
        // Lấy thông tin ứng viên
        final candidate = await candidateInfoService.getCandidateById(id:candidateId);
        tempCandidates.add(candidate);
        // Lấy thông tin tài khoản của ứng viên
        final account = await accountService.getUserById(id:candidate.idUser);
        tempUsers.add(account);
      }

      // Cập nhật state với danh sách ứng viên và tài khoản
      setState(() {
        savedCandidates = tempCandidates;
        savedUsers = tempUsers;
      });
    } catch (e) {
      // Hiển thị lỗi nếu xảy ra vấn đề khi tải dữ liệu
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải danh sách ứng viên đã lưu: $e')),
      );
    }
  }

  Future<void> _removeCandidate(CandidateInfoModel candidate) async {
    final account = await accountService.getUserById(id:candidate.idUser);
    await saveCandidateService.deleteCandidate(recruiterId: widget.recruiterId, candidateId: candidate.idUser);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã xóa ứng viên ${account.userName} khỏi danh sách lưu.')),
    );
    // Immediately remove candidate from lists
    setState(() {
      final index = savedCandidates.indexWhere((c) => c.idUser == candidate.idUser);
      if (index != -1) {
        savedCandidates.removeAt(index);
        savedUsers.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Danh sách ứng viên đã lưu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: loadSavedCandidates,
        child: savedCandidates.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bookmark_outline, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'Chưa có ứng viên nào được lưu',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: savedCandidates.length,
                itemBuilder: (context, index) {
                  final candidate = savedCandidates[index];
                  final account = savedUsers[index];
                  return _buildCandidateCard(candidate, account);
                },
              ),
      ),
    );
  }

  Widget _buildCandidateCard(CandidateInfoModel candidate, UserModel account) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: ImageUtils.getImageProvider(account.avatarUrl),
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
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        candidate.workPosition ?? 'Chưa xác định',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        account.address ?? '---',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (candidate.skills?.split(',') ?? []).isNotEmpty
                  ? candidate.skills!.split(',').map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          skill.trim(),
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList()
                  : [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Chưa có kỹ năng',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.visibility_outlined, size: 18, color: Colors.blue),
                  label: const Text('Xem chi tiết', style: TextStyle(color: Colors.blue)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CandidateDetailScreen(
                          candidate: candidate,
                          account: account,
                        ),
                      ),
                    );
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                  label: const Text('Xóa', style: TextStyle(color: Colors.red)),
                  onPressed: () => _removeCandidate(candidate),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}