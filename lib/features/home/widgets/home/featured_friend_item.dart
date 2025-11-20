import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/config/widgets/info_chip.dart';
import 'package:job_connect/features/profile/model/user_model.dart';

class FeaturedFriendItem extends StatelessWidget {
  final UserModel user;
  final bool isFriend;
  final bool isRequestSent;
  final bool isRequestReceived;
  final void Function(UserModel user)? onSendRequest;
  final void Function(UserModel user)? onCancelRequest;
  final void Function(UserModel user)? onAcceptRequest;
  final void Function(UserModel user)? onRejectRequest;
  final void Function(UserModel user)? onUnfriend;

  const FeaturedFriendItem({
    super.key,
    required this.user,
    this.isFriend = false,
    this.isRequestSent = false,
    this.isRequestReceived = false,
    this.onSendRequest,
    this.onCancelRequest,
    this.onAcceptRequest,
    this.onRejectRequest,
    this.onUnfriend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buildSingleButton({
      required String label,
      required Color textColor,
      required VoidCallback onPressed,
      IconData? icon,
    }) {
      return TextButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 16.sp, color: textColor) : const SizedBox.shrink(),
        label: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: textColor, fontWeight: FontWeight.w600),
        ),
        style: TextButton.styleFrom(
          backgroundColor: textColor.withValues(alpha:0.1),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      );
    }

    Widget buildButton() {
      if (isFriend) {
        return buildSingleButton(
          label: 'Hủy kết bạn',
          textColor: Colors.red,
          icon: Icons.person_remove,
          onPressed: () => onUnfriend?.call(user),
        );
      } else if (isRequestReceived) {
        return Row(
          children: [
            Expanded(
              child: buildSingleButton(
                label: 'Chấp nhận',
                textColor: Colors.green,
                icon: Icons.check_circle,
                onPressed: () => onAcceptRequest?.call(user),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: buildSingleButton(
                label: 'Từ chối',
                textColor: Colors.red,
                icon: Icons.cancel,
                onPressed: () => onRejectRequest?.call(user),
              ),
            ),
          ],
        );
      } else if (isRequestSent) {
        return buildSingleButton(
          label: 'Hủy gửi',
          textColor: Colors.red,
          icon: Icons.cancel,
          onPressed: () => onCancelRequest?.call(user),
        );
      } else {
        return buildSingleButton(
          label: 'Kết bạn',
          textColor: theme.colorScheme.primary,
          icon: Icons.person_add,
          onPressed: () => onSendRequest?.call(user),
        );
      }
    }

    return Container(
      width: 200.w,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 6, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40.r,
            backgroundImage: ImageUtils.getImageProvider(user.avatarUrl),
          ),
          SizedBox(height: 8.h),
          Text(
            user.userName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          InfoChip(
            icon: user.role?.roleName == 'Candidate' ? Icons.star_rounded : Icons.stars_rounded,
            label: user.role?.roleName == 'Candidate' ? 'Người tìm việc' : 'Nhà tuyển dụng',
            color: theme.colorScheme.secondary,
            isHighlighted: true,
            maxLines: 1,
          ),
          SizedBox(height: 12.h),
          SizedBox(width: double.infinity, child: buildButton()),
        ],
      ),
    );
  }
}
