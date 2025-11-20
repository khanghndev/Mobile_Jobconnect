import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DotIndicator extends StatelessWidget {
  final int currentIndex;
  final int total;
  final int maxDots;

  const DotIndicator({
    super.key,
    required this.currentIndex,
    required this.total,
    this.maxDots = 7,
  });

  @override
  Widget build(BuildContext context) {
    if (total <= 0) return const SizedBox.shrink();

    if (total <= maxDots) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          total,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            width: currentIndex == index ? 12.w : 8.w,
            height: currentIndex == index ? 12.w : 8.w,
            decoration: BoxDecoration(
              color: currentIndex == index
                  ? Colors.black
                  : Colors.black.withValues( alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }

    int start = (currentIndex - 3).clamp(0, total - maxDots);
    int end = (start + maxDots).clamp(0, total);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        end - start,
        (i) {
          final index = start + i;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            width: currentIndex == index ? 12.w : 8.w,
            height: currentIndex == index ? 12.w : 8.w,
            decoration: BoxDecoration(
              color: currentIndex == index
                  ? Colors.black
                  : Colors.black.withValues( alpha: 0.4),
              shape: BoxShape.circle,
            ),
          );
        },
      ),
    );
  }
}
