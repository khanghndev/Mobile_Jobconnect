import 'package:flutter/material.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/data/models/job_posting_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/model/candidate_info_model.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/features/job/screens/job_detail_screen.dart';

class JobMatchingScreen extends StatefulWidget {
  final String idUser;

  const JobMatchingScreen({super.key, required this.idUser});

  @override
  State<JobMatchingScreen> createState() => _JobMatchingScreenState();
}

class _JobMatchingScreenState extends State<JobMatchingScreen> {
  List<JobMatch> _matchedJobs = [];
  UserModel? _account;
  CandidateInfoModel? _candidateInfo;
  final List<JobPostingModel> _jobs = [];
  final ApiService _apiService = ApiService( );
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadAllData();
    _matchedJobs = await _calculateJobMatches(_jobs);
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await Future.wait([_fetchAccount(), _fetchCandidateInfo(), _fetchJobs()]);
    } catch (e) {
      print("Error loading data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchAccount() async {
    try {
      final data = await _apiService.get(
        endpoint: '${ApiConstants.userEndpoint}/${widget.idUser}',
      );
      if (mounted && data.isNotEmpty) {
        setState(() => _account = UserModel.fromJson(data.first));
      }
    } catch (e) {
      print('Error fetching account: $e');
    }
  }

  Future<void> _fetchCandidateInfo() async {
    try {
      final data = await _apiService.get(
        endpoint: '${ApiConstants.candidateInfoEndpoint}/${widget.idUser}',
      );
      if (mounted && data.isNotEmpty) {
        setState(() => _candidateInfo = CandidateInfoModel.fromJson(data.first));
      }
    } catch (e) {
      print('Error fetching candidate info: $e');
    }
  }

  Future<void> _fetchJobs() async {
    try {
      final response = await _apiService.get(endpoint: ApiConstants.jobPostingEndpoint);
      if (mounted) {
        _jobs.clear();
        _jobs.addAll(response.map((job) => JobPostingModel.fromJson(job)));
      }
    } catch (e) {
      print('Error fetching jobs: $e');
    }
  }

  Future<List<JobMatch>> _calculateJobMatches(List<JobPostingModel> jobs) async {
    List<JobMatch> matches = [];

    for (var job in jobs) {
      double totalScore = 0;
      double skillScore = 0;
      double experienceScore = 0;
      double educationScore = 0;
      double positionScore = 0;

      if (_candidateInfo != null) {
        // 1. Skills (25% weight)
        skillScore = _calculateSkillScore(job);
        totalScore += skillScore;

        // 2. Experience Level (25% weight)
        experienceScore = _calculateExperienceScore(job);
        totalScore += experienceScore;

        // 3. Education Level (25% weight)
        educationScore = _calculateEducationScore(job);
        totalScore += educationScore;

        // 4. Position (25% weight)
        positionScore = _calculatePositionScore(job);
        totalScore += positionScore;
      }

      matches.add(
        JobMatch(
          job: job,
          matchPercentage: totalScore,
          skillScore: skillScore,
          experienceScore: experienceScore,
          educationScore: educationScore,
          positionScore: positionScore,
        ),
      );
    }

    // Sort by match percentage in descending order
    matches.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
    return matches;
  }

  double _calculateSkillScore(JobPostingModel job) {
    if (_candidateInfo == null ||
        _candidateInfo!.skills == null ||
        _candidateInfo!.skills!.isEmpty) {
      return 0;
    }

    List<String> userSkills = _candidateInfo!.skills!.toLowerCase().split(',');
    List<String> requiredSkills = job.requirements.toLowerCase().split(',');

    // Remove empty strings and trim whitespace
    userSkills = userSkills.where((skill) => skill.trim().isNotEmpty).toList();
    requiredSkills =
        requiredSkills.where((skill) => skill.trim().isNotEmpty).toList();

    if (requiredSkills.isEmpty) {
      return 25; // Nếu không có yêu cầu kỹ năng cụ thể, cho điểm tối đa
    }

    int matchingSkills =
        userSkills
            .where(
              (skill) =>
                  requiredSkills.any((req) => req.contains(skill.trim())),
            )
            .length;

    return (matchingSkills / requiredSkills.length) * 25;
  }

  double _calculateExperienceScore(JobPostingModel job) {
    if (_candidateInfo == null || _candidateInfo!.experienceYears == null) {
      return 0;
    }

    int userExp = _candidateInfo!.experienceYears!;
    String jobExpLevel = job.experienceLevel.toLowerCase();
    double expScore = 0;

    // Map experience levels to years
    if (jobExpLevel.contains('intern') || jobExpLevel.contains('thực tập')) {
      if (userExp >= 1) {
        expScore = 25; // Có kinh nghiệm > 1 năm
      } else if (userExp >= 0) {
        expScore = 20; // Có ít kinh nghiệm
      } else {
        expScore = 15; // Không có kinh nghiệm
      }
    } else if (jobExpLevel.contains('fresher') ||
        jobExpLevel.contains('mới tốt nghiệp')) {
      if (userExp >= 2) {
        expScore = 25; // Có kinh nghiệm > 2 năm
      } else if (userExp >= 1) {
        expScore = 20; // Có 1-2 năm kinh nghiệm
      } else {
        expScore = 15; // Ít hơn 1 năm kinh nghiệm
      }
    } else if (jobExpLevel.contains('junior')) {
      if (userExp >= 3) {
        expScore = 25; // Có kinh nghiệm > 3 năm
      } else if (userExp >= 2) {
        expScore = 20; // Có 2-3 năm kinh nghiệm
      } else if (userExp >= 1) {
        expScore = 15; // Có 1-2 năm kinh nghiệm
      } else {
        expScore = 10; // Ít hơn 1 năm kinh nghiệm
      }
    } else if (jobExpLevel.contains('middle') ||
        jobExpLevel.contains('trung cấp')) {
      if (userExp >= 5) {
        expScore = 25; // Có kinh nghiệm > 5 năm
      } else if (userExp >= 3) {
        expScore = 20; // Có 3-5 năm kinh nghiệm
      } else if (userExp >= 2) {
        expScore = 15; // Có 2-3 năm kinh nghiệm
      } else {
        expScore = 10; // Ít hơn 2 năm kinh nghiệm
      }
    } else if (jobExpLevel.contains('senior') ||
        jobExpLevel.contains('cao cấp')) {
      if (userExp >= 7) {
        expScore = 25; // Có kinh nghiệm > 7 năm
      } else if (userExp >= 5) {
        expScore = 20; // Có 5-7 năm kinh nghiệm
      } else if (userExp >= 3) {
        expScore = 15; // Có 3-5 năm kinh nghiệm
      } else {
        expScore = 10; // Ít hơn 3 năm kinh nghiệm
      }
    } else {
      // Default case - nếu không xác định được level
      expScore = userExp >= 1 ? 20 : 15;
    }

    return expScore;
  }

  double _calculateEducationScore(JobPostingModel job) {
    if (_candidateInfo == null || _candidateInfo!.educationLevel == null) {
      return 0;
    }

    String jobRequirements = job.requirements.toLowerCase();

    // Kiểm tra xem trong requirements có đề cập đến yêu cầu học vấn không
    List<String> educationKeywords = [
      'đại học',
      'thạc sĩ',
      'tiến sĩ',
      'cao đẳng',
      'trung cấp',
      'university',
      'master',
      'phd',
      'college',
      'vocational',
    ];

    bool hasEducationRequirement = educationKeywords.any(
      (keyword) => jobRequirements.contains(keyword),
    );

    // Nếu không có yêu cầu học vấn cụ thể, cho điểm tối đa
    if (!hasEducationRequirement) {
      return 25.0;
    }

    // Nếu có yêu cầu học vấn, so sánh với học vấn của ứng viên
    String candidateEducation = _candidateInfo!.educationLevel!.toLowerCase();

    // Map các level học vấn từ thấp đến cao
    Map<String, int> educationLevels = {
      'trung cấp': 1,
      'cao đẳng': 2,
      'đại học': 3,
      'thạc sĩ': 4,
      'tiến sĩ': 5,
    };

    // Tìm level học vấn yêu cầu từ job requirements
    int requiredLevel = 0;
    for (var level in educationLevels.keys) {
      if (jobRequirements.contains(level)) {
        requiredLevel = educationLevels[level]!;
        break;
      }
    }

    // Tìm level học vấn của ứng viên
    int candidateLevel = 0;
    for (var level in educationLevels.keys) {
      if (candidateEducation.contains(level)) {
        candidateLevel = educationLevels[level]!;
        break;
      }
    }

    // Nếu không xác định được level của ứng viên, cho điểm trung bình
    if (candidateLevel == 0) {
      return 15.0;
    }

    // Tính điểm dựa trên sự chênh lệch level
    if (candidateLevel >= requiredLevel) {
      return 25.0; // Đạt yêu cầu
    } else if (candidateLevel == requiredLevel - 1) {
      return 15.0; // Thấp hơn 1 level
    } else {
      return 10.0; // Thấp hơn nhiều level
    }
  }

  double _calculatePositionScore(JobPostingModel job) {
    if (_candidateInfo == null ||
        _candidateInfo!.workPosition == null ||
        _candidateInfo!.workPosition!.isEmpty) {
      return 0;
    }

    String candidatePosition =
        FormatUtils.removeDiacritics(
          _candidateInfo!.workPosition!,
        ).toLowerCase();
    String jobTitle = FormatUtils.removeDiacritics(job.title).toLowerCase();

    // Tách các từ trong vị trí công việc
    List<String> candidateWords =
        candidatePosition
            .split(RegExp(r'[\s,]+'))
            .where((word) => word.length > 2) // Bỏ qua các từ quá ngắn
            .toList();

    List<String> jobWords =
        jobTitle
            .split(RegExp(r'[\s,]+'))
            .where((word) => word.length > 2)
            .toList();

    if (candidateWords.isEmpty || jobWords.isEmpty) {
      return 0;
    }

    // Đếm số từ trùng khớp
    int matchingWords =
        candidateWords
            .where(
              (word) => jobWords.any(
                (jobWord) => jobWord.contains(word) || word.contains(jobWord),
              ),
            )
            .length;

    // Tính phần trăm từ trùng khớp
    double matchPercentage = (matchingWords / candidateWords.length) * 100;

    // Chuyển đổi phần trăm thành điểm (tối đa 25 điểm)
    return (matchPercentage / 100) * 25;
  }

  void _showMatchDetailsDialog(BuildContext context, JobMatch jobMatch) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              jobMatch.job.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              jobMatch.job.company!.companyName,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.analytics, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tổng điểm phù hợp',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${jobMatch.matchPercentage.toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Chi tiết đánh giá',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildScoreItem(
                    'Kỹ năng',
                    jobMatch.skillScore,
                    Icons.code,
                    'Đánh giá dựa trên kỹ năng của bạn so với yêu cầu công việc',
                  ),
                  _buildScoreItem(
                    'Kinh nghiệm',
                    jobMatch.experienceScore,
                    Icons.work,
                    'Đánh giá dựa trên số năm kinh nghiệm của bạn',
                  ),
                  _buildScoreItem(
                    'Học vấn',
                    jobMatch.educationScore,
                    Icons.school,
                    'Đánh giá dựa trên trình độ học vấn của bạn',
                  ),
                  _buildScoreItem(
                    'Vị trí',
                    jobMatch.positionScore,
                    Icons.business_center,
                    'Đánh giá dựa trên vị trí công việc hiện tại của bạn',
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Đóng dialog
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => JobDetailScreen(
                                  idUser: widget.idUser,
                                  jobPosting: jobMatch.job,
                                ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Xem chi tiết công việc'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildScoreItem(
    String title,
    double score,
    IconData icon,
    String description,
  ) {
    // Tính phần trăm dựa trên điểm tối đa của tiêu chí (25 điểm)
    double percentage = (score / 25) * 100;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.grey[700]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getMatchColor(percentage),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getMatchColor(percentage),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Công việc phù hợp',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _onRefresh),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _matchedJobs.length,
                  itemBuilder: (context, index) {
                    final jobMatch = _matchedJobs[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => _showMatchDetailsDialog(context, jobMatch),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          jobMatch.job.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.business,
                                              size: 16,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                jobMatch
                                                    .job
                                                    .company!
                                                    .companyName,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getMatchColor(
                                        jobMatch.matchPercentage,
                                      ).withValues(alpha:0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _getMatchColor(
                                          jobMatch.matchPercentage,
                                        ).withValues(alpha:0.3),
                                      ),
                                    ),
                                    child: Text(
                                      '${jobMatch.matchPercentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        color: _getMatchColor(
                                          jobMatch.matchPercentage,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: jobMatch.matchPercentage / 100,
                                  backgroundColor: Colors.grey[200],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getMatchColor(jobMatch.matchPercentage),
                                  ),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildInfoChip(
                                    Icons.location_on,
                                    FormatUtils.extractDistrictAndCity(
                                      jobMatch.job.location,
                                    ),
                                  ),
                                  _buildInfoChip(
                                    Icons.work,
                                    jobMatch.job.workType,
                                  ),
                                  _buildInfoChip(
                                    Icons.attach_money,
                                    FormatUtils.formatSalary(
                                      jobMatch.job.salary ?? 0,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => JobDetailScreen(
                                                idUser: widget.idUser,
                                                jobPosting:
                                                    jobMatch.job,
                                              ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.arrow_forward),
                                    label: const Text('Xem chi tiết'),
                                    style: TextButton.styleFrom(
                                      foregroundColor:
                                          Theme.of(context).primaryColor,
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
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await _loadAllData();
    // setState(() => _isLoading = false); // Đã có trong _loadAllData
  }

  Color _getMatchColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}

class JobMatch {
  final JobPostingModel job;
  final double matchPercentage;
  final double skillScore;
  final double experienceScore;
  final double educationScore;
  final double positionScore;

  JobMatch({
    required this.job,
    required this.matchPercentage,
    required this.skillScore,
    required this.experienceScore,
    required this.educationScore,
    required this.positionScore,
  });
}
