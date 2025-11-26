import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/job/screens/job_detail_screen.dart';

class JobMatchDetailScreen extends StatelessWidget {
  final JobPostingModel job;
  final String idUser;

  const JobMatchDetailScreen({
    super.key,
    required this.job,
    required this.idUser,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppbarTitleLarge(
        title: 'Chi tiết phù hợp',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //   Job Header
            _buildJobHeader(theme),
            SizedBox(height: 24.h),

            //   Match Score Card
            _buildMatchScoreCard(theme),
            SizedBox(height: 24.h),

            //   Match Analysis Section
            if (job.matchReason != null && job.matchReason!.isNotEmpty) ...[
              Text(
                'Phân tích phù hợp',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              _buildMatchAnalysisCard(theme),
              SizedBox(height: 24.h),
            ],

            //   Matched Skills Section
            if (job.matchedSkills != null && job.matchedSkills!.isNotEmpty) ...[
              Text(
                'Kỹ năng phù hợp',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              _buildMatchedSkillsSection(theme),
              SizedBox(height: 24.h),
            ],
            SizedBox(height: 32.h),

            //   Action Buttons
            _buildActionButtons(context, theme),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  //   Job Header Widget
  Widget _buildJobHeader(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.business,
                  size: 18.sp,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    job.company?.companyName ?? 'N/A',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            if (job.location.isNotEmpty)
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 18.sp,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      job.location,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  //   Match Score Card
  Widget _buildMatchScoreCard(ThemeData theme) {
    // API trả về matchScore dạng 0.0-1.0, cần nhân với 100 để chuyển thành phần trăm
    final matchScore = ((job.matchScore ?? 0.0) * 100).clamp(0.0, 100.0);
    final scoreColor = _getMatchColor(matchScore);

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scoreColor.withValues(alpha: 0.1),
            scoreColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: scoreColor.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.analytics,
              color: scoreColor,
              size: 32.sp,
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng điểm phù hợp',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '${matchScore.toStringAsFixed(1)}%',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //   Match Analysis Card
  Widget _buildMatchAnalysisCard(ThemeData theme) {
    // API trả về matchScore dạng 0.0-1.0, cần nhân với 100 để chuyển thành phần trăm
    final matchScore = ((job.matchScore ?? 0.0) * 100).clamp(0.0, 100.0);
    final scoreColor = _getMatchColor(matchScore);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: scoreColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: scoreColor.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.insights_rounded,
                size: 20.sp,
                color: scoreColor,
              ),
              SizedBox(width: 8.w),
              Text(
                'Vì sao phù hợp?',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            job.matchReason ?? 'Không có thông tin phân tích',
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  //   Matched Skills Section
  Widget _buildMatchedSkillsSection(ThemeData theme) {
    // API trả về matchScore dạng 0.0-1.0, cần nhân với 100 để chuyển thành phần trăm
    final matchScore = ((job.matchScore ?? 0.0) * 100).clamp(0.0, 100.0);
    final scoreColor = _getMatchColor(matchScore);
    final matchedSkills = job.matchedSkills ?? [];

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: matchedSkills.map((skill) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: scoreColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: scoreColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 16.sp,
                color: scoreColor,
              ),
              SizedBox(width: 6.w),
              Text(
                skill,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scoreColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }


  //   Action Buttons
  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => JobDetailScreen(
                    idUser: idUser,
                    jobPosting: job,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Xem chi tiết công việc'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Quay lại'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  //   Match Color Helper
  Color _getMatchColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }
}