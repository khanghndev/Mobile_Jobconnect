import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/features/navigation/widgets/custom_appbar_with_drawer/profile_avatar.dart';
import 'package:job_connect/features/profile/model/user_model.dart';

class SettingCardProfileHeader extends StatelessWidget {
  final UserModel? user;

  const SettingCardProfileHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: (){
        context.push(
          '/profile/edit',
          extra: {'idUser': user?.idUser},
        );
      },
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.8),
              theme.colorScheme.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withValues(alpha: 0.2),
              blurRadius: 12.r,
              offset: Offset(0.w, 4.h),
            ),
          ],
        ),
        child: Row(
          children: [
            ProfileAvatar(
              radius: 36.r,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.userName ?? "Người dùng",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    user?.email ?? "Chưa có email",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit_rounded, color: Colors.white, size: 24.sp),
              onPressed: () {
                context.push(
                  '/profile/edit',
                  extra: {'idUser': user?.idUser},
                );
              },
              tooltip: "Chỉnh sửa hồ sơ",
              splashRadius: 22.r,
            ),
          ],
        ),
      ),
    );
  }
}