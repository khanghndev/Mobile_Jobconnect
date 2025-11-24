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
        // Avatar nhà tuyển dụng nhỏ gọn
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 2.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 6.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.w),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                user?.userName ?? 'Người dùng',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  letterSpacing: 0.1,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    Icons.business_outlined,
                    color: Colors.white.withValues(alpha: 0.9),
                    size: 14.sp,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      companyInfo?.companyName ?? "Chưa có công ty",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFD700),
                      Color(0xFFFFC107),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      blurRadius: 4.r,
                      offset: Offset(0, 1.h),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 12.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      isPremiumUser
                          ? packageName ?? "Gói Cao Cấp"
                          : "Gói Cơ bản",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                        letterSpacing: 0.2,
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
