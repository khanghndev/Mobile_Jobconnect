import 'package:flutter/material.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/features/notifications/model/notification_model.dart';
import 'package:job_connect/features/notifications/service/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  // ===== STATE =====
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _selectMode = false;
  String? _errorMessage;
  final Set<String> _selectedNotifications = {};
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  // ===== GETTERS =====
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  bool get selectMode => _selectMode;
  String? get errorMessage => _errorMessage;
  List<NotificationModel> get notifications => _notifications;
  Set<String> get selectedNotifications => _selectedNotifications;
  int get unreadCount => _unreadCount;

  // ===== PRIVATE SET STATE =====
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

  // TODO: Lấy danh sách thông báo theo FIFO (cũ nhất trước)
  Future<void> getNotifications(String userId) async {
    _setState(isLoading: true, errorMessage: null, isSuccess: false);
    try {
      final data = await _notificationService.getNotifications();

      // FIFO: cũ nhất trước
      data.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      _setState(notifications: data, isSuccess: true);
    } on ServerException catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    } finally {
      _setState(isLoading: false);
    }
  }

  // TODO: Lấy số lượng thông báo chưa đọc (nếu backend có endpoint riêng)
  Future<void> getUnreadCount(String userId) async {
    try {
      final notifications = await _notificationService.getNotifications();
      final count = notifications.where((n) => n.isRead == 0).length;
      _setState(notifications: notifications);
      _setState(unreadCount: count);
    } catch (e) {
      debugPrint('Error getching unread count: $e');
    }
  }

  // TODO: Cập nhật state chế độ chọn nhiều
  void onToggleSelectMode() {
    _selectMode = !_selectMode;
    if (!_selectMode) _selectedNotifications.clear();
    notifyListeners();
  }

  // TODO: Chọn / bỏ chọn 1 thông báo
  void onToggleSelect(String id) {
    if (_selectedNotifications.contains(id)) {
      _selectedNotifications.remove(id);
    } else {
      _selectedNotifications.add(id);
    }
    notifyListeners();
  }

  // TODO: Đánh dấu đã đọc cho các thông báo được chọn
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

    _setState(notifications: updated);
    _selectedNotifications.clear();
    _selectMode = false;

    try {
      await Future.wait(updateFutures);
      _setState(unreadCount: updated.where((n) => n.isRead == 0).length);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // TODO: Xóa thông báo được chọn
  Future<void> deleteNotifications() async {
    if (_selectedNotifications.isEmpty) return;

    final idsToDelete = List<String>.from(_selectedNotifications);
    _notifications.removeWhere(
        (noti) => idsToDelete.contains(noti.idNotification));
    notifyListeners();

    final List<Future> deleteFutures = [];
    for (String id in idsToDelete) {
      deleteFutures.add(_notificationService.deleteNotification(id: id));
    }

    _selectedNotifications.clear();
    _selectMode = false;

    try {
      await Future.wait(deleteFutures);
      _setState(unreadCount: _notifications.where((n) => n.isRead == 0).length);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // TODO: Đánh dấu toàn bộ thông báo là đã đọc
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

    _setState(notifications: updated, unreadCount: 0);

    try {
      await Future.wait(updateFutures);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // TODO: Reset toàn bộ state
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
