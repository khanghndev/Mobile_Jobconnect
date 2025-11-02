import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/date_utils_helper.dart';
import 'package:job_connect/config/widgets/reaction_picker.dart';
import 'package:job_connect/features/mini_social/model/social_comment_model.dart';
import 'package:job_connect/features/mini_social/widgets/comments/comment_filter_dropdown.dart';
import 'package:job_connect/features/mini_social/widgets/comments/comment_input_field.dart';
import 'package:job_connect/features/mini_social/widgets/comments/comment_tile.dart';

class CommentBottomSheet extends StatefulWidget {
  final TextEditingController commentController;
  final Future<void> Function(String text, String? parentId) onSubmit;
  final List<SocialCommentModel> comments;
  final Future<void> Function()? onRefresh;
  final Function(SocialCommentModel)? onReply;
  final Function(SocialCommentModel)? onReact;
  final String Function(String userId)? resolveUsername;
  final String Function(String userId)? resolveUserAvatar;
  final bool? isDrag;
  final bool? isScrollComment;
  
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
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  String _selectedFilter = "Phù hợp nhất";
  SocialCommentModel? _replyingComment;
  bool _hasText = false;
  String? _selectedReaction;

  final List<String> _filters = ["Phù hợp nhất", "Mới nhất", "Tất cả bình luận"];

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

  Future<void> _onShowReactions(SocialCommentModel comment) async {
    await ReactionPicker.show(
      context,
      onSelected: (reaction) {
        setState(() => _selectedReaction = reaction);
        widget.onReact?.call(comment);
      },
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
    if (text.isEmpty) return;
    final parentId = _replyingComment?.idComment;
    widget.onSubmit(text, parentId);
    widget.commentController.clear();
    setState(() {
      _hasText = false;
      _replyingComment = null;
    });
  }

  // TODO: Nhóm comment cha/con 
  Map<String?, List<SocialCommentModel>> _groupComments(List<SocialCommentModel> comments) {
    final map = <String?, List<SocialCommentModel>>{};
    for (final c in comments) {
      final parent = c.parentComment;
      map.putIfAbsent(parent, () => []).add(c);
    }
    return map;
  }

  // TODO: Render 1 comment và replies 
  Widget _buildCommentWithReplies(
    SocialCommentModel comment,
    Map<String?, List<SocialCommentModel>> grouped,
  ) {
    final username = widget.resolveUsername?.call(comment.idUser) ?? "Người dùng";
    final avatarUrl = widget.resolveUserAvatar?.call(comment.idUser) ?? "";

    final replies = grouped[comment.idComment] ?? [];

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommentTile(
            username: username,
            avatarUrl: avatarUrl,
            text: comment.content,
            time: DateUtilsHelper.getTimeAgo(comment.createdAt),
            icon: _selectedReaction ?? '👍',
            count: 0,
            onReplyTap: () => _onReply(comment),
            onReactTap: () => _onShowReactions(comment),
          ),
          //  Replies 
          if (replies.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: 40.w, top: 4.h),
              child: Column(
                children: replies
                    .map((reply) => _buildCommentWithReplies(reply, grouped))
                    .toList(),
              ),
            ),
        ],
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
            //  Drag handle 
            if(widget.isDrag == true)...[
              Container(
                height: 4.h,
                width: 40.w,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ],

            SizedBox(height: 8.h),

            //  Filter 
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CommentFilterDropdown(
                  filters: _filters,
                  selectedFilter: _selectedFilter,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedFilter = val);
                  },
                ),
              ),
            ),
            SizedBox(height: 4.h),

            //  Comment list 
            Flexible(
              fit: FlexFit.loose,
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: RefreshIndicator(
                  onRefresh: widget.onRefresh ?? () async {},
                  child: rootComments.isEmpty
                      ? const Center(child: Text("Chưa có bình luận nào"))
                      : ListView.builder(
                          physics: widget.isScrollComment == true ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
                          itemCount: rootComments.length,
                          itemBuilder: (_, i) => _buildCommentWithReplies(rootComments[i], grouped),
                        ),
                ),
              ),
            ),

            Divider(height: 1.h),

            //  Replying bar 
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

            //  Input field 
            Padding(
              padding: EdgeInsets.all(8.w),
              child: CommentInputField(
                controller: widget.commentController,
                hasText: _hasText,
                onChanged: (value) => setState(() => _hasText = value.trim().isNotEmpty),
                onSend: _hasText ? _onSend : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
