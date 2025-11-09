import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/mini_social/model/friend_model.dart';
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
  Future<SocialConnectionModel> sendRequest({required SocialConnectionRequest request}) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.socialConnectionsRequestEndpoint,
          body: request.toJson(),
        );
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => SocialConnectionModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi gửi kết bạn',
        );
      },
      'Lỗi khi gửi kết bạn',
    );
  }

  /// Chấp nhận yêu cầu kết bạn
  Future<SocialConnectionModel> acceptRequest({required SocialConnectionRequest request}) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.socialConnectionsAcceptEndpoint,
          body: request.toJson(),
        );
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => SocialConnectionModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi chấp nhận kết bạn',
        );
      },
      'Lỗi khi chấp nhận kết bạn',
    );
  }

  /// Từ chối yêu cầu kết bạn
  Future<SocialConnectionModel> rejectRequest({required SocialConnectionRequest request}) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.socialConnectionsRejectEndpoint,
          body: request.toJson(),
        );
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => SocialConnectionModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi từ chối kết bạn',
        );
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
      },
      'Lỗi khi huỷ yêu cầu kết bạn',
    );
  }

  /// Chặn người dùng
  Future<SocialConnectionModel> blockUser({required SocialConnectionRequest request}) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.socialConnectionsBlockEndpoint,
          body: request.toJson(),
        );
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => SocialConnectionModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi chặn người dùng',
        );
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
          body: {
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
  Future<List<String>> getRequests({required String userId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.socialConnectionsRequestsByUserEndpoint.replaceFirst('{userId}', userId);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => json.toString(),
          errorMsg: 'Phản hồi không hợp lệ khi lấy danh sách yêu cầu kết bạn',
        );
      },
      'Lỗi khi tải danh sách yêu cầu kết bạn',
    );
  }

  /// Lấy danh sách yêu cầu đã gửi
  Future<List<String>> getSentRequests({required String userId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.socialConnectionsSentByUserEndpoint.replaceFirst('{userId}', userId);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => json.toString(),
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
  Future<SocialConnectionModel> getStatus({required SocialConnectionRequest request}) async {
    return _handleApi(
      () async {
        final res = await _apiService.get(
          endpoint: ApiConstants.socialConnectionsStatusEndpoint,
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