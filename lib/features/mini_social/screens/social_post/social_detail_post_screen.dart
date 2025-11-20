import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/enum/messenger_type.dart';
import 'package:job_connect/config/enum/post_type.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/config/utils/get_adaptive_back_icon.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/custom_adaptive_tap_effect.dart';
import 'package:job_connect/config/widgets/custom_app_bar.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/features/mini_social/model/conversation_model.dart';
import 'package:job_connect/features/mini_social/model/social_comment_model.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';
import 'package:job_connect/features/mini_social/view_model/conversation_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/message_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_comment_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_connection_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_post_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_save_post_view_model.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/comment_bottom_sheet.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/save_bottom_sheet.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/share_bottom_sheet.dart';
import 'package:job_connect/features/mini_social/widgets/shimmer/social_post_detail_shimmer.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_action_bar.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_image_grid.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_item_header.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class SocialDetailPostScreen extends StatefulWidget {
  final SocialPostModel socialPostModel;
  final bool isLoggedIn;
  final String idUser;

  const SocialDetailPostScreen({
    super.key,
    required this.socialPostModel,
    required this.isLoggedIn,
    required this.idUser,
  });

  @override
  State<SocialDetailPostScreen> createState() => _SocialDetailPostScreenState();
}

class _SocialDetailPostScreenState extends State<SocialDetailPostScreen> {
  late final SocialPostViewModel socialPostVm;
  late final SocialCommentViewModel socialCommentVm;
  late final SocialSavePostViewModel socialSavePostVm;
  late final UserViewModel userVm;
  late final SocialConnectionViewModel socialConnectionVm;
  late final ConversationViewModel conversationViewModel;
  late final MessageViewModel messageViewModel;

  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _folderController = TextEditingController();
  final Map<String, UserModel> _userCache = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    socialPostVm = context.read<SocialPostViewModel>();
    socialCommentVm = context.read<SocialCommentViewModel>();
    socialSavePostVm = context.read<SocialSavePostViewModel>();
    userVm = context.read<UserViewModel>();
    socialConnectionVm = context.read<SocialConnectionViewModel>();
    conversationViewModel = context.read<ConversationViewModel>();
    messageViewModel = context.read<MessageViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAllData());
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    await socialPostVm.refreshPosts(roleName: userVm.roleName ?? '');
    await socialCommentVm.refreshComments(postId: widget.socialPostModel.idPost);

    // Load user info cho comment
    for (var c in socialCommentVm.comments) {
      if (!_userCache.containsKey(c.idUser)) {
        final user = await userVm.fetchUserViewerById(c.idUser);
        _userCache[c.idUser] = user as UserModel;
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _onSubmitComment(String text, String? parentId) async {
    if (text.isEmpty) return;

    await socialCommentVm.createComment(
      newComment: SocialCommentModel(
        idComment: '',
        idPost: widget.socialPostModel.idPost,
        idUser: widget.idUser,
        content: text,
        parentComment: parentId,
        createdAt: DateTime.now(),
      ),
    );

    _commentController.clear();
    await _loadUsersForComments(socialCommentVm.comments);
  }

  Future<void> _loadUsersForComments(List<SocialCommentModel> comments) async {
    for (var c in comments) {
      if (!_userCache.containsKey(c.idUser)) {
        final user = await userVm.fetchUserViewerById(c.idUser);
        _userCache[c.idUser] = user as UserModel;
      }
    }
    if (mounted) setState(() {});
  }

  void _onReport({required String userName, required String authorName}) {
    context.push(
      '/social/report',
      extra: {'userName': userName, 'authorName': authorName},
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

  void _onDeletePost(String idPost) {
    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Xóa bài viết",
      message: "Bạn muốn xóa bài viết này?",
      icon: Icons.delete_forever_rounded,
      onConfirm: () async {
        socialPostVm.deletePost(idPost);
        context.pop();
      },
    );
  }

  void _onOpenProfile(String idUser) {
    context.push('/social/profile', extra: {'idUser': idUser});
  }

  void _onOpenEditPost(SocialPostModel post) {
    context.push('/social/edit-post', extra: {'socialPostModel': post});
  }

  void _onCopyPostLink(String id) {
    Clipboard.setData(ClipboardData(text: "https://jobconnect.app/post/$id"));
    SnackbarApp.show(
      context,
      title: "Thành công",
      message: "Sao chép link thành công",
      backgroundColor: BackgroundColors.backgroundSuccessPrimary,
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

  Future<void> _showCommentSheet(String postId) async {
    if (mounted) socialCommentVm.loadCommentsWithUsers(postId: postId, userVm: userVm);
    await _showBottomSheetWrapper(
      Consumer<SocialCommentViewModel>(
        builder: (context, vm, _) => CommentBottomSheet(
          commentController: _commentController,
          comments: vm.comments,
          isLoading: vm.isLoading,
          errorMessage: vm.errorMessage,
          onSubmit: _onSubmitComment,
          onRefresh: () => vm.loadCommentsWithUsers(postId: postId, userVm: userVm),
          resolveUsername: (id) => _userCache[id]?.userName ?? "",
          resolveUserAvatar: (id) => _userCache[id]?.avatarUrl ?? AppImages.defaultAvatar,
        ),
      ),
    );
  }

  Future<void> _showSaveSheet(String postId) async {
    if (mounted) socialSavePostVm.loadSavedData();
    await _showBottomSheetWrapper(
      Consumer<SocialSavePostViewModel>(
        builder: (context, vm, _) => SaveBottomSheet(
          folderSavedCount: vm.folderSavedCount,
          folders: vm.folders,
          isLoading: vm.isLoading,
          errorMessage: vm.errorMessage,
          onSaved: (folderName) async {
            vm.setSelectedFolder(folderName);
            await vm.savePost(idPost: postId, folderName: folderName);
            vm.folderSavedCount[folderName] = (vm.folderSavedCount[folderName] ?? 0) + 1;
            if (vm.isSuccess && mounted) {
              context.pop();
              SnackbarApp.show(
                context,
                title: 'Thành công',
                message: 'Lưu vào $folderName thành công',
                backgroundColor: BackgroundColors.backgroundSuccessPrimary,
              );
            } else if (vm.errorMessage != null && mounted) {
              context.pop();
              SnackbarApp.show(
                context,
                title: 'Thất bại',
                message: 'Lưu vào $folderName thất bại',
                backgroundColor: BackgroundColors.backgroundErrorPrimary,
              );
            }
          },
          onDelete: (folder) async {},
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
                    if(name.isNotEmpty) await vm.savePost(idPost: postId, folderName: name);
                    _folderController.clear();
                    if(ctx.mounted) ctx.pop();
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

  void _onShowBottomSheet({required String type, required String postId}) {
    switch(type){
      case 'comment': _showCommentSheet(postId); break;
      case 'save': _showSaveSheet(postId); break;
      case 'share': _showShareSheet(postId); break;
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BackgroundColors.backgroundDefaultPrimary,
      appBar: CustomAppbarTitleLarge(title: 'Bài viết của ${widget.socialPostModel.userName}'),
      body: _isLoading
          ? const Center(child: SocialPostDetailShimmer())
          : SafeArea(
            child: RefreshIndicator(
                onRefresh: _loadAllData,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PostItemHeader(
                              idUser: widget.idUser,
                              socialPostModel: widget.socialPostModel,
                              roleName: userVm.roleName ?? '',
                              onFollow: () {},
                              onHide: () => socialPostVm.onHidePost(widget.socialPostModel.idPost),
                              onCopyLink: () => _onCopyPostLink(widget.socialPostModel.idPost),
                              onReport: () => _onReport(
                                authorName: widget.socialPostModel.userName ?? 'Người dùng',
                                userName: userVm.currentUser?.userName ?? '',
                              ),
                              onOpenProfile: () => _onOpenProfile(widget.socialPostModel.idUser),
                              onDeletePost: () => _onDeletePost(widget.socialPostModel.idPost),
                              onEditPost: () => _onOpenEditPost(widget.socialPostModel),
                              onGoToGroup: () => _onGoToGroup(widget.socialPostModel.idGroup ?? ''),
                            ),
                            SizedBox(height: 8.h),
                            Html(data: widget.socialPostModel.content),
                            if(widget.socialPostModel.imageUrls != null)...[
                              SizedBox(height: 16.h),
                              GestureDetector(
                                onTap: () => DialogUtils.showImageViewer(context, widget.socialPostModel.imageUrls!, 0),
                                child: PostImageGrid(imagePaths: widget.socialPostModel.imageUrls!),
                              ),
                            ],
                            SizedBox(height: 16.h),
                            PostActionBar(
                              likesCount: widget.socialPostModel.likesCount,
                              commentCount: widget.socialPostModel.commentsCount,
                              shareCount: widget.socialPostModel.sharesCount,
                              isLiked: socialPostVm.isPostLiked(widget.socialPostModel.idPost),
                              isSaved: socialPostVm.isPostSaved(widget.socialPostModel.idPost),
                              isAccessJob: widget.socialPostModel.postType == PostType.job.name,
                              onLike: () => socialPostVm.onToggleLike(widget.socialPostModel.idPost),
                              onSave: () => _onShowBottomSheet(type: 'save', postId: widget.socialPostModel.idPost),
                              onShare: () => _onShowBottomSheet(type: 'share', postId: widget.socialPostModel.idPost),
                              onAccessJob: () => _onAccessJob(widget.socialPostModel),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: true,
                      child: CommentBottomSheet(
                        commentController: _commentController,
                        comments: socialCommentVm.comments,
                        onSubmit: _onSubmitComment,
                        resolveUsername: (id) => _userCache[id]?.userName ?? "",
                        resolveUserAvatar: (id) => _userCache[id]?.avatarUrl ?? AppImages.defaultAvatar,
                        isDrag: false,
                        isScrollComment: false,
                      ),
                    ),
                  ],
                ),
              ),
          ),
    );
  }
}
