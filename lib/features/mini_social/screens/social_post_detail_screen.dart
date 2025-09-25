import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/mini_social/widgets/comments/comment_tile.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_action_bar.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/post_item_header.dart';

import '../widgets/social_feed/post_item.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  String _selectedFilter = "Phù hợp nhất";
  String? _replyingTo;
  bool hasText = false;

  final List<String> filters = ["Phù hợp nhất", "Mới nhất", "Tất cả bình luận"];

  final comments = List.generate(2, (i) => {
        'user': 'Phạm Trường Vũ',
        'time': '10 giờ',
        'text': 'Tự do làm những điều mình thích đi b.',
        'reactions': 4,
        'reactionIcon': '😆',
      });

  void _pickReaction(int index) async {
    final reactions = ['😂', '😍', '😢', '😡', '👍'];
    final selected = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Wrap(
          children: reactions.map((e) {
            return InkWell(
              onTap: () => Navigator.pop(ctx, e),
              child: Padding(
                padding: EdgeInsets.all(8.r),
                child: Text(e, style: TextStyle(fontSize: 24.sp)),
              ),
            );
          }).toList(),
        ),
      ),
    );
    if (selected != null) {
      setState(() {
        comments[index]['reactionIcon'] = selected;
        comments[index]['reactions'] = (comments[index]['reactions'] as int) + 1;
      });
    }
  }

  void _replyTo(String user) {
    setState(() => _replyingTo = user);
    _commentController.text = "@$user ";
    _commentController.selection = TextSelection.fromPosition(
      TextPosition(offset: _commentController.text.length),
    );
    hasText = true;
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
      hasText = false;
    });
    _commentController.clear();
  }

  void _submitComment() {
    print("Send: ${_commentController.text}");
    _commentController.clear();
    setState(() {
      hasText = false;
      _replyingTo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết bài viết')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(bottom: 12.h),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: PostItemHeader(
                    postId: widget.post.postId,
                    avatarUrl: widget.post.avatarUrl,
                    username: widget.post.username,
                    group: widget.post.group,
                    timeAgo: widget.post.timeAgo,
                    onFollow: () {},
                  ),
                ),
                const Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    widget.post.content,
                    style: TextStyle(fontSize: 15.sp, height: 1.6),
                  ),
                ),
                SizedBox(height: 12.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: PostActionBar(
                    reactionCount: widget.post.likeCount,
                    commentCount: widget.post.commentCount,
                    shareCount: widget.post.shareCount,
                    isComment: false,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    underline: SizedBox.shrink(),
                    icon: Icon(Icons.arrow_drop_down),
                    items: filters
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e, style: TextStyle(fontSize: 14.sp)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedFilter = value);
                      }
                    },
                  ),
                ),
                ...comments.asMap().entries.map((entry) {
                  final i = entry.key;
                  final c = entry.value;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    child: CommentTile(
                      username: c['user'] as String,
                      text: c['text'] as String,
                      time: c['time'] as String,
                      icon: c['reactionIcon'] as String,
                      count: c['reactions'] as int,
                      onReplyTap: () => _replyTo(c['user'] as String),
                      onReactTap: () => _pickReaction(i),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          if (_replyingTo != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              child: Row(
                children: [
                  Text("Đang trả lời $_replyingTo",
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
                  Spacer(),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: Text("Huỷ",
                        style: TextStyle(fontSize: 14.sp, color: Colors.blue)),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Row(
              children: [
                Icon(Icons.camera_alt_outlined, size: 20.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    onChanged: (val) => setState(() => hasText = val.trim().isNotEmpty),
                    minLines: 1,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Viết bình luận công khai...",
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.gif_box_outlined, color: Colors.grey, size: 20.sp),
                          SizedBox(width: 8.w),
                          Icon(Icons.emoji_emotions_outlined, color: Colors.grey, size: 20.sp),
                          SizedBox(width: 8.w),
                        ],
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.r),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                IconButton(
                  onPressed: hasText ? _submitComment : null,
                  icon: Icon(Icons.send,
                      color: hasText ? Colors.blue : Colors.grey, size: 20.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
