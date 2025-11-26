  import 'package:flutter/material.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:job_connect/config/constant/api_constants.dart';
  import 'package:job_connect/config/widgets/background_error_state.dart';
  import 'package:job_connect/config/widgets/section_title.dart';
  import 'package:job_connect/features/company/model/company_model.dart';
  import 'package:job_connect/features/job/model/job_posting_model.dart';
  import 'package:job_connect/config/services/api_service.dart';
  import 'package:job_connect/features/company/viewmodel/company_view_model.dart';
  import 'package:job_connect/features/company/widgets/company_detail/company_detail_appbar.dart';
  import 'package:job_connect/features/company/widgets/company_detail/company_detail_shimmer.dart';
  import 'package:job_connect/features/company/widgets/company_detail/company_info_row.dart';
  import 'package:job_connect/features/company/widgets/company_detail/company_job_card.dart';
  import 'package:provider/provider.dart';
  import 'package:url_launcher/url_launcher.dart';
  import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

  class CompanyDetailsScreen extends StatefulWidget {
    final String idUser;
    final CompanyModel company;

    const CompanyDetailsScreen({
      super.key,
      required this.company,
      required this.idUser,
    });

    @override
    CompanyDetailState createState() => CompanyDetailState();
  }

  class CompanyDetailState extends State<CompanyDetailsScreen> with TickerProviderStateMixin {
    final _apiService = ApiService();
    List<JobPostingModel> _companyJobsList = [];
    bool _isLoadingCompanyJobs = true;
    String _companyJobsError = '';

    late AnimationController _animationController;
    late Animation<double> _fadeAnimation;
    late CompanyViewModel companyViewModel;

    @override
    void initState() {
      super.initState();
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
      );
      _fadeAnimation = CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      );
      companyViewModel = context.read<CompanyViewModel>();
      //   LẤY CHI TIẾT CÔNG TY
      getDetailJob();
      _fetchAndFilterCompanyJobs();
    }

    void getDetailJob() {
      final viewModel = context.read<CompanyViewModel>();
      viewModel.getCompanyDetail(widget.company.idCompany);
    }

    @override
    void dispose() {
      _animationController.dispose();
      super.dispose();
    }

    Future<void> _fetchAndFilterCompanyJobs() async {
      if (!mounted) return;
      setState(() {
        _isLoadingCompanyJobs = true;
        _companyJobsError = '';
        _companyJobsList.clear();
      });
      try {
        final responseData =
            await _apiService.get(endpoint: ApiConstants.jobPostingEndpoint);
        List<JobPostingModel> allJobs =
            responseData.map<JobPostingModel>((job) => JobPostingModel.fromJson(job)).toList();

        String targetCompanyId = widget.company.idCompany;

        //   Lọc và sắp xếp
        allJobs =
            allJobs.where((job) => job.idCompany == targetCompanyId).toList();
        allJobs.sort((a, b) {
          if (a.isFeatured == 1 && b.isFeatured != 1) return -1;
          if (a.isFeatured != 1 && b.isFeatured == 1) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });

        if (mounted) {
          setState(() => _companyJobsList = allJobs);
          _animationController.forward(from: 0.0);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _companyJobsError = "Lỗi tải công việc: ${e.toString()}";
            _companyJobsList = [];
          });
        }
      } finally {
        if (mounted) setState(() => _isLoadingCompanyJobs = false);
      }
    }

    Future<void> _onRefresh() async {
      _animationController.reset();
      await _fetchAndFilterCompanyJobs();
    }

    Future<void> _launchURL(String url) async {
      if (url.isEmpty) return;
      final Uri uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể mở liên kết: $url')),
          );
        }
      }
    }

    @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context);
      if(companyViewModel.isDetailLoading){
        return const CompanyDetailShimmer();
      }
      if(companyViewModel.errorMessage != null){
        return BackgroundErrorState(
          title: "Hệ thống đang gặp sự cố\nVui lòng thử lại sau.",
          onRetry: _onRefresh,
        );
      }
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: theme.primaryColor,
          backgroundColor: theme.cardColor,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              //   APPBAR
              CompanyDetailAppbar(
                companyName: widget.company.companyName,
                industry: widget.company.industry,
                logoCompany: widget.company.logoCompany,
                jobName: widget.company.companyName,
                onShare: () {},
                isCompany: true,
              ),

              //   CONTENT
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 24.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: AnimationConfiguration.toStaggeredList(
                        duration: const Duration(milliseconds: 400),
                        childAnimationBuilder: (widget) => SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(child: widget),
                        ),
                        children: [
                          //    SECTION - Giới thiệu
                          SectionTitle(
                            title: "Giới thiệu công ty",
                            icon: Icons.info_outline_rounded,
                          ),
                          SizedBox(height: 8.h),

                          Card(
                            elevation: 1.5,
                            color: theme.cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Text(
                                widget.company.description ?? "Chưa có thông tin",
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.6,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.85),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          //   SECTION - Thông tin liên hệ
                          SectionTitle(
                            title: "Thông tin liên hệ",
                            icon: Icons.contact_page_outlined,
                          ),
                          SizedBox(height: 8.h),

                          Card(
                            elevation: 1.5,
                            color: theme.cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.w),
                              child: Column(
                                children: [
                                  CompanyInfoRow(
                                    icon: Icons.location_city_rounded,
                                    title: 'Địa chỉ',
                                    content: widget.company.address,
                                  ),
                                  Divider(
                                    color: theme.dividerColor
                                        .withValues(alpha: 0.3),
                                    height: 1.h,
                                  ),
                                  if (widget.company.websiteUrl != null &&
                                      widget.company.websiteUrl!.isNotEmpty)
                                    GestureDetector(
                                      onTap: () =>
                                          _launchURL(widget.company.websiteUrl!),
                                      child: CompanyInfoRow(
                                        icon: Icons.language_rounded,
                                        title: 'Website',
                                        content: widget.company.websiteUrl!,
                                        isLink: true,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 24.h),

                          //   SECTION - Việc làm đang tuyển
                          SectionTitle(
                            title:
                                "Việc Làm Đang Tuyển (${_companyJobsList.length})",
                            icon: Icons.work_history_outlined,
                          ),
                          SizedBox(height: 12.h),

                          _isLoadingCompanyJobs
                              ? Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 32.h),
                                    child: CircularProgressIndicator(
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                )
                              : _companyJobsList.isEmpty
                                  ? Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 32.h,
                                        horizontal: 16.w,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.cardColor
                                            .withValues(alpha: 0.7),
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                      ),
                                      child: Center(
                                        child: Text(
                                          _companyJobsError.isNotEmpty
                                              ? _companyJobsError
                                              : 'Hiện chưa có vị trí nào đang tuyển tại công ty này.',
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                            color: theme.colorScheme
                                                .onSurfaceVariant,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: _companyJobsList
                                          .map(
                                            (job) => CompanyJobCard(
                                              job: job,
                                              idUser: widget.idUser,
                                            ),
                                          )
                                          .toList(),
                                    ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
