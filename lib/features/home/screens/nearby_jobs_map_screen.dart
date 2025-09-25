import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as flutter_geocoding;
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/data/models/job_posting_model.dart';
import 'package:job_connect/data/services/api.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:job_connect/config/utils/format.dart';
import 'package:job_connect/features/job/screens/job_detail_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // For nice loading indicators
import 'dart:ui'; // For custom markers
import 'dart:typed_data'; // For custom markers

class NearbyJobsMapScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;

  const NearbyJobsMapScreen({
    Key? key,
    required this.isLoggedIn,
    required this.idUser,
  }) : super(key: key);

  @override
  State<NearbyJobsMapScreen> createState() => _NearbyJobsMapScreenState();
}

const String _mapStyleLightJson = '''
[
  {
    "featureType": "poi.business",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  }
]
''';

const String _mapStyleDarkJson = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.business",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text",
    "stylers": [
      {
        "visibility": "off"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]
''';

class _NearbyJobsMapScreenState extends State<NearbyJobsMapScreen>
    with TickerProviderStateMixin {
  // Add TickerProviderStateMixin
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  bool _showJobList = false;
  bool _isLoading = true;
  // bool _isGeocodingMarkers = false; // Có thể không cần nếu geocoding ở backend
  String _errorMessage = '';
  LatLng? _currentPositionLatLng;
  City? _currentCity;
  // bool _isRenderingMarkers = false; // Đã tích hợp vào _isLoading
  final ApiService _apiService = ApiService(baseUrl: ApiConstants.baseUrl);
  List<JobPosting> _allFetchedJobs = [];
  List<JobPosting> _jobsInView =
      []; // Jobs hiển thị trong DraggableScrollableSheet, được lọc theo map bounds

  final TextEditingController _searchLocationController =
      TextEditingController();
  Timer? _debounce;
  Timer? _cameraIdleDebounce;

  // Animation
  late AnimationController _sheetAnimationController;
  late Animation<double> _sheetHeaderFadeAnimation;

  // BitmapDescriptor for custom markers
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

  String _removeDiacritics(String input) {
    final diacriticsMap = {
      'á': 'a',
      'à': 'a',
      'ả': 'a',
      'ã': 'a',
      'ạ': 'a',
      'ă': 'a',
      'ắ': 'a',
      'ằ': 'a',
      'ẳ': 'a',
      'ẵ': 'a',
      'ặ': 'a',
      'â': 'a',
      'ấ': 'a',
      'ầ': 'a',
      'ẩ': 'a',
      'ẫ': 'a',
      'ậ': 'a',
      'é': 'e',
      'è': 'e',
      'ẻ': 'e',
      'ẽ': 'e',
      'ẹ': 'e',
      'ê': 'e',
      'ế': 'e',
      'ề': 'e',
      'ể': 'e',
      'ễ': 'e',
      'ệ': 'e',
      'í': 'i',
      'ì': 'i',
      'ỉ': 'i',
      'ĩ': 'i',
      'ị': 'i',
      'ó': 'o',
      'ò': 'o',
      'ỏ': 'o',
      'õ': 'o',
      'ọ': 'o',
      'ô': 'o',
      'ố': 'o',
      'ồ': 'o',
      'ổ': 'o',
      'ỗ': 'o',
      'ộ': 'o',
      'ơ': 'o',
      'ớ': 'o',
      'ờ': 'o',
      'ở': 'o',
      'ỡ': 'o',
      'ợ': 'o',
      'ú': 'u',
      'ù': 'u',
      'ủ': 'u',
      'ũ': 'u',
      'ụ': 'u',
      'ư': 'u',
      'ứ': 'u',
      'ừ': 'u',
      'ử': 'u',
      'ữ': 'u',
      'ự': 'u',
      'ý': 'y',
      'ỳ': 'y',
      'ỷ': 'y',
      'ỹ': 'y',
      'ỵ': 'y',
      'đ': 'd',
      'Á': 'A',
      'À': 'A',
      'Ả': 'A',
      'Ã': 'A',
      'Ạ': 'A',
      'Ă': 'A',
      'Ắ': 'A',
      'Ằ': 'A',
      'Ẳ': 'A',
      'Ẵ': 'A',
      'Ặ': 'A',
      'Â': 'A',
      'Ấ': 'A',
      'Ầ': 'A',
      'Ẩ': 'A',
      'Ẫ': 'A',
      'Ậ': 'A',
      'É': 'E',
      'È': 'E',
      'Ẻ': 'E',
      'Ẽ': 'E',
      'Ẹ': 'E',
      'Ê': 'E',
      'Ế': 'E',
      'Ề': 'E',
      'Ể': 'E',
      'Ễ': 'E',
      'Ệ': 'E',
      'Í': 'I',
      'Ì': 'I',
      'Ỉ': 'I',
      'Ĩ': 'I',
      'Ị': 'I',
      'Ó': 'O',
      'Ò': 'O',
      'Ỏ': 'O',
      'Õ': 'O',
      'Ọ': 'O',
      'Ô': 'O',
      'Ố': 'O',
      'Ồ': 'O',
      'Ổ': 'O',
      'Ỗ': 'O',
      'Ộ': 'O',
      'Ơ': 'O',
      'Ớ': 'O',
      'Ờ': 'O',
      'Ở': 'O',
      'Ỡ': 'O',
      'Ợ': 'O',
      'Ú': 'U',
      'Ù': 'U',
      'Ủ': 'U',
      'Ũ': 'U',
      'Ụ': 'U',
      'Ư': 'U',
      'Ứ': 'U',
      'Ừ': 'U',
      'Ử': 'U',
      'Ữ': 'U',
      'Ự': 'U',
      'Ý': 'Y',
      'Ỳ': 'Y',
      'Ỷ': 'Y',
      'Ỹ': 'Y',
      'Ỵ': 'Y',
      'Đ': 'D',
    };
    return input.split('').map((char) => diacriticsMap[char] ?? char).join();
  }

  String _normalizeCityName(String cityName) {
    if (cityName.isEmpty) return "";
    String normalized = _removeDiacritics(cityName).trim();
    normalized = normalized.replaceAll(
      RegExp(r'^(Thành Phố|tp\.|t\.p\.|Tỉnh)\s*'),
      '',
    );
    normalized = normalized.replaceAll(
      RegExp(r'\s*(Thành phố|tp\.|t\.p\.|Tỉnh)$'),
      '',
    );
    normalized = normalized.replaceAll(RegExp(r'^(City|Province)\s*'), '');
    normalized = normalized.replaceAll(RegExp(r'\s*(City|Province)$'), '');
    normalized = normalized.replaceAll(RegExp(r'\s*Thành phố\s*'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s*Tỉnh\s*'), ' ');
    return normalized.trim();
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
        _currentCity = City(
          // Sử dụng City model của bạn
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
        ApiConstants.jobPostingEndpoint,
      );
      _allFetchedJobs.addAll(
        (responseData as List)
            .map((job) => JobPosting.fromJson(job as Map<String, dynamic>))
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
    controller.setMapStyle(isDarkMode ? _mapStyleDarkJson : _mapStyleLightJson);
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
              snippet: '${job.company.companyName} - $salarySnippet',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => JobDetailScreen(
                            idUser: widget.idUser,
                            idJobPost: job.idJobPost,
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
              ), // Loading indicator đẹp
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
      resizeToAvoidBottomInset:
          false, // Quan trọng để bàn phím không đẩy map lên
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target:
                  _currentPositionLatLng ??
                  const LatLng(10.8231, 106.6297), // Mặc định là TP.HCM
              zoom: 13.0, // Zoom ra xa hơn một chút ban đầu
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
            style:
                isDarkMode
                    ? _mapStyleDarkJson
                    : _mapStyleLightJson, // Áp dụng style tùy theo theme
          ),

          // Bọc Row của bạn trong một Padding để nó không bị sát các cạnh màn hình
          Padding(
            padding: const EdgeInsets.only(
              // Điều chỉnh các giá trị top, left, right cho phù hợp với thiết kế của bạn
              top:
                  50.0, // Ví dụ: bằng với MediaQuery.of(context).padding.top + 15
              left: 15.0,
              right: 15.0,
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Căn giữa các item theo chiều dọc
              children: [
                // 1. Nút Back (không cần Container bọc ngoài cũng được)
                FloatingActionButton.small(
                  heroTag: "backButtonMap",
                  onPressed: () => Navigator.pop(context, true),
                  backgroundColor: theme.cardColor.withOpacity(0.9),
                  elevation: 3,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: theme.primaryColor,
                    size: 18,
                  ),
                ),

                // Thêm một khoảng trống nhỏ giữa 2 widget
                const SizedBox(width: 10),

                // 2. Thanh tìm kiếm (dùng Expanded để nó chiếm hết không gian còn lại)
                Expanded(
                  child: Material(
                    // Material để có shadow đẹp
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(30.0),
                    shadowColor: theme.shadowColor.withOpacity(0.3),
                    child: TextField(
                      controller: _searchLocationController,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm địa điểm, thành phố...',
                        hintStyle: TextStyle(
                          color: theme.hintColor.withOpacity(0.8),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: theme.primaryColor,
                          size: 22,
                        ),
                        suffixIcon:
                            _searchLocationController.text.isNotEmpty
                                ? IconButton(
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    color: theme.iconTheme.color?.withOpacity(
                                      0.7,
                                    ),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _searchLocationController.clear();
                                    FocusScope.of(context).unfocus();
                                    if (_currentPositionLatLng != null &&
                                        mapController != null) {
                                      mapController!.animateCamera(
                                        CameraUpdate.newLatLngZoom(
                                          _currentPositionLatLng!,
                                          13.0,
                                        ),
                                      );
                                    }
                                  },
                                  splashRadius: 20,
                                )
                                : null,
                        filled: true,
                        fillColor: theme.cardColor,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14.0,
                          horizontal: 20.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(
                            color: theme.dividerColor.withOpacity(0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 1.5,
                          ),
                        ),
                      ),
                      onSubmitted: _searchAndGoToLocation,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Danh sách công việc (DraggableScrollableSheet)
          DraggableScrollableSheet(
            initialChildSize: 0.15, // Bắt đầu nhỏ hơn
            minChildSize: 0.15, // Giữ nguyên min
            maxChildSize: 0.85, // Giảm max một chút
            snap: true, // Cho phép snap tới các kích thước
            snapSizes: const [0.15, 0.5, 0.85],
            builder: (BuildContext context, ScrollController scrollController) {
              // Cập nhật trạng thái _showJobList dựa trên vị trí của sheet
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  final currentSheetSize =
                      scrollController.hasClients
                          ? (scrollController.position.viewportDimension /
                              MediaQuery.of(context).size.height)
                          : 0.15;
                  if (currentSheetSize > 0.18 && !_showJobList) {
                    // Ngưỡng để coi là đang mở list
                    setState(() => _showJobList = true);
                    _sheetAnimationController.forward();
                  } else if (currentSheetSize <= 0.18 && _showJobList) {
                    setState(() => _showJobList = false);
                    _sheetAnimationController.reverse();
                  }
                }
              });

              return Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      // Thanh kéo (Grabber)
                      width: 45,
                      height: 5.5,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FadeTransition(
                      // Animation cho header của sheet
                      opacity: _sheetHeaderFadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isLoading && _jobsInView.isEmpty
                                  ? "Đang tìm việc làm..."
                                  : "${_jobsInView.length} việc làm trong khu vực",
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_isLoading &&
                                _jobsInView
                                    .isNotEmpty) // Loading nhỏ khi đang update list
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    theme.primaryColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child:
                          (_isLoading && _jobsInView.isEmpty)
                              ? Center(
                                child: Text(
                                  _currentCity == null
                                      ? "Vui lòng bật vị trí..."
                                      : "Không có việc làm nào tại đây.",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                ),
                              )
                              : _jobsInView.isEmpty
                              ? Center(
                                child: Text(
                                  "Không có việc làm nào trong vùng bản đồ này.",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.hintColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                              : ListView.separated(
                                controller: scrollController,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  16,
                                ),
                                itemCount: _jobsInView.length,
                                separatorBuilder:
                                    (context, index) =>
                                        const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final job = _jobsInView[index];
                                  return JobCard(
                                    jobPosting: job,
                                    idUser: widget.idUser,
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Nút MyLocation và Toggle List/Map (đã được thiết kế lại)
          Positioned(
            bottom:
                _showJobList
                    ? (MediaQuery.of(context).size.height *
                            (_jobsInView.isEmpty ? 0.18 : 0.5)) +
                        25
                    : 30, // Điều chỉnh vị trí dựa trên sheet
            right: 15,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: "myLocationButtonMap",
                  backgroundColor: theme.cardColor,
                  elevation: 4,
                  onPressed: () {
                    if (_currentPositionLatLng != null &&
                        mapController != null) {
                      mapController!.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          _currentPositionLatLng!,
                          14.5,
                        ),
                      );
                    } else {
                      _loadInitialData(); // Thử tải lại nếu chưa có vị trí
                    }
                  },
                  child: Icon(
                    Icons.my_location_rounded,
                    color: theme.primaryColor,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 12),
                // FloatingActionButton(
                //   heroTag: "toggleListMapButton",
                //   backgroundColor: theme.primaryColor,
                //   elevation: 4,
                //   onPressed: () {
                //     if (_showJobList) {
                //       // Nếu danh sách đang hiển thị, thu nhỏ lại
                //       setState(() => _showJobList = false);
                //       _sheetAnimationController.reverse();
                //     } else {
                //       // Nếu danh sách đang thu nhỏ, mở rộng ra
                //       setState(() => _showJobList = true);
                //       _sheetAnimationController.forward();
                //     }
                //   },
                //   child: Icon(
                //     _showJobList
                //         ? Icons.map_rounded
                //         : Icons.format_list_bulleted_rounded,
                //     color: Colors.white,
                //     size: 26,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- City Class ---
class City {
  final String isoCountryCode;
  final String country;
  final String postalCode;
  final String administrativeArea;
  final String subAdministrativeArea;
  final String locality;
  final String subLocality;
  final String thoroughfare;
  final String subThoroughfare;

  City({
    required this.isoCountryCode,
    required this.country,
    required this.postalCode,
    required this.administrativeArea,
    required this.subAdministrativeArea,
    required this.locality,
    required this.subLocality,
    required this.thoroughfare,
    required this.subThoroughfare,
  });

  @override
  String toString() {
    return 'City(isoCountryCode: $isoCountryCode, country: $country, postalCode: $postalCode, administrativeArea: $administrativeArea, subAdministrativeArea: $subAdministrativeArea, locality: $locality, subLocality: $subLocality, thoroughfare: $thoroughfare, subThoroughfare: $subThoroughfare)';
  }
}

// --- JobCard Widget (Cập nhật giao diện) ---
class JobCard extends StatelessWidget {
  final JobPosting jobPosting;
  final String idUser;

  const JobCard({Key? key, required this.jobPosting, required this.idUser})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final companyInitial =
        (jobPosting.company.companyName.isNotEmpty)
            ? jobPosting.company.companyName[0].toUpperCase()
            : "C";
    final salaryText =
        (jobPosting.salary != null && jobPosting.salary! > 0)
            ? FormatUtils.formatSalary(jobPosting.salary!)
            : "Thỏa Thuận";

    return Card(
      // Sử dụng Card để có elevation và shape
      elevation: 2.5,
      margin: const EdgeInsets.only(
        bottom: 1.0,
      ), // Chỉ margin bottom để sát nhau hơn trong list
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: theme.cardColor,
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => JobDetailScreen(
                      idUser: idUser,
                      idJobPost: jobPosting.idJobPost,
                    ),
              ),
            ),
        borderRadius: BorderRadius.circular(14),
        splashColor: theme.primaryColor.withOpacity(0.1),
        highlightColor: theme.primaryColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.all(14.0), // Tăng padding
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Căn giữa theo chiều dọc
            children: [
              Container(
                width: 56,
                height: 56, // Tăng kích thước logo
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12), // Bo góc lớn hơn
                  border: Border.all(
                    color: theme.dividerColor.withOpacity(0.3),
                    width: 0.8,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child:
                      (jobPosting.company.logoCompany != null &&
                              jobPosting.company.logoCompany!.isNotEmpty)
                          ? Image.network(
                            jobPosting.company.logoCompany!,
                            fit: BoxFit.contain,
                            errorBuilder:
                                (c, e, s) => Center(
                                  child: Text(
                                    companyInitial,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          color: theme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                          )
                          : Center(
                            child: Text(
                              companyInitial,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      jobPosting.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      jobPosting.company.companyName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant.withOpacity(
                          0.85,
                        ),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      // Gom các chip thông tin lại
                      children: [
                        _buildInfoChip(
                          context,
                          icon: Icons.attach_money_rounded,
                          text: salaryText,
                          color: theme.colorScheme.secondary,
                          theme: theme,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          context,
                          icon: Icons.location_pin,
                          text: FormatUtils.extractDistrictAndCity(
                            jobPosting.location,
                          ),
                          color: theme.colorScheme.tertiary,
                          theme: theme,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Bỏ nút bookmark ở đây để card gọn hơn, người dùng có thể vào chi tiết để lưu
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String text,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ), // Điều chỉnh padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16), // Bo tròn hơn
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15), // Icon nhỏ hơn
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ), // Chữ đậm hơn
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
