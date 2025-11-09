import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/utils/download_file.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/custom_dialog.dart';
import 'package:job_connect/features/resume/view_model/resum_view_model.dart';
import 'package:provider/provider.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/background_empty_state.dart';
import 'package:job_connect/config/widgets/custom_buttom_leading_icon.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/resume/model/resume_model.dart';
import 'package:job_connect/features/resume/widgets/cv_options/create_options_modal.dart';
import 'package:job_connect/features/resume/widgets/cv_options/cv_card.dart';
import 'package:job_connect/features/resume/widgets/cv_options/cv_count_and_filters.dart';
import 'package:job_connect/features/resume/widgets/cv_options/cv_search_bar.dart';
import 'package:job_connect/features/resume/widgets/cv_options/edit_cv_ame_dialog.dart';
import 'package:job_connect/features/resume/widgets/cv_options/filter_dialog.dart';
import 'package:job_connect/features/resume/widgets/cv_options/help_dialog.dart';
import 'package:job_connect/features/resume/widgets/cv_options/upload_progress_indicator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CVOptionsScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;

  const CVOptionsScreen({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
  });

  @override
  State<CVOptionsScreen> createState() => _CVOptionsScreenState();
}

class _CVOptionsScreenState extends State<CVOptionsScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _listAnimationController;

  String _searchTerm = '';
  String _selectedFilter = 'Tất cả';
  PlatformFile? _pickedCvPlatformFile;
  late bool _isUploadingCv;
  late double _uploadProgress;

  @override
  bool get wantKeepAlive => true;

  // TODO: Lifecycle
  @override
  void initState() {
    super.initState();
    _isUploadingCv = false;
    _uploadProgress = 0.0;

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResumeViewModel>().getResumesByUser(idUser: widget.idUser);
      _listAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  // TODO: Refresh dữ liệu
  Future<void> _onRefresh() async {
    _listAnimationController.reset();
    await context.read<ResumeViewModel>().getResumesByUser(idUser: widget.idUser);
    _listAnimationController.forward();
  }

  // TODO: Upload CV
  Future<void> _pickAndUploadCV() async {
    if (_isUploadingCv) {
      if (!mounted) return;
      SnackbarApp.show(
        context,
        title: 'Thông báo',
        message: 'Đang tải lên file khác...',
        backgroundColor: BackgroundColors.backgroundInfoPrimary,
      );
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result == null || result.files.isEmpty) return;

      setState(() {
        _pickedCvPlatformFile = result.files.first;
        _isUploadingCv = true;
        _uploadProgress = 0.1;
      });

      final pickedFile = _pickedCvPlatformFile!;
      final vm = context.read<ResumeViewModel>();

      if (!mounted) return;
      SnackbarApp.show(
        context,
        title: 'Thông báo',
        message: 'Đang tải file: ${pickedFile.name}',
        backgroundColor: BackgroundColors.backgroundInfoPrimary,
      );

      // Giả lập tiến trình upload
      for (double p = 0.2; p <= 0.9; p += 0.2) {
        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;
        setState(() => _uploadProgress = p);
      }

      final resumeModel = ResumeModel(
        idResume: '',
        idUser: widget.idUser,
        fileName: pickedFile.name,
        fileUrl: pickedFile.path ?? '',
        fileId: '',
        fileSizeKB: (pickedFile.size / 1024).ceil(),
        isDefault: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await vm.createResume(resume: resumeModel, file: File(pickedFile.path!));

      if (!mounted) return;

      if (vm.isSuccess) {
        SnackbarApp.show(
          context,
          title: 'Thành công',
          message: 'Tải hồ sơ thành công!',
          backgroundColor: BackgroundColors.backgroundSuccessPrimary,
        );
        await vm.getResumesByUser(idUser: widget.idUser);
      } else {
        SnackbarApp.show(
          context,
          title: 'Thất bại',
          message: vm.errorMessage ?? 'Không thể tạo hồ sơ. Vui lòng thử lại.',
          backgroundColor: BackgroundColors.backgroundErrorPrimary,
        );
      }

      if (!mounted) return;
      setState(() {
        _isUploadingCv = false;
        _uploadProgress = 1.0;
      });
    } catch (e) {
      if (!mounted) return;
      SnackbarApp.show(
        context,
        title: 'Lỗi',
        message: 'Không thể tải lên file: $e',
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
      if (mounted) setState(() => _isUploadingCv = false);
    }
  }

  // TODO: Xóa CV
  void _deleteCV(ResumeModel resumeToDelete) {
    CustomDialog.show(
      context,
      title: "Xóa hồ sơ?",
      message: "Bạn có chắc chắn muốn xóa hồ sơ này không?",
      icon: Icons.delete_forever,
      iconColor: Colors.red,
      confirmButtonColor: Colors.red,
      confirmText: "Xóa",
      cancelText: "Hủy",
      onConfirm: () async {
        final vm = context.read<ResumeViewModel>();
        await vm.deleteResume(
          idResume: resumeToDelete.idResume,
          fileId: resumeToDelete.fileId,
          userId: widget.idUser,
        );

        if (!context.mounted) return;

        if (vm.isSuccess) {
          if(mounted){
              SnackbarApp.show(
              context,
              title: 'Thành công',
              message: 'Đã xóa CV khỏi hệ thống.',
              backgroundColor: Colors.green,
            );
          }
          await vm.getResumesByUser(idUser: widget.idUser);
        } else {
          if(mounted){
            SnackbarApp.show(
              context,
              title: 'Lỗi',
              message: vm.errorMessage ?? 'Không thể xóa CV. Vui lòng thử lại.',
              backgroundColor: BackgroundColors.backgroundErrorPrimary,
            );
          }
        }
      },
    );
  }

  // TODO: Sort & Filter
  void _sortByName(ResumeViewModel vm) {
    vm.resumes.sort((a, b) => a.fileName.compareTo(b.fileName));
    vm.searchResumes(keyword: _searchTerm);
  }

  void _sortByDate(ResumeViewModel vm) {
    vm.resumes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    vm.searchResumes(keyword: _searchTerm);
  }

  void _showFilterDialog() {
    showDialog(context: context, builder: (_) => FilterDialogWidget());
  }

  void _showHelp() {
    showDialog(context: context, builder: (_) => HelpDialogWidget());
  }

  // TODO: Tạo CV mới
  void _showCreateOptions(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CreateOptionsModal(
        theme: theme,
        isUploadingCv: _isUploadingCv,
        uploadProgress: _uploadProgress,
        onUpload: _isUploadingCv
            ? null
            : () {
                context.pop();
                _pickAndUploadCV();
              },
        onAICreate: () {
          context.pop();
          SnackbarApp.show(
            context,
            title: 'Thông báo',
            message: 'Tính năng AI CV sắp ra mắt!',
            backgroundColor: theme.colorScheme.secondary,
          );
        },
        onTemplates: () {
          context.pop();
          context.push('/resume/template');
        },
      ),
    );
  }

  // TODO: Đổi tên CV
  Future<void> _editCVName(BuildContext context, ResumeModel resume) async {
    final controller = TextEditingController(text: resume.fileName);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => EditCVNameDialog(
        controller: controller,
        formKey: formKey,
        onConfirm: (newName) async {
          final updated = resume.copyWith(fileName: newName);
          final vm = context.read<ResumeViewModel>();

          await vm.updateResume(id: resume.idResume, updated: updated);

          if (!context.mounted) return;

          if (vm.isSuccess) {
            SnackbarApp.show(
              context,
              title: 'Thành công',
              message: 'Đã đổi tên CV thành "$newName".',
              backgroundColor: Colors.green,
            );
            await vm.getResumesByUser(idUser: widget.idUser);
          } else {
            SnackbarApp.show(
              context,
              title: 'Lỗi',
              message: vm.errorMessage ?? 'Không thể đổi tên CV.',
              backgroundColor: BackgroundColors.backgroundErrorPrimary,
            );
          }
        },
      ),
    );
  }

  // TODO: Xem / Chia sẻ / Tải xuống CV
  void _viewCV(BuildContext context, ResumeModel resume) {
    print(resume.fileUrl);
    if (resume.fileUrl.isEmpty) {
      SnackbarApp.show(
        context,
        title: 'Lỗi',
        message: 'Không tìm thấy URL file.',
        backgroundColor: BackgroundColors.backgroundErrorPrimary,
      );
      return;
    }
    context.push(
      '/resume/file',
      extra: {
        'fileUrl': resume.fileUrl,
        'fileName': resume.fileName,
      }
    );
  }

  void _shareCV(BuildContext context, ResumeModel resume) {
    if (resume.fileUrl.isNotEmpty) {
      Share.share(
        'Xem CV của tôi: ${resume.fileUrl}',
        subject: 'CV: ${resume.fileName}',
      );
    }
  }

  Future<void> _downloadCV(BuildContext context, ResumeModel resume) async {
    await downloadResumeFile(
      context: context,
      fileUrl: resume.fileUrl,
      fileName: resume.fileName,
    );
  }

  // TODO: Build UI
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Consumer<ResumeViewModel>(
      builder: (context, vm, child) {
        final filteredResumes = vm.filteredResumes.where((r) {
          if (_selectedFilter == 'Tất cả') return true;
          if (_selectedFilter == 'PDF') {
            return r.fileName.toLowerCase().endsWith('.pdf');
          } else if (_selectedFilter == 'Word') {
            return r.fileName.toLowerCase().endsWith('.doc') ||
                r.fileName.toLowerCase().endsWith('.docx');
          }
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: const CustomAppbarTitleLarge(title: "Quản lý CV"),
          body: UnfocusWidget(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          CVSearchBar(
                            onSearchChanged: (v) {
                              _searchTerm = v;
                              vm.searchResumes(keyword: v);
                            },
                            onMenuSelected: (value) {
                              switch (value) {
                                case 'sort_name':
                                  _sortByName(vm);
                                  break;
                                case 'sort_date':
                                  _sortByDate(vm);
                                  break;
                                case 'filter':
                                  _showFilterDialog();
                                  break;
                                case 'help':
                                  _showHelp();
                                  break;
                              }
                            },
                          ),
                          if (_isUploadingCv)
                            UploadProgressIndicator(
                              uploadProgress: _uploadProgress,
                              pickedFile: _pickedCvPlatformFile,
                            ),
                          CvCountAndFilters(
                            selectedFilter: _selectedFilter,
                            onFilterSelected: (f) =>
                                setState(() => _selectedFilter = f),
                          ),
                        ],
                      ),
                    ),
                    vm.isListLoading
                        ? const SliverFillRemaining(
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : filteredResumes.isEmpty
                            ? SliverFillRemaining(
                                child: BackgroundEmptyState(
                                  title: "CV",
                                  subTitle: "Hãy thêm hoặc tải lên CV mới.",
                                  onRefresh: _onRefresh,
                                  isSearching: _searchTerm.isNotEmpty,
                                  iconData: Icons.folder_off_outlined,
                                ),
                              )
                            : SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final resume = filteredResumes[index];
                                    return AnimationConfiguration.staggeredList(
                                      position: index,
                                      duration:
                                          const Duration(milliseconds: 475),
                                      child: SlideAnimation(
                                        verticalOffset: 50.0,
                                        child: FadeInAnimation(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 4.h),
                                            child: CvCard(
                                              resume: resume,
                                              onView: () =>
                                                  _viewCV(context, resume),
                                              onEditName: () =>
                                                  _editCVName(context, resume),
                                              onShare: () =>
                                                  _shareCV(context, resume),
                                              onDownload: () =>
                                                  _downloadCV(context, resume),
                                              onDelete: () =>
                                                  _deleteCV(resume),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: filteredResumes.length,
                                ),
                              ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: CustomButtomLeadingIcon(
            width: 140.w,
            onPressed: () => _showCreateOptions(context),
            text: "Thêm CV",
            icon: Icons.add_rounded,
            iconColor: theme.colorScheme.onPrimary,
            backgroundColor: theme.primaryColor,
            textColor: theme.colorScheme.onPrimary,
          ),
        );
      },
    );
  }
}
