import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/widgets/custom_gradient_button.dart';
import 'package:job_connect/config/widgets/login_required_dialog.dart';
import 'package:job_connect/features/home/view_model/job_saved_view_model.dart';
import 'package:job_connect/features/home/widgets/home/home_shimmer.dart';
import 'package:job_connect/features/navigation/screens/navigation_page.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/company/model/company_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/notifications/model/notification_model.dart';
import 'package:job_connect/features/home/model/podcast_model.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/home/widgets/home/banner_slide_show.dart';
import 'package:job_connect/features/home/widgets/home/featured_companies_list.dart';
import 'package:job_connect/features/home/widgets/home/featured_jobs_list.dart';
import 'package:job_connect/features/home/widgets/podcast/featured_podcasts_list.dart';
import 'package:job_connect/features/home/widgets/home/section_header.dart';
import 'package:job_connect/features/home/widgets/home/wave_clipper.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;

  const HomeScreen({
    super.key,
    this.isLoggedIn = false,
    required this.idUser,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final _apiService = ApiService();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  final PageController _bannerController = PageController(viewportFraction: 0.9);
  Timer? _bannerTimer;

  UserModel? _user;
  List<CompanyModel> _featuredCompanies = [];
  List<JobPostingModel> _featuredJobs = [];
  List<PodcastModel> _featuredPodcasts = [];
  List<Map<String, dynamic>> _bannerItems = [];
  int unreadNotifications = 0;
  bool _isLoading = true;
  int _currentBannerIndex = 0;

  bool get isLoggedIn => widget.isLoggedIn;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    final jobSavedVM = Provider.of<JobSavedViewModel>(context, listen: false);
    jobSavedVM.fetchSavedJobsByUser(widget.idUser);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadAllData();
    _bannerItems = AppStrings.bannerItems;
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startBannerTimer();
        _fadeController.forward();
      });
    }
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchAccount(),
      _fetchFeaturedCompanies(),
      _fetchFeaturedJobs(),
      _fetchFeaturedPodcasts(),
      _fetchUnreadNotificationsCount(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _onRefresh() async {
    _featuredCompanies.clear();
    _featuredJobs.clear();
    _featuredPodcasts.clear();
    unreadNotifications = 0;
    _user = null;
    await _loadAllData();
    _fadeController.reset();
    if (mounted) _fadeController.forward();
  }

  Future<void> _fetchAccount() async {
    if (widget.idUser.isEmpty) {
      _user = null;
      return;
    }
    try {
      final responseData = await _apiService.get(
        endpoint: '${ApiConstants.userEndpoint}/${widget.idUser}',
      );
      if (responseData != null) {
        if (responseData is List && responseData.isNotEmpty) {
          if (responseData.first is Map<String, dynamic>) {
            _user = UserModel.fromJson(responseData.first as Map<String, dynamic>);
          }
        } else if (responseData is Map<String, dynamic>) {
          _user = UserModel.fromJson(responseData);
        }
      }
    } catch (_) {
      _user = null;
    }
  }

  Future<void> _fetchFeaturedCompanies() async {
    try {
      final responseData = await _apiService.get(
        endpoint: ApiConstants.companiesFeaturedEndpoint,
      );
      if (responseData is List) {
        _featuredCompanies = responseData
            .whereType<Map<String, dynamic>>()
            .map((e) => CompanyModel.fromJson(e))
            .toList();
      }
    } catch (_) {
      _featuredCompanies = [];
    }
  }

  Future<void> _fetchFeaturedJobs() async {
    try {
      final responseData = await _apiService.get(
        endpoint: ApiConstants.jobPostingFeaturedEndpoint,
      );
      if (responseData is List) {
        _featuredJobs = responseData
            .whereType<Map<String, dynamic>>()
            .map((e) => JobPostingModel.fromJson(e))
            .toList();
      }
    } catch (_) {
      _featuredJobs = [];
    }
  }

  Future<void> _fetchFeaturedPodcasts() async {
    try {
      final responseData = await _apiService.get(
        endpoint: ApiConstants.podcastFeaturedEndpoint,
      );
      if (responseData is List) {
        _featuredPodcasts = responseData
            .whereType<Map<String, dynamic>>()
            .map((e) => PodcastModel.fromJson(e))
            .toList();
      }
    } catch (_) {
      _featuredPodcasts = [];
    }
  }

  Future<void> _fetchUnreadNotificationsCount() async {
    if (widget.idUser.isEmpty) {
      unreadNotifications = 0;
      return;
    }
    try {
      final responseData = await _apiService.get(
        endpoint: "${ApiConstants.notificationEndpoint}/${widget.idUser}",
      );
      if (responseData is List) {
        unreadNotifications = responseData
            .whereType<Map<String, dynamic>>()
            .map((e) => NotificationModel.fromJson(e))
            .where((n) => n.isRead == 0)
            .length;
      }
    } catch (_) {
      unreadNotifications = 0;
    }
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _bannerItems.isEmpty) return;
      if (_bannerController.hasClients) {
        _currentBannerIndex = (_currentBannerIndex + 1) % _bannerItems.length;
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutQuint,
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
    super.build(context);
    final theme = Theme.of(context);
     if (_isLoading) {
      return HomeShimmer();
    }
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _loadAllData,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 80.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
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
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        SizedBox(height: 8.h),
                        Text(
                          _user?.userName ?? "Khám Phá Ngay",
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        // TODO: BANNER
                        BannerSlideshow(
                          banners: _bannerItems,
                          isLoggedIn: widget.isLoggedIn,
                          idUser: widget.idUser,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24.h),
                      CustomGradientButton(
                        title: "Tìm Việc Quanh Đây",
                        icon: Icons.radar_outlined,
                        gradientColors: [
                          theme.colorScheme.secondary,
                          theme.colorScheme.tertiary.withOpacity(0.8),
                        ],
                        onTap: () {
                          if (!isLoggedIn) {
                            LoginRequiredDialog.show(context, isLoggedIn: false);
                            return;
                          }
                          context.go(
                            '/home/near-job',
                            extra: {
                              'isLoggedIn': widget.isLoggedIn,
                              'idUser': widget.idUser
                            },
                          );
                          _onRefresh();
                        },
                      ),
                      SizedBox(height: 40.h),
                      SectionHeader(
                        title: "Doanh nghiệp nổi bật",
                        onSeeAll: () {
                          context.push('/home/company', extra: {"idUser": widget.idUser});
                        },
                      ),
                      SizedBox(height: 16.h),
                      FeaturedCompaniesList(companies: _featuredCompanies),
                      SizedBox(height: 16.h),
                      SectionHeader(
                        title: "Công việc nổi bật",
                        onSeeAll: () => NavigationPage.goToSearchTab(context)
                      ),
                      SizedBox(height: 16.h),
                      FeaturedJobsList(jobs: _featuredJobs, idUser: widget.idUser),
                      SizedBox(height: 16.h),

                      SectionHeader(
                        title: "Công việc thời vụ",
                        onSeeAll: () => context.push('/social/job-board'),
                      ),
                      SizedBox(height: 16.h),
                      FeaturedPodcastsList(podcasts: _featuredPodcasts),
                      SizedBox(height: 16.h),

                      SectionHeader(
                        title: "Bạn có thể biết",
                        onSeeAll: () => context.push('/social/job-board'),
                      ),
                      SizedBox(height: 16.h),
                      FeaturedPodcastsList(podcasts: _featuredPodcasts),
                      SizedBox(height: 16.h),
                      // SectionHeader(
                      //   title: "Podcast thư giãn",
                      //   onSeeAll: () {
                      //     context.push("/home/podcast");
                      //   },
                      // ),
                      // SizedBox(height: 16.h),
                      // FeaturedPodcastsList(podcasts: _featuredPodcasts),
                      // SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
