import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/config/widgets/info_chip.dart';
import 'package:job_connect/config/utils/format.dart';

class FeaturedSeasonalJobsList extends StatelessWidget {
  final List<JobPostingModel> jobs;
  final int maxItems;
  final String idUser;

  const FeaturedSeasonalJobsList({
    super.key,
    required this.jobs,
    this.maxItems = 10, required this.idUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (jobs.isEmpty) {
      return Center(
        child: Text(
          'Chưa có việc làm thời vụ!',
          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
        ),
      );
    }

    final displayedJobs = jobs.length > maxItems ? jobs.sublist(0, maxItems) : jobs;

    return SizedBox(
      height: 220.h,
      child: AnimationLimiter(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: displayedJobs.length,
          padding: EdgeInsets.zero,
          itemBuilder: (context, index) {
            final job = displayedJobs[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: GestureDetector(
                    onTap: () {
                      context.push(
                        '/job/detail',
                        extra: {
                          "idUser": idUser,
                          "jobPosting": job,
                        },
                      );
                    },
                    child: Stack(
                      children: [
                        Card(
                          elevation: 3,
                          shadowColor: theme.shadowColor.withValues(alpha:0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                          margin: EdgeInsets.only(right: 16.w, bottom: 8.h),
                          child: Container(
                            width: 280.w,
                            padding: EdgeInsets.all(16.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Logo
                                    Container(
                                      width: 50.w,
                                      height: 50.w,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12.r),
                                        color: theme.colorScheme.primaryContainer.withValues(alpha:0.2),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12.r),
                                        child: job.company?.logoCompany != null &&
                                                job.company!.logoCompany!.isNotEmpty
                                            ? Image.network(
                                                job.company!.logoCompany!,
                                                fit: BoxFit.contain,
                                                errorBuilder: (_, __, ___) =>
                                                    Center(child: Icon(Icons.business)),
                                              )
                                            : Center(
                                                child: Text(
                                                  job.company?.companyName
                                                          .substring(0, 1)
                                                          .toUpperCase() ??
                                                      '?',
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: theme.colorScheme.primary,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    // Title & company
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            job.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 4.h),
                                          if (job.company != null)
                                            Text(
                                              job.company!.companyName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: theme.textTheme.bodyMedium!.color!
                                                    .withValues(alpha:0.7),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: [
                                    InfoChip(
                                      icon: Icons.location_on_outlined,
                                      label: FormatUtils.extractDistrictAndCity(job.location),
                                      color: theme.colorScheme.secondary,
                                      isHighlighted: true,
                                      maxLines: 1,
                                    ),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          if (job.salary != null)
                                            InfoChip(
                                              icon: Icons.monetization_on_outlined,
                                              label: FormatUtils.formatSalary(job.salary!),
                                              color: theme.colorScheme.tertiary,
                                            ),
                                          if (job.salary != null && job.workType.isNotEmpty)
                                            SizedBox(width: 8.w),
                                          if (job.workType.isNotEmpty)
                                            InfoChip(
                                              icon: Icons.business_center_outlined,
                                              label: job.workType,
                                              color: theme.colorScheme.tertiary.withValues(alpha:0.8),
                                            ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Featured tag
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
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
