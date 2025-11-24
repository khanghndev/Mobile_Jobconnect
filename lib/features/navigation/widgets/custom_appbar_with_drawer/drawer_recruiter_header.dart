import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/features/navigation/widgets/custom_appbar_with_drawer/profile_avatar.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:provider/provider.dart';

class DrawerRecruiterHeader extends StatelessWidget {
  final bool isLoggedIn;

  const DrawerRecruiterHeader({
    super.key,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    const recruiterPrimary = Color(0xFF1A237E);
    const recruiterSecondary = Color(0xFF283593);
    
    final userVM = context.watch<UserViewModel>();
    final user = userVM.currentUser;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            recruiterPrimary,
            recruiterSecondary,
            recruiterPrimary.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: recruiterPrimary.withValues(alpha: 0.3),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8.r,
                          offset: Offset(0, 2.h),
                        ),
                      ],
                    ),
                    child: const ProfileAvatar(radius: 30),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoggedIn ? user?.userName ?? "Nhà tuyển dụng" : "Nhà tuyển dụng ${AppStrings.appName}",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          isLoggedIn ? user?.email ?? "Chào mừng bạn quay trở lại" : "Vui lòng đăng nhập",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white.withValues(alpha: 0.9),
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

