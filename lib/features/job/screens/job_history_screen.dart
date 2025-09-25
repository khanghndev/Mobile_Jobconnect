import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/data/models/job_application_model.dart';
import 'package:job_connect/data/services/api.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/config/utils/status_helper.dart';
import 'package:job_connect/features/home/screens/home_page.dart';
import 'package:job_connect/features/job/screens/job_application_detail_screen.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

const String _closedGroupFilterKey = 'closed_group_filter';

class JobHistoryScreen extends StatefulWidget {
  final String idUser;
  const JobHistoryScreen({super.key, required this.idUser});

  @override
  JobHistoryScreenState createState() => JobHistoryScreenState();
}

class JobHistoryScreenState extends State<JobHistoryScreen>
    with TickerProviderStateMixin {
  final _apiService = ApiService(baseUrl: ApiConstants.baseUrl);
  List<JobApplication> _allJobApplications = [];
  List<JobApplication> _filteredJobApplications = [];
  bool _isLoading = true;
  String? _selectedStatusFilter;

  late AnimationController _listAnimationController;
  late AnimationController
  _filterBarAnimationController; // Animation cho thanh filter
  late Animation<Offset> _filterBarSlideAnimation;
  late Animation<double> _filterBarFadeAnimation;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _filterBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterBarSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _filterBarAnimationController,
        curve: Curves.easeOut,
      ),
    );
    _filterBarFadeAnimation = CurvedAnimation(
      parent: _filterBarAnimationController,
      curve: Curves.easeInOut,
    );

    _initializeData();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _filterBarAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadAllData();
    if (mounted) {
      _listAnimationController.forward();
      _filterBarAnimationController.forward(); // Chạy animation cho filter bar
    }
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get(
        "${ApiConstants.jobApplicationEndpoint}/${widget.idUser}",
      );
      if (mounted) {
        _allJobApplications =
            response
                .map<JobApplication>(
                  (jobJson) => JobApplication.fromJson(jobJson),
                )
                .toList();
        _allJobApplications.sort(
          (a, b) => b.submittedAt.compareTo(a.submittedAt),
        );
        _applyFilter();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải lịch sử: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    if (_selectedStatusFilter == null) {
      _filteredJobApplications = List.from(_allJobApplications);
    } else if (_selectedStatusFilter == _closedGroupFilterKey) {
      _filteredJobApplications =
          _allJobApplications
              .where(
                (app) =>
                    app.applicationStatus == AppStatus.rejected ||
                    app.applicationStatus == AppStatus.viewed ||
                    app.applicationStatus == AppStatus.interview,
              )
              .toList();
    } else {
      _filteredJobApplications =
          _allJobApplications
              .where((app) => app.applicationStatus == _selectedStatusFilter)
              .toList();
    }
  }

  Future<void> _onRefresh() async {
    _listAnimationController.reset();
    _filterBarAnimationController.reset();
    _selectedStatusFilter = null;
    await _loadAllData();
    if (mounted) {
      _listAnimationController.forward();
      _filterBarAnimationController.forward();
    }
  }

  void _handleFilterSelection(String? statusKey) {
    setState(() {
      if (_selectedStatusFilter == statusKey && statusKey != null) {
        _selectedStatusFilter = null;
      } else {
        _selectedStatusFilter = statusKey;
      }
      _listAnimationController.reset();
      _applyFilter();
      _listAnimationController.forward();
    });
  }

  String _getFilterDisplayName(ThemeData theme) {
    if (_selectedStatusFilter == null) return 'Tất Cả Ứng Tuyển';
    if (_selectedStatusFilter == _closedGroupFilterKey) {
      return 'Các Mục Đã Đóng';
    }
    if (_selectedStatusFilter != null &&
        AppStatus.displayConfig.containsKey(_selectedStatusFilter!)) {
      return AppStatus.getDisplayText(_selectedStatusFilter!);
    }
    return 'Đang Lọc';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF121212) : const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(
          'Lịch sử ứng tuyển',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        elevation: 0, // REFINED: Bỏ elevation để dùng border
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onSurface,
            size: 22,
          ),
          // CHANGED: Thay đổi hành vi nút back
          onPressed:
              () => Navigator.of(context).popUntil((route) => route.isFirst),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDarkMode ? Brightness.light : Brightness.dark,
        ),
        // NEW: Thêm đường kẻ dưới AppBar để tách biệt rõ ràng
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: theme.dividerColor.withOpacity(0.5),
            height: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: theme.primaryColor,
          backgroundColor: theme.cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SlideTransition(
                position: _filterBarSlideAnimation,
                child: FadeTransition(
                  opacity: _filterBarFadeAnimation,
                  child: _buildStatsSummary(theme),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_getFilterDisplayName(theme)} (${_filteredJobApplications.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withOpacity(0.9),
                      ),
                    ),
                    if (_selectedStatusFilter != null)
                      TextButton.icon(
                        onPressed: () => _handleFilterSelection(null),
                        icon: Icon(
                          Icons.filter_list_off_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        label: Text(
                          'Xóa Lọc',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child:
                    _isLoading && _allJobApplications.isEmpty
                        ? Center(
                          child: CircularProgressIndicator(
                            color: theme.primaryColor,
                          ),
                        )
                        : _filteredJobApplications.isEmpty
                        ? _buildEmptyState(theme)
                        : AnimationLimiter(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: _filteredJobApplications.length,
                            itemBuilder: (context, index) {
                              final jobApp = _filteredJobApplications[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 425),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    // REFINED: Bỏ Padding ở đây và đưa margin vào Card
                                    child: _buildJobHistoryCard(jobApp, theme),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // REFINED: Toàn bộ phần _buildStatsSummary và _buildStatItem đã được tinh chỉnh
  // để có giao diện chuyên nghiệp và dễ nhìn hơn.
  Widget _buildStatsSummary(ThemeData theme) {
    if (_isLoading && _allJobApplications.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        color:
            theme.brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : Colors.white,
        height: 90,
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    int totalApplications = _allJobApplications.length;
    int pendingApplications =
        _allJobApplications
            .where((job) => job.applicationStatus == AppStatus.pending)
            .length;
    int acceptedApplications =
        _allJobApplications
            .where((job) => job.applicationStatus == AppStatus.accepted)
            .length;
    int closedApplications =
        _allJobApplications
            .where(
              (job) =>
                  job.applicationStatus == AppStatus.rejected ||
                  job.applicationStatus == AppStatus.viewed ||
                  job.applicationStatus == AppStatus.interview,
            )
            .length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color:
            theme.brightness == Brightness.dark
                ? const Color(0xFF1E1E1E)
                : Colors.white,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildStatItem(
                count: totalApplications.toString(),
                label: 'Tất Cả',
                icon: Icons.all_inbox_rounded,
                color: theme.colorScheme.onSurfaceVariant,
                filterKey: null,
                isSelected: _selectedStatusFilter == null,
                theme: theme,
              ),
              const SizedBox(width: 12),
              _buildStatItem(
                count: pendingApplications.toString(),
                label: 'Đang Chờ',
                icon: Icons.hourglass_top_rounded,
                color: AppStatus.getTextColor(AppStatus.pending),
                filterKey: AppStatus.pending,
                isSelected: _selectedStatusFilter == AppStatus.pending,
                theme: theme,
              ),
              const SizedBox(width: 12),
              _buildStatItem(
                count: acceptedApplications.toString(),
                label: 'Chấp Nhận',
                icon: Icons.verified_user_outlined,
                color: AppStatus.getTextColor(AppStatus.accepted),
                filterKey: AppStatus.accepted,
                isSelected: _selectedStatusFilter == AppStatus.accepted,
                theme: theme,
              ),
              const SizedBox(width: 12),
              _buildStatItem(
                count: closedApplications.toString(),
                label: 'Đã Đóng',
                icon: Icons.inventory_2_outlined,
                color: Colors.grey.shade600,
                filterKey: _closedGroupFilterKey,
                isSelected: _selectedStatusFilter == _closedGroupFilterKey,
                theme: theme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String count,
    required String label,
    required IconData icon,
    required Color color,
    required String? filterKey,
    required bool isSelected,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: () => _handleFilterSelection(filterKey),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withOpacity(0.12)
                  : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border:
              isSelected
                  ? Border.all(color: color.withOpacity(0.8), width: 1.8)
                  : Border.all(color: theme.dividerColor.withOpacity(0.5)),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                  : null,
        ),
        constraints: const BoxConstraints(minWidth: 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              count,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    isSelected
                        ? color
                        : theme.colorScheme.onSurfaceVariant.withOpacity(0.9),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // REFINED: Toàn bộ widget _buildJobHistoryCard được cấu trúc lại để rõ ràng và chuyên nghiệp hơn.
  Widget _buildJobHistoryCard(JobApplication jobApp, ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 14.0,
      ), // REFINED: Dùng margin thay vì Padding
      elevation: 2.0,
      shadowColor: theme.shadowColor.withOpacity(isDarkMode ? 0.12 : 0.07),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      JobApplicationDetailScreen(jobApplication: jobApp),
            ),
          ).then((_) => _onRefresh());
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: theme.primaryColor.withOpacity(0.1),
        highlightColor: theme.primaryColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Phần Header: Logo, Title, Company, Status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCompanyLogo(jobApp, theme),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          jobApp.jobPosting.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          jobApp.jobPosting.company.companyName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(jobApp.applicationStatus, theme),
                ],
              ),
              const SizedBox(height: 16),

              // Phần thông tin chi tiết: Location, Salary
              _buildInfoRow(
                theme,
                icon: Icons.location_on_outlined,
                text: jobApp.jobPosting.location ?? 'Chưa cập nhật',
                iconColor: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                theme,
                icon: Icons.paid_outlined,
                text: FormatUtils.formatSalary(jobApp.jobPosting.salary ?? 0),
                iconColor: theme.colorScheme.tertiary,
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.tertiary,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Divider(
                  height: 1,
                  color: theme.dividerColor.withOpacity(0.4),
                ),
              ),

              // Phần Footer: Ngày ứng tuyển và nút hành động
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildInfoRow(
                      theme,
                      icon: Icons.calendar_today_rounded,
                      text:
                          'Nộp ngày: ${FormatUtils.formattedDateTime(jobApp.submittedAt)}',
                      iconSize: 14,
                      textStyle: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(
                          0.8,
                        ),
                      ),
                    ),
                  ),
                  _buildActionButtons(context, jobApp, theme),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // NEW: Tách widget logo ra để code gọn hơn
  Widget _buildCompanyLogo(JobApplication jobApp, ThemeData theme) {
    final String? effectiveLogoCompany = jobApp.jobPosting.company.logoCompany;
    final String companyNameForPlaceholder =
        jobApp.jobPosting.company.companyName.isNotEmpty
            ? jobApp.jobPosting.company.companyName[0].toUpperCase()
            : 'C';

    Widget logoWidget;
    if (effectiveLogoCompany != null && effectiveLogoCompany.isNotEmpty) {
      logoWidget = Image.network(
        effectiveLogoCompany,
        fit: BoxFit.contain,
        errorBuilder:
            (context, error, stackTrace) => Center(
              child: Text(
                companyNameForPlaceholder,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      );
    } else {
      logoWidget = Center(
        child: Text(
          companyNameForPlaceholder,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
          width: 0.8,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: logoWidget,
      ),
    );
  }

  // NEW: Widget helper để hiển thị một dòng thông tin (icon + text)
  Widget _buildInfoRow(
    ThemeData theme, {
    required IconData icon,
    required String text,
    Color? iconColor,
    TextStyle? textStyle,
    double iconSize = 16,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: iconSize,
          color:
              iconColor ?? theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style:
                textStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _handleCancelApplication(String idJobPost) async {
    try {
      await _apiService.delete(
        '${ApiConstants.jobApplicationPostEndpoint}/$idJobPost/${widget.idUser}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã hủy ứng tuyển thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        _onRefresh(); // Tải lại dữ liệu sau khi hủy
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể hủy ứng tuyển: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // REFINED: Tinh chỉnh style của các nút bấm
  Widget _buildActionButtons(
    BuildContext context,
    JobApplication jobApp,
    ThemeData theme,
  ) {
    final buttonStyle = OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: theme.textTheme.labelMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
      side: BorderSide(color: theme.primaryColor.withOpacity(0.9), width: 1.5),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        JobApplicationDetailScreen(jobApplication: jobApp),
              ),
            ).then((_) => _onRefresh());
          },
          style: buttonStyle.copyWith(
            foregroundColor: MaterialStateProperty.all(theme.primaryColor),
          ),
          icon: Icon(
            Icons.visibility_rounded,
            size: 18,
            color: theme.primaryColor,
          ),
          label: const Text('Xem'),
        ),
        if (jobApp.applicationStatus == AppStatus.pending) ...[
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: () {
              _handleCancelApplication(jobApp.jobPosting.idJobPost);
            },
            style: buttonStyle.copyWith(
              side: MaterialStateProperty.all(
                BorderSide(
                  color: theme.colorScheme.error.withOpacity(0.9),
                  width: 1.5,
                ),
              ),
              foregroundColor: MaterialStateProperty.all(
                theme.colorScheme.error,
              ),
            ),
            icon: Icon(
              Icons.cancel_rounded,
              size: 18,
              color: theme.colorScheme.error,
            ),
            label: const Text('Hủy'),
          ),
        ],
      ],
    );
  }

  // REFINED: Tinh chỉnh style của chip trạng thái
  Widget _buildStatusChip(String apiStatus, ThemeData theme) {
    final Color bgColor = AppStatus.getBgColor(apiStatus);
    final Color textColor = AppStatus.getTextColor(apiStatus);
    final IconData icon = AppStatus.getIcon(apiStatus);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(
          theme.brightness == Brightness.dark ? 0.25 : 1.0,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: textColor),
          const SizedBox(width: 6),
          Text(
            AppStatus.getDisplayText(apiStatus),
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // REFINED: Cải thiện nội dung và giao diện của trạng thái rỗng
  Widget _buildEmptyState(ThemeData theme) {
    final bool isFiltered = _selectedStatusFilter != null;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFiltered
                  ? Icons.filter_alt_off_outlined
                  : Icons.history_toggle_off_rounded,
              size: 80,
              color: theme.hintColor.withOpacity(0.35),
            ),
            const SizedBox(height: 24),
            Text(
              isFiltered ? 'Không Tìm Thấy Kết Quả' : 'Chưa Có Lịch Sử',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isFiltered
                  ? 'Không có hồ sơ ứng tuyển nào khớp với bộ lọc của bạn.'
                  : 'Mọi công việc bạn ứng tuyển sẽ được lưu tại đây để tiện theo dõi.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.65),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            if (isFiltered)
              ElevatedButton.icon(
                icon: const Icon(Icons.clear_all_rounded, size: 20),
                label: const Text('Xóa Lọc & Tải Lại'),
                onPressed: _onRefresh,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 13,
                  ),
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              )
            else
              OutlinedButton.icon(
                icon: Icon(Icons.search_rounded, color: theme.primaryColor),
                label: Text(
                  'Tìm Việc Ngay',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  // HomePage.goToSearchTab(context, initialTabIndex: 1);
                  HomePage.goToUniJobsTab(context, initialTabIndex: 1);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: theme.primaryColor.withOpacity(0.7),
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
