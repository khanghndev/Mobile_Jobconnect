// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/mini_social/widgets/comments/comment_filter_dropdown.dart';
import 'package:job_connect/features/mini_social/widgets/comments/comment_input_field.dart';
import 'package:job_connect/features/mini_social/widgets/comments/comment_tile.dart';

class CommentBottomSheet extends StatefulWidget {
  final TextEditingController commentController;
  final VoidCallback onSubmit;

  const CommentBottomSheet({
    super.key,
    required this.commentController,
    required this.onSubmit,
  });

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  String _selectedFilter = "Phù hợp nhất";
  String? _replyingTo;
  bool hasText = false;
  String? _selectedReaction;

  final List<String> filters = ["Phù hợp nhất", "Mới nhất", "Tất cả bình luận"];

  final comments = List.generate(3, (i) => {
        'user': 'Phạm Trường Vũ',
        'time': '10 giờ',
        'text': 'Tự do làm những điều mình thích đi b.',
        'reactions': 4,
        'reactionIcon': '😆',
      });

  void _pickReaction() async {
    final reactions = ['😂', '😍', '😢', '😡', '👍'];
    final selected = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Wrap(
          children: reactions.map((e) => InkWell(
            onTap: () => Navigator.pop(ctx, e),
            child: Padding(
              padding: EdgeInsets.all(8.r),
              child: Text(e, style: TextStyle(fontSize: 24.sp)),
            ),
          )).toList(),
        ),
      ),
    );
    if (selected != null) {
      setState(() => _selectedReaction = selected);
    }
  }

  void _replyTo(String user) {
    setState(() => _replyingTo = user);
    widget.commentController.text = "@$user ";
    widget.commentController.selection = TextSelection.fromPosition(
      TextPosition(offset: widget.commentController.text.length),
    );
    hasText = true;
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
      hasText = false;
    });
    widget.commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          SizedBox(height: 8.h),
          Container(
            height: 4.h,
            width: 40.w,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CommentFilterDropdown(
                filters: filters,
                selectedFilter: _selectedFilter,
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedFilter = val);
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (_, i) {
                final c = comments[i];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  child: CommentTile(
                    username: c['user'] as String,
                    text: c['text'] as String,
                    time: c['time'] as String,
                    icon: c['reactionIcon'] as String,
                    count: c['reactions'] as int,
                    onReplyTap: () => _replyTo(c['user'] as String),
                    onReactTap: () => _pickReaction,
                  ),
                );
              },
            ),
          ),
          Divider(height: 1.h),
          if (_replyingTo != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              child: Row(
                children: [
                  Text("Đang trả lời $_replyingTo", style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
                  Spacer(),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: Text("Huỷ", style: TextStyle(fontSize: 14.sp, color: Colors.blue)),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: CommentInputField(
              controller: widget.commentController,
              hasText: hasText,
              onSend: hasText ? widget.onSubmit : null,
            ),
          ),
        ],
      ),
    );
  }
}
