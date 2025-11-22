import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as flutter_geocoding;
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/config/theme/app_google_theme.dart';
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/features/home/model_ui/city_model_ui.dart';
import 'package:job_connect/features/home/widgets/nearby_jobs_map/job_list_draggable_sheet.dart';
import 'package:job_connect/features/home/widgets/nearby_jobs_map/location_button.dart';
import 'package:job_connect/features/home/widgets/nearby_jobs_map/search_location_bar.dart';
import 'package:job_connect/features/job/model/job_posting_model.dart';
import 'package:job_connect/features/job/screens/job_detail_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; 
import 'dart:ui';
class NearbyJobsMapScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;

  const NearbyJobsMapScreen({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
  });

  @override
  State<NearbyJobsMapScreen> createState() => _NearbyJobsMapScreenState();
}

class _NearbyJobsMapScreenState extends State<NearbyJobsMapScreen> with TickerProviderStateMixin {
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  bool _showJobList = false;
  bool _isLoading = true;
  String _errorMessage = '';
  LatLng? _currentPositionLatLng;
  CityModelUi? _currentCity;
  final ApiService _apiService = ApiService( );
  List<JobPostingModel> _allFetchedJobs = [];
  List<JobPostingModel> _jobsInView = [];
  final TextEditingController _searchLocationController = TextEditingController();
  Timer? _debounce;
  Timer? _cameraIdleDebounce;
  late AnimationController _sheetAnimationController;
  late Animation<double> _sheetHeaderFadeAnimation;
  BitmapDescriptor? _jobMarkerIcon;
  BitmapDescriptor? _currentLocationMarkerIcon;

  @override
  void initState() {
    super.initState();
    _sheetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _sheetHeaderFadeAnimation = CurvedAnimation(
      parent: _sheetAnimationController,
      curve: Curves.easeInOut,
    );

    _loadCustomMarkers(); // Tải custom marker icons
    _loadInitialData();
  }

  @override
  void dispose() {
    mapController?.dispose();
    _searchLocationController.dispose();
    _debounce?.cancel();
    _sheetAnimationController.dispose();
    _cameraIdleDebounce?.cancel();
    super.dispose();
  }

  Future<void> _determinePositionAndCity() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Dịch vụ vị trí bị tắt.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Quyền truy cập vị trí bị từ chối.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Quyền truy cập vị trí bị từ chối vĩnh viễn.');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPositionLatLng = LatLng(position.latitude, position.longitude);

      // Sử dụng alias cho geocoding package
      List<flutter_geocoding.Placemark> placemarks = await flutter_geocoding
          .placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        flutter_geocoding.Placemark place = placemarks[0];
        _currentCity = CityModelUi(
          isoCountryCode: place.isoCountryCode ?? '',
          country: place.country ?? '',
          postalCode: place.postalCode ?? '',
          administrativeArea: place.administrativeArea ?? '',
          subAdministrativeArea: place.subAdministrativeArea ?? '',
          locality: place.locality ?? '',
          subLocality: place.subLocality ?? '',
          thoroughfare: place.thoroughfare ?? '',
          subThoroughfare: place.subThoroughfare ?? '',
        );
        print(
          "DEBUG: Current City determined: ${_currentCity?.administrativeArea}, Locality: ${_currentCity?.locality}",
        );
      } else {
        _currentCity = null;
        // Không throw exception ở đây để app vẫn có thể fetch all jobs nếu không xác định được thành phố
        print("Không thể xác định địa chỉ từ tọa độ.");
      }
    } catch (e) {
      _currentCity = null;
      // Không throw Exception ở đây, chỉ ghi log và cho phép app tiếp tục
      print('Lỗi xác định vị trí: ${e.toString()}');
      // throw Exception('Lỗi xác định vị trí: ${e.toString()}'); // Bỏ dòng này nếu muốn app chạy tiếp
    }
  }

  Future<void> _fetchJobs() async {
    try {
      print(_currentCity?.administrativeArea);
      // Clear _allFetchedJobs trước khi fetch để tránh trùng lặp nếu gọi lại
      _allFetchedJobs.clear();
      // final responseData = await _apiService.get(
      //   '${ApiConstants.jobPostingSearchEndpoint}?locationQuery=${_normalizeCityName(_currentCity!.administrativeArea)}',
      // );
      final responseData = await _apiService.get(
        endpoint:  ApiConstants.jobPostingEndpoint,
      );
      _allFetchedJobs.addAll(
        (responseData as List)
            .map((job) => JobPostingModel.fromJson(job as Map<String, dynamic>))
            .toList(),
      );
    } catch (e) {
      debugPrint('Error fetching jobs: $e');
      _allFetchedJobs = [];
    }
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true; // Vẫn giữ loading tổng thể
      _errorMessage = '';
      _allFetchedJobs.clear(); // Clear danh sách jobs đã fetch
      _markers
          .clear(); // Không clear ở đây nếu muốn giữ lại marker cũ khi refresh
    });

    try {
      // Bước 1: Xác định vị trí (quan trọng cho map ban đầu)
      await _determinePositionAndCity();
      if (!mounted) return;

      // Cập nhật map controller nếu đã có vị trí
      if (mapController != null && _currentPositionLatLng != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(_currentPositionLatLng!, 14.0),
        );
      }
      // Có thể thêm marker vị trí hiện tại ngay ở đây
      if (_currentPositionLatLng != null && _currentCity != null) {
        final currentPosMarker = Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPositionLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(
            title: 'Vị trí của bạn',
            snippet:
                _currentCity!.locality.isNotEmpty
                    ? '${_currentCity!.locality}, ${_currentCity!.administrativeArea}'
                    : _currentCity!.administrativeArea,
          ),
        );
        setState(() {
          _markers.add(currentPosMarker); // Thêm marker vị trí hiện tại sớm
        });
      }

      // Bước 2: Tải jobs (vẫn chạy song song được nếu muốn, nhưng tách ra để dễ quản lý state)
      await _fetchJobs();
      if (!mounted) return;

      _updateJobsInView(); // Lọc jobs theo map bounds ban đầu

      // Bước 3: Thêm markers (quá trình này có thể chậm)
      // setState ở đây để UI cập nhật danh sách jobs trước khi markers được thêm
      setState(() {
        _isLoading =
            false; // Tắt loading tổng thể, list jobs đã có thể hiển thị
      });
      _addMarkersToMap(); // Hàm này sẽ tự setState khi có markers mới
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false; // Quan trọng
        });
      }
    }
  }

  Future<BitmapDescriptor> _createCustomMarkerBitmap(
    String titleInitial,
    Color bgColor,
    Color textColor,
  ) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = bgColor;
    const double size = 100; // Kích thước của marker
    final Rect rect = Rect.fromLTWH(0.0, 0.0, size, size);
    final RRect rRect = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(15),
    ); // Bo góc
    canvas.drawRRect(rRect, paint);

    // Vẽ "đuôi" cho marker
    final Path path = Path();
    path.moveTo(size / 2 - 15, size - 5); // Giảm y để đuôi ngắn hơn
    path.lineTo(size / 2, size + 15); // Tăng y để đuôi dài hơn
    path.lineTo(size / 2 + 15, size - 5);
    path.close();
    canvas.drawPath(path, paint);

    TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    painter.text = TextSpan(
      text: titleInitial.isNotEmpty ? titleInitial : 'J',
      style: TextStyle(
        fontSize: size / 2.5,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
    );
    painter.layout();
    painter.paint(
      canvas,
      Offset((size - painter.width) / 2, (size - painter.height) / 2 - 5),
    ); // Dịch lên một chút

    final img = await pictureRecorder.endRecording().toImage(
      size.toInt(),
      (size + 20).toInt(),
    ); // Tăng chiều cao cho đuôi
    final data = await img.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  Future<void> _loadCustomMarkers() async {
    _jobMarkerIcon = await _createCustomMarkerBitmap(
      "Job",
      Colors.orange.shade700,
      Colors.white,
    );
    _currentLocationMarkerIcon = await _createCustomMarkerBitmap(
      "You",
      Colors.blue.shade700,
      Colors.white,
    ); // "B" cho "Bạn"
    if (mounted) {
      setState(() {}); // Rebuild để map sử dụng icon mới nếu đã load xong
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark; // Lấy theme hiện tại
    // Áp dụng style cho map
    controller.setMapStyle(isDarkMode ? AppGoogleTheme.dark : AppGoogleTheme.light);
    if (_currentPositionLatLng != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPositionLatLng!, 13.5),
      );
    }
  }

  void _addMarkersToMap() {
    if (!mounted || _jobMarkerIcon == null) return; // Chờ icon load xong
    setState(() => _isLoading = true); // Báo đang render markers

    final newMarkers = <Marker>{};
    if (_currentPositionLatLng != null &&
        _currentCity != null &&
        _currentLocationMarkerIcon != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentPositionLatLng!,
          icon: _currentLocationMarkerIcon!,
          infoWindow: InfoWindow(
            title: 'Vị Trí Của Bạn',
            snippet:
                _currentCity!.locality.isNotEmpty
                    ? '${_currentCity!.locality}, ${_currentCity!.administrativeArea}'
                    : _currentCity!.administrativeArea,
          ),
          zIndex: 2, // Ưu tiên hiển thị trên cùng
        ),
      );
    }

    for (var job in _jobsInView) {
      // Chỉ thêm marker cho jobs trong view
      if (job.latitude != null &&
          job.longitude != null &&
          (job.latitude != 0 || job.longitude != 0)) {
        final jobLatLng = LatLng(job.latitude!, job.longitude!);
        final salarySnippet =
            (job.salary != null && job.salary! > 0)
                ? FormatUtils.formatSalary(job.salary!)
                : "Thỏa thuận";
        newMarkers.add(
          Marker(
            markerId: MarkerId(job.idJobPost),
            position: jobLatLng,
            icon: _jobMarkerIcon!, // Sử dụng custom icon
            infoWindow: InfoWindow(
              title: job.title,
              snippet: '${job.company!.companyName} - $salarySnippet',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => JobDetailScreen(
                            idUser: widget.idUser,
                            jobPosting: job,
                          ),
                    ),
                  ),
            ),
          ),
        );
      }
    }
    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.addAll(newMarkers);
        _isLoading = false;
      });
    }
  }

  // Hàm cập nhật danh sách công việc trong vùng nhìn thấy của bản đồ
  Future<void> _updateJobsInView() async {
    if (mapController == null || _allFetchedJobs.isEmpty) {
      _jobsInView = List.from(
        _allFetchedJobs,
      ); // Nếu map chưa sẵn sàng, hiển thị tất cả
      return;
    }
    if (!mounted) return;

    try {
      LatLngBounds visibleRegion = await mapController!.getVisibleRegion();
      setState(() {
        _jobsInView =
            _allFetchedJobs.where((job) {
              if (job.latitude != null && job.longitude != null) {
                final jobLatLng = LatLng(job.latitude!, job.longitude!);
                return visibleRegion.contains(jobLatLng);
              }
              return false;
            }).toList();
      });
    } catch (e) {
      print("Error getting visible region: $e");
      // Giữ lại danh sách cũ nếu có lỗi
    }
  }

  // Hàm tìm kiếm địa điểm và di chuyển bản đồ
  Future<void> _searchAndGoToLocation(String address) async {
    if (address.isEmpty) return;
    FocusScope.of(context).unfocus(); // Ẩn bàn phím
    setState(() => _isLoading = true);
    try {
      List<flutter_geocoding.Location> locations = await flutter_geocoding
          .locationFromAddress(address);
      if (locations.isNotEmpty && mapController != null) {
        final targetLatLng = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );
        mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(targetLatLng, 14.0),
        );
        // Sau khi di chuyển, cập nhật lại jobs in view và markers
        // Đợi camera di chuyển xong một chút rồi mới cập nhật
        await Future.delayed(const Duration(milliseconds: 700));
        await _updateJobsInView();
        _addMarkersToMap();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy địa điểm.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi tìm kiếm địa điểm: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    if (_isLoading && _markers.isEmpty && _currentPositionLatLng == null) {
      // Điều kiện loading ban đầu chặt chẽ hơn
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitFadingCube(
                color: theme.primaryColor,
                size: 40.0,
              ),
              const SizedBox(height: 20),
              Text(
                "Đang xác định vị trí và tải việc làm...",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Đã Xảy Ra Lỗi',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onErrorContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: theme.colorScheme.errorContainer,
          leading: IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: theme.colorScheme.onErrorContainer,
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: theme.colorScheme.onErrorContainer,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.errorContainer,
                  foregroundColor: theme.colorScheme.onErrorContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Quay lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _currentPositionLatLng ?? const LatLng(10.8231, 106.6297), // Mặc định là TP.HCM
              zoom: 13.0, 
            ),
            markers: _markers,
            myLocationEnabled: true, // Hiển thị chấm xanh vị trí người dùng
            myLocationButtonEnabled: false, // Tắt nút mặc định
            zoomControlsEnabled: false, // Tắt nút zoom mặc định
            compassEnabled: false, // Tắt la bàn
            mapToolbarEnabled: false, // Tắt toolbar khi nhấn marker
            onCameraIdle: () {
              if (_cameraIdleDebounce?.isActive ?? false)
                _cameraIdleDebounce!.cancel();
              _cameraIdleDebounce = Timer(
                const Duration(milliseconds: 500),
                () {
                  // Đợi 500ms sau khi camera ngừng
                  if (mounted) {
                    // Kiểm tra mounted trước khi thực hiện
                    print("Camera Idle - Updating jobs and markers");
                    _updateJobsInView().then((_) {
                      if (mounted) {
                        // Kiểm tra lại mounted sau async gap
                        _addMarkersToMap();
                      }
                    });
                  }
                },
              );
            },
            style: isDarkMode? AppGoogleTheme.dark : AppGoogleTheme.light
          ),
          SearchLocationBar(
            controller: _searchLocationController,
            mapController: mapController,
            currentPosition: _currentPositionLatLng,
            onSubmitted: _searchAndGoToLocation,
          ),

          JobListDraggableSheet(
            isLoading: _isLoading,
            jobsInView: _jobsInView,
            sheetAnimationController: _sheetAnimationController,
            showJobList: _showJobList,
            onSheetStateChanged: (value) {
              setState(() => _showJobList = value);
            },
            idUser: widget.idUser,
            currentCity: _currentCity?.locality,
          ),

          // Nút MyLocation và Toggle List/Map (đã được thiết kế lại)
          LocationButton(
            showJobList: _showJobList,
            jobsInView: _jobsInView,
            currentPositionLatLng: _currentPositionLatLng,
            mapController: mapController,
            loadInitialData: _loadInitialData,
          ),
        ],
      ),
    );
  }
}
