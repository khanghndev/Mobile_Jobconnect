import 'package:flutter/material.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/features/mini_social/model/friend_model.dart';
import 'package:job_connect/features/mini_social/model/social_connection_model.dart';
import 'package:job_connect/features/mini_social/service/social_connection_service.dart';

class SocialConnectionViewModel extends ChangeNotifier {
  final SocialConnectionService _service = SocialConnectionService();

  // STATE
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  List<FriendModel> _friends = [];
  List<String> _requests = [];
  List<String> _sentRequests = [];

  // GETTERS
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  List<FriendModel> get friends => _friends;
  List<String> get requests => _requests;
  List<String> get sentRequests => _sentRequests;

  // PRIVATE SET STATE
  void _setState({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<FriendModel>? friends,
    List<String>? requests,
    List<String>? sentRequests,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _errorMessage = errorMessage ?? _errorMessage;
    _friends = friends ?? _friends;
    _requests = requests ?? _requests;
    _sentRequests = sentRequests ?? _sentRequests;
    notifyListeners();
  }

  // GENERIC API CALL HANDLER
  Future<void> _handleApiCall<T>({
    required Future<T> Function() apiCall,
    void Function(T)? onSuccess,
  }) async {
    _setState(isLoading: true, isSuccess: false, errorMessage: null);
    try {
      final result = await apiCall();
      if (onSuccess != null) onSuccess(result);
      _setState(isSuccess: true);
    } on ServerException catch (e) {
      _setState(errorMessage: e.err, isSuccess: false);
    } catch (e) {
      _setState(errorMessage: e.toString(), isSuccess: false);
    }
  }

  // Lấy danh sách bạn bè
  Future<void> getFriends({required String userId}) async {
    await _handleApiCall<List<FriendModel>>(
      apiCall: () => _service.getFriends(userId: userId),
      onSuccess: (data) => _friends = data,
    );
  }

  // Lấy danh sách yêu cầu kết bạn
  Future<void> getRequests({required String userId}) async {
    await _handleApiCall<List<String>>(
      apiCall: () => _service.getRequests(userId: userId),
      onSuccess: (data) => _requests = data,
    );
  }

  // Lấy danh sách yêu cầu đã gửi
  Future<void> getSentRequests({required String userId}) async {
    await _handleApiCall<List<String>>(
      apiCall: () => _service.getSentRequests(userId: userId),
      onSuccess: (data) => _sentRequests = data,
    );
  }

  // Gửi yêu cầu kết bạn
  Future<void> sendRequest({required SocialConnectionRequest request}) async {
    await _handleApiCall(
      apiCall: () => _service.sendRequest(request: request),
    );
  }

  // Chấp nhận yêu cầu kết bạn
  Future<void> acceptRequest({required SocialConnectionRequest request}) async {
    await _handleApiCall(
      apiCall: () => _service.acceptRequest(request: request),
    );
  }

  // Từ chối yêu cầu kết bạn
  Future<void> rejectRequest({required SocialConnectionRequest request}) async {
    await _handleApiCall(
      apiCall: () => _service.rejectRequest(request: request),
    );
  }

  // Huỷ yêu cầu kết bạn
  Future<void> cancelRequest({required SocialConnectionRequest request}) async {
    await _handleApiCall(
      apiCall: () => _service.cancelRequest(request: request),
    );
  }

  // Chặn người dùng
  Future<void> blockUser({required SocialConnectionRequest request}) async {
    await _handleApiCall(
      apiCall: () => _service.blockUser(request: request),
    );
  }

  // Huỷ kết bạn
  Future<void> unfriend({required String userId1, required String userId2}) async {
    await _handleApiCall(
      apiCall: () => _service.unfriend(userId1: userId1, userId2: userId2),
    );
  }

  // Chấp nhận tất cả yêu cầu
  Future<void> acceptAllRequests({required String userId}) async {
    await _handleApiCall(
      apiCall: () => _service.acceptAllRequests(userId: userId),
    );
  }

  // Huỷ tất cả yêu cầu
  Future<void> cancelAllRequests({required String userId}) async {
    await _handleApiCall(
      apiCall: () => _service.cancelAllRequests(userId: userId),
    );
  }

  // Lấy trạng thái kết bạn
  Future<SocialConnectionModel> getStatus({required SocialConnectionRequest request}) async {
    SocialConnectionModel? status;
    await _handleApiCall<SocialConnectionModel>(
      apiCall: () => _service.getStatus(request: request),
      onSuccess: (data) => status = data,
    );
    return status!;
  }

  // Load tất cả connections
  Future<void> loadAllConnections({required String userId}) async {
    await Future.wait([
      getFriends(userId: userId),
      getRequests(userId: userId),
      getSentRequests(userId: userId),
    ]);
  }

  // Refresh danh sách bạn bè
  Future<void> refreshFriends({required String userId}) async {
    await getFriends(userId: userId);
  }

  // Refresh danh sách yêu cầu kết bạn
  Future<void> refreshRequests({required String userId}) async {
    await getRequests(userId: userId);
  }

  // Nếu cần, refresh danh sách yêu cầu đã gửi
  Future<void> refreshSentRequests({required String userId}) async {
    await getSentRequests(userId: userId);
  }

  void resetState() {
    _isLoading = false;
    _isSuccess = false;
    _errorMessage = null;
    _friends = [];
    _requests = [];
    _sentRequests = [];
    notifyListeners();
  }

}
