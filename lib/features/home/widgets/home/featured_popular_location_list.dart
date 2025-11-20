import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:job_connect/config/widgets/info_chip.dart';

class FeaturedPopularLocationList extends StatelessWidget {
  final List<String> locations;
  final void Function(String location)? onLocationTap;
  final int maxItems;

  const FeaturedPopularLocationList({
    super.key,
    required this.locations,
    this.onLocationTap,
    this.maxItems = 10,
  });

  /// Tách location thành ward/district/city
  Map<String, String> splitLocation(String location) {
    final parts = location.split(',').map((e) => e.trim()).toList();
    final Map<String, String> result = {};
    if (parts.isNotEmpty) result['city'] = parts.last;
    if (parts.length > 1) result['district'] = parts[parts.length - 2];
    if (parts.length > 2) result['ward'] = parts.sublist(0, parts.length - 2).join(', ');
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (locations.isEmpty) {
      return Center(
        child: Text(
          'Chưa có địa điểm nổi bật!',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final displayedLocations =
        locations.length > maxItems ? locations.sublist(0, maxItems) : locations;

    return SizedBox(
      height: 180.h,
      child: AnimationLimiter(
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: displayedLocations.length,
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final location = displayedLocations[index];
            final parts = splitLocation(location);

            final ward = parts['ward'];
            final district = parts['district'];
            final city = parts['city'];

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 400),
              child: SlideAnimation(
                horizontalOffset: 50.0,
                child: FadeInAnimation(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20.r),
                      onTap: () => onLocationTap?.call(location),
                      child: Container(
                        width: 200.w,
                        margin: EdgeInsets.only(right: 12.w),
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.15),
                              theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(2, 4),
                            ),
                          ],
                          border: Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            width: 1.w,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Icon lớn
                            Icon(Icons.location_city_rounded,
                                color: theme.colorScheme.primary, size: 40.sp),
                            SizedBox(height: 8.h),
                            // City
                            if (city != null)
                              Text(
                                city,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  fontSize: 16.sp,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            SizedBox(height: 6.h),
                            // Ward chip
                            if (ward != null)
                              InfoChip(
                                label: ward,
                                color: theme.colorScheme.primary,
                                isHighlighted: true,
                                maxLines: 1,
                              ),
                            SizedBox(height: 4.h),
                            // District chip
                            if (district != null)
                              InfoChip(
                                label: district,
                                color: theme.colorScheme.secondary,
                                isHighlighted: false,
                                maxLines: 1,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
