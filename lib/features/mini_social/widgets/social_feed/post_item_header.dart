import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/features/mini_social/screens/social_report_post_screem.dart';

class PostItemHeader extends StatefulWidget {
  final String avatarUrl;
  final String username;
  final String group;
  final String timeAgo;
  final String postId; // thêm postId
  final VoidCallback onFollow;

  const PostItemHeader({
    super.key,
    required this.avatarUrl,
    required this.username,
    required this.group,
    required this.timeAgo,
    required this.postId, 
    required this.onFollow,
  });

  @override
  State<PostItemHeader> createState() => _PostItemHeaderState();
}

class _PostItemHeaderState extends State<PostItemHeader> {
  bool _isFollowed = false;

  void _toggleFollow() {
    widget.onFollow(); 
    setState(() {
      _isFollowed = !_isFollowed; 
    });
  }

  void _copyPostLink() {
    final link = "https://jobconnect.app/post/${widget.postId}";
    Clipboard.setData(ClipboardData(text: link));
    SnackbarApp.show(
      context,
        title: "Thành công",
        message: "Sao chép link thành công",
        bgColor: ThemeData.light().primaryColor,
        icon: Icons.check_circle_outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap:() => context.push('/profile'),
          child: CircleAvatar(
            radius: 20.r,
            backgroundImage: NetworkImage(widget.avatarUrl),
          ),
        ),
        SizedBox(width: 12.h),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap:() => context.push('/profile'),
                      child: Text(
                        widget.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_right, color: Colors.black, size: 16),
                  Flexible(
                    child: GestureDetector(
                      onTap:() => context.push('/group'),
                      child: Text(
                        widget.group,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                widget.timeAgo,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Nút toggle theo dõi
        TextButton(
          onPressed: _toggleFollow,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: _isFollowed ? Colors.grey : Colors.blue,
            side: BorderSide(color: _isFollowed ? Colors.grey : Colors.blue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            _isFollowed ? "Đã theo dõi" : "Theo dõi",
            style: const TextStyle(fontSize: 12),
          ),
        ),

        SizedBox(width: 10.w),
        SizedBox(
          height: 28.h,
          child: PopupMenuButton<int>(
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) {
              if (value == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) 
                  => ReportPostScreen(
                      userName: widget.username,
                      authorName: widget.username,
                    )
                  ),
                );
              } else if (value == 2) {
                // Bỏ theo dõi
              } else if (value == 3) {
                // Ẩn bài viết
              } else if (value == 4) {
                _copyPostLink(); // Gọi hàm copy link
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 1, child: Text("Báo cáo bài viết")),
              const PopupMenuItem(value: 2, child: Text("Bỏ theo dõi")),
              const PopupMenuItem(value: 3, child: Text("Ẩn bài viết")),
              const PopupMenuItem(value: 4, child: Text("Sao chép link bài viết")),
            ],
          ),
        )
      ],
    );
  }
}
