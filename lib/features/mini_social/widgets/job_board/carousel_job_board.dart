import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'job_board_card.dart';

typedef OnPageChanged = void Function(int index);
typedef OnPageScroll = void Function(double page);

class CarouselJobBoard extends StatefulWidget {
  final List<String> posters;
  final OnPageChanged? onPageChanged;
  final OnPageScroll? onPageScroll;

  const CarouselJobBoard({
    super.key,
    required this.posters,
    this.onPageChanged,
    this.onPageScroll,
  });

  @override
  State<CarouselJobBoard> createState() => _CarouselJobBoardState();
}

class _CarouselJobBoardState extends State<CarouselJobBoard> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    final initialPage =
        (widget.posters.length ~/ 2).clamp(0, widget.posters.length - 1);

    _pageController = PageController(
      viewportFraction: 0.7,
      initialPage: initialPage,
    );

    _pageController.addListener(() {
      if (!_pageController.hasClients) return;

      widget.onPageScroll?.call(_pageController.page ?? 0.0);

      final page = _pageController.page?.round() ?? 0;
      if (page != _currentIndex) {
        _currentIndex = page;
        widget.onPageChanged?.call(page);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360.h,
      width: double.infinity,
      child: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.posters.length,
        itemBuilder: (context, index) {
          final poster = widget.posters[index];
          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double currentPage = 0;
              if (_pageController.hasClients) {
                currentPage = _pageController.page ??
                    _pageController.initialPage.toDouble();
              }

              double diff = (index - currentPage);
              double absDiff = diff.abs();

              double scale = (1 - absDiff * 0.2).clamp(0.8, 1.0);
              double angle = diff * (math.pi / 10);
              angle = angle.clamp(-math.pi / 6, math.pi / 6);
              double yOffset = 40.h * (1 - scale);

              return Transform.translate(
                offset: Offset(0, yOffset),
                child: Transform(
                  alignment: diff > 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(angle),
                  child: Transform.scale(
                    scale: scale,
                    child: Opacity(
                      opacity: (1 - absDiff * 0.5).clamp(0.5, 1.0),
                      child: JobBoardCard(
                        imagePath: poster,
                        gradientColors: [Colors.black.withValues(alpha:0.2), Colors.transparent],
                        shadowOpacity: 0.3,
                        borderColor: Colors.blueAccent,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
