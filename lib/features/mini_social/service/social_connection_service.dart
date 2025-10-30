import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
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

  /// TODO: POST /api/SocialConnections/request - Gửi yêu cầu kết bạn
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
          errorMsg: 'Phản hồi không hợp lệ từ API (send request)',
        );
      },
      'Lỗi khi gửi kết bạn',
    );
  }

  /// TODO: POST /api/SocialConnections/accept - Chấp nhận yêu cầu kết bạn
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
          errorMsg: 'Phản hồi không hợp lệ từ API (accept request)',
        );
      },
      'Lỗi khi chấp nhận kết bạn',
    );
  }

  /// TODO: POST /api/SocialConnections/block - Chặn người dùng
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
          errorMsg: 'Phản hồi không hợp lệ từ API (block user)',
        );
      },
      'Lỗi khi block user',
    );
  }

  /// TODO: DELETE /api/SocialConnections/unfriend - Huỷ kết bạn
  Future<void> unfriend({required SocialConnectionRequest request}) async {
    return _handleApi(
      () async {
        await _apiService.delete(
          endpoint: ApiConstants.socialConnectionsUnfriendEndpoint,
          body: request.toJson(),
        );
      },
      'Lỗi khi huỷ kết bạn',
    );
  }

  /// TODO: GET /api/SocialConnections/friends/{userId} - Lấy danh sách bạn bè của user
  Future<List<SocialConnectionModel>> getFriends({required String userId}) async {
    return _handleApi(
      () async {
        final endpoint =
            ApiConstants.socialConnectionsFriendsByUserEndpoint.replaceFirst('{userId}', userId);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => SocialConnectionModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (get friends)',
        );
      },
      'Lỗi khi tải danh sách bạn bè',
    );
  }

  /// TODO: GET /api/SocialConnections/requests/{userId} - Lấy danh sách yêu cầu kết bạn của user
  Future<List<SocialConnectionModel>> getRequests({required String userId}) async {
    return _handleApi(
      () async {
        final endpoint =
            ApiConstants.socialConnectionsRequestsByUserEndpoint.replaceFirst('{userId}', userId);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => SocialConnectionModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (get requests)',
        );
      },
      'Lỗi khi tải danh sách yêu cầu kết bạn',
    );
  }
}
