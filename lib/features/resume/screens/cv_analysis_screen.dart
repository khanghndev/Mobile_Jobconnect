import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class CvAnalysisScreen extends StatefulWidget {
  const CvAnalysisScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CvAnalysisScreenState createState() => _CvAnalysisScreenState();
}

class _CvAnalysisScreenState extends State<CvAnalysisScreen> {
  List<JobRecommendation> _recommendations = [];
  bool _isAnalyzed = false;
  bool _isProcessing =
      false; // Đổi tên để rõ ràng hơn: đang tải lên HOẶC đang phân tích
  File? _selectedFile;

  // Mock data for previously imported CVs
  final List<PreviousCV> _previousCVs = [
    PreviousCV(
      fileName: 'CV_NguyenVanA.pdf',
      userName: 'Nguyễn Văn A',
      uploadDate: '20250310',
      fileType: 'pdf',
    ),
    PreviousCV(
      fileName: 'CV_TranThiB.docx',
      userName: 'Trần Thị B',
      uploadDate: '20250325',
      fileType: 'docx',
    ),
    PreviousCV(
      fileName: 'CV_LeVanC.doc',
      userName: 'Lê Văn C',
      uploadDate: '20250401',
      fileType: 'doc',
    ),
  ];

  Future<void> _pickFile() async {
    setState(() {
      _isProcessing = true; // Bắt đầu quá trình tải lên
      _isAnalyzed = false; // Đảm bảo ẩn kết quả cũ
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          // Sau khi tải lên thành công, chuyển sang phân tích
          _analyzeCV(); // Sẽ tự động set _isProcessing = true lại bên trong
        });
      } else {
        // User cancelled the picker
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra khi tải file: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _analyzeCV() {
    setState(() {
      _isProcessing = true; // Hiển thị loading spinner cho quá trình phân tích
    });

    // Giả lập thời gian phân tích
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Kiểm tra mounted trước khi gọi setState
        setState(() {
          _isAnalyzed = true;
          _isProcessing = false;
          _recommendations = [
            JobRecommendation(
              title: 'Frontend Developer',
              company: 'Tech Solutions Inc.',
              matchPercentage: 92,
              description:
                  'Phát triển giao diện người dùng ứng dụng di động và web với React và Flutter.',
              requirements: ['React', 'Flutter', 'JavaScript', 'UI/UX'],
            ),
            JobRecommendation(
              title: 'Mobile Developer (Native)',
              company: 'Digital Innovation Hub',
              matchPercentage: 87,
              description:
                  'Thiết kế và phát triển ứng dụng di động đa nền tảng (iOS/Android).',
              requirements: [
                'Flutter',
                'Dart',
                'Firebase',
                'REST API',
                'Swift/Kotlin',
              ],
            ),
            JobRecommendation(
              title: 'Full Stack Engineer',
              company: 'Global Software Solutions',
              matchPercentage: 75,
              description:
                  'Xây dựng và duy trì hệ thống ứng dụng web end-to-end.',
              requirements: [
                'JavaScript',
                'Node.js',
                'React',
                'MongoDB',
                'AWS',
              ],
            ),
          ];
        });
      }
    });
  }

  void _selectPreviousCV(PreviousCV cv) {
    setState(() {
      // Giả lập file từ PreviousCV, trong thực tế bạn sẽ cần đường dẫn file thật
      _selectedFile = File('path/to/${cv.fileName}');
      _analyzeCV(); // Tự động phân tích CV đã có
    });
  }

  // Hàm helper để lấy Icon và Color dựa trên loại file
  Map<String, dynamic> _getFileIconAndColor(String? filePath) {
    String fileName = filePath?.split('/').last ?? 'unknown';
    if (fileName.toLowerCase().endsWith('.pdf')) {
      return {'icon': Icons.picture_as_pdf, 'color': Colors.red.shade700};
    } else if (fileName.toLowerCase().endsWith('.doc') ||
        fileName.toLowerCase().endsWith('.docx')) {
      return {'icon': Icons.description, 'color': Colors.blue.shade700};
    } else {
      return {'icon': Icons.insert_drive_file, 'color': Colors.grey.shade700};
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Lấy theme từ context

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phân tích CV'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0, // Bỏ shadow cho AppBar
      ),
      body:
          _isProcessing
              ? _buildLoadingView(theme) // Truyền theme vào
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isAnalyzed) ...[
                      _buildInitialOptions(theme),
                    ], // Truyền theme vào
                    if (_isAnalyzed) ...[
                      _buildAnalysisResults(theme),
                    ], // Truyền theme vào
                  ],
                ),
              ),
    );
  }

  Widget _buildLoadingView(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isAnalyzed ? 'Đang phân tích CV của bạn...' : 'Đang tải lên CV...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Quá trình này có thể mất vài giây.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialOptions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn CV để phân tích',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 24),

        // Option 1: Import new CV
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: _pickFile,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary, // Dùng primary color
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.upload_file,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tải lên CV mới',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tải lên file CV của bạn (PDF, DOC, DOCX)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.hintColor, // Dùng hint color
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Option 2: Previous CVs
        if (_previousCVs.isNotEmpty) ...[
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              theme
                                  .colorScheme
                                  .secondary, // Dùng secondary color
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'CV đã tải lên trước đó',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Dùng Column.builder để tránh toList trong spread
                  ListView.separated(
                    shrinkWrap:
                        true, // Quan trọng để ListView trong SingleChildScrollView
                    physics:
                        const NeverScrollableScrollPhysics(), // Vô hiệu hóa cuộn riêng
                    itemCount: _previousCVs.length,
                    separatorBuilder:
                        (context, index) =>
                            Divider(color: theme.dividerColor, height: 1),
                    itemBuilder: (context, index) {
                      return _buildPreviousCVItem(_previousCVs[index], theme);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPreviousCVItem(PreviousCV cv, ThemeData theme) {
    String formattedDate =
        '${cv.uploadDate.substring(6, 8)}/${cv.uploadDate.substring(4, 6)}/${cv.uploadDate.substring(0, 4)}';

    final fileInfo = _getFileIconAndColor(
      'dummy.${cv.fileType}',
    ); // Dùng fileType để lấy icon/color
    final IconData fileIcon = fileInfo['icon'];
    final Color fileIconColor = fileInfo['color'];

    return InkWell(
      onTap: () => _selectPreviousCV(cv),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(fileIcon, color: fileIconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cv.userName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Tải lên: $formattedDate',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.iconTheme.color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResults(ThemeData theme) {
    String fileName = _selectedFile?.path.split('/').last ?? 'Unknown File';
    final fileInfo = _getFileIconAndColor(_selectedFile?.path);
    final IconData fileIcon = fileInfo['icon'];
    final Color fileIconColor = fileInfo['color'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // File info
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(fileIcon, color: fileIconColor, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Đã phân tích xong',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              Colors
                                  .green
                                  .shade600, // Có thể giữ màu xanh lá cho trạng thái hoàn thành
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
                  onPressed: () {
                    setState(() {
                      _isAnalyzed = false;
                      _selectedFile = null; // Reset file selection
                    });
                  },
                  tooltip: 'Chọn CV khác',
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'Kết quả phân tích',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // CV Analysis Summary
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tóm tắt phân tích',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                _buildAnalysisItem('Điểm mạnh', [
                  'Kỹ năng lập trình di động',
                  'Kinh nghiệm với Flutter & React',
                  'Khả năng làm việc nhóm',
                ], theme),
                _buildAnalysisItem('Cần cải thiện', [
                  'Kinh nghiệm với backend và cơ sở dữ liệu',
                  'Kỹ năng quản lý dự án lớn',
                  'Kỹ năng lãnh đạo',
                ], theme),
                const SizedBox(height: 12),
                Text(
                  'Đánh giá tổng quan: CV của bạn rất mạnh về phát triển giao diện và ứng dụng di động. Để mở rộng cơ hội, bạn có thể cân nhắc phát triển thêm kỹ năng backend và quản lý dự án.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Job Recommendations
        Text(
          'Công việc phù hợp',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),

        // Dùng ListView.builder cho các recommendations
        ListView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(), // Vô hiệu hóa cuộn riêng
          itemCount: _recommendations.length,
          itemBuilder: (context, index) {
            return _buildJobRecommendationCard(_recommendations[index], theme);
          },
        ),
      ],
    );
  }

  Widget _buildAnalysisItem(String title, List<String> items, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ...items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 6,
                        color: theme.hintColor,
                      ), // Bullet point đẹp hơn
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildJobRecommendationCard(JobRecommendation job, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary, // Title color
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _getMatchColor(job.matchPercentage),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${job.matchPercentage}%',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              job.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Kỹ năng yêu cầu:',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  job.requirements
                      .map(
                        (req) => Chip(
                          label: Text(req),
                          backgroundColor: theme.colorScheme.primary
                              .withValues(alpha:0.1), // Chip background
                          labelStyle: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary, // Chip text color
                            fontWeight: FontWeight.w500,
                          ),
                          side: BorderSide(
                            color: theme.colorScheme.primary.withValues(alpha:0.3),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )
                      .toList(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Hiển thị chi tiết công việc
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: const Text('Xem chi tiết'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Ứng tuyển công việc
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        theme.colorScheme.primary, // Primary button color
                    foregroundColor:
                        theme.colorScheme.onPrimary, // Text color on primary
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('Ứng tuyển'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Thay đổi màu dựa trên dải phần trăm, sử dụng màu của theme
  Color _getMatchColor(int percentage) {
    final theme = Theme.of(context);
    if (percentage >= 90)
      return Colors.green.shade600; // Hoặc theme.colorScheme.success nếu có
    if (percentage >= 75) return theme.colorScheme.primary;
    if (percentage >= 60)
      return Colors.orange.shade700; // Hoặc theme.colorScheme.warning
    return theme.colorScheme.error;
  }
}

class JobRecommendation {
  final String title;
  final String company;
  final int matchPercentage;
  final String description;
  final List<String> requirements;

  JobRecommendation({
    required this.title,
    required this.company,
    required this.matchPercentage,
    required this.description,
    required this.requirements,
  });
}

class PreviousCV {
  final String fileName;
  final String userName;
  final String uploadDate;
  final String fileType; // Dùng fileType thay vì IconData và Color

  PreviousCV({
    required this.fileName,
    required this.userName,
    required this.uploadDate,
    required this.fileType,
  });
}
