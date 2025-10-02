import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CandidateManagementScreen extends StatefulWidget {
  const CandidateManagementScreen({Key? key}) : super(key: key);

  @override
  State<CandidateManagementScreen> createState() =>
      _CandidateManagementScreenState();
}

class _CandidateManagementScreenState extends State<CandidateManagementScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _selectedFilter = 'Tất cả';
  final List<String> _filters = [
    'Tất cả',
    'Mới nộp hồ sơ',
    'Đang phỏng vấn',
    'Đã phỏng vấn',
    'Đã nhận việc',
    'Đã từ chối',
  ];

  final List<Map<String, dynamic>> _candidates = [
    {
      'id': 1,
      'name': 'Nguyễn Văn Anh',
      'position': 'Flutter Developer',
      'experience': '3 năm',
      'skills': ['Flutter', 'Dart', 'Firebase'],
      'status': 'Đang phỏng vấn',
      'avatar': 'assets/images/logohuit.png',
      'date': '12/03/2025',
      'rating': 4.5,
      'email': 'nguyenvananh@example.com',
      'phone': '0912345678',
    },
    {
      'id': 2,
      'name': 'Trần Thị Bình',
      'position': 'UI/UX Designer',
      'experience': '4 năm',
      'skills': ['Figma', 'Adobe XD', 'Sketch'],
      'status': 'Mới nộp hồ sơ',
      'avatar': 'assets/images/logohuit.png',
      'date': '10/03/2025',
      'rating': 4.0,
      'email': 'tranthib@example.com',
      'phone': '0923456789',
    },
    {
      'id': 3,
      'name': 'Phạm Văn Cường',
      'position': 'Backend Developer',
      'experience': '5 năm',
      'skills': ['Node.js', 'MongoDB', 'Express'],
      'status': 'Đã phỏng vấn',
      'avatar': 'assets/images/logohuit.png',
      'date': '08/03/2025',
      'rating': 4.8,
      'email': 'phamvanc@example.com',
      'phone': '0934567890',
    },
    {
      'id': 4,
      'name': 'Lê Thị Dung',
      'position': 'Product Manager',
      'experience': '6 năm',
      'skills': ['Agile', 'Scrum', 'Jira'],
      'status': 'Đã từ chối',
      'avatar': 'assets/images/logohuit.png',
      'date': '05/03/2025',
      'rating': 3.7,
      'email': 'lethid@example.com',
      'phone': '0945678901',
    },
    {
      'id': 5,
      'name': 'Hoàng Văn Giang',
      'position': 'DevOps Engineer',
      'experience': '4 năm',
      'skills': ['Docker', 'Kubernetes', 'AWS'],
      'status': 'Đã nhận việc',
      'avatar': 'assets/images/logohuit.png',
      'date': '01/03/2025',
      'rating': 4.9,
      'email': 'hoangvang@example.com',
      'phone': '0956789012',
    },
  ];

  List<Map<String, dynamic>> get _filteredCandidates {
    if (_selectedFilter == 'Tất cả') {
      return _candidates
          .where(
            (candidate) =>
                candidate['name'].toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                candidate['position'].toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                candidate['skills'].any(
                  (skill) => skill.toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  ),
                ),
          )
          .toList();
    }
    return _candidates
        .where(
          (candidate) =>
              candidate['status'] == _selectedFilter &&
              (candidate['name'].toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  ) ||
                  candidate['position'].toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  ) ||
                  candidate['skills'].any(
                    (skill) => skill.toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    ),
                  )),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Function to get color for status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Mới nộp hồ sơ':
        return Colors.blue;
      case 'Đang phỏng vấn':
        return Colors.orange;
      case 'Đã phỏng vấn':
        return Colors.purple;
      case 'Đã nhận việc':
        return Colors.green;
      case 'Đã từ chối':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Function to show candidate details
  void _showCandidateDetails(Map<String, dynamic> candidate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with close button
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
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(candidate['avatar']),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              candidate['name'],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              candidate['position'],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      candidate['status'],
                                    ).withValues(alpha:0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    candidate['status'],
                                    style: TextStyle(
                                      color: _getStatusColor(
                                        candidate['status'],
                                      ),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${candidate['rating']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
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

                  const SizedBox(height: 30),

                  // Contact information
                  const Text(
                    'Thông tin liên hệ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _contactInfoItem(Icons.email_outlined, candidate['email']),
                  _contactInfoItem(Icons.phone_outlined, candidate['phone']),

                  const SizedBox(height: 30),

                  // Professional information
                  const Text(
                    'Thông tin chuyên môn',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  _infoItem('Vị trí ứng tuyển', candidate['position']),
                  _infoItem('Kinh nghiệm', candidate['experience']),
                  _infoItem('Ngày nộp', candidate['date']),

                  const SizedBox(height: 20),

                  // Skills
                  const Text(
                    'Kỹ năng',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        (candidate['skills'] as List<String>).map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
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

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.check_circle_outline),
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
                          onPressed: () {},
                          icon: const Icon(Icons.cancel_outlined),
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
                ],
              ),
            ),
          ),
    );
  }

  // Helper method for contact info items
  Widget _contactInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 15)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.content_copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
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

  // Helper method for info items
  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
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
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatsCard(
                    icon: Icons.person_add_alt_1,
                    title: 'Tổng ứng viên',
                    value: _candidates.length.toString(),
                    color: Colors.blue,
                  ),
                  _buildStatsCard(
                    icon: Icons.file_present,
                    title: 'Mới nộp hồ sơ',
                    value:
                        _candidates
                            .where((c) => c['status'] == 'Mới nộp hồ sơ')
                            .length
                            .toString(),
                    color: Colors.blue,
                  ),
                  _buildStatsCard(
                    icon: Icons.pending_actions,
                    title: 'Đang phỏng vấn',
                    value:
                        _candidates
                            .where((c) => c['status'] == 'Đang phỏng vấn')
                            .length
                            .toString(),
                    color: Colors.orange,
                  ),
                  _buildStatsCard(
                    icon: Icons.check_circle_outline,
                    title: 'Đã phỏng vấn',
                    value:
                        _candidates
                            .where((c) => c['status'] == 'Đã phỏng vấn')
                            .length
                            .toString(),
                    color: Colors.purple,
                  ),
                  _buildStatsCard(
                    icon: Icons.task_alt,
                    title: 'Đã nhận việc',
                    value:
                        _candidates
                            .where((c) => c['status'] == 'Đã nhận việc')
                            .length
                            .toString(),
                    color: Colors.green,
                  ),
                  _buildStatsCard(
                    icon: Icons.cancel_outlined,
                    title: 'Đã từ chối',
                    value:
                        _candidates
                            .where((c) => c['status'] == 'Đã từ chối')
                            .length
                            .toString(),
                    color: Colors.red,
                  ),
                ],
              ),
            ),
          ),

          // Search and filter bar
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    setState(() {
                      _selectedFilter = value;
                    });
                  },
                  itemBuilder:
                      (context) =>
                          _filters
                              .map(
                                (filter) => PopupMenuItem<String>(
                                  value: filter,
                                  child: Row(
                                    children: [
                                      if (_selectedFilter == filter)
                                        const Icon(
                                          Icons.check,
                                          color: Colors.blue,
                                          size: 16,
                                        )
                                      else
                                        const SizedBox(width: 16),
                                      const SizedBox(width: 8),
                                      Text(filter),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _selectedFilter,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Danh sách ứng viên
          Expanded(
            child:
                _filteredCandidates.isEmpty
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
                        final candidate = _filteredCandidates[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => _showCandidateDetails(candidate),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top row with avatar and basic info
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Avatar
                                      Hero(
                                        tag: 'avatar-${candidate['id']}',
                                        child: CircleAvatar(
                                          radius: 28,
                                          backgroundImage: AssetImage(candidate['avatar']),
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      // Basic info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              candidate['name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              candidate['position'],
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Kinh nghiệm: ${candidate['experience']}',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Rating
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${candidate['rating']}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            candidate['date'],
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Skills
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Wrap(
                                          spacing: 6,
                                          runSpacing: 6,
                                          children:
                                              (candidate['skills']
                                                      as List<String>)
                                                  .map((skill) {
                                                    return Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue[50],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        skill,
                                                        style: TextStyle(
                                                          color:
                                                              Colors.blue[700],
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    );
                                                  })
                                                  .toList(),
                                        ),
                                      ),
                                      // Status pill
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                            candidate['status'],
                                          ).withValues(alpha:0.1),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Text(
                                          candidate['status'],
                                          style: TextStyle(
                                            color: _getStatusColor(
                                              candidate['status'],
                                            ),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // Action buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.email_outlined),
                                        onPressed: () {},
                                        color: Colors.blue,
                                        iconSize: 20,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.phone_outlined),
                                        onPressed: () {},
                                        color: Colors.green,
                                        iconSize: 20,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.calendar_today_outlined,
                                        ),
                                        onPressed: () {},
                                        color: Colors.orange,
                                        iconSize: 20,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.more_horiz),
                                        onPressed: () {},
                                        color: Colors.grey[700],
                                        iconSize: 20,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 36,
                                          minHeight: 36,
                                        ),
                                      ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: theme.primaryColor,
        icon: const Icon(Icons.add),
        label: const Text('Thêm ứng viên'),
      ),
    );
  }

  Widget _buildStatsCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      width: 140,
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha:0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
