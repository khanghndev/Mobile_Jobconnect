import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/enum/friend_status.dart';

class ProfileActions extends StatelessWidget {
  final VoidCallback onMessagePressed;
  final VoidCallback? onAddFriend;
  final VoidCallback? onUnfriend;
  final VoidCallback? onAcceptRequest;
  final VoidCallback? onCancelRequest;
  final FriendStatus friendStatus;
  final bool isLoading;

  const ProfileActions({
    super.key,
    required this.onMessagePressed,
    this.onAddFriend,
    this.onUnfriend,
    this.onAcceptRequest,
    this.onCancelRequest,
    this.friendStatus = FriendStatus.notFriend,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildButton(
          icon: Icons.message_outlined,
          label: "Nhắn tin",
          bgColor: Colors.white,
          fgColor: Colors.black,
          onPressed: onMessagePressed,
        ),
        SizedBox(width: 12.w),
        _buildFriendButton(),
      ],
    );
  }

  Widget _buildFriendButton() {
    String label = "";
    Color bgColor = Colors.white;
    Color fgColor = Colors.black;
    VoidCallback? callback;

    switch (friendStatus) {
      case FriendStatus.notFriend:
        label = "Kết bạn";
        bgColor = Colors.blue;
        fgColor = Colors.white;
        callback = isLoading ? null : onAddFriend;
        break;
      case FriendStatus.requestSent:
        label = "Hủy lời mời";
        bgColor = Colors.white;
        fgColor = Colors.red;
        callback = isLoading ? null : onCancelRequest;
        break;
      case FriendStatus.requestReceived:
        label = "Chấp nhận";
        bgColor = Colors.green;
        fgColor = Colors.white;
        callback = isLoading ? null : onAcceptRequest;
        break;
      case FriendStatus.friend:
        label = "Hủy kết bạn";
        bgColor = Colors.white;
        fgColor = Colors.red;
        callback = isLoading ? null : onUnfriend;
        break;
    }

    return _buildButton(
      label: label,
      bgColor: bgColor,
      fgColor: fgColor,
      onPressed: callback ?? () {},
    );
  }

  Widget _buildButton({
    IconData? icon,
    required String label,
    required Color bgColor,
    required Color fgColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues( alpha: 0.15),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          minimumSize: Size(140.w, 44.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 18.sp) : const SizedBox.shrink(),
        label: Text(label, style: TextStyle(fontSize: 14.sp)),
      ),
    );
  }
}
