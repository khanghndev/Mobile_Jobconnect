import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/data/models/account_model.dart';
import 'package:job_connect/data/models/candidate_info_model.dart';
import 'package:job_connect/data/models/job_application_model.dart';
import 'package:job_connect/data/models/job_saved_model.dart';
import 'package:job_connect/data/services/api.dart';
import 'package:job_connect/features/auth/screens/login_screen.dart';
import 'package:job_connect/features/home/screens/home_page.dart';
import 'package:job_connect/features/job/screens/job_history_screen.dart';
import 'package:job_connect/features/profile/screens/edit_profile_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Widget cho hiệu ứng "breathing" của border avatar (GIỮ NGUYÊN)
class BreathingBorderAvatar extends StatefulWidget {
  final double radius;
  final ImageProvider backgroundImage;
  final Widget? child;
  final List<Color> borderColors;

  const BreathingBorderAvatar({
    super.key,
    required this.radius,
    required this.backgroundImage,
    this.child,
    this.borderColors = const [Colors.cyanAccent, Colors.purpleAccent],
  });

  @override
  _BreathingBorderAvatarState createState() => _BreathingBorderAvatarState();
}

class _BreathingBorderAvatarState extends State<BreathingBorderAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 2.0,
      end: 5.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(_animation.value), // Border width animates
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: widget.borderColors,
              transform: GradientRotation(_controller.value * 2 * math.pi),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.borderColors.first.withOpacity(0.5),
                blurRadius: _animation.value * 2,
                spreadRadius: _animation.value / 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: widget.radius,
            backgroundColor: Colors.grey[200], // Fallback background
            backgroundImage: widget.backgroundImage,
            child: widget.child,
          ),
        );
      },
    );
  }
}

class ProfilePageScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;
  const ProfilePageScreen({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
  });

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePageScreen>
    with TickerProviderStateMixin {
  // =======================================================================
  // PHẦN LOGIC VÀ STATE MANAGEMENT - GIỮ NGUYÊN
  // =======================================================================
  final _apiService = ApiService(baseUrl: ApiConstants.baseUrl);
  Account? _account;
  CandidateInfo? _candidateInfo;
  final List<JobApplication> _applicationJobs = [];
  final List<JobSaved> _savedJobs = [];
  bool get isLoggedIn => widget.isLoggedIn;
  bool _isLoading = true;
  late AnimationController _staggerController;
  late AnimationController _fabPulseController;

  // NEW: ScrollController for Parallax Effect
  final ScrollController _scrollController = ScrollController();
  double _backgroundOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fabPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // NEW: Listener for Parallax Effect
    _scrollController.addListener(() {
      setState(() {
        // The 0.4 factor creates the parallax effect (background moves slower)
        _backgroundOffset = _scrollController.offset * 0.4;
      });
    });

    _initializeData();
    
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _fabPulseController.dispose();
    _scrollController.dispose(); // NEW: Dispose the scroll controller
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (mounted) setState(() => _isLoading = true);
    await Future.wait([
      _fetchAccount(),
      _fetchCandidateInfo(),
      _fetchApplicationJobs(),
      _fetchSavedJobs(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
      _staggerController.forward(from: 0.0);
    }
  }

  Future<void> _onRefresh() async {
    _staggerController.reset();
    await _loadAllData();
  }

  Future<void> _fetchAccount() async {
    try {
      final data = await _apiService.get(
        '${ApiConstants.userEndpoint}/${widget.idUser}',
      );
      if (data != null && data.isNotEmpty) {
        _account = Account.fromJson(data.first);
      }
    } catch (e) {
      print("Error fetching account: $e");
    }
  }

  Future<void> _fetchCandidateInfo() async {
    try {
      final data = await _apiService.get(
        '${ApiConstants.candidateInfoEndpoint}/${widget.idUser}',
      );
      if (data.isNotEmpty) {
        _candidateInfo = CandidateInfo.fromJson(data.first);
      } else {
        _candidateInfo = CandidateInfo(idUser: widget.idUser);
      }
    } catch (e) {
      print("Error fetching candidate info: $e");
    }
  }

  Future<void> _fetchApplicationJobs() async {
    try {
      final response = await _apiService.get(
        "${ApiConstants.jobApplicationEndpoint}/${widget.idUser}",
      );
      _applicationJobs.clear();
      _applicationJobs.addAll(
        response.map((job) => JobApplication.fromJson(job)),
      );
    } catch (e) {
      print('Error fetching application jobs: $e');
    }
  }

  Future<void> _fetchSavedJobs() async {
    try {
      final response = await _apiService.get(
        "${ApiConstants.jobSavedEndpoint}/${widget.idUser}",
      );
      _savedJobs.clear();
      _savedJobs.addAll(response.map((job) => JobSaved.fromJson(job)));
    } catch (e) {
      print('Error fetching saved jobs: $e');
    }
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                EditProfilePage(idUser: widget.idUser),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutQuint;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
    if (result == true) {
      _onRefresh();
    }
  }

  double _calculateProfileCompletionPercentage() {
    if (_account == null && _candidateInfo == null) return 0.0;
    double currentScore = 0;
    const double maxScore = 101; // Tổng các trọng số

    if (_account != null) {
      if (_account!.avatarUrl != null && _account!.avatarUrl!.isNotEmpty)
        currentScore += 10;
      if (_account!.userName != null && _account!.userName!.isNotEmpty)
        currentScore += 5;
      if (_account!.email.isNotEmpty) currentScore += 10;
      if (_account!.phoneNumber != null && _account!.phoneNumber!.isNotEmpty)
        currentScore += 10;
      if (_account!.dateOfBirth != null) currentScore += 5;
      if (_account!.gender != null && _account!.gender!.isNotEmpty)
        currentScore += 3;
      if (_account!.address != null && _account!.address!.isNotEmpty)
        currentScore += 7;
    }
    if (_candidateInfo != null) {
      if (_candidateInfo!.workPosition != null &&
          _candidateInfo!.workPosition!.isNotEmpty)
        currentScore += 10;
      if (_candidateInfo!.universityName != null &&
          _candidateInfo!.universityName!.isNotEmpty)
        currentScore += 8;
      if (_candidateInfo!.educationLevel != null &&
          _candidateInfo!.educationLevel!.isNotEmpty)
        currentScore += 8;
      if (_candidateInfo!.experienceYears != null &&
          _candidateInfo!.experienceYears! > 0)
        currentScore += 10;
      if (_candidateInfo!.skills != null && _candidateInfo!.skills!.isNotEmpty)
        currentScore += 15;
    }

    return (currentScore / maxScore).clamp(0.0, 1.0);
  }

  void _copyToClipboard(String? text, String fieldName) {
    if (text != null && text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Đã sao chép $fieldName!',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.secondary.withOpacity(0.9),
          elevation: 4,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // =======================================================================
  // PHẦN GIAO DIỆN (BUILD METHOD) - ĐÃ ĐƯỢC THIẾT KẾ LẠI
  // =======================================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.secondary),
        ),
      );
    }
    if (!isLoggedIn) {
      return _buildNotLoggedInProfile(context);
    }

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          // Lớp nền trang trí (UPDATED for Parallax)
          Positioned(
            top: -_backgroundOffset,
            left: 0,
            right: 0,
            child: _buildDecorativeBackground(theme),
          ),
          // Nội dung chính có thể cuộn
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController, // NEW: Attach scroll controller
              physics: const BouncingScrollPhysics(),
              child: AnimationLimiter(
                child: Column(
                  children: AnimationConfiguration.toStaggeredList(
                    // UPDATED: Enhanced animation parameters
                    duration: const Duration(milliseconds: 600),
                    childAnimationBuilder:
                        (widget) => SlideAnimation(
                          verticalOffset: 80.0,
                          child: FadeInAnimation(
                            curve: Curves.easeOutCubic,
                            child: widget,
                          ),
                        ),
                    children: [
                      const SizedBox(height: 24),
                      // Thẻ thông tin chính (Header)
                      _buildProfileHeaderCard(context),
                      // Các thẻ thông tin chi tiết
                      _buildSectionCard(
                        context,
                        "Thông Tin Cá Nhân",
                        Icons.face_retouching_natural,
                        [
                          _buildInfoRow(
                            Icons.person_4_outlined,
                            _account?.userName ?? "Chưa cập nhật",
                            "Họ và tên",
                            onCopy:
                                () => _copyToClipboard(
                                  _account?.userName,
                                  "Họ tên",
                                ),
                          ),
                          _buildInfoRow(
                            Icons.celebration_outlined,
                            _account?.dateOfBirth != null
                                ? DateFormat(
                                  'dd/MM/yyyy',
                                ).format(_account!.dateOfBirth!)
                                : "Chưa cập nhật",
                            "Ngày sinh",
                          ),
                          _buildInfoRow(
                            Icons.wc_outlined,
                            _account?.gender.toLowerCase() == "male"
                                ? "Nam"
                                : _account?.gender.toLowerCase() == "female"
                                ? "Nữ"
                                : "Chưa cập nhật",
                            "Giới tính",
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        context,
                        "Kênh Liên Lạc",
                        Icons.connect_without_contact_rounded,
                        [
                          _buildInfoRow(
                            Icons.alternate_email_rounded,
                            _account?.email ?? "Chưa có email",
                            "Email",
                            onCopy:
                                () =>
                                    _copyToClipboard(_account?.email, "Email"),
                          ),
                          _buildInfoRow(
                            Icons.phone_android_rounded,
                            _account?.phoneNumber ?? "Chưa có SĐT",
                            "Điện thoại",
                            onCopy:
                                () => _copyToClipboard(
                                  _account?.phoneNumber,
                                  "Số điện thoại",
                                ),
                          ),
                          _buildInfoRow(
                            Icons.home_work_outlined,
                            _account?.address ?? "Chưa có địa chỉ",
                            "Địa chỉ",
                            onCopy:
                                () => _copyToClipboard(
                                  _account?.address,
                                  "Địa chỉ",
                                ),
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        context,
                        "Học Vấn & Sự Nghiệp",
                        Icons.auto_stories_outlined,
                        [
                          _buildInfoRow(
                            Icons.account_balance_outlined,
                            _candidateInfo?.universityName ?? "Chưa có trường",
                            "Trường Đại học",
                          ),
                          _buildInfoRow(
                            Icons.workspace_premium_outlined,
                            _candidateInfo?.educationLevel ??
                                "Chưa có trình độ",
                            "Trình độ học vấn",
                          ),
                          _buildInfoRow(
                            Icons.workspaces_outline,
                            _candidateInfo?.workPosition ?? "Chưa có vị trí",
                            "Vị trí mong muốn",
                          ),
                          _buildInfoRow(
                            Icons.model_training_outlined,
                            _candidateInfo?.experienceYears != null
                                ? "${_candidateInfo?.experienceYears} năm"
                                : "Chưa có kinh nghiệm",
                            "Kinh nghiệm",
                          ),
                        ],
                      ),
                      _buildSkillsSection(context),
                      // Nút đăng xuất
                      _buildLogoutButton(context),
                      // Khoảng trống để không bị FAB che
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(parent: _fabPulseController, curve: Curves.easeInOut),
        ),
        child: FloatingActionButton.extended(
          onPressed: _navigateToEditProfile,
          backgroundColor: theme.colorScheme.primary,
          icon: const Icon(
            Icons.edit_notifications_outlined,
            color: Colors.white,
          ),
          label: Text(
            "Chỉnh sửa hồ sơ",
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  // =======================================================================
  // CÁC WIDGET CON ĐÃ ĐƯỢC THIẾT KẾ LẠI
  // =======================================================================

  /// Widget nền trang trí cho màn hình
  Widget _buildDecorativeBackground(ThemeData theme) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.25),
            theme.scaffoldBackgroundColor.withOpacity(0.1),
          ],
        ),
      ),
    );
  }

  /// Widget thẻ thông tin chính (Header)
  Widget _buildProfileHeaderCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final completion = _calculateProfileCompletionPercentage(); // 0.0 – 1.0
    final isComplete = completion == 1.0; // true nếu không có trường nào null

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.15 : 0.08),
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar và Tên + dấu tích xanh (nếu đầy đủ)
          Row(
            children: [
              Hero(
                tag: 'profile_avatar_${widget.idUser}',
                child: BreathingBorderAvatar(
                  radius: 45,
                  backgroundImage:
                      _account?.avatarUrl?.isNotEmpty == true
                          ? NetworkImage(_account!.avatarUrl!)
                          : const AssetImage("assets/images/logohuit.png")
                              as ImageProvider,
                  borderColors: [
                    theme.colorScheme.secondary,
                    theme.colorScheme.tertiary,
                    theme.colorScheme.primary,
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _account?.userName ?? "Người Dùng",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isComplete) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    if (_candidateInfo?.workPosition != null &&
                        _candidateInfo!.workPosition!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          _candidateInfo!.workPosition!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          Divider(color: theme.dividerColor.withOpacity(0.5), height: 1),
          const SizedBox(height: 16),

          // Các chỉ số thống kê
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                _applicationJobs.length.toDouble(),
                "Ứng tuyển",
                Icons.outbox_rounded,
                theme.colorScheme.secondary,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => JobHistoryScreen(idUser: widget.idUser),
                  ),
                ).then((_) => _onRefresh()),
              ),
              _buildStatItem(
                context,
                _savedJobs.length.toDouble(),
                "Đã lưu",
                Icons.bookmark_rounded,
                theme.colorScheme.tertiary,
                () => HomePage.goToSearchTab(context, initialTabIndex: 2),
              ),
              _buildStatItem(
                context,
                completion * 100,
                "Hoàn thiện",
                Icons.checklist_rtl_rounded,
                theme.colorScheme.primary,
                _navigateToEditProfile,
                isPercentage: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget cho mỗi mục thống kê (được dùng trong Header)
  /// UPDATED: Now animates the count value
  Widget _buildStatItem(
    BuildContext context,
    double count,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isPercentage = false,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            // NEW: Animated counter
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: count),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                final displayValue =
                    isPercentage
                        ? "${value.toStringAsFixed(0)}%"
                        : value.toStringAsFixed(0);
                return Text(
                  displayValue,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget cho các thẻ thông tin (Cá nhân, Liên lạc, v.v.)
  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData titleIcon,
    List<Widget> children,
  ) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.1 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  titleIcon,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(
              color: theme.dividerColor.withOpacity(0.5),
              height: 1,
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  /// Widget cho mỗi dòng thông tin (Họ tên, Email, v.v.)
  /// UPDATED: Enhanced visual hierarchy and icon styling
  Widget _buildInfoRow(
    IconData icon,
    String text,
    String subtitle, {
    Function()? onCopy,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 24), // Increased spacing
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NEW: Icon with background for better visibility
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.secondary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // UPDATED: Subtitle style is less prominent
                Text(
                  subtitle,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                // UPDATED: Main text is larger and bolder
                Text(
                  text.isNotEmpty ? text : "Chưa cập nhật",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (onCopy != null && text.isNotEmpty && text != "Chưa cập nhật")
            InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.copy_rounded,
                  size: 20,
                  color: theme.colorScheme.outline.withOpacity(0.8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Widget cho khu vực hiển thị kỹ năng
  /// UPDATED: Added staggered animation for the chips
  Widget _buildSkillsSection(BuildContext context) {
    final theme = Theme.of(context);
    final List<String> skillsList =
        _candidateInfo?.skills
            ?.split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];

    if (skillsList.isEmpty) {
      return _buildSectionCard(context, "Kỹ Năng", Icons.flare_outlined, [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            "Hãy cập nhật kỹ năng để nhà tuyển dụng tìm thấy bạn!",
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ]);
    }

    return _buildSectionCard(context, "Kỹ Năng", Icons.flare_outlined, [
      AnimationLimiter(
        child: Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 400),
            childAnimationBuilder:
                (widget) => SlideAnimation(
                  verticalOffset: 40.0,
                  child: FadeInAnimation(curve: Curves.easeOut, child: widget),
                ),
            children:
                skillsList.map((skill) {
                  return Chip(
                    avatar: Icon(
                      Icons.star_border_rounded,
                      color: theme.colorScheme.onSecondaryContainer.withOpacity(
                        0.8,
                      ),
                      size: 18,
                    ),
                    label: Text(
                      skill,
                      style: TextStyle(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: theme.colorScheme.secondaryContainer
                        .withOpacity(0.8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: theme.colorScheme.secondaryContainer,
                      ),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
          ),
        ),
      ),
    ]);
  }

  /// Widget cho nút Đăng xuất
  Widget _buildLogoutButton(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.width * 0.05,
        vertical: screenSize.height * 0.02,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.error.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _logout(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: screenSize.height * 0.018,
                horizontal: screenSize.width * 0.04,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    theme.colorScheme.error.withOpacity(0.08),
                    theme.colorScheme.error.withOpacity(0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.error.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: theme.colorScheme.error,
                    size: isSmallScreen ? 20 : 24,
                  ),
                  SizedBox(width: screenSize.width * 0.03),
                  Text(
                    "Đăng Xuất",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      fontSize: isSmallScreen ? 15 : 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Widget cho màn hình khi chưa đăng nhập (GIỮ NGUYÊN)
  Widget _buildNotLoggedInProfile(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.9),
              theme.colorScheme.secondary.withOpacity(0.7),
              theme.colorScheme.tertiary.withOpacity(0.5),
            ],
            stops: const [0.1, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              Icon(
                Icons.sentiment_very_dissatisfied_outlined,
                size: 100,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(height: 24),
              Text(
                "Bạn ơi, Đăng Nhập Nào!",
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    const Shadow(
                      blurRadius: 5,
                      color: Colors.black38,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Khám phá tiềm năng, kết nối cơ hội. Đăng nhập để bắt đầu hành trình sự nghiệp của bạn!",
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Spacer(flex: 3),
              ElevatedButton.icon(
                onPressed:
                    () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    ),
                icon: const Icon(Icons.rocket_launch_outlined, size: 24),
                label: const Text("BẮT ĐẦU NGAY"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: theme.colorScheme.primary,
                  minimumSize: const Size(double.infinity, 60),
                  elevation: 5,
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  shadowColor: Colors.black.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder:
          (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ), // Bo góc lớn hơn
            elevation: 5,
            backgroundColor: Colors.transparent, // Để Container con kiểm soát
            child: _buildLogoutDialog(context),
          ),
    );
    if (confirmLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', false);
      await prefs.setString('userId', "");
      if (mounted) {
        // Kiểm tra mounted trước khi dùng context
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Đăng xuất thành công")));
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildLogoutDialog(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Container(
      width: screenSize.width * 0.85,
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: screenSize.height * 0.03,
              horizontal: screenSize.width * 0.05,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.error,
                  theme.colorScheme.error.withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.exit_to_app_rounded,
                    color: theme.colorScheme.error,
                    size: isSmallScreen ? 36 : 42,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                Text(
                  'Xác Nhận Đăng Xuất',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    fontSize: isSmallScreen ? 20 : 24,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenSize.width * 0.06),
            child: Column(
              children: [
                Text(
                  'Bạn có chắc chắn muốn kết thúc phiên làm việc hiện tại?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
                SizedBox(height: screenSize.height * 0.03),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.onSurfaceVariant,
                          side: BorderSide(
                            color: theme.dividerColor.withOpacity(0.7),
                            width: 1.5,
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: screenSize.height * 0.015,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Ở LẠI',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            fontSize: isSmallScreen ? 13 : 14,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: screenSize.width * 0.04),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                          padding: EdgeInsets.symmetric(
                            vertical: screenSize.height * 0.015,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          shadowColor: theme.colorScheme.error.withOpacity(0.3),
                        ),
                        child: Text(
                          'ĐĂNG XUẤT',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                            fontSize: isSmallScreen ? 13 : 14,
                            color: theme.colorScheme.onError,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
