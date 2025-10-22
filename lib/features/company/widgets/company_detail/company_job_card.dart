import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/config/widgets/info_chip.dart';
import 'package:job_connect/data/models/job_posting_model.dart';
import 'package:job_connect/features/job/screens/job_detail_screen.dart';

class CompanyJobCard extends StatelessWidget {
  final JobPostingModel job;
  final String idUser;

  const CompanyJobCard({
    super.key,
    required this.job,
    required this.idUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobCompanyLogoUrl = job.company!.logoCompany;
    final jobCompanyName = job.company!.companyName;
    final jobCompanyInitial =
        (jobCompanyName.isNotEmpty) ? jobCompanyName[0].toUpperCase() : "J";
    final salaryText = (job.salary != null && job.salary! > 0)
        ? FormatUtils.formatSalary(job.salary!)
        : "Thỏa Thuận";

    return Card(
      elevation: 2.5,
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      color: theme.cardColor,
      child: InkWell(
        onTap: () async {
          // TODO: Chuyển sang trang chi tiết công việc
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  JobDetailScreen(idUser: idUser, jobPosting: job),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16.r),
        splashColor: theme.primaryColor.withValues(alpha: 0.1),
        highlightColor: theme.primaryColor.withValues(alpha: 0.05),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.3),
                        width: 0.8.w,
                      ),
                    ),
                    child: (jobCompanyLogoUrl != null && jobCompanyLogoUrl.isNotEmpty)
                    // TODO: ẢNH 
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(11.r),
                          child: Image.network(
                            jobCompanyLogoUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                Image.asset(AppImages.logoApp,),
                          ),
                        )
                      : Center(
                          child: Text(
                            jobCompanyInitial,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 22.sp,
                            ),
                          ),
                        ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TODO: LABEL NỔI BẬT
                        if (job.isFeatured == 1) ...[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            margin: EdgeInsets.only(bottom: 7.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.amber.shade600, Colors.orange.shade400],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'NỔI BẬT',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                fontSize: 11.sp,
                              ),
                            ),
                          )
                        ],
                        // TODO: TÊN CÔNG VIỆC
                        Text(
                          job.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                            fontSize: 17.sp,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        // TODO: TÊN CÔNG TY
                        Text(
                          jobCompanyName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.85),
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // TODO: DANH SÁCH CHIP
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    size: 26.sp,
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 8.h,
                children: [
                  InfoChip(
                    icon: Icons.location_city_outlined,
                    label: FormatUtils.extractDistrictAndCity(job.location),
                    color: Theme.of(context).colorScheme.secondary,
                    isHighlighted: true,
                  ),
                  InfoChip(
                    icon: Icons.attach_money_rounded,
                    label: salaryText,
                    color: theme.colorScheme.secondary,
                    isHighlighted: true,
                  ),
                  if (job.workType.isNotEmpty)
                    InfoChip(
                      icon: Icons.work_history_outlined,
                      label: job.workType,
                      color: theme.colorScheme.primary,
                      isHighlighted: true,
                    ),
                  if (job.experienceLevel.isNotEmpty)
                    InfoChip(
                      icon: Icons.military_tech_outlined,
                      label: job.experienceLevel,
                      color: theme.colorScheme.tertiary,
                      isHighlighted: true,
                    ),
                  InfoChip(
                    icon: Icons.calendar_month_outlined,
                    label: "Thời gian đăng ${FormatUtils.formattedDateTime(job.createdAt)}",
                    color: theme.colorScheme.onSurfaceVariant,
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