import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/constant/app_string.dart';
import 'package:job_connect/data/models/company_model.dart';
import 'package:job_connect/data/models/job_application_model.dart';
import 'package:job_connect/data/models/job_posting_model.dart';
import 'package:job_connect/data/models/job_saved_model.dart';
import 'package:job_connect/config/providers/theme_provider.dart';
import 'package:job_connect/data/services/api.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/features/auth/screens/login_screen.dart';
import 'package:job_connect/features/company/screens/company_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:job_connect/features/job/screens/apply_job_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // Thêm cho animation
import 'package:share_plus/share_plus.dart'; // Thêm cho nút chia sẻ

class JobDetailScreen extends StatefulWidget {
  final String idUser;
  final String idJobPost;

  const JobDetailScreen({
    super.key,
    required this.idUser,
    required this.idJobPost,
  });

  @override
  JobDetailState createState() => JobDetailState();
}

class JobDetailState extends State<JobDetailScreen>
    with TickerProviderStateMixin {
  // Thêm TickerProviderStateMixin
  final _apiService = ApiService(baseUrl: ApiConstants.baseUrl);
  JobPosting? _jobPosting;
  JobSaved? _jobSaved; // Sẽ lưu trạng thái đã lưu của công việc này
  bool _isLoading = true;
  String? _errorMessage;
  List<JobApplication> _appJobList =
      []; // Giữ lại để hiển thị số lượng ứng viên

  late AnimationController _animationController; // Animation cho các section
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _initializeData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadAllData();
    if (mounted) _animationController.forward();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await Future.wait([
        _fetchJob(),
        _fetchSavedJobStatus(), // Đổi tên hàm này để rõ ràng hơn
        _fetchApplicationJobCount(), // Chỉ fetch số lượng nếu cần
      ]);
    } catch (e) {
      if (mounted) {
        setState(
          () => _errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại.',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    _animationController.reset();
    await _loadAllData();
    if (mounted) _animationController.forward();
  }

  Future<void> _fetchJob() async {
    try {
      final data = await _apiService.get(
        '${ApiConstants.jobPostingEndpoint}/${widget.idJobPost}',
      );
      if (data.isNotEmpty) {
        _jobPosting = JobPosting.fromJson(data.first);
      } else {
        throw Exception('Không tìm thấy thông tin công việc.');
      }
    } catch (e) {
      print('Error fetching job: $e');
      throw Exception('Lỗi khi tải thông tin công việc: $e');
    }
  }

  Future<void> _fetchSavedJobStatus() async {
    // Lấy trạng thái lưu của CÔNG VIỆC HIỆN TẠI
    if (widget.idUser.isEmpty) {
      _jobSaved = null; // Nếu không có idUser, không thể có trạng thái đã lưu
      return;
    }
    try {
      final data = await _apiService.get(
        '${ApiConstants.jobSaveJobPostdEndpoint}/${widget.idJobPost}/${widget.idUser}',
      );
      if (data.isNotEmpty) {
        _jobSaved = JobSaved.fromJson(data.first);
      } else {
        _jobSaved = null; // Công việc này chưa được lưu bởi user này
      }
    } catch (e) {
      print('Error fetching saved job status: $e');
      _jobSaved = null; // Lỗi thì coi như chưa lưu
      // Không ném lỗi ở đây để các phần khác vẫn có thể tải
    }
  }

  Future<void> _fetchApplicationJobCount() async {
    // Chỉ lấy số lượng ứng viên cho công việc này
    try {
      // API này cần trả về danh sách ứng viên cho một job post cụ thể
      // Hoặc một API khác trả về số lượng ứng viên
      final data = await _apiService.get(
        '${ApiConstants.jobApplicationJobPostEndpoint}/${widget.idJobPost}',
      );
      if (mounted) {
        _appJobList =
            data
                .map<JobApplication>((app) => JobApplication.fromJson(app))
                .toList();
      }
    } catch (e) {
      print('Error fetching applications count: $e');
      _appJobList = []; // Lỗi thì coi như không có ứng viên
    }
  }

  Future<void> _toggleSaveJob() async {
    // Đổi tên hàm và logic
    if (_jobPosting == null) return;
    if (widget.idUser.isEmpty) {
      _showLoginRequiredDialog(); // Yêu cầu đăng nhập nếu chưa có idUser
      return;
    }

    final theme = Theme.of(context);
    final bool currentlySaved = _jobSaved != null;

    setState(() {
      // Optimistic update
      if (currentlySaved) {
        _jobSaved = null;
      } else {
        // Tạo một đối tượng JobSaved giả để UI cập nhật ngay
        _jobSaved = JobSaved(
          idJobPost: widget.idJobPost,
          idUser: widget.idUser,
        );
      }
    });

    try {
      if (currentlySaved) {
        // Nếu đang lưu -> thực hiện bỏ lưu
        await _apiService.delete(
          "${ApiConstants.jobSaveJobPostdEndpoint}/${widget.idJobPost}/${widget.idUser}",
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Đã bỏ lưu công việc",
                style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
              ),
              backgroundColor: theme.colorScheme.secondaryContainer,
            ),
          );
        }
      } else {
        // Nếu chưa lưu -> thực hiện lưu
        Map<String, dynamic> data = {
          "idJobPost": widget.idJobPost,
          "idUser": widget.idUser,
        };
        final response = await _apiService.post(
          ApiConstants.jobSavedPostEndpoint,
          data,
        );
        if (response == 200 || response == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Đã lưu công việc thành công!",
                  style: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                backgroundColor: theme.colorScheme.secondaryContainer,
              ),
            );
          }
          // Sau khi lưu thành công, fetch lại trạng thái để có idJobSaved đúng
          await _fetchSavedJobStatus();
          if (mounted) setState(() {}); // Cập nhật lại UI với _jobSaved mới
        } else {
          throw Exception("Không thể lưu công việc");
        }
      }
    } catch (e) {
      if (mounted) {
        // Revert optimistic update
        setState(() {
          if (currentlySaved) {
            // Nếu trước đó đã lưu (giờ đang cố bỏ lưu mà lỗi)
            _jobSaved = JobSaved(
              idJobPost: widget.idJobPost,
              idUser: widget.idUser,
            ); // Giữ lại trạng thái đã lưu (có thể với id giả)
          } else {
            // Nếu trước đó chưa lưu (giờ đang cố lưu mà lỗi)
            _jobSaved = null;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentlySaved
                  ? 'Bỏ lưu thất bại: ${e.toString()}'
                  : 'Lưu thất bại: ${e.toString()}',
              style: TextStyle(color: theme.colorScheme.onError),
            ),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }

  void _shareJob() {
    if (_jobPosting != null) {
      Share.share(
        'Xem công việc thú vị này: ${_jobPosting!.title} tại ${_jobPosting!.company.companyName}! Chi tiết: [URL_CONG_VIEC_CUA_BAN]', // Thay [URL_CONG_VIEC_CUA_BAN] bằng link thực tế
        subject: 'Cơ hội việc làm: ${_jobPosting!.title}',
      );
    }
  }

  // ... (Các hàm build UI phụ trợ giữ nguyên, chỉ cần truyền theme)
  Widget _buildDetailItem(
    BuildContext context,
    IconData icon,
    String title,
    String value,
    Color color,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14), // Tăng padding
          decoration: BoxDecoration(
            color: color.withOpacity(0.15), // Nền đậm hơn
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ), // Thêm border
          ),
          child: Icon(icon, color: color, size: 26), // Icon lớn hơn
        ),
        const SizedBox(height: 10),
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    String? content, {
    required IconData icon,
    required Color iconColor,
    required ThemeData theme,
  }) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24), // Icon lớn hơn
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Tăng khoảng cách
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor, // Nền card
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor.withOpacity(0.4)),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              content,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.65,
                color: theme.colorScheme.onSurface.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarJobCard(
    BuildContext context,
    String title,
    String company,
    String salary,
    String location,
    ThemeData theme,
  ) {
    final isDarkMode = theme.brightness == Brightness.dark;
    return Container(
      width: 280, // Tăng chiều rộng
      margin: const EdgeInsets.only(right: 16), // Tăng margin
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor.withOpacity(isDarkMode ? 0.3 : 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(isDarkMode ? 0.1 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        // Thêm Material để có InkWell
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () {
            /* TODO: Navigate to this similar job's detail */
          },
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24, // Tăng kích thước
                          backgroundColor: theme.colorScheme.primaryContainer
                              .withOpacity(0.2),
                          child: Icon(
                            Icons.work_history_outlined,
                            color: theme.colorScheme.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                company,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withOpacity(0.85),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14), // Tăng khoảng cách
                    _buildInfoChip(
                      context,
                      Icons.attach_money_rounded,
                      salary == "0" ? "Lương thỏa thuận" : salary,
                      theme.colorScheme.secondary,
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoChip(
                      context,
                      Icons.location_pin,
                      location,
                      theme.colorScheme.tertiary,
                      theme,
                    ),
                  ],
                ),
                Container(
                  // Nút "Xem Ngay"
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.primaryColor,
                        theme.primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      "Xem Ngay",
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobLogo(BuildContext context, ThemeData theme) {
    final companyInitial =
        (_jobPosting!.title.isNotEmpty)
            ? _jobPosting!.title[0].toUpperCase()
            : "C";
    final String? coverPhotoUrl =
        _jobPosting!.company.logoCompany; // Logo của công ty

    return Stack(
      alignment: Alignment.center, // Căn giữa các thành phần trong Stack
      children: [
        // Lớp 1: Ảnh bìa hoặc Gradient nền
        Container(
          // Chiều cao này sẽ là chiều cao của FlexibleSpaceBar.background
          // Nó cần đủ lớn để chứa ảnh bìa và phần logo nhô ra
          height: 280.0, // Có thể điều chỉnh chiều cao này
          decoration: BoxDecoration(
            gradient:
                (coverPhotoUrl == null || coverPhotoUrl.isEmpty)
                    ? LinearGradient(
                      colors: [
                        theme.primaryColor.withOpacity(
                          0.9,
                        ), // Màu đậm hơn ở trên
                        theme.primaryColor.withOpacity(
                          0.6,
                        ), // Màu nhạt hơn ở dưới
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    )
                    : null,
            image:
                (coverPhotoUrl != null && coverPhotoUrl.isNotEmpty)
                    ? DecorationImage(
                      image: NetworkImage(coverPhotoUrl),
                      fit: BoxFit.cover,
                      // Lớp phủ nhẹ lên ảnh bìa để text/logo nổi hơn
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.35),
                        BlendMode.darken,
                      ),
                    )
                    : null,
          ),
        ),

        // Lớp 2: Logo và Tên công ty (khi SliverAppBar mở rộng)
        // Positioned này để đảm bảo logo và tên công ty nằm ở vị trí đẹp khi header mở rộng
        // và không bị che bởi title của SliverAppBar khi co lại.
        Positioned(
          // bottom: 65, // Điều chỉnh vị trí này để logo và tên không quá sát title khi co lại
          // Hoặc sử dụng Column và MainAxisAlignment.center nếu không có ảnh bìa
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100, // Kích thước logo
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.cardColor, // Nền cho logo
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.8),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.25),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child:
                      (_jobPosting!.company.logoCompany != null &&
                              _jobPosting!.company.logoCompany!.isNotEmpty)
                          ? Image.network(
                            _jobPosting!.company.logoCompany!,
                            fit: BoxFit.contain, // Contain để thấy rõ logo
                            errorBuilder:
                                (context, error, stackTrace) => Center(
                                  child: Image.asset(
                                    "assets/images/logohuit.png",
                                  ),
                                ),
                          )
                          : Center(
                            child: Text(
                              companyInitial,
                              style: theme.textTheme.displayMedium?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 12),
              // Tên công ty sẽ hiển thị ở đây khi header mở rộng
              // Nó sẽ bị ẩn đi bởi title của FlexibleSpaceBar khi co lại
              // Chúng ta sẽ dùng Opacity để làm mờ nó đi khi title của FlexibleSpaceBar xuất hiện
              // (Cần tính toán scroll offset để làm điều này, hoặc đơn giản là chấp nhận nó bị che)
              Text(
                _jobPosting!.company.companyName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color:
                      (coverPhotoUrl != null && coverPhotoUrl.isNotEmpty)
                          ? Colors.white
                          : theme.colorScheme.onPrimary, // Màu chữ tùy theo nền
                  fontWeight: FontWeight.bold,
                  shadows:
                      (coverPhotoUrl != null && coverPhotoUrl.isNotEmpty)
                          ? [
                            // Shadow cho chữ trên ảnh
                            BoxShadow(
                              color: Colors.black.withOpacity(0.7),
                              blurRadius: 5,
                              offset: Offset(0, 1),
                            ),
                          ]
                          : null,
                ),
                textAlign: TextAlign.center,
              ),
              if (_jobPosting!.company.industry.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _jobPosting!.company.industry,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color:
                        (coverPhotoUrl != null && coverPhotoUrl.isNotEmpty)
                            ? Colors.white.withOpacity(0.9)
                            : theme.colorScheme.onPrimary.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ), // Tăng padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), // Nền đậm hơn
        borderRadius: BorderRadius.circular(10), // Bo góc lớn hơn
        // border: Border.all(color: color.withOpacity(0.4), width: 1) // Có thể thêm border
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color), // Icon lớn hơn
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ), // Chữ đậm hơn
              overflow: TextOverflow.ellipsis, // Cho phép tràn nếu quá dài
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog() {
    // ... (Giữ nguyên dialog này, đảm bảo nó sử dụng Theme.of(context))
    final theme = Theme.of(context);
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation1, animation2) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        );
        return ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(curvedAnimation),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              backgroundColor: theme.cardColor,
              child: Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.lock_person_outlined,
                              color: theme.colorScheme.primary,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Yêu Cầu Đăng Nhập',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                      child: Column(
                        children: [
                          Text(
                            'Để tiếp tục, bạn cần đăng nhập vào tài khoản ${AppStrings.appName}. Khám phá ngay!',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              height: 1.45,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context, true);
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                  (Route<dynamic> route) => false,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              icon: const Icon(Icons.login_rounded, size: 20),
                              label: Text(
                                'ĐĂNG NHẬP NGAY',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: theme
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.7),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'ĐỂ SAU',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final systemOverlayStyle =
        isDarkMode ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    Widget appBarTitle = Text(
      _isLoading || _jobPosting == null ? "Đang Tải..." : "Chi Tiết Công Việc",
      style: theme.textTheme.titleLarge?.copyWith(
        color: theme.colorScheme.onPrimary,
        fontWeight: FontWeight.bold,
      ),
    );

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.colorScheme.primary, // Nền AppBar khi loading
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.onPrimary,
              size: 22,
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
          title: appBarTitle,
          centerTitle: true,
          systemOverlayStyle:
              SystemUiOverlayStyle.light, // Luôn light cho AppBar primary
        ),
        body: Center(
          child: CircularProgressIndicator(color: theme.primaryColor),
        ),
      );
    }

    if (_errorMessage != null || _jobPosting == null) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.colorScheme.errorContainer,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: theme.colorScheme.onErrorContainer,
              size: 22,
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
          title: Text(
            "Đã Xảy Ra Lỗi",
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onErrorContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          systemOverlayStyle: systemOverlayStyle,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: theme.colorScheme.error,
                  size: 70,
                ),
                const SizedBox(height: 20),
                Text(
                  _errorMessage ??
                      "Không thể tải thông tin công việc. Vui lòng kiểm tra lại kết nối mạng.",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: _onRefresh, // Gọi _onRefresh
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text("Thử Lại Ngay"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bool isJobCurrentlySaved =
        _jobSaved != null && _jobSaved!.idJobPost.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _onRefresh, // Sử dụng _onRefresh
        color: theme.primaryColor,
        backgroundColor: theme.cardColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight:
                  280.0, // Chiều cao khi mở rộng (chứa ảnh bìa và logo)
              floating: false,
              pinned: true, // AppBar sẽ pin lại khi cuộn lên
              stretch: true, // Cho phép stretch
              backgroundColor: theme.colorScheme.primary, // Màu nền khi co lại
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 2.0,
              systemOverlayStyle:
                  SystemUiOverlayStyle.light, // Icon status bar màu trắng
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                  StretchMode.fadeTitle,
                ],
                background: _buildJobLogo(
                  context,
                  theme,
                ), // Phần header với logo và ảnh bìa
                titlePadding: const EdgeInsetsDirectional.only(
                  start: 50.0,
                  bottom: 16.0,
                  end: 50.0,
                ), // Điều chỉnh padding
                centerTitle: true,
                title: Text(
                  // Title này sẽ chỉ hiển thị khi AppBar co lại
                  _jobPosting!.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color:
                        Colors
                            .white, // Luôn là màu trắng để nổi trên nền primary
                    fontWeight: FontWeight.bold,
                    // Thêm shadow để dễ đọc hơn khi co lại trên nền ảnh (nếu ảnh bìa phức tạp)
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                collapseMode: CollapseMode.parallax,
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isJobCurrentlySaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 26,
                  ),
                  onPressed: _toggleSaveJob,
                  tooltip:
                      isJobCurrentlySaved
                          ? "Bỏ lưu công việc"
                          : "Lưu công việc",
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined, size: 26),
                  onPressed: _shareJob, // Gọi hàm _shareJob
                  tooltip: "Chia sẻ công việc",
                ),
                const SizedBox(width: 4),
              ],
              // FlexibleSpaceBar không cần thiết nếu chỉ muốn title đơn giản
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                // Animation cho nội dung
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16.0,
                    20.0,
                    16.0,
                    100.0,
                  ), // Tăng padding bottom cho FAB
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      // Animation cho các section
                      duration: const Duration(milliseconds: 450),
                      childAnimationBuilder:
                          (widget) => SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(child: widget),
                          ),
                      children: [
                        _buildJobOverviewCard(theme),
                        const SizedBox(height: 24),
                        _buildSection(
                          context,
                          "Mô Tả Công Việc Chi Tiết",
                          _jobPosting!.description,
                          icon: Icons.article_outlined,
                          iconColor: theme.colorScheme.primary,
                          theme: theme,
                        ),
                        _buildSection(
                          context,
                          "Yêu Cầu Đối Với Ứng Viên",
                          _jobPosting!.requirements,
                          icon: Icons.rule_folder_outlined,
                          iconColor: theme.colorScheme.primary,
                          theme: theme,
                        ),
                        if (_jobPosting!.benefits != null &&
                            _jobPosting!.benefits!.isNotEmpty)
                          _buildSection(
                            context,
                            "Quyền Lợi & Phúc Lợi",
                            _jobPosting!.benefits!,
                            icon: Icons.emoji_events_outlined,
                            iconColor: theme.colorScheme.primary,
                            theme: theme,
                          ),
                        _buildCompanyInfoCard(theme),
                        _buildSimilarJobsSection(theme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildFloatingActionButtons(
        theme,
        isJobCurrentlySaved,
      ),
    );
  }

  Widget _buildJobOverviewCard(ThemeData theme) {
    return Card(
      elevation: 4, // Tăng elevation
      shadowColor: theme.shadowColor.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                    border: Border.all(
                      color: theme.dividerColor.withOpacity(0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child:
                        (_jobPosting!.company.logoCompany != null &&
                                _jobPosting!.company.logoCompany!.isNotEmpty)
                            ? Image.network(
                              _jobPosting!.company.logoCompany!,
                              fit: BoxFit.contain,
                              errorBuilder:
                                  (c, e, s) => Icon(
                                    Icons.business_center_rounded,
                                    size: 35,
                                    color: theme.colorScheme.primary,
                                  ),
                            )
                            : Icon(
                              Icons.business_center_rounded,
                              size: 35,
                              color: theme.colorScheme.primary,
                            ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _jobPosting!.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _jobPosting!.company.companyName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.9,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              // Sử dụng Wrap để các chip tự xuống dòng
              spacing: 12, // Khoảng cách ngang
              runSpacing: 12, // Khoảng cách dọc
              children: [
                _buildInfoChip(
                  context,
                  Icons.location_pin,
                  _jobPosting!.location,
                  theme.colorScheme.secondary,
                  theme,
                ),
                _buildInfoChip(
                  context,
                  Icons.calendar_month_rounded,
                  FormatUtils.formattedDateTime(_jobPosting!.createdAt),
                  theme.colorScheme.tertiary,
                  theme,
                ),
                _buildInfoChip(
                  context,
                  Icons.work_history_outlined,
                  _jobPosting!.workType,
                  theme.colorScheme.primary,
                  theme,
                ),
                _buildInfoChip(
                  context,
                  Icons.leaderboard_outlined,
                  _jobPosting!.experienceLevel,
                  theme.colorScheme.error,
                  theme,
                ),
              ],
            ),
            Divider(
              height: 35,
              thickness: 0.8,
              color: theme.dividerColor.withOpacity(0.5),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _buildDetailItem(
                    context,
                    Icons.payments_rounded,
                    "Mức Lương",
                    FormatUtils.formatSalary(_jobPosting!.salary ?? 0),
                    theme.colorScheme.secondary,
                    theme,
                  ),
                ),
                Container(
                  height: 50,
                  width: 1,
                  color: theme.dividerColor.withOpacity(0.4),
                ), // Vertical divider
                Expanded(
                  child: _buildDetailItem(
                    context,
                    Icons.groups_2_outlined,
                    "Ứng Viên",
                    '${_appJobList.length}',
                    theme.colorScheme.tertiary,
                    theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyInfoCard(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.apartment_rounded,
                color: theme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Thông Tin Công Ty",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            // Thêm Material để có InkWell
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16),
            elevation: 1.5,
            shadowColor: theme.shadowColor.withOpacity(0.05),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CompanyDetailsScreen(
                          company: _jobPosting!.company,
                          idUser: widget.idUser,
                        ),
                  ),
                ).then((_) => _onRefresh());
              },
              borderRadius: BorderRadius.circular(16),
              splashColor: theme.primaryColor.withOpacity(0.1),
              highlightColor: theme.primaryColor.withOpacity(0.05),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // color: theme.cardColor, // Đã set ở Material
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.3),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32, // Tăng kích thước
                      backgroundColor: theme.colorScheme.primaryContainer
                          .withOpacity(0.15),
                      child:
                          (_jobPosting!.company.logoCompany != null &&
                                  _jobPosting!.company.logoCompany!.isNotEmpty)
                              ? ClipOval(
                                child: Image.network(
                                  _jobPosting!.company.logoCompany!,
                                  fit: BoxFit.contain,
                                  width: 50,
                                  height: 50,
                                  errorBuilder:
                                      (c, e, s) => Icon(
                                        Icons.business_rounded,
                                        color: theme.colorScheme.primary,
                                        size: 30,
                                      ),
                                ),
                              )
                              : Icon(
                                Icons.business_rounded,
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
                            _jobPosting!.company.companyName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.visibility_outlined,
                                size: 18,
                                color: theme.colorScheme.primary.withOpacity(
                                  0.8,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                "Xem chi tiết công ty",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 20,
                      color: theme.iconTheme.color?.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarJobsSection(ThemeData theme) {
    // Dữ liệu giả, cần thay thế bằng API fetch
    final List<Map<String, String>> similarJobsData = [
      {
        "title": "Senior Flutter Developer",
        "company": "Innovatech Ltd.",
        "salary": FormatUtils.formatSalary(25000000),
        "location": "Quận 1, TP. HCM",
        "logo": "URL_LOGO_1",
      },
      {
        "title": "Mobile Application Engineer",
        "company": "SolutionHub",
        "salary": FormatUtils.formatSalary(22000000),
        "location": "Đống Đa, Hà Nội",
        "logo": "URL_LOGO_2",
      },
      {
        "title": "Junior Mobile Developer (Flutter)",
        "company": "StartupX",
        "salary": FormatUtils.formatSalary(12000000),
        "location": "Hải Châu, Đà Nẵng",
        "logo": "",
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.explore_outlined,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Việc Làm Tương Tự",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  /* TODO: Navigate to full similar jobs list */
                },
                child: Text(
                  "Xem Tất Cả",
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 220, // Tăng chiều cao
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: similarJobsData.length,
              itemBuilder: (context, index) {
                final job = similarJobsData[index];
                return AnimationConfiguration.staggeredList(
                  // Animation cho từng card
                  position: index,
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  child: SlideAnimation(
                    horizontalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildSimilarJobCard(
                        context,
                        job["title"]!,
                        job["company"]!,
                        job["salary"]!,
                        job["location"]!,
                        theme,
                      ),
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

  Widget _buildFloatingActionButtons(
    ThemeData theme,
    bool isJobCurrentlySaved,
  ) {
    return Container(
      height: 85, // Tăng chiều cao
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ), // Tăng padding
      decoration: BoxDecoration(
        color: theme.bottomAppBarTheme.color ?? theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(
              theme.brightness == Brightness.dark ? 0.2 : 0.1,
            ),
            spreadRadius: 1,
            blurRadius: 15, // Tăng blur
            offset: const Offset(0, -4), // Shadow hướng lên
          ),
        ],
        // borderRadius: BorderRadius.vertical(top: Radius.circular(24)) // Có thể thêm bo góc trên
      ),
      child: SafeArea(
        // Đảm bảo không bị che bởi bottom system UI
        top: false, // Chỉ áp dụng cho bottom
        child: Row(
          children: [
            InkWell(
              // Nút bookmark với hiệu ứng chạm tốt hơn
              onTap: _toggleSaveJob,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14), // Tăng padding
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(
                      isJobCurrentlySaved ? 0.7 : 0.3,
                    ),
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  isJobCurrentlySaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_add_outlined,
                  color: theme.primaryColor,
                  size: 28, // Icon lớn hơn
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton.icon(
                // Thêm icon cho nút ứng tuyển
                onPressed: () {
                  if (widget.idUser.isEmpty) {
                    _showLoginRequiredDialog();
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ApplyJobScreen(
                            jobId: widget.idJobPost,
                            jobTitle: _jobPosting!.title,
                            companyName: _jobPosting!.company.companyName,
                            idUser: widget.idUser,
                          ),
                    ),
                  ).then((_) => _onRefresh());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ), // Tăng padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                ),
                icon: const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  'Ứng Tuyển Ngay',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
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
