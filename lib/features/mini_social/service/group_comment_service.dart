import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/mini_social/model/group_comment_model.dart';
import 'package:job_connect/features/mini_social/model/group_reaction_model.dart';

class GroupCommentService {
  final ApiService _apiService;

  GroupCommentService() : _apiService = ApiService();

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

  //  GET /api/GroupComments - Lấy danh sách tất cả comment nhóm
  Future<List<GroupCommentModel>> getGroupComments() async {
    return _handleApi(
      () async {
        final res = await _apiService.get(endpoint: ApiConstants.groupCommentsEndpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: GroupCommentModel.fromJson,
          errorMsg: 'Phản hồi không hợp lệ từ API (group comments)',
        );
      },
      'Lỗi không xác định khi tải group comments',
    );
  }

  //  POST /api/GroupComments - Tạo comment mới
  Future<GroupCommentModel> createGroupComment({
    required GroupCommentModel comment,
  }) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.groupCommentsEndpoint,
          body: comment.toJson(),
        );
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: GroupCommentModel.fromJson,
          errorMsg: 'Phản hồi không hợp lệ từ API (tạo comment)',
        );
      },
      'Lỗi khi tạo comment mới',
    );
  }

  //  GET /api/GroupComments/post/{postId} - Lấy danh sách comment theo postId
  Future<List<GroupCommentModel>> getGroupCommentsByPost({
    required String postId,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupCommentsByPostEndpoint.replaceFirst('{postId}', postId);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: GroupCommentModel.fromJson,
          errorMsg: 'Phản hồi không hợp lệ từ API (group comments theo bài viết)',
        );
      },
      'Lỗi khi tải group comments theo bài viết',
    );
  }

  //  GET /api/GroupComments/{id}/replies - Lấy danh sách reply theo comment ID
  Future<List<GroupCommentModel>> getRepliesByCommentId({
    required String id,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupCommentRepliesEndpoint.replaceFirst('{id}', id);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: GroupCommentModel.fromJson,
          errorMsg: 'Phản hồi không hợp lệ từ API (replies)',
        );
      },
      'Lỗi khi tải replies',
    );
  }

  //  GET /api/GroupComments/{id} - Lấy chi tiết comment theo ID
  Future<GroupCommentModel> getGroupCommentById({
    required String id,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupCommentByIdEndpoint.replaceFirst('{id}', id);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: GroupCommentModel.fromJson,
          errorMsg: 'Phản hồi không hợp lệ từ API (chi tiết comment)',
        );
      },
      'Lỗi khi tải chi tiết comment',
    );
  }

  //  PUT /api/GroupComments/{id} - Cập nhật comment
  Future<GroupCommentModel> updateGroupComment({
    required GroupCommentModel comment,
  }) async {
    if (comment.idComment.isEmpty) {
      throw ServerException(
        err: 'Thiếu idComment trong model khi cập nhật comment',
        type: ServerExceptionType.invalidData,
      );
    }

    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupCommentByIdEndpoint.replaceFirst('{id}', comment.idComment);
        final res = await _apiService.put(
          endpoint: endpoint,
          body: comment.toJson(),
        );
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: GroupCommentModel.fromJson,
          errorMsg: 'Phản hồi không hợp lệ từ API (cập nhật comment)',
        );
      },
      'Lỗi khi cập nhật comment',
    );
  }

  //  DELETE /api/GroupComments/{id} - Xóa comment
  Future<void> deleteGroupComment({
    required String id,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupCommentByIdEndpoint.replaceFirst('{id}', id);
        await _apiService.delete(endpoint: endpoint);
      },
      'Lỗi khi xóa comment',
    );
  }

  //  POST /api/GroupComments/{id}/reaction - Thêm reaction vào comment
  Future<void> addReaction({
    required String id,
    required GroupReactionModel reaction,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupCommentReactionEndpoint.replaceFirst('{id}', id);
        await _apiService.post(endpoint: endpoint, body: reaction.toJson());
      },
      'Lỗi khi thêm reaction vào comment',
    );
  }

  //  DELETE /api/GroupComments/{id}/reaction - Xóa reaction khỏi comment
  Future<void> removeReaction({
    required String id,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupCommentReactionEndpoint.replaceFirst('{id}', id);
        await _apiService.delete(endpoint: endpoint);
      },
      'Lỗi khi xóa reaction khỏi comment',
    );
  }

  //  GET /api/GroupComments/{id}/reactions - Lấy danh sách reaction của comment
  Future<List<GroupReactionModel>> getReactionsByCommentId({
    required String id,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupCommentReactionsEndpoint.replaceFirst('{id}', id);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: GroupReactionModel.fromJson,
          errorMsg: 'Phản hồi không hợp lệ từ API (reactions)',
        );
      },
      'Lỗi khi tải reactions của comment',
    );
  }
}