import 'package:flutter/material.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/features/notifications/model/notification_model.dart';
import 'package:job_connect/features/notifications/service/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  //   STATE 
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _selectMode = false;
  String? _errorMessage;
  final Set<String> _selectedNotifications = {};
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  //   GETTERS 
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  bool get selectMode => _selectMode;
  String? get errorMessage => _errorMessage;
  List<NotificationModel> get notifications => _notifications;
  Set<String> get selectedNotifications => _selectedNotifications;
  int get unreadCount => _unreadCount;

  //   PRIVATE SET STATE 
  void _setState({
    bool? isLoading,
    bool? isSuccess,
    bool? selectMode,
    String? errorMessage,
    List<NotificationModel>? notifications,
    int? unreadCount,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _selectMode = selectMode ?? _selectMode;
    _errorMessage = errorMessage;
    _notifications = notifications ?? _notifications;
    _unreadCount = unreadCount ?? _unreadCount;
    notifyListeners();
  }

  //   GENERIC API HANDLER 
  Future<void> _handleApiCall<T>({
    required Future<T> Function() apiCall,
    void Function(T)? onSuccess,
    bool showLoading = true,
  }) async {
    if (showLoading) _setState(isLoading: true, isSuccess: false, errorMessage: null);
    try {
      final result = await apiCall();
      if (onSuccess != null) onSuccess(result);
      _setState(isSuccess: true);
    } on ServerException catch (e) {
      _setState(errorMessage: e.err, isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } finally {
      if (showLoading) _setState(isLoading: false);
    }
  }

  //   GET: Danh sách thông báo theo user 
  Future<void> getNotificationsByIdUser(String userId) async {
    await _handleApiCall<List<NotificationModel>>(
      apiCall: () => _notificationService.getNotificationsByIdUser(idUser: userId),
      onSuccess: (data) {
        _notifications = data;
      },
    );
  }

  //   GET: Số lượng thông báo chưa đọc 
  Future<void> getUnreadCount(String userId) async {
    await _handleApiCall<List<NotificationModel>>(
      apiCall: () => _notificationService.getNotificationsByIdUser(idUser: userId),
      showLoading: false,
      onSuccess: (data) {
        _unreadCount = data.where((n) => n.isRead == 0).length;
      },
    );
  }

  //   CẬP NHẬT: Chế độ chọn nhiều 
  void onToggleSelectMode() {
    _selectMode = !_selectMode;
    if (!_selectMode) _selectedNotifications.clear();
    notifyListeners();
  }

  //   CẬP NHẬT: Chọn / bỏ chọn một thông báo 
  void onToggleSelect(String id) {
    if (_selectedNotifications.contains(id)) {
      _selectedNotifications.remove(id);
    } else {
      _selectedNotifications.add(id);
    }
    notifyListeners();
  }

  //   UPDATE: Đánh dấu đã đọc các thông báo được chọn 
  Future<void> markAsRead() async {
    if (_selectedNotifications.isEmpty) return;

    final updated = List<NotificationModel>.from(_notifications);
    final List<Future> updateFutures = [];

    for (String id in _selectedNotifications) {
      int index = updated.indexWhere((n) => n.idNotification == id);
      if (index != -1 && updated[index].isRead == 0) {
        updated[index].isRead = 1;
        updateFutures.add(
          _notificationService.updateNotification(
            id: id,
            data: updated[index].toJson(),
          ),
        );
      }
    }

    _setState(notifications: updated, unreadCount: updated.where((n) => n.isRead == 0).length);
    _selectedNotifications.clear();
    _selectMode = false;

    await _handleApiCall<void>(
      apiCall: () async => Future.wait(updateFutures),
      showLoading: false,
    );
  }

  //   DELETE: Xóa các thông báo được chọn 
  Future<void> deleteNotifications() async {
    if (_selectedNotifications.isEmpty) return;

    final idsToDelete = List<String>.from(_selectedNotifications);
    final List<Future> deleteFutures = [];

    _notifications.removeWhere((n) => idsToDelete.contains(n.idNotification));
    _selectedNotifications.clear();
    _selectMode = false;

    for (String id in idsToDelete) {
      deleteFutures.add(_notificationService.deleteNotification(id: id));
    }

    await _handleApiCall<void>(
      apiCall: () async => Future.wait(deleteFutures),
      showLoading: false,
      onSuccess: (_) {
        _unreadCount = _notifications.where((n) => n.isRead == 0).length;
      },
    );
  }

  //   UPDATE: Đánh dấu tất cả là đã đọc 
  Future<void> markAllAsRead() async {
    final unread = _notifications.where((n) => n.isRead == 0).toList();
    if (unread.isEmpty) return;

    final updated = List<NotificationModel>.from(_notifications);
    final List<Future> updateFutures = [];

    for (final noti in updated) {
      if (noti.isRead == 0) {
        noti.isRead = 1;
        updateFutures.add(
          _notificationService.updateNotification(
            id: noti.idNotification,
            data: noti.toJson(),
          ),
        );
      }
    }

    await _handleApiCall<void>(
      apiCall: () async => Future.wait(updateFutures),
      showLoading: false,
      onSuccess: (_) {
        _setState(notifications: updated, unreadCount: 0);
      },
    );
  }

  //   RESET 
  void onReset() {
    _setState(
      isLoading: false,
      isSuccess: false,
      selectMode: false,
      errorMessage: null,
      notifications: [],
      unreadCount: 0,
    );
    _selectedNotifications.clear();
  }
}
