import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/utils/image_url.dart';

class CompanyLogoHeader extends StatelessWidget {
  final String companyName;
  final String industry;
  final String? logoCompany;
  final String jobName;
  final bool isCompany;
  const CompanyLogoHeader({
    super.key,
    required this.companyName,
    required this.industry,
    this.logoCompany,
    this.isCompany = true,
    required this.jobName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final companyInitial = (companyName.isNotEmpty)
        ? companyName[0].toUpperCase()
        : "C";
    final String? coverPhotoUrl = logoCompany;

    return Stack(
      alignment: Alignment.center,
      children: [
        //   NỀN
        SizedBox(
          height: 280.h,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: (coverPhotoUrl == null || coverPhotoUrl.isEmpty)
                ? LinearGradient(
                    colors: [
                      theme.primaryColor.withValues(alpha: 0.9),
                      theme.primaryColor.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
              image: (coverPhotoUrl != null && coverPhotoUrl.isNotEmpty)
                  ? DecorationImage(
                      image: ImageUtils.getImageProvider(coverPhotoUrl),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.35),
                        BlendMode.darken,
                      ),
                    )
                  : null,
            ),
          ),
        ),

        //  Logo + Tên công ty + Ngành nghề
        Positioned(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar/logo công ty
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.cardColor,
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.8),
                    width: 3.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.25),
                      blurRadius: 15.r,
                      spreadRadius: 1.r,
                      offset: Offset(0, 6.h),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: (logoCompany != null &&
                          logoCompany!.isNotEmpty)
                      ? Image.network(
                          logoCompany!,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Image.asset(
                              AppImages.logoApp,
                              width: 100.w,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            companyInitial,
                            style: theme.textTheme.displayMedium?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 40.sp,
                            ),
                          ),
                        ),
                ),
              ),

              SizedBox(height: 12.h),

              // Tên công ty
              Text(
                isCompany == true ? "Công ty" : "Công việc",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 22.sp,
                  color: (coverPhotoUrl != null && coverPhotoUrl.isNotEmpty)
                      ? Colors.white
                      : theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  shadows: (coverPhotoUrl != null && coverPhotoUrl.isNotEmpty)
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.7),
                            blurRadius: 5.r,
                            offset: Offset(0, 1.h),
                          ),
                        ]
                      : null,
                ),
                textAlign: TextAlign.center,
              ),

              // Ngành nghề
              if (industry.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  "Lĩnh vực: $industry",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    color: (coverPhotoUrl != null && coverPhotoUrl.isNotEmpty)
                        ? Colors.white.withValues(alpha: 0.9)
                        : theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}