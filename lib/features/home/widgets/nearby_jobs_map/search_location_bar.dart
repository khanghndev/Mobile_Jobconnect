import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchLocationBar extends StatelessWidget {
  final TextEditingController controller;
  final GoogleMapController? mapController;
  final LatLng? currentPosition;
  final Function(String) onSubmitted;
  final VoidCallback? onFilterPressed;

  const SearchLocationBar({
    super.key,
    required this.controller,
    required this.mapController,
    required this.currentPosition,
    required this.onSubmitted,
    this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        top: 50.h,
        left: 15.w,
        right: 15.w,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FloatingActionButton.small(
            heroTag: "backButtonMap",
            onPressed: () => Navigator.pop(context, true),
            backgroundColor: theme.cardColor.withValues(alpha: 0.9),
            elevation: 3,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: theme.primaryColor,
              size: 18.sp,
            ),
          ),

          SizedBox(width: 10.w),

          Expanded(
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(30.r),
              shadowColor: theme.shadowColor.withValues(alpha: 0.3),
              child: TextField(
                controller: controller,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm địa điểm, thành phố...',
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    color: theme.hintColor.withValues(alpha: 0.8),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.primaryColor,
                    size: 22.sp,
                  ),
                  suffixIcon: controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: theme.iconTheme.color?.withValues(alpha: 0.7),
                            size: 20.sp,
                          ),
                          onPressed: () {
                            controller.clear();
                            FocusScope.of(context).unfocus();

                            if (currentPosition != null && mapController != null) {
                              mapController!.animateCamera(
                                CameraUpdate.newLatLngZoom(currentPosition!, 13),
                              );
                            }
                          },
                          splashRadius: 20.r,
                        )
                      : null,
                  filled: true,
                  fillColor: theme.cardColor,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14.h,
                    horizontal: 20.w,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.r),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.r),
                    borderSide: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.r),
                    borderSide: BorderSide(
                      color: theme.primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
                onSubmitted: onSubmitted,
              ),
            ),
          ),
          
          if (onFilterPressed != null) ...[
            SizedBox(width: 10.w),
            FloatingActionButton.small(
              heroTag: "filterButtonMap",
              onPressed: onFilterPressed,
              backgroundColor: theme.cardColor.withValues(alpha: 0.9),
              elevation: 3,
              child: Icon(
                Icons.tune_rounded,
                color: theme.primaryColor,
                size: 20.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }
}