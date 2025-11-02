import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/features/job/screens/job_history_screen.dart';
import 'package:job_connect/features/profile/widgets/profile/profile_avatar_breathing.dart';
import 'package:job_connect/features/profile/widgets/profile/profile_state_item.dart';

class ProfileHeaderCard extends StatelessWidget {
  final String idUser;
  final String? avatarUrl;
  final String? userName;
  final String? workPosition;
  final double completion;
  final int applicationCount;
  final int savedJobsCount;
  final VoidCallback onOpenEditProfile;

  const ProfileHeaderCard({
    super.key,
    required this.idUser,
    required this.completion,
    required this.applicationCount,
    required this.savedJobsCount,
    required this.onOpenEditProfile,
    this.avatarUrl,
    this.userName,
    this.workPosition,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplete = completion == 1.0;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 25.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onOpenEditProfile,
            child: Row(
              children: [
                // Avatar
                ProfileAvatarBreathing(
                  radius: 45.r,
                  backgroundImage: ImageUtils.getImageProvider(avatarUrl!),
                  borderColors: [
                    theme.colorScheme.secondary,
                    theme.colorScheme.tertiary,
                    theme.colorScheme.primary,
                  ],
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              userName ?? "Người Dùng ${AppStrings.appName}",
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp,
                              ),
                            ),
                          ),
                          if (isComplete) ...[
                            SizedBox(width: 6.w),
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20.sp,
                            ),
                          ],
                        ],
                      ),
                      if (workPosition != null && workPosition!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            workPosition!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),
          Divider(
            color: theme.dividerColor.withValues(alpha: 0.5),
            height: 1.h,
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ProfileStateItem(
                count: applicationCount.toDouble(),
                label: "Ứng tuyển",
                icon: Icons.outbox_rounded,
                color: theme.colorScheme.secondary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => JobHistoryScreen(idUser: idUser),
                  ),
                )
              ),
              ProfileStateItem(
                count: savedJobsCount.toDouble(),
                label: "Đã lưu",
                icon: Icons.bookmark_rounded,
                color: theme.colorScheme.secondary,
                onTap: () {
                  context.push(
                    '/home/search', 
                    extra: {
                      'isLoggedIn': true,
                      'idUser': idUser,
                      'initialTabIndex' : 2,
                    }
                  );
                }
              ),
              ProfileStateItem(
                count: completion * 100,
                label: "Hoàn thiện",
                icon: Icons.checklist_rtl_rounded,
                color: theme.colorScheme.primary,
                onTap: onOpenEditProfile,
                isPercentage: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
