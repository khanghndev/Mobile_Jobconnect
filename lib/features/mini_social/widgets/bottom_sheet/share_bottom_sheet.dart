import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/features/mini_social/model/friend_model.dart';
import 'package:shimmer/shimmer.dart';

class ShareBottomSheet extends StatefulWidget {
  final List<FriendModel>? listFriend;
  final bool isLoading;
  final String postId;
  final String? titleSheet;
  final Future<void> Function(String targetUserId, String postId) onSendMessage;

  const ShareBottomSheet({
    super.key,
    required this.postId,
    required this.onSendMessage,
    this.listFriend,
    this.isLoading = false, 
    this.titleSheet,
  });

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 16.h),

          // Title
          Row(
            children: [
              Text(
                widget.titleSheet ?? "Chia sẻ tới",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () => context.pop(),
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(Icons.close_rounded, size: 24.sp, color: Colors.grey[700]),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // List
          Expanded(
            child: Builder(
              builder: (context) {
                // Nếu đang loading, show shimmer
                if (widget.isLoading) return _buildShimmer();

                // Nếu dữ liệu null hoặc rỗng
                final friends = widget.listFriend ?? [];
                if (friends.isEmpty) {
                  return Center(
                    child: Text(
                      "Không có bạn bè để ${widget.titleSheet == null ? "chia sẻ" : "mời"}",
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                    ),
                  );
                }

                // Nếu có dữ liệu
                return ListView.separated(
                  padding: EdgeInsets.only(bottom: 12.h),
                  itemCount: friends.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (_, i) {
                    final user = friends[i];
                    return _buildFriendItem(user, theme);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendItem(FriendModel user, ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues( alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26.r,
            backgroundImage: ImageUtils.getImageProvider(user.avatar),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                SizedBox(height: 2.h),
                Text("Nhấn để chia sẻ", style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
              ],
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () async {
              await widget.onSendMessage(user.id, widget.postId);
              if (context.mounted) context.pop();
            },
            child: Container(
              decoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle),
              padding: EdgeInsets.all(10.w),
              child: Icon(Icons.send, color: Colors.white, size: 18.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding: EdgeInsets.only(bottom: 12.h),
      itemCount: 6,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
          child: Row(
            children: [
              Container(width: 52.w, height: 52.w, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14.h, width: double.infinity, color: Colors.white, margin: EdgeInsets.only(bottom: 4.h)),
                    Container(height: 12.h, width: 150.w, color: Colors.white),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Container(width: 36.w, height: 36.w, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            ],
          ),
        ),
      ),
    );
  }
}
