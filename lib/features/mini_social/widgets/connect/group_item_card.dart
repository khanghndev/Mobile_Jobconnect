import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/enum/join_status.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/features/mini_social/model/social_groups_model.dart';

class GroupItemCard extends StatelessWidget {
  final SocialGroupsModel group;
  final JoinStatus joinStatus;
  final void Function(SocialGroupsModel group)? onJoinGroup;
  final void Function(String id)? onTap;
  final void Function(String id)? onDeleteGroup;

  const GroupItemCard({
    super.key,
    required this.group,
    required this.joinStatus,
    this.onJoinGroup,
    this.onTap,
    this.onDeleteGroup,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onTap?.call(group.idGroup),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar nhóm
            CircleAvatar(
              radius: 28.r,
              backgroundImage: ImageUtils.getImageProvider(group.avatarUrl ?? ''),
            ),

            SizedBox(width: 12.w),

            // Tên & mô tả
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.groupName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    group.description ?? "Không có mô tả",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Nút Join / Đã tham gia
            IconButton(
              onPressed: (joinStatus == JoinStatus.joined || joinStatus == JoinStatus.pending) 
                ? null 
                : joinStatus == JoinStatus.myGroup
                  ? () => onDeleteGroup?.call(group.idGroup)
                  : () => onJoinGroup?.call(group),
              icon:  
                joinStatus == JoinStatus.myGroup 
                ? Row(
                  children: [
                    Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                      size: 24.sp,
                    ),
                    SizedBox(width: 6.w),
                    // Icon(
                    //   Icons.edit,
                    //   color: Colors.black.withValues(alpha: 0.5),
                    //   size: 24.sp,
                    // ),
                  ],
                )
                : Icon(
                joinStatus == JoinStatus.joined
                    ? Icons.check_circle
                    : joinStatus == JoinStatus.canJoin
                        ? Icons.group_add
                        : joinStatus == JoinStatus.myGroup
                            ? Icons.delete_forever
                            : Icons.lock_clock,
                color: joinStatus == JoinStatus.joined 
                  ? Colors.green 
                  : joinStatus == JoinStatus.canJoin  
                    ? Colors.blue
                    : Colors.amber,
                size: 24.sp,
              ),
              tooltip: joinStatus == JoinStatus.joined 
                ? 'Đã tham gia' 
                : joinStatus == JoinStatus.canJoin  
                  ? 'Tham gia nhóm'
                  : 'Đang chờ duyệt',
            ),
          ],
        ),
      ),
    );
  }
}