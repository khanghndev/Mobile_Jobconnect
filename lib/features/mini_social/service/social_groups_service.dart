import 'package:job_connect/api/api_response_parser.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/config/enum/server_exception_type.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/mini_social/model/group_stats_model.dart';
import 'package:job_connect/features/mini_social/model/social_groups_model.dart';
import 'package:job_connect/features/mini_social/model/group_member_model.dart';

class SocialGroupsService {
  final ApiService _apiService;

  SocialGroupsService() : _apiService = ApiService();

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

  /// TODO: GET /api/SocialGroups - Lấy danh sách tất cả nhóm
  Future<List<SocialGroupsModel>> getAllGroups() async {
    return _handleApi(
      () async {
        final res = await _apiService.get(endpoint: ApiConstants.socialGroupsEndpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => SocialGroupsModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (get all groups)',
        );
      },
      'Lỗi khi tải danh sách nhóm',
    );
  }

  /// TODO: GET /api/SocialGroups/joined - Lấy danh sách nhóm đã tham gia
  Future<List<SocialGroupsModel>> getJoinedGroups() async {
    return _handleApi(
      () async {
        final res = await _apiService.get(endpoint: ApiConstants.socialGroupsJoinedEndpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => SocialGroupsModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (get joined groups)',
        );
      },
      'Lỗi khi tải danh sách nhóm đã tham gia',
    );
  }

  /// TODO: GET /api/SocialGroups/search?q=keyword - Tìm kiếm nhóm
  Future<List<SocialGroupsModel>> searchGroups({required String keyword}) async {
    return _handleApi(
      () async {
        final endpoint = '${ApiConstants.socialGroupsSearchEndpoint}?q=$keyword';
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => SocialGroupsModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (search groups)',
        );
      },
      'Lỗi khi tìm kiếm nhóm',
    );
  }

  /// TODO: GET /api/SocialGroups/{id} - Lấy thông tin nhóm theo id
  Future<SocialGroupsModel> getGroupById({required String id}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.socialGroupByIdEndpoint.replaceFirst('{id}', id);
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => SocialGroupsModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (get group by id)',
        );
      },
      'Lỗi khi tải thông tin nhóm',
    );
  }

  /// TODO: POST /api/SocialGroups - Tạo nhóm
  Future<SocialGroupsModel> createGroup({required SocialGroupsModel group}) async {
    return _handleApi(
      () async {
        final res = await _apiService.post(
          endpoint: ApiConstants.socialGroupsEndpoint,
          body: group.toJson(),
        );
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => SocialGroupsModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (create group)',
        );
      },
      'Lỗi khi tạo nhóm',
    );
  }

  /// TODO: PUT /api/SocialGroups/{id} - Cập nhật nhóm
  Future<SocialGroupsModel> updateGroup({required String id, required SocialGroupsModel group}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.socialGroupByIdEndpoint.replaceFirst('{id}', id);
        final res = await _apiService.put(
          endpoint: endpoint,
          body: group.toJson(),
        );
        return ApiResponseParser.parseObject(
          res: res,
          fromJson: (json) => SocialGroupsModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (update group)',
        );
      },
      'Lỗi khi cập nhật nhóm',
    );
  }

  /// TODO: DELETE /api/SocialGroups/{id} - Xóa nhóm
  Future<void> deleteGroup({required String id}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.socialGroupByIdEndpoint.replaceFirst('{id}', id);
        await _apiService.delete(endpoint: endpoint);
      },
      'Lỗi khi xóa nhóm',
    );
  }

  /// TODO: POST /api/SocialGroups/{id}/join - Tham gia nhóm
  Future<void> joinGroup({required String id}) async {
    return _handleApi(
      () async {
        final endpoint = '${ApiConstants.socialGroupByIdEndpoint.replaceFirst('{id}', id)}/join';
        await _apiService.post(endpoint: endpoint, body: {});
      },
      'Lỗi khi tham gia nhóm',
    );
  }

  /// TODO: POST /api/SocialGroups/{id}/leave - Rời nhóm
  Future<void> leaveGroup({required String id}) async {
    return _handleApi(
      () async {
        final endpoint = '${ApiConstants.socialGroupByIdEndpoint.replaceFirst('{id}', id)}/leave';
        await _apiService.post(endpoint: endpoint, body: {});
      },
      'Lỗi khi rời nhóm',
    );
  }

  /// TODO: GET /api/SocialGroups/{id}/members - Lấy danh sách thành viên nhóm
  Future<List<GroupMemberModel>> getGroupMembers({required String groupId}) async {
    return _handleApi(
      () async {
        final endpoint = '${ApiConstants.socialGroupByIdEndpoint.replaceFirst('{id}', groupId)}/members';
        final res = await _apiService.get(endpoint: endpoint);
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => GroupMemberModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (get group members)',
        );
      },
      'Lỗi khi tải thành viên nhóm',
    );
  }

  /// TODO: PUT /api/SocialGroups/{id}/members/role - Cập nhật vai trò thành viên
  Future<void> updateMemberRole({
    required String groupId,
    required String userId,
    required String role,
  }) async {
    return _handleApi(
      () async {
        final endpoint = '${ApiConstants.socialGroupByIdEndpoint.replaceFirst('{id}', groupId)}/members/role';
        await _apiService.put(
          endpoint: endpoint, 
          body: GroupMemberModel(
            idGroup: groupId,
            idUser: userId,
            role: role,
            joinedAt: DateTime.now(), 
          ).toJson(),
        );
      },
      'Lỗi khi cập nhật vai trò thành viên',
    );
  }

  /// TODO: DELETE /api/SocialGroups/{id}/members/{userId} - Xóa thành viên
  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) async {
    return _handleApi(
      () async {
        final endpoint = '${ApiConstants.socialGroupByIdEndpoint.replaceFirst('{id}', groupId)}/members/$userId';
        await _apiService.delete(endpoint: endpoint);
      },
      'Lỗi khi xóa thành viên',
    );
  }

  /// TODO: GET /api/SocialGroups/tags - Lấy danh sách tags
  Future<List<String>> getGroupTags() async {
    return _handleApi(
      () async {
        final res = await _apiService.get(endpoint: ApiConstants.socialGroupsTagsEndpoint);
        return List<String>.from(res);
      },
      'Lỗi khi tải tags nhóm',
    );
  }

  /// TODO: GET /api/SocialGroups/stats - Lấy thống kê nhóm
  Future<GroupStatsModel> getGroupStats() async {
    return _handleApi(
      () async {
        final res = await _apiService.get(endpoint: ApiConstants.socialGroupsStatsEndpoint);
        return GroupStatsModel.fromJson(Map<String, dynamic>.from(res));
      },
      'Lỗi khi tải thống kê nhóm',
    );
  }
}
