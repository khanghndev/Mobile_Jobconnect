import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/mini_social/model/friend_model.dart';
import 'package:job_connect/features/mini_social/model/friend_request_model.dart';
import 'package:job_connect/features/mini_social/model/sent_request_model.dart';
import 'package:job_connect/features/mini_social/model/social_connection_model.dart';

class SocialConnectionService {
  final ApiService _apiService;

  SocialConnectionService() : _apiService = ApiService();

  Future<T> _handleApi<T>(Future<T> Function() action, String errorMsg) async {
    try {
      return await action();
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        err: '$errorMsg: ${e.toString()}',
        type: ServerExceptionType.unknown,
      );
    }
  }

  /// Gửi yêu cầu kết bạn
  Future<String> sendRequest({required SocialConnectionRequest request}) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.socialConnectionsRequestEndpoint,
          body: request.toJson(),
        );

        // Server luôn trả {"message": "..."}
        return res.data["message"] ?? "Thành công";
      },
      'Lỗi khi gửi kết bạn',
    );
  }

  /// Chấp nhận yêu cầu kết bạn
  Future<void> acceptRequest({required SocialConnectionRequest request}) async {
    return _handleApi(
      () async {
        await _apiService.post(
          endpoint: ApiConstants.socialConnectionsAcceptEndpoint,
          body: request.toJson(),
        );
        // Không cần parse JSON, vì backend chỉ trả 200 OK
      },
      'Lỗi khi chấp nhận kết bạn',
    );
  }

  /// Từ chối yêu cầu kết bạn
  Future<void> rejectRequest({required SocialConnectionRequest request}) async {
    return _handleApi(
      () async {
        await _apiService.post(
          endpoint: ApiConstants.socialConnectionsRejectEndpoint,
          body: request.toJson(),
        );
        // Không cần parse JSON, vì backend chỉ trả 200 OK
      },
      'Lỗi khi từ chối kết bạn',
    );
  }

  /// Huỷ yêu cầu kết bạn
  Future<void> cancelRequest({required SocialConnectionRequest request}) async {
    return _handleApi(
      () async {
        await _apiService.post(
          endpoint: ApiConstants.socialConnectionsCancelEndpoint,
          body: request.toJson(),
        );
        // Không cần parse JSON, vì backend chỉ trả 200 OK
      },
      'Lỗi khi huỷ yêu cầu kết bạn',
    );
  }

  /// Chặn người dùng
  Future<void> blockUser({required SocialConnectionRequest request}) async {
    return _handleApi(
      () async {
        await _apiService.post(
          endpoint: ApiConstants.socialConnectionsBlockEndpoint,
          body: request.toJson(),
        );
        // Không cần parse JSON, vì backend chỉ trả 200 OK
      },
      'Lỗi khi chặn người dùng',
    );
  }

  /// Huỷ kết bạn
  Future<void> unfriend({required String userId1, required String userId2}) async {
    return _handleApi(
      () async {
        await _apiService.delete(
          endpoint: ApiConstants.socialConnectionsUnfriendEndpoint,
          queryParams: {
            'userId1': userId1,
            'userId2': userId2,
          }
        );
      },
      'Lỗi khi huỷ kết bạn',
    );
  }

  /// Lấy danh sách bạn bè
  Future<List<FriendModel>> getFriends({required String userId}) async {
    return _handleApi(
      () async {
        final endpoint =  ApiConstants.socialConnectionsFriendsByUserEndpoint.replaceFirst('{userId}', userId);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => FriendModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi lấy danh sách bạn bè',
        );
      },
      'Lỗi khi tải danh sách bạn bè',
    );
  }

  /// Lấy danh sách yêu cầu kết bạn
  Future<List<FriendRequestModel>> getRequests({required String userId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.socialConnectionsRequestsByUserEndpoint
            .replaceFirst('{userId}', userId);
        final res = await _apiService.get(endpoint: endpoint);

        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => FriendRequestModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi lấy danh sách yêu cầu kết bạn',
        );
      },
      'Lỗi khi tải danh sách yêu cầu kết bạn',
    );
  }

 /// Lấy danh sách yêu cầu đã gửi
  Future<List<SentRequestModel>> getSentRequests({required String userId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.socialConnectionsSentByUserEndpoint
            .replaceFirst('{userId}', userId);
        final res = await _apiService.get(endpoint: endpoint);

        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => SentRequestModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi lấy danh sách yêu cầu đã gửi',
        );
      },
      'Lỗi khi tải danh sách yêu cầu đã gửi',
    );
  }

  /// Chấp nhận tất cả yêu cầu
  Future<void> acceptAllRequests({required String userId}) async {
    return _handleApi(
      () async {
        await _apiService.post(
          endpoint: ApiConstants.socialConnectionsAcceptAllEndpoint,
          body: {'userId': userId},
        );
      },
      'Lỗi khi chấp nhận tất cả yêu cầu',
    );
  }

  /// Huỷ tất cả yêu cầu
  Future<void> cancelAllRequests({required String userId}) async {
    return _handleApi(
      () async {
        await _apiService.post(
          endpoint: ApiConstants.socialConnectionsCancelAllEndpoint,
          body: {'userId': userId},
        );
      },
      'Lỗi khi huỷ tất cả yêu cầu',
    );
  }

  /// Lấy trạng thái kết bạn
  Future<SocialConnectionModel> getStatus({
    required String currentUserId, 
    required String targetUserId,
  }) async {
    return _handleApi(
      () async {
        final res = await _apiService.get(
          endpoint: ApiConstants.socialConnectionsStatusEndpoint,
          queryParams: {
            'currentUserId': currentUserId,
            'targetUserId': targetUserId,
          },
        );

        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => SocialConnectionModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi lấy trạng thái kết bạn',
        );
      },
      'Lỗi khi lấy trạng thái kết bạn',
    );
  }
}