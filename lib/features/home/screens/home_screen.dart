import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/widgets/custom_gradient_button.dart';
import 'package:job_connect/config/widgets/login_required_dialog.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/company/model/company_model.dart';
import 'package:job_connect/data/models/job_posting_model.dart';
import 'package:job_connect/features/notifications/model/notification_model.dart';
import 'package:job_connect/features/home/model/podcast_model.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/home/widgets/home/banner_slide_show.dart';
import 'package:job_connect/features/home/widgets/home/featured_companies_list.dart';
import 'package:job_connect/features/home/widgets/home/featured_jobs_list.dart';
import 'package:job_connect/features/home/widgets/home/featured_podcasts_list.dart';
import 'package:job_connect/features/home/widgets/home/section_header.dart';
import 'package:job_connect/features/home/widgets/home/wave_clipper.dart';
import 'package:job_connect/features/home/widgets/shared/gooey_fab_menu.dart';
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
  final _apiService = ApiService( );
  bool get isLoggedIn => widget.isLoggedIn;
  UserModel? _user;
  List<CompanyModel> _featuredCompanies = [];
  List<JobPostingModel> _featuredJobs = [];
  List<PodcastModel> _featuredPodcasts = [];
  List<Map<String, dynamic>> _bannerItems = [];
  int unreadNotifications = 0;

  bool _isLoading = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation = CurvedAnimation(
    parent: _fadeController,
    curve: Curves.easeIn,
  );

  @override
  bool get wantKeepAlive => true;

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
  }

  Future<void> _initializeData() async {
    await _loadAllData();
    _bannerItems = AppStrings.bannerItems;
    
    if (mounted) {
      _onStartBannerTimer();
      _fadeController.forward(); 
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
    _user = null;
    _fadeController.reset(); // Reset animation
    await _loadAllData();
    if (mounted) _fadeController.forward(); // Restart animation
  }

  Future<void> _fetchAccount() async {
    if (widget.idUser.isEmpty) {
      _user = null;
      return;
    }
    try {
      final dynamic responseData = await _apiService.get(
        endpoint: '${ApiConstants.userEndpoint}/${widget.idUser}',
      );
      if (responseData != null) {
        if (responseData is List && responseData.isNotEmpty) {
          if (responseData.first is Map<String, dynamic>) {
            _user = UserModel.fromJson(
              responseData.first as Map<String, dynamic>,
            );
          }
        } else if (responseData is Map<String, dynamic>) {
          _user = UserModel.fromJson(responseData);
        }
      }
    } catch (e) {
      debugPrint('Error fetching account: $e');
      _user = null;
    }
  }

  Future<void> _fetchFeaturedCompanies() async {
    try {
      final dynamic responseData = await _apiService.get(
        endpoint:  ApiConstants.companiesFeaturedEndpoint,
      );
      if (responseData != null && responseData is List) {
        _featuredCompanies =
            responseData
                .where((item) => item is Map<String, dynamic>)
                .map((item) => CompanyModel.fromJson(item as Map<String, dynamic>))
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
        endpoint: ApiConstants.jobPostingFeaturedEndpoint,
      );
      if (responseData != null && responseData is List) {
        _featuredJobs =
            responseData
                .where((item) => item is Map<String, dynamic>)
                .map(
                  (item) => JobPostingModel.fromJson(item as Map<String, dynamic>),
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
        endpoint: ApiConstants.podcastFeaturedEndpoint,
      );
      if (responseData != null && responseData is List) {
        _featuredPodcasts =
            responseData
                .where((item) => item is Map<String, dynamic>)
                .map((item) => PodcastModel.fromJson(item as Map<String, dynamic>))
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
       endpoint:  "${ApiConstants.notificationEndpoint}/${widget.idUser}",
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
  ); 
  Timer? _bannerTimer;

  void _onStartBannerTimer() {
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

  String _onGetGreeting() {
    // TODO: Lấy lời chào theo thời gian
    final hour = DateTime.now().hour;
    if (hour < 12) return "Chào buổi sáng!";
    if (hour < 17) return "Buổi chiều năng động!";
    return "Buổi tối thư giãn!";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    debugPrint("✅✅idUser: ${widget.idUser}✅✅");
    return Scaffold (
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
                        // TODO: LỜI CHÀO
                        Text(
                          _onGetGreeting(),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        // TODO: TÊN NGƯỜI DÙNG
                        Text(
                          _user?.userName ?? "Khám Phá Ngay", 
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 24.h),
                        // TODO: BANNER SLIDER
                        BannerSlideshow(
                          banners: _bannerItems,
                          isLoggedIn: widget.isLoggedIn,
                        )
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
                      // TODO: NÚT TÌM VIỆC QUANH ĐÂY
                      CustomGradientButton(
                        title: "Tìm Việc Quanh Đây",
                        icon: Icons.radar_outlined,
                        gradientColors: [
                          Theme.of(context).colorScheme.secondary,
                          Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.8),
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
                              'idUser': widget.idUser,
                            }
                          );
                          _onRefresh();
                        },
                      ),
                      SizedBox(height: 40.h),
          
                      // TODO: DANH SÁCH CÔNG TY NỔI BẬT
                      SectionHeader(
                        title: "Doanh nghiệp nổi bật", 
                        onSeeAll: (){
                          context.push(
                            '/home/company', 
                            extra: {
                              "idUser" : ""
                            }
                          );
                        }
                      ),
                      SizedBox(height: 16.h),
                      FeaturedCompaniesList(
                        companies: _featuredCompanies,
                      ),
                      SizedBox(height: 16.h),
          
                      // TODO: DANH SÁCH CÔNG VIỆC NỔI BẬT
                      SectionHeader(
                        title: "Công việc nổi bật", 
                        onSeeAll: (){
                          context.push(
                            '/home/search', 
                            extra: {
                              'isLoggedIn': widget.isLoggedIn,
                              'idUser': widget.idUser,
                              'initialTabIndex' : 0,
                            }
                          );
                        }
                      ),
                      SizedBox(height: 16.h),
                      FeaturedJobsList(
                        jobs: _featuredJobs, 
                        idUser: widget.idUser,
                      ),
                      SizedBox(height: 16.h),
          
                      // TODO: DANH SÁCH PODCAST NỔI BẬT
                      SectionHeader(
                        title: "Podcast thư giãn", 
                        onSeeAll: (){
                          context.push("/home/podcast");
                        }
                      ),
                      SizedBox(height: 16.h),
                      FeaturedPodcastsList(
                        podcasts: _featuredPodcasts,
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
       floatingActionButton: GooeyFABMenu(
        items: [
          GooeyFABItem(
            icon: Icons.add,
            color: Colors.red,
            onTap: () => context.push("/home/podcast"),
          ),
          GooeyFABItem(
            icon: Icons.local_fire_department,
            color: Colors.green,
            onTap: () => context.push("/home/podcast"),
          ),
          GooeyFABItem(
            icon: Icons.post_add,
            color: Colors.pink,
            onTap: () => context.push("/home/podcast"),
          ),
        ]
      ),
    );
  }
}