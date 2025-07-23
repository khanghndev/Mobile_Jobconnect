import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import 'package:job_connect/core/config/constant/api_constants.dart';
import 'package:job_connect/core/data/models/account_model.dart';
import 'package:job_connect/core/data/models/job_application_model.dart';
import 'package:job_connect/core/data/models/job_posting_model.dart';
import 'package:job_connect/core/data/models/job_saved_model.dart';
import 'package:job_connect/core/data/services/api.dart';
import 'package:job_connect/core/config/utils/format.dart';
import 'package:job_connect/features/job/screens/apply_job_screen.dart';
import 'package:job_connect/features/job/screens/job_detail_screen.dart';
import 'dart:async';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart'; // For list animations
import 'dart:ui'; // For ImageFilter

class SearchPage extends StatefulWidget {
  final void Function(RefreshCallback refreshCallback)? registerRefreshCallback;
  final bool isLoggedIn;
  final String idUser;
  final int? initialTabIndex;

  const SearchPage({
    super.key,
    required this.idUser,
    required this.isLoggedIn,
    this.registerRefreshCallback,
    this.initialTabIndex,
  });

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool _showClearButton = false;
  final _apiService = ApiService(baseUrl: ApiConstants.baseUrl);
  List<JobPosting> _jobList = [];
  List<JobPosting> _filteredJobs = [];
  List<JobSaved> _savedJobs = [];
  List<JobApplication> _appliedJobs = [];
  Account? _account;
  bool _isLoading = false;
  final List<String> _locations = ['Tất cả'];
  final List<String> _jobTypes = ['Tất cả'];
  final List<String> _experienceLevels = ['Tất cả'];
  String _selectedLocation = 'Tất cả';
  String _selectedJobType = 'Tất cả';
  String _selectedExperience = 'Tất cả';
  double _minSalary = 0;
  double _maxSalary = 5000000;
  double _currentMinSalary = 0;
  double _currentMaxSalary = 5000000;
  bool _showFilters = false;
  final Map<String, List<String>> _locationGroups = {};

  // Animation controller cho panel filter
  late AnimationController _filterPanelController;
  late Animation<Offset> _filterPanelAnimation;

  @override
  void initState() {
    super.initState();
    widget.registerRefreshCallback?.call(_onRefresh);

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex ?? 0,
    );
    _tabController.addListener(() {
      if (mounted && !_tabController.indexIsChanging) {
        setState(() {}); // Rebuild để cập nhật UI nếu cần
      }
    });

    _searchController.addListener(() {
      if (mounted) {
        setState(() => _showClearButton = _searchController.text.isNotEmpty);
      }
      _filterJobs();
    });

    _filterPanelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _filterPanelAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // Bắt đầu từ dưới
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _filterPanelController,
        curve: Curves.easeOutQuint,
      ),
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
          if (mounted) {
            // Nhóm địa điểm theo thành phố
            for (var job in _jobList) {
              final location = FormatUtils.extractDistrictAndCity(job.location);
              if (location.contains('TP.') || location.contains('Thành phố')) {
                final parts = location.split(',');
                if (parts.length >= 2) {
                  final city = parts[1].trim();
                  final district = parts[0].trim();

                  if (!_locationGroups.containsKey(city)) {
                    _locationGroups[city] = [];
                  }
                  if (!_locationGroups[city]!.contains(district)) {
                    _locationGroups[city]!.add(district);
                  }
                }
              }
            }

            // Sắp xếp các quận trong mỗi thành phố
            _locationGroups.forEach((city, districts) {
              districts.sort();
            });

            _jobTypes.addAll(
              _jobList.map((job) => job.workType).toSet().toList(),
            );
            _experienceLevels.addAll(
              _jobList.map((job) => job.experienceLevel).toSet().toList(),
            );
            _maxSalary = _jobList.fold(
              0,
              (max, job) =>
                  job.salary != null && job.salary! > max
                      ? job.salary!.toDouble()
                      : max,
            );
            _currentMaxSalary = _maxSalary;
            _filteredJobs = List.from(_jobList);
          }
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
    // setState(() => _isLoading = false); // Đã có trong _loadAllData
  }

  Future<void> _fetchAccount() async {
    try {
      final data = await _apiService.get(
        '${ApiConstants.userEndpoint}/${widget.idUser}',
      );
      if (mounted && data.isNotEmpty) {
        setState(() => _account = Account.fromJson(data.first));
      }
    } catch (e) {
      print('Error fetching account: $e');
    }
  }

  Future<void> _fetchJobs() async {
    try {
      final response = await _apiService.get(ApiConstants.jobPostingEndpoint);
      if (mounted) {
        _jobList.clear();
        _jobList.addAll(response.map((job) => JobPosting.fromJson(job)));
        _jobList.removeWhere(
          (job) => _appliedJobs.any(
            (appliedJob) => appliedJob.idJobPost == job.idJobPost,
          ),
        ); // Chỉ lấy những công việc đang hoạt động và nổi bật
        _jobList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (e) {
      print('Error fetching jobs: $e');
    }
  }

  Future<void> _fetchSavedJobs() async {
    if (widget.idUser.isEmpty) return;
    try {
      final response = await _apiService.get(
        "${ApiConstants.jobSavedEndpoint}/${widget.idUser}",
      );
      if (mounted) {
        // setState(() { // Không cần setState ở đây nữa
        _savedJobs.clear();
        _savedJobs.addAll(response.map((job) => JobSaved.fromJson(job)));
        // });
      }
    } catch (e) {
      print('Error fetching saved jobs: $e');
    }
  }

  Future<void> _fetchApplicationJob() async {
    if (widget.idUser.isEmpty) return;
    try {
      final response = await _apiService.get(
        "${ApiConstants.jobApplicationEndpoint}/${widget.idUser}",
      );
      if (mounted) {
        _appliedJobs.clear();
        _appliedJobs.addAll(
          response.map((job) => JobApplication.fromJson(job)),
        );
      }
    } catch (e) {
      print('Error fetching saved jobs: $e');
    }
  }

  String _removeDiacritics(String input) {
    final diacriticsMap = {
      'á': 'a',
      'à': 'a',
      'ả': 'a',
      'ã': 'a',
      'ạ': 'a',
      'ă': 'a',
      'ắ': 'a',
      'ằ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'ặ': 'a',
      'â': 'a',
      'ấ': 'a',
      'ầ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ậ': 'a',
      'é': 'e',
      'è': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ẹ': 'e',
      'ê': 'e',
      'ế': 'e',
      'ề': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ệ': 'e',
      'í': 'i',
      'ì': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ị': 'i',
      'ó': 'o',
      'ò': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ọ': 'o',
      'ô': 'o',
      'ố': 'o',
      'ồ': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ộ': 'o',
      'ơ': 'o',
      'ớ': 'o',
      'ờ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ợ': 'o',
      'ú': 'u',
      'ù': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ụ': 'u',
      'ư': 'u',
      'ứ': 'u',
      'ừ': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ự': 'u',
      'ý': 'y',
      'ỳ': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'ỵ': 'y',
      'đ': 'd',
      'Á': 'A',
      'À': 'A',
      'Ả': 'A',
      'Ã': 'A',
      'Ạ': 'A',
      'Ă': 'A',
      'Ắ': 'A',
      'Ằ': 'A',
      'Ẳ': 'A',
      'Ẵ': 'A',
      'Ặ': 'A',
      'Â': 'A',
      'Ấ': 'A',
      'Ầ': 'A',
      'Ẩ': 'A',
      'Ẫ': 'A',
      'Ậ': 'A',
      'É': 'E',
      'È': 'E',
      'Ẻ': 'E',
      'Ẽ': 'E',
      'Ẹ': 'E',
      'Ê': 'E',
      'Ế': 'E',
      'Ề': 'E',
      'Ể': 'E',
      'Ễ': 'E',
      'Ệ': 'E',
      'Í': 'I',
      'Ì': 'I',
      'Ỉ': 'I',
      'Ĩ': 'I',
      'Ị': 'I',
      'Ó': 'O',
      'Ò': 'O',
      'Ỏ': 'O',
      'Õ': 'O',
      'Ọ': 'O',
      'Ô': 'O',
      'Ố': 'O',
      'Ồ': 'O',
      'Ổ': 'O',
      'Ỗ': 'O',
      'Ộ': 'O',
      'Ơ': 'O',
      'Ớ': 'O',
      'Ờ': 'O',
      'Ở': 'O',
      'Ỡ': 'O',
      'Ợ': 'O',
      'Ú': 'U',
      'Ù': 'U',
      'Ủ': 'U',
      'Ũ': 'U',
      'Ụ': 'U',
      'Ư': 'U',
      'Ứ': 'U',
      'Ừ': 'U',
      'Ử': 'U',
      'Ữ': 'U',
      'Ự': 'U',
      'Ý': 'Y',
      'Ỳ': 'Y',
      'Ỷ': 'Y',
      'Ỹ': 'Y',
      'Ỵ': 'Y',
      'Đ': 'D',
    };
    return input.split('').map((char) => diacriticsMap[char] ?? char).join();
  }

  Future<void> _saveJob(String idJobPost, bool isSaved) async {
    if (!mounted) return;
    final theme = Theme.of(context);
    // ... (logic save/unsave job giữ nguyên)
    // Chỉ cần đảm bảo _onRefresh() được gọi để cập nhật UI
    if (isSaved) {
      try {
        await _apiService.delete(
          "${ApiConstants.jobSaveJobPostdEndpoint}/$idJobPost/${widget.idUser}",
        );
        _onRefresh();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Không thể bỏ lưu: ${e.toString()}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onError,
                ),
              ),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      }
    } else {
      try {
        final response = await _apiService.post(
          ApiConstants.jobSavedPostEndpoint,
          {"idJobPost": idJobPost, "idUser": widget.idUser},
        );
        if (mounted) {
          if (response == 200 || response == 201) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Đã lưu công việc!",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                backgroundColor: theme.colorScheme.secondaryContainer,
              ),
            );
            _onRefresh();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Không thể lưu! Status: $response",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onError,
                  ),
                ),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lưu thất bại: ${e.toString()}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onError,
                ),
              ),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _filterJobs() {
    if (!mounted) return;
    final query = _removeDiacritics(_searchController.text.toLowerCase());
    setState(() {
      _filteredJobs =
          _jobList.where((job) {
            final matchesQuery =
                _removeDiacritics(job.title.toLowerCase()).contains(query) ||
                _removeDiacritics(
                  job.company.companyName.toLowerCase(),
                ).contains(query);
            final matchesLocation =
                _selectedLocation == 'Tất cả' ||
                _removeDiacritics(
                      FormatUtils.extractDistrictAndCity(
                        job.location,
                      ).toLowerCase(),
                    ) ==
                    _removeDiacritics(_selectedLocation.toLowerCase());
            final matchesJobType =
                _selectedJobType == 'Tất cả' ||
                _removeDiacritics(job.workType.toLowerCase()) ==
                    _removeDiacritics(_selectedJobType.toLowerCase());
            final matchesExperience =
                _selectedExperience == 'Tất cả' ||
                _removeDiacritics(job.experienceLevel.toLowerCase()) ==
                    _removeDiacritics(_selectedExperience.toLowerCase());

            // Kiểm tra mức lương
            final matchesSalary =
                job.salary == null ||
                (job.salary! >= _currentMinSalary &&
                    job.salary! <= _currentMaxSalary);

            return matchesQuery &&
                matchesLocation &&
                matchesJobType &&
                matchesExperience &&
                matchesSalary;
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
    _filterPanelController.reverse(); // Đóng panel filter
    setState(() => _showFilters = false);
  }

  void _toggleFilterPanel() {
    setState(() {
      _showFilters = !_showFilters;
      if (_showFilters) {
        _filterPanelController.forward();
      } else {
        _filterPanelController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      // Thêm Scaffold để có thể dùng AppBar nếu cần sau này
      backgroundColor: theme.colorScheme.background,
      body: Column(
        children: [
          _buildHeader(theme, isDarkMode), // Tách header ra widget riêng
          Expanded(
            child: Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  children: [
                    _buildJobListView(isFeatured: true, sortByNewest: false),
                    _buildJobListView(isFeatured: false, sortByNewest: true),
                    _buildSavedJobsView(),
                  ],
                ),
                // Panel filter sẽ được hiển thị trên cùng
                if (_showFilters)
                  _buildFiltersPanelOverlay(theme), // Panel filter mới
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 0,
      ), // Thêm padding top cho status bar
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors:
              isDarkMode
                  ? [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withOpacity(0.8),
                  ]
                  : [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.85),
                  ],
          stops: const [0.3, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Khám Phá Việc Làm',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hàng ngàn việc làm đang chờ bạn.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // Có thể thêm icon hoặc avatar ở đây nếu muốn
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Material(
                    // Thêm Material để SearchBar có thể hiển thị shadow đúng cách
                    elevation: 3.0, // Tăng elevation
                    shadowColor: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16), // Bo góc lớn hơn
                    child: SearchBar(
                      controller: _searchController,
                      onSubmitted: (value) => _filterJobs(),
                      trailing: [
                        if (_showClearButton)
                          IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              color: theme.iconTheme.color?.withOpacity(0.7),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _filterJobs();
                            },
                          ),
                      ],
                      hintText: "Tên công việc",
                      hintStyle: WidgetStateProperty.all(
                        theme.textTheme.bodyLarge?.copyWith(
                          color: theme.hintColor.withOpacity(0.8),
                        ),
                      ),
                      backgroundColor: WidgetStateProperty.all(theme.cardColor),
                      elevation: WidgetStateProperty.all(
                        0,
                      ), // Đã có Material xử lý elevation
                      padding: WidgetStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      ),
                      leading: Icon(
                        Icons.search_rounded,
                        color: theme.colorScheme.primary,
                        size: 26,
                      ),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      textStyle: WidgetStateProperty.all(
                        theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Material(
                  // Thêm Material cho nút filter
                  elevation: 3.0,
                  shadowColor: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  color: theme.colorScheme.secondary, // Màu nền cho nút filter
                  child: InkWell(
                    // InkWell để có hiệu ứng chạm
                    onTap: _toggleFilterPanel,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(15), // Tăng padding
                      child: Icon(
                        Icons.filter_list_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12), // Giảm khoảng cách trước TabBar
          Theme(
            // Custom theme cho TabBar
            data: theme.copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              tabBarTheme: TabBarThemeData(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.75),
                indicatorSize: TabBarIndicatorSize.label,
                indicator: UnderlineTabIndicator(
                  borderSide: const BorderSide(color: Colors.white, width: 3.0),
                  insets: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ), // Thu hẹp indicator
                ),
                labelStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
                unselectedLabelStyle: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: "NỔI BẬT"),
                Tab(text: "MỚI NHẤT"),
                Tab(text: "ĐÃ LƯU"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobListView({
    bool isFeatured = false,
    bool sortByNewest = false,
  }) {
    List<JobPosting> jobsToDisplay = List.from(_filteredJobs);
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
      // Hiển thị loading nếu đang tải và chưa có job
      return const Center(child: CircularProgressIndicator());
    }

    if (jobsToDisplay.isEmpty) {
      return _buildEmptyState(
        isFeatured ? 'Không có công việc nổi bật' : 'Không tìm thấy công việc',
        isFeatured
            ? 'Hãy thử tìm kiếm hoặc xem các tab khác.'
            : 'Hãy thử thay đổi từ khóa hoặc bộ lọc của bạn.',
        Icons.work_off_outlined,
      );
    }

    return RefreshIndicator(
      // Bọc ListView trong RefreshIndicator
      onRefresh: _onRefresh,
      color: Theme.of(context).primaryColor,
      child: AnimationLimiter(
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.only(
            top: 16,
            bottom: 16,
            left: 12,
            right: 12,
          ), // Thêm padding
          itemCount: jobsToDisplay.length,
          itemBuilder: (context, index) {
            final job = jobsToDisplay[index];
            final bool isJobSaved = _savedJobs.any(
              (savedJob) => savedJob.idJobPost == job.idJobPost,
            );
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 425),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: _buildJobCard(job, isJobSaved)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSavedJobsView() {
    final savedJobPostsFromFullList =
        _jobList.where((job) {
          final isActuallySaved = _savedJobs.any(
            (savedJob) => savedJob.idJobPost == job.idJobPost,
          );
          if (!isActuallySaved) return false;
          final query = _removeDiacritics(_searchController.text.toLowerCase());
          final matchesQuery =
              query.isEmpty ||
              _removeDiacritics(job.title.toLowerCase()).contains(query) ||
              _removeDiacritics(
                job.company.companyName.toLowerCase(),
              ).contains(query);
          final matchesLocation =
              _selectedLocation == 'Tất cả' ||
              _removeDiacritics(
                    FormatUtils.extractDistrictAndCity(
                      job.location,
                    ).toLowerCase(),
                  ) ==
                  _removeDiacritics(_selectedLocation.toLowerCase());
          final matchesJobType =
              _selectedJobType == 'Tất cả' ||
              _removeDiacritics(job.workType.toLowerCase()) ==
                  _removeDiacritics(_selectedJobType.toLowerCase());
          final matchesExperience =
              _selectedExperience == 'Tất cả' ||
              _removeDiacritics(job.experienceLevel.toLowerCase()) ==
                  _removeDiacritics(_selectedExperience.toLowerCase());
          final matchesSalary =
              job.salary == null ||
              (job.salary! >= _currentMinSalary &&
                  job.salary! <= _currentMaxSalary);
          return matchesQuery &&
              matchesLocation &&
              matchesJobType &&
              matchesExperience &&
              matchesSalary;
        }).toList();
    savedJobPostsFromFullList.sort(
      (a, b) => b.createdAt.compareTo(a.createdAt),
    );

    if (_isLoading && savedJobPostsFromFullList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (savedJobPostsFromFullList.isEmpty) {
      return _buildEmptyState(
        'Chưa có công việc nào được lưu',
        _searchController.text.isNotEmpty ||
                _selectedLocation != 'Tất cả' ||
                _selectedJobType != 'Tất cả' ||
                _selectedExperience != 'Tất cả' ||
                _currentMinSalary != _minSalary ||
                _currentMaxSalary != _maxSalary
            ? 'Không có công việc đã lưu nào khớp với bộ lọc của bạn.'
            : 'Hãy bắt đầu lưu những công việc bạn quan tâm nhé!',
        Icons.bookmark_add_outlined,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Theme.of(context).primaryColor,
      child: AnimationLimiter(
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.only(
            top: 16,
            bottom: 16,
            left: 12,
            right: 12,
          ),
          itemCount: savedJobPostsFromFullList.length,
          itemBuilder: (context, index) {
            final job = savedJobPostsFromFullList[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 425),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(child: _buildJobCard(job, true)),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: theme.hintColor.withOpacity(0.4)),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.hintColor.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.hintColor.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(JobPosting job, bool isSaved) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final String displaySalary = FormatUtils.formatSalary(job.salary ?? 0);

    return Card(
      margin: const EdgeInsets.only(bottom: 18), // Tăng margin dưới
      elevation: 3, // Tăng elevation
      shadowColor: theme.shadowColor.withOpacity(isDarkMode ? 0.15 : 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18), // Bo góc lớn hơn
        // side: BorderSide(color: theme.dividerColor.withOpacity(0.2), width: 0.8), // Có thể bỏ nếu elevation đủ
      ),
      child: InkWell(
        onTap: () {
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
          padding: const EdgeInsets.all(18), // Tăng padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    // Thêm Hero cho logo
                    tag:
                        'search_job_logo_${job.idJobPost}', // Tag khác với trang home
                    child: Container(
                      width: 60,
                      height: 60, // Tăng kích thước logo
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(
                          0.15,
                        ),
                        borderRadius: BorderRadius.circular(14), // Bo góc logo
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(1, 1),
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
                                      (context, error, stackTrace) => Icon(
                                        Icons.business_center_rounded,
                                        color: theme.colorScheme.primary,
                                        size: 30,
                                      ),
                                )
                                : Icon(
                                  _getIconForJob(job.title),
                                  color: theme.colorScheme.primary,
                                  size: 30,
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (job.isFeatured == 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(bottom: 7),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                // Gradient cho tag Premium
                                colors: [
                                  Colors.amber.shade600,
                                  Colors.orange.shade400,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'NỔI BẬT',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        Text(
                          job.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          job.company.companyName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded, // Icon tròn trịa hơn
                      color:
                          isSaved
                              ? theme.colorScheme.primary
                              : theme.iconTheme.color?.withOpacity(0.6),
                      size: 28, // Tăng kích thước
                    ),
                    onPressed:
                        () async => await _saveJob(job.idJobPost, isSaved),
                    padding: const EdgeInsets.all(4), // Tăng vùng chạm
                    constraints: const BoxConstraints(),
                    splashRadius: 24,
                  ),
                ],
              ),
              const SizedBox(height: 18), // Tăng khoảng cách
              Wrap(
                // Sử dụng Wrap cho các chip thông tin
                spacing: 10, // Khoảng cách ngang giữa các chip
                runSpacing: 10, // Khoảng cách dọc giữa các dòng chip
                children: [
                  _buildInfoChip(
                    Icons.location_on_rounded,
                    FormatUtils.extractDistrictAndCity(job.location),
                    theme.colorScheme.secondary,
                  ),
                  _buildInfoChip(
                    Icons.attach_money_rounded,
                    displaySalary,
                    theme.colorScheme.tertiary,
                  ),
                  _buildInfoChip(
                    Icons.event_available_rounded,
                    FormatUtils.formattedDateTime(job.createdAt).toString(),
                    theme.colorScheme.primary.withOpacity(0.8),
                  ),
                  _buildInfoChip(
                    Icons.work_outline_rounded,
                    job.workType,
                    theme.colorScheme.onSurfaceVariant,
                  ),
                  _buildInfoChip(
                    Icons.layers_rounded,
                    job.experienceLevel,
                    theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      // Thêm icon cho nút
                      onPressed: () {
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
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: theme.colorScheme.primary.withOpacity(0.7),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ), // Bo góc lớn hơn
                        padding: const EdgeInsets.symmetric(
                          vertical: 13,
                        ), // Tăng padding
                      ),
                      icon: Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(
                        'Chi Tiết',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ApplyJobScreen(
                                  jobId: job.idJobPost,
                                  jobTitle: job.title,
                                  companyName: job.company.companyName,
                                  idUser: widget.idUser,
                                ),
                          ),
                        ).then((_) => _onRefresh());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor:
                            Colors.white, // Set màu trắng cho cả icon & text
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      icon: const Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: Colors.white, // Đảm bảo icon là trắng
                      ),
                      label: const Text(
                        'Ứng Tuyển',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Đảm bảo text là trắng
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ), // Tăng padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.12), // Màu nền nhẹ nhàng hơn
        borderRadius: BorderRadius.circular(20), // Bo tròn hơn
        // border: Border.all(color: color.withOpacity(0.3), width: 0.8) // Có thể bỏ border
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color), // Kích thước icon
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ), // Đậm hơn
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForJob(String title) {
    title = title.toLowerCase();
    if (title.contains('flutter') ||
        title.contains('mobile') ||
        title.contains('android') ||
        title.contains('ios')) {
      return Icons.smartphone_rounded;
    }
    if (title.contains('backend') ||
        title.contains('server') ||
        title.contains('api')) {
      return Icons.dns_rounded;
    }
    if (title.contains('frontend') ||
        title.contains('ui') ||
        title.contains('ux') ||
        title.contains('web')) {
      return Icons.web_rounded;
    }
    if (title.contains('data') ||
        title.contains('ai') ||
        title.contains('machine learning')) {
      return Icons.analytics_rounded;
    }
    if (title.contains('design') || title.contains('graphic')) {
      return Icons.palette_rounded;
    }
    if (title.contains('marketing') || title.contains('sale')) {
      return Icons.campaign_rounded;
    }
    if (title.contains('manager') || title.contains('lead')) {
      return Icons.supervisor_account_rounded;
    }
    return Icons.work_outline_rounded; // Icon mặc định
  }

  Widget _buildFiltersPanelOverlay(ThemeData theme) {
    // Lớp phủ mờ phía sau panel
    return Stack(
      children: [
        GestureDetector(
          onTap: _toggleFilterPanel, // Đóng khi chạm ra ngoài
          child: BackdropFilter(
            // Hiệu ứng blur
            filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
        ),
        SlideTransition(
          // Animation cho panel trượt lên
          position: _filterPanelAnimation,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: _buildFiltersPanel(theme), // Nội dung panel
          ),
        ),
      ],
    );
  }

  Widget _buildFiltersPanel(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    return Material(
      // Material để có thể dùng elevation và shape
      elevation: 16, // Tăng elevation
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28), // Bo góc lớn hơn
          topRight: Radius.circular(28),
        ),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75, // Tăng chiều cao
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            Padding(
              // Header của panel
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bộ Lọc Nâng Cao',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.iconTheme.color,
                      size: 26,
                    ),
                    onPressed: _toggleFilterPanel,
                    splashRadius: 24,
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: theme.dividerColor.withOpacity(0.5),
            ), // Divider
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLocationFilter(theme),
                    const SizedBox(height: 12),
                    Divider(color: theme.dividerColor.withOpacity(0.3)),
                    _buildFilterSection(
                      'Loại công việc',
                      _jobTypes,
                      _selectedJobType,
                      (value) => setState(() => _selectedJobType = value),
                    ),
                    const SizedBox(height: 12),
                    Divider(color: theme.dividerColor.withOpacity(0.3)),
                    _buildFilterSection(
                      'Kinh nghiệm',
                      _experienceLevels,
                      _selectedExperience,
                      (value) => setState(() => _selectedExperience = value),
                    ),
                    const SizedBox(height: 12),
                    Divider(color: theme.dividerColor.withOpacity(0.3)),
                    _buildSalaryFilter(theme),
                  ],
                ),
              ),
            ),
            Container(
              // Footer với các nút
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
                border: Border(
                  top: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetFilters,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.7),
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Đặt Lại',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Áp Dụng',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildLocationFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          child: Text(
            'Địa điểm',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ChoiceChip(
              label: Text(
                'Tất cả',
                style: TextStyle(
                  fontWeight:
                      _selectedLocation == 'Tất cả'
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
              selected: _selectedLocation == 'Tất cả',
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedLocation = 'Tất cả');
                }
              },
              backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(
                0.5,
              ),
              selectedColor: theme.colorScheme.primaryContainer,
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color:
                    _selectedLocation == 'Tất cả'
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: BorderSide(
                  color:
                      _selectedLocation == 'Tất cả'
                          ? theme.colorScheme.primary.withOpacity(0.7)
                          : theme.dividerColor.withOpacity(0.7),
                  width: _selectedLocation == 'Tất cả' ? 1.5 : 1.0,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              elevation: _selectedLocation == 'Tất cả' ? 2 : 0,
              showCheckmark: false,
            ),
            ..._locationGroups.entries.map((entry) {
              final city = entry.key;
              final districts = entry.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      city,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        districts.map((district) {
                          final fullLocation = '$district, $city';
                          final isSelected = _selectedLocation == fullLocation;
                          return ChoiceChip(
                            label: Text(
                              district,
                              style: TextStyle(
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(
                                  () => _selectedLocation = fullLocation,
                                );
                              }
                            },
                            backgroundColor: theme.colorScheme.surfaceVariant
                                .withOpacity(0.5),
                            selectedColor: theme.colorScheme.primaryContainer,
                            labelStyle: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  isSelected
                                      ? theme.colorScheme.onPrimaryContainer
                                      : theme.colorScheme.onSurfaceVariant,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                              side: BorderSide(
                                color:
                                    isSelected
                                        ? theme.colorScheme.primary.withOpacity(
                                          0.7,
                                        )
                                        : theme.dividerColor.withOpacity(0.7),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            elevation: isSelected ? 2 : 0,
                            showCheckmark: false,
                          );
                        }).toList(),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String selectedValue,
    Function(String) onChanged,
  ) {
    final theme = Theme.of(context);
    final validOptions =
        options.where((option) => option.isNotEmpty).toSet().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 16), // Tăng padding
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Wrap(
          spacing: 10, // Tăng spacing
          runSpacing: 10,
          children:
              validOptions.map((option) {
                final isSelected = selectedValue == option;
                return ChoiceChip(
                  label: Text(
                    option,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) onChanged(option);
                  },
                  backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(
                    0.5,
                  ),
                  selectedColor: theme.colorScheme.primaryContainer,
                  labelStyle: theme.textTheme.bodyMedium?.copyWith(
                    color:
                        isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // Bo tròn hơn
                    side: BorderSide(
                      color:
                          isSelected
                              ? theme.colorScheme.primary.withOpacity(0.7)
                              : theme.dividerColor.withOpacity(0.7),
                      width:
                          isSelected ? 1.5 : 1.0, // Border đậm hơn khi selected
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ), // Tăng padding
                  elevation: isSelected ? 2 : 0, // Thêm elevation khi selected
                  showCheckmark: false, // Bỏ checkmark mặc định
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildSalaryFilter(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 16),
          child: Text(
            'Mức lương',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        RangeSlider(
          values: RangeValues(_currentMinSalary, _currentMaxSalary),
          min: _minSalary,
          max: _maxSalary,
          divisions: 100,
          activeColor: theme.colorScheme.primary,
          inactiveColor: theme.colorScheme.primary.withOpacity(0.2),
          labels: RangeLabels(
            _currentMinSalary == 0
                ? 'Lương thỏa thuận'
                : '${FormatUtils.formatSalary(_currentMinSalary.toInt())}',
            FormatUtils.formatSalary(_currentMaxSalary.toInt()),
          ),
          onChanged: (RangeValues values) {
            setState(() {
              _currentMinSalary = values.start;
              _currentMaxSalary = values.end;
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _currentMinSalary == 0
                    ? 'Lương thỏa thuận'
                    : FormatUtils.formatSalary(_currentMinSalary.toInt()),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                FormatUtils.formatSalary(_currentMaxSalary.toInt()),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
