import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import 'package:job_connect/data/models/job_application_model.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/config/utils/status_helper.dart';
// Giả sử bạn có ApiService và ApiConstants để gọi API hủy
import 'package:job_connect/data/services/api.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/features/file/screens/file_viewer_screen.dart';
// import 'package:job_connect/features/file/file_viewer_screen.dart';

class JobApplicationDetailScreen extends StatefulWidget {
  // Chuyển thành StatefulWidget
  final JobApplication jobApplication;

  const JobApplicationDetailScreen({super.key, required this.jobApplication});

  @override
  State<JobApplicationDetailScreen> createState() =>
      _JobApplicationDetailScreenState();
}

class _JobApplicationDetailScreenState
    extends State<JobApplicationDetailScreen> {
  late JobApplication
  _currentJobApplication; // Để có thể cập nhật trạng thái sau khi hủy
  bool _isCancelling = false; // Cờ để theo dõi trạng thái hủy
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseUrl);

  @override
  void initState() {
    super.initState();
    _currentJobApplication = widget.jobApplication;
  }

  Future<void> _cancelApplication() async {
    // Hiển thị dialog xác nhận
    final bool? confirmCancel = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 10),
              Text(
                'Xác Nhận Hủy',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Bạn có chắc chắn muốn hủy đơn ứng tuyển cho vị trí "${_currentJobApplication.jobPosting.title}" không? Hành động này có thể không thể hoàn tác.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'KHÔNG',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'HỦY ỨNG TUYỂN',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmCancel == true) {
      if (!mounted) return;
      setState(() => _isCancelling = true);

      try {
        // TODO: Gọi API để hủy ứng tuyển
        // Ví dụ: await _apiService.post('${ApiConstants.jobApplicationEndpoint}/${_currentJobApplication.idJobApplication}/cancel', {});
        // Hoặc có thể là một lệnh DELETE hoặc PUT tùy theo API của bạn
        // Giả lập thành công sau 1 giây
        await Future.delayed(const Duration(seconds: 1));
        print(
          'Đã hủy ứng tuyển cho: ${_currentJobApplication.jobPosting.title}',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Đã hủy ứng tuyển thành công cho vị trí "${_currentJobApplication.jobPosting.title}".',
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Cập nhật trạng thái của jobApplication hiện tại (ví dụ: thành 'Đã hủy')
          // Hoặc pop về trang trước và yêu cầu refresh
          Navigator.of(
            context,
          ).pop(true); // true để báo hiệu trang trước cần refresh
        }
      } catch (e) {
        print('Lỗi khi hủy ứng tuyển: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi hủy ứng tuyển: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isCancelling = false);
      }
    }
  }

  // Các hàm build UI (_buildLogoPlaceholder, _buildStatusCard, ...) giữ nguyên như trước
  // Chỉ cần đảm bảo chúng nhận ThemeData theme từ hàm build chính

  Widget _buildLogoPlaceholder(
    String text, {
    double size = 60,
    required ThemeData theme,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: size * 0.45,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    String apiStatus,
    DateTime submittedAt,
    ThemeData theme,
  ) {
    final Color statusBgColor = AppStatus.getBgColor(apiStatus);
    final Color statusTextColor = AppStatus.getTextColor(apiStatus);
    final IconData statusIcon = AppStatus.getIcon(apiStatus);

    return Card(
      elevation: 3,
      shadowColor: statusBgColor.withOpacity(0.3),
      color: statusBgColor.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(statusIcon, color: statusTextColor, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trạng thái: ${AppStatus.getDisplayText(apiStatus)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusTextColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Ngày ứng tuyển: ${FormatUtils.formattedDateTime(submittedAt)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: statusTextColor.withOpacity(0.85),
                      fontWeight: FontWeight.w500,
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

  Widget _buildSectionTitle(
    BuildContext context,
    String title,
    IconData icon,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor, size: 22),
          const SizedBox(width: 10),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(
    String content,
    ThemeData theme, {
    bool isHtml = false,
  }) {
    return Card(
      elevation: 1.5,
      shadowColor: theme.shadowColor.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          content.isNotEmpty ? content : "Chưa có thông tin.",
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.6,
            color: theme.colorScheme.onSurface.withOpacity(0.85),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String? text,
    ThemeData theme, {
    Color? iconColor,
    bool isBold = false,
  }) {
    if (text == null || text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color:
                iconColor ??
                theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithAction(
    IconData icon,
    String text,
    VoidCallback onPressed,
    ThemeData theme,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Row(
          children: [
            Icon(icon, size: 22, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  String getFileNameFromFirebaseUrl(String url) {
    try {
      // Phân tích URL
      Uri uri = Uri.parse(url);

      // Lấy phần path (ví dụ: /v0/b/bucket-name/o/path%2Fto%2Ffile.pdf)
      String path = uri.path;

      // Loại bỏ phần đầu không cần thiết và giải mã URL
      // Tìm vị trí của '/o/'
      int objectPathStartIndex = path.indexOf('/o/');
      if (objectPathStartIndex == -1) {
        // Nếu không tìm thấy '/o/', có thể URL không đúng định dạng hoặc là một loại URL khác
        // Trong trường hợp này, thử lấy phần tử cuối cùng của path segments
        return uri.pathSegments.isNotEmpty
            ? uri.pathSegments.last
            : 'unknown_file';
      }

      // Lấy phần path của object sau '/o/' và giải mã
      String encodedObjectPath = path.substring(
        objectPathStartIndex + 3,
      ); // +3 để bỏ qua '/o/'
      String decodedObjectPath = Uri.decodeComponent(encodedObjectPath);

      // Tên file là phần cuối cùng của decodedObjectPath
      List<String> pathSegments = decodedObjectPath.split('/');
      if (pathSegments.isNotEmpty) {
        return pathSegments.last;
      }
    } catch (e) {
      print("Error parsing Firebase URL to get file name: $e");
    }
    // Trả về một giá trị mặc định hoặc ném lỗi nếu không thể phân tích
    return 'unknown_file';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final jobPosting =
        _currentJobApplication.jobPosting; // Sử dụng _currentJobApplication
    final company = jobPosting.company;

    Widget logoWidget;
    final String? effectiveLogoCompany = company.logoCompany;
    final String companyNameForPlaceholder =
        company.companyName.isNotEmpty
            ? company.companyName[0].toUpperCase()
            : 'C';

    if (effectiveLogoCompany != null && effectiveLogoCompany.isNotEmpty) {
      logoWidget = Image.network(
        effectiveLogoCompany,
        width: 64,
        height: 64,
        fit: BoxFit.contain,
        errorBuilder:
            (context, error, stackTrace) => _buildLogoPlaceholder(
              companyNameForPlaceholder,
              size: 64,
              theme: theme,
            ),
      );
    } else {
      logoWidget = _buildLogoPlaceholder(
        companyNameForPlaceholder,
        size: 64,
        theme: theme,
      );
    }

    // Điều kiện hiển thị nút hủy
    final bool canCancelApplication =
        _currentJobApplication.applicationStatus == AppStatus.pending;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF121212) : const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(
          jobPosting.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: 0.8,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface, size: 22),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(
              context,
              _currentJobApplication.applicationStatus,
              _currentJobApplication.submittedAt,
              theme,
            ),
            const SizedBox(height: 20),

            Card(
              elevation: 2.5,
              shadowColor: theme.shadowColor.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: theme.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 64,
                            height: 64,
                            color: theme.colorScheme.surfaceVariant.withOpacity(
                              0.3,
                            ),
                            child: logoWidget,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                jobPosting.title,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                company.companyName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant
                                      .withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Divider(
                      color: theme.dividerColor.withOpacity(0.5),
                      height: 1,
                    ),
                    const SizedBox(height: 18),
                    _buildInfoRow(
                      Icons.location_on_rounded,
                      jobPosting.location,
                      theme,
                      iconColor: theme.colorScheme.secondary,
                    ),
                    _buildInfoRow(
                      Icons.attach_money_rounded,
                      FormatUtils.formatSalary(jobPosting.salary ?? 0),
                      theme,
                      iconColor: theme.colorScheme.tertiary,
                      isBold: true,
                    ),
                    if (jobPosting.applicationDeadline != null)
                      _buildInfoRow(
                        Icons.event_busy_rounded,
                        'Hạn nộp: ${FormatUtils.formattedDateTime(jobPosting.applicationDeadline!)}',
                        theme,
                        iconColor: theme.colorScheme.error,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle(
              context,
              'Mô Tả Công Việc',
              Icons.description_rounded,
              theme,
            ),
            _buildContentCard(
              jobPosting.description ?? 'Chưa có mô tả chi tiết.',
              theme,
            ),
            const SizedBox(height: 24),

            _buildSectionTitle(
              context,
              'Yêu Cầu Ứng Viên',
              Icons.checklist_rtl_rounded,
              theme,
            ),
            _buildContentCard(
              jobPosting.requirements ?? 'Chưa có yêu cầu chi tiết.',
              theme,
            ),
            const SizedBox(height: 24),

            _buildSectionTitle(
              context,
              'Thông Tin Công Ty',
              Icons.business_rounded,
              theme,
            ),
            Card(
              elevation: 1.5,
              shadowColor: theme.shadowColor.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: theme.cardColor,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.companyName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      Icons.location_city_rounded,
                      company.address,
                      theme,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (_currentJobApplication.cvFileUrl != null ||
                (_currentJobApplication.coverLetter != null &&
                    _currentJobApplication.coverLetter!.isNotEmpty)) ...[
              _buildSectionTitle(
                context,
                'Hồ Sơ Đã Nộp',
                Icons.folder_shared_rounded,
                theme,
              ),
              Card(
                elevation: 1.5,
                shadowColor: theme.shadowColor.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: theme.cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_currentJobApplication.cvFileUrl != null)
                        _buildInfoRowWithAction(
                          Icons.picture_as_pdf_rounded,
                          'Xem CV đã nộp (${getFileNameFromFirebaseUrl(_currentJobApplication.cvFileUrl!)})',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => FileViewerScreen(
                                      fileUrl:
                                          _currentJobApplication.cvFileUrl!,
                                      fileName: getFileNameFromFirebaseUrl(
                                        _currentJobApplication.cvFileUrl!,
                                      ),
                                    ),
                              ),
                            );
                          },
                          theme,
                        ),
                      if (_currentJobApplication.cvFileUrl != null &&
                          (_currentJobApplication.coverLetter != null &&
                              _currentJobApplication.coverLetter!.isNotEmpty))
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Divider(height: 1),
                        ),
                      if (_currentJobApplication.coverLetter != null &&
                          _currentJobApplication.coverLetter!.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.mail_lock_outlined,
                                  color: theme.colorScheme.secondary,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Thư Xin Việc Đã Gửi:',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant
                                    .withOpacity(0.4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _currentJobApplication.coverLetter!,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24), // Khoảng cách trước nút hủy (nếu có)
            // Nút Hủy Ứng Tuyển
            if (canCancelApplication)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon:
                        _isCancelling
                            ? Container(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: theme.colorScheme.onError,
                                strokeWidth: 2.5,
                              ),
                            )
                            : Icon(
                              Icons.cancel_schedule_send_outlined,
                              color: theme.colorScheme.onError,
                            ),
                    label: Text(
                      _isCancelling ? 'ĐANG HỦY...' : 'HỦY ỨNG TUYỂN',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onError,
                      ),
                    ),
                    onPressed: _isCancelling ? null : _cancelApplication,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.errorContainer
                          .withOpacity(0.8), // Màu nền nhẹ của error
                      foregroundColor:
                          theme
                              .colorScheme
                              .onErrorContainer, // Màu chữ trên error container
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1, // Elevation nhẹ
                      side: BorderSide(
                        color: theme.colorScheme.error.withOpacity(0.5),
                      ), // Viền nhẹ
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
