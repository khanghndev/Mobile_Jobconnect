import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/features/mini_social/model/group_member_model.dart';

class GroupMemberItem extends StatelessWidget {
  final GroupMemberModel member;
  final bool canApprove; 
  final bool canManageRole; // <-- cho biết user hiện tại có quyền set role
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onRemove;
  final VoidCallback? onOpenProfile;

  // callback role
  final VoidCallback? onPromoteAdmin; // thăng cấp quản trị viên
  final VoidCallback? onDemoteMember; // hạ xuống thành viên

  const GroupMemberItem({
    super.key,
    required this.member,
    this.canApprove = false,
    this.canManageRole = false,
    this.onApprove,
    this.onReject,
    this.onRemove,
    this.onOpenProfile,
    this.onPromoteAdmin,
    this.onDemoteMember,
  });

  Color _roleColor() {
    if (member.status == 'pending') return Colors.grey;
    if (member.roleInGroup == 'owner') return Colors.red;
    if (member.roleInGroup == 'admin') return Colors.orange;
    return Colors.blueGrey;
  }

  String _roleLabel() {
    if (member.status == 'pending') return 'Đang chờ duyệt';
    if (member.roleInGroup == 'owner') return 'Quản trị viên chính';
    if (member.roleInGroup == 'admin') return 'Quản trị viên';
    return 'Thành viên';
  }

  void _showRoleActionBottomSheet(BuildContext context) {
    if (!canManageRole || member.roleInGroup == "owner") return;

    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(16.w),
          child: IconTheme(
            data: IconThemeData(
              size: 22.sp, // set kích thước icon đồng bộ
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Quản lý quyền",
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                /// THĂNG ADMIN
                if (member.roleInGroup != "admin")
                  ListTile(
                    leading: Icon(Icons.arrow_upward, color: Colors.green),
                    title: Text(
                      "Thăng cấp quản trị viên",
                      style: textTheme.bodyLarge?.copyWith(fontSize: 18.sp),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onPromoteAdmin?.call();
                    },
                  ),

                /// HẠ XUỐNG MEMBER
                if (member.roleInGroup == "admin")
                  ListTile(
                    leading: Icon(Icons.arrow_downward, color: Colors.orange),
                    title: Text(
                      "Hạ xuống thành viên",
                      style: textTheme.bodyLarge?.copyWith(fontSize: 18.sp),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onDemoteMember?.call();
                    },
                  ),

                /// HỦY
                ListTile(
                  leading: const Icon(Icons.close),
                  title: Text(
                    "Hủy",
                    style: textTheme.bodyLarge?.copyWith(fontSize: 18.sp),
                  ),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    final isPending = member.status == 'pending';
    final canShowApproveButtons = canApprove && isPending;

    final canShowRoleButton = canManageRole && member.roleInGroup != "owner";

    return GestureDetector(
      onLongPress: () => _showRoleActionBottomSheet(context),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onOpenProfile,
              child: CircleAvatar(
                radius: 24.r,
                backgroundImage: ImageUtils.getImageProvider(member.avatarUrl),
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
                      member.userName,
                      style: theme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: _roleColor(),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        _roleLabel(),
                        style: theme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// DUYỆT
                if (canShowApproveButtons)
                  Row(
                    children: [
                      TextButton(
                        onPressed: onApprove,
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
                        child: Text("Chấp nhận", style: theme.labelSmall?.copyWith(color: Colors.green)),
                      ),
                      SizedBox(width: 4.w),
                      TextButton(
                        onPressed: onReject,
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
                        child: Text("Từ chối", style: theme.labelSmall?.copyWith(color: Colors.red)),
                      ),
                    ],
                  ),

                /// NÚT CẤP QUYỀN
                if (canShowRoleButton)...[
                  TextButton(
                    onPressed: () => _showRoleActionBottomSheet(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: Colors.blue,
                      side: BorderSide(color: member.roleInGroup == "admin" ? Colors.orange : Colors.blue,),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    child: Icon(
                      member.roleInGroup == "admin"
                          ? Icons.arrow_downward       // Hạ xuống member
                          : Icons.arrow_upward,        // Thăng lên admin
                      color: member.roleInGroup == "admin" ? Colors.orange : Colors.blue,
                      size: 22.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                  
                /// NÚT XÓA MEMBER
                if (onRemove != null)
                  TextButton(
                    onPressed: onRemove,
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
                    child: Text("Xóa", style: theme.labelSmall?.copyWith(color: Colors.red)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
