import 'package:flutter/material.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/data/models/job_posting_model.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/features/job/screens/apply_job_screen.dart';
import 'package:job_connect/features/job/screens/job_detail_screen.dart'; // Thêm để định dạng tiền tệ và ngày tháng

class JobSuggestionsPage extends StatefulWidget {
  // Thêm key vào constructor nếu cần
  const JobSuggestionsPage({super.key, required this.idUser});
  final String idUser; // Giữ idUser nếu bạn muốn dùng nó để fetch data cá nhân

  @override
  State<JobSuggestionsPage> createState() => _JobSuggestionsPageState();
}

class _JobSuggestionsPageState extends State<JobSuggestionsPage> {
  final _apiService = ApiService( );

  List<JobPosting> _allJobs = []; // Lưu trữ tất cả công việc đã fetch
  List<JobPosting> _suggestedJobs =
      []; // Danh sách hiển thị sau khi lọc và xử lý gợi ý
  bool _isLoading = true; // Trạng thái tải dữ liệu
  String _selectedFilter = 'Tất cả';
  final List<String> _filterOptions = [
    'Tất cả',
    'Hà Nội',
    'TP. Hồ Chí Minh',
    'Đà Nẵng',
    // Bạn có thể thêm các địa điểm khác từ dữ liệu thực tế
  ];

  @override
  void initState() {
    super.initState();
    _fetchJobSuggestions(); // Gọi hàm fetch dữ liệu
  }

  Future<void> _onRefresh() async {
    // Hàm này sẽ được gọi khi người dùng kéo để làm mới
    await _fetchJobSuggestions(); // Gọi lại hàm fetch dữ liệu
  }

