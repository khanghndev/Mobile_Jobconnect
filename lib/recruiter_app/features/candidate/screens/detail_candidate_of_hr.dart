import 'package:flutter/material.dart';
import 'package:job_connect/model/save_candidate_model.dart';
import 'package:job_connect/features/profile/model/candidate_info_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/recruiter_app/services/save_candidate_service.dart';

class CandidateDetailScreen extends StatefulWidget {
  final CandidateInfoModel candidate;
  final UserModel account;

  const CandidateDetailScreen({
    super.key,
    required this.candidate,
    required this.account,
  });

  @override
  State<CandidateDetailScreen> createState() => _CandidateDetailScreenState();
}

class _CandidateDetailScreenState extends State<CandidateDetailScreen> {
  final SaveCandidateService saveCandidateService = SaveCandidateService();
  List<String> savedCandidateIds = [];

  @override
  void initState() {
    super.initState();
    _loadSavedIds();
  }

  List<String> _parseSkills(String? skills) {
    if (skills == null || skills.trim().isEmpty) return [];
    return skills.split(',').map((s) => s.trim()).toList();
  }

  Future<void> _loadSavedIds() async {
    try {
      final list = await saveCandidateService.getSavedCandidates(recruiterId: widget.account.idUser);
      setState(() {
        savedCandidateIds = list.map((s) => s.idUserCandidate).toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải danh sách đã lưu: $e')),
        );
      }
    }
  }

  bool isCandidateSaved(String idUser) => savedCandidateIds.contains(idUser);

  void toggleSaveCandidate(CandidateInfoModel c) async {
    final id = c.idUser;
    final name = widget.account.userName;
    try {
      if (isCandidateSaved(id)) {
        await saveCandidateService.deleteCandidate(recruiterId:  widget.account.idUser,candidateId: id);
        setState(() => savedCandidateIds.remove(id));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã bỏ lưu $name'), duration: const Duration(seconds: 3)),
          );
        }
      } else {
        final item = SaveCandidateModel(
          idUserRecruiter: widget.account.idUser,
          idUserCandidate: id,
          savedAt: DateTime.now(),
          note: 'Ứng viên tiềm năng',
        );
        await saveCandidateService.saveCandidate(data: item);
        setState(() => savedCandidateIds.add(id));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã lưu $name'), duration: const Duration(seconds: 3)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu/bỏ lưu: $e')),
        );
      }
    }
  }

  String amendsLocations(String location) {
    if (location == "TP. Hồ Chí Minh") return "TP.HCM";
    return location;
  }

  @override
  Widget build(BuildContext context) {
    final skillList = _parseSkills(widget.candidate.skills);
    final account = widget.account;
    final candidate = widget.candidate;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blueGrey[800]),
        title: Text('Thông tin chi tiết', style: TextStyle(color: Colors.blueGrey[900], fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 16)],
                  ),
                  child: CircleAvatar(
                    radius: 64,
                    backgroundImage: account.avatarUrl != null ? NetworkImage(account.avatarUrl!) : null,
                    backgroundColor: Colors.grey[200],
                    child: account.avatarUrl == null
                        ? Icon(Icons.person, size: 64, color: Colors.grey[400])
                        : null,
                  ),
                ),
                if (account.accountStatus == 'active')
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent[400],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(account.userName,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.badge, size: 18, color: Colors.blueGrey[400]),
                        const SizedBox(width: 4),
                        Text(candidate.workPosition ?? '---', style: TextStyle(color: Colors.blueGrey[600])),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _infoSection(title: 'Thông tin liên hệ', widgets: [
                    _infoRow(Icons.email, account.email),
                    if (account.phoneNumber != null) ...[
                      const SizedBox(height: 8),
                      _infoRow(Icons.phone, account.phoneNumber!)
                    ],
                    const SizedBox(height: 8),
                    _infoRow(Icons.location_on, account.address ?? '---'),
                  ]),
                  const SizedBox(height: 16),
                  _infoSection(title: 'Chi tiết ứng viên', widgets: [
                    _infoRow(Icons.work, 'Kinh nghiệm: ${candidate.experienceYears ?? 0} năm'),
                    const SizedBox(height: 8),
                    _infoRow(Icons.school, 'Đại học: ${candidate.universityName ?? '---'}'),
                    const SizedBox(height: 8),
                    _infoRow(Icons.grade, 'Trình độ: ${candidate.educationLevel ?? '---'}'),
                    const SizedBox(height: 8),
                    _infoRow(Icons.star, 'Đánh giá: ${candidate.ratingScore?.toStringAsFixed(1) ?? '0.0'}'),
                  ]),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Kỹ năng',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[800])),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skillList
                          .map((skill) => Chip(
                                label: Text(skill),
                                elevation: 1,
                                backgroundColor: Colors.blueAccent.withValues(alpha:0.15),
                                labelStyle: TextStyle(color: Colors.blueAccent[700]),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.message, color: Colors.white),
                            label: Text('Liên hệ', style: TextStyle(color: Colors.white, fontSize: 14)),
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                             icon: Icon(
                              isCandidateSaved(candidate.idUser)
                                  ? Icons.bookmark
                                  : Icons.bookmark_outline,
                              size: 18,
                              color: Colors.blue,
                            ),
                            label: Text(
                              isCandidateSaved(candidate.idUser) ? 'Đã lưu' : 'Lưu xem sau',
                              style: TextStyle(color: Colors.blueAccent, fontSize: 14),
                            ),
                            onPressed: () => toggleSaveCandidate(candidate),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.blueAccent),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoSection({required String title, required List<Widget> widgets}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
              const SizedBox(height: 12),
              ...widgets,
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blueGrey[600]),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: Colors.blueGrey[800]))),
      ],
    );
  }
}
