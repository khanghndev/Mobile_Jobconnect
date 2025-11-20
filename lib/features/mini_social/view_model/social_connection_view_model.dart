import 'package:flutter/material.dart';
import 'package:job_connect/features/mini_social/model/friend_model.dart';
import 'package:job_connect/features/mini_social/model/friend_request_model.dart';
import 'package:job_connect/features/mini_social/model/sent_request_model.dart';
import 'package:job_connect/features/mini_social/model/social_connection_model.dart';
import 'package:job_connect/features/mini_social/service/social_connection_service.dart';

class SocialConnectionViewModel extends ChangeNotifier {
  final SocialConnectionService _service = SocialConnectionService();

  // STATE CHUNG
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  List<FriendModel> _friends = [];
  List<FriendRequestModel> _requests = [];
  List<SentRequestModel> _sentRequests = [];

  // GETTERS
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  List<FriendModel> get friends => _friends;
  List<FriendRequestModel> get requests => _requests;
  List<SentRequestModel> get sentRequests => _sentRequests;

  // PRIVATE - Update state
  void _setState({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<FriendModel>? friends,
    List<FriendRequestModel>? requests,
    List<SentRequestModel>? sentRequests,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _errorMessage = errorMessage ?? _errorMessage;

    if (friends != null) _friends = friends;
    if (requests != null) _requests = requests;
    if (sentRequests != null) _sentRequests = sentRequests;

    notifyListeners();
  }

  // Gọi API generic
  Future<void> _handleApiCall<T>({
    required Future<T> Function() apiCall,
    required Function(T) onSuccess,
  }) async {
    _setState(isLoading: true, isSuccess: false, errorMessage: null);

    try {
      final result = await apiCall();
      onSuccess(result);
      _setState(isLoading: false, isSuccess: true);
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString(), isSuccess: false);
    }
  }

  // -----------------------------
  // API CALLS
  // -----------------------------

  /// Load tất cả connections
  Future<void> loadAllConnections({required String userId}) async {
    await Future.wait([
      getFriends(userId: userId),
      getRequests(userId: userId),
      getSentRequests(userId: userId),
    ]);
  }

  /// Lấy danh sách bạn bè
  Future<void> getFriends({required String userId}) async {
    await _handleApiCall<List<FriendModel>>(
      apiCall: () => _service.getFriends(userId: userId),
      onSuccess: (data) => _setState(friends: data),
    );
  }

  /// Lấy danh sách yêu cầu kết bạn
  Future<void> getRequests({required String userId}) async {
    await _handleApiCall<List<FriendRequestModel>>(
      apiCall: () => _service.getRequests(userId: userId),
      onSuccess: (data) => _setState(requests: data),
    );
  }

  /// Lấy danh sách yêu cầu đã gửi
  Future<void> getSentRequests({required String userId}) async {
    await _handleApiCall<List<SentRequestModel>>(
      apiCall: () => _service.getSentRequests(userId: userId),
      onSuccess: (data) => _setState(sentRequests: data),
    );
  }

  /// Gửi yêu cầu kết bạn
  Future<void> sendRequest({required SocialConnectionRequest request}) async {
    await _handleApiCall<void>(
      apiCall: () => _service.sendRequest(request: request),
      onSuccess: (_) async {
        await getSentRequests(userId: request.fromUserId);
      },
    );
  }

  /// Huỷ kết bạn
  Future<void> unfriend({required String userId1, required String userId2}) async {
    await _handleApiCall<void>(
      apiCall: () => _service.unfriend(userId1: userId1, userId2: userId2),
      onSuccess: (_) async {
        await getFriends(userId: userId1);
        await getSentRequests(userId: userId1);
      },
    );
  }

  /// Chấp nhận yêu cầu kết bạn
  Future<void> acceptRequest({required SocialConnectionRequest request}) async {
    await _handleApiCall<void>(
      apiCall: () => _service.acceptRequest(request: request),
      onSuccess: (_) async {
        await getRequests(userId: request.toUserId);
        await getFriends(userId: request.toUserId);
      },
    );
  }

  /// Từ chối yêu cầu kết bạn
  Future<void> rejectRequest({required SocialConnectionRequest request}) async {
    await _handleApiCall<void>(
      apiCall: () => _service.rejectRequest(request: request),
      onSuccess: (_) async {
        await getRequests(userId: request.toUserId);
      },
    );
  }

  /// Huỷ yêu cầu đã gửi
  Future<void> cancelRequest({required SocialConnectionRequest request}) async {
    await _handleApiCall<void>(
      apiCall: () => _service.cancelRequest(request: request),
      onSuccess: (_) async {
        await getSentRequests(userId: request.fromUserId);
      },
    );
  }

  /// Chặn người dùng
  Future<void> blockUser({required SocialConnectionRequest request}) async {
    await _handleApiCall<void>(
      apiCall: () => _service.blockUser(request: request),
      onSuccess: (_) async {
        await loadAllConnections(userId: request.fromUserId);
      },
    );
  }

  /// Chấp nhận tất cả yêu cầu kết bạn
  Future<void> acceptAllRequests({required String userId}) async {
    await _handleApiCall<void>(
      apiCall: () => _service.acceptAllRequests(userId: userId),
      onSuccess: (_) async {
        await getRequests(userId: userId);
        await getFriends(userId: userId);
      },
    );
  }

  /// Huỷ tất cả yêu cầu kết bạn
  Future<void> cancelAllRequests({required String userId}) async {
    await _handleApiCall<void>(
      apiCall: () => _service.cancelAllRequests(userId: userId),
      onSuccess: (_) async {
        await getSentRequests(userId: userId);
      },
    );
  }

  /// Lấy trạng thái kết bạn
  Future<SocialConnectionModel> getStatus({
    required String currentUserId,
    required String targetUserId,
  }) async {
    SocialConnectionModel? status;
    await _handleApiCall<SocialConnectionModel>(
      apiCall: () => _service.getStatus(
        currentUserId: currentUserId,
        targetUserId: targetUserId,
      ),
      onSuccess: (data) => status = data,
    );
    return status!;
  }

  /// Reset toàn bộ state
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
