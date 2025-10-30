import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/mini_social/model/group_reaction_model.dart';

class GroupReactionService {
  final ApiService _apiService;

  GroupReactionService() : _apiService = ApiService();

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

  //TODO: GET /api/GroupReactions - Lấy tất cả reaction
  Future<List<GroupReactionModel>> getAllReactions() async {
    return _handleApi(
      () async {
        final res = await _apiService.get(endpoint: ApiConstants.groupReactionsEndpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => GroupReactionModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (group reactions)',
        );
      },
      'Lỗi khi tải reactions',
    );
  }

  //TODO: POST /api/GroupReactions - Thêm reaction mới
  Future<GroupReactionModel> createReaction({required GroupReactionModel reaction}) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.groupReactionsEndpoint,
          body: reaction.toJson(),
        );
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => GroupReactionModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (tạo reaction)',
        );
      },
      'Lỗi khi tạo reaction',
    );
  }

  //TODO: GET /api/GroupReactions/{entityType}/{entityId} - Lấy reaction theo entity
  Future<List<GroupReactionModel>> getReactionsByEntity({
    required String entityType,
    required String entityId,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupReactionByEntityEndpoint
            .replaceFirst('{entityType}', entityType)
            .replaceFirst('{entityId}', entityId);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => GroupReactionModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (reactions theo entity)',
        );
      },
      'Lỗi khi tải reactions theo entity',
    );
  }

  //TODO: DELETE /api/GroupReactions/{entityType}/{entityId}/{userId} - Xóa reaction
  Future<void> deleteReaction({
    required String entityType,
    required String entityId,
    required String userId,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupReactionDeleteEndpoint
            .replaceFirst('{entityType}', entityType)
            .replaceFirst('{entityId}', entityId)
            .replaceFirst('{userId}', userId);
        await _apiService.delete(endpoint: endpoint);
      },
      'Lỗi khi xóa reaction',
    );
  }
}