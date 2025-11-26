import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/features/company/model/company_model.dart';

class CompanyInfoCard extends StatelessWidget {
  final CompanyModel company;
  final String idUser;
  final VoidCallback? onRefresh;

  const CompanyInfoCard({
    super.key,
    required this.company,
    required this.idUser,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.apartment_rounded,
                color: theme.primaryColor,
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                "Thông Tin Công Ty",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Material(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(16.r),
            elevation: 1.5,
            shadowColor: theme.shadowColor.withValues(alpha: 0.05),
            child: InkWell(
              onTap: () {
                context.push(
                  '/company/detail',
                  extra: {
                    "company": company,
                    "idUser": idUser,
                  },
                );
              },
              borderRadius: BorderRadius.circular(16.r),
              splashColor: theme.primaryColor.withValues(alpha: 0.1),
              highlightColor: theme.primaryColor.withValues(alpha: 0.05),
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32.r,
                      backgroundColor: theme.colorScheme.primaryContainer
                          .withValues(alpha: 0.15),
                      child: (company.logoCompany != null &&
                              company.logoCompany!.isNotEmpty)
                          ? ClipOval(
                              child: Image.network(
                                company.logoCompany!,
                                fit: BoxFit.contain,
                                width: 50.w,
                                height: 50.h,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                  Icons.business_rounded,
                                  color: theme.colorScheme.primary,
                                  size: 30.sp,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.business_rounded,
                              color: theme.colorScheme.primary,
                              size: 30.sp,
                            ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            company.companyName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Icon(
                                Icons.visibility_outlined,
                                size: 18.sp,
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.8),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                "Xem chi tiết công ty",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 20.sp,
                      color: theme.iconTheme.color?.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
