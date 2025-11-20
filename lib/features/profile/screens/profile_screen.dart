import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/config/widgets/custom_button_border.dart';
import 'package:job_connect/config/widgets/overlay_loading.dart';
import 'package:job_connect/features/auth/viewmodel/auth_view_model.dart';
import 'package:job_connect/features/home/view_model/job_saved_view_model.dart';
import 'package:job_connect/features/job/view_model/job_application_view_model.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/view_model/candidate_info_view_model.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:job_connect/features/profile/widgets/profile/profile_button_logout.dart';
import 'package:job_connect/features/profile/widgets/profile/profile_header_card.dart';
import 'package:job_connect/features/profile/widgets/profile/profile_info_row.dart';
import 'package:job_connect/features/profile/widgets/profile/profile_section_card.dart';
import 'package:job_connect/features/profile/widgets/profile/profile_skills_section.dart';
import 'package:job_connect/features/profile/widgets/profile/profile_un_loggin.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'edit_profile_screen.dart';

class ProfilePageScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;
  const ProfilePageScreen({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
  });

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePageScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _fabPulseController;
  final ScrollController _scrollController = ScrollController();

  late UserViewModel userViewModel;
  late CandidateInfoViewModel candidateViewModel;
  late AuthViewModel authViewModel;
  late JobApplicationViewModel jobApplicationViewModel;
  late JobSavedViewModel jobSavedViewModel;

  bool _isLoading = true;

  bool get isLoggedIn => widget.isLoggedIn;

  @override
  void initState() {
    super.initState();
    userViewModel = context.read<UserViewModel>();
    candidateViewModel = context.read<CandidateInfoViewModel>();
    authViewModel = context.read<AuthViewModel>();
    jobApplicationViewModel = context.read<JobApplicationViewModel>();
    jobSavedViewModel = context.read<JobSavedViewModel>();

    _fabPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onRefresh();
    });
  }

  @override
  void dispose() {
    _fabPulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        userViewModel.getCurrentUser(widget.idUser),
        candidateViewModel.getCandidateDetail(widget.idUser),
        jobApplicationViewModel.getJobApplicationsByUser(widget.idUser),
        jobSavedViewModel.fetchSavedJobsByUser(widget.idUser),
      ]);
    } catch (e) {
      debugPrint("Error refreshing profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onOpenEditProfile() async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditProfilePage(idUser: widget.idUser),
      ),
    );
    if (result == true) {
      _onRefresh();
    }
  }

  double _onCompletion(UserModel? account, CandidateInfoViewModel candidateVM) {
    final candidate = candidateVM.candidateDetail;
    if (account == null && candidate == null) return 0.0;
    double currentScore = 0;
    const double maxScore = 101;

    if (account != null) {
      if (account.avatarUrl?.isNotEmpty ?? false) currentScore += 10;
      if (account.userName.isNotEmpty) currentScore += 5;
      if (account.email.isNotEmpty) currentScore += 10;
      if (account.phoneNumber?.isNotEmpty ?? false) currentScore += 10;
      if (account.dateOfBirth != null) currentScore += 5;
      if (account.gender.isNotEmpty) currentScore += 3;
      if (account.address?.isNotEmpty ?? false) currentScore += 7;
    }

    if (candidate != null) {
      if (candidate.workPosition?.isNotEmpty ?? false) currentScore += 10;
      if (candidate.universityName?.isNotEmpty ?? false) currentScore += 8;
      if (candidate.educationLevel?.isNotEmpty ?? false) currentScore += 8;
      if ((candidate.experienceYears ?? 0) > 0) currentScore += 10;
      if (candidate.skills?.isNotEmpty ?? false) currentScore += 15;
    }

    return (currentScore / maxScore).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final userVM = context.watch<UserViewModel>();
    final candidateVM = context.watch<CandidateInfoViewModel>();
    final jobAppVM = context.watch<JobApplicationViewModel>();
    final jobSavedVM = context.watch<JobSavedViewModel>();
    final account = userVM.currentUser;
    final candidateInfo = candidateVM.candidateDetail;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: !isLoggedIn
          ? ProfileUnLoggin()
          : SafeArea(
              minimum: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 16.w),
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      SizedBox(height: 16.w),
                      ProfileHeaderCard(
                        idUser: widget.idUser,
                        completion: _onCompletion(account, candidateVM),
                        applicationCount: jobAppVM.applications.length,
                        savedJobsCount: jobSavedVM.savedJobs.length,
                        onOpenEditProfile: _onOpenEditProfile,
                        userName: account?.userName,
                        avatarUrl: account?.avatarUrl,
                      ),
                      SizedBox(height: 16.w),
                      ProfileSectionCard(
                        title: "Thông Tin Cá Nhân",
                        titleIcon: Icons.face_retouching_natural,
                        children: [
                          ProfileInfoRow(
                            icon: Icons.person_4_outlined,
                            title: account?.userName ?? "Chưa cập nhật",
                            subtitle: "Họ và tên",
                          ),
                          ProfileInfoRow(
                            icon: Icons.celebration_outlined,
                            title: account?.dateOfBirth != null
                                ? DateFormat('dd/MM/yyyy')
                                    .format(account!.dateOfBirth!)
                                : "Chưa cập nhật",
                            subtitle: "Ngày sinh",
                          ),
                          ProfileInfoRow(
                            icon: Icons.wc_outlined,
                            title: account?.gender.toLowerCase() == "male"
                                ? "Nam"
                                : account?.gender.toLowerCase() == "female"
                                    ? "Nữ"
                                    : "Chưa cập nhật",
                            subtitle: "Giới tính",
                          ),
                        ],
                      ),
                      SizedBox(height: 16.w),
                      ProfileSectionCard(
                        title: "Học Vấn & Sự Nghiệp",
                        titleIcon: Icons.auto_stories_outlined,
                        children: [
                          ProfileInfoRow(
                            icon: Icons.account_balance_outlined,
                            title: candidateInfo?.universityName ?? "Chưa có trường",
                            subtitle: "Trường Đại học",
                          ),
                          ProfileInfoRow(
                            icon: Icons.workspace_premium_outlined,
                            title: candidateInfo?.educationLevel ?? "Chưa có trình độ",
                            subtitle: "Trình độ học vấn",
                          ),
                          ProfileInfoRow(
                            icon: Icons.workspaces_outline,
                            title: candidateInfo?.workPosition ?? "Chưa có vị trí",
                            subtitle: "Vị trí mong muốn",
                          ),
                          ProfileInfoRow(
                            icon: Icons.model_training_outlined,
                            title: candidateInfo?.experienceYears != null
                                ? "${candidateInfo!.experienceYears} năm"
                                : "Chưa có kinh nghiệm",
                            subtitle: "Kinh nghiệm",
                          ),
                        ],
                      ),
                      SizedBox(height: 16.w),
                      ProfileSkillsSection(
                        skills: candidateInfo?.skills
                                ?.split(',')
                                .map((e) => e.trim())
                                .where((e) => e.isNotEmpty)
                                .toList() ??
                            [],
                      ),
                      SizedBox(height: 16.w),
                      CustomButtonBorder(
                        title: isLoggedIn ? "Đăng xuất" : "Đăng nhập",
                        icon: isLoggedIn
                            ? Icons.logout_outlined
                            : Icons.login_outlined,
                        onPressed: () => isLoggedIn
                            ? DialogUtils.showLogoutDialog(context)
                            : context.push('/auth/login',
                                extra: {'role': UserRole.candidate.name}),
                      ),
                      SizedBox(height: 80.h),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(parent: _fabPulseController, curve: Curves.easeInOut),
        ),
        child: !isLoggedIn
            ? const SizedBox.shrink()
            : ProfileButtonLogout(
                onPressed: _onOpenEditProfile,
                icon: Icons.edit,
                title: "Chỉnh sửa hồ sơ",
                backgroundColor: theme.colorScheme.primary,
              ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
