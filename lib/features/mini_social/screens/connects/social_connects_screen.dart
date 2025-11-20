import 'dart:math';
import 'package:collection/collection.dart';
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
import 'package:job_connect/features/mini_social/model/conversation_model.dart';
import 'package:job_connect/features/mini_social/model/social_groups_model.dart';
import 'package:job_connect/features/mini_social/view_model/conversation_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/message_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_connection_view_model.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/share_bottom_sheet.dart';
import 'package:job_connect/features/mini_social/widgets/connect/groups_tab.dart';
import 'package:job_connect/features/mini_social/widgets/connect/referral_tab.dart';
import 'package:job_connect/features/mini_social/widgets/connect/referral_tab_shimmer.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
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
  late final SocialGroupsViewModel socialGroupVm;
  late final UserViewModel userVm;
  late final ConversationViewModel conversationViewModel;
  late final MessageViewModel messageViewModel;
  late final SocialConnectionViewModel socialConnectionVm;
  String? referralCode;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    socialGroupsVm = context.read<SocialGroupsViewModel>();
    socialGroupVm = context.read<SocialGroupsViewModel>();
    userVm = context.read<UserViewModel>();
    conversationViewModel = context.read<ConversationViewModel>();
    messageViewModel = context.read<MessageViewModel>();
     socialConnectionVm = context.read<SocialConnectionViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initReferralCode();

      if (widget.isLoggedIn && userVm.currentUser != null) {
        await socialConnectionVm.getFriends(userId: userVm.currentUser!.idUser);
      }

      if (userVm.currentUser != null) {
        await Future.wait([
          socialGroupsVm.getGroupsWithJoinStatus(userId: widget.idUser),
          socialGroupsVm.getAllGroups(),
          conversationViewModel.fetchConversationsByUser(
            userId: userVm.currentUser!.idUser,
          ),
        ]);
      } else {
        await Future.wait([
          socialGroupsVm.getGroupsWithJoinStatus(userId: widget.idUser),
          socialGroupsVm.getAllGroups(),
        ]);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Tạo hoặc lấy mã giới thiệu từ local
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

  // Sinh mã giới thiệu ngẫu nhiên (kết hợp ID user)
  String _generateReferralCode(String userId) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final randomPart = List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
    return '${userId.substring(0, min(3, userId.length)).toUpperCase()}$randomPart';
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

  void _onDeleteGroup(String idGroup){
    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Xóa nhóm của bạn",
      message: "Bạn muốn xóa nhóm này không?",
      icon: Icons.delete_forever_rounded,
      onConfirm: () async {
        socialGroupsVm.deleteGroup(id: idGroup, userId: widget.idUser);
        if(socialGroupsVm.isSuccess){
          SnackbarApp.show(
            context,
            message: 'Xóa thành công',
            backgroundColor: BackgroundColors.backgroundSuccessPrimary
          );
        } else if (socialGroupsVm.errorMessage != null){
          SnackbarApp.show(
            context,
            message: 'Lỗi khi xóa nhóm: ${socialGroupsVm.errorMessage}',
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

  Future<void> _showBottomSheetWrapper(Widget child) async {
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) => Padding(
          padding: EdgeInsets.all(8.w),
          child: child,
        ),
      ),
    );
  }
  
  Future<void> _onShareCode(String referralCode, String targetUserId) async {
    final currentUserId = userVm.currentUser?.idUser;
    if (currentUserId == null) return;

    ConversationModel? conversation = conversationViewModel.conversations.firstWhereOrNull(
      (c) =>
        c.members.contains(currentUserId) &&
        c.members.contains(targetUserId) &&
        c.members.length == 2, // đảm bảo là 1-1 conversation
    );

      conversation ??= await conversationViewModel.createConversation(
        memberIds: [currentUserId, targetUserId],
      );

    if (conversation == null) return;

    await messageViewModel.createMessage(
      idConversation: conversation.idConversation,
      idSender: currentUserId,
      content: 'Nhập mã giới thiệu để được cộng điểm $referralCode',
      messageType: 'text',
    );

    final otherUser = await userVm.getViewUser(targetUserId);
    if (!mounted) return;

    context.push('/social/messenger-detail', extra: {
      'isLoggedIn': widget.isLoggedIn,
      'idUser': widget.idUser,
      'conversationId': conversation.idConversation,
      'otherUserName': otherUser?.userName,
      'otherUserId': otherUser?.idUser,
      'otherUserAvatar': otherUser?.avatarUrl,
      'currentUserAvatar': userVm.currentUser?.avatarUrl ?? '',
    });
  }

  Future<void> _showShareCodeSheet(String referralCode) async {
    await socialConnectionVm.getFriends(userId: userVm.currentUser!.idUser);
    await _showBottomSheetWrapper(
      Consumer<SocialConnectionViewModel>(
        builder: (context, vm, _) => ShareBottomSheet(
          postId: referralCode,
          titleSheet: "Chia sẽ mã giới thiệu",
          listFriend: vm.friends,
          isLoading: vm.isLoading,
          onSendMessage: (targetUserId, referralCode) => _onShareCode(referralCode, targetUserId),
        ),
      ),
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
                labelStyle:TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp, color: Colors.white),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp, color: Colors.black),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Text(
                      "Giới thiệu của bạn",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Text(
                      "Tham gia nhóm (${socialGroupsVm.allGroups.length})",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 14.sp
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body:TabBarView(
          controller: _tabController,
          children: [
            referralCode == null
            ? const ReferralTabShimmer()
            : ReferralTabWidget(
              referralCode: referralCode!,
              rewardPoints: 1000,
              imagePath: AppImages.connect,
              onCopy: () {
                OnClipBoard.copyToClipboard(
                  context: context,
                  titleCopy: referralCode!,
                  subtitleCopy: "Mã giới thiệu",
                );
              },
              onShare: () => _showShareCodeSheet(referralCode!),
            ),
            Consumer<SocialGroupsViewModel>(
              builder: (context, viewModel, _) {
                return GroupsTab(
                  isLoading: viewModel.isLoading,
                  errorMessage: viewModel.errorMessage,
                  joinedGroups: viewModel.joinedGroups,
                  pendingGroups: viewModel.pendingGroups,
                  notJoinedGroups: viewModel.notJoinedGroups,
                  myGroups: viewModel.myGroups,
                  onRefresh: () => viewModel.getGroupsWithJoinStatus(userId: widget.idUser),
                  onTapGroup: _onGoToGroup,
                  onJoinGroup: _onJoinGroup,
                  onCreateGroup: _onCreateGroup,
                  onDeleteGroup: (id) => _onDeleteGroup(id),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
