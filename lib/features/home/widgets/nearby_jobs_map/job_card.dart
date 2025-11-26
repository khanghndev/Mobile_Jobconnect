import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/job/screens/job_detail_screen.dart';

class JobCard extends StatelessWidget {
  final JobPostingModel jobPosting;
  final String idUser;

  const JobCard({super.key, required this.jobPosting, required this.idUser});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final companyInitial = jobPosting.company!.companyName.isNotEmpty
        ? jobPosting.company!.companyName[0].toUpperCase()
        : "C";

    final salaryText = (jobPosting.salary != null && jobPosting.salary! > 0)
        ? FormatUtils.formatSalary(jobPosting.salary!)
        : "Thỏa thuận";

    return Card(
      elevation: 2.5,
      margin: EdgeInsets.only(bottom: 4.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      color: theme.cardColor,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailScreen(
              idUser: idUser,
              jobPosting: jobPosting,
            ),
          ),
        ),
        borderRadius: BorderRadius.circular(14.r),
        splashColor: theme.primaryColor.withValues(alpha: 0.1),
        highlightColor: theme.primaryColor.withValues(alpha: 0.05),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // LOGO
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color:
                      theme.colorScheme.primaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11.r),
                  child: (jobPosting.company!.logoCompany != null &&
                          jobPosting.company!.logoCompany!.isNotEmpty)
                      ? Image.network(
                          jobPosting.company!.logoCompany!,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => Center(
                            child: Text(
                              companyInitial,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontSize: 20.sp,
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Text(
                            companyInitial,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontSize: 20.sp,
                              color: theme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ),

              SizedBox(width: 14.w),

              // TEXT CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE
                    Text(
                      jobPosting.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 5.h),

                    // COMPANY NAME
                    Text(
                      jobPosting.company!.companyName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 13.sp,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 8.h),

                    // INFO CHIPS
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: [
                        _buildInfoChip(
                          context,
                          icon: Icons.attach_money_rounded,
                          text: salaryText,
                          color: theme.colorScheme.secondary,
                        ),
                        _buildInfoChip(
                          context,
                          icon: Icons.location_pin,
                          text: FormatUtils.extractDistrictAndCity(
                            jobPosting.location,
                          ),
                          color: theme.colorScheme.tertiary,
                        ),
                        if (jobPosting.distanceKm != null)
                          _buildInfoChip(
                            context,
                            icon: Icons.navigation_rounded,
                            text: '${jobPosting.distanceKm!.toStringAsFixed(1)} km',
                            color: theme.primaryColor,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // CHIP WIDGET
  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 15.sp, // ICON SIZE via screenutil
          ),
          SizedBox(width: 5.w),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
