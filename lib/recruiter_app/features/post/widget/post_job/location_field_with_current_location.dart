import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:job_connect/config/widgets/custom_text_field_with_label.dart';
import 'package:job_connect/config/utils/snackbar_app.dart';
import 'package:job_connect/config/constant/app_colors.dart';

class LocationFieldWithCurrentLocation extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final Color? labelTextColor;
  final Color? prefixIconColor;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderRadius;
  final Function(double? latitude, double? longitude)? onLocationObtained;

  const LocationFieldWithCurrentLocation({
    super.key,
    required this.controller,
    required this.label,
    this.hintText = 'Nhập địa điểm...',
    this.labelTextColor,
    this.prefixIconColor,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
    this.onLocationObtained,
  });

  @override
  State<LocationFieldWithCurrentLocation> createState() => _LocationFieldWithCurrentLocationState();
}

class _LocationFieldWithCurrentLocationState extends State<LocationFieldWithCurrentLocation> {
  bool _isLoadingLocation = false;
  double? _latitude;
  double? _longitude;

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Kiểm tra dịch vụ vị trí
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          SnackbarApp.show(
            context,
            message: 'Vui lòng bật dịch vụ vị trí',
            backgroundColor: BackgroundColors.backgroundErrorPrimary,
          );
        }
        return;
      }

      // Kiểm tra quyền
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            SnackbarApp.show(
              context,
              message: 'Quyền truy cập vị trí bị từ chối',
              backgroundColor: BackgroundColors.backgroundErrorPrimary,
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          SnackbarApp.show(
            context,
            message: 'Quyền truy cập vị trí bị từ chối vĩnh viễn. Vui lòng cấp quyền trong cài đặt',
            backgroundColor: BackgroundColors.backgroundErrorPrimary,
          );
        }
        return;
      }

      // Lấy vị trí hiện tại
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      // Geocoding để lấy địa chỉ
      List<geocoding.Placemark> placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        // Tạo địa chỉ từ placemark
        final addressParts = <String>[];
        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }

        final address = addressParts.join(', ');
        widget.controller.text = address;

        // Gọi callback nếu có
        if (widget.onLocationObtained != null) {
          widget.onLocationObtained!(_latitude, _longitude);
        }

        if (mounted) {
          SnackbarApp.show(
            context,
            message: 'Đã lấy vị trí hiện tại thành công',
            backgroundColor: BackgroundColors.backgroundSuccessPrimary,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarApp.show(
          context,
          message: 'Lỗi khi lấy vị trí: ${e.toString()}',
          backgroundColor: BackgroundColors.backgroundErrorPrimary,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const recruiterPrimary = Color(0xFF1A237E);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextFieldWithLabel(
                labelTextColor: widget.labelTextColor ?? recruiterPrimary,
                prefixIconColor: widget.prefixIconColor ?? recruiterPrimary,
                fillColor: widget.fillColor ?? recruiterPrimary.withValues(alpha: 0.05),
                borderColor: widget.borderColor ?? recruiterPrimary.withValues(alpha: 0.3),
                borderRadius: widget.borderRadius ?? 14.r,
                controller: widget.controller,
                label: widget.label,
                hintText: widget.hintText,
                icon: Icons.location_on_outlined,
                iconSize: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A237E), Color(0xFF283593)],
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 14.r),
                boxShadow: [
                  BoxShadow(
                    color: recruiterPrimary.withValues(alpha: 0.3),
                    blurRadius: 8.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isLoadingLocation ? null : _getCurrentLocation,
                  borderRadius: BorderRadius.circular(widget.borderRadius ?? 14.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: _isLoadingLocation
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            Icons.my_location_rounded,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

