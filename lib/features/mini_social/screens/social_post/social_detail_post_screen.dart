import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/enum/messenger_type.dart';
import 'package:job_connect/config/enum/post_type.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load saved posts để sync trạng thái
      if (widget.isLoggedIn) {
        await socialSavePostVm.getSavedPosts();
      }
      await _loadAllData();
    });
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);

    await socialPostVm.refreshPosts(roleName: userVm.roleName ?? '');
    await socialCommentVm.refreshComments(postId: widget.socialPostModel.idPost);

    // Đảm bảo post hiện tại có trong ViewModel để có thể cập nhật real-time
    if (!socialPostVm.posts.any((p) => p.idPost == widget.socialPostModel.idPost)) {
      socialPostVm.posts.add(widget.socialPostModel);
    }

    // Load user info cho comment
    for (var c in socialCommentVm.comments) {
      if (!_userCache.containsKey(c.idUser)) {
        final user = await userVm.fetchUserViewerById(c.idUser);
        _userCache[c.idUser] = user as UserModel;
      }
    }

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _onSubmitComment(String text, String? parentId, String? imagePath, String? icon) async {
    final hasContent = text.isNotEmpty || imagePath != null || icon != null;
    if (!hasContent) return;

    try {
      await socialCommentVm.createComment(
        newComment: SocialCommentModel(
          idComment: '',
          idPost: widget.socialPostModel.idPost,
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
      // createComment sẽ throw exception nếu lỗi, nên nếu đến đây là thành công
      socialPostVm.incrementCommentCount(widget.socialPostModel.idPost);
      _commentController.clear();
    } catch (e) {
      // Nếu lỗi, không cập nhật số comment
      // Có thể show snackbar để thông báo lỗi nếu cần
    }
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
        builder: (context, vm, _) {
          // Cập nhật user cache khi có comment mới
          for (var comment in vm.comments) {
            if (!_userCache.containsKey(comment.idUser)) {
              // Load user info nếu chưa có trong cache
              userVm.getViewUser(comment.idUser).then((user) {
                if (user != null && mounted) {
                  setState(() {
                    _userCache[comment.idUser] = user;
                  });
                }
              });
            }
          }
          
          return CommentBottomSheet(
            commentController: _commentController,
            comments: vm.comments,
            isLoading: vm.isLoading,
            errorMessage: vm.errorMessage,
            onSubmit: _onSubmitComment,
            onRefresh: () => vm.loadCommentsWithUsers(postId: postId, userVm: userVm),
            resolveUsername: (id) => _userCache[id]?.userName ?? vm.resolveUsername(id),
            resolveUserAvatar: (id) => _userCache[id]?.avatarUrl ?? vm.resolveUserAvatar(id),
          );
        },
      ),
    );
  }

  Future<void> _showSaveSheet(String postId) async {
    if (mounted) socialSavePostVm.loadSavedData();
    
    final folders = await socialSavePostVm.getSavedFolders();
    const defaultFolder = 'Bộ sưu tập yêu thích';
    final folderToSelect = folders.isNotEmpty ? folders.first : defaultFolder;
    
    await _showBottomSheetWrapper(
      Consumer<SocialSavePostViewModel>(
        builder: (context, vm, _) => SaveBottomSheet(
          folderSavedCount: vm.folderSavedCount,
          folders: vm.folders,
          isLoading: vm.isLoading,
          errorMessage: vm.errorMessage,
          onSaved: (folderName) async {
            final selectedFolder = folderName.isNotEmpty ? folderName : folderToSelect;
            
            // Cập nhật trạng thái ngay lập tức (optimistic update)
            socialPostVm.updateLocalSavedState(postId, true);

            await socialSavePostVm.toggleSavePostWithFolder(
              idPost: postId,
              selectedFolder: selectedFolder,
            );

            // Kiểm tra lại trạng thái sau khi toggle để đảm bảo chính xác
            final isNowSaved = socialSavePostVm.isPostSaved(postId);
            
            // Cập nhật lại trạng thái dựa trên kết quả thực tế
            socialPostVm.updateLocalSavedState(postId, isNowSaved);

            if (socialSavePostVm.isSuccess && mounted) {
              context.pop();
              SnackbarApp.show(
                context,
                title: 'Thành công',
                message: isNowSaved
                    ? 'Đã lưu vào "$selectedFolder"'
                    : 'Đã bỏ lưu bài viết',
                backgroundColor: BackgroundColors.backgroundSuccessPrimary,
              );
            } else if (socialSavePostVm.errorMessage != null && mounted) {
              // Nếu lỗi, revert lại trạng thái
              socialPostVm.updateLocalSavedState(postId, false);
              context.pop();
              SnackbarApp.show(
                context,
                title: 'Thất bại',
                message: 'Lưu bài viết thất bại: ${socialSavePostVm.errorMessage}',
                backgroundColor: BackgroundColors.backgroundErrorPrimary,
              );
            }
          },
          onDelete: (folder) async {},
          onTapFolder: (folderName) {
            // Đóng bottom sheet và navigate đến saved posts screen với folder filter
            context.pop();
            context.push(
              '/social/saved-posts',
              extra: {
                'isLoggedIn': widget.isLoggedIn,
                'idUser': widget.idUser,
                'folderName': folderName,
              },
            );
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

  Future<void> _onSavePost(String postId) async {
    // Kiểm tra trạng thái từ ViewModel thay vì từ model để đảm bảo chính xác
    final isCurrentlySaved = socialSavePostVm.isPostSaved(postId) || 
        socialPostVm.isPostSaved(postId);
    
    if (isCurrentlySaved) {
      // Bỏ lưu trực tiếp không cần mở bottom sheet
      await socialSavePostVm.deleteSavedPost(postId);
      
      // Đợi một chút để đảm bảo state được cập nhật
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Cập nhật trạng thái sau khi xóa
      final isStillSaved = socialSavePostVm.isPostSaved(postId);
      socialPostVm.updateLocalSavedState(postId, isStillSaved);
      
      if (mounted) {
        SnackbarApp.show(
          context,
          title: 'Đã bỏ lưu',
          message: 'Bài viết đã được xoá khỏi "Bộ sưu tập yêu thích"',
          backgroundColor: BackgroundColors.backgroundWarningPrimary,
        );
      }
      return;
    }

    // Nếu chưa lưu, mở bottom sheet để chọn folder
    await _showSaveSheet(postId);
  }

  void _onShowBottomSheet({required String type, required String postId}) {
    switch(type){
      case 'comment': _showCommentSheet(postId); break;
      case 'save': _onSavePost(postId); break;
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

    // Cập nhật số share trên UI
    socialPostVm.incrementShareCount(post.idPost);

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

    // Cập nhật số share trên UI
    socialPostVm.incrementShareCount(postId);

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
                            Consumer<SocialPostViewModel>(
                              builder: (context, postVm, _) {
                                // Lấy post từ ViewModel để có data được cập nhật
                                final currentPost = postVm.posts.firstWhere(
                                  (p) => p.idPost == widget.socialPostModel.idPost,
                                  orElse: () => widget.socialPostModel,
                                );
                                
                                return PostItemHeader(
                                  idUser: widget.idUser,
                                  socialPostModel: currentPost,
                                  roleName: userVm.roleName ?? '',
                                  onFollow: () {},
                                  onHide: () => postVm.onHidePost(widget.socialPostModel.idPost),
                                  onCopyLink: () => _onCopyPostLink(widget.socialPostModel.idPost),
                                  onReport: () => _onReport(
                                    authorName: currentPost.userName ?? 'Người dùng',
                                    userName: userVm.currentUser?.userName ?? '',
                                  ),
                                  onOpenProfile: () => _onOpenProfile(currentPost.idUser),
                                  onDeletePost: () => _onDeletePost(widget.socialPostModel.idPost),
                                  onEditPost: () => _onOpenEditPost(currentPost),
                                  onGoToGroup: () => _onGoToGroup(currentPost.idGroup ?? ''),
                                );
                              },
                            ),
                            SizedBox(height: 8.h),
                            Consumer<SocialPostViewModel>(
                              builder: (context, postVm, _) {
                                final currentPost = postVm.posts.firstWhere(
                                  (p) => p.idPost == widget.socialPostModel.idPost,
                                  orElse: () => widget.socialPostModel,
                                );
                                
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Html(data: currentPost.content),
                                    if(currentPost.imageUrls != null)...[
                                      SizedBox(height: 16.h),
                                      GestureDetector(
                                        onTap: () => DialogUtils.showImageViewer(context, currentPost.imageUrls!, 0),
                                        child: PostImageGrid(imagePaths: currentPost.imageUrls!),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                            SizedBox(height: 16.h),
                            Consumer2<SocialPostViewModel, SocialSavePostViewModel>(
                              builder: (context, postVm, saveVm, _) {
                                // Lấy post từ ViewModel để có counts được cập nhật real-time
                                final currentPost = postVm.posts.firstWhere(
                                  (p) => p.idPost == widget.socialPostModel.idPost,
                                  orElse: () => widget.socialPostModel,
                                );
                                
                                // Kiểm tra trạng thái saved từ cả model và ViewModel để đảm bảo chính xác
                                final isSaved = currentPost.isSaved || 
                                    saveVm.isPostSaved(widget.socialPostModel.idPost);
                                
                                return PostActionBar(
                                  likesCount: currentPost.likesCount,
                                  commentCount: currentPost.commentsCount,
                                  shareCount: currentPost.sharesCount,
                                  isLiked: postVm.isPostLiked(widget.socialPostModel.idPost),
                                  isSaved: isSaved,
                                  isAccessJob: currentPost.postType == PostType.job.name,
                                  onLike: () => postVm.onToggleLike(widget.socialPostModel.idPost),
                                  onSave: () => _onSavePost(widget.socialPostModel.idPost),
                                  onShare: () => _onShowBottomSheet(type: 'share', postId: widget.socialPostModel.idPost),
                                  onAccessJob: () => _onAccessJob(currentPost),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverFillRemaining(
                      hasScrollBody: true,
                      child: Consumer<SocialCommentViewModel>(
                        builder: (context, commentVm, _) {
                          // Cập nhật user cache khi có comment mới
                          for (var comment in commentVm.comments) {
                            if (!_userCache.containsKey(comment.idUser)) {
                              // Load user info nếu chưa có trong cache
                              userVm.getViewUser(comment.idUser).then((user) {
                                if (user != null && mounted) {
                                  setState(() {
                                    _userCache[comment.idUser] = user;
                                  });
                                }
                              });
                            }
                          }
                          
                          return CommentBottomSheet(
                            commentController: _commentController,
                            comments: commentVm.comments,
                            isLoading: commentVm.isLoading,
                            errorMessage: commentVm.errorMessage,
                            onSubmit: _onSubmitComment,
                            onRefresh: () => commentVm.loadCommentsWithUsers(
                              postId: widget.socialPostModel.idPost,
                              userVm: userVm,
                            ),
                            resolveUsername: (id) => _userCache[id]?.userName ?? commentVm.resolveUsername(id),
                            resolveUserAvatar: (id) => _userCache[id]?.avatarUrl ?? commentVm.resolveUserAvatar(id),
                            isDrag: false,
                            isScrollComment: false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ),
    );
  }
}
