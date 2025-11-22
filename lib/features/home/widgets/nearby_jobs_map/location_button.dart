import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';

class LocationButton extends StatelessWidget {
  final bool showJobList;
  final List<JobPostingModel> jobsInView; 
  final LatLng? currentPositionLatLng;
  final GoogleMapController? mapController;
  final Future<void> Function() loadInitialData;

  const LocationButton({
    super.key,
    required this.showJobList,
    required this.jobsInView,
    required this.currentPositionLatLng,
    required this.mapController,
    required this.loadInitialData,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Dùng ScreenUtil để scale các kích thước
    final double bottomPosition = showJobList
        ? (MediaQuery.of(context).size.height *
                (jobsInView.isEmpty ? 0.18 : 0.5)) +
            25.h
        : 30.h;

    return Positioned(
      bottom: bottomPosition,
      right: 15.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: "LocationButtonMap",
            backgroundColor: theme.cardColor,
            elevation: 4,
            onPressed: () async {
              if (currentPositionLatLng != null && mapController != null) {
                mapController!.animateCamera(
                  CameraUpdate.newLatLngZoom(
                    currentPositionLatLng!,
                    14.5,
                  ),
                );
              } else {
                await loadInitialData();
              }
            },
            child: Icon(
              Icons.my_location_rounded,
              color: theme.primaryColor,
              size: 26.sp, // scale size icon
            ),
          ),
        ],
      ),
    );
  }
}
