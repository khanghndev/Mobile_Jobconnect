import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/enum/shared_prefs_key.dart';
import 'package:job_connect/config/services/shared_prefs_service.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/config/utils/on_clip_board.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/overlay_loading.dart';
import 'package:job_connect/features/mini_social/model/social_groups_model.dart';
import 'package:job_connect/features/mini_social/widgets/connect/groups_tab.dart';
import 'package:job_connect/features/mini_social/widgets/connect/referral_tab.dart';
import 'package:provider/provider.dart';
import 'package:job_connect/features/mini_social/view_model/social_groups_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SocialConnectsScreen extends StatefulWidget {
  final String idUser;
  final bool isLoggedIn;
  const SocialConnectsScreen({
    super.key,
    required this.idUser,
    required this.isLoggedIn,
  });

  @override
  State<SocialConnectsScreen> createState() => _SocialConnectsScreenState();
}

class _SocialConnectsScreenState extends State<SocialConnectsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SocialGroupsViewModel socialGroupsVm;
  String? referralCode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    socialGroupsVm = context.read<SocialGroupsViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initReferralCode();
      Future.wait([
        socialGroupsVm.getGroupsWithJoinStatus(userId: widget.idUser),
        socialGroupsVm.getPendingGroups(userId: widget.idUser),
        socialGroupsVm.getJoinedGroups(userId: widget.idUser),
        socialGroupsVm.getAllGroups(),
      ]);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Tạo hoặc lấy mã giới thiệu từ local
  Future<void> _initReferralCode() async {
    final prefs = await SharedPreferences.getInstance();
    final sharedPrefsService = SharedPrefsService(prefs: prefs);

    final savedCode = sharedPrefsService.getString(SharedPrefsKey.referralCode);

    if (savedCode != null && savedCode.isNotEmpty) {
      setState(() => referralCode = savedCode);
    } else {
      final newCode = _generateReferralCode(widget.idUser);
      await sharedPrefsService.saveString(SharedPrefsKey.referralCode, newCode);
      setState(() => referralCode = newCode);
    }
  }

  /// Sinh mã giới thiệu ngẫu nhiên (kết hợp ID user)
  String _generateReferralCode(String userId) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final randomPart = List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
    return '${userId.substring(0, min(3, userId.length)).toUpperCase()}$randomPart';
  }

  void _onShareCode(){

  }
  void _onGoToGroup(String idGroup) {
    context.push(
      '/social/group',
      extra: {
        'idGroup': idGroup,
        'isLoggedIn': widget.isLoggedIn,
        'idUser': widget.idUser,
      },
    );
  }
  void _onJoinGroup(SocialGroupsModel socialGroupsModel) {
    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Tham gia nhóm",
      message: "Bạn muốn tham gia nhóm ${socialGroupsModel.groupName}?",
      icon: Icons.group_add,
      onConfirm: () async {
        socialGroupsVm.joinGroup(
          idGroup: socialGroupsModel.idGroup,
          userId: widget.idUser,
        );
        if(socialGroupsVm.isSuccess){
          context.pop();
          _onGoToGroup(socialGroupsModel.idGroup);
        } else if(socialGroupsVm.errorMessage != null){
          context.pop();
          SnackbarApp.show(
            context,
            title: 'Tham gia nhóm thất bại',
            message: 'Lỗi tham gia nhóm: ${socialGroupsVm.errorMessage}',
            backgroundColor: BackgroundColors.backgroundErrorPrimary,
          );
        }
      },
    );
  }

  void _onCreateGroup(){
    context.push(
      '/social/create-group',
    );
  }

  @override
  Widget build(BuildContext context) {
    final socialGroupsVm = context.watch<SocialGroupsViewModel>();

    return OverlayLoading(
      isLoading: socialGroupsVm.isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new, 
              color: Colors.black, 
              size: 22.sp,
            ),
            onPressed: () => context.pop(),
          ),
          title: Text(
            "Kết nối việc làm",
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.bold),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.h),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.black,
                labelStyle:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
                unselectedLabelStyle:
                    TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: const Text("Giới thiệu của bạn"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Text("Tham gia nhóm (${socialGroupsVm.allGroups.length})"),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: referralCode == null
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                ReferralTabWidget(
                  referralCode: referralCode!,
                  rewardPoints: 1000,
                  imagePath: AppImages.connect,
                  onCopy: () {
                    OnClipBoard.copyToClipboard(
                      context: context,
                      titleCopy: referralCode!,
                      subtitleCopy: "Referral code",
                    );
                  },
                  onShare: _onShareCode
                ),
                Consumer<SocialGroupsViewModel>(
                  builder: (context, viewModel, _) {
                    return GroupsTab(
                      isLoading: viewModel.isLoading,
                      errorMessage: viewModel.errorMessage,
                      joinedGroups: viewModel.joinedGroups,
                      pendingGroups: viewModel.pendingGroups,
                      notJoinedGroups: viewModel.notJoinedGroups,
                      onRefresh: () => viewModel.getGroupsWithJoinStatus(userId: widget.idUser),
                      onTapGroup: _onGoToGroup,
                      onJoinGroup: _onJoinGroup,
                      onCreateGroup: _onCreateGroup,
                    );
                  },
                )
              ],
            ),
      ),
    );
  }
}
