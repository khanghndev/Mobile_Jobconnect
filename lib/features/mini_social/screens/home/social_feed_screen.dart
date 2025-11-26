import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/enum/messenger_type.dart';
import 'package:job_connect/config/enum/post_type.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/widgets/background_error_state.dart';
import 'package:job_connect/config/widgets/custom_button_icon_simple.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/features/mini_social/model/conversation_model.dart';
import 'package:job_connect/features/mini_social/model/social_comment_model.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';
import 'package:job_connect/features/mini_social/view_model/conversation_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/message_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_connection_view_model.dart';
import 'package:job_connect/features/mini_social/widgets/shimmer/social_feed_shimmer.dart';
import 'package:job_connect/features/mini_social/view_model/social_comment_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_post_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_save_post_view_model.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/comment_bottom_sheet.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/save_bottom_sheet.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/share_bottom_sheet.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/create_post_input.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_item.dart';

class SocialFeedScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;
  final VoidCallback onSearch;

  const SocialFeedScreen({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
    required this.onSearch,
  });

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool _showFab = false;
  bool _isInitialized = false;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late final SocialPostViewModel socialPostVm;
  late final SocialCommentViewModel socialCommentVm;
  late final SocialSavePostViewModel socialSavePostVm;
  late final UserViewModel userVm;
  late final SocialConnectionViewModel socialConnectionVm;
  late final ConversationViewModel conversationViewModel;
  late final MessageViewModel messageViewModel;
  String selectedFolder = 'Bài viết yêu thích';
  
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _folderController = TextEditingController();

  @override

  void initState() {
    super.initState();
    socialPostVm = context.read<SocialPostViewModel>();
    socialCommentVm = context.read<SocialCommentViewModel>();
    userVm = context.read<UserViewModel>();
    socialSavePostVm = context.read<SocialSavePostViewModel>();
    socialConnectionVm = context.read<SocialConnectionViewModel>();
    conversationViewModel = context.read<ConversationViewModel>();
    messageViewModel = context.read<MessageViewModel>();
    
    // Chỉ load một lần khi init
    if (!_isInitialized) {
      _isInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        
        // Load role name trước
        await userVm.loadRoleName();
        
        if (!mounted) return;
        
        // Load saved posts để sync trạng thái
        if (widget.isLoggedIn) {
          await socialSavePostVm.getSavedPosts();
        }
        
        // Chỉ load posts nếu chưa có dữ liệu hoặc đang loading
        if (userVm.roleName != null && socialPostVm.posts.isEmpty && !socialPostVm.isLoading) {
          await socialPostVm.getPostsByRole(roleName: userVm.roleName!);
        }
        
        // Load friends chỉ khi cần (khi share)
        // Không load ngay để tránh gọi API không cần thiết
      });
    }

    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !_showFab) {
        setState(() => _showFab = true);
      } else if (_scrollController.offset <= 300 && _showFab) {
        setState(() => _showFab = false);
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _commentController.dispose();
    _folderController.dispose();
    super.dispose();
  }

  void _onCreatePost() {
    context.push(
      '/social/create-post',
      extra: {
        'idUser': widget.idUser,
      }
    );
  }

  void _onReport({required String userName, required String authorName}) {
    context.push(
      '/social/report',
      extra: {'userName': userName, 'authorName': authorName});
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
      message: "Bạn muốn xóa bài viết nây?",
      icon: Icons.delete_forever_rounded,
      onConfirm: () async {
        socialPostVm.deletePost(idPost);
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

  Future<void> _onSavePost(BuildContext context, SocialPostModel socialPost) async {
    // Kiểm tra trạng thái từ ViewModel thay vì từ model để đảm bảo chính xác
    final isCurrentlySaved = socialSavePostVm.isPostSaved(socialPost.idPost) || socialPost.isSaved;
    
    if (isCurrentlySaved) {
      // Bỏ lưu trực tiếp không cần mở bottom sheet
      await socialSavePostVm.deleteSavedPost(socialPost.idPost);
      
      // Đợi một chút để đảm bảo state được cập nhật
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Cập nhật trạng thái sau khi xóa
      final isStillSaved = socialSavePostVm.isPostSaved(socialPost.idPost);
      socialPostVm.updateLocalSavedState(socialPost.idPost, isStillSaved);
      
      if (context.mounted) {
        SnackbarApp.show(
          context,
          title: 'Đã bỏ lưu',
          message: 'Bài viết đã được xoá khỏi "Bộ sưu tập yêu thích"',
          backgroundColor: BackgroundColors.backgroundWarningPrimary,
        );
      }
      return;
    }

    final folders = await socialSavePostVm.getSavedFolders();
    const defaultFolder = 'Bộ sưu tập yêu thích';
    final folderToSelect = folders.isNotEmpty ? folders.first : defaultFolder;

      _onShowBottomSheet(
      postId: socialPost.idPost,
      type: 'save',
      onSave: (String? selected) async {
        final folderName = selected ?? folderToSelect;

        // Cập nhật trạng thái ngay lập tức (optimistic update)
        // Giả sử lưu thành công, cập nhật UI ngay
        socialPostVm.updateLocalSavedState(socialPost.idPost, true);

        await socialSavePostVm.toggleSavePostWithFolder(
          idPost: socialPost.idPost,
          selectedFolder: folderName,
        );

        // Kiểm tra lại trạng thái sau khi toggle để đảm bảo chính xác
        final isNowSaved = socialSavePostVm.isPostSaved(socialPost.idPost);
        
        // Cập nhật lại trạng thái dựa trên kết quả thực tế
        socialPostVm.updateLocalSavedState(socialPost.idPost, isNowSaved);

        if (socialSavePostVm.isSuccess && context.mounted) {
          SnackbarApp.show(
            context,
            title: 'Thành công',
            message: isNowSaved
                ? 'Đã lưu vào "$folderName"'
                : 'Đã bỏ lưu bài viết',
            backgroundColor: BackgroundColors.backgroundSuccessPrimary,
          );
        } else if (socialSavePostVm.errorMessage != null && context.mounted) {
          // Nếu lỗi, revert lại trạng thái
          socialPostVm.updateLocalSavedState(socialPost.idPost, false);
          DialogUtils.showConfirmationDialog(
            context: context,
            title: "Thông báo",
            message: "Lưu bài viết thất bại: ${socialSavePostVm.errorMessage}",
            icon: Icons.error_outline_rounded,
            onConfirm: () async => context.pop(),
          );
        }
      },
    );
  }

  void _onOpenProfile(String idUser) {
    context.push('/social/profile', extra: {'idUser': idUser});
  }

  void _onOpenEditPost(SocialPostModel socialPostModel) {
    context.push(
      '/social/edit-post', 
      extra: {
        'socialPostModel': socialPostModel
      }
    );
  }

  void onFirstPage() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
    );
  }

  void _onCopyPostLink(String id) {
    final link = "https://jobconnect.app/post/$id";
    Clipboard.setData(ClipboardData(text: link));
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
    // Load comment và user trước (dù chỉ mất 1–2 frame để rebuild)
    if (mounted) {
      socialCommentVm.loadCommentsWithUsers(postId: postId, userVm: userVm);
    }
    // Mở sheet ngay
    await _showBottomSheetWrapper(
      Consumer<SocialCommentViewModel>(
        builder: (context, vm, _) {
          return CommentBottomSheet(
            commentController: _commentController,
            comments: vm.comments,
            isLoading: vm.isLoading,
            errorMessage: vm.errorMessage,
            onSubmit: (text, parentId, imagePath, icon) async {
              final hasContent = text.isNotEmpty || imagePath != null || icon != null;
              if (!hasContent) return;
              
              try {
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
                // createComment sẽ throw exception nếu lỗi, nên nếu đến đây là thành công
                socialPostVm.incrementCommentCount(postId);
                _commentController.clear();
              } catch (e) {
                // Nếu lỗi, không cập nhật số comment
                // Có thể show snackbar để thông báo lỗi nếu cần
              }
            },
            onRefresh: () => vm.loadCommentsWithUsers(postId: postId, userVm: userVm),
            resolveUsername: vm.resolveUsername,
            resolveUserAvatar: vm.resolveUserAvatar,
          );
        },
      ),
    );
  }

  Future<void> _showSaveSheet(String postId) async {
    // Sau khi BottomSheet mở, load dữ liệu
    if (mounted) {
      socialSavePostVm.loadSavedData(); 
    }
    // Mở sheet ngay với trạng thái loading
    await _showBottomSheetWrapper(
      Consumer<SocialSavePostViewModel>(
        builder: (context, vm, _) {
          return SaveBottomSheet(
            folderSavedCount: vm.folderSavedCount,
            folders: vm.folders,
            isLoading: vm.isLoading,
            errorMessage: vm.errorMessage,
            onSaved: (folderName) async {
              vm.setSelectedFolder(folderName);
              await vm.savePost(idPost: postId, folderName: folderName);
              vm.folderSavedCount[folderName] = (vm.folderSavedCount[folderName] ?? 0) + 1;

              if (vm.isSuccess && context.mounted) {
                context.pop();
                SnackbarApp.show(
                  context,
                  title: 'Thành công',
                  message: 'Lưu vào $folderName thành công',
                  backgroundColor: BackgroundColors.backgroundSuccessPrimary,
                );
              } else if (vm.errorMessage != null && context.mounted) {
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
            onCreateFolder: () {},
            onTapFolder: (folderName) {
              // Đóng bottom sheet và navigate đến saved posts screen
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
          );
        },
      ),
    );
  }

  Future<void> _showShareSheet(String postId) async {
    final vm = context.read<SocialConnectionViewModel>();
    // Chỉ load friends khi mở share sheet, không load trước
    if (vm.friends.isEmpty && !vm.isLoading) {
      await vm.getFriends(userId: userVm.currentUser!.idUser);
    }

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

  void _onShowBottomSheet({
    required String type,
    required String postId,
    VoidCallback? onShare,
    VoidCallback? onComment,
    Future<void> Function(String?)? onSave,
  }) {
    switch (type) {
      case 'comment':
        _showCommentSheet(postId);
        break;
      case 'save':
        _showSaveSheet(postId);
        break;
      case 'share':
        if (onShare != null) _showShareSheet(postId);
        break;
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

  void _onSearchUser(String idUser) async {
    context.push(
      '/social/search',
      extra: {
        'idUser' : idUser
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return Consumer2<SocialPostViewModel, SocialSavePostViewModel>(
      builder: (context, socialPostVm, socialSavePostVm, _) {
        // Chỉ load lại nếu chưa có dữ liệu và không đang loading
        if (!_isInitialized && userVm.roleName != null && socialPostVm.posts.isEmpty && !socialPostVm.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && userVm.roleName != null) {
              socialPostVm.getPostsByRole(roleName: userVm.roleName!);
            }
          });
        }
        
        if(socialPostVm.isLoading){
          return SocialFeedShimmer();
        }
        if(socialPostVm.errorMessage != null && socialPostVm.posts.isEmpty){
          return BackgroundErrorState(
            title: "Hệ thống đang gặp sự cố\nVui lòng thử lại sau.",
            onRetry: () {
              if (userVm.roleName != null) {
                socialPostVm.getPostsByRole(roleName: userVm.roleName!);
              }
            },
          );
        }
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () => socialPostVm.refreshPosts(roleName: userVm.roleName!),
            displacement: 80,
            color: Colors.blue,
            backgroundColor: Colors.white,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
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
                      Divider(height: 20.h),
                      
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = socialPostVm.posts[index];
                      final isLast = index == socialPostVm.posts.length - 1;
                      // Kiểm tra trạng thái saved từ cả model và ViewModel để đảm bảo chính xác
                      // Ưu tiên post.isSaved vì nó được cập nhật ngay lập tức
                      final isSaved = post.isSaved || socialSavePostVm.isPostSaved(post.idPost);
                      return Column(
                        children: [
                          PostItem(
                            socialPostModel: post,
                            isLiked: socialPostVm.isPostLiked(post.idPost),
                            isSaved: isSaved,
                            isAccessJob: post.postType == PostType.job.name,
                            idUser: socialPostVm.currentUserId,
                            roleName: userVm.roleName!,
                            onDeletePost: () => _onDeletePost(post.idPost),
                            onEditPost: () => _onOpenEditPost(post),
                            onLike: () => socialPostVm.onToggleLike(post.idPost),
                            onSave: () => _onSavePost(context, post),
                            onShare: () => _onShowBottomSheet(
                              postId: post.idPost,
                              type: 'share',
                              onShare:() => _onAccessJob(post)
                            ),
                            onHide: () => socialPostVm.onHidePost(post.idPost),
                            onCopyLink: () => _onCopyPostLink(post.idPost),
                            onOpenDetail: () => _onOpenDetail(post),
                            onOpenProfile: () => _onOpenProfile(post.idUser),
                            onReport: () => _onReport(
                              authorName: post.userName ?? 'Người dùng ${AppStrings.appName}',
                              userName: userVm.currentUser!.userName,
                            ),
                            onComment: () => _onShowBottomSheet(
                              postId: post.idPost,
                              type: 'comment',
                              onComment: () => socialPostVm.onCommentPost(post.idPost),
                            ),
                            onAccessJob: post.idUser == userVm.currentUser?.idUser 
                              ? (){} 
                              : () => _onAccessJob(post),
                            onGoToGroup: () => _onGoToGroup(post.idGroup!),
                          ),
                          SizedBox(
                            height: 4.h,
                            width: double.infinity,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.borderSecondary.withValues(alpha: 0.2),
                              ),
                            ),
                          ),
                          if (isLast) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: SectionTitle(
                                title: "Bạn đã xem hết rồi",
                                textColor: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                                isCenter: true,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: SectionTitle(
                                title: "Hãy quay lại sau để xem những thông tin mới.",
                                textColor: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.25),
                                isCenter: true,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            CustomButtonIconSimple(
                              icon: Icons.refresh_rounded,
                              onTap: () {
                                socialPostVm.refreshPosts(roleName: userVm.roleName!);
                                onFirstPage();
                              },
                              color: theme.primaryColor,
                              size: 24.sp,
                            ),
                            SizedBox(height: 20.h),
                          ],
                        ],
                      );
                    },
                    childCount: socialPostVm.posts.length,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: _showFab
            ? ScaleTransition(
                scale: _scaleAnimation,
                child: GestureDetector(
                  onLongPress: onFirstPage,
                  onTap: !widget.isLoggedIn 
                    ? () => context.push(
                        '/auth/login', 
                        extra: {
                          'role': UserRole.candidate.name
                        }
                      )
                    : widget.onSearch,
                  child: Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isLoggedIn ? Icons.search_rounded : Icons.login,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                ),
              )
            : null,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}