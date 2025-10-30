import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:job_connect/config/widgets/background_empty_state.dart';
import 'package:job_connect/config/widgets/background_error_state.dart';
import 'package:job_connect/config/widgets/custom_appbar_title_large.dart';
import 'package:job_connect/config/widgets/custom_search_bar_main.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';

import 'package:job_connect/config/utils/string_utils.dart';
import 'package:job_connect/features/home/view_model/podcast_view_model.dart';
import 'package:job_connect/features/home/widgets/podcast/podcast_card.dart';
import 'package:job_connect/features/home/widgets/podcast/podcast_shimmer.dart';

class PodcastScreen extends StatefulWidget {
  const PodcastScreen({super.key});

  @override
  State<PodcastScreen> createState() => _PodcastScreenState();
}

class _PodcastScreenState extends State<PodcastScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    _listAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    final vm = context.read<PodcastViewModel>();
    await Future.wait([
      vm.getPodcasts(),
      vm.loadFavorites(),
    ]);
    if (mounted) _listAnimationController.forward();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      final keyword =
          StringUtils.removeDiacritics(_searchController.text.trim());
      context.read<PodcastViewModel>().filterPodcasts(keyword);
      _listAnimationController.forward(from: 0);
    });
  }

  Future<void> _onRefresh() async {
    _listAnimationController.reset();
    _searchController.clear();
    await context.read<PodcastViewModel>().refreshPodcasts();
    if (mounted) _listAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppbarTitleLarge(title: "Khám phá Podcast"),
      body: UnfocusWidget(
        child: Consumer<PodcastViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const Center(child: PodcastShimmer());
            }

            if (vm.errorMessage != null && vm.errorMessage!.isNotEmpty) {
              return BackgroundErrorState(
                title: "Hệ thống đang gặp sự cố\nVui lòng thử lại sau.",
                onRetry: _onRefresh,
              );
            }

            final podcasts = vm.filteredPodcasts;
            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: theme.primaryColor,
              backgroundColor: theme.cardColor,
              child: Column(
                children: [
                  // TODO: Thanh tìm kiếm podcast
                  CustomSearchBarMain(
                    controller: _searchController,
                    onChanged: (_) => _onSearchChanged(),
                    onClear: _searchController.clear,
                    hinText: "Tìm kiếm podcast...",
                  ),
                  Expanded(
                    child: podcasts.isEmpty
                        ? BackgroundEmptyState(
                            isSearching: _searchController.text.isNotEmpty,
                            onRefresh: _onRefresh,
                            title: "Podcast",
                            iconData: Icons.headphones_rounded,
                          )
                        : AnimationLimiter(
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics(),
                              ),
                              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                              itemCount: podcasts.length,
                              itemBuilder: (context, index) {
                                final podcast = podcasts[index];
                                final isFavorite = vm.isFavorite(podcast);
                                return AnimationConfiguration.staggeredList(
                                  position: index,
                                  duration: const Duration(milliseconds: 425),
                                  child: SlideAnimation(
                                    verticalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: PodcastCard(
                                        podcast: podcast,
                                        isFavorite: isFavorite,
                                        onFavoritePressed: () =>
                                            vm.toggleFavorite(podcast),
                                        onPlayPressed: () {
                                          // TODO: Phát nhạc
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
