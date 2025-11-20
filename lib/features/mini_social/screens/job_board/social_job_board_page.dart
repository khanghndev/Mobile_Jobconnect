import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/widgets/background_empty_state.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/job/view_model/job_category_view_model.dart';
import 'package:job_connect/features/job/view_model/job_posting_view_model.dart';
import 'package:job_connect/features/mini_social/widgets/job_board/carousel_job_board.dart';
import 'package:job_connect/features/mini_social/widgets/job_board/category_chips.dart';
import 'package:job_connect/features/mini_social/widgets/job_board/dot_in_dicator.dart';
import 'package:job_connect/features/mini_social/widgets/job_board/job_board_shimmer.dart';
import 'package:job_connect/features/mini_social/widgets/job_board/title_section.dart';
import 'package:job_connect/features/mini_social/widgets/job_board/top_header.dart';
import 'package:provider/provider.dart';

class SocialJobBoardPage extends StatefulWidget {
  final String idUser;
  const SocialJobBoardPage({super.key, required this.idUser});

  @override
  State<SocialJobBoardPage> createState() => _SocialJobBoardPageState();
}

class _SocialJobBoardPageState extends State<SocialJobBoardPage> {
  double _currentPage = 0.0;
  int _currentIndex = 0;

  late JobCategoryViewModel _jobCategoryViewModel;
  late JobPostingViewModel _jobPostingViewModel;

  @override
  void initState() {
    super.initState();
    _jobCategoryViewModel = context.read<JobCategoryViewModel>();
    _jobPostingViewModel = context.read<JobPostingViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _jobCategoryViewModel.fetchAllCategories();
      await _jobPostingViewModel.fetchJobPostingsExcludeFullTime();
    });
  }

  void _onGoToDetailJob(String idUser, JobPostingModel job) {
    context.push('/job/detail', extra: {"idUser": idUser, "jobPosting": job});
  }

  void _onGoToApplyJob(String idUser, JobPostingModel job) {
    context.push('/job/apply', extra: {
      'jobId': job.idJobPost,
      'jobTitle': job.title,
      'companyName': job.company?.companyName ?? '',
      'idUser': idUser,
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryVM = context.watch<JobCategoryViewModel>();
    final jobVM = context.watch<JobPostingViewModel>();
    final jobList = jobVM.jobPostings;

    return Scaffold(
      body: SafeArea(
        child: jobVM.isLoading || categoryVM.isLoading
            ? const JobBoardShimmer()
            : RefreshIndicator(
                onRefresh: () => jobVM.fetchJobPostingsExcludeFullTime(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: TopHeader(
                          backIconColor: Colors.black,
                          settingsIconColor: Colors.blue,
                          titleColor: Colors.black87,
                          subtitleColor: Colors.grey,
                          onBack: () => context.pop(),
                          onSettings: () {},
                        ),
                      ),
                      SizedBox(height: 18.h),

                      /// DANH MỤC
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Builder(
                          builder: (context) {
                            final categoryNames = [
                              'Tất cả',
                              ...categoryVM.categories.map((e) => e.categoryName ?? 'Không tên'),
                            ];

                            return CategoryChips(
                              selectedColor: Colors.blue,
                              unselectedColor: Colors.blue.withValues( alpha: 0.2),
                              selectedTextColor: Colors.white,
                              unselectedTextColor: Colors.blue,
                              borderColor: Colors.blue,
                              categories: categoryNames,
                              onSelected: (index) async {
                                if (index == 0) {
                                  await jobVM.fetchAllJobPostings();
                                } else {
                                  final selectedCategory = categoryVM.categories[index - 1];
                                   jobVM.filterJobPostingsByCategory(
                                      selectedCategory.categoryName ?? '');
                                }
                                setState(() {
                                  _currentIndex = 0;
                                  _currentPage = 0.0;
                                });
                              },
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 24.h),

                      /// EMPTY STATE
                      if (jobList.isEmpty) ...[
                        BackgroundEmptyState(
                          isSearching: false,
                          onRefresh: jobVM.fetchAllJobPostings,
                          title: "Không có tin tuyển dụng cho lựa chọn này",
                          iconData: Icons.work_off,
                        ),
                      ] else ...[
                        /// CAROUSEL
                        CarouselJobBoard(
                          posters: jobList
                              .map((job) => job.company?.logoCompany ?? AppImages.logoApp)
                              .toList(),
                          onPageScroll: (page) => setState(() => _currentPage = page),
                          onPageChanged: (index) => setState(() => _currentIndex = index),
                        ),

                        SizedBox(height: 12.h),

                        /// DOT INDICATOR
                        DotIndicator(
                          currentIndex: _currentIndex,
                          total: jobList.length,
                        ),

                        SizedBox(height: 18.h),

                        /// JOB DETAIL SECTION
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Builder(
                            builder: (_) {
                              final job = jobList[_currentIndex];
                              final badges = [
                                if (job.company?.companyName != null)
                                  job.company!.companyName,
                                job.experienceLevel,
                                job.location,
                                job.workType,
                                if (job.salary != null) job.salary.toString(),
                              ];

                              return TitleSection(
                                title: job.title,
                                subtitle: job.category?.categoryName ?? 'Chưa phân loại',
                                decription: job.description,
                                badges: badges,
                                onApply: () => _onGoToApplyJob(widget.idUser, job),
                                onDetail: () => _onGoToDetailJob(widget.idUser, job),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
