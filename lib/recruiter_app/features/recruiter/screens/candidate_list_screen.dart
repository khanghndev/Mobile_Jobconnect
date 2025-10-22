// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/data/models/job_application_model.dart';
import 'package:job_connect/features/profile/model/candidate_info_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/service/user_service.dart';
import '../../../services/chat_service.dart';
import '../../candidate/screens/detail_candidate_of_hr.dart';

// ignore: must_be_immutable
class CandidateListPage extends StatefulWidget {
  String recruiterId;
  List<CandidateInfoModel> candidateInfoList;
  List<JobApplicationModel> jobApplicationList;
  CandidateListPage({
    super.key,
    required this.recruiterId,
    required this.candidateInfoList,
    required this.jobApplicationList,
  });

  @override
  State<CandidateListPage> createState() => _CandidateListPageState();
}

class _CandidateListPageState extends State<CandidateListPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tất cả';
  final List<String> _filters = [
    'Tất cả', 'Chờ duyệt', 'Đã xem', 'Phỏng vấn', 'Đã nhận','Từ chối',
  ];

  final UserService _accountService = UserService();
  final Map<String, Future<UserModel>> _accountFutures = {};

  bool _isSearching = false;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccounts().then((_) {
      setState(() {
        _isLoading = false; // Dữ liệu đã được tải
      });
    });
    _tabController = TabController(length: 6, vsync: this);
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadAccounts(); // gọi lại hàm cũ
    setState(() {
      _isLoading = false;
    });
  }


  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  final Map<String, UserModel> accountsMap = {};

  Future<void> _loadAccounts() async {
    try {
      for (var candidate in widget.candidateInfoList) {
        if (!accountsMap.containsKey(candidate.idUser)) {
          final account = await _accountService.getUserById(id:candidate.idUser);
          accountsMap[candidate.idUser] = account;
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tải thông tin tài khoản: $e')),
      );
    }
  }

  String? _getApplicationStatus(String idUser) {
    final apps = widget.jobApplicationList
        .where((e) => e.idUser == idUser)
        .toList();
    if (apps.isEmpty) return null;
    apps.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return apps.first.applicationStatus;
  }

  DateTime? _getApplicationDate(String idUser) {
    final apps = widget.jobApplicationList
        .where((e) => e.idUser == idUser)
        .toList();
    if (apps.isEmpty) return null;
    apps.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return apps.first.submittedAt;
  }

  String? _mapFilterToSqlStatus(String filter) {
    switch (filter) {
      case 'Chờ duyệt':
        return 'pending';
      case 'Đã xem':
        return 'viewed';
      case 'Phỏng vấn':
        return 'interview';
      case 'Đã nhận':
        return 'accepted';
      case 'Từ chối':
        return 'rejected';
      default:
        return null;
    }
  }

  List<CandidateInfoModel> get _filteredCandidates { List<CandidateInfoModel> result = widget.candidateInfoList;
    if (_selectedFilter != 'Tất cả') {
      final sqlStatus = _mapFilterToSqlStatus(_selectedFilter);
      result = result
          .where((c) => _getApplicationStatus(c.idUser) == sqlStatus)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result
          .where(
            (c) =>
                c.idUser.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (c.workPosition?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
                (c.skills?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false),
          )
          .toList();
    }

    return result;
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'Chờ duyệt';
      case 'viewed':
        return 'Đã xem';
      case 'interview':
        return 'Phỏng vấn';
      case 'accepted':
        return 'Đã nhận';
      case 'rejected':
        return 'Từ chối';
      default:
        return 'Không xác định';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.blue;
      case 'viewed':
        return Colors.orange;
      case 'interview':
        return Colors.purple;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
      _searchController.text = _searchQuery;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Tìm kiếm ứng viên...",
                  border: InputBorder.none,
                ),
                onChanged: _onSearchChanged,
                onSubmitted: (_) {
                  setState(() {
                    _searchQuery = _searchController.text;
                  });
                },
              )
            : const Text(
                "Quản lý ứng viên",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF3366FF)),
        actions: _isSearching
            ? [
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      _searchController.clear();
                      _onSearchChanged('');
                    } else {
                      _stopSearch();
                    }
                  },
                ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.search),
                  tooltip: 'Tìm kiếm ứng viên',
                  onPressed: _startSearch,
                ),
              ],
      ),
      body: Column(
        children: [
          // Scrollable stat filter bar
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatFilterCard(
                    label: 'Tổng số',
                    count: widget.candidateInfoList.length.toString(),
                    color: const Color(0xFF3366FF),
                    icon: Icons.people,
                    filter: 'Tất cả',
                  ),
                  const SizedBox(width: 10),
                  _buildStatFilterCard(
                    label: 'Chờ duyệt',
                    count: widget.candidateInfoList
                        .where((c) => _getApplicationStatus(c.idUser) == 'pending')
                        .length
                        .toString(),
                    color: const Color(0xFF42A5F5),
                    icon: Icons.hourglass_empty,
                    filter: 'Chờ duyệt',
                  ),
                  const SizedBox(width: 10),
                  _buildStatFilterCard(
                    label: 'Đã xem',
                    count: widget.candidateInfoList
                        .where((c) => _getApplicationStatus(c.idUser) == 'viewed')
                        .length
                        .toString(),
                    color: Colors.orange,
                    icon: Icons.remove_red_eye,
                    filter: 'Đã xem',
                  ),
                  const SizedBox(width: 10),
                  _buildStatFilterCard(
                    label: 'Phỏng vấn',
                    count: widget.candidateInfoList
                        .where((c) => _getApplicationStatus(c.idUser) == 'interview')
                        .length
                        .toString(),
                    color: const Color(0xFF7C4DFF),
                    icon: Icons.mic,
                    filter: 'Phỏng vấn',
                  ),
                  const SizedBox(width: 10),
                  _buildStatFilterCard(
                    label: 'Đã nhận',
                    count: widget.candidateInfoList
                        .where((c) => _getApplicationStatus(c.idUser) == 'accepted')
                        .length
                        .toString(),
                    color: const Color(0xFF4CAF50),
                    icon: Icons.check_circle,
                    filter: 'Đã nhận',
                  ),
                  const SizedBox(width: 10),
                  _buildStatFilterCard(
                    label: 'Từ chối',
                    count: widget.candidateInfoList
                        .where((c) => _getApplicationStatus(c.idUser) == 'rejected')
                        .length
                        .toString(),
                    color: Colors.red,
                    icon: Icons.cancel,
                    filter: 'Từ chối',
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: const Color(0xFF3366FF),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF3366FF),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: "Tất cả"),
                Tab(text: "Chờ duyệt"),
                Tab(text: "Đã xem"),
                Tab(text: "Phỏng vấn"),
                Tab(text: "Đã nhận"),
                Tab(text: "Từ chối"),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey.shade50,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCandidateList(_filteredCandidates),
                  _buildCandidateList(
                    _filteredCandidates
                        .where((c) => _getApplicationStatus(c.idUser) == 'pending')
                        .toList(),
                  ),
                  _buildCandidateList(
                    _filteredCandidates
                        .where((c) => _getApplicationStatus(c.idUser) == 'viewed')
                        .toList(),
                  ),
                  _buildCandidateList(
                    _filteredCandidates
                        .where((c) => _getApplicationStatus(c.idUser) == 'interview')
                        .toList(),
                  ),
                  _buildCandidateList(
                    _filteredCandidates
                        .where((c) => _getApplicationStatus(c.idUser) == 'accepted')
                        .toList(),
                  ),
                  _buildCandidateList(
                    _filteredCandidates
                        .where((c) => _getApplicationStatus(c.idUser) == 'rejected')
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatFilterCard({
    required String label,
    required String count,
    required Color color,
    required IconData icon,
    required String filter,
  }) {
    final bool isSelected = _selectedFilter == filter || (filter == 'Tất cả' && _selectedFilter == 'Tất cả');
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        width: 100,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha:0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha:0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? color : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateList(List<CandidateInfoModel> candidates) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: candidates.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                const Text(
                  "Không tìm thấy ứng viên nào",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final candidate = candidates[index];
              final status = _getApplicationStatus(candidate.idUser);
              final date = _getApplicationDate(candidate.idUser);

              // Lấy thông tin Account (tên) theo idUser, cache lại để tránh gọi lại nhiều lần
              _accountFutures.putIfAbsent(
                candidate.idUser,
                () => _accountService.getUserById(id:candidate.idUser),
              );

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    // Chuyển đến trang chi tiết ứng viên
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              // ignore: deprecated_member_use
                              backgroundColor: _getStatusColor(status).withValues(alpha:0.1),
                              radius: 28,
                              child: Text(
                                candidate.idUser.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FutureBuilder<UserModel>(
                                    future: _accountService.getUserById(id:candidate.idUser),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const SizedBox(
                                          height: 18,
                                          width: 80,
                                          child: LinearProgressIndicator(minHeight: 2),
                                        );
                                      }
                                      if (snapshot.hasError) {
                                        return Text(
                                          'Lỗi',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.red,
                                          ),
                                        );
                                      }
                                      final account = snapshot.data;
                                      return Text(
                                        account?.userName ?? 'Không xác định',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      );
                                    },
                                  ),
                                  
                                  const SizedBox(height: 4),
                                  Text(
                                    candidate.workPosition ?? 'Chưa cập nhật',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (status != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(status).withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  _getStatusText(status),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getStatusColor(status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildInfoChip(
                              Icons.calendar_today,
                              date != null
                                  ? DateFormat('dd/MM/yyyy').format(date)
                                  : 'Chưa cập nhật',
                            ),
                            const SizedBox(width: 12),
                            _buildInfoChip(
                              Icons.work,
                              '${candidate.experienceYears ?? 0} năm KN',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (candidate.skills != null && candidate.skills!.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: candidate.skills!
                                .split(',')
                                .map(
                                  (skill) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Text(
                                      skill.trim(),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.email_outlined, size: 16),
                              label: const Text('Liên hệ'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF3366FF),
                              ),
                              onPressed: () {
                                final account = accountsMap[candidate.idUser];
                                if (account == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Thông tin tài khoản chưa được tải.')),
                                  );
                                  return;
                                }
                              },
                            ),

                            const SizedBox(width: 8),
                            TextButton.icon(
                              icon: const Icon(Icons.visibility_outlined, size: 16),
                              label: const Text('Xem chi tiết'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF3366FF),
                              ),
                             onPressed: () {
                                final account = accountsMap[candidate.idUser];
                                if (account == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Thông tin tài khoản chưa được tải.')),
                                  );
                                  return;
                                }
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          )
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}