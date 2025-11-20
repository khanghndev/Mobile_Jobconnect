import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/features/company/model/company_model.dart';

class RecruiterInfoRow extends StatelessWidget {
  final UserModel? user;
  final CompanyModel? companyInfo;
  final bool isPremiumUser;
  final String? packageName;

  const RecruiterInfoRow({
    super.key,
    required this.user,
    required this.companyInfo,
    this.isPremiumUser = false,
    this.packageName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Avatar nhà tuyển dụng
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 2.w),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25.w),
            child: Image(
              image: ImageUtils.getImageProvider(user?.avatarUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        // Thông tin nhà tuyển dụng
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.userName ?? 'Người dùng',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "Công ty: ${companyInfo?.companyName ?? "chưa có"}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Color(0xFFFFD700),
                      size: 12,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isPremiumUser
                          ? packageName ?? "Gói Cao Cấp"
                          : "Gói Cơ bản",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFFFD700),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
