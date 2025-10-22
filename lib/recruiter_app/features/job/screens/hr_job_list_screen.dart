import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job_connect/data/models/job_application_model.dart';
import 'package:job_connect/data/models/job_posting_model.dart';
import 'hr_job_detail_screen.dart';
import '../../profile/screens/hr_profile_screen.dart';

class JobListScreen extends StatefulWidget {
  final List<JobPostingModel> jobpostingList;
  final List<JobApplicationModel> jobApplications;
  const JobListScreen({
    super.key,
    required this.jobpostingList,
    required this.jobApplications,
  });

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  String _currentFilter = "Tất cả";
  String _searchKeyword = "";
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // ignore: unused_field
  final List<String> _filterOptions = [
    "Tất cả",
    "Đang tuyển",
    "Đã đóng",
    "Chờ duyệt",
    "Chỉnh sửa",
    "Tin gấp",
  ];

  List<JobPostingModel> get _filteredJobs {
    List<JobPostingModel> jobs;
    if (_currentFilter == "Tất cả") {
      jobs = widget.jobpostingList;
    } else if (_currentFilter == "Tin gấp") {
      jobs = widget.jobpostingList.where((job) => job.isFeatured == 1).toList();
    } else {
      String status = _mapFilterToPostStatus(_currentFilter);
      jobs = widget.jobpostingList.where((job) => job.postStatus == status).toList();
    }
    // Lọc theo từ khóa tìm kiếm nếu có
    if (_searchKeyword.trim().isNotEmpty) {
      final keyword = _searchKeyword.trim().toLowerCase();
      jobs = jobs.where((job) =>
        job.title!.toLowerCase().contains(keyword) ||
        job.location!.toLowerCase().contains(keyword) ||
        (job.description ?? '').toLowerCase().contains(keyword)
      ).toList();
    }
    return jobs;
  }

  String _mapFilterToPostStatus(String filter) {
    switch (filter) {
      case "Đang tuyển":
        return "open";
      case "Đã đóng":
        return "closed";
      case "Chờ duyệt":
        return "waiting";
      case "Chỉnh sửa":
        return "editing";
      default:
        return "open";
    }
  }

  String _mapPostStatusToFilter(String postStatus) {
    switch (postStatus) {
      case "open":
        return "Đang tuyển";
      case "closed":
        return "Đã đóng";
      case "waiting":
        return "Chờ duyệt";
      case "editing":
        return "Chỉnh sửa";
      default:
        return "Đang tuyển";
    }
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
      _searchController.text = _searchKeyword;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchKeyword = "";
      _searchController.clear();
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchKeyword = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: "Tìm kiếm công việc...",
                    border: InputBorder.none,
                  ),
                  onChanged: _onSearchChanged,
                  onSubmitted: (_) {
                    setState(() {
                      _searchKeyword = _searchController.text;
                    });
                  },
                )
              : const Text(
                  'Danh sách công việc',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.black87,
                  ),
                ),
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
                    onPressed: _startSearch,
                  ),
                ],
        ),
        body: Column(
          children: [
            _buildStatFilterBar(),
            Expanded(child: _buildJobList()),
          ],
        ),
        // floatingActionButton: FloatingActionButton.extended(
        //   onPressed: () {
        //     // Navigator.push(context,
        //     // MaterialPageRoute(builder: (contetx)=> RecruiterProfilePage(
        //     //   recruiterId: widget.userAccount.idUser,
        //     //   account: widget.userAccount,
        //     // )));
        //   },
        //   backgroundColor: const Color(0xFF3366FF),
        //   icon: const Icon(Icons.add, color: Colors.white),
        //   label: const Text("Tạo công việc", style: TextStyle(color: Colors.white)),
        // ),
      ),
    );
  }

  Widget _buildStatFilterBar() {
    int total = widget.jobpostingList.length;
    int open = widget.jobpostingList.where((job) => job.postStatus == 'open').length;
    int closed = widget.jobpostingList.where((job) => job.postStatus == 'closed').length;
    int waiting = widget.jobpostingList.where((job) => job.postStatus == 'waiting').length;
    int editing = widget.jobpostingList.where((job) => job.postStatus == 'editing').length;
    int featured = widget.jobpostingList.where((job) => job.isFeatured == 1).length;

    List<_StatFilterItem> items = [
      _StatFilterItem(
        label: "Tất cả",
        count: total,
        icon: Icons.list,
        color: const Color(0xFF3366FF),
        filter: "Tất cả",
      ),
      _StatFilterItem(
        label: "Đang tuyển",
        count: open,
        icon: Icons.check_circle_outline,
        color: Colors.green,
        filter: "Đang tuyển",
      ),
      _StatFilterItem(
        label: "Đã đóng",
        count: closed,
        icon: Icons.block,
        color: Colors.red,
        filter: "Đã đóng",
      ),
      _StatFilterItem(
        label: "Chờ duyệt",
        count: waiting,
        icon: Icons.hourglass_empty,
        color: Colors.orange,
        filter: "Chờ duyệt",
      ),
      _StatFilterItem(
        label: "Chỉnh sửa",
        count: editing,
        icon: Icons.edit,
        color: Colors.blueGrey,
        filter: "Chỉnh sửa",
      ),
      _StatFilterItem(
        label: "Tin gấp",
        count: featured,
        icon: Icons.priority_high,
        color: Colors.red,
        filter: "Tin gấp",
      ),
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items.map((item) {
            final isSelected = _currentFilter == item.filter;
            return Container(
              width: 120,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _currentFilter = item.filter;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? item.color.withValues(alpha:0.08) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? item.color : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha:0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item.icon, color: item.color, size: 20),
                      const SizedBox(height: 8),
                      Text(
                        item.count.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: item.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? item.color : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildJobList() {
    return _filteredJobs.isEmpty
        ? _buildEmptyState()
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredJobs.length,
            itemBuilder: (context, index) {
              final job = _filteredJobs[index];
              return _buildJobCard(job);
            },
          );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "Không tìm thấy công việc nào",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Hãy thử bỏ bộ lọc hoặc tạo công việc mới",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(JobPostingModel job) {
    Color statusColor;
    Widget statusIcon;
    String statusText = _mapPostStatusToFilter(job.postStatus ?? '');

    switch (job.postStatus) {
      case 'open':
        statusColor = Colors.green;
        statusIcon = const Icon(
          Icons.check_circle_outline,
          size: 16,
          color: Colors.green,
        );
        break;
      case 'closed':
        statusColor = Colors.red;
        statusIcon = const Icon(Icons.block, size: 16, color: Colors.red);
        break;
      case 'waiting':
        statusColor = Colors.orange;
        statusIcon = const Icon(
          Icons.hourglass_empty,
          size: 16,
          color: Colors.orange,
        );
        break;
      case 'editing':
        statusColor = Colors.blueGrey;
        statusIcon = const Icon(
          Icons.edit,
          size: 16,
          color: Colors.blueGrey,
        );
        break;
      default:
        statusColor = Colors.blue;
        statusIcon = const Icon(
          Icons.info_outline,
          size: 16,
          color: Colors.blue,
        );
    }

    String salaryText = "${(job.salary! / 1000000).toStringAsFixed(0)} triệu";

    // Số ứng viên dựa vào danh sách JobApplication
    int applicantCount = widget.jobApplications
        .where((app) => app.idJobPost == job.idJobPost)
        .map((app) => app.idUser)
        .toSet()
        .length;

    // Random lượt xem từ 100-500 cho mỗi job (dựa vào idJobPost để ổn định)
    int viewCount = 100 + (job.idJobPost.codeUnits.fold(0, (a, b) => a + b) % 401);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 12),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3366FF).withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.work_outline,
                              color: Color(0xFF3366FF),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 24),
                                Text(
                                  job.title ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Column(
                                  children: [
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      const SizedBox(width: 4),
                                      SizedBox(
                                        width: 160,
                                          child: Text(
                                            job.location ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          job.workType ?? '',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                               // Trạng thái - lương
                                Row(
                                  children: [
                                    // Trạng thái
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withValues(alpha:0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          statusIcon,
                                          const SizedBox(width: 4),
                                          Text(
                                            statusText,
                                            style: TextStyle(
                                              color: statusColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Lương
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(alpha:0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.payments_outlined, size: 16, color: Colors.orange),
                                          const SizedBox(width: 4),
                                          Text(
                                            salaryText,
                                            style: const TextStyle(
                                              color: Colors.orange,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
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

                          // Nút more
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert, color: Colors.grey.shade700),
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text('Chỉnh sửa'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'status',
                                child: Row(
                                  children: [
                                    Icon(Icons.swap_horiz, size: 18),
                                    SizedBox(width: 8),
                                    Text('Thay đổi trạng thái'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'duplicate',
                                child: Row(
                                  children: [
                                    Icon(Icons.content_copy, size: 18),
                                    SizedBox(width: 8),
                                    Text('Nhân bản'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Xóa',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Ngày tháng
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              icon: Icons.calendar_today_outlined,
                              label: _formatDate(job.createdAt ?? DateTime.now()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoItem(
                              icon: Icons.event_busy_outlined,
                              label: _formatDate(job.applicationDeadline ?? DateTime.now()),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$applicantCount ứng viên",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.visibility_outlined,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$viewCount lượt xem",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.work, color: Color.fromARGB(255, 44, 44, 44)),
                            tooltip: "Xem chi tiết",
                            onPressed: () {
                              Navigator.push(context, 
                                MaterialPageRoute(builder: (context)=> JobDetailScreen(job: job)));
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
          // Nhãn "Gấp" ở góc trên bên trái
          if (job.isFeatured == 1)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  children: const [
                    Icon(Icons.priority_high, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      "Gấp",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}

class _StatFilterItem {
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final String filter;
  _StatFilterItem({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.filter,
  });
}