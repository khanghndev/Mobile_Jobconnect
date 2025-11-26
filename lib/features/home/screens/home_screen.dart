import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/widgets/custom_button_border.dart';
import 'package:job_connect/config/widgets/custom_gradient_button.dart';
import 'package:job_connect/config/widgets/login_required_dialog.dart';
import 'package:job_connect/features/company/viewmodel/company_view_model.dart';
import 'package:job_connect/features/home/view_model/job_saved_view_model.dart';
import 'package:job_connect/features/home/widgets/home/featured_friends_list.dart';
import 'package:job_connect/features/home/widgets/home/featured_job_board_list.dart';
import 'package:job_connect/features/home/widgets/home/featured_popular_location_list.dart';
import 'package:job_connect/features/home/widgets/home/featured_skill_trending_list.dart';
import 'package:job_connect/features/home/widgets/home/home_shimmer.dart';
import 'package:job_connect/features/job/view_model/job_posting_view_model.dart';
import 'package:job_connect/features/job/view_model/job_recommendation_view_model.dart';
import 'package:job_connect/features/mini_social/model/social_connection_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_connection_view_model.dart';
import 'package:job_connect/features/navigation/screens/navigation_page.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/home/widgets/home/banner_slide_show.dart';
import 'package:job_connect/features/home/widgets/home/featured_companies_list.dart';
import 'package:job_connect/features/home/widgets/home/featured_jobs_list.dart';
import 'package:job_connect/features/home/widgets/home/section_header.dart';
import 'package:job_connect/features/home/widgets/home/wave_clipper.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
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
  List<JobPostingModel> _featuredJobs = [];
  List<Map<String, dynamic>> _bannerItems = [];
  int unreadNotifications = 0;
  bool _isLoading = true;
  int _currentBannerIndex = 0;

  bool get isLoggedIn => widget.isLoggedIn;

  late JobPostingViewModel _jobPostingViewModel;
  late JobSavedViewModel _jobSavedViewModel;
  late UserViewModel _userViewModel;
  late JobRecommendationViewModel _jobRecommendationViewModel;
  late CompanyViewModel _companyViewModel;
  late SocialConnectionViewModel _connVm;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _jobSavedViewModel = context.read<JobSavedViewModel>();
    _jobPostingViewModel = context.read<JobPostingViewModel>();
    _userViewModel = context.read<UserViewModel>();
    _jobRecommendationViewModel = context.read<JobRecommendationViewModel>();
    _companyViewModel = context.read<CompanyViewModel>();
    _connVm = context.read<SocialConnectionViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) async{
      await _jobSavedViewModel.fetchSavedJobsByUser(widget.idUser);
      await _jobPostingViewModel.fetchJobPostingsExcludeFullTime();
      await _userViewModel.fetchAllUsers();
      await _companyViewModel.getFeaturedCompanies();
      await _jobRecommendationViewModel.loadHomepageJobs();
      await _jobRecommendationViewModel.loadPersonalizedJobs();
      await _jobRecommendationViewModel.loadPopularLocations();
      await _jobRecommendationViewModel.loadTrendingSkills();
      await _jobRecommendationViewModel.createSmartSchedule(userId: widget.idUser);
      await _connVm.getFriends(userId: widget.idUser);
      await _connVm.getSentRequests(userId: widget.idUser);
      await _connVm.getRequests(userId: widget.idUser);
    });
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
      _fetchFeaturedJobs(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _onRefresh() async {
  try {
    // Reset local state
    setState(() {
      _featuredJobs.clear();
      unreadNotifications = 0;
      _user = null;
    });

    // Load lại toàn bộ dữ liệu của màn Home
    await _loadAllData();

    // Load lại ViewModels quan trọng
    await Future.wait([
      _jobSavedViewModel.fetchSavedJobsByUser(widget.idUser),
      _jobPostingViewModel.fetchJobPostingsExcludeFullTime(),
      _userViewModel.fetchAllUsers(),
      _companyViewModel.getFeaturedCompanies(),
      _jobRecommendationViewModel.createSmartSchedule(userId: widget.idUser),
      _jobRecommendationViewModel.loadHomepageJobs(),
      _jobRecommendationViewModel.loadPersonalizedJobs(),
      _jobRecommendationViewModel.loadPopularLocations(),
      _jobRecommendationViewModel.loadTrendingSkills(),
    ]);

    // Restart animation
    _fadeController.reset();
    if (mounted) {
      _fadeController.forward();
    }
  } catch (e) {
    debugPrint("❌ Refresh error: $e");
  }
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

  Future<void> _sendFriendRequest(UserModel targetUser) async {
    final _connVm = context.read<SocialConnectionViewModel>();

    await _connVm.sendRequest(
      request: SocialConnectionRequest(
        fromUserId: widget.idUser,
        toUserId: targetUser.idUser,
      ),
    );

    await _connVm.getSentRequests(userId: widget.idUser);
  }

  Future<void> _unfriend(UserModel targetUser) async {
    final _connVm = context.read<SocialConnectionViewModel>();
    await _connVm.unfriend(userId1: widget.idUser, userId2: targetUser.idUser);

    // Refresh tab nếu đang ở tab "Bạn bè"
    await _connVm.getFriends(userId: widget.idUser);
  }

  Future<void> _acceptRequest(UserModel user) async {
    final _connVm = context.read<SocialConnectionViewModel>();
    await _connVm.acceptRequest(
      request: SocialConnectionRequest(
        fromUserId: widget.idUser,
        toUserId: user.idUser,
      ),
    );
    await _connVm.getRequests(userId: widget.idUser); // cập nhật tab lời mời
    await _connVm.getFriends(userId: widget.idUser);  // cập nhật bạn bè
  }

  Future<void> _rejectRequest(UserModel user) async {
    final _connVm = context.read<SocialConnectionViewModel>();
    await _connVm.rejectRequest(
      request: SocialConnectionRequest(
        fromUserId:  widget.idUser,
        toUserId: user.idUser,
      ),
    );
  }

  Future<void> _cancelFriendRequest(UserModel targetUser) async {
    final _connVm = context.read<SocialConnectionViewModel>();

    // Tạo request object
    final request = SocialConnectionRequest(
      fromUserId: widget.idUser,
      toUserId: targetUser.idUser,
    );

    await _connVm.cancelRequest(request: request);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final jobVM = context.watch<JobPostingViewModel>();
    final userVM = context.watch<UserViewModel>();
    final companyVM = context.watch<CompanyViewModel>();
    final jobRecommentVM = context.watch<JobRecommendationViewModel>();

     if (_isLoading) {
      return HomeShimmer();
    }
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
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
                          theme.colorScheme.tertiary.withValues(alpha: 0.8),
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
                      FeaturedCompaniesList(
                        companies: companyVM.featuredCompanies,
                        idUser: widget.idUser
                      ),

                      SectionHeader(
                        title: "Công việc nổi bật",
                        onSeeAll: () => NavigationPage.goToSearchTab(context)
                      ),
                      FeaturedJobsList(jobs: _featuredJobs, idUser: widget.idUser,),

                      SectionHeader(
                        title: "Công việc thời vụ",
                        onSeeAll: () => context.push(
                          '/social/job-board',
                          extra: {"idUser": widget.idUser}
                        ),
                      ),
                      FeaturedSeasonalJobsList(
                        jobs: jobVM.jobPostings,
                        idUser: widget.idUser
                      ),

                      SectionHeader(
                        title: "Việc làm cá nhân hóa",
                        onSeeAll: () => NavigationPage.goToSearchTab(context)
                      ),
                      FeaturedJobsList(jobs: jobRecommentVM.personalizedJobs, idUser: widget.idUser),

                      SectionHeader(
                        title: "Việc làm gợi ý",
                        onSeeAll: () => NavigationPage.goToSearchTab(context)
                      ),
                      FeaturedJobsList(jobs: jobRecommentVM.homepageJobs, idUser: widget.idUser),
                      SizedBox(height: 16.h),
                      SectionHeader(
                        title: "Kỹ năng đang thịnh hành",
                        isSeeAll: false
                      ),
                      SizedBox(height: 16.h),
                      FeaturedSkillTrendingList(skills: jobRecommentVM.trendingSkills),
                      SectionHeader(
                        title: "Địa điểm thu hút",
                        onSeeAll: () => context.push('/social/job-board', extra: {"idUser": widget.idUser}),
                      ),
                      FeaturedPopularLocationList(
                        locations: jobRecommentVM.popularLocations,
                        onLocationTap: (location) {
                          context.go(
                            '/home/near-job',
                            extra: {
                              'isLoggedIn': widget.isLoggedIn,
                              'idUser': widget.idUser,
                              'initialLocation': location,
                            },
                          );
                        },
                      ),
                      
                      SectionHeader(
                        title: "Bạn có thể biết",
                        onSeeAll: () => context.push('/social/search',extra: {'idUser' : widget.idUser}),
                      ),
                      FeaturedFriendsList(
                        users: userVM.users.where((user) => user.idUser != widget.idUser).toList(),
                        getFriendStatus: (user) {
                          return {
                            'isFriend': _connVm.friends.any((f) => f.id == user.idUser),
                            'isRequestSent': _connVm.sentRequests.any((r) => r.idUser2 == user.idUser),
                            'isRequestReceived': _connVm.requests.any((r) => r.idUser1 == user.idUser),
                          };
                        },
                        onSendRequest: (user) async {
                          await _sendFriendRequest(user);
                          setState(() {}); 
                        },
                        onCancelRequest: (user) async {
                          await _cancelFriendRequest(user);
                          setState(() {});
                        },
                        onAcceptRequest: (user) async {
                          await _acceptRequest(user);
                          setState(() {});
                        },
                        onRejectRequest: (user) async {
                          await _rejectRequest(user);
                          setState(() {});
                        },
                        onUnfriend: (user) async {
                          await _unfriend(user);
                          setState(() {});
                        },
                      ),

                      SizedBox(height:32.h),

                      // SectionHeader(
                      //   title: "Podcast thư giãn",
                      //   onSeeAll: () {
                      //     context.push("/home/podcast");
                      //   },
                      // ),
                      // SizedBox(height: 16.h),
                      // FeaturedPodcastsList(podcasts: _featuredPodcasts),
                      // SizedBox(height: 16.h),

                      CustomButtonBorder(
                        title: "Thử ngày lịch làm việc thông minh",
                        icon: Icons.smart_button_rounded,
                        color: theme.primaryColor,
                        onPressed: () => context.push('/home/smart-shedule', extra: {"userId": widget.idUser}),
                      ),
                      SizedBox(height: 32.h),
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
