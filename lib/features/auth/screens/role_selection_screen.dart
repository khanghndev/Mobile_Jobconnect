import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/enum/user_role.dart';
import 'package:job_connect/features/auth/widgets/role/role_card.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30.h),
                Text(
                  "Bạn thuộc nhóm nào?",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  "Chọn vai trò phù hợp để chúng tôi mang đến trải nghiệm tốt nhất cho bạn",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 40.h),
            
                RoleCard(
                  title: "Ứng viên",
                  description: "Tìm việc làm, xây dựng hồ sơ và kết nối với các nhà tuyển dụng hàng đầu.",
                  imagePath: AppImages.candidateRole,
                  backgroundColor: const Color(0xFFEAF3FF),
                  borderColor: theme.primaryColor,
                  onTap: () => context.push(
                    '/auth/login', 
                    extra: {
                      'role': UserRole.candidate.name
                    }
                  ),
                ),
            
                RoleCard(
                  title: "Nhà tuyển dụng",
                  description: "Đăng tuyển, quản lý ứng viên và phát triển đội ngũ của bạn.",
                  imagePath: AppImages.recruiterRole,
                  backgroundColor: const Color(0xFFFFF4E5),
                  borderColor: const Color(0xFFFFA726),
                  onTap: () => context.push(
                    '/auth/login', 
                    extra: {
                      'role': UserRole.recruiter.name
                    }
                  ),
                ),
            
                RoleCard(
                  title: "Khách",
                  description: "Trải nghiệm mà không cần đăng nhập.",
                  imagePath: AppImages.defaultAvatar,
                  backgroundColor: const Color(0xFFF5F5F5),
                  borderColor: const Color(0xFFBDBDBD),
                  onTap: () => context.go('/home', extra: {
                    'isLoggedIn': false,
                    'idUser': '###',
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}