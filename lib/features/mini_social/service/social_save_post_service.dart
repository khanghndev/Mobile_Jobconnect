import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/mini_social/model/save_post_model.dart';

class SocialSavePostService {
  final ApiService _apiService;

  SocialSavePostService() : _apiService = ApiService();

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

  /// GET /api/SavedPosts/user/{idUser} - Lấy tất cả bài viết đã lưu của user
  Future<List<SavedPostModel>> getSavedPostsByUser(String idUser) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.savedPostsByUser.replaceFirst('{idUser}', idUser);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => SavedPostModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (get saved posts by user)',
        );
      },
      'Lỗi khi tải danh sách bài viết đã lưu',
    );
  }

  /// GET /api/SavedPosts/folders/{idUser} - Lấy danh sách folder của user (chỉ tên folder)
  Future<List<String>> getSavedPostsFolders(String idUser) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.savedPostsFolders.replaceFirst('{idUser}', idUser);
        final res = await _apiService.get(endpoint: endpoint);
        if (res is List) {
          return res.map((e) => e.toString()).toList();
        } else {
          throw Exception('Phản hồi không hợp lệ từ API (get saved folders)');
        }
      },
      'Lỗi khi tải danh sách folder',
    );
  }

  /// POST /api/SavedPosts - Tạo mới bài viết đã lưu
  Future<SavedPostModel> createSavedPost({
    required String idPost,
    required String idUser,
    required String folderName,
    required String note,
  }) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.createSavedPost,
          body: {
            "idPost": idPost,
            "idUser": idUser,
            "folderName": folderName,
            "note": note,
          },
        );
        return SavedPostModel.fromJson(res);
      },
      'Lỗi khi tạo bài viết đã lưu',
    );
  }

  /// PUT /api/SavedPosts - Cập nhật bài viết đã lưu
  Future<SavedPostModel> updateSavedPost({
    required String idPost,
    required String idUser,
    required String folderName,
    required String note,
  }) async {
    return _handleApi(
      () async {
        final res = await _apiService.put(
          endpoint: ApiConstants.updateSavedPost,
          body: {
            "idPost": idPost,
            "idUser": idUser,
            "folderName": folderName,
            "note": note,
          },
        );
        return SavedPostModel.fromJson(res);
      },
      'Lỗi khi cập nhật bài viết đã lưu',
    );
  }

  /// DELETE /api/SavedPosts - Xoá bài viết đã lưu theo idPost và idUser
  Future<void> deleteSavedPost({required String idPost, required String idUser}) async {
    return _handleApi(
      () async {
        // Chuyển từ body sang query parameters
        final endpoint = '${ApiConstants.deleteSavedPost}?idPost=$idPost&idUser=$idUser';
        await _apiService.delete(
          endpoint: endpoint,
        );
      },
      'Lỗi khi xoá bài viết đã lưu',
    );
  }
}
