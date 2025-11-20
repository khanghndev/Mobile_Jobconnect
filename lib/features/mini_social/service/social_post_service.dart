import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/mini_social/model/social_post_model.dart';

class SocialPostService {
  final ApiService _apiService;

  SocialPostService() : _apiService = ApiService();

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

  //TODO: GET /api/SocialPosts - Lấy tất cả bài viết
  Future<List<SocialPostModel>> getAllPosts() async {
    return _handleApi(
      () async {
        final res = await _apiService.get(endpoint: ApiConstants.socialPostsEndpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => SocialPostModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi lấy tất cả bài viết',
        );
      },
      'Lỗi khi tải tất cả bài viết',
    );
  }

  //TODO: POST /api/SocialPosts - Tạo bài viết mới
  Future<SocialPostModel> createPost(SocialPostModel postModel) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.socialPostsEndpoint,
          body: postModel.toJson(),
        );

        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => SocialPostModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi tạo bài viết',
        );
      },
      'Lỗi khi tạo bài viết',
    );
  }

  //TODO: GET /api/SocialPosts/{id} - Lấy bài viết theo ID
  Future<SocialPostModel> getPostById({required String id}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.socialPostByIdEndpoint.replaceFirst('{id}', id);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => SocialPostModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi lấy bài viết theo ID',
        );
      },
      'Lỗi khi tải bài viết',
    );
  }

  //TODO: PUT /api/SocialPosts/{id} - Cập nhật bài viết
  Future<void> updatePost({
    required String id,
    required SocialPostModel post,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.socialPostByIdEndpoint.replaceFirst('{id}', id);
        final body = {
          'content': post.content,
          'imageUrl': post.imageUrl ?? '',
          'imageUrls': post.imageUrls ?? [],
          'videoUrl': post.videoUrl ?? '',
          'visibility': post.visibility,
          'postType': post.postType ?? '',
          'hashtags': post.hashtags ?? [],
        };
        await _apiService.put(endpoint: endpoint, body: body);
      },
      'Lỗi khi cập nhật bài viết',
    );
  }

  //TODO: DELETE /api/SocialPosts/{id} - Xóa bài viết
  Future<void> deletePost({required String id}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.socialPostByIdEndpoint.replaceFirst('{id}', id);
        await _apiService.delete(endpoint: endpoint);
      },
      'Lỗi khi xóa bài viết',
    );
  }

  // TODO: POST /api/SocialPosts/{id}/like - Thích bài viết
  Future<void> likePost({required String id, required String userId}) async {
    return _handleApi(
      () async {
        // nếu backend dùng FromQuery
        final endpoint = '${ApiConstants.socialPostLikeEndpoint.replaceFirst('{id}', id)}?userId=$userId';
        await _apiService.post(
          endpoint: endpoint,
          body: {},
        );
      },
      'Lỗi khi thích bài viết',
    );
  }

  // TODO: DELETE /api/SocialPosts/{id}/like - Bỏ thích bài viết
  Future<void> unlikePost({required String id, required String userId}) async {
    return _handleApi(
      () async {
        // nếu backend dùng FromQuery
        final endpoint = '${ApiConstants.socialPostLikeEndpoint.replaceFirst('{id}', id)}?userId=$userId';
        await _apiService.delete(
          endpoint: endpoint,
        );
      },
      'Lỗi khi bỏ thích bài viết',
    );
  }

  //TODO: GET /api/SocialPosts/{id}/likes - Lấy danh sách người thích bài viết
  Future<List<String>> getPostLikes({required String id}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.socialPostLikesEndpoint.replaceFirst('{id}', id);
        final res = await _apiService.get(endpoint: endpoint);
        return List<String>.from(res);
      },
      'Lỗi khi tải danh sách người thích bài viết',
    );
  }

  //TODO: GET /api/SocialPosts/feed/{userId} - Lấy feed bài viết của user
  Future<List<SocialPostModel>> getFeedUserId({required String userId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.socialPostsFeedByUserEndpoint.replaceFirst('{userId}', userId);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => SocialPostModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi lấy feed bài viết',
        );
      },
      'Lỗi khi tải feed bài viết',
    );
  }

  // TODO: POST /api/users/{id}/follow - Theo dõi người dùng
  Future<void> followUser({required String userId}) async {
    // return _handleApi(
    //   () async {
    //     final endpoint = ApiConstants.userFollowEndpoint.replaceFirst('{id}', userId);
    //     await _apiService.post(endpoint: endpoint, body: {});
    //   },
    //   'Lỗi khi theo dõi người dùng',
    // );
  }

  // TODO: DELETE /api/users/{id}/follow - Bỏ theo dõi người dùng
  Future<void> unfollowUser({required String userId}) async {
    // return _handleApi(
    //   () async {
    //     final endpoint = ApiConstants.userFollowEndpoint.replaceFirst('{id}', userId);
    //     await _apiService.delete(endpoint: endpoint);
    //   },
    //   'Lỗi khi bỏ theo dõi người dùng',
    // );
  }

  // TODO: POST /api/SocialPosts/{id}/save - Lưu bài viết
  Future<void> savePost({required String id, required String userId}) async {
    // return _handleApi(
    //   () async {
    //     final endpoint = ApiConstants.socialPostSaveEndpoint.replaceFirst('{id}', id);
    //     await _apiService.post(endpoint: endpoint, body: {});
    //   },
    //   'Lỗi khi lưu bài viết',
    // );
  }

  // TODO: DELETE /api/SocialPosts/{id}/save - Bỏ lưu bài viết
  Future<void> unsavePost({required String id, required String userId}) async {
    // return _handleApi(
    //   () async {
    //     final endpoint = ApiConstants.socialPostSaveEndpoint.replaceFirst('{id}', id);
    //     await _apiService.delete(endpoint: endpoint);
    //   },
    //   'Lỗi khi bỏ lưu bài viết',
    // );
  }

  // TODO: POST /api/SocialPosts/{id}/share - Chia sẻ bài viết
  Future<void> sharePost({required String id, required String userId, required String userOtherId}) async {
    // return _handleApi(
    //   () async {
    //     final endpoint = ApiConstants.socialPostShareEndpoint.replaceFirst('{id}', id);
    //     await _apiService.post(endpoint: endpoint, body: {});
    //   },
    //   'Lỗi khi chia sẻ bài viết',
    // );
  }

  Future<List<SocialPostModel>> getAllPostsOfGroup({
    required String groupId,
    required String currentUserId,
    int page = 1,
    int pageSize = 20,
  }) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.socialPostsInGroupByUserEndpoint
            .replaceFirst('{groupId}', groupId);

        final res = await _apiService.get(
          endpoint: endpoint,
          queryParams: {
            'currentUserId': currentUserId,
            'page': page.toString(),
            'pageSize': pageSize.toString(),
          },
        );

        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => SocialPostModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ khi lấy tất cả bài viết của nhóm',
        );
      },
      'Lỗi khi tải tất cả bài viết của nhóm',
    );
  }

}
