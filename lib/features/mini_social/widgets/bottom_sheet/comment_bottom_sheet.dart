import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/widgets/background_error_state.dart';
import 'package:shimmer/shimmer.dart';
import 'package:job_connect/config/utils/date_utils_helper.dart';
import 'package:job_connect/features/mini_social/model/social_comment_model.dart';
import 'package:job_connect/features/mini_social/widgets/comments/comment_input_field.dart';
import 'package:job_connect/features/mini_social/widgets/comments/comment_tile.dart';

class CommentBottomSheet extends StatefulWidget {
  final TextEditingController commentController;
  final Future<void> Function(String text, String? parentId, String? imagePath, String? icon) onSubmit;
  final List<SocialCommentModel> comments;
  final Future<void> Function()? onRefresh;
  final Function(SocialCommentModel)? onReply;
  final Function(SocialCommentModel)? onReact;
  final String Function(String userId)? resolveUsername;
  final String Function(String userId)? resolveUserAvatar;
  final bool? isDrag;
  final bool? isScrollComment;
  final bool isLoading; 
  final String? errorMessage;
  final VoidCallback? onRefesh;
  
  const CommentBottomSheet({
    super.key,
    required this.commentController,
    required this.onSubmit,
    required this.comments,
    this.onRefresh,
    this.onReply,
    this.onReact,
    this.resolveUsername,
    this.resolveUserAvatar,
    this.isDrag = true,
    this.isScrollComment = true,
    this.isLoading = false,
    this.errorMessage,
    this.onRefesh,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  SocialCommentModel? _replyingComment;
  bool _hasText = false;
  String? _selectedReaction;
  String? _selectedImagePath;
  String? _selectedIcon;

  @override
  void initState() {
    super.initState();
    widget.commentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasContent = widget.commentController.text.trim().isNotEmpty;
    if (hasContent != _hasText) {
      setState(() => _hasText = hasContent);
    }
  }

  @override
  void dispose() {
    widget.commentController.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onGoToProfile(String idUser) {
    context.push(
      '/social/profile', 
      extra: {
        'idUser': idUser
      }
    );
  }


  void _onReply(SocialCommentModel comment) {
    final username = widget.resolveUsername?.call(comment.idUser) ?? "Người dùng";
    
    widget.commentController.text = "@$username ";
    widget.commentController.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.commentController.text.length),
    );

    setState(() {
      _replyingComment = comment;
      _hasText = true;
    });

    widget.onReply?.call(comment);
  }

  void _cancelReply() {
    setState(() => _replyingComment = null);
    widget.commentController.clear();
  }

  void _onSend() {
    final text = widget.commentController.text.trim();
    final hasContent = text.isNotEmpty || _selectedImagePath != null || _selectedIcon != null;
    if (!hasContent) return;
    
    final parentId = _replyingComment?.idComment;
    // Gửi text, imagePath và icon
    widget.onSubmit(text, parentId, _selectedImagePath, _selectedIcon);
    
    widget.commentController.clear();
    setState(() {
      _hasText = false;
      _replyingComment = null;
      _selectedImagePath = null;
      _selectedIcon = null;
    });
  }
  
  void _onImageSelected(String? imagePath) {
    setState(() {
      _selectedImagePath = imagePath;
    });
  }
  
  void _onIconSelected(String? icon) {
    setState(() {
      _selectedIcon = icon;
    });
  }

  Map<String?, List<SocialCommentModel>> _groupComments(List<SocialCommentModel> comments) {
    final map = <String?, List<SocialCommentModel>>{};
    for (final c in comments) {
      final parent = c.parentComment;
      map.putIfAbsent(parent, () => []).add(c);
    }
    return map;
  }

 Widget _buildCommentWithReplies(
    SocialCommentModel comment,
    Map<String?, List<SocialCommentModel>> grouped,
  ) {
    final username = widget.resolveUsername?.call(comment.idUser) ?? "Người dùng";
    final avatarUrl = widget.resolveUserAvatar?.call(comment.idUser) ?? "";
    final replies = _collectAllReplies(comment.idComment, grouped);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommentTile(
            username: username,
            avatarUrl: avatarUrl,
            textContent: comment.content,
            time: DateUtilsHelper.timeAgo(comment.createdAt),
            icon: _selectedReaction ?? '👍',
            count: 0,
            imageUrl: comment.imageUrl,
            commentIcon: comment.icon,
            onReplyTap: () => _onReply(comment),
            onReactTap: () => (){},
            onUserTap: () => _onGoToProfile(comment.idUser),
          ),

          if (replies.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 40.w, top: 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: replies.map((reply) {
                  final replyUsername = widget.resolveUsername?.call(reply.idUser) ?? "Người dùng";
                  final replyAvatar = widget.resolveUserAvatar?.call(reply.idUser) ?? "";

                  return Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: CommentTile(
                      username: replyUsername,
                      avatarUrl: replyAvatar,
                      textContent: reply.content,
                      time: DateUtilsHelper.timeAgo(reply.createdAt),
                      icon: _selectedReaction ?? '👍',
                      count: 0,
                      imageUrl: reply.imageUrl,
                      commentIcon: reply.icon,
                      onReplyTap: () => _onReply(comment), 
                      onReactTap: () => (){},
                      onUserTap: () => _onGoToProfile(reply.idUser),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  List<SocialCommentModel> _collectAllReplies(
    String? parentId,
    Map<String?, List<SocialCommentModel>> grouped,
  ) {
    final result = <SocialCommentModel>[];
    final directReplies = grouped[parentId] ?? [];

    for (final reply in directReplies) {
      result.add(reply);
      result.addAll(_collectAllReplies(reply.idComment, grouped)); 
    }
    return result;
  }

  // Widget shimmer cho loading
  Widget _buildShimmer() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: 5,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 40.w, height: 40.w, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 12.h, color: Colors.white, margin: EdgeInsets.only(bottom: 4.h)),
                    Container(height: 10.h, width: double.infinity, color: Colors.white, margin: EdgeInsets.only(bottom: 4.h)),
                    Container(height: 10.h, width: 150.w, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupComments(widget.comments);
    final rootComments = grouped[null] ?? [];

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            if (widget.isDrag == true)
              Container(
                height: 4.h,
                width: 40.w,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            // Filter dropdown
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 12.w),
            //   child: Align(
            //     alignment: Alignment.centerLeft,
            //     child: CommentFilterDropdown(
            //       filters: _filters,
            //       selectedFilter: _selectedFilter,
            //       onChanged: (val) {
            //         if (val != null) setState(() => _selectedFilter = val);
            //       },
            //     ),
            //   ),
            // ),

            // Comment list hoặc shimmer khi loading
            Flexible(
              fit: FlexFit.loose,
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: widget.isLoading
                  ? _buildShimmer()
                  :  widget.errorMessage != null
                    ? BackgroundErrorState(
                        title: "Hệ thống đang gặp sự cố\nVui lòng thử lại sau.\n ${widget.errorMessage}",
                        onRetry: () => widget.onRefesh,
                      )
                    : RefreshIndicator(
                        onRefresh: widget.onRefresh ?? () async {},
                        child: rootComments.isEmpty
                          ? Center(
                              child: Text(
                                "Chưa có bình luận nào",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              physics: widget.isScrollComment == true
                                  ? const BouncingScrollPhysics()
                                  : const NeverScrollableScrollPhysics(),
                              itemCount: rootComments.length,
                              itemBuilder: (_, i) => _buildCommentWithReplies(rootComments[i], grouped),
                            ),
                      ),
                ),
              ),

            Divider(height: 1.h),

            // Replying bar
            if (_replyingComment != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Đang trả lời ${widget.resolveUsername?.call(_replyingComment!.idUser) ?? "người dùng"}",
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: _cancelReply,
                      child: Text(
                        "Huỷ",
                        style: TextStyle(fontSize: 14.sp, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),

            // Input field
            Padding(
              padding: EdgeInsets.all(8.w),
              child: CommentInputField(
                controller: widget.commentController,
                hasText: _hasText || _selectedImagePath != null || _selectedIcon != null,
                onChanged: (value) => setState(() => _hasText = value.trim().isNotEmpty),
                onSend: (_hasText || _selectedImagePath != null || _selectedIcon != null) ? _onSend : null,
                onImageSelected: _onImageSelected,
                onIconSelected: _onIconSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}