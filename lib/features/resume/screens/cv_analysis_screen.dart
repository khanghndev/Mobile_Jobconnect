import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/features/resume/view_model/resum_view_model.dart';
import 'package:job_connect/features/resume/model/resume_model.dart';
import 'package:job_connect/features/resume/service/cv_analysis_service.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/job/screens/job_detail_screen.dart';
import 'package:provider/provider.dart';

class CvAnalysisScreen extends StatefulWidget {
  final String idUser;
  const CvAnalysisScreen({super.key, required this.idUser});

  @override
  State<CvAnalysisScreen> createState() => _CvAnalysisScreenState();
}

class _CvAnalysisScreenState extends State<CvAnalysisScreen> {
  List<JobRecommendation> _recommendations = [];
  bool _isAnalyzed = false;
  bool _isProcessing = false;
  File? _selectedFile;
  ResumeModel? _selectedResume;
  bool _isMounted = true;
  String? _analysisError;
  double _analysisProgress = 0.0;

  // Kết quả phân tích từ API
  CVAnalysisResult? _analysisResult;

  late ResumeViewModel _resumeVm;
  final CVAnalysisService _cvAnalysisService = CVAnalysisService();

  @override
  void initState() {
    super.initState();
    _resumeVm = context.read<ResumeViewModel>();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isMounted && mounted) {
        _loadResumes();
      }
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _loadResumes() async {
    if (!_isMounted || !mounted) return;
    
    try {
      await _resumeVm.getResumesByUser(idUser: widget.idUser);
    } catch (e) {
      if (_isMounted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  Future<void> _pickFile() async {
    if (!_isMounted || !mounted) return;
    
    setState(() {
      _isProcessing = true;
      _isAnalyzed = false;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (!_isMounted || !mounted) return;

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _selectedResume = null;
        });
        
        await _analyzeCV();
      } else {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (_isMounted && mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra khi tải file: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _analyzeCV() async {
    if (!_isMounted || !mounted) return;

    setState(() {
      _isProcessing = true;
      _analysisError = null;
      _analysisProgress = 0.0;
      _isAnalyzed = false;
      _analysisResult = null;
    });

    try {
      CVAnalysisResult? result;

      if (_selectedFile != null) {
        // Phân tích từ file PDF mới upload
        result = await _cvAnalysisService.analyzeCVFromFile(
          pdfFile: _selectedFile!,
          userId: widget.idUser,
        );
      } else if (_selectedResume != null) {
        // Phân tích từ CV đã lưu
        result = await _cvAnalysisService.analyzeCVFromUrl(
          cvUrl: _selectedResume!.fileUrl,
          userId: widget.idUser,
        );
      } else {
        throw Exception('Không có file CV để phân tích');
      }

      if (!_isMounted || !mounted) return;

      // Convert JobPostingModel sang JobRecommendation để hiển thị
      final recommendations = result.recommendedJobs?.map((job) {
        final matchScore = ((job.matchScore ?? 0.0) * 100).clamp(0.0, 100.0);
        return JobRecommendation(
          title: job.title,
          company: job.company?.companyName ?? 'N/A',
          matchPercentage: matchScore.toInt(),
          description: job.description,
          requirements: job.requirements
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .take(5)
              .toList(),
          jobPosting: job, // Lưu jobPosting để navigate
        );
      }).toList() ?? [];

      setState(() {
        _isAnalyzed = true;
        _isProcessing = false;
        _analysisResult = result;
        _recommendations = recommendations;
        _analysisProgress = 1.0;
      });

      if (mounted) {
        SnackbarApp.show(
          context,
          title: 'Thành công',
          message: 'Phân tích CV hoàn tất!',
          backgroundColor: BackgroundColors.backgroundSuccessPrimary,
        );
      }
    } catch (e) {
      if (!_isMounted || !mounted) return;

      setState(() {
        _isProcessing = false;
        _analysisError = e.toString().replaceFirst('Exception: ', '');
        _analysisProgress = 0.0;
      });

      if (mounted) {
        SnackbarApp.show(
          context,
          title: 'Lỗi',
          message: _analysisError ?? 'Có lỗi xảy ra khi phân tích CV',
          backgroundColor: BackgroundColors.backgroundErrorPrimary,
        );
      }
    }
  }

  void _selectPreviousCV(ResumeModel resume) {
    if (!_isMounted || !mounted) return;

    setState(() {
      _selectedResume = resume;
      _selectedFile = null;
      _isAnalyzed = false;
    });

    _analyzeCV();
  }

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
    final theme = Theme.of(context);
    final resumeVm = context.watch<ResumeViewModel>();

    return Scaffold(
      appBar: const CustomAppbarTitleLarge(title: 'Phân tích CV'),
      body: _isProcessing
          ? _buildLoadingView(theme)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_isAnalyzed) ...[
                    _buildInitialOptions(theme, resumeVm),
                  ],
                  if (_isAnalyzed) ...[
                    _buildAnalysisResults(theme),
                  ],
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
          if (_analysisProgress > 0.0)
            SizedBox(
              width: 200.w,
              child: LinearProgressIndicator(
                value: _analysisProgress,
                backgroundColor: theme.colorScheme.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            )
          else
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
            ),
          SizedBox(height: 24.h),
          Text(
            _isAnalyzed ? 'Đang phân tích CV của bạn...' : 'Đang xử lý CV...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _analysisProgress > 0.0
                ? 'Tiến độ: ${(_analysisProgress * 100).toStringAsFixed(0)}%'
                : 'Quá trình này có thể mất vài giây.',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          if (_analysisError != null) ...[
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                _analysisError!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInitialOptions(ThemeData theme, ResumeViewModel resumeVm) {
    final resumes = resumeVm.resumes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        //  Upload new CV
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
                      color: theme.colorScheme.primary,
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
                            color: theme.hintColor,
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

        //  Previous CVs từ ResumeViewModel
        if (resumeVm.isListLoading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          )
        else if (resumes.isNotEmpty)
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
                          color: theme.colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.history,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Text(
                        'CV của bạn: ${resumes.length}',
                        softWrap: true,
                        maxLines: 2,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: resumes.length,
                    separatorBuilder: (context, index) =>
                        Divider(color: theme.dividerColor, height: 1),
                    itemBuilder: (context, index) {
                      return _buildPreviousCVItem(resumes[index], theme);
                    },
                  ),
                ],
              ),
            ),
          )
        else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Chưa có CV nào được lưu',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPreviousCVItem(ResumeModel cv, ThemeData theme) {
    final fileInfo = _getFileIconAndColor('dummy.${cv.fileName.split('.').last}');
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
                    cv.fileName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${cv.fileSizeKB} KB • ${cv.createdAt.day}/${cv.createdAt.month}/${cv.createdAt.year}',
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
    String fileName = '';
    if (_selectedFile != null) {
      fileName = _selectedFile!.path.split('/').last;
    } else if (_selectedResume != null) {
      fileName = _selectedResume!.fileName;
    }

    final fileInfo = _getFileIconAndColor(_selectedFile?.path ?? 'dummy.${_selectedResume?.fileName.split('.').last}');
    final IconData fileIcon = fileInfo['icon'];
    final Color fileIconColor = fileInfo['color'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // File info
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(fileIcon, color: fileIconColor, size: 40.sp),
                SizedBox(width: 12.w),
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
                          color: Colors.green.shade600,
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
                      _selectedFile = null;
                      _selectedResume = null;
                      _analysisResult = null;
                    });
                  },
                  tooltip: 'Chọn CV khác',
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 20.h),

        // CV Text Content Section
        if (_analysisResult != null && _analysisResult!.cvText.isNotEmpty) ...[
          Text(
            'Nội dung CV',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 12.h),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Container(
              constraints: BoxConstraints(maxHeight: 300.h),
              padding: EdgeInsets.all(16.w),
              child: SingleChildScrollView(
                child: Text(
                  _analysisResult!.cvText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
        ],

        Text(
          'Kết quả phân tích',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 16.h),

        // CV Analysis Summary
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
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
                SizedBox(height: 12.h),
                _buildAnalysisItem(
                  'Điểm mạnh',
                  _analysisResult?.strengths?.split('\n• ') ?? [
                    'Đang phân tích...',
                  ],
                  theme,
                  isStrengths: true,
                ),
                _buildAnalysisItem(
                  'Cần cải thiện',
                  _analysisResult?.weaknesses?.split('\n• ') ?? [
                    'Đang phân tích...',
                  ],
                  theme,
                  isStrengths: false,
                ),
                if (_analysisResult?.suggestedSkills != null &&
                    _analysisResult!.suggestedSkills!.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  _buildSuggestedSkills(_analysisResult!.suggestedSkills!, theme),
                ],
                SizedBox(height: 12.h),
                Text(
                  _analysisResult?.overallAssessment ??
                      'Đang phân tích CV của bạn...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.hintColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 24.h),

        // Job Recommendations
        Text(
          'Công việc phù hợp',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 16.h),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _recommendations.length,
          itemBuilder: (context, index) {
            return _buildJobRecommendationCard(_recommendations[index], theme);
          },
        ),
      ],
    );
  }

  Widget _buildSuggestedSkills(List<String> skills, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kỹ năng đề xuất',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: skills.map((skill) {
            return Chip(
              label: Text(skill),
              backgroundColor: theme.colorScheme.primaryContainer,
              labelStyle: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
              side: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAnalysisItem(
    String title,
    List<String> items,
    ThemeData theme, {
    bool isStrengths = true,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
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
          SizedBox(height: 8.h),
          ...items
              .map(
                (item) => Padding(
                  padding: EdgeInsets.only(left: 8.w, top: 4.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 6.sp,
                        color: theme.hintColor,
                      ),
                      SizedBox(width: 8.w),
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
      margin: EdgeInsets.symmetric(vertical: 8.h),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
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
                          color: theme.colorScheme.primary,
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
              children: job.requirements
                  .map(
                    (req) => Chip(
                      label: Text(req),
                      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                      labelStyle: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    if (job.jobPosting != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JobDetailScreen(
                            idUser: widget.idUser,
                            jobPosting: job.jobPosting!,
                          ),
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                  child: const Text('Xem chi tiết'),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: () {
                    // Ứng tuyển
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
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

  Color _getMatchColor(int percentage) {
    if (percentage >= 90) return Colors.green.shade600;
    if (percentage >= 75) return Theme.of(context).colorScheme.primary;
    if (percentage >= 60) return Colors.orange.shade700;
    return Theme.of(context).colorScheme.error;
  }
}

class JobRecommendation {
  final String title;
  final String company;
  final int matchPercentage;
  final String description;
  final List<String> requirements;
  final JobPostingModel? jobPosting; // Thêm để navigate

  JobRecommendation({
    required this.title,
    required this.company,
    required this.matchPercentage,
    required this.description,
    required this.requirements,
    this.jobPosting,
  });
}