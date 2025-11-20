import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/enum/job_application_status.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/overlay_loading.dart';
import 'package:job_connect/features/job/view_model/job_application_view_model.dart';
import 'package:job_connect/features/resume/view_model/resum_view_model.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/widgets/app_dialog.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/custom_submit_button.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/resume/model/resume_model.dart';
import 'package:job_connect/features/job/widgets/apply_job/apply_job_cover_letter_input.dart';
import 'package:job_connect/features/job/widgets/apply_job/apply_job_header.dart';
import 'package:job_connect/features/job/widgets/apply_job/apply_tips_card.dart';
import 'package:job_connect/features/job/widgets/apply_job/cv_selection_section.dart';
import 'package:job_connect/features/job/model/job_application_model.dart';

class ApplyJobScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;
  final String companyName;
  final String idUser;

  const ApplyJobScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
    required this.companyName,
    required this.idUser,
  });

  @override
  State<ApplyJobScreen> createState() => _ApplyJobScreenState();
}

class _ApplyJobScreenState extends State<ApplyJobScreen> with TickerProviderStateMixin {
  File? selectedCVFile;
  final TextEditingController _coverLetterCon = TextEditingController();
  String? _selectedSavedCvUrl;
  String? _selectedSavedCvName;
  String? selectedCVFileName;

  bool _isCvListExpanded = false;
  bool _isSubmitting = false;

  late AnimationController _formAnimationController;
  late Animation<double> _formFadeAnimation;

  @override
  void initState() {
    super.initState();
    _formAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _formFadeAnimation = CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeInOut,
    );
    _formAnimationController.forward();

    // Load danh sách CV từ ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResumeViewModel>().getResumesByUser(idUser: widget.idUser);
    });
  }

  @override
  void dispose() {
    _coverLetterCon.dispose();
    _formAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickCV() async {
    final resumeViewModel = context.read<ResumeViewModel>();

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result == null || result.files.single.path == null) return;

      final pickedFile = result.files.single;
      final file = File(pickedFile.path!);
      final fileName = pickedFile.name;

      if (mounted) {
        SnackbarApp.show(
          context,
          title: 'Đang tải lên...',
          message: 'Vui lòng chờ trong giây lát.',
          backgroundColor: Colors.blueAccent,
        );
      }

      // Upload file lên Appwrite qua ViewModel
      await resumeViewModel.createResume(
        resume: ResumeModel(
          idResume: '',
          idUser: widget.idUser,
          fileName: fileName,
          fileUrl: '', // sẽ được BE trả về
          fileId: '',
          fileSizeKB: (pickedFile.size / 1024).ceil(),
          isDefault: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        file: file,
      );

      if (!mounted) return;

      if (resumeViewModel.isSuccess && resumeViewModel.lastCreatedResume != null) {
        final uploadedResume = resumeViewModel.lastCreatedResume!;

        setState(() {
          selectedCVFile = file;
          selectedCVFileName = uploadedResume.fileName;
          _selectedSavedCvName = uploadedResume.fileName;
        });

        SnackbarApp.show(
          context,
          title: 'Thành công',
          message: 'Tải lên CV thành công!',
          backgroundColor: Colors.green,
        );
      } else {
        SnackbarApp.show(
          context,
          title: 'Lỗi',
          message: resumeViewModel.errorMessage ?? 'Không thể tải lên CV.',
          backgroundColor: Colors.redAccent,
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarApp.show(
          context,
          title: 'Lỗi',
          message: 'Đã xảy ra lỗi khi tải lên CV.',
          backgroundColor: Colors.redAccent,
        );
      }
    }
  }

  Future<void> _onSubmitApplication() async {
    final jobVm = context.read<JobApplicationViewModel>();
    final resumeVm = context.read<ResumeViewModel>();

    String? finalCvUrlToSend;
    String? finalCvNameToDisplay;

    // Nếu user vừa upload CV => lấy link từ BE
    if (resumeVm.lastCreatedResume != null) {
      finalCvUrlToSend = resumeVm.lastCreatedResume!.fileUrl;
      finalCvNameToDisplay = resumeVm.lastCreatedResume!.fileName;
    }
    // Nếu user chọn từ CV đã lưu
    else if (_selectedSavedCvUrl != null) {
      finalCvUrlToSend = _selectedSavedCvUrl;
      finalCvNameToDisplay = _selectedSavedCvName;
    }

    if (finalCvUrlToSend == null) {
      SnackbarApp.show(
        context,
        title: 'Thông báo',
        message: 'Vui lòng chọn hoặc tải lên một CV để ứng tuyển.',
        backgroundColor: BackgroundColors.backgroundInfoPrimary,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final newApplication = JobApplicationModel(
      idJobPost: widget.jobId,
      idUser: widget.idUser,
      cvFileUrl: finalCvUrlToSend, // ✅ luôn là link thật từ Appwrite
      coverLetter: _coverLetterCon.text.trim(),
      submittedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      applicationStatus: JobApplicationStatus.pending.name,
    );

    await jobVm.createJobApplication(newApplication);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (jobVm.isSuccess) {
      AppDialog.show(
        context,
        title: "Nộp Hồ Sơ Thành Công!",
        icon: Icons.check_circle_outline_rounded,
        iconColor: Theme.of(context).colorScheme.primary,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hồ sơ của bạn cho vị trí: ${widget.jobTitle}"),
            SizedBox(height: 8),
            Text("Sử dụng CV: $finalCvNameToDisplay"),
            SizedBox(height: 8),
            Text("Đã được gửi đến nhà tuyển dụng."),
            SizedBox(height: 12),
            Text(
              "Bạn có thể theo dõi trong 'Lịch sử ứng tuyển'.",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
              context.push('/job/history/', extra: {'idUser': widget.idUser});
            },
            child: const Text("XEM LỊCH SỬ"),
          ),
          ElevatedButton(
            onPressed: () {
              context.pop();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text("VỀ TRANG CHỦ"),
          ),
        ],
      );
    } else {
      SnackbarApp.show(
        context,
        title: 'Lỗi',
        message: jobVm.errorMessage ?? 'Không thể gửi ứng tuyển.',
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resumeVm = context.watch<ResumeViewModel>();
    final savedCVs = resumeVm.resumes;

    return OverlayLoading(
      isLoading: _isSubmitting,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: const CustomAppbarTitleLarge(title: "Ứng tuyển công việc"),
        body: SafeArea(
          child: UnfocusWidget(
            child: FadeTransition(
              opacity: _formFadeAnimation,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  ApplyJobHeader(
                    jobTitle: widget.jobTitle,
                    companyName: widget.companyName,
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionTitle(
                          title: "Chọn Hồ Sơ CV",
                          icon: Icons.file_present_rounded,
                        ),
                        CvSelectionSection(
                          savedCVs: savedCVs,
                          selectedSavedCvUrl: _selectedSavedCvUrl,
                          selectedSavedCvName: _selectedSavedCvName,
                          selectedCVFileName: selectedCVFileName,
                          hasLocalFile: selectedCVFile != null,
                          isExpanded: _isCvListExpanded,
                          onPickCv: _pickCV,
                          onRemoveCv: () {
                            setState(() {
                              selectedCVFile = null;
                              selectedCVFileName = null;
                              _selectedSavedCvUrl = null;
                              _selectedSavedCvName = null;
                            });
                          },
                          onSelectSavedCv: (resume) {
                            setState(() {
                              _selectedSavedCvUrl = resume.fileUrl;
                              _selectedSavedCvName = resume.fileName;
                              selectedCVFile = null;
                              selectedCVFileName = null;
                            });
                          },
                          onToggleExpand: (expanded) {
                            setState(() => _isCvListExpanded = expanded);
                          },
                        ),
                        SizedBox(height: 24.h),
                        SectionTitle(
                          title: "Thư Giới Thiệu",
                          icon: Icons.mail_outline_rounded,
                        ),
                        ApplyJobCoverLetterInput(controller: _coverLetterCon),
                        SizedBox(height: 24.h),
                        CustomSubmitButton(
                          isLoading: _isSubmitting,
                          onPressed: _onSubmitApplication,
                          label: "GỬI ỨNG TUYỂN NGAY",
                          icon: Icons.send_and_archive_rounded,
                        ),
                        SizedBox(height: 24.h),
                        ApplyTipsCard(
                          title: "Mẹo Nhỏ Cho Bạn",
                          tips: AppStrings.applyTipsList,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
