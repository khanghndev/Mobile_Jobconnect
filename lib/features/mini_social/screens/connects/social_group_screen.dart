import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/enum/messenger_type.dart';
import 'package:job_connect/config/widgets/background_empty_state.dart';
import 'package:job_connect/config/widgets/custom_button_icon_simple.dart';
import 'package:job_connect/config/widgets/reusable_bottom_sheet.dart';
import 'package:job_connect/features/mini_social/model/conversation_model.dart';
import 'package:job_connect/features/mini_social/widgets/social_group/social_group_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/widgets/background_error_state.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/create_post_input.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_item.dart';
import 'package:job_connect/features/mini_social/widgets/social_group/group_app_bar.dart';
import 'package:job_connect/features/mini_social/widgets/social_group/group_header.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/save_bottom_sheet.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/comment_bottom_sheet.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/share_bottom_sheet.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';
import 'package:job_connect/features/mini_social/model/social_comment_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_post_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_save_post_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_groups_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_comment_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_connection_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/conversation_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/message_view_model.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:job_connect/config/enum/post_type.dart';

class SocialGroupScreen extends StatefulWidget {
  final String idGroup;
  final String idUser;
  final bool isLoggedIn;

  const SocialGroupScreen({
    super.key,
    required this.idGroup,
    required this.idUser,
    required this.isLoggedIn,
  });

  @override
  State<SocialGroupScreen> createState() => _SocialGroupScreenState();
}

class _SocialGroupScreenState extends State<SocialGroupScreen> with SingleTickerProviderStateMixin {
  // ViewModels
  late final SocialGroupsViewModel socialGroupVm;
  late final SocialPostViewModel socialPostVm;
  late final SocialSavePostViewModel socialSaveVm;
  late final SocialCommentViewModel socialCommentVm;
  late final UserViewModel userVm;
  late final SocialConnectionViewModel socialConnectionVm;
  late final ConversationViewModel conversationViewModel;
  late final MessageViewModel messageViewModel;

  // Controllers
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _folderController = TextEditingController();

  // Animation
  late final AnimationController _animationController;

  // State
  bool _showFab = false;
  bool _isLoading = true; 
  bool _isJoinSheetOpen = false;
  String selectedFilter = "Mới nhất";

