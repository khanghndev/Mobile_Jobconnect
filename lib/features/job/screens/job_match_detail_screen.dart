import 'package:flutter/material.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/features/job/screens/job_detail_screen.dart';
import 'package:job_connect/features/job/screens/job_matching_screen.dart';

class JobMatchDetailScreen extends StatelessWidget {
  final JobMatch jobMatch;
  final String idUser;

  const JobMatchDetailScreen({
    super.key,
    required this.jobMatch,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //   Job Header
            _buildJobHeader(theme),
            const SizedBox(height: 24),

            //   Match Score Card
            _buildMatchScoreCard(theme),
            const SizedBox(height: 24),

            //   Score Details Title
            Text(
              'Chi tiết đánh giá',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            //   Score Items
            _buildScoreItem(
              theme: theme,
              title: 'Kỹ năng',
              score: jobMatch.skillScore,
              icon: Icons.code,
              description: 'Đánh giá dựa trên kỹ năng của bạn so với yêu cầu công việc',
            ),
            _buildScoreItem(
              theme: theme,
              title: 'Kinh nghiệm',
              score: jobMatch.experienceScore,
              icon: Icons.work,
              description: 'Đánh giá dựa trên số năm kinh nghiệm của bạn',
            ),
            _buildScoreItem(
              theme: theme,
              title: 'Học vấn',
              score: jobMatch.educationScore,
              icon: Icons.school,
              description: 'Đánh giá dựa trên trình độ học vấn của bạn',
            ),
            _buildScoreItem(
              theme: theme,
              title: 'Vị trí',
              score: jobMatch.positionScore,
              icon: Icons.business_center,
              description: 'Đánh giá dựa trên vị trí công việc hiện tại của bạn',
            ),
            const SizedBox(height: 32),

            //   Action Buttons
            _buildActionButtons(context, theme),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  //   Job Header Widget
  Widget _buildJobHeader(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              jobMatch.job.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.business,
                  size: 18,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    jobMatch.job.company?.companyName ?? 'N/A',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (jobMatch.job.location.isNotEmpty)
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      jobMatch.job.location,
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
    final scoreColor = _getMatchColor(jobMatch.matchPercentage);

    return Container(
      padding: const EdgeInsets.all(20),
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
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.analytics,
              color: scoreColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
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
                const SizedBox(height: 8),
                Text(
                  '${jobMatch.matchPercentage.toStringAsFixed(1)}%',
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

  //   Score Item Widget
  Widget _buildScoreItem({
    required ThemeData theme,
    required String title,
    required double score,
    required IconData icon,
    required String description,
  }) {
    final percentage = (score / 25) * 100;
    final scoreColor = _getMatchColor(percentage);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${percentage.toStringAsFixed(1)}%',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: scoreColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: theme.colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
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
                    jobPosting: jobMatch.job,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Xem chi tiết công việc'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Quay lại'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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