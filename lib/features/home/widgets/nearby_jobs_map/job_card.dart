import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/job/screens/job_detail_screen.dart';
import 'package:job_connect/features/home/view_model/job_saved_view_model.dart';
import 'package:job_connect/features/home/model/job_saved_model.dart';
import 'package:provider/provider.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
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
          borderRadius: BorderRadius.circular(18.r),
          splashColor: theme.primaryColor.withValues(alpha: 0.12),
          highlightColor: theme.primaryColor.withValues(alpha: 0.06),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LOGO
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: theme.dividerColor.withValues(alpha: 0.15),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.r),
                    child: (jobPosting.company!.logoCompany != null &&
                            jobPosting.company!.logoCompany!.isNotEmpty)
                        ? Image.network(
                            jobPosting.company!.logoCompany!,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.primaryColor.withOpacity(0.2),
                                    theme.primaryColor.withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  companyInitial,
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontSize: 24.sp,
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.primaryColor.withOpacity(0.2),
                                  theme.primaryColor.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                companyInitial,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontSize: 24.sp,
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),

                SizedBox(width: 12.w),

                // TEXT CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TITLE
                      Text(
                        jobPosting.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 4.h),

                      // COMPANY NAME
                      Text(
                        jobPosting.company!.companyName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12.sp,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 8.h),

                      // SALARY BUTTON và DISTANCE
                      Row(
                        children: [
                          // Salary button màu xanh lá
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            child: Text(
                              salaryText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          // Distance
                          if (jobPosting.distanceKm != null)
                            Text(
                              '${jobPosting.distanceKm!.toStringAsFixed(1)} km',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 13.sp,
                                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // HEART ICON
                SizedBox(width: 4.w),
                Consumer<JobSavedViewModel>(
                  builder: (context, jobSavedVM, child) {
                    final isSaved = jobSavedVM.savedJobs.any(
                      (saved) => saved.idJobPost == jobPosting.idJobPost && saved.idUser == idUser,
                    );
                    
                    return GestureDetector(
                      onTap: () async {
                        if (isSaved) {
                          await jobSavedVM.deleteSavedJob(jobPosting.idJobPost, idUser);
                        } else {
                          await jobSavedVM.saveJob(
                            JobSavedModel(
                              idJobPost: jobPosting.idJobPost,
                              idUser: idUser,
                            ),
                          );
                        }
                        await jobSavedVM.fetchSavedJobsByUser(idUser);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.all(2.w),
                        child: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          color: isSaved ? Colors.red : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                          size: 20.sp,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
