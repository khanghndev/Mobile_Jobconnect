import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/image_url.dart';

class SearchUserItem extends StatelessWidget {
  final String avatar;
  final String name;
  final String? subtitle;
  final String postCount;
  final bool isFriend;
  final bool isRequestSent;
  final bool isRequestReceived; // ai đã gửi kết bạn cho tôi
  final VoidCallback? onSendRequest;    // gửi lời mời
  final VoidCallback? onCancelRequest;  // hủy gửi lời mời
  final VoidCallback? onUnfriend;       // hủy kết bạn
  final VoidCallback? onAcceptRequest;  // chấp nhận lời mời
  final VoidCallback? onRejectRequest;  // từ chối lời mời
  final VoidCallback? onOpenProfile;

  const SearchUserItem({
    super.key,
    required this.avatar,
    required this.name,
    this.subtitle,
    required this.postCount,
    this.isFriend = false,
    this.isRequestSent = false,
    this.isRequestReceived = false,
    this.onSendRequest,
    this.onCancelRequest, 
    this.onUnfriend,
    this.onAcceptRequest,
    this.onRejectRequest,
    this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    Widget buildButton() {
      if (isFriend) {
        return TextButton(
          onPressed: onUnfriend,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          child: Text(
            "Hủy kết bạn",
            style: theme.labelSmall?.copyWith(color: Colors.red, fontSize: 12.sp),
          ),
        );
      } else if (isRequestSent) {
        // Sửa lại button "Hủy gửi"
        return TextButton(
          onPressed: onCancelRequest,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: Colors.grey,
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          child: Text(
            "Hủy gửi",
            style: theme.labelSmall?.copyWith(color: Colors.red, fontSize: 12.sp),
          ),
        );
      } else if (isRequestReceived) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: onAcceptRequest,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text(
                "Chấp nhận",
                style: theme.labelSmall?.copyWith(color: Colors.green, fontSize: 12.sp),
              ),
            ),
            SizedBox(width: 4.w),
            TextButton(
              onPressed: onRejectRequest,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Text(
                "Từ chối",
                style: theme.labelSmall?.copyWith(color: Colors.red, fontSize: 12.sp),
              ),
            ),
          ],
        );
      } else {
        return TextButton(
          onPressed: onSendRequest,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: Colors.blue,
            side: const BorderSide(color: Colors.blue),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
          ),
          child: Text(
            "Kết bạn",
            style: theme.labelSmall?.copyWith(color: Colors.blue, fontSize: 12.sp),
          ),
        );
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onOpenProfile,
            child: CircleAvatar(
              radius: 24.r,
              backgroundImage: ImageUtils.getImageProvider(avatar),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: GestureDetector(
              onTap: onOpenProfile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: theme.bodySmall?.copyWith(fontSize: 12.sp),
                    ),
                  SizedBox(height: 4.h),
                  Text(
                    postCount,
                    style: theme.bodySmall?.copyWith(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ),
          buildButton(),
        ],
      ),
    );
  }
}
