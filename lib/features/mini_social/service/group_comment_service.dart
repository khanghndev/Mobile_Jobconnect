import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/mini_social/model/group_comment_model.dart';

class GroupCommentService {
  final ApiService _apiService;

  GroupCommentService() : _apiService = ApiService();

  /// Helper chung để wrap API call và bắt lỗi unknown
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

  /// Lấy danh sách comment nhóm
  Future<List<GroupCommentModel>> getGroupComments() async {
    return _handleApi(
      () async {
        final res = await _apiService.get(endpoint: ApiConstants.groupCommentsEndpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => GroupCommentModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (group comments)',
        );
      },
      'Lỗi không xác định khi tải group comments',
    );
  }

  /// Lấy chi tiết comment theo ID
  Future<GroupCommentModel> getGroupCommentById({required String id}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupCommentByIdEndpoint.replaceFirst('{id}', id);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => GroupCommentModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (chi tiết comment)',
        );
      },
      'Lỗi khi tải chi tiết comment',
    );
  }

  /// Thêm comment mới
  Future<GroupCommentModel> createGroupComment({required GroupCommentModel comment}) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.groupCommentsEndpoint,
          body: comment.toJson(),
        );
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => GroupCommentModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (tạo comment)',
        );
      },
      'Lỗi khi tạo comment mới',
    );
  }

  /// Cập nhật comment theo ID và model
  Future<GroupCommentModel> updateGroupComment({
    required String id,
    required GroupCommentModel comment,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupCommentByIdEndpoint.replaceFirst('{id}', id);
        final res = await _apiService.put(
          endpoint: endpoint,
          body: comment.toJson(),
        );
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => GroupCommentModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (cập nhật comment)',
        );
      },
      'Lỗi khi cập nhật comment',
    );
  }

  /// Xóa comment theo ID
  Future<void> deleteGroupComment({required String id}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupCommentByIdEndpoint.replaceFirst('{id}', id);
        await _apiService.delete(endpoint: endpoint);
      },
      'Lỗi khi xóa comment',
    );
  }
}