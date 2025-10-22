import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/utils/string_utils.dart';
import 'package:job_connect/config/widgets/background_empty_state.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/data/models/job_application_model.dart';
import 'package:job_connect/data/models/job_posting_model.dart';
import 'package:job_connect/data/models/job_saved_model.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:job_connect/features/search/widgets/search_filter_panel.dart';
import 'package:job_connect/features/search/widgets/search_header.dart';
import 'package:job_connect/features/search/widgets/search_job_item_card.dart';
import 'package:job_connect/features/search/widgets/search_job_shimmer.dart';

class SearchPage extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;
  final int? initialTabIndex;

  const SearchPage({
    super.key,
    required this.idUser,
    required this.isLoggedIn,
    this.initialTabIndex,
  });

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool _showClearButton = false;
  final _apiService = ApiService();

  List<JobPostingModel> _jobList = [];
  List<JobPostingModel> _filteredJobs = [];
  List<JobSavedModel> _savedJobs = [];
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
  bool _showFilters = false;
  final Map<String, List<String>> _locationGroups = {};

  late AnimationController _filterPanelController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex ?? 0,
    );

    _tabController.addListener(() {
      if (mounted && !_tabController.indexIsChanging) setState(() {});
    });

    _searchController.addListener(() {
      if (mounted) setState(() => _showClearButton = _searchController.text.isNotEmpty);
      _filterJobs();
    });

    _filterPanelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _initializeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _filterPanelController.dispose();
    super.dispose();
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
            final location = FormatUtils.extractDistrictAndCity(job.location ?? '');
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

          _jobTypes.addAll(_jobList.map((job) => job.workType ?? '').toSet().toList());
          _experienceLevels.addAll(_jobList.map((job) => job.experienceLevel ?? '').toSet().toList());
          _maxSalary = _jobList.fold(0, (max, job) {
            return job.salary != null && job.salary! > max ? job.salary!.toDouble() : max;
          });

          _currentMaxSalary = _maxSalary;
          _filteredJobs = List.from(_jobList);
        }),
        _fetchSavedJobs(),
      ]);
    } catch (e) {
      print("SearchPage _loadAllData: Error loading data - $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    _jobList.clear();
    _savedJobs.clear();
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
      if (mounted && data.isNotEmpty) setState(() => _account = UserModel.fromJson(data.first));
    } catch (e) {
      print('Error fetching account: $e');
    }
  }

  // TODO: Fetch danh sách job posting
  Future<void> _fetchJobs() async {
    try {
      final response = await _apiService.get(endpoint: ApiConstants.jobPostingEndpoint);
      if (!mounted) return;

      _jobList.clear();
      final List<dynamic> jobData = response as List<dynamic>;
      _jobList.addAll(jobData.map((job) => JobPostingModel.fromJson(job as Map<String, dynamic>)).toList());

      _jobList.removeWhere((job) => _appliedJobs.any((applied) => applied.idJobPost == job.idJobPost));
      _jobList.sort((a, b) => b.createdAt!.compareTo(a.createdAt ?? DateTime.now()));
    } catch (e) {
      print('Error fetching jobs: $e');
    }
  }

  Future<void> _fetchSavedJobs() async {
    if (widget.idUser.isEmpty) return;
    try {
      final response = await _apiService.get(endpoint: "${ApiConstants.jobSavedEndpoint}/${widget.idUser}");
      if (!mounted) return;
      _savedJobs.clear();
      _savedJobs.addAll(response.map((job) => JobSavedModel.fromJson(job)));
    } catch (e) {
      print('Error fetching saved jobs: $e');
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

  Future<void> _saveJob(String idJobPost, bool isSaved) async {
    if (!mounted) return;
    final theme = Theme.of(context);

    if (isSaved) {
      try {
        await _apiService.delete(endpoint: "${ApiConstants.jobSavedEndpoint}/$idJobPost/${widget.idUser}");
        _onRefresh();
      } catch (e) {
        _showSnackBar(theme, "Không thể bỏ lưu: ${e.toString()}", theme.colorScheme.error);
      }
    } else {
      try {
        final response = await _apiService.post(
          endpoint: ApiConstants.jobSavedEndpoint,
          body: {"idJobPost": idJobPost, "idUser": widget.idUser},
        );
        if (!mounted) return;

        if (response == 200 || response == 201) {
          _showSnackBar(theme, "Đã lưu công việc!", theme.colorScheme.secondaryContainer);
          _onRefresh();
        } else {
          _showSnackBar(theme, "Không thể lưu! Status: $response", theme.colorScheme.error);
        }
      } catch (e) {
        _showSnackBar(theme, 'Lưu thất bại: ${e.toString()}', theme.colorScheme.error);
      }
    }
  }

  void _showSnackBar(ThemeData theme, String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onError)),
        backgroundColor: bgColor,
      ),
    );
  }

  void _filterJobs() {
    if (!mounted) return;
    final query = StringUtils.removeDiacritics(_searchController.text.toLowerCase());
    setState(() {
      _filteredJobs = _jobList.where((job) {
        final matchesQuery =
            StringUtils.removeDiacritics(job.title!.toLowerCase()).contains(query) ||
            StringUtils.removeDiacritics(job.company!.companyName.toLowerCase()).contains(query);
        final matchesLocation = _selectedLocation == 'Tất cả' ||
            StringUtils.removeDiacritics(FormatUtils.extractDistrictAndCity(job.location ?? '').toLowerCase()) ==
                StringUtils.removeDiacritics(_selectedLocation.toLowerCase());
        final matchesJobType = _selectedJobType == 'Tất cả' ||
            StringUtils.removeDiacritics(job.workType!.toLowerCase()) ==
                StringUtils.removeDiacritics(_selectedJobType.toLowerCase());
        final matchesExperience = _selectedExperience == 'Tất cả' ||
            StringUtils.removeDiacritics(job.experienceLevel!.toLowerCase()) ==
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
    _filterPanelController.reverse();
    setState(() => _showFilters = false);
  }

  void _toggleFilterPanel() {
    setState(() {
      _showFilters = !_showFilters;
      _showFilters ? _filterPanelController.forward() : _filterPanelController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          SearchHeader(
            searchController: _searchController,
            onFilterTap: _toggleFilterPanel,
            tabController: _tabController,
          ),
          Expanded(
            child: Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  children: [
                    _buildJobListView(isFeatured: true, sortByNewest: false),
                    _buildJobListView(isFeatured: false, sortByNewest: true),
                    _buildSavedJobsView(),
                  ],
                ),
                if (_showFilters)
                  FilterPanelWidget(
                    locationGroups: _locationGroups,
                    jobTypes: _jobTypes,
                    experienceLevels: _experienceLevels,
                    onResetFilters: _resetFilters,
                    onApply: ({
                      required location,
                      required jobType,
                      required experience,
                      required minSalary,
                      required maxSalary,
                    }) {
                      setState(() {
                        _selectedLocation = location;
                        _selectedJobType = jobType;
                        _selectedExperience = experience;
                        _currentMinSalary = minSalary;
                        _currentMaxSalary = maxSalary;
                      });
                      _applyFilters();
                    },
                    onClose: _toggleFilterPanel,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobListView({bool isFeatured = false, bool sortByNewest = false}) {
    List<JobPostingModel> jobsToDisplay = List.from(_filteredJobs);

    if (isFeatured) {
      jobsToDisplay.sort((a, b) {
        if (a.isFeatured == 1 && b.isFeatured != 1) return -1;
        if (a.isFeatured != 1 && b.isFeatured == 1) return 1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      jobsToDisplay.retainWhere((j) => j.isFeatured == 1);
    } else if (sortByNewest) {
      jobsToDisplay.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    }

    if (_isLoading && jobsToDisplay.isEmpty) {
      return Center(
        child: SearchJobShimmer()
      );
    }

    if (jobsToDisplay.isEmpty) {
      return BackgroundEmptyState(
        isSearching: _searchController.text.isNotEmpty,
        onRefresh: _onRefresh,
        title: isFeatured ? "Công Việc Nổi Bật" : "Công Việc",
        iconData: Icons.work_off_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Theme.of(context).primaryColor,
      child: AnimationLimiter(
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          itemCount: jobsToDisplay.length,
          itemBuilder: (context, index) {
            final job = jobsToDisplay[index];
            final bool isJobSavedModel = _savedJobs.any((savedJob) => savedJob.idJobPost == job.idJobPost);

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 425),
              child: SlideAnimation(
                verticalOffset: 50.h,
                child: FadeInAnimation(
                  child: SearchJobItemCard(
                    job: job,
                    isSaved: isJobSavedModel,
                    idUser: widget.idUser,
                    onSaveJob: _saveJob,
                    onRefresh: _onRefresh,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSavedJobsView() {
    final savedJobPostsFromFullList = _jobList.where((job) {
      final isActuallySaved = _savedJobs.any((savedJob) => savedJob.idJobPost == job.idJobPost);
      if (!isActuallySaved) return false;

      final query = StringUtils.removeDiacritics(_searchController.text.toLowerCase());
      final matchesQuery = query.isEmpty ||
          StringUtils.removeDiacritics(job.title!.toLowerCase()).contains(query) ||
          StringUtils.removeDiacritics(job.company!.companyName.toLowerCase()).contains(query);

      final matchesLocation = _selectedLocation == 'Tất cả' ||
          StringUtils.removeDiacritics(FormatUtils.extractDistrictAndCity(job.location ?? '').toLowerCase()) ==
              StringUtils.removeDiacritics(_selectedLocation.toLowerCase());

      final matchesJobType = _selectedJobType == 'Tất cả' ||
          StringUtils.removeDiacritics(job.workType!.toLowerCase()) ==
              StringUtils.removeDiacritics(_selectedJobType.toLowerCase());

      final matchesExperience = _selectedExperience == 'Tất cả' ||
          StringUtils.removeDiacritics(job.experienceLevel!.toLowerCase()) ==
              StringUtils.removeDiacritics(_selectedExperience.toLowerCase());

      final matchesSalary =
          job.salary == null || (job.salary! >= _currentMinSalary && job.salary! <= _currentMaxSalary);

      return matchesQuery && matchesLocation && matchesJobType && matchesExperience && matchesSalary;
    }).toList();

    savedJobPostsFromFullList.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

    if (_isLoading && savedJobPostsFromFullList.isEmpty) {
      return Center(
        child: SearchJobShimmer()
      );
    }

    if (savedJobPostsFromFullList.isEmpty) {
      return BackgroundEmptyState(
        isSearching: _searchController.text.isNotEmpty,
        onRefresh: _onRefresh,
        title: "Công Việc Đã Lưu",
        iconData: Icons.bookmark_add_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Theme.of(context).primaryColor,
      child: AnimationLimiter(
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          itemCount: savedJobPostsFromFullList.length,
          itemBuilder: (context, index) {
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
                    onSaveJob: _saveJob,
                    onRefresh: _onRefresh,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
