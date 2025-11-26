import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/background_error_state.dart';
import 'package:job_connect/config/widgets/custom_action_bar.dart';
import 'package:job_connect/config/widgets/login_required_dialog.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/home/model/job_saved_model.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/features/home/view_model/job_saved_view_model.dart';
import 'package:job_connect/features/company/widgets/company_detail/company_detail_appbar.dart';
import 'package:job_connect/features/job/widgets/job_detail/company_info_card.dart';
import 'package:job_connect/features/job/widgets/job_detail/job_detail_section.dart';
import 'package:job_connect/features/job/widgets/job_detail/job_detail_shimmer.dart';
import 'package:job_connect/features/job/widgets/job_detail/job_overview_card.dart';
import 'package:job_connect/features/job/widgets/job_detail/similar_jobs_section.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart'; 

class JobDetailScreen extends StatefulWidget {
  final String idUser;
  final JobPostingModel jobPosting;

  const JobDetailScreen({
    super.key,
    required this.idUser,
    required this.jobPosting,
  });

  @override
  JobDetailState createState() => JobDetailState();
}

class JobDetailState extends State<JobDetailScreen>with TickerProviderStateMixin {
  final _apiService = ApiService( );
  late JobSavedViewModel _jobSavedVM;
  JobPostingModel? _jobPosting;
  bool _isLoading = true;
  String? _errorMessage;
  List<JobApplicationModel> _appJobList = []; // Giữ lại để hiển thị số lượng ứng viên

  late AnimationController _animationController; // Animation cho các section
  late Animation<double> _fadeAnimation;

  List<JobPostingModel> _similarJobs = []; // Công việc cùng công ty

  @override
  void initState() {
    super.initState();
    _jobSavedVM = context.read<JobSavedViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _jobSavedVM.fetchSavedJobsByUser(widget.idUser);
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _initializeData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadAllData();
    if (mounted) _animationController.forward();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await Future.wait([
        _fetchJob(),
        _fetchApplicationJobCount(), // Chỉ fetch số lượng nếu cần
      ]);
      // Fetch saved jobs từ ViewModel
      if (widget.idUser.isNotEmpty) {
        await _jobSavedVM.fetchSavedJobsByUser(widget.idUser);
      }
      // Fetch công việc cùng công ty sau khi đã có _jobPosting
      if (_jobPosting != null && _jobPosting!.company != null) {
        await _fetchSimilarJobs();
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _errorMessage = 'Không thể tải dữ liệu. Vui lòng thử lại.',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    _animationController.reset();
    await _loadAllData();
    if (mounted) _animationController.forward();
  }

  Future<void> _fetchJob() async {
    try {
      final data = await _apiService.get(
        endpoint: '${ApiConstants.jobPostingEndpoint}/${widget.jobPosting.idJobPost}',
      );

      // ✅ API trả về 1 object (Map), không phải list
      if (data != null && data.isNotEmpty) {
        _jobPosting = JobPostingModel.fromJson(data);
      } else {
        throw Exception('Không tìm thấy thông tin công việc.');
      }
    } catch (e) {
      print('Error fetching job: $e');
      throw Exception('Lỗi khi tải thông tin công việc: $e');
    }
  }


  Future<void> _fetchApplicationJobCount() async {
    // Chỉ lấy số lượng ứng viên cho công việc này
    try {
      // API này cần trả về danh sách ứng viên cho một job post cụ thể
      // Hoặc một API khác trả về số lượng ứng viên
      final data = await _apiService.get(
         endpoint: '${ApiConstants.jobApplicationEndpoint}/${widget.jobPosting.idJobPost}',
      );
      if (mounted) {
        _appJobList =
            data
                .map<JobApplicationModel>((app) => JobApplicationModel.fromJson(app))
                .toList();
      }
    } catch (e) {
      print('Error fetching applications count: $e');
      _appJobList = []; // Lỗi thì coi như không có ứng viên
    }
  }

  Future<void> _fetchSimilarJobs() async {
    if (_jobPosting == null || _jobPosting!.company == null) return;
    
    try {
      final endpoint = ApiConstants.jobPostingByCompanyEndpoint
          .replaceFirst('{companyId}', _jobPosting!.company!.idCompany);
      final data = await _apiService.get(endpoint: endpoint);
      
      if (mounted && data != null) {
        final List<JobPostingModel> allCompanyJobs = 
            (data as List).map<JobPostingModel>((job) => JobPostingModel.fromJson(job)).toList();
        
        // Lọc bỏ công việc hiện tại và giới hạn số lượng
        _similarJobs = allCompanyJobs
            .where((job) => job.idJobPost != widget.jobPosting.idJobPost)
            .take(5)
            .toList();
        
        if (mounted) setState(() {});
      }
    } catch (e) {
      print('Error fetching similar jobs: $e');
      _similarJobs = [];
    }
  }

  Future<void> _onToggleSaveJob() async {
    if (_jobPosting == null) return;
    if (widget.idUser.isEmpty) {
      LoginRequiredDialog.show(context);
      return;
    }

    final isCurrentlySaved = _jobSavedVM.savedJobs.any(
      (saved) => saved.idJobPost == widget.jobPosting.idJobPost && saved.idUser == widget.idUser,
    );

    try {
      if (isCurrentlySaved) {
        // Nếu đang lưu -> thực hiện bỏ lưu
        await _jobSavedVM.deleteSavedJob(widget.jobPosting.idJobPost, widget.idUser);
        if (mounted) {
          SnackbarApp.show(
            context,
            title: 'Thành công',
            message: 'Đã bỏ lưu công việc',
            backgroundColor: BackgroundColors.backgroundInfoPrimary,
          );
        }
      } else {
        // Nếu chưa lưu -> thực hiện lưu
        final jobToSave = JobSavedModel(
          idJobPost: widget.jobPosting.idJobPost,
          idUser: widget.idUser,
        );
        await _jobSavedVM.saveJob(jobToSave);
        if (mounted) {
          SnackbarApp.show(
            context,
            title: 'Thành công',
            message: 'Đã lưu công việc thành công!',
            backgroundColor: BackgroundColors.backgroundSuccessPrimary,
          );
        }
      }
      // Reload lại danh sách đã lưu sau khi thay đổi
      await _jobSavedVM.fetchSavedJobsByUser(widget.idUser);
      if (mounted) setState(() {}); // Cập nhật lại UI
    } catch (e) {
      if (mounted) {
        SnackbarApp.show(
          context,
          title: 'Lỗi',
          message: isCurrentlySaved
              ? 'Bỏ lưu thất bại: ${e.toString()}'
              : 'Lưu thất bại: ${e.toString()}',
          backgroundColor: BackgroundColors.backgroundErrorPrimary,
        );
      }
    }
  }

  void _shareJob() {
    if (_jobPosting != null) {
      Share.share(
        'Xem công việc thú vị này: ${_jobPosting!.title} tại ${_jobPosting!.company!.companyName}! Chi tiết: [URL_CONG_VIEC_CUA_BAN]', // Thay [URL_CONG_VIEC_CUA_BAN] bằng link thực tế
        subject: 'Cơ hội việc làm: ${_jobPosting!.title}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(
          child: JobDetailShimmer(),
        ),
      );
    }

    //   ERROR VIEW
    if (_errorMessage != null || _jobPosting == null) {
      return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: BackgroundErrorState(
          title: "Hệ thống đang gặp sự cố\nVui lòng thử lại sau.",
          onRetry: _onRefresh
        )
      ),
    );
    }

    return Consumer<JobSavedViewModel>(
      builder: (context, jobSavedVM, child) {
        final isJobCurrentlySaved = jobSavedVM.savedJobs.any(
          (saved) => saved.idJobPost == widget.jobPosting.idJobPost && saved.idUser == widget.idUser,
        );

        return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: theme.primaryColor,
        backgroundColor: theme.cardColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            //   APPBAR
             CompanyDetailAppbar(
              companyName:  _jobPosting!.title,
              industry: _jobPosting!.company!.industry,
              logoCompany: _jobPosting!.company!.logoCompany,
              jobName: _jobPosting!.title,
              onShare: _shareJob,
              isCompany: false,
            ),
            
            //   CONTENT
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0,20.0, 16.0, 100.0), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 450),
                      childAnimationBuilder:
                          (widget) => SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(child: widget),
                          ),
                      children: [
                        //   JOB OVERVIEW
                        JobOverviewCard(
                          jobPosting: _jobPosting!,
                          applicantCount: _appJobList.length,
                        ),

                        const SizedBox(height: 24),
                        JobDetailSection(
                          title: "Mô tả công việc",
                          content: _jobPosting!.description,
                          icon: Icons.description_outlined,
                          iconColor: theme.primaryColor,
                        ),
                        JobDetailSection(
                          title: "Yêu cầu ứng viên",
                          content: _jobPosting!.requirements,
                          icon: Icons.rule_outlined,
                          iconColor: theme.primaryColor,
                        ),
                        if (_jobPosting!.benefits != null &&
                            _jobPosting!.benefits!.isNotEmpty)
                          JobDetailSection(
                            title: "Quyền lợi",
                            content: _jobPosting!.benefits ?? "",
                            icon: Icons.card_giftcard_outlined,
                            iconColor: theme.primaryColor,
                          ),
                        //   COMPANY INFO
                        CompanyInfoCard(
                          company: _jobPosting!.company!,
                          idUser: widget.idUser,
                          onRefresh: _onRefresh,
                        ),

                        if (_similarJobs.isNotEmpty)
                          SimilarJobsSection(
                            similarJobs: _similarJobs.map((job) => {
                              "idJobPost": job.idJobPost,
                              "title": job.title,
                              "company": job.company?.companyName ?? "",
                              "salary": job.salary != null 
                                  ? "${FormatUtils.formatCurrency(job.salary!.toDouble())}đ"
                                  : "Lương thỏa thuận",
                              "location": FormatUtils.extractDistrictAndCity(job.location),
                            }).toList(),
                            onSeeAll: () {
                              // Navigate đến trang công ty để xem tất cả công việc
                              if (_jobPosting?.company != null) {
                                context.push(
                                  '/company/detail',
                                  extra: {'company': _jobPosting!.company!},
                                );
                              }
                            },
                            onTapJob: (job) {
                              // Navigate đến chi tiết job được chọn
                              final jobPosting = _similarJobs.firstWhere(
                                (j) => j.idJobPost == job["idJobPost"],
                                orElse: () => _similarJobs.first,
                              );
                              context.push(
                                '/job/detail',
                                extra: {
                                  'jobPosting': jobPosting,
                                  'idUser': widget.idUser,
                                },
                              );
                            },
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: CustomActionBar(
        theme: Theme.of(context),
        isSaved: isJobCurrentlySaved,
        onToggleSave: _onToggleSaveJob,
        onButtonPressed: () {
          if (widget.idUser.isEmpty) {
            LoginRequiredDialog();
            return;
          }
          context.push(
            '/job/apply',
            extra: {
              'jobId': widget.jobPosting.idJobPost,
              'jobTitle':  _jobPosting!.title,
              'companyName': _jobPosting!.company!.companyName,
              'idUser' : widget.idUser,
            }
          );
        },
        buttonText: 'Ứng Tuyển Ngay',
        mainButtonIcon: Icons.send_rounded,
        leftIcon: isJobCurrentlySaved
          ? Icons.bookmark_rounded
          : Icons.bookmark_add_outlined,
      ),
    );
      },
    );
  }
}