import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/enum/messenger_type.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/mini_social/model/conversation_model.dart';
import 'package:provider/provider.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/enum/post_type.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/custom_search_bar.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/config/widgets/background_error_state.dart';
import 'package:job_connect/features/mini_social/model/social_comment_model.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_post_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_save_post_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_comment_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_connection_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/conversation_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/message_view_model.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_item.dart';
import 'package:job_connect/features/mini_social/widgets/shimmer/social_feed_shimmer.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/comment_bottom_sheet.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/save_bottom_sheet.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/share_bottom_sheet.dart';

class SocialManagentPostGroupScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;
  final String idGroup;

  const SocialManagentPostGroupScreen({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
    required this.idGroup,
  });

  @override
  State<SocialManagentPostGroupScreen> createState() => _SocialManagentPostGroupScreenState();
}

class _SocialManagentPostGroupScreenState extends State<SocialManagentPostGroupScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool _showFab = false;
  int _selectedTab = 0;
  final List<String> _tabs = ["Bài viết của bạn", "Bài viết thành viên"];
  
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  
  late final SocialPostViewModel socialPostVm;
  late final SocialCommentViewModel socialCommentVm;
  late final SocialSavePostViewModel socialSavePostVm;
  late final UserViewModel userVm;
  late final SocialConnectionViewModel socialConnectionVm;
  late final ConversationViewModel conversationViewModel;
  late final MessageViewModel messageViewModel;
  
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _folderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    socialPostVm = context.read<SocialPostViewModel>();
    socialCommentVm = context.read<SocialCommentViewModel>();
    userVm = context.read<UserViewModel>();
    socialSavePostVm = context.read<SocialSavePostViewModel>();
    socialConnectionVm = context.read<SocialConnectionViewModel>();
    conversationViewModel = context.read<ConversationViewModel>();
    messageViewModel = context.read<MessageViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await userVm.loadRoleName();
      if (userVm.roleName != null) {
        await socialPostVm.getAllPostsOfGroup(groupId: widget.idGroup, currentUserId: widget.idUser);
      }
      if (widget.isLoggedIn && userVm.currentUser != null) {
        await socialConnectionVm.getFriends(userId: userVm.currentUser!.idUser);
      }
    });
  }

  void _scrollListener() {
    if (_scrollController.offset > 300 && !_showFab) setState(() => _showFab = true);
    else if (_scrollController.offset <= 300 && _showFab) setState(() => _showFab = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _commentController.dispose();
    _searchController.dispose();
    _folderController.dispose();
    super.dispose();
  }

  List<SocialPostModel> _getFilteredPosts() {
    final keyword = _searchController.text.toLowerCase();
    List<SocialPostModel> posts = socialPostVm.posts.where((p) => p.idGroup == widget.idGroup).toList();

    if (_selectedTab == 0) posts = posts.where((p) => p.idUser == widget.idUser).toList();
    if (_selectedTab == 1) posts = posts.where((p) => p.idUser != widget.idUser).toList();

    if (keyword.isNotEmpty) {
      posts = posts.where((p) => p.content.toLowerCase().contains(keyword) || (p.groupName?.toLowerCase().contains(keyword) ?? false)).toList();
    }

    return posts;
  }

  void _onDeletePost(String idPost) {
    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Xóa bài viết",
      message: "Bạn muốn xóa bài viết này?",
      icon: Icons.delete_forever_rounded,
      onConfirm: () async {
        await socialPostVm.deletePost(idPost);
        if (mounted) context.pop();
      },
    );
  }

  void _onOpenDetail(SocialPostModel post) {
    context.push('/social/detail-post', extra: {'socialPostModel': post, 'isLoggedIn': widget.isLoggedIn, 'idUser': widget.idUser});
  }

  void _onOpenProfile(String idUser) => context.push('/social/profile', extra: {'idUser': idUser});

  void _onOpenEditPost(SocialPostModel post) => context.push('/social/edit-post', extra: {'socialPostModel': post});

  void _onCopyPostLink(String idPost) {
    Clipboard.setData(ClipboardData(text: "https://jobconnect.app/post/$idPost"));
    SnackbarApp.show(context, title: "Thành công", message: "Sao chép link thành công", backgroundColor: BackgroundColors.backgroundSuccessPrimary);
  }

  void _onGoToGroup(String idGroup) {
    context.push('/social/group', extra: {'idGroup': idGroup, 'isLoggedIn': widget.isLoggedIn, 'idUser': widget.idUser});
  }

  void _onReport({required String userName, required String authorName}) {
    context.push('/social/report', extra: {'userName': userName, 'authorName': authorName});
  }

  Future<void> _onSavePost(BuildContext context, SocialPostModel post) async {
    if (post.isSaved) {
      await socialSavePostVm.deleteSavedPost(post.idPost);
      socialPostVm.updateLocalSavedState(post.idPost, false);
      if (mounted) SnackbarApp.show(context, title: 'Đã bỏ lưu', message: 'Bài viết đã được xoá khỏi bộ sưu tập', backgroundColor: BackgroundColors.backgroundWarningPrimary);
      return;
    }
    final folders = await socialSavePostVm.getSavedFolders();
    final folderToSelect = folders.isNotEmpty ? folders.first : 'Bộ sưu tập yêu thích';

    await _showBottomSheetWrapper(SaveBottomSheet(
      folderSavedCount: socialSavePostVm.folderSavedCount,
      folders: folders,
      isLoading: socialSavePostVm.isLoading,
      onSaved: (folderName) async {
        final folder = folderName ?? folderToSelect;
        await socialSavePostVm.toggleSavePostWithFolder(idPost: post.idPost, selectedFolder: folder);
        socialPostVm.updateLocalSavedState(post.idPost, socialSavePostVm.isPostSaved(post.idPost));
        if (mounted) {
          context.pop();
          SnackbarApp.show(context, title: 'Thành công', message: 'Đã lưu vào "$folder"', backgroundColor: BackgroundColors.backgroundSuccessPrimary);
        }
      },
      onDelete: (folderName) async {
        
      },
      onCreateFolder: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Tạo bộ sưu tập mới'),
            content: TextField(controller: _folderController, decoration: const InputDecoration(hintText: 'Nhập tên bộ sưu tập')),
            actions: [
              TextButton(onPressed: () { _folderController.clear(); ctx.pop(); }, child: const Text('Hủy')),
              ElevatedButton(onPressed: () async {
                final name = _folderController.text.trim();
                if (name.isNotEmpty) await socialSavePostVm.savePost(idPost: post.idPost, folderName: name);
                _folderController.clear();
                if (ctx.mounted) ctx.pop();
              }, child: const Text('Tạo')),
            ],
          ),
        );
      },
    ));
  }

  Future<void> _showCommentSheet(String postId) async {
    socialCommentVm.loadCommentsWithUsers(postId: postId, userVm: userVm);
    await _showBottomSheetWrapper(CommentBottomSheet(
      commentController: _commentController,
      comments: socialCommentVm.comments,
      isLoading: socialCommentVm.isLoading,
      errorMessage: socialCommentVm.errorMessage,
      onSubmit: (text, parentId) async {
        if (text.isNotEmpty) {
          await socialCommentVm.createComment( newComment: 
            SocialCommentModel(
            idComment: '',
            idPost: postId,
            idUser: widget.idUser,
            content: text,
            parentComment: parentId,
            createdAt: DateTime.now(),
          ));
          _commentController.clear();
        }
      },
      onRefresh: () => socialCommentVm.loadCommentsWithUsers(postId: postId, userVm: userVm),
      resolveUsername: socialCommentVm.resolveUsername,
      resolveUserAvatar: socialCommentVm.resolveUserAvatar,
    ));
  }

  Future<void> _showShareSheet(String postId) async {
    await socialConnectionVm.getFriends(userId: userVm.currentUser!.idUser);
    await _showBottomSheetWrapper(ShareBottomSheet(
      postId: postId,
      listFriend: socialConnectionVm.friends,
      isLoading: socialConnectionVm.isLoading,
      onSendMessage: (targetUserId, postId) => _onAccessJobToUser(postId, targetUserId),
    ));
  }

  Future<void> _showBottomSheetWrapper(Widget child) async {
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, controller) => Padding(padding: EdgeInsets.all(8.w), child: child),
      ),
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

  Widget _buildCustomTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Text(_tabs[index], style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 14.sp)),
              ),
            ),
          );
        }),
      ),
    );
  }

  void onFirstPage() => _scrollController.animateTo(0, duration: const Duration(milliseconds: 600), curve: Curves.easeOut);

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Consumer<SocialPostViewModel>(builder: (context, vm, _) {
      final filteredPosts = _getFilteredPosts();
      if (vm.isLoading) return Scaffold(body: const SocialFeedShimmer());
      if (vm.errorMessage != null) return Scaffold(body: SafeArea(child: Center(child: BackgroundErrorState(title: "Hệ thống đang gặp sự cố\nVui lòng thử lại sau.", onRetry: () => vm.getAllPostsOfGroup(groupId: widget.idGroup, currentUserId: widget.idUser)))));

      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: const CustomAppbarTitleLarge(title: 'Quản lý bài viết nhóm'),
        body: UnfocusWidget(
          child: SafeArea(
            child: RefreshIndicator(
              onRefresh: () => vm.getAllPostsOfGroup(groupId: widget.idGroup, currentUserId: widget.idUser),
              displacement: 80,
              color: Colors.blue,
              backgroundColor: Colors.white,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.h),
                      child: CustomSearchBar(controller: _searchController, hintText: 'Tìm kiếm bài viết', borderRadius: 30.r),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(padding: EdgeInsets.symmetric(horizontal: 16.w), child: _buildCustomTabBar()),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 16.h),),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final post = filteredPosts[index];
                      final isLast = index == filteredPosts.length - 1;
                      return Column(
                        children: [
                          PostItem(
                            socialPostModel: post,
                            isLiked: vm.isPostLiked(post.idPost),
                            isSaved: post.isSaved,
                            isAccessJob: post.postType == PostType.job.name,
                            idUser: vm.currentUserId,
                            roleName: userVm.roleName!,
                            onDeletePost: () => _onDeletePost(post.idPost),
                            onEditPost: () => _onOpenEditPost(post),
                            onLike: () => vm.onToggleLike(post.idPost),
                            onSave: () => _onSavePost(context, post),
                            onShare: () => _showShareSheet(post.idPost),
                            onHide: () => vm.onHidePost(post.idPost),
                            onCopyLink: () => _onCopyPostLink(post.idPost),
                            onOpenDetail: () => _onOpenDetail(post),
                            onOpenProfile: () => _onOpenProfile(post.idUser),
                            onReport: () => _onReport(authorName: post.userName ?? 'Người dùng ${AppStrings.appName}', userName: userVm.currentUser!.userName),
                            onComment: () => _showCommentSheet(post.idPost),
                            onAccessJob: post.idUser == userVm.currentUser?.idUser ? (){} : () => _onAccessJob(post),
                            onGoToGroup: () => _onGoToGroup(post.idGroup!),
                          ),
                          SizedBox(height: 4.h),
                          if (isLast) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: SectionTitle(title: "Bạn đã xem hết rồi", textColor: theme.textTheme.bodyMedium?.color?.withValues( alpha: 0.5), isCenter: true, fontWeight: FontWeight.w500),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: SectionTitle(title: "Hãy quay lại sau để xem những thông tin mới.", textColor: theme.textTheme.bodyMedium?.color?.withValues( alpha: 0.25), isCenter: true, fontWeight: FontWeight.w400),
                            ),
                          ]
                        ],
                      );
                    }, childCount: filteredPosts.length),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  @override
  bool get wantKeepAlive => true;
}
