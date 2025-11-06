import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/utils/string_utils.dart';
import 'package:job_connect/config/widgets/background_error_state.dart';
import 'package:job_connect/config/widgets/card_main.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/custom_button_border.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/features/job/view_model/job_application_view_model.dart';
import 'package:job_connect/features/job/widgets/job_application_detail/status_card.dart';
import 'package:job_connect/features/job/widgets/job_history/job_history_card.dart';
import 'package:job_connect/features/profile/widgets/profile/profile_info_row.dart';
import 'package:job_connect/features/job/widgets/job_application_detail/job_application_detail_shimmer.dart';
import 'package:provider/provider.dart';

class JobApplicationDetailScreen extends StatefulWidget {
  final String idJobPost;
  final String idUser;

  const JobApplicationDetailScreen({
    super.key,
    required this.idJobPost,
    required this.idUser,
  });

  @override
  State<JobApplicationDetailScreen> createState() =>_JobApplicationDetailScreenState();
}

class _JobApplicationDetailScreenState extends State<JobApplicationDetailScreen> {
  late JobApplicationViewModel _jobAppVm;

  @override
  void initState() {
    super.initState();
    _jobAppVm = context.read<JobApplicationViewModel>();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    await _jobAppVm.getJobApplicationDetail(widget.idJobPost, widget.idUser);
  }

  Future<void> _onCancelApplication() async {
    final jobApp = _jobAppVm.selectedJobApplication;
    if (jobApp == null) return;

    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Hủy ứng tuyển?",
      message: "Bạn có chắc chắn muốn hủy ứng tuyển này không?",
      icon: Icons.delete_forever_rounded,
      onConfirm: () async {
        _jobAppVm.resetState();
        _jobAppVm.deleteJobApplication(jobApp.idJobPost, jobApp.idUser).then((_) {
          if (!mounted) return;

          if (_jobAppVm.isSuccess) {
            SnackbarApp.show(
              context,
              title: 'Thành công',
              message: 'Đã hủy ứng tuyển thành công',
              backgroundColor: BackgroundColors.backgroundSuccessPrimary,
            );
            context.pop();
            context.push(
              '/job/history/',
              extra: {'idUser': widget.idUser},
            );
          } else if (_jobAppVm.errorMessage != null) {
            SnackbarApp.show(
              context,
              title: 'Lỗi',
              message: 'Hủy ứng tuyển thất bại: ${_jobAppVm.errorMessage }',
              backgroundColor: BackgroundColors.backgroundErrorPrimary,
            );
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<JobApplicationViewModel>();

    final jobApp = viewModel.selectedJobApplication;
    final jobPosting = jobApp?.jobPosting;
    final company = jobPosting?.company;

    if (viewModel.isLoading || jobApp == null) {
      return const Scaffold(
        body: JobApplicationDetailShimmer(),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppbarTitleLarge(title: 'Chi tiết ứng tuyển'),
      body: RefreshIndicator(
        onRefresh: _fetchDetail,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          child: viewModel.errorMessage != null
            ? BackgroundErrorState(
              title: "Hệ thống đang gặp sự cố\nVui lòng thử lại sau.\n ${viewModel.errorMessage}",
              onRetry: _fetchDetail,
            )
            : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trạng thái ứng tuyển
              StatusCard(
                apiStatus: jobApp.applicationStatus,
                submittedAt: jobApp.submittedAt,
              ),
              SizedBox(height: 16.h),

              // Job Info
              JobHistoryCard(
                jobApp: jobApp,
                isShowAction: false,
              ),
              SizedBox(height: 16.h),

              // Mô tả công việc
              SectionTitle(
                title: 'Mô Tả Công Việc',
                icon: Icons.description_rounded,
              ),
              CardMain(
                child: Row(
                  children: [
                    Text(
                      (jobPosting?.description == null || jobPosting!.description.trim().isEmpty)
                          ? 'Chưa có mô tả chi tiết.'
                          : jobPosting.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              // Yêu cầu
              SectionTitle(
                title: 'Yêu Cầu Ứng Viên',
                icon: Icons.checklist_rtl_rounded,
              ),
              CardMain(
                child: Row(
                  children: [
                    Text(
                      (jobPosting?.requirements == null || jobPosting!.requirements.trim().isEmpty)
                          ? 'Chưa có yêu cầu chi tiết.'
                          : jobPosting.requirements,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Thông tin công ty
              SectionTitle(
                title: 'Thông Tin Công Ty',
                icon: Icons.business_rounded,
              ),
              CardMain(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProfileInfoRow(
                      icon: Icons.location_city_rounded,
                      title: company?.companyName ?? 'Chưa có tên công ty',
                      onTap: () {
                        context.push(
                          '/company/detail',
                          extra: {
                            "company": company,
                            "idUser": jobApp.idUser,
                          },
                        );
                      },
                    ),
                    ProfileInfoRow(
                      icon: Icons.nature,
                      title: company?.address ?? 'Chưa có địa chỉ',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Hồ sơ đã nộp
              if (jobApp.cvFileUrl != null ||
                  (jobApp.coverLetter != null &&
                      jobApp.coverLetter!.isNotEmpty)) ...[
                SectionTitle(
                  title: 'Hồ Sơ Đã Nộp',
                  icon: Icons.folder_shared_rounded,
                ),
                CardMain(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (jobApp.cvFileUrl != null)
                        ProfileInfoRow(
                          icon: Icons.picture_as_pdf_rounded,
                          title:
                              'Xem CV đã nộp (${(StringUtils.extractFileName(jobApp.cvFileUrl!))})',
                          onTap: () {
                            print(  jobApp.cvFileUrl);
                            context.push(
                              '/resume/file',
                              extra: {
                                'fileUrl': jobApp.cvFileUrl,
                                'fileName': jobApp.cvFileUrl,
                              },
                            );
                          },
                        ),
                      if (jobApp.cvFileUrl != null &&
                          (jobApp.coverLetter != null &&
                              jobApp.coverLetter!.isNotEmpty))
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Divider(height: 1),
                        ),
                      if (jobApp.coverLetter != null && jobApp.coverLetter!.isNotEmpty) ... [
                        SectionTitle(
                          title: 'Thư Giới Thiệu',
                          icon: Icons.business_rounded,
                        ),
                        CardMain(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ProfileInfoRow(
                                icon: Icons.location_city_rounded,
                                title: jobApp.coverLetter ?? 'Chưa có thư giới thiệu',
                              ),
                            ],
                          ),
                        ),
                      ]

                    ],
                  ),
                ),
              ],

              SizedBox(height: 24.h),

              // Nút hủy ứng tuyển
              CustomButtonBorder(
                title: 'HỦY ỨNG TUYỂN',
                icon: Icons.cancel_schedule_send_outlined,
                onPressed: () async => _onCancelApplication(),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
