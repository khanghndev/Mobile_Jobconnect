import 'package:flutter/material.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/widgets/background_error_state.dart';
import 'package:job_connect/config/widgets/custom_action_bar.dart';
import 'package:job_connect/config/widgets/login_required_dialog.dart';
import 'package:job_connect/data/models/job_application_model.dart';
import 'package:job_connect/data/models/job_posting_model.dart';
import 'package:job_connect/data/models/job_saved_model.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/company/widgets/company_detail/company_detail_appbar.dart';
import 'package:job_connect/features/job/screens/apply_job_screen.dart';
import 'package:job_connect/features/job/widgets/job_detail/company_info_card.dart';
import 'package:job_connect/features/job/widgets/job_detail/job_detail_section.dart';
import 'package:job_connect/features/job/widgets/job_detail/job_detail_shimmer.dart';
import 'package:job_connect/features/job/widgets/job_detail/job_overview_card.dart';
import 'package:job_connect/features/job/widgets/job_detail/similar_jobs_section.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:share_plus/share_plus.dart'; 

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
  JobPostingModel? _jobPosting;
  JobSavedModel? _jobSaved; // Sẽ lưu trạng thái đã lưu của công việc này
  bool _isLoading = true;
  String? _errorMessage;
  List<JobApplicationModel> _appJobList = []; // Giữ lại để hiển thị số lượng ứng viên

  late AnimationController _animationController; // Animation cho các section
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> similarJobsData = [
    {
      "title": "Senior Flutter Developer",
      "company": "Innovatech Ltd.",
      "salary": "25.000.000đ",
      "location": "Quận 1, TP. HCM",
    },
    {
      "title": "Mobile Application Engineer",
      "company": "SolutionHub",
      "salary": "22.000.000đ",
      "location": "Đống Đa, Hà Nội",
    },
  ];

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
        _fetchSavedJobStatus(), // Đổi tên hàm này để rõ ràng hơn
        _fetchApplicationJobCount(), // Chỉ fetch số lượng nếu cần
      ]);
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

  Future<void> _fetchSavedJobStatus() async {
    // Lấy trạng thái lưu của CÔNG VIỆC HIỆN TẠI
    if (widget.idUser.isEmpty) {
      _jobSaved = null; // Nếu không có idUser, không thể có trạng thái đã lưu
      return;
    }
    try {
      final data = await _apiService.get(
        endpoint: '${ApiConstants.jobSavedEndpoint}/${widget.jobPosting.idJobPost}/${widget.idUser}',
      );
      if (data.isNotEmpty) {
        _jobSaved = JobSavedModel.fromJson(data.first);
      } else {
        _jobSaved = null; // Công việc này chưa được lưu bởi user này
      }
    } catch (e) {
      print('Error fetching saved job status: $e');
      _jobSaved = null; // Lỗi thì coi như chưa lưu
      // Không ném lỗi ở đây để các phần khác vẫn có thể tải
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

  Future<void> _onToggleSaveJob() async {
    if (_jobPosting == null) return;
    if (widget.idUser.isEmpty) {
      LoginRequiredDialog.show(context);
      return;
    }

    final theme = Theme.of(context);
    final bool currentlySaved = _jobSaved != null;

    setState(() {
      // Optimistic update
      if (currentlySaved) {
        _jobSaved = null;
      } else {
        // Tạo một đối tượng JobSaved giả để UI cập nhật ngay
        _jobSaved = JobSavedModel(
          idJobPost: widget.jobPosting.idJobPost,
          idUser: widget.idUser,
        );
      }
    });

    try {
      if (currentlySaved) {
        // Nếu đang lưu -> thực hiện bỏ lưu
        await _apiService.delete(
           endpoint: "${ApiConstants.jobSavedEndpoint}/${widget.jobPosting.idJobPost}/${widget.idUser}",
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Đã bỏ lưu công việc",
                style: TextStyle(color: theme.colorScheme.onSecondaryContainer),
              ),
              backgroundColor: theme.colorScheme.secondaryContainer,
            ),
          );
        }
      } else {
        // Nếu chưa lưu -> thực hiện lưu
        Map<String, dynamic> data = {
          "idJobPost": widget.jobPosting.idJobPost,
          "idUser": widget.idUser,
        };
        final response = await _apiService.post(
          endpoint: ApiConstants.jobSavedEndpoint,
          body : data,
        );
        if (response == 200 || response == 201) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Đã lưu công việc thành công!",
                  style: TextStyle(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                backgroundColor: theme.colorScheme.secondaryContainer,
              ),
            );
          }
          // Sau khi lưu thành công, fetch lại trạng thái để có idJobSaved đúng
          await _fetchSavedJobStatus();
          if (mounted) setState(() {}); // Cập nhật lại UI với _jobSaved mới
        } else {
          throw Exception("Không thể lưu công việc");
        }
      }
    } catch (e) {
      if (mounted) {
        // Revert optimistic update
        setState(() {
          if (currentlySaved) {
            // Nếu trước đó đã lưu (giờ đang cố bỏ lưu mà lỗi)
            _jobSaved = JobSavedModel(
              idJobPost: widget.jobPosting.idJobPost,
              idUser: widget.idUser,
            ); // Giữ lại trạng thái đã lưu (có thể với id giả)
          } else {
            // Nếu trước đó chưa lưu (giờ đang cố lưu mà lỗi)
            _jobSaved = null;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentlySaved
                  ? 'Bỏ lưu thất bại: ${e.toString()}'
                  : 'Lưu thất bại: ${e.toString()}',
              style: TextStyle(color: theme.colorScheme.onError),
            ),
            backgroundColor: theme.colorScheme.error,
          ),
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

    // TODO: ERROR VIEW
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

    final bool isJobCurrentlySaved =  _jobSaved != null && _jobSaved!.idJobPost.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: theme.primaryColor,
        backgroundColor: theme.cardColor,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // TODO: APPBAR
             CompanyDetailAppbar(
              companyName:  _jobPosting!.title,
              industry: _jobPosting!.company!.industry,
              logoCompany: _jobPosting!.company!.logoCompany,
              jobName: _jobPosting!.title,
              onShare: _shareJob,
              isCompany: false,
            ),
            
            // TODO: CONTENT
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
                        // TODO: JOB OVERVIEW
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
                        // TODO: COMPANY INFO
                        CompanyInfoCard(
                          company: _jobPosting!.company!,
                          idUser: widget.idUser,
                          onRefresh: _onRefresh,
                        ),

                        SimilarJobsSection(
                          similarJobs: similarJobsData,
                          onSeeAll: () {
                            // TODO: Navigate đến danh sách việc làm tương tự
                          },
                          onTapJob: (job) {
                            // TODO: Navigate đến chi tiết job được chọn
                            
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ApplyJobScreen(
                jobId: widget.jobPosting.idJobPost,
                jobTitle: _jobPosting!.title,
                companyName: _jobPosting!.company!.companyName,
                idUser: widget.idUser,
              ),
            ),
          ).then((_) => _onRefresh());
        },
        buttonText: 'Ứng Tuyển Ngay',
        mainButtonIcon: Icons.send_rounded,
        leftIcon: isJobCurrentlySaved
          ? Icons.bookmark_rounded
          : Icons.bookmark_add_outlined,
      )
    );
  }
}