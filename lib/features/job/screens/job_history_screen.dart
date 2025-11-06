import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/utils/status_helper.dart';
import 'package:job_connect/config/widgets/background_empty_state.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/overlay_loading.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/view_model/job_application_view_model.dart';
import 'package:job_connect/features/job/widgets/job_history/job_history_card.dart';
import 'package:job_connect/features/job/widgets/job_history/job_history_shimmer.dart';
import 'package:job_connect/features/job/widgets/job_history/stats_summary.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

const String _closedGroupFilterKey = 'closed_group_filter';

class JobHistoryScreen extends StatefulWidget {
  final String idUser;
  const JobHistoryScreen({super.key, required this.idUser});

  @override
  JobHistoryScreenState createState() => JobHistoryScreenState();
}

class JobHistoryScreenState extends State<JobHistoryScreen> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  String? _selectedStatusFilter;
  bool _isInitialLoading = true;
  late AnimationController _listAnimationController;
  late AnimationController _filterBarAnimationController;
  late Animation<Offset> _filterBarSlideAnimation;
  late Animation<double> _filterBarFadeAnimation;

  void _onGoToDetail(JobApplicationModel jobApp) {
    context.push(
      '/job/apply-detail',
      extra: {
        'idUser' : jobApp.idUser,
        'idJobPost': jobApp.idJobPost,
      }
    );
  }
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
    _filterBarSlideAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _filterBarAnimationController, curve: Curves.easeOut));
    _filterBarFadeAnimation = CurvedAnimation(parent: _filterBarAnimationController, curve: Curves.easeInOut);

    // Load dữ liệu từ ViewModel
    Future.microtask(() {
      if(mounted) {
        final vm = context.read<JobApplicationViewModel>();
        vm.getJobApplicationsByUser(widget.idUser).then((_) {
        if (mounted) {
          _listAnimationController.forward();
          _filterBarAnimationController.forward();
          setState(() {
            _isInitialLoading = false;
          });
        }});
      }
    });
  }

  Future<void> _onRefresh() async {
    final vm = context.read<JobApplicationViewModel>();
    _listAnimationController.reset();
    _filterBarAnimationController.reset();
    _selectedStatusFilter = null;

    await vm.refreshApplications(userId: widget.idUser);

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
      _listAnimationController.forward();
    });
  }

  // Lọc dữ liệu dựa vào ViewModel
  List<JobApplicationModel> _filteredApplications(JobApplicationViewModel vm) {
    final allApps = vm.applications;
    if (_selectedStatusFilter == null) return allApps;

    if (_selectedStatusFilter == _closedGroupFilterKey) {
      return allApps.where((app) =>
          app.applicationStatus == AppStatus.rejected ||
          app.applicationStatus == AppStatus.viewed ||
          app.applicationStatus == AppStatus.interview).toList();
    }

    return allApps.where((app) => app.applicationStatus == _selectedStatusFilter).toList();
  }

  String _getFilterDisplayName(ThemeData theme) {
    if (_selectedStatusFilter == null) return 'Tất Cả Ứng Tuyển';
    if (_selectedStatusFilter == _closedGroupFilterKey) return 'Các Mục Đã Đóng';
    if (_selectedStatusFilter != null &&
        AppStatus.displayConfig.containsKey(_selectedStatusFilter!)) {
      return AppStatus.getDisplayText(_selectedStatusFilter!);
    }
    return 'Đang Lọc';
  }

  void _onCancelApply(JobApplicationModel jobApp) async {
    final vm = context.read<JobApplicationViewModel>();
    await vm.deleteJobApplication(jobApp.idJobPost, jobApp.idUser);
    if(mounted){
       SnackbarApp.show(
          context,
          title: 'Thành công',
          message: 'Hủy ứng tuyển thành công',
          backgroundColor: BackgroundColors.backgroundSuccessPrimary,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final vm = context.watch<JobApplicationViewModel>();
    final filteredApps = _filteredApplications(vm);
    if (_isInitialLoading) {
      return Scaffold(body: const JobHistoryShimmer());
    }
    return OverlayLoading(
      isLoading: vm.isLoading,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: const CustomAppbarTitleLarge(title: 'Lịch sử ứng tuyển'),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Filter bar
                SlideTransition(
                  position: _filterBarSlideAnimation,
                  child: FadeTransition(
                    opacity: _filterBarFadeAnimation,
                    child: StatsSummary(
                      applications: vm.applications,
                      selectedFilter: _selectedStatusFilter,
                      closedGroupFilterKey: _closedGroupFilterKey,
                      onFilterSelected: _handleFilterSelection,
                    ),
                  ),
                ),

                // Header: Filter summary
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_getFilterDisplayName(theme)} (${filteredApps.length})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
                        ),
                      ),
                      if (_selectedStatusFilter != null)
                        TextButton.icon(
                          onPressed: () => _handleFilterSelection(null),
                          icon: Icon(Icons.filter_list_off_rounded, size: 18, color: theme.colorScheme.primary),
                          label: Text('Xóa Lọc', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                    ],
                  ),
                ),

                // Job list
                Expanded(
                  child: filteredApps.isEmpty
                      ? BackgroundEmptyState(
                          isSearching: false,
                          onRefresh: _onRefresh,
                          title: _selectedStatusFilter != null ? 'Không Tìm Thấy Kết Quả' : 'Chưa Có Lịch Sử',
                          subTitle: _selectedStatusFilter != null
                              ? 'Không có hồ sơ ứng tuyển nào khớp với bộ lọc của bạn.'
                              : 'Mọi công việc bạn ứng tuyển sẽ được lưu tại đây để tiện theo dõi.',
                          iconData: Icons.history,
                        )
                      : AnimationLimiter(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            itemCount: filteredApps.length,
                            itemBuilder: (context, index) {
                              final jobApp = filteredApps[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 425),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: JobHistoryCard(
                                      jobApp: jobApp,
                                      onViewDetail: () {
                                        _onGoToDetail(jobApp);
                                      },
                                      onCancel: jobApp.applicationStatus == AppStatus.pending
                                        ? () => _onCancelApply(jobApp)
                                        : null,
                                    ),
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

}