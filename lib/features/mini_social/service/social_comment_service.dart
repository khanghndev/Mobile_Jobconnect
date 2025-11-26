import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/mini_social/model/social_comment_model.dart';

class SocialCommentService {
  final ApiService _apiService;

  SocialCommentService() : _apiService = ApiService();

  Future<T> _handleApi<T>(
    Future<T> Function() action,
    String errorMsg,
  ) async {
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

  //   GET /api/SocialComments/by-post/{postId} - Lấy danh sách comment theo post
  Future<List<SocialCommentModel>> getCommentsByPost({required String postId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.socialCommentsByPostEndpoint.replaceFirst('{postId}', postId);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => SocialCommentModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (social comments theo post)',
        );
      },
      'Lỗi khi tải social comments theo post',
    );
  }

  //   GET /api/SocialComments/replies/{parentId} - Lấy danh sách replies theo parent comment
  Future<List<SocialCommentModel>> getRepliesByParent({required String parentId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.socialCommentsRepliesEndpoint.replaceFirst('{parentId}', parentId);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => SocialCommentModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (replies social comments)',
        );
      },
      'Lỗi khi tải replies social comments',
    );
  }

  //   POST /api/SocialComments - Tạo comment mới
  Future<SocialCommentModel> createComment({required SocialCommentModel comment}) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.socialCommentEndpoint,
          body: comment.toJson(),
        );
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => SocialCommentModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (tạo social comment)',
        );
      },
      'Lỗi khi tạo social comment',
    );
  }

  //   DELETE /api/SocialComments/{id} - Xóa comment
  Future<void> deleteComment({required String id}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.socialCommentByIdEndpoint.replaceFirst('{id}', id);
        await _apiService.delete(endpoint: endpoint);
      },
      'Lỗi khi xóa social comment',
    );
  }
}