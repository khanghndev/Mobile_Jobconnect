import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:job_connect/features/home/model/podcast_model.dart';
import 'package:job_connect/features/home/widgets/podcast/featured_podcast_card.dart';

class FeaturedPodcastsList extends StatelessWidget {
  final List<PodcastModel> podcasts;
  final void Function(PodcastModel podcast)? onPodcastTap;
  final int maxItems;

  const FeaturedPodcastsList({
    super.key,
    required this.podcasts,
    this.onPodcastTap,
    this.maxItems = 2,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (podcasts.isEmpty) {
      return Center(
        child: Text(
          'Podcast sắp ra mắt!',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final displayedPodcasts = podcasts.length > maxItems ? podcasts.sublist(0, maxItems) : podcasts;

    return AnimationLimiter(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayedPodcasts.length,
        itemBuilder: (context, index) {
          final podcast = displayedPodcasts[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 70.0,
              child: FadeInAnimation(
                child: FeaturedPodcastCard(
                  podcast: podcast,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
