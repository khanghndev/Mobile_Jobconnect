import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/utils/string_utils.dart';
import 'package:job_connect/config/widgets/background_empty_state.dart';
import 'package:job_connect/features/home/view_model/job_saved_view_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/home/model/job_saved_model.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:job_connect/features/search/widgets/search_filter_panel.dart';
import 'package:job_connect/features/search/widgets/search_header.dart';
import 'package:job_connect/features/search/widgets/search_job_item_card.dart';
import 'package:job_connect/features/search/widgets/search_job_shimmer.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;
  final int? initialTabIndex;

  const SearchScreen({
    super.key,
    required this.idUser,
    required this.isLoggedIn,
    this.initialTabIndex,
  });

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late JobSavedViewModel _jobSavedVM;
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool _showClearButton = false;
  final _apiService = ApiService();
  final ScrollController _mainScrollController = ScrollController();

  List<JobPostingModel> _jobList = [];
  List<JobPostingModel> _filteredJobs = [];
  List<JobApplicationModel> _appliedJobs = [];
  UserModel? _account;
  bool _isLoading = false;

  final List<String> _locations = ['Tất cả'];
  final List<String> _jobTypes = ['Tất cả'];
  final List<String> _experienceLevels = ['Tất cả'];
  String _selectedLocation = 'Tất cả';
  String _selectedJobType = 'Tất cả';
  String _selectedExperience = 'Tất cả';
  final double _minSalary = 0;
  double _maxSalary = 5000000;
  double _currentMinSalary = 0;
  double _currentMaxSalary = 5000000;
  final Map<String, List<String>> _locationGroups = {};

  @override
  void initState() {
    super.initState();
    _jobSavedVM = context.read<JobSavedViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jobSavedVM.fetchSavedJobsByUser(widget.idUser);
    });
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex ?? 0,
    );

    _tabController.addListener(() {
      if (mounted && !_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    _searchController.addListener(() {
      if (mounted) setState(() => _showClearButton = _searchController.text.isNotEmpty);
      _filterJobs();
    });

    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _mainScrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    if (_mainScrollController.hasClients) {
      _mainScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void setTab(int index) {
    if (index >= 0 && index < _tabController.length) {
      _tabController.animateTo(index);
    }
  }
  Future<void> _initializeData() async {
    await _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    _locations.retainWhere((item) => item == 'Tất cả');
    _jobTypes.retainWhere((item) => item == 'Tất cả');
    _experienceLevels.retainWhere((item) => item == 'Tất cả');
    _locationGroups.clear();

    try {
      await Future.wait([
        _fetchAccount(),
        _fetchApplicationJob(),
        _fetchJobs().then((_) {
          if (!mounted) return;
          for (var job in _jobList) {
            final location = FormatUtils.extractDistrictAndCity(job.location);
            if (location.contains('TP.') || location.contains('Thành phố')) {
              final parts = location.split(',');
              if (parts.length >= 2) {
                final city = parts[1].trim();
                final district = parts[0].trim();

                _locationGroups.putIfAbsent(city, () => []);
                if (!_locationGroups[city]!.contains(district)) {
                  _locationGroups[city]!.add(district);
                }
              }
            }
          }

          _locationGroups.forEach((city, districts) => districts.sort());

          _jobTypes.addAll(_jobList.map((job) => job.workType).toSet().toList());
          _experienceLevels.addAll(_jobList.map((job) => job.experienceLevel).toSet().toList());
          _maxSalary = _jobList.fold(0, (max, job) {
            return job.salary != null && job.salary! > max ? job.salary!.toDouble() : max;
          });

          _currentMaxSalary = _maxSalary;
          _filteredJobs = List.from(_jobList);
        }),
      ]);
    } catch (e) {
      print("SearchScreen _loadAllData: Error loading data - $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    _jobList.clear();
    _selectedLocation = 'Tất cả';
    _selectedJobType = 'Tất cả';
    _selectedExperience = 'Tất cả';
    _currentMinSalary = _minSalary;
    _currentMaxSalary = _maxSalary;
    _searchController.clear();
    await _loadAllData();
  }

  Future<void> _fetchAccount() async {
    try {
      final data = await _apiService.get(endpoint: '${ApiConstants.userEndpoint}/${widget.idUser}');
      if (mounted && data.isNotEmpty) setState(() => _account = UserModel.fromJson(data));
    } catch (e) {
      print('Error fetching account: $e');
    }
  }

  //   Fetch danh sách job posting
  Future<void> _fetchJobs() async {
    try {
      final response = await _apiService.get(endpoint: ApiConstants.jobPostingEndpoint);
      if (!mounted) return;

      _jobList.clear();
      final List<dynamic> jobData = response as List<dynamic>;
      _jobList.addAll(jobData.map((job) => JobPostingModel.fromJson(job)).toList());

      _jobList.removeWhere((job) => _appliedJobs.any((applied) => applied.idJobPost == job.idJobPost));
      _jobList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      print('Error fetching jobs: $e');
    }
  }

  Future<void> _fetchApplicationJob() async {
    if (widget.idUser.isEmpty) return;
    try {
      final response = await _apiService.get(endpoint: "${ApiConstants.jobApplicationEndpoint}/${widget.idUser}");
      if (!mounted) return;
      _appliedJobs.clear();
      _appliedJobs.addAll(response.map((job) => JobApplicationModel.fromJson(job)));
    } catch (e) {
      print('Error fetching applied jobs: $e');
    }
  }

  Future<void> _onSaveJob(String idJobPost, bool isSaved) async {
    if (isSaved) {
      await _jobSavedVM.deleteSavedJob(idJobPost, widget.idUser);
      _showSnackBar( "Đã bỏ lưu công việc", BackgroundColors.backgroundInfoPrimary);
    } else {
      final jobToSave = JobSavedModel(idJobPost: idJobPost, idUser: widget.idUser);
      await _jobSavedVM.saveJob(jobToSave);
      _showSnackBar( "Đã lưu công việc", BackgroundColors.backgroundSuccessPrimary);
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    SnackbarApp.show(
      context,
      message: message,
      backgroundColor: bgColor,
    );
  }

  void _filterJobs() {
    if (!mounted) return;
    final query = StringUtils.removeDiacritics(_searchController.text.toLowerCase());
    setState(() {
      _filteredJobs = _jobList.where((job) {
        final matchesQuery =
            StringUtils.removeDiacritics(job.title.toLowerCase()).contains(query) ||
            StringUtils.removeDiacritics(job.company!.companyName.toLowerCase()).contains(query);
        final matchesLocation = _selectedLocation == 'Tất cả' ||
            StringUtils.removeDiacritics(FormatUtils.extractDistrictAndCity(job.location).toLowerCase()) ==
                StringUtils.removeDiacritics(_selectedLocation.toLowerCase());
        final matchesJobType = _selectedJobType == 'Tất cả' ||
            StringUtils.removeDiacritics(job.workType.toLowerCase()) ==
                StringUtils.removeDiacritics(_selectedJobType.toLowerCase());
        final matchesExperience = _selectedExperience == 'Tất cả' ||
            StringUtils.removeDiacritics(job.experienceLevel.toLowerCase()) ==
                StringUtils.removeDiacritics(_selectedExperience.toLowerCase());
        final matchesSalary = job.salary == null ||
            (job.salary! >= _currentMinSalary && job.salary! <= _currentMaxSalary);

        return matchesQuery && matchesLocation && matchesJobType && matchesExperience && matchesSalary;
      }).toList();
    });
  }

  void _resetFilters() {
    if (!mounted) return;
    setState(() {
      _selectedLocation = 'Tất cả';
      _selectedJobType = 'Tất cả';
      _selectedExperience = 'Tất cả';
      _currentMinSalary = _minSalary;
      _currentMaxSalary = _maxSalary;
      _filterJobs();
    });
  }

  void _applyFilters() {
    if (!mounted) return;
    _filterJobs();
  }

  void _toggleFilterPanel() {
    FilterPanelWidget.show(
      context,
      locationGroups: _locationGroups,
      jobTypes: _jobTypes,
      experienceLevels: _experienceLevels,
      selectedLocation: _selectedLocation,
      selectedJobType: _selectedJobType,
      selectedExperience: _selectedExperience,
      currentMinSalary: _currentMinSalary,
      currentMaxSalary: _currentMaxSalary,
      maxSalary: _maxSalary,
      onApply: ({
        required location,
        required jobType,
        required experience,
        required minSalary,
        required maxSalary,
      }) {
        if (!mounted) return;
        setState(() {
          _selectedLocation = location;
          _selectedJobType = jobType;
          _selectedExperience = experience;
          _currentMinSalary = minSalary;
          _currentMaxSalary = maxSalary;
        });
        _applyFilters();
      },
      onResetFilters: _resetFilters,
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override

  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _scrollToTop,
      //   backgroundColor: theme.colorScheme.primary,
      //   foregroundColor: theme.colorScheme.onPrimary,
      //   elevation: 4,
      //   child: Icon(Icons.arrow_upward_rounded, size: 28.sp),
      // ),
      body: CustomScrollView(
        controller: _mainScrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: SearchHeader(
              searchController: _searchController,
              onFilterTap: _toggleFilterPanel,
              tabController: _tabController,
            ),
          ),
          _buildSliverContent(),
        ],
      ),
    );
  }

  Widget _buildSliverContent() {
    final currentIndex = _tabController.index;
    
    if (currentIndex == 0) {
      return _buildSliverJobList(isFeatured: true, sortByNewest: false);
    } else if (currentIndex == 1) {
      return _buildSliverJobList(isFeatured: false, sortByNewest: true);
    } else {
      return _buildSliverSavedJobsList();
    }
  }

  Widget _buildSliverJobList({bool isFeatured = false, bool sortByNewest = false}) {
    List<JobPostingModel> jobsToDisplay = List.from(_filteredJobs);

    if (isFeatured) {
      jobsToDisplay.sort((a, b) {
        if (a.isFeatured == 1 && b.isFeatured != 1) return -1;
        if (a.isFeatured != 1 && b.isFeatured == 1) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
      jobsToDisplay.retainWhere((j) => j.isFeatured == 1);
    } else if (sortByNewest) {
      jobsToDisplay.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    if (_isLoading && jobsToDisplay.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: SearchJobShimmer()
        ),
      );
    }

    if (jobsToDisplay.isEmpty) {
      return SliverFillRemaining(
        child: BackgroundEmptyState(
          isSearching: _searchController.text.isNotEmpty,
          onRefresh: _onRefresh,
          title: isFeatured ? "Công Việc Nổi Bật" : "Công Việc",
          iconData: Icons.work_off_outlined,
        ),
      );
    }

    return Consumer<JobSavedViewModel>(
      builder: (context, jobSavedVM, _) {
        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final job = jobsToDisplay[index];
                final isSaved = jobSavedVM.savedJobs.any((s) => s.idJobPost == job.idJobPost);
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 425),
                  child: SlideAnimation(
                    verticalOffset: 50.h,
                    child: FadeInAnimation(
                      child: SearchJobItemCard(
                        job: job,
                        isSaved: isSaved,
                        idUser: widget.idUser,
                        onSaveJob: _onSaveJob,
                        onRefresh: _onRefresh,
                      ),
                    ),
                  ),
                );
              },
              childCount: jobsToDisplay.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSliverSavedJobsList() {
    final savedJobPostsFromFullList = _jobList.where((job) {
      final isActuallySaved = _jobSavedVM.savedJobs.any((savedJob) => savedJob.idJobPost == job.idJobPost);
      if (!isActuallySaved) return false;

      final query = StringUtils.removeDiacritics(_searchController.text.toLowerCase());
      final matchesQuery = query.isEmpty ||
          StringUtils.removeDiacritics(job.title.toLowerCase()).contains(query) ||
          StringUtils.removeDiacritics(job.company!.companyName.toLowerCase()).contains(query);

      final matchesLocation = _selectedLocation == 'Tất cả' ||
          StringUtils.removeDiacritics(FormatUtils.extractDistrictAndCity(job.location ).toLowerCase()) ==
              StringUtils.removeDiacritics(_selectedLocation.toLowerCase());

      final matchesJobType = _selectedJobType == 'Tất cả' ||
          StringUtils.removeDiacritics(job.workType.toLowerCase()) ==
              StringUtils.removeDiacritics(_selectedJobType.toLowerCase());

      final matchesExperience = _selectedExperience == 'Tất cả' ||
          StringUtils.removeDiacritics(job.experienceLevel.toLowerCase()) ==
              StringUtils.removeDiacritics(_selectedExperience.toLowerCase());

      final matchesSalary =
          job.salary == null || (job.salary! >= _currentMinSalary && job.salary! <= _currentMaxSalary);

      return matchesQuery && matchesLocation && matchesJobType && matchesExperience && matchesSalary;
    }).toList();

    savedJobPostsFromFullList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (_isLoading && savedJobPostsFromFullList.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: SearchJobShimmer()
        ),
      );
    }

    if (savedJobPostsFromFullList.isEmpty) {
      return SliverFillRemaining(
        child: BackgroundEmptyState(
          isSearching: _searchController.text.isNotEmpty,
          onRefresh: _onRefresh,
          title: "Công Việc Đã Lưu",
          iconData: Icons.bookmark_add_outlined,
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final job = savedJobPostsFromFullList[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 425),
              child: SlideAnimation(
                verticalOffset: 50.h,
                child: FadeInAnimation(
                  child: SearchJobItemCard(
                    job: job,
                    isSaved: true,
                    idUser: widget.idUser,
                    onSaveJob: _onSaveJob,
                    onRefresh: _onRefresh,
                  ),
                ),
              ),
            );
          },
          childCount: savedJobPostsFromFullList.length,
        ),
      ),
    );
  }
}
