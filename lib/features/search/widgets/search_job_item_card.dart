import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/config/widgets/custom_adaptive_button.dart';
import 'package:job_connect/config/widgets/custom_adaptive_tap_effect.dart';
import 'package:job_connect/config/widgets/info_chip.dart';
import 'package:job_connect/data/models/job_posting_model.dart';
import 'package:job_connect/features/job/screens/job_detail_screen.dart';

class SearchJobItemCard extends StatelessWidget {
  final JobPostingModel job;
  final bool isSaved;
  final String idUser;
  final Future<void> Function(String jobId, bool isSaved) onSaveJob;
  final Future<void> Function() onRefresh;

  const SearchJobItemCard({
    super.key,
    required this.job,
    required this.isSaved,
    required this.idUser,
    required this.onSaveJob,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: 18.h),
      elevation: 4,
      shadowColor: theme.shadowColor.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailScreen(
                idUser: idUser,
                jobPosting: job,
              ),
            ),
          );
          await onRefresh();
        },
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TODO: Header: Logo + Title + Bookmark
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.05),
                          blurRadius: 5,
                          offset: const Offset(1, 1),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 14.r,
                      backgroundImage: ImageUtils.getImageProvider(job.company!.logoCompany),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (job.isFeatured == 1)
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
                              ),
                            ),
                          ),
                        Text(
                          job.title ?? '',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          job.company!.companyName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  CustomAdaptiveTapEffect(
                    onPressed: () => onSaveJob(job.idJobPost, isSaved),
                    child: Icon(
                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: theme.colorScheme.primary,
                      size: 30.sp,
                    ),
                  )
                ],
              ),

              SizedBox(height: 18.h),

              // TODO: Info Chips
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  InfoChip(
                    icon: Icons.location_on_rounded,
                    label: FormatUtils.extractDistrictAndCity(job.location ?? ''),
                    color: theme.colorScheme.secondary,
                    isHighlighted: true,
                  ),
                  InfoChip(
                    icon: Icons.attach_money_rounded,
                    label: FormatUtils.formatSalary(job.salary ?? 0),
                    color: theme.colorScheme.tertiary,
                  ),
                  InfoChip(
                    icon: Icons.event_available_rounded,
                    label: FormatUtils.formattedDateTime(job.createdAt ?? DateTime.now()).toString(),
                    color: theme.colorScheme.tertiary.withValues(alpha:0.8),
                  ),
                  InfoChip(
                    icon: Icons.work_outline_rounded,
                    label: job.workType ?? '',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  InfoChip(
                    icon: Icons.layers_rounded,
                    label: job.experienceLevel ?? '',
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              // TODO: Actions
              Row(
                children: [
                  Expanded(
                    child: CustomAdaptiveButton(
                      onPressed: (){}, 
                      text: "Chi Tiết",
                      backgroundColor: Colors.white,
                      textColor: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      borderWidth: 1.w,
                      borderColor: theme.colorScheme.primary.withValues(alpha: 0.7),
                      preffixWidget: Icon(
                        Icons.info_outline_rounded,
                        size: 20.sp, color: theme.colorScheme.primary
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomAdaptiveButton(
                      onPressed: (){}, 
                      text: "Ứng tuyển",
                      backgroundColor: theme.colorScheme.primary,
                      textColor: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                      borderWidth: 1.w,
                      preffixWidget: Icon(
                        Icons.send_rounded,
                        size: 20.sp, color: Colors.white
                      ),
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

  // TODO: chọn icon phù hợp với loại job
  IconData _getIconForJob(String title) {
    title = title.toLowerCase();
    if (title.contains('flutter') ||
        title.contains('mobile') ||
        title.contains('android') ||
        title.contains('ios')) {
      return Icons.smartphone_rounded;
    }
    if (title.contains('backend') || title.contains('server') || title.contains('api')) return Icons.dns_rounded;
    if (title.contains('frontend') || title.contains('ui') || title.contains('ux') || title.contains('web')) return Icons.web_rounded;
    if (title.contains('data') || title.contains('ai') || title.contains('machine learning')) return Icons.analytics_rounded;
    if (title.contains('design') || title.contains('graphic')) return Icons.palette_rounded;
    if (title.contains('marketing') || title.contains('sale')) return Icons.campaign_rounded;
    if (title.contains('manager') || title.contains('lead')) return Icons.supervisor_account_rounded;
    return Icons.work_outline_rounded;
  }
}
