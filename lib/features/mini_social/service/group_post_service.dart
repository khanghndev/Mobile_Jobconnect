import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/mini_social/model/group_post_model.dart';
import 'package:job_connect/features/mini_social/model/group_reaction_model.dart';

class GroupPostService {
  final ApiService _apiService;

  GroupPostService() : _apiService = ApiService();

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

  //  GET /api/GroupPosts - Lấy tất cả bài viết nhóm
  Future<List<GroupPostModel>> getGroupPosts() async {
    return _handleApi(
      () async {
        final res = await _apiService.get(endpoint: ApiConstants.groupPostsEndpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => GroupPostModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (get all group posts)',
        );
      },
      'Lỗi khi tải danh sách group posts',
    );
  }

  //  POST /api/GroupPosts - Tạo bài viết mới
  Future<GroupPostModel> createGroupPost({required GroupPostModel post}) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.groupPostsEndpoint,
          body: post.toJson(),
        );
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => GroupPostModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (tạo group post)',
        );
      },
      'Lỗi khi tạo group post mới',
    );
  }

  //  GET /api/GroupPosts/{id} - Lấy chi tiết bài viết
  Future<GroupPostModel> getGroupPostById({required String id}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupPostByIdEndpoint.replaceFirst('{id}', id);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => GroupPostModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (group post by id)',
        );
      },
      'Lỗi khi tải chi tiết group post',
    );
  }

  //  PUT /api/GroupPosts/{id} - Cập nhật bài viết
  Future<GroupPostModel> updateGroupPost({required GroupPostModel post}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupPostByIdEndpoint.replaceFirst('{id}', post.idPost);
        final res = await _apiService.put(endpoint: endpoint, body: post.toJson());
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => GroupPostModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (update group post)',
        );
      },
      'Lỗi khi cập nhật group post',
    );
  }

  //  DELETE /api/GroupPosts/{id} - Xóa nhóm
  Future<void> deleteGroupPost({required String id}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupPostByIdEndpoint.replaceFirst('{id}', id);
        await _apiService.delete(endpoint: endpoint);
      },
      'Lỗi khi xóa group post',
    );
  }

  //  GET /api/GroupPosts/group/{groupId} - Lấy danh sách bài viết theo group
  Future<List<GroupPostModel>> getPostsByGroup({required String groupId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupPostsByGroupEndpoint.replaceFirst('{groupId}', groupId);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => GroupPostModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (posts by group)',
        );
      },
      'Lỗi khi tải bài viết theo group',
    );
  }

  //  POST /api/GroupPosts/{id}/reaction - Thêm reaction vào bài viết
  Future<void> addReaction({required String id, required GroupReactionModel reaction}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupPostReactionEndpoint.replaceFirst('{id}', id);
        await _apiService.post(endpoint: endpoint, body: reaction.toJson());
      },
      'Lỗi khi thêm reaction vào post',
    );
  }

  //  DELETE /api/GroupPosts/{id}/reaction - Xóa reaction khỏi bài viết
  Future<void> removeReaction({required String id}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupPostReactionEndpoint.replaceFirst('{id}', id);
        await _apiService.delete(endpoint: endpoint);
      },
      'Lỗi khi xóa reaction khỏi post',
    );
  }

  //  GET /api/GroupPosts/{id}/reactions - Lấy danh sách reaction của bài viết
  Future<List<GroupReactionModel>> getReactionsByPostId({required String id}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupPostReactionsEndpoint.replaceFirst('{id}', id);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => GroupReactionModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (reactions of post)',
        );
      },
      'Lỗi khi tải reactions của bài viết',
    );
  }

  //  GET /api/GroupPosts/pending/{groupId} - Lấy danh sách bài viết chờ duyệt
  Future<List<GroupPostModel>> getPendingPosts({required String groupId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupPostsPendingEndpoint.replaceFirst('{groupId}', groupId);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => GroupPostModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (pending posts)',
        );
      },
      'Lỗi khi tải bài viết chờ duyệt',
    );
  }

  //  POST /api/GroupPosts/approve - Duyệt bài viết
  Future<void> approvePost({required String idPost}) async {
    return _handleApi(
      () async {
        await _apiService.post(
          endpoint: ApiConstants.groupPostApproveEndpoint,
          body: {'idPost': idPost},
        );
      },
      'Lỗi khi duyệt bài viết',
    );
  }

  //  GET /api/GroupPosts/stats/{groupId} - Lấy thống kê bài viết nhóm
  Future<Map<String, dynamic>> getGroupPostStats({required String groupId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupPostStatsEndpoint.replaceFirst('{groupId}', groupId);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseMap(
          res: res,
          errorMsg: 'Phản hồi không hợp lệ từ API (group stats)',
        );
      },
      'Lỗi khi tải thống kê bài viết nhóm',
    );
  }

  //  GET /api/GroupPosts/notifications/{userId} - Lấy thông báo bài viết
  Future<List<GroupPostModel>> getGroupPostNotifications({required String userId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.groupPostNotificationsEndpoint.replaceFirst('{userId}', userId);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => GroupPostModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (post notifications)',
        );
      },
      'Lỗi khi tải thông báo group posts',
    );
  }
}