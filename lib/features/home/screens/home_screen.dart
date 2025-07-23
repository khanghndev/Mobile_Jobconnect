import 'package:flutter/material.dart';
import 'package:job_connect/core/config/constant/api_constants.dart';
import 'package:job_connect/core/data/models/account_model.dart';
import 'package:job_connect/core/data/models/company_model.dart';
import 'package:job_connect/core/data/models/job_posting_model.dart';
import 'package:job_connect/core/data/models/notification_model.dart';
import 'package:job_connect/core/data/models/podcast_model.dart';
import 'package:job_connect/core/data/services/api.dart';
import 'package:job_connect/core/config/utils/format.dart';
import 'package:job_connect/features/company/screens/company_detail_screen.dart';
import 'package:job_connect/features/company/screens/company_screen.dart';
import 'package:job_connect/features/home/screens/home_page.dart';
import 'package:job_connect/features/job/screens/job_detail_screen.dart';
import 'package:job_connect/features/home/screens/podcast_screen.dart';
import 'package:job_connect/features/home/screens/nearby_jobs_map_screen.dart';
import 'package:job_connect/features/auth/screens/login_screen.dart';
import 'dart:async';
import 'dart:math' as math; // For random colors or transformations
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // For list animations

// Custom Clipper cho hiệu ứng sóng
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.85); // Bắt đầu sóng thấp hơn một chút

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2.25, size.height - 30.0);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(
      size.width - (size.width / 3.25),
      size.height - 65,
    );
    var secondEndPoint = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, size.height * 0.85);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class HomeScreen extends StatefulWidget {
  final void Function(RefreshCallback refreshCallback)? registerRefreshCallback;
  final bool isLoggedIn;
  final String idUser;

  const HomeScreen({
    super.key,
    this.isLoggedIn = false,
    required this.idUser,
    this.registerRefreshCallback,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Add TickerProviderStateMixin
  final _apiService = ApiService(baseUrl: ApiConstants.baseUrl);
  bool get isLoggedIn => widget.isLoggedIn;
  Account? _account;
  List<Company> _featuredCompanies = [];
  List<JobPosting> _featuredJobs = [];
  List<Podcast> _featuredPodcasts = [];
  List<Map<String, dynamic>> _bannerItems = [];
  int unreadNotifications = 0;

  bool _isLoading = true;
  late AnimationController _fadeController; // For fade-in animation
  late Animation<double> _fadeAnimation = CurvedAnimation(
    parent: _fadeController,
    curve: Curves.easeIn,
  );

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _initializeData();
    widget.registerRefreshCallback?.call(_onRefresh);
  }

  Future<void> _initializeData() async {
    await _loadAllData();
    _bannerItems = [
      {
        'image': 'assets/images/placeholder_banner_1.jpg',
        'color': const Color(0xFF6A11CB), // Purple Gradient Start
        'endColor': const Color(0xFF2575FC), // Purple Gradient End
        'title': 'Khám phá sự nghiệp',
        'value': 1,
        'description': 'Hàng ngàn cơ hội đang chờ đón bạn mỗi ngày.',
        'icon': Icons.explore_outlined,
      },
      {
        'image': 'assets/images/placeholder_banner_2.jpg',
        'color': const Color(0xFFFC5C7D), // Pink Gradient Start
        'endColor': const Color(0xFF6A82FB), // Pink Gradient End
        'title': 'AI tư vấn thông minh',
        'value': 2,
        'description': 'Chatbot định hướng, gợi ý công việc hoàn hảo.',
        'icon': Icons.psychology_alt_outlined,
      },
      {
        'image': 'assets/images/placeholder_banner_3.jpg',
        'color': const Color(0xFF00C9FF), // Blue-Green Gradient Start
        'endColor': const Color(0xFF92FE9D), // Blue-Green Gradient End
        'title': 'CV đột phá ấn tượng',
        'value': 3,
        'description': 'Tạo dấu ấn riêng, chinh phục nhà tuyển dụng.',
        'icon': Icons.auto_stories_outlined,
      },
      {
        'image': 'assets/images/placeholder_banner_4.jpg',
        'color': const Color(0xFFFF8008), // Orange Gradient Start
        'endColor': const Color(0xFFFFC837), // Orange Gradient End
        'title': 'Mạng lưới doanh nghiệp',
        'value': 4,
        'description': 'Kết nối trực tiếp, mở rộng mối quan hệ.',
        'icon': Icons.hub_outlined,
      },
    ];

    if (mounted) {
      _startBannerTimer();
      _fadeController.forward(); // Start fade-in animation for the whole screen
    }
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    await Future.wait([
      _fetchAccount(),
      _fetchFeaturedCompanies(),
      _fetchFeaturedJobs(),
      _fetchFeaturedPodcasts(),
      _fetchUnreadNotificationsCount(),
    ]).catchError((e) {
      debugPrint("Error loading all data: $e");
    });
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    _featuredCompanies.clear();
    _featuredJobs.clear();
    _featuredPodcasts.clear();
    unreadNotifications = 0;
    _account = null;
    _fadeController.reset(); // Reset animation
    await _loadAllData();
    if (mounted) _fadeController.forward(); // Restart animation
  }

  Future<void> _fetchAccount() async {
    if (widget.idUser.isEmpty) {
      _account = null;
      return;
    }
    try {
      final dynamic responseData = await _apiService.get(
        '${ApiConstants.userEndpoint}/${widget.idUser}',
      );
      if (responseData != null) {
        if (responseData is List && responseData.isNotEmpty) {
          if (responseData.first is Map<String, dynamic>) {
            _account = Account.fromJson(
              responseData.first as Map<String, dynamic>,
            );
          }
        } else if (responseData is Map<String, dynamic>) {
          _account = Account.fromJson(responseData);
        }
      }
    } catch (e) {
      debugPrint('Error fetching account: $e');
      _account = null;
    }
  }

  Future<void> _fetchFeaturedCompanies() async {
    try {
      final dynamic responseData = await _apiService.get(
        ApiConstants.companiesFeaturedEndpoint,
      );
      if (responseData != null && responseData is List) {
        _featuredCompanies =
            responseData
                .where((item) => item is Map<String, dynamic>)
                .map((item) => Company.fromJson(item as Map<String, dynamic>))
                .toList();
      }
    } catch (e) {
      debugPrint('Error fetching featured companies: $e');
      _featuredCompanies = [];
    }
  }

  Future<void> _fetchFeaturedJobs() async {
    try {
      final dynamic responseData = await _apiService.get(
        ApiConstants.jobPostingFeaturedEndpoint,
      );
      if (responseData != null && responseData is List) {
        _featuredJobs =
            responseData
                .where((item) => item is Map<String, dynamic>)
                .map(
                  (item) => JobPosting.fromJson(item as Map<String, dynamic>),
                )
                .toList();
      }
    } catch (e) {
      debugPrint('Error fetching featured jobs: $e');
      _featuredJobs = [];
    }
  }

  Future<void> _fetchFeaturedPodcasts() async {
    try {
      final dynamic responseData = await _apiService.get(
        ApiConstants.podcastFeaturedEndpoint,
      );
      if (responseData != null && responseData is List) {
        _featuredPodcasts =
            responseData
                .where((item) => item is Map<String, dynamic>)
                .map((item) => Podcast.fromJson(item as Map<String, dynamic>))
                .toList();
      }
    } catch (e) {
      debugPrint('Error fetching featured podcasts: $e');
      _featuredPodcasts = [];
    }
  }

  Future<void> _fetchUnreadNotificationsCount() async {
    if (widget.idUser.isEmpty) {
      unreadNotifications = 0;
      return;
    }
    try {
      final dynamic responseData = await _apiService.get(
        "${ApiConstants.notificationEndpoint}/${widget.idUser}",
      );
      if (responseData != null && responseData is List) {
        List<NotificationModel> notifications =
            responseData
                .where((item) => item is Map<String, dynamic>)
                .map(
                  (item) =>
                      NotificationModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
        unreadNotifications = notifications.where((n) => n.isRead == 0).length;
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
      unreadNotifications = 0;
    }
  }

  final ScrollController _scrollController = ScrollController();
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController(
    viewportFraction: 0.9,
  ); // Cho banner nhỏ hơn, thấy banner kế
  Timer? _bannerTimer;

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Tăng thời gian banner
      if (!mounted) {
        timer.cancel();
        return;
      }
      int nextPage = (_currentBannerIndex + 1) % _bannerItems.length;
      if (_bannerController.hasClients) {
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800), // Tăng thời gian chuyển
          curve: Curves.easeInOutQuint, // Curve mượt hơn
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Chào buổi sáng!";
    if (hour < 17) return "Buổi chiều năng động!";
    return "Buổi tối thư giãn!";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return FadeTransition(
      // Wrap toàn bộ màn hình trong FadeTransition
      opacity: _fadeAnimation,
      child: Scaffold(
        // Sử dụng Scaffold để có thể thêm AppBar nếu muốn sau này
        // backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5), // Nền tùy chỉnh
        body: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header với hiệu ứng sóng
              ClipPath(
                clipper: WaveClipper(), // Áp dụng WaveClipper
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    60,
                    24,
                    70,
                  ), // Tăng padding cho sóng
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDarkMode
                              ? [
                                theme.colorScheme.primary.withOpacity(0.8),
                                theme.colorScheme.secondary.withOpacity(0.7),
                              ]
                              : [
                                theme.colorScheme.primary,
                                theme.colorScheme.primaryContainer,
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w300, // Font mỏng hơn
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _account?.userName ??
                            "Khám Phá Ngay", // Hiển thị tên nếu có
                        style: theme.textTheme.displaySmall?.copyWith(
                          // Font lớn, ấn tượng
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildBannerSlideshow(context),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ), // Giảm padding vertical
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildNearbyJobsButton(context),
                    const SizedBox(height: 35),

                    _buildSectionHeader(context, "Doanh nghiệp nổi bật", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => CompanyScreen(idUser: widget.idUser),
                        ),
                      ).then((_) => _onRefresh());
                    }),
                    const SizedBox(height: 18),
                    _buildFeaturedCompaniesList(context),
                    const SizedBox(height: 35),

                    _buildSectionHeader(
                      context,
                      "Công việc nổi bật",
                      () => HomePage.goToSearchTab(context),
                    ),
                    const SizedBox(height: 18),
                    _buildFeaturedJobsList(context),
                    const SizedBox(height: 35),

                    _buildSectionHeader(context, "Podcast nổi bật", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PodcastScreen(),
                        ),
                      ).then((_) => _onRefresh());
                    }),
                    const SizedBox(height: 18),
                    _buildFeaturedPodcastsList(context),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNearbyJobsButton(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () async {
        if (!isLoggedIn) {
          _showLoginRequiredDialog();
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => NearbyJobsMapScreen(
                  isLoggedIn: widget.isLoggedIn,
                  idUser: widget.idUser,
                ),
          ),
        ).then((_) => _onRefresh());
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.secondary,
              theme.colorScheme.tertiary.withOpacity(0.8),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.secondary.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.radar_outlined, color: Colors.white, size: 26),
            const SizedBox(width: 12),
            Text(
              "Tìm Việc Quanh Đây",
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onViewAll,
  ) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            // Lớn hơn, ấn tượng hơn
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface.withOpacity(0.85),
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            // Thêm icon cho "Xem tất cả"
            children: [
              Text(
                "Tất cả",
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCompaniesList(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.secondary,
            ),
          ),
        ),
      );
    }
    if (_featuredCompanies.isEmpty) {
      return SizedBox(
        height: 60,
        child: Center(
          child: Text(
            'Chưa có doanh nghiệp nổi bật',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return SizedBox(
      height: 210, // Tăng chiều cao
      child: AnimationLimiter(
        // Thêm AnimationLimiter
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _featuredCompanies.length,
          itemBuilder: (context, index) {
            final company = _featuredCompanies[index];
            return AnimationConfiguration.staggeredList(
              // Animation cho từng item
              position: index,
              duration: const Duration(milliseconds: 475),
              child: SlideAnimation(
                verticalOffset: 50.0,
                horizontalOffset: 100.0,
                child: FadeInAnimation(
                  child: _buildCompanyCard(context, company, index),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedJobsList(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.secondary,
          ),
        ),
      );
    }
    if (_featuredJobs.isEmpty) {
      return Center(
        child: Text(
          'Hiện chưa có cơ hội nào',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount:
            _featuredJobs.length > 4 ? 4 : _featuredJobs.length, // Giới hạn
        itemBuilder: (context, index) {
          final job = _featuredJobs[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 425),
            child: SlideAnimation(
              verticalOffset: 60.0,
              child: FadeInAnimation(child: _buildJobCard(context, job)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedPodcastsList(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.secondary,
          ),
        ),
      );
    }
    if (_featuredPodcasts.isEmpty) {
      return Center(
        child: Text('Podcast sắp ra mắt!', style: theme.textTheme.bodyMedium),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount:
            _featuredPodcasts.length > 2
                ? 2
                : _featuredPodcasts.length, // Giới hạn
        itemBuilder: (context, index) {
          final podcast = _featuredPodcasts[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 70.0,
              child: FadeInAnimation(
                child: _buildPodcastCard(context, podcast),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerSlideshow(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(
          height: 190, // Tăng chiều cao banner
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _bannerItems.length,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemBuilder: (context, index) {
              Map<String, dynamic> banner = _bannerItems[index];
              bool isActive = index == _currentBannerIndex;
              double scale =
                  isActive
                      ? 1.0
                      : 0.92; // Hiệu ứng scale cho banner không active
              double verticalMargin = isActive ? 0 : 10;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutSine,
                transform: Matrix4.identity()..scale(scale),
                margin: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: verticalMargin,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24), // Bo góc lớn hơn
                  gradient: LinearGradient(
                    colors: [
                      banner['color'],
                      banner['endColor'] ?? banner['color'].withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (banner['color'] as Color).withOpacity(0.4),
                      blurRadius: isActive ? 15 : 8,
                      offset: Offset(0, isActive ? 8 : 4),
                    ),
                  ],
                ),
                child: Material(
                  // Thêm Material để có InkWell ripple effect
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: () {
                      if (isLoggedIn) {
                        switch (banner['value']) {
                          case 1:
                            HomePage.goToSearchTab(context);
                            break;
                          case 2:
                            HomePage.goToChatBotTab(context);
                            break;
                          case 3:
                            HomePage.goToCVTab(context);
                            break;
                          case 4:
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        CompanyScreen(idUser: widget.idUser),
                              ),
                            ).then((_) => _onRefresh());
                            break;
                        }
                      } else {
                        _showLoginRequiredDialog();
                      }
                    },
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 20,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  banner['title'],
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  banner['description'],
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.88),
                                    fontSize: 13.5,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Spacer(), // Đẩy nút xuống dưới
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (isLoggedIn) {
                                      switch (banner['value']) {
                                        case 1:
                                          HomePage.goToSearchTab(context);
                                          break;
                                        case 2:
                                          HomePage.goToChatBotTab(context);
                                          break;
                                        case 3:
                                          HomePage.goToCVTab(context);
                                          break;
                                        case 4:
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => CompanyScreen(
                                                    idUser: widget.idUser,
                                                  ),
                                            ),
                                          ).then((_) => _onRefresh());
                                          break;
                                      }
                                    } else {
                                      _showLoginRequiredDialog();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(
                                      0.25,
                                    ),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                    side: BorderSide(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    "Chi Tiết",
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Icon(
                                banner['icon'] as IconData? ??
                                    Icons.interests_rounded,
                                color: Colors.white.withOpacity(0.85),
                                size: 55,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_bannerItems.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              width: _currentBannerIndex == index ? 28 : 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color:
                    _currentBannerIndex == index
                        ? theme
                            .colorScheme
                            .secondary // Màu active nổi bật
                        : theme.colorScheme.onSurface.withOpacity(0.2),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCompanyCard(BuildContext context, Company company, int index) {
    final theme = Theme.of(context);
    // Tạo màu gradient ngẫu nhiên hoặc dựa trên index cho mỗi card
    List<Color> cardGradientColors = [
      Colors.primaries[index % Colors.primaries.length].withOpacity(0.1),
      Colors.accents[(index + 5) % Colors.accents.length].withOpacity(0.05),
    ];
    if (theme.brightness == Brightness.dark) {
      cardGradientColors = [
        Colors.primaries[index % Colors.primaries.length].withOpacity(0.2),
        Colors.accents[(index + 5) % Colors.accents.length].withOpacity(0.15),
      ];
    }

    return Hero(
      // Thêm Hero animation
      tag: 'company_logo_${company.idCompany}',
      child: Container(
        width: 175,
        margin: const EdgeInsets.only(right: 18, bottom: 10, top: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // Gradient nhẹ cho nền card
            colors: cardGradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20), // Bo góc lớn hơn
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: theme.dividerColor.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Material(
          // Để có hiệu ứng ripple
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => CompanyDetailsScreen(
                        company: company,
                        idUser: widget.idUser,
                      ),
                ),
              ).then((_) => _onRefresh());
            },
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 70,
                  width: 70,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16), // Bo góc logo
                    child: Image.network(
                      company.logoCompany ?? '',
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer
                                  .withOpacity(0.4),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: Image.asset("assets/images/logohuit.png"),
                            ),
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  company.companyName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                // Text(
                //   "${company.jobPostings?.length ?? math.Random().nextInt(10) + 1} cơ hội", // Random nếu không có data
                //   style: theme.textTheme.bodySmall?.copyWith(
                //     color: theme.colorScheme.secondary,
                //     fontWeight: FontWeight.w600,
                //   ),
                //   textAlign: TextAlign.center,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, JobPosting job) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3, // Tăng elevation
      shadowColor: theme.shadowColor.withOpacity(isDarkMode ? 0.15 : 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18), // Bo góc lớn hơn
        // side: BorderSide(color: theme.dividerColor.withOpacity(0.3), width: 1), // Có thể bỏ nếu elevation đủ
      ),
      child: InkWell(
        onTap: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => JobDetailScreen(
                    idUser: widget.idUser,
                    idJobPost: job.idJobPost,
                  ),
            ),
          ).then((_) => _onRefresh());
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    // Thêm Hero cho logo
                    tag: 'job_logo_${job.idJobPost}',
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: theme.colorScheme.primaryContainer.withOpacity(
                          0.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child:
                            job.company.logoCompany != null &&
                                    job.company.logoCompany!.isNotEmpty
                                ? Image.network(
                                  job.company.logoCompany!,
                                  fit: BoxFit.contain,
                                  errorBuilder:
                                      (context, error, stackTrace) => Center(
                                        child: Image.asset(
                                          "assets/images/logohuit.png",
                                        ),
                                      ),
                                )
                                : Center(
                                  child: Text(
                                    job.company.companyName
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                      ),
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
                            // Lớn hơn
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            height: 1.2, // Giảm chiều cao dòng nếu quá sát
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          job.company.companyName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(
                              0.75,
                            ),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Icon(Icons.bookmark_border_rounded, color: theme.colorScheme.outline, size: 26) // Bookmark
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildInfoChip(
                    context,
                    Icons.location_city_outlined,
                    FormatUtils.extractDistrictAndCity(job.location),
                    theme.colorScheme.secondary,
                    true,
                  ),
                  _buildInfoChip(
                    context,
                    Icons.monetization_on_outlined,
                    FormatUtils.formatSalary(job.salary ?? 0),
                    theme.colorScheme.tertiary,
                    true,
                  ),
                  _buildInfoChip(
                    context,
                    Icons.business_center_outlined,
                    job.workType,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ),
                  _buildInfoChip(
                    context,
                    Icons.layers_outlined,
                    job.experienceLevel,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPodcastCard(BuildContext context, Podcast podcast) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      elevation: 2,
      shadowColor: theme.shadowColor.withOpacity(0.07),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Material(
        // Để có ripple
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            /* TODO: Play podcast */
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      // Gradient cho thumbnail
                      colors: [
                        theme.colorScheme.secondaryContainer,
                        theme.colorScheme.tertiaryContainer.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.secondary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.graphic_eq_rounded, // Icon khác
                      color: theme.colorScheme.onSecondaryContainer,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        podcast.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Host: ${podcast.host ?? 'HUITERN Team'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(
                            0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Thời lượng: ${FormatUtils.formatDuration(podcast.duration)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.calendar_month_outlined,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            podcast.publishDate != null
                                ? DateFormat(
                                  'dd/MM',
                                ).format(podcast.publishDate!)
                                : 'Mới', // Rút gọn ngày
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  Icons.play_circle_fill_rounded,
                  color: theme.colorScheme.primary,
                  size: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color, [
    bool isHighlighted = false,
  ]) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isHighlighted ? 12 : 10,
        vertical: isHighlighted ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color:
            isHighlighted
                ? color.withOpacity(0.15)
                : theme.dividerColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(
          isHighlighted ? 10 : 20,
        ), // Hình dạng khác nhau
        border:
            isHighlighted
                ? Border.all(color: color.withOpacity(0.4), width: 1)
                : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isHighlighted ? 18 : 15,
            color:
                isHighlighted
                    ? color
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  isHighlighted
                      ? color
                      : theme.colorScheme.onSurfaceVariant.withOpacity(0.9),
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog() {
    // Giữ nguyên dialog này hoặc tùy chỉnh thêm nếu muốn
    // ... (code dialog đã có)
    // Để đơn giản, giữ nguyên dialog cũ
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
              backgroundColor: Theme.of(context).cardColor,
              child: Container(
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.9),
                            Theme.of(context).colorScheme.primary,
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
                              color: Theme.of(
                                context,
                              ).colorScheme.surface.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.lock_person_outlined,
                              color: Theme.of(context).colorScheme.primary,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Yêu cầu đăng nhập',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
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
                            'Để trải nghiệm đầy đủ các tính năng tuyệt vời, vui lòng đăng nhập tài khoản HUITERN của bạn.',
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyLarge?.copyWith(height: 1.4),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
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
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              child: Text(
                                'ĐĂNG NHẬP NGAY',
                                style: Theme.of(
                                  context,
                                ).textTheme.labelLarge?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'ĐỂ SAU',
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
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
}