  @override
  void initState() {
    super.initState();

    // Gán ViewModel
    socialGroupVm = context.read<SocialGroupsViewModel>();
    socialPostVm = context.read<SocialPostViewModel>();
    socialSaveVm = context.read<SocialSavePostViewModel>();
    socialCommentVm = context.read<SocialCommentViewModel>();
    userVm = context.read<UserViewModel>();
    socialConnectionVm = context.read<SocialConnectionViewModel>();
    conversationViewModel = context.read<ConversationViewModel>();
    messageViewModel = context.read<MessageViewModel>();

    // Load dữ liệu sau khi build xong
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadGroupData();
      if (widget.isLoggedIn && userVm.currentUser != null) {
        await socialConnectionVm.getFriends(userId: userVm.currentUser!.idUser);
      }
      await conversationViewModel.fetchConversationsByUser(userId: userVm.currentUser!.idUser);
    });

    // Scroll listener để show/hide FAB
    _scrollController.addListener(() {
      final shouldShow = _scrollController.offset > 300;
      if (shouldShow != _showFab) setState(() => _showFab = shouldShow);
    });

    // Animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

  }

  @override
  void didUpdateWidget(covariant SocialGroupScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.idGroup != widget.idGroup) {
      // Reset posts cũ và show spinner
      socialPostVm.clearPosts();
      _loadGroupData();
    }
  }

  List<FilterOption> getControlOptions() {
  final group = socialGroupVm.selectedGroup;
  if (group == null) return [];

  final isOwner = group.createdBy == widget.idUser; // Chủ nhóm
  final isMember = socialGroupVm.isUserMember(groupId: group.idGroup); // Thành viên
  final isPending = socialGroupVm.isUserPending(groupId: group.idGroup); // Đang chờ duyệt

  List<FilterOption> options = [];

  if (isOwner) {
    // Nếu là chủ nhóm, có thể quản lý và xóa nhóm
    options.addAll([
      FilterOption(
        icon: Icons.manage_accounts_outlined,
        title: "Quản lý nhóm",
        value: "Quản lý nhóm",
        iconColor: Colors.black,
        onTapItem: () {
          context.push('/social/manage-group', extra: {
            'idGroup': group.idGroup,
            'idUser' : widget.idUser
          });
        },
      ),
      FilterOption(
        icon: Icons.manage_history_outlined,
        title: "Quản lý bài viết",
        value: "Quản lý bài viết",
        iconColor: Colors.black,
        onTapItem: () {
          context.push(
            '/social/manage-post-group', 
            extra: {
              'idGroup': group.idGroup,
              'idUser' : widget.idUser,
              'isLoggedIn': widget.isLoggedIn
            }
          );
        },
      ),
      FilterOption(
        icon: Icons.delete_forever_outlined,
        title: "Xóa nhóm",
        value: "Xóa nhóm",
        iconColor: Colors.red,
        onTapItem: () async {
          DialogUtils.showConfirmationDialog(
            context: context,
            title: "Xóa nhóm",
            message: "Bạn có chắc muốn xóa nhóm này không?",
            icon: Icons.delete_forever_rounded,
            onConfirm: () async{
              await socialGroupVm.deleteGroup(id: group.idGroup, userId: widget.idUser);
              if(socialGroupVm.isSuccess){
                if (context.canPop()) context.pop();
                  SnackbarApp.show(
                    context,
                    title: "Đã xóa nhóm",
                    message: "Nhóm đã được xóa thành công",
                    backgroundColor: Colors.green,
                  );
                } else if (socialGroupVm.errorMessage != null){
                  SnackbarApp.show(
                    context,
                    title: "Đã xóa nhóm",
                    message: "Nhóm đã được xóa thất bại",
                    backgroundColor: Colors.green,
                  );
                }
              }
          );
        },
      ),
    ]);
  } else if (isMember) {
    // Nếu là thành viên, có thể rời nhóm
    options.add(
      FilterOption(
        icon: Icons.logout,
        title: "Rời nhóm",
        value: "Rời nhóm",
        iconColor: Colors.red,
        onTapItem: () async {
          await socialGroupVm.leaveGroup(
            idGroup: group.idGroup,
            userId: widget.idUser,
          );
          SnackbarApp.show(
            context,
            title: "Bạn đã rời nhóm",
            message: "Bạn đã rời nhóm thành công",
            backgroundColor: Colors.green,
          );
          setState(() {});
        },
      ),
    );
  } else if (isPending) {
    // Nếu đang chờ duyệt, hiển thị trạng thái pending
    options.add(
      FilterOption(
        icon: Icons.hourglass_top,
        title: "Đang chờ duyệt",
        value: "Đang chờ duyệt",
        iconColor: Colors.orange,
        onTapItem: null,
      ),
    );
  } else {
    // Nếu chưa tham gia, hiển thị join
    options.add(
      FilterOption(
        icon: Icons.group_add,
        title: "Tham gia nhóm",
        value: "Tham gia nhóm",
        iconColor: Colors.blue,
        onTapItem: () async {
          await socialGroupVm.joinGroup(
            idGroup: group.idGroup,
            userId: widget.idUser,
          );
          SnackbarApp.show(
            context,
            title: "Đã tham gia nhóm",
            message: "Bạn đã tham gia nhóm",
            backgroundColor: Colors.green,
          );
          setState(() {});
        },
      ),
    );
  }

  return options;
}

  Future<void> _loadGroupData() async {
    setState(() => _isLoading = true); // bắt đầu loading
    try {
      await socialGroupVm.getGroupById(id: widget.idGroup);
      if (userVm.roleName == null) await userVm.loadRoleName();
      if (socialGroupVm.selectedGroup != null && widget.isLoggedIn && userVm.currentUser != null) {
        // await socialPostVm.getAllPostsOfGroup(
        //   groupId: widget.idGroup,
        //   currentUserId: userVm.currentUser!.idUser,
        // );
        await socialPostVm.getAllPosts();
      }
    } finally {
      if (mounted) setState(() => _isLoading = false); // kết thúc loading
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    _folderController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void onFirstPage() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }

  void _onCreatePost() {
    context.push(
      '/social/create-post',
      extra: {
        'idUser': widget.idUser,
        'groupId': widget.idGroup,
        'groupName': socialGroupVm.selectedGroup?.groupName,
      },
    );
  }

  void _onDeletePost(String idPost) {
    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Xóa bài viết",
      message: "Bạn muốn xóa bài viết này?",
      icon: Icons.delete_forever_rounded,
      onConfirm: () async {
        await socialPostVm.deletePost(idPost);
        context.pop();
      },
    );
  }

  void _onOpenDetail(SocialPostModel post) {
    context.push(
      '/social/detail-post',
      extra: {
        'socialPostModel': post,
        'isLoggedIn': true, // hoặc lấy từ trạng thái hiện tại
        'idUser': userVm.currentUser?.idUser ?? '',
      },
    );
  }

  void _onSavePost(SocialPostModel post) async {
    if (post.isSaved) {
      await socialSaveVm.deleteSavedPost(post.idPost);
      socialPostVm.updateLocalSavedState(post.idPost, false);
      SnackbarApp.show(
        context,
        title: 'Đã bỏ lưu',
        message: 'Bài viết đã được xóa khỏi bộ sưu tập',
        backgroundColor: BackgroundColors.backgroundWarningPrimary,
      );
      return;
    }

    _onShowBottomSheet('save', post.idPost);
  }

  void _onOpenEditPost(SocialPostModel post) {
    context.push('/social/edit-post', extra: {'socialPostModel': post});
  }

  void _onOpenProfile(String idUser) {
    context.push('/social/profile', extra: {'idUser': idUser});
  }

  void _onReport(SocialPostModel post) {
    context.push(
      '/social/report',
      extra: {
        'userName': userVm.currentUser?.userName ?? '',
        'authorName': post.userName ?? 'Người dùng',
      },
    );
  }

  void _onShowBottomSheet(String type, String postId) {
    switch (type) {
      case 'comment':
        _showCommentSheet(postId);
        break;
      case 'save':
        _showSaveSheet(postId);
        break;
      case 'share':
        _showShareSheet(postId);
        break;
    }
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

  Future<void> _showCommentSheet(String postId) async {
    if (mounted) {
      socialCommentVm.loadCommentsWithUsers(postId: postId, userVm: userVm);
    }
    await _showBottomSheetWrapper(
      Consumer<SocialCommentViewModel>(
        builder: (context, vm, _) => CommentBottomSheet(
          commentController: _commentController,
          comments: vm.comments,
          isLoading: vm.isLoading,
          errorMessage: vm.errorMessage,
          onSubmit: (text, parentId, imagePath, icon) async {
            final hasContent = text.isNotEmpty || imagePath != null || icon != null;
            if (!hasContent) return;
            
            await vm.createComment(
              newComment: SocialCommentModel(
                idComment: '',
                idPost: postId,
                idUser: widget.idUser,
                content: text,
                parentComment: parentId,
                createdAt: DateTime.now(),
              ),
              userVm: userVm, // Truyền userVm để load user info
              imagePath: imagePath, // Truyền imagePath để upload
              icon: icon, // Truyền icon
            );
            // Cập nhật số comment trên UI sau khi comment thành công
            socialPostVm.incrementCommentCount(postId);
            _commentController.clear();
          },
          onRefresh: () => vm.loadCommentsWithUsers(postId: postId, userVm: userVm),
          resolveUsername: vm.resolveUsername,
          resolveUserAvatar: vm.resolveUserAvatar,
        ),
      ),
    );
  }

  Future<void> _showSaveSheet(String postId) async {
    socialSaveVm.loadSavedData();
    await _showBottomSheetWrapper(
      Consumer<SocialSavePostViewModel>(
        builder: (context, vm, _) => SaveBottomSheet(
          folderSavedCount: vm.folderSavedCount,
          folders: vm.folders,
          isLoading: vm.isLoading,
          errorMessage: vm.errorMessage,
          onDelete: (folderName) {},
          onSaved: (folderName) async {
            vm.setSelectedFolder(folderName);
            await vm.savePost(idPost: postId, folderName: folderName);
            if (vm.isSuccess && mounted) context.pop();
          },
          onCreateFolder: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                title: const Text('Tạo bộ sưu tập mới'),
                content: TextField(controller: _folderController, decoration: const InputDecoration(hintText: 'Nhập tên bộ sưu tập')),
                actions: [
                  TextButton(onPressed: () { _folderController.clear(); ctx.pop(); }, child: const Text('Hủy')),
                  ElevatedButton(onPressed: () async {
                    final name = _folderController.text.trim();
                    if (name.isNotEmpty) await vm.savePost(idPost: postId, folderName: name);
                    _folderController.clear();
                    if (ctx.mounted) ctx.pop();
                  }, child: const Text('Tạo')),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showShareSheet(String postId) async {
    await socialConnectionVm.getFriends(userId: userVm.currentUser!.idUser);
    await _showBottomSheetWrapper(
      Consumer<SocialConnectionViewModel>(
        builder: (context, vm, _) => ShareBottomSheet(
          postId: postId,
          listFriend: vm.friends,
          isLoading: vm.isLoading,
          onSendMessage: (targetUserId, postId) => _onAccessJobToUser(postId, targetUserId),
        ),
      ),
    );
  }


  Future<void> _showInviteSheet(String groupId, String groupName) async {
    await _showBottomSheetWrapper(
      Consumer<SocialConnectionViewModel>(
        builder: (context, vm, _) => ShareBottomSheet(
          postId: groupId,
          titleSheet: "Mời tham gia nhóm",
          listFriend: vm.friends,
          isLoading: vm.isLoading,
          onSendMessage: (targetUserId, groupId) => _onInviteGroupToUser(groupId, targetUserId, groupName),
        ),
      ),
    );
  }

  Future<void> _onAccessJobToUser(String postId, String targetUserId) async {
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
      content: postId,
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

  Future<void> _onInviteGroupToUser(String groupId, String groupName, String targetUserId) async {
    final currentUserId = userVm.currentUser?.idUser;
    if (currentUserId == null) return;
    ConversationModel? conversation = conversationViewModel.conversations.firstWhereOrNull(
      (c) =>
        c.members.contains(currentUserId) &&
        c.members.contains(targetUserId) &&
        c.members.length == 2, 
    );
    conversation ??= await conversationViewModel.createConversation(
      memberIds: [currentUserId, targetUserId],
    );
    if (conversation == null) return;
    await messageViewModel.createMessage(
      idConversation: conversation.idConversation,
      idSender: currentUserId,
      content: groupId,
      messageType: 'text',
    );
    await messageViewModel.createMessage(
      idConversation: conversation.idConversation,
      idSender: currentUserId,
      content: 'Tham gia nhóm $groupName nhé',
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

  void _onSearchUser(String idUser) async {
    context.push(
      '/social/search',
      extra: {
        'idUser' : idUser
      }
    );
  }

  void _onAccessJob(SocialPostModel post) async {
    if (!mounted) return;
    final currentUserId = userVm.currentUser?.idUser;
    if (currentUserId == null) return;
    ConversationModel? conversation = conversationViewModel.conversations.firstWhereOrNull(
      (c) =>
          c.members.length == 2 &&
          c.members.contains(currentUserId) &&
          c.members.contains(post.idUser),
    );
    if (conversation == null) {
      conversation = await conversationViewModel.createConversation(
        memberIds: [post.idUser, currentUserId],
      );

      if (conversation == null) return; 
    }
    final otherUser = await userVm.getViewUser(post.idUser);
    final currentAvatar = userVm.currentUser?.avatarUrl ?? '';
    await messageViewModel.createMessage(
      idConversation: conversation.idConversation,
      idSender: currentUserId,
      content: post.idPost,
      messageType: MessengerType.text.name,
      fileUrl: null,
      fileName: null,
      fileSize: null,
    );
    await messageViewModel.createMessage(
      idConversation: conversation.idConversation,
      idSender: currentUserId,
      content: 'Tôi muốn nhận công việc này',
      messageType: MessengerType.text.name,
      fileUrl: null,
      fileName: null,
      fileSize: null,
    );
    if (!mounted) return;
    context.push(
      '/social/messenger-detail',
      extra: {
        'isLoggedIn': widget.isLoggedIn,
        'idUser': widget.idUser,
        'conversationId': conversation.idConversation,
        'otherUserName': otherUser?.userName,
        'otherUserId': otherUser?.idUser,
        'otherUserAvatar': otherUser?.avatarUrl,
        'currentUserAvatar': currentAvatar,
      },
    );
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

  void _openJoinOptions() {
    setState(() => _isJoinSheetOpen = true);
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => ReusableBottomSheet(
        options: getControlOptions(),
        selectedValue: selectedFilter,
        showRadio: false,
        onSelected: (value) => setState(() => selectedFilter = value),
      ),
    ).whenComplete(() {
      setState(() => _isJoinSheetOpen = false);
    });
  }

  String getJoinStatusText() {
    final group = socialGroupVm.selectedGroup;
    if (group == null) return "";

    final isOwner = group.createdBy == widget.idUser;
    if (isOwner) return "Chủ nhóm";

    final isMember = socialGroupVm.isUserMember(groupId: group.idGroup);
    if (isMember) return "Đã tham gia";

    final isPending = socialGroupVm.isUserPending(groupId: group.idGroup);
    if (isPending) return "Đang chờ duyệt";

    return "Tham gia";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialGroupsViewModel>(
      builder: (context, groupVm, _) {
        final group = groupVm.selectedGroup;
        final groupName = groupVm.selectedGroup?.groupName;
        final posts = groupName != null && groupName.isNotEmpty
            ? socialPostVm.getPostsOfCurrentGroupByName(groupName)
            : [];

        if (groupVm.isLoading || _isLoading) {
          return Scaffold(
            body: SafeArea(child: Center(child: SocialGroupShimmer())),
          );
        }
        if(groupVm.errorMessage != null){
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60.h),
                child: BackgroundErrorState(
                  title: "Hệ thống đang gặp sự cố\nVui lòng thử lại sau.",
                  onRetry: _loadGroupData,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          body: RefreshIndicator(
            onRefresh: _loadGroupData,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                GroupAppbar(
                  groupName: group?.groupName ?? "Chưa có tên nhóm",
                  groupImage: group?.avatarUrl ?? AppImages.connect,
                  groupCoverImage: group?.coverImageUrl ?? AppImages.logo,
                  onMorePressed: _openJoinOptions,
                ),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      GroupHeader(
                        isJoinSheetOpen: _isJoinSheetOpen,
                        groupName: group?.groupName ?? "Chưa có tên nhóm",
                        visibilityText: group?.privacy.toLowerCase() == "public" ? "Nhóm công khai" : "Nhóm riêng tư",
                        memberCountText: "${group?.memberCount ?? 0} thành viên",
                        selectedFilter: selectedFilter,
                        controlOptions: getControlOptions(),
                        onSelected: (value) => setState(() => selectedFilter = value),
                        joinStatusText: getJoinStatusText(),
                        onInviteFriend: () => _showInviteSheet(group!.idGroup, group.groupName),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: CreatePostInput(
                          user: UserInfoModel(
                            avatarUrl: userVm.currentUser?.avatarUrl ?? AppImages.logoApp,
                            username: userVm.currentUser?.userName ?? "Chưa có tên người dùng",
                            placeholder: 'Có gì mới?',
                          ),
                          onSearch: ()=>_onSearchUser(userVm.currentUser!.idUser),
                          onCreatePost: _onCreatePost,
                        ),
                      ),
                      Divider(height: 2.h),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Builder(
                    builder: (context) {
                      // Lỗi từ server hoặc ViewModel
                      if (groupVm.errorMessage != null) {
                        return BackgroundErrorState(
                          title: "Hệ thống đang gặp sự cố\nVui lòng thử lại sau.",
                          onRetry: _loadGroupData,
                          padding: 20.r,
                        );
                      }

                      // Nhóm chưa có bài viết
                      if (posts.isEmpty) {
                        return Center(
                          child: BackgroundEmptyState(
                            title: "Bài Viết", 
                            subTitle: "Chưa có bài viết trong nhóm.\nVui lòng quay lại sau.",
                            padding: 12.r,
                            onRefresh: _loadGroupData,
                            iconData: Icons.post_add_outlined,
                          )
                        );
                      }

                      // Nếu có bài viết, hiển thị danh sách
                      return Column(
                        children: [
                          ...posts.map((post) {
                            final isLast = posts.indexOf(post) == posts.length - 1;
                            return Column(
                              children: [
                                PostItem(
                                  socialPostModel: post,
                                  isLiked: socialPostVm.isPostLiked(post.idPost),
                                  isSaved: post.isSaved,
                                  isAccessJob: post.postType == PostType.job.name,
                                  idUser: socialPostVm.currentUserId,
                                  roleName: userVm.roleName ?? '',
                                  onDeletePost: () => _onDeletePost(post.idPost),
                                  onEditPost: () => _onOpenEditPost(post),
                                  onLike: () => socialPostVm.onToggleLike(post.idPost),
                                  onSave: () => _onSavePost(post),
                                  onShare: () => _onShowBottomSheet('share', post.idPost),
                                  onHide: () => socialPostVm.onHidePost(post.idPost),
                                  onCopyLink: () => Clipboard.setData(
                                      ClipboardData(text: "https://jobconnect.app/post/${post.idPost}")),
                                  onOpenDetail: () => _onOpenDetail(post),
                                  onOpenProfile: () => _onOpenProfile(post.idUser),
                                  onReport: () => _onReport(post),
                                  onComment: () => _onShowBottomSheet('comment', post.idPost),
                                  onAccessJob: post.idUser == userVm.currentUser?.idUser
                                      ? () {}
                                      : () => _onAccessJob(post),
                                  onGoToGroup: () => _onGoToGroup(post.idGroup!),
                                ),
                                SizedBox(height: 4.h),
                                if (isLast) ...[
                                  Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20.h),
                                    child: SectionTitle(
                                      title: "Bạn đã xem hết rồi",
                                      isCenter: true,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  CustomButtonIconSimple(
                                    icon: Icons.refresh_rounded,
                                    onTap: () {
                                      socialPostVm.refreshPosts(roleName: userVm.roleName ?? '');
                                      onFirstPage();
                                    },
                                    color: Theme.of(context).primaryColor,
                                    size: 24.sp,
                                  ),
                                  SizedBox(height: 20.h),
                                ]
                              ],
                            );
                          }),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
