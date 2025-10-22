import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/features/home/model/podcast_model.dart';

class PodcastCard extends StatelessWidget {
  final PodcastModel podcast;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onPlayPressed;
  final bool isFavorite;

  const PodcastCard({
    super.key,
    required this.podcast,
    this.onFavoritePressed,
    this.onPlayPressed, 
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              ),
              child: Center(
                child: Icon(
                  Icons.podcasts_rounded,
                  color: theme.colorScheme.primary,
                  size: 40.sp,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    FormatUtils.formattedDateTime(podcast.createdAt),
                    style: textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    podcast.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Người dẫn: ${podcast.host ?? 'Không rõ'}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Thời lượng: ${FormatUtils.formatDuration(podcast.duration)}',
                        style: textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12.sp,
                        ),
                      ),
                      GestureDetector(
                        onTap: onPlayPressed,
                        child: Icon(
                          Icons.play_circle_fill_rounded,
                          color: theme.colorScheme.secondary,
                          size: 36.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Nút yêu thích
            Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: IconButton(
                icon: Icon(
                  isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                  color: theme.colorScheme.primary,
                  size: 24.sp,
                ),
                onPressed: onFavoritePressed,
                tooltip: 'Yêu thích',
              ),
            ),
          ],
        ),
      ),
    );
  }
}