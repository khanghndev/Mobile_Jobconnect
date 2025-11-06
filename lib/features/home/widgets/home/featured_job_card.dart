import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/config/widgets/info_chip.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';

class FeaturedJobCard extends StatelessWidget {
  final JobPostingModel job;
  final String idUser;
  final bool isSaved;
  final VoidCallback onSaveToggle;

  const FeaturedJobCard({
    super.key,
    required this.job, 
    required this.idUser,
    this.isSaved = false,
    required this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          margin: EdgeInsets.only(bottom: 20.h),
          elevation: 3,
          shadowColor: Theme.of(context).shadowColor.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: InkWell(
            onTap: () {
              context.push(
                '/job/detail',
                extra: {
                  "idUser": idUser,
                  "jobPosting": job,
                },
              );
            },
            borderRadius: BorderRadius.circular(18.r),
            child: Padding(
              padding: EdgeInsets.all(18.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 58.w,
                        height: 58.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withValues(alpha: 0.2),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14.r),
                          child: job.company!.logoCompany != null &&
                                  job.company!.logoCompany!.isNotEmpty
                              ? Image.network(
                                  job.company!.logoCompany!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                    child: Image.asset(
                                      AppImages.logoApp,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    job.company!.companyName
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              job.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              job.company!.companyName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.75),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Icon bookmark
                      InkWell(
                        onTap: onSaveToggle,
                        borderRadius: BorderRadius.circular(12.r),
                        child: Icon(
                          isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_border_rounded,
                          color: isSaved
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                          size: 26.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      InfoChip(
                        icon: Icons.location_city_outlined,
                        label: FormatUtils.extractDistrictAndCity(job.location),
                        color: Theme.of(context).colorScheme.secondary,
                        isHighlighted: true,
                      ),
                      InfoChip(
                        icon: Icons.monetization_on_outlined,
                        label: FormatUtils.formatSalary(job.salary ?? 0),
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      InfoChip(
                        icon: Icons.business_center_outlined,
                        label: job.workType,
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withValues(alpha: 0.8),
                      ),
                      InfoChip(
                        icon: Icons.layers_outlined,
                        label: job.experienceLevel,
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Nổi bật tag
        if (job.isFeatured == 1)
          Positioned(
            top: 12.h,
            left: 12.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                'Nổi bật',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}