import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:job_connect/config/enum/shared_prefs_key.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/utils/string_utils.dart';
import 'package:job_connect/features/home/model/podcast_model.dart';
import 'package:job_connect/features/home/service/podcast_service.dart';
import 'package:job_connect/config/services/shared_prefs_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PodcastViewModel extends ChangeNotifier {
  // TODO: Service xử lý API
  final PodcastService _podcastService = PodcastService();

  // TODO: Service lưu trữ local
  SharedPrefsService? _prefsService; // dùng nullable để tránh LateInitializationError
  bool _prefsReady = false;

  // TODO: Constructor khởi tạo SharedPrefsService
  PodcastViewModel() {
    _initPrefs();
  }

  // TODO: Hàm async khởi tạo SharedPrefsService
  Future<void> _initPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _prefsService = SharedPrefsService(prefs: prefs);
    _prefsReady = true;
    await loadFavorites(); // load danh sách yêu thích ngay khi có prefs
  }

  // TODO: State nội bộ
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;
  List<PodcastModel> _podcasts = [];
  List<PodcastModel> _filteredPodcasts = [];
  final Set<String> _favoriteIds = {}; // TODO: Lưu ID podcast yêu thích local

  // TODO: Getter cho view
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  List<PodcastModel> get podcasts => _podcasts;
  List<PodcastModel> get filteredPodcasts => _filteredPodcasts;
  bool isFavorite(PodcastModel podcast) => _favoriteIds.contains(podcast.idPodcast);

  // TODO: Cập nhật state nội bộ
  void _setState({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<PodcastModel>? podcasts,
    List<PodcastModel>? filteredPodcasts,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _errorMessage = errorMessage;
    _podcasts = podcasts ?? _podcasts;
    _filteredPodcasts = filteredPodcasts ?? _filteredPodcasts;
    notifyListeners();
  }

  // TODO: Gọi API lấy danh sách podcast
  Future<void> getPodcasts() async {
    _setState(isLoading: true, errorMessage: null, isSuccess: false);

    try {
      final data = await _podcastService.getPodcasts();
      data.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

      _setState(
        podcasts: data,
        filteredPodcasts: data,
        isSuccess: true,
      );
    } on ServerException catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    }  
  }

  // TODO: Lọc podcast theo từ khóa (có xử lý bỏ dấu)
  void filterPodcasts(String keyword) {
    if (keyword.isEmpty) {
      _setState(filteredPodcasts: _podcasts);
      return;
    }

    final lower = StringUtils.removeDiacritics(keyword.toLowerCase());
    final filtered = _podcasts.where((podcast) {
      final title = StringUtils.removeDiacritics(podcast.title.toLowerCase());
      final host = StringUtils.removeDiacritics((podcast.host ?? '').toLowerCase());
      return title.contains(lower) || host.contains(lower);
    }).toList();

    _setState(filteredPodcasts: filtered);
  }

  // TODO: Làm mới danh sách podcast
  Future<void> refreshPodcasts() async => await getPodcasts();

  // TODO: Load danh sách yêu thích từ local storage
  Future<void> loadFavorites() async {
    if (!_prefsReady || _prefsService == null) return;

    final jsonString = _prefsService!.getString(SharedPrefsKey.favoritePodcasts);
    if (jsonString != null) {
      try {
        final List<dynamic> decoded = jsonDecode(jsonString);
        _favoriteIds
          ..clear()
          ..addAll(decoded.cast<String>());
      } catch (_) {
        _favoriteIds.clear();
      }
    }
    notifyListeners();
  }

  // TODO: Thêm / Xóa podcast khỏi danh sách yêu thích và lưu local
  Future<void> toggleFavorite(PodcastModel podcast) async {
    // TODO: Nếu chưa khởi tạo prefs thì chờ init
    if (!_prefsReady || _prefsService == null) {
      await _initPrefs();
    }

    // TODO: Cập nhật local state để phản hồi nhanh
    if (isFavorite(podcast)) {
      _favoriteIds.remove(podcast.idPodcast);
    } else {
      _favoriteIds.add(podcast.idPodcast);
    }

    notifyListeners();

    // TODO: Lưu xuống local (không chặn UI)
    unawaited(
      _prefsService?.saveString(
        SharedPrefsKey.favoritePodcasts,
        jsonEncode(_favoriteIds.toList()),
      ),
    );
  }

  // TODO: Reset toàn bộ state
  void reset() {
    _setState(
      isLoading: false,
      isSuccess: false,
      errorMessage: null,
      podcasts: [],
      filteredPodcasts: [],
    );
    _favoriteIds.clear();
  }
}