  // Hàm fetch dữ liệu từ API
  Future<void> _fetchJobSuggestions() async {
    if (!mounted) return; // Kiểm tra mounted trước khi setState

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.get(endpoint: ApiConstants.jobPostingEndpoint);

      if (!mounted) return; // Kiểm tra mounted sau khi await

      // Chuyển đổi dữ liệu JSON thành danh sách JobPosting
      _allJobs.addAll(response.map((job) => JobPosting.fromJson(job)).toList());

      // Giả lập logic gợi ý (ví dụ: chỉ lấy 5 công việc đầu tiên)
      // Trong thực tế, bạn sẽ có một thuật toán gợi ý phức tạp hơn dựa trên CV
      _suggestedJobs = List.from(_allJobs); // Bắt đầu với tất cả các công việc
      // Sắp xếp theo ngày tạo mới nhất (hoặc theo một tiêu chí "gợi ý" nào đó)
      _suggestedJobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _isLoading = false;
        // Áp dụng bộ lọc ban đầu (Tất cả)
        _applyFilter();
      });

      print('Job suggestions fetched and processed successfully.');
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('Error fetching job suggestions: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải gợi ý công việc: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  // Hàm áp dụng bộ lọc vào danh sách _suggestedJobs
  void _applyFilter() {
    if (_selectedFilter == 'Tất cả') {
      _suggestedJobs = List.from(_allJobs);
    } else {
      _suggestedJobs =
          _allJobs.where((job) => job.location == _selectedFilter).toList();
    }
  }

  // Hàm định dạng tiền tệ
  String _formatSalary(double? salary) {
    if (salary == null) return 'Thỏa thuận';
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'đ',
      decimalDigits: 0,
    );
    return formatter.format(salary);
  }

  // Hàm định dạng ngày tháng
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Hàm lấy màu sắc cho phần trăm phù hợp (nếu có)
  Color _getMatchColor(double percentage) {
    if (percentage >= 90) return Colors.green.shade600;
    if (percentage >= 75) return Theme.of(context).colorScheme.primary;
    if (percentage >= 60) return Colors.orange.shade700;
    return Theme.of(context).colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Lấy theme từ context
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Gợi ý công việc",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.appBarTheme.foregroundColor,
          ),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              color: theme.appBarTheme.foregroundColor,
            ),
            onPressed: () {
              _showFilterOptions(context, theme); // Truyền theme
            },
          ),
          IconButton(
            icon: Icon(Icons.search, color: theme.appBarTheme.foregroundColor),
            onPressed: () {
              // TODO: Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Chức năng tìm kiếm chưa được triển khai.'),
                ),
              );
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              )
              : Column(
                children: [
                  _buildMatchInfoBar(theme), // Truyền theme
                  Expanded(
                    child:
                        _suggestedJobs
                                .isEmpty // Sử dụng _suggestedJobs sau khi lọc
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.sentiment_dissatisfied,
                                    size: 80,
                                    color: theme.hintColor.withValues(alpha:0.5),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Không có công việc phù hợp',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Hãy thử thay đổi bộ lọc hoặc cập nhật CV của bạn.',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.hintColor,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              itemCount: _suggestedJobs.length,
                              padding: const EdgeInsets.all(16), // Tăng padding
                              itemBuilder: (context, index) {
                                final job = _suggestedJobs[index];
                                return _buildJobCard(
                                  job,
                                  theme,
                                  isDarkMode,
                                ); // Truyền theme và isDarkMode
                              },
                            ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to CV editing page or similar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Chỉnh sửa CV để cải thiện kết quả gợi ý (chưa triển khai).',
              ),
              backgroundColor: theme.colorScheme.secondary,
            ),
          );
        },
        backgroundColor: theme.colorScheme.secondary, // Màu nút FAB từ theme
        foregroundColor: theme.colorScheme.onSecondary, // Màu icon từ theme
        child: const Icon(Icons.edit_note_rounded), // Icon đẹp hơn
        tooltip: 'Chỉnh sửa CV',
      ),
    );
  }

  Widget _buildMatchInfoBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      // Background color from theme
      color: theme.colorScheme.primary.withValues(alpha:0.08), // Màu primary nhẹ
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Đã tìm thấy ${_suggestedJobs.length} công việc phù hợp", // Đếm _suggestedJobs
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Dựa trên kỹ năng và kinh nghiệm trong CV của bạn",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Navigate to CV analytics
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Xem phân tích CV (chưa triển khai).'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              textStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Xem phân tích'),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(JobPosting job, ThemeData theme, bool isDarkMode) {
    final double matchPercentage =
        job.idJobPost.hashCode % 100 * 1.0; // Random percentage

    return Card(
      margin: const EdgeInsets.only(
        bottom: 20,
      ), // Tăng khoảng cách giữa các card
      elevation: 6, // Tăng elevation để card nổi bật hơn
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ), // Bo tròn hơn
      color: theme.cardColor,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to job detail screen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Xem chi tiết công việc: ${job.title} (chưa triển khai).',
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20), // Tăng padding bên trong card
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Logo/Placeholder
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color:
                          theme.colorScheme.surfaceVariant, // Màu nền cho logo
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha:0.5),
                      ),
                    ),
                    alignment: Alignment.center,
                    child:
                        job.company.logoCompany != null &&
                                job.company.logoCompany!.isNotEmpty
                            ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                job.company.logoCompany!,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) => Icon(
                                      Icons
                                          .business_center_rounded, // Icon placeholder đẹp hơn
                                      color: theme.colorScheme.primary,
                                      size: 30,
                                    ),
                              ),
                            )
                            : Icon(
                              Icons
                                  .business_center_rounded, // Icon placeholder đẹp hơn
                              color: theme.colorScheme.primary,
                              size: 30,
                            ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          job.company.companyName,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.location,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor.withValues(alpha:0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Match Percentage Badge
                  // Chỉ hiển thị nếu có matchPercentage
                  _buildMatchPercentageBadge(matchPercentage, theme),
                ],
              ),
              const SizedBox(height: 20),

              // Salary & Posted Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on_outlined,
                        size: 20,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatSalary(job.salary),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 20, color: theme.hintColor),
                      const SizedBox(width: 6),
                      Text(
                        'Đăng: ${_formatDate(job.createdAt)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Skills/Requirements
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha:
                          0.1,
                        ), // Màu primary nhẹ
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha:0.3),
                        ),
                      ),
                      child: Text(
                        job.requirements,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => JobDetailScreen(
                                idUser: widget.idUser,
                                idJobPost: job.idJobPost,
                              ),
                        ),
                      ).then((_) {
                        // Callback sau khi xem chi tiết công ty
                        _onRefresh();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Bo tròn hơn
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      textStyle: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      foregroundColor: theme.colorScheme.primary,
                    ),
                    child: const Text('Xem chi tiết'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ApplyJobScreen(
                                jobId: job.idJobPost, // Truyền idJobPost
                                jobTitle: job.title,
                                companyName: job.company.companyName,
                                idUser: widget.idUser,
                              ),
                        ),
                      ).then((_) {
                        // Callback sau khi xem chi tiết công ty
                        _onRefresh();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // Bo tròn hơn
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      textStyle: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      elevation: 4, // Thêm elevation cho nút
                    ),
                    child: const Text('Ứng tuyển'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchPercentageBadge(double percentage, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _getMatchColor(percentage).withValues(alpha:0.2), // Màu badge nhẹ
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getMatchColor(percentage).withValues(alpha:0.5)),
      ),
      child: Text(
        '${percentage.toStringAsFixed(0)}% phù hợp',
        style: theme.textTheme.labelMedium?.copyWith(
          color: _getMatchColor(percentage),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showFilterOptions(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.cardColor, // Màu nền modal từ theme
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ), // Bo tròn nhiều hơn
      ),
      builder: (context) {
        return StatefulBuilder(
          // Dùng StatefulBuilder để setState chỉ trong bottom sheet
          builder: (BuildContext context, StateSetter modalSetState) {
            return Container(
              padding: const EdgeInsets.symmetric(
                vertical: 24,
                horizontal: 20,
              ), // Tăng padding
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lọc theo địa điểm',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 12, // Khoảng cách giữa các chip
                    runSpacing: 12, // Khoảng cách giữa các hàng chip
                    children:
                        _filterOptions.map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return ChoiceChip(
                            // Sử dụng ChoiceChip để có UI đẹp hơn
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                modalSetState(() {
                                  // Chỉ setState cho modal
                                  _selectedFilter = filter;
                                });
                                // Áp dụng filter ngay lập tức và đóng modal
                                setState(() {
                                  // setState cho trang chính
                                  _applyFilter();
                                });
                                Navigator.pop(context, true);
                              }
                            },
                            selectedColor: theme.colorScheme.primary
                                .withValues(alpha:0.15), // Màu nền khi chọn
                            backgroundColor:
                                theme
                                    .colorScheme
                                    .surface, // Màu nền khi không chọn
                            labelStyle: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurface,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color:
                                    isSelected
                                        ? theme.colorScheme.primary
                                        : theme.dividerColor,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: theme.dividerColor),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSurface,
                          textStyle: theme.textTheme.labelLarge,
                        ),
                        child: const Text('Đóng'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
