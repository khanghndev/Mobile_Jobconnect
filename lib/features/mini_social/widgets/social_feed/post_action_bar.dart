import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/comment_bottom_sheet.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/share_bottom_sheet.dart';

class PostActionBar extends StatefulWidget {
  final int reactionCount;
  final int commentCount;
  final int shareCount;
  final bool? isComment;

 const PostActionBar({
    super.key,
    required this.reactionCount,
    required this.commentCount,
    required this.shareCount, 
    this.isComment,
  });

  @override
  State<PostActionBar> createState() => _PostActionBarState();
}

class _PostActionBarState extends State<PostActionBar> {
  late int _likes;
  bool _isLiked = false;
  bool _isSaved = false;
  String? _selectedReaction; // Reaction emoji

  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _likes = widget.reactionCount;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      if (_isLiked) {
        _likes -= 1;
        _selectedReaction = null;
      } else {
        _likes += 1;
        _selectedReaction ??= '👍';
      }
      _isLiked = !_isLiked;
    });
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
  }

  void _submitComment() {
    final comment = _commentController.text.trim();
    if (comment.isNotEmpty) {
      print("Comment gửi: $comment");
      _commentController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Đã gửi bình luận!')),
      );
    }
  }

  void _showBottomSheet(String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.7,
          minChildSize: 0.3,
          builder: (_, controller) {
            return type == 'comment'
              ? Padding(
                padding: EdgeInsetsGeometry.all(8.w),
                child: CommentBottomSheet(
                    commentController: _commentController,
                    onSubmit: _submitComment,
                  ),
              )
              : ShareBottomSheet(
                  initialUsers: List.generate(6, (i) => {
                    'name': 'Người dùng $i',
                    'avatar': 'https://i.pravatar.cc/150?img=${i + 5}',
                  }),
                );
          },
        );
      },
    );
  }

  Future<void> _showReactions() async {
    final reactions = ['😂', '😍', '😢', '😡', '👍'];
    final selected = await showDialog<String>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: reactions.map((e) => GestureDetector(
                onTap: () => Navigator.of(ctx).pop(e),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Text(e, style: TextStyle(fontSize: 28.sp)),
                ),
              )).toList(),
            ),
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedReaction = selected;
        if (!_isLiked) _likes += 1;
        _isLiked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          child: Row(
            children: [
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(left: 30, child: Text('😢', style: TextStyle(fontSize: 18.sp))),
                      Positioned(left: 14, child: Text('😍', style: TextStyle(fontSize: 18.sp))),
                      Text('😂', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  SizedBox(width: 40.w),
                  Text(
                    '$_likes',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
             Spacer(),
              Text('${widget.commentCount} bình luận', style: TextStyle(fontSize: 14.sp)),
              SizedBox(width: 8.w),
              Text('${widget.shareCount} lượt chia sẻ', style: TextStyle(fontSize: 14.sp)),
            ],
          ),
        ),
       Divider(height: 4.h),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAction(
                icon: _selectedReaction != null ? null : (_isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined),
                label: _selectedReaction ?? (_isLiked ? "Đã thích" : "Thích"),
                onTap: _toggleLike,
                onLongPress: _showReactions,
                active: _isLiked,
              ),
              _buildAction(
                icon: Icons.chat_bubble_outline,
                label: "Bình luận",
                onTap: () => widget.isComment ?? _showBottomSheet('comment'),
              ),
              _buildAction(
                icon: _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                label: _isSaved ? "Đã lưu" : "Lưu",
                onTap: _toggleSave,
                active: _isSaved,
              ),
              _buildAction(
                icon: Icons.reply_outlined,
                label: "Chia sẻ",
                onTap: () => _showBottomSheet('share'),
              ),
            ],
          ),
        ),
       Divider(height: 1),
      ],
    );
  }

  Widget _buildAction({
    IconData? icon,
    required String label,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
    bool active = false,
  }) {
    final color = active ? Colors.blue : Colors.black87;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(icon, size: 20, color: color)
            else
              Text(label, style: TextStyle(fontSize: 20.sp, color: color)),
            if (icon != null)
              SizedBox(height: 2.h),
            if (icon != null)
              Text(label, style: TextStyle(fontSize: 13.sp, color: color)),
          ],
        ),
      ),
    );
  }
}
