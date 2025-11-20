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
  Future<List<SocialGroupsModel>> getJoinedGroups({required String userId}) async {
    return _handleApi(
      () async {
        final res = await _apiService.get(
          endpoint: ApiConstants.socialGroupsJoinedEndpoint,
          queryParams: {'userId': userId},
        );
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => SocialGroupsModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (get joined groups)',
        );
      },
      'Lỗi khi tải danh sách nhóm đã tham gia',
    );
  }

  /// TODO: GET /api/SocialGroups/pending - Lấy danh sách nhóm đang chờ tham gia
  Future<List<SocialGroupsModel>> getPendingGroups({required String userId}) async {
    return _handleApi(
      () async {
        final res = await _apiService.get(
          endpoint: ApiConstants.socialGroupsPendingEndpoint,
          queryParams: {'userId': userId},
        );
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => SocialGroupsModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (get pending groups)',
        );
      },
      'Lỗi khi tải danh sách nhóm đang chờ tham gia',
    );
  }

  // TODO: GET /api/SocialGroups/my-group - Lấy danh sách nhóm của tôi
  Future<List<SocialGroupsModel>> getMyGroups({required String userId, required String createdBy}) async {
    return _handleApi(
      () async {
        final res = await _apiService.get(
          endpoint: ApiConstants.socialGroupsEndpoint,
          queryParams: {
            'userId': userId,
            'createdBy': createdBy,
          },
        );
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => SocialGroupsModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (get my groups)',
        );
      },
      'Lỗi khi tải danh sách nhóm của tôi',
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

  /// PUT /api/SocialGroups/{id}?userId=xxx - Cập nhật nhóm
  Future<void> updateGroup({
    required String id,
    required String userId,
    required String groupName,
    required String description,
    required String privacy, // "private" hoặc "public"
    String? coverImageUrl,
    String? avatarUrl,
    bool? requirePostApproval,
    List<String>? tags,
  }) async {
    await _handleApi(
      () async {
        final endpoint =
            ApiConstants.socialGroupByIdEndpoint.replaceFirst('{id}', id);

        final body = {
          "groupName": groupName,
          "description": description,
          "privacy": privacy,
          "coverImageUrl": coverImageUrl ?? "",
          "avatarUrl": avatarUrl ?? "",
          "requirePostApproval": requirePostApproval ?? true,
          "tags": tags ?? [],
        };

        // PUT request với query param userId
        await _apiService.put(
          endpoint: endpoint,
          body: body,
          queryParams: {"userId": userId},
        );

        // không parse response vì backend trả về 200 OK không body
      },
      'Lỗi khi cập nhật nhóm',
    );
  }

  /// TODO: DELETE /api/SocialGroups/{id} - Xóa nhóm
  Future<void> deleteGroup({required String id, required String userId}) async {
    return _handleApi(
      () async {
        final endpoint = ApiConstants.socialGroupByIdEndpoint.replaceFirst('{id}', id);
        await _apiService.delete(
          endpoint: endpoint,
          queryParams: {
            'userId': userId
          }
        );
      },
      'Lỗi khi xóa nhóm',
    );
  }

    /// POST /api/SocialGroups/{id}/join - Tham gia nhóm
  Future<void> joinGroup({
    required String idGroup,
    required String userId,
  }) async {
    return _handleApi(
      () async {
        final endpoint =
            '${ApiConstants.socialGroupByIdEndpoint.replaceFirst('{id}', idGroup)}/join';

        // Gọi API POST với query param userId
        await _apiService.post(
          endpoint: endpoint,
          queryParams: {'userId': userId},
        );

        // backend trả về 200 OK không body
      },
      'Lỗi khi tham gia nhóm',
    );
  }

  /// POST /api/SocialGroups/{id}/leave - Rời nhóm
  Future<void> leaveGroup({
    required String idGroup,
    required String userId,
  }) async {
    return _handleApi(
      () async {
        final endpoint =
            ApiConstants.socialGroupLeaveEndpoint.replaceFirst('{id}', idGroup);

        // Gọi API POST với query param userId
        await _apiService.post(
          endpoint: endpoint,
          queryParams: {'userId': userId},
        );
      },
      'Lỗi khi rời nhóm',
    );
  }

  // GET /api/SocialGroups/{id}/members - Lấy danh sách thành viên nhóm
  Future<List<GroupMemberModel>> getGroupMembers({
    required String groupId,
  }) async {
    return _handleApi(
      () async {
        // endpoint với path param
        final endpoint =
            '${ApiConstants.socialGroupByIdEndpoint.replaceFirst('{id}', groupId)}/members';

        // GET request
        final res = await _apiService.get(endpoint: endpoint);

        // parse danh sách JSON thành List<GroupMemberModel>
        return ApiResponseParser.parseList(
          res: res,
          fromJson: (json) => GroupMemberModel.fromJson(json),
          errorMsg: 'Phản hồi không hợp lệ từ API (get group members)',
        );
      },
      'Lỗi khi tải thành viên nhóm',
    );
  }

  /// PUT /api/SocialGroups/{id}/members/role - Cập nhật vai trò thành viên
  Future<void> updateMemberRole({
    required String groupId,       // ID nhóm
    required String currentUserId, // ID người thao tác
    required String targetUserId,  // ID thành viên cần cập nhật
    required String role,          // Vai trò mới ("admin", "member", ...)
  }) async {
    return _handleApi(
      () async {
        final endpoint =
            '${ApiConstants.socialGroupByIdEndpoint.replaceFirst('{id}', groupId)}/members/role';

        // Body JSON theo BE
        final body = {
          "idGroup": groupId,
          "idUser": targetUserId,
          "roleInGroup": role,
        };

        await _apiService.put(
          endpoint: endpoint,
          body: body,
          queryParams: {"currentUserId": currentUserId}, // query param
        );

        // backend trả về 200 OK, không cần parse response
      },
      'Lỗi khi cập nhật vai trò thành viên',
    );
  }

  /// DELETE /api/SocialGroups/{id}/members/{userId}?currentUserId=xxx - Xóa thành viên
    Future<void> removeMember({
      required String groupId,        // ID nhóm
      required String targetUserId,   // ID thành viên cần xóa
      required String currentUserId,  // ID người thao tác
    }) async {
      return _handleApi(
        () async {
          final endpoint =
              '${ApiConstants.socialGroupByIdEndpoint.replaceFirst('{id}', groupId)}/members/$targetUserId';

          await _apiService.delete(
            endpoint: endpoint,
            queryParams: {'currentUserId': currentUserId}, // query param
          );

          // backend trả về 200 OK, không cần parse response
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

  /// POST /api/SocialGroups/{id}/members/{userId}/approve - Duyệt một thành viên
  Future<void> approveMember({
    required String groupId,
    required String targetUserId,
    required String currentUserId,
  }) async {
    return _handleApi(
      () async {
        final endpoint =
            '${ApiConstants.socialGroupByIdEndpoint.replaceFirst('{id}', groupId)}/members/$targetUserId/approve';

        await _apiService.post(
          endpoint: endpoint,
          queryParams: {"currentUserId": currentUserId},
        );
      },
      'Lỗi khi duyệt thành viên',
    );
  }

  /// POST /api/SocialGroups/{id}/members/approve - Duyệt một thành viên (body JSON)
  Future<void> approveMemberWithBody({
    required String groupId,       // ID nhóm (path param)
    required String currentUserId, // ID người thao tác (query param)
    required String targetUserId,  // ID thành viên cần approve (body)
  }) async {
    return _handleApi(
      () async {
        final endpoint =
            '${ApiConstants.socialGroupByIdEndpoint.replaceFirst('{id}', groupId)}/members/approve';

        final body = {
          "idUser": targetUserId,
          "action": "approve",
        };

        await _apiService.post(
          endpoint: endpoint,
          body: body,
          queryParams: {"currentUserId": currentUserId},
        );

        // Backend trả về 200 OK, không cần parse response
      },
      'Lỗi khi duyệt thành viên',
    );
  }

  /// POST /api/SocialGroups/{id}/members/{userId}/reject - Từ chối thành viên
  Future<void> rejectMember({
    required String groupId,
    required String targetUserId,
    required String currentUserId,
  }) async {
    return _handleApi(
      () async {
        final endpoint =
            '${ApiConstants.socialGroupByIdEndpoint.replaceFirst('{id}', groupId)}/members/$targetUserId/reject';

        await _apiService.post(
          endpoint: endpoint,
          queryParams: {"currentUserId": currentUserId},
        );
      },
      'Lỗi khi từ chối thành viên',
    );
  }

}
