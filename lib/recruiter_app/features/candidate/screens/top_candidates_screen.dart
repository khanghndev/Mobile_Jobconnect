// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/profile/model/candidate_info_model.dart';

class TopCandidatesScreen extends StatefulWidget {
  List<JobPostingModel> jobPostingList;
  List<JobApplicationModel> jobApplicationList;
  List<CandidateInfoModel> candidateInfoList;
  TopCandidatesScreen({
    super.key,
    required this.jobPostingList,
    required this.jobApplicationList,
    required this.candidateInfoList,
  });

  @override
  State<TopCandidatesScreen> createState() => _TopCandidatesScreenState();
}

class _TopCandidatesScreenState extends State<TopCandidatesScreen> {
  // Danh sách các công việc đang tuyển dụng
  final List<Map<String, dynamic>> _jobs = [
    {
      'id': '1',
      'title': 'Senior Flutter Developer',
      'company': 'Tech Solutions Inc.',
      'location': 'Hồ Chí Minh',
      'experience': '3-5 năm',
      'salary': '15-25 triệu',
      'icon': Icons.code,
      'color': Colors.blue,
      'candidates': 25,
    },
    {
      'id': '2',
      'title': 'UI/UX Designer',
      'company': 'Tech Solutions Inc.',
      'location': 'Hà Nội',
      'experience': '2-4 năm',
      'salary': '12-20 triệu',
      'icon': Icons.design_services,
      'color': Colors.orange,
      'candidates': 18,
    },
    {
      'id': '3',
      'title': 'Product Manager',
      'company': 'Tech Solutions Inc.',
      'location': 'Hồ Chí Minh',
      'experience': '5-7 năm',
      'salary': '30-40 triệu',
      'icon': Icons.people,
      'color': Colors.green,
      'candidates': 10,
    },
    {
      'id': '4',
      'title': 'Backend Developer',
      'company': 'Tech Solutions Inc.',
      'location': 'Đà Nẵng',
      'experience': '2-4 năm',
      'salary': '15-22 triệu',
      'icon': Icons.storage,
      'color': Colors.purple,
      'candidates': 15,
    },
  ];

  // Job hiện tại được chọn để xem ứng viên
  late Map<String, dynamic> _selectedJob;

  // Sort option
  String _selectedSortOption = 'Độ phù hợp';
  final List<String> _sortOptions = ['Độ phù hợp', 'Kinh nghiệm', 'Mới nhất'];

  @override
  void initState() {
    super.initState();
    _selectedJob = _jobs[0]; // Mặc định chọn job đầu tiên
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Ứng viên nổi bật',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.black87,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black87),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.black87),
            onPressed: () {
              _showFilterBottomSheet(context);
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJobSelector(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildJobDetailCard(),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ứng viên phù hợp (${_selectedJob['candidates']})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        _buildSortDropdown(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildCandidateList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobSelector() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Chọn vị trí tuyển dụng',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _jobs.length,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final job = _jobs[index];
                final isSelected = job['id'] == _selectedJob['id'];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedJob = job;
                    });
                  },
                  child: Container(
                    width: 110,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? job['color'].withValues(alpha:0.1)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? job['color']
                                : Colors.grey.withValues(alpha:0.3),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: job['color'].withValues(alpha:0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                job['icon'],
                                size: 16,
                                color: job['color'],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${job['candidates']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            job['title'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

  
  Widget _buildSortDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha:0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedSortOption,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          borderRadius: BorderRadius.circular(8),
          items:
              _sortOptions.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedSortOption = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildJobDetailCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _selectedJob['color'].withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _selectedJob['icon'],
                  size: 30,
                  color: _selectedJob['color'],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedJob['title'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedJob['company'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.blueGrey),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _JobAttributeChip(
                icon: Icons.location_on_outlined,
                label: _selectedJob['location'],
              ),
              const SizedBox(width: 8),
              _JobAttributeChip(
                icon: Icons.work_outline,
                label: _selectedJob['experience'],
              ),
              const SizedBox(width: 8),
              _JobAttributeChip(
                icon: Icons.attach_money,
                label: _selectedJob['salary'],
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatusIndicator(
                value: 15,
                label: 'Đã liên hệ',
                color: Colors.blue,
              ),
              _StatusIndicator(
                value: 8,
                label: 'Phỏng vấn',
                color: Colors.orange,
              ),
              _StatusIndicator(
                value: 2,
                label: 'Nhận việc',
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCandidateList() {
    // Giả lập dữ liệu ứng viên phù hợp với vị trí được chọn
    final String jobId = _selectedJob['id'];

    // Tạo danh sách ứng viên dựa trên công việc được chọn
    final candidates = _getCandidatesForJob(jobId);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: candidates.length,
      itemBuilder: (context, index) {
        final candidate = candidates[index];
        return _CandidateCard(
          candidate: candidate,
          jobColor: _selectedJob['color'],
        );
      },
    );
  }

  // Phương thức này sẽ trả về danh sách ứng viên phù hợp với công việc được chọn
  List<Map<String, dynamic>> _getCandidatesForJob(String jobId) {
    // Mỗi công việc sẽ có danh sách ứng viên khác nhau
    switch (jobId) {
      case '1': // Flutter Developer
        return [
          {
            'name': 'Nguyễn Văn A',
            'position': 'Senior Flutter Developer',
            'experience': '5 năm',
            'skills': ['Flutter', 'Dart', 'Firebase'],
            'match': 95,
            'avatar': 'https://i.pravatar.cc/150?img=1',
            'status': 'Đã liên hệ',
          },
          {
            'name': 'Trần Thị B',
            'position': 'Mobile Developer',
            'experience': '4 năm',
            'skills': ['Flutter', 'React Native', 'UI/UX'],
            'match': 92,
            'avatar': 'https://i.pravatar.cc/150?img=2',
            'status': 'Mới',
          },
          {
            'name': 'Lê Văn C',
            'position': 'Flutter Developer',
            'experience': '3 năm',
            'skills': ['Flutter', 'Dart', 'REST API'],
            'match': 88,
            'avatar': 'https://i.pravatar.cc/150?img=3',
            'status': 'Phỏng vấn',
          },
          {
            'name': 'Phạm Thị D',
            'position': 'Mobile Developer',
            'experience': '4 năm',
            'skills': ['Flutter', 'Android', 'iOS'],
            'match': 85,
            'avatar': 'https://i.pravatar.cc/150?img=4',
            'status': 'Mới',
          },
          {
            'name': 'Hoàng Văn E',
            'position': 'Flutter Developer',
            'experience': '3 năm',
            'skills': ['Flutter', 'Dart', 'Git'],
            'match': 82,
            'avatar': 'https://i.pravatar.cc/150?img=5',
            'status': 'Mới',
          },
        ];

      case '2': // UI/UX Designer
        return [
          {
            'name': 'Lý Thị F',
            'position': 'Senior UI/UX Designer',
            'experience': '6 năm',
            'skills': ['Figma', 'Adobe XD', 'Sketch'],
            'match': 97,
            'avatar': 'https://i.pravatar.cc/150?img=6',
            'status': 'Phỏng vấn',
          },
          {
            'name': 'Đặng Văn G',
            'position': 'Product Designer',
            'experience': '4 năm',
            'skills': ['UI/UX', 'Wireframing', 'User Research'],
            'match': 94,
            'avatar': 'https://i.pravatar.cc/150?img=7',
            'status': 'Mới',
          },
          {
            'name': 'Vũ Thị H',
            'position': 'UI Designer',
            'experience': '3 năm',
            'skills': ['Figma', 'Photoshop', 'Illustration'],
            'match': 90,
            'avatar': 'https://i.pravatar.cc/150?img=8',
            'status': 'Đã liên hệ',
          },
        ];

      case '3': // Product Manager
        return [
          {
            'name': 'Đinh Văn I',
            'position': 'Senior Product Manager',
            'experience': '7 năm',
            'skills': ['Product Strategy', 'Agile', 'User Stories'],
            'match': 96,
            'avatar': 'https://i.pravatar.cc/150?img=9',
            'status': 'Phỏng vấn',
          },
          {
            'name': 'Phan Thị K',
            'position': 'Product Owner',
            'experience': '5 năm',
            'skills': ['Scrum', 'Roadmapping', 'Analytics'],
            'match': 93,
            'avatar': 'https://i.pravatar.cc/150?img=10',
            'status': 'Nhận việc',
          },
        ];

      case '4': // Backend Developer
        return [
          {
            'name': 'Cao Văn L',
            'position': 'Senior Backend Developer',
            'experience': '5 năm',
            'skills': ['Node.js', 'Python', 'MongoDB'],
            'match': 98,
            'avatar': 'https://i.pravatar.cc/150?img=11',
            'status': 'Đã liên hệ',
          },
          {
            'name': 'Đỗ Thị M',
            'position': 'Backend Engineer',
            'experience': '4 năm',
            'skills': ['Java', 'Spring Boot', 'SQL'],
            'match': 91,
            'avatar': 'https://i.pravatar.cc/150?img=12',
            'status': 'Mới',
          },
          {
            'name': 'Ngô Văn N',
            'position': 'DevOps Engineer',
            'experience': '3 năm',
            'skills': ['Docker', 'AWS', 'CI/CD'],
            'match': 87,
            'avatar': 'https://i.pravatar.cc/150?img=13',
            'status': 'Phỏng vấn',
          },
        ];

      default:
        return [];
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return SingleChildScrollView(
              controller: controller,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lọc ứng viên',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.close),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildFilterSection('Kỹ năng'),
                    _buildFilterSection('Kinh nghiệm'),
                    _buildFilterSection('Mức lương mong muốn'),
                    _buildFilterSection('Vị trí'),
                    _buildFilterSection('Trạng thái'),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.grey[400]!),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'Đặt lại',
                              style: TextStyle(color: Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              context.pop();
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Áp dụng'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        // Placeholder for filter options
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _FilterChip(label: '${title.toLowerCase()} 1'),
            _FilterChip(label: '${title.toLowerCase()} 2'),
            _FilterChip(label: '${title.toLowerCase()} 3'),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;

  const _FilterChip({required this.label});

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _isSelected = false;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(widget.label),
      selected: _isSelected,
      onSelected: (bool selected) {
        setState(() {
          _isSelected = selected;
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.blue.withValues(alpha:0.2),
      checkmarkColor: Colors.blue,
      side: BorderSide(color: _isSelected ? Colors.blue : Colors.grey[300]!),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  final Map<String, dynamic> candidate;
  final Color jobColor;

  const _CandidateCard({
    Key? key,
    required this.candidate,
    required this.jobColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 70,
                          height: 70,
                          color: Colors.grey[200],
                          child: Image.asset(
                            'assets/images/logohuit.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      if (candidate['status'] != null &&
                          candidate['status'] != 'Mới')
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(candidate['status']),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              candidate['status'],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidate['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          candidate['position'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kinh nghiệm: ${candidate['experience']}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: jobColor.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${candidate['match']}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: jobColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _ActionButton(
                    icon: Icons.bookmark_outline,
                    label: 'Lưu',
                    color: Colors.blueGrey,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.visibility_outlined,
                    label: 'Xem hồ sơ',
                    color: Colors.blueGrey,
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.person_add_outlined,
                    label: 'Liên hệ',
                    color: Colors.white,
                    backgroundColor: jobColor,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đã liên hệ':
        return Colors.blue;
      case 'Phỏng vấn':
        return Colors.orange;
      case 'Nhận việc':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? backgroundColor;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side:
              backgroundColor == null
                  ? BorderSide(color: Colors.grey[300]!)
                  : BorderSide.none,
        ),
      ),
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _JobAttributeChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _JobAttributeChip({Key? key, required this.icon, required this.label})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.blueGrey),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _StatusIndicator({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha:0.1),
          ),
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
      ],
    );
  }
}
