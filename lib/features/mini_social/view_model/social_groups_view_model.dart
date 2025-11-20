import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:job_connect/appwrite/storage_appwrite_service.dart';
import 'package:job_connect/config/error/server_exception.dart';
import 'package:job_connect/features/mini_social/model/social_groups_model.dart';
import 'package:job_connect/features/mini_social/model/group_member_model.dart';
import 'package:job_connect/features/mini_social/model/group_stats_model.dart';
import 'package:job_connect/features/mini_social/service/social_groups_service.dart';

class SocialGroupsViewModel extends ChangeNotifier {
  final SocialGroupsService _socialGroupsService = SocialGroupsService();
  final StorageAppwriteService _storageAppwriteService = StorageAppwriteService();

  // STATE
  bool _isLoading = false;
  bool _isSuccess = false;
  String? _errorMessage;

  List<SocialGroupsModel> _allGroups = [];
  List<SocialGroupsModel> _joinedGroups = [];
  List<SocialGroupsModel> _pendingGroups = [];
  List<SocialGroupsModel> _notJoinedGroups = [];
  List<SocialGroupsModel> _myGroups = [];
  List<GroupMemberModel> _members = [];
  GroupStatsModel? _stats;
  List<String> _tags = [];
  SocialGroupsModel? _selectedGroup;

  // GETTERS
  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  String? get errorMessage => _errorMessage;
  List<SocialGroupsModel> get allGroups => _allGroups;
  List<SocialGroupsModel> get joinedGroups => _joinedGroups;
  List<SocialGroupsModel> get pendingGroups => _pendingGroups;
  List<SocialGroupsModel> get notJoinedGroups => _notJoinedGroups;
  List<SocialGroupsModel> get myGroups => _myGroups;
  List<GroupMemberModel> get members => _members;
  GroupStatsModel? get stats => _stats;
  List<String> get tags => _tags;
  SocialGroupsModel? get selectedGroup => _selectedGroup;

  // PRIVATE SET STATE
  void _setState({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<SocialGroupsModel>? allGroups,
    List<SocialGroupsModel>? joinedGroups,
    List<SocialGroupsModel>? pendingGroups,
    List<SocialGroupsModel>? notJoinedGroups,
    List<SocialGroupsModel>? myGroups,
    List<GroupMemberModel>? members,
    GroupStatsModel? stats,
    List<String>? tags,
    SocialGroupsModel? selectedGroup,
  }) {
    _isLoading = isLoading ?? _isLoading;
    _isSuccess = isSuccess ?? _isSuccess;
    _errorMessage = errorMessage;
    _allGroups = allGroups ?? _allGroups;
    _joinedGroups = joinedGroups ?? _joinedGroups;
    _pendingGroups = pendingGroups ?? _pendingGroups;
    _notJoinedGroups = notJoinedGroups ?? _notJoinedGroups;
    _myGroups = myGroups ?? _myGroups;
    _members = members ?? _members;
    _stats = stats ?? _stats;
    _tags = tags ?? _tags;
    _selectedGroup = selectedGroup ?? _selectedGroup;
    notifyListeners();
  }

  // API CALL HANDLER
  Future<void> _handleApiCall<T>({
    required Future<T> Function() apiCall,
    void Function(T)? onSuccess,
  }) async {
    _setState(isLoading: true, isSuccess: false, errorMessage: null);
    try {
      final result = await apiCall();
      if (onSuccess != null) onSuccess(result);
      _setState(isLoading: false, isSuccess: true);
    } on ServerException catch (e) {
      _setState(isLoading: false, errorMessage: e.err, isSuccess: false);
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString(), isSuccess: false);
    }
  }

  /// Kiểm tra user đã tham gia nhóm chưa
  bool isUserMember({required String groupId}) {
    return _joinedGroups.any((group) => group.idGroup == groupId);
  }

  /// Kiểm tra user đang chờ duyệt tham gia nhóm
  bool isUserPending({required String groupId}) {
    return _pendingGroups.any((group) => group.idGroup == groupId);
  }

  /// Upload ảnh chính và ảnh bìa nhóm
  Future<List<String>> uploadMainAndCoverImages({
    required String mainImagePath,
    required String coverImagePath,
  }) async {
    final bucketId = dotenv.env['APPWRITE_BUCKET_ID_IMAGE'] ?? '';
    _setState(isLoading: true, errorMessage: null);

    try {
      final urls = <String>[];

      if (mainImagePath.isNotEmpty) {
        final mainFile = File(mainImagePath);
        final uploadedMain = await _storageAppwriteService.uploadFile(mainFile, bucketId: bucketId);
        final mainUrl = _storageAppwriteService.getFileViewUrl(uploadedMain.$id, bucketId: bucketId);
        urls.add(mainUrl);
      }

      if (coverImagePath.isNotEmpty) {
        final coverFile = File(coverImagePath);
        final uploadedCover = await _storageAppwriteService.uploadFile(coverFile, bucketId: bucketId);
        final coverUrl = _storageAppwriteService.getFileViewUrl(uploadedCover.$id, bucketId: bucketId);
        urls.add(coverUrl);
      }

      _setState(isLoading: false);
      return urls;
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  // ====================== API WRAPPERS ======================

  Future<void> getGroupsWithJoinStatus({required String userId}) async {
    _setState(isLoading: true, isSuccess: false, errorMessage: null);
    try {
      final allGroups = await _socialGroupsService.getAllGroups();
      final joinedGroups = await _socialGroupsService.getJoinedGroups(userId: userId);
      final pendingGroups = await _socialGroupsService.getPendingGroups(userId: userId);
      final myGroups = await _socialGroupsService.getMyGroups(userId: userId, createdBy: userId);

      // Loại bỏ các nhóm do user tạo khỏi joinedGroups
      final filteredJoinedGroups = joinedGroups.where((g) => !myGroups.any((my) => my.idGroup == g.idGroup)).toList();

      final joinedIds = filteredJoinedGroups.map((g) => g.idGroup).toSet();
      final pendingIds = pendingGroups.map((g) => g.idGroup).toSet();

      final notJoinedGroups = allGroups
          .where((g) => !joinedIds.contains(g.idGroup) && !pendingIds.contains(g.idGroup) && !myGroups.any((my) => my.idGroup == g.idGroup))
          .toList();

      _setState(
        isLoading: false,
        isSuccess: true,
        allGroups: allGroups,
        joinedGroups: filteredJoinedGroups,
        pendingGroups: pendingGroups,
        notJoinedGroups: notJoinedGroups,
        myGroups: myGroups,
      );
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString(), isSuccess: false);
    }
  }

  Future<void> getAllGroups() async {
    await _handleApiCall<List<SocialGroupsModel>>(
      apiCall: _socialGroupsService.getAllGroups,
      onSuccess: (data) => _setState(allGroups: data),
    );
  }

  Future<void> getJoinedGroups({required String userId}) async {
    await _handleApiCall<List<SocialGroupsModel>>(
      apiCall: () => _socialGroupsService.getJoinedGroups(userId: userId),
      onSuccess: (data) => _setState(joinedGroups: data),
    );
  }

  Future<void> getPendingGroups({required String userId}) async {
    await _handleApiCall<List<SocialGroupsModel>>(
      apiCall: () => _socialGroupsService.getPendingGroups(userId: userId),
      onSuccess: (data) => _setState(pendingGroups: data),
    );
  }

  Future<void> getMyGroups({required String userId, required String createdBy}) async {
    await _handleApiCall<List<SocialGroupsModel>>(
      apiCall: () => _socialGroupsService.getMyGroups(userId: userId, createdBy: createdBy),
      onSuccess: (data) => _setState(myGroups: data),
    );
  }

  Future<void> searchGroups(String keyword) async {
    await _handleApiCall<List<SocialGroupsModel>>(
      apiCall: () => _socialGroupsService.searchGroups(keyword: keyword),
      onSuccess: (data) => _setState(allGroups: data),
    );
  }

  Future<void> getGroupById({required String id}) async {
    await _handleApiCall<SocialGroupsModel>(
      apiCall: () => _socialGroupsService.getGroupById(id: id),
      onSuccess: (data) => _setState(selectedGroup: data),
    );
  }

  Future<SocialGroupsModel?> createGroup({
    required SocialGroupsModel group,
    required String userId,
  }) async {
    SocialGroupsModel? createdGroup;

    await _handleApiCall<SocialGroupsModel>(
      apiCall: () => _socialGroupsService.createGroup(group: group),
      onSuccess: (data) {
        createdGroup = data;

        final updatedAllGroups = List<SocialGroupsModel>.from(_allGroups)..add(data);

        List<SocialGroupsModel> updatedMyGroups = List<SocialGroupsModel>.from(_myGroups);
        List<SocialGroupsModel> updatedNotJoinedGroups = List<SocialGroupsModel>.from(_notJoinedGroups);

        if (data.createdBy == userId) {
          // Nếu user tạo nhóm -> thêm vào myGroups, không thêm vào notJoinedGroups
          updatedMyGroups.add(data);
        } else {
          // Nếu user không tạo -> nhóm là notJoinedGroups
          updatedNotJoinedGroups.add(data);
        }

        _setState(
          allGroups: updatedAllGroups,
          myGroups: updatedMyGroups,
          notJoinedGroups: updatedNotJoinedGroups,
        );
      },
    );

    return createdGroup;
  }

  Future<void> updateGroup({
    required String id,
    required String userId,
    required String groupName,
    required String description,
    required String privacy,
    String? coverImageUrl,
    String? avatarUrl,
    bool? requirePostApproval,
    List<String>? tags,
  }) async {
    await _handleApiCall<void>(
      apiCall: () => _socialGroupsService.updateGroup(
        id: id,
        userId: userId,
        groupName: groupName,
        description: description,
        privacy: privacy,
        coverImageUrl: coverImageUrl,
        avatarUrl: avatarUrl,
        requirePostApproval: requirePostApproval,
        tags: tags,
      ),
      onSuccess: (_) {
        final index = _allGroups.indexWhere((g) => g.idGroup == id);
        if (index != -1) {
          final updatedList = List<SocialGroupsModel>.from(_allGroups);
          updatedList[index] = _allGroups[index].copyWith(
            groupName: groupName,
            description: description,
            privacy: privacy,
            coverImageUrl: coverImageUrl,
            avatarUrl: avatarUrl,
            requirePostApproval: requirePostApproval,
            tags: tags,
          );
          _setState(allGroups: updatedList);
        }
      },
    );
  }

  Future<void> deleteGroup({required String id, required String userId}) async {
    await _handleApiCall<void>(
      apiCall: () => _socialGroupsService.deleteGroup(id: id, userId: userId),
      onSuccess: (_) {
        final updatedMyGroups = List<SocialGroupsModel>.from(_myGroups)..removeWhere((g) => g.idGroup == id);
        final updatedAllGroups = List<SocialGroupsModel>.from(_allGroups)..removeWhere((g) => g.idGroup == id);
        final updatedNotJoinedGroups = List<SocialGroupsModel>.from(_notJoinedGroups)..removeWhere((g) => g.idGroup == id);
        _setState(myGroups: updatedMyGroups, allGroups: updatedAllGroups, notJoinedGroups: updatedNotJoinedGroups);
      },
    );
  }

  Future<void> joinGroup({required String idGroup, required String userId}) async {
    await _handleApiCall<void>(
      apiCall: () => _socialGroupsService.joinGroup(idGroup: idGroup, userId: userId),
      onSuccess: (_) {
        // Sau khi join, reload joinedGroups, notJoinedGroups
        getGroupsWithJoinStatus(userId: userId);
      },
    );
  }

  Future<void> leaveGroup({required String idGroup, required String userId}) async {
    await _handleApiCall<void>(
      apiCall: () => _socialGroupsService.leaveGroup(idGroup: idGroup, userId: userId),
      onSuccess: (_) {
        getGroupsWithJoinStatus(userId: userId);
      },
    );
  }

  Future<void> getGroupMembers({required String groupId}) async {
    await _handleApiCall<List<GroupMemberModel>>(
      apiCall: () => _socialGroupsService.getGroupMembers(groupId: groupId),
      onSuccess: (data) => _setState(members: data),
    );
  }

  Future<void> updateMemberRole({required String groupId, required String currentUserId, required String targetUserId, required String role}) async {
    await _handleApiCall<void>(
      apiCall: () => _socialGroupsService.updateMemberRole(groupId: groupId, currentUserId: currentUserId, targetUserId: targetUserId, role: role),
      onSuccess: (_) {
        final updatedMembers = List<GroupMemberModel>.from(_members);
        final index = updatedMembers.indexWhere((m) => m.idUser == targetUserId);
        if (index != -1) {
          updatedMembers[index] = updatedMembers[index].copyWith(roleInGroup: role);
        }
        _setState(members: updatedMembers);
      },
    );
  }

  Future<void> removeMember({required String groupId, required String targetUserId, required String currentUserId}) async {
    await _handleApiCall<void>(
      apiCall: () => _socialGroupsService.removeMember(groupId: groupId, targetUserId: targetUserId, currentUserId: currentUserId),
      onSuccess: (_) {
        final updatedMembers = List<GroupMemberModel>.from(_members)..removeWhere((m) => m.idUser == targetUserId);
        _setState(members: updatedMembers);
      },
    );
  }

  Future<void> approveMember({required String groupId, required String targetUserId, required String currentUserId}) async {
    await _handleApiCall<void>(
      apiCall: () => _socialGroupsService.approveMember(groupId: groupId, targetUserId: targetUserId, currentUserId: currentUserId),
      onSuccess: (_) {
        // Cập nhật members nếu cần
        getGroupMembers(groupId: groupId);
      },
    );
  }

  Future<void> approveMemberWithBody({required String groupId, required String targetUserId, required String currentUserId}) async {
    await _handleApiCall<void>(
      apiCall: () => _socialGroupsService.approveMemberWithBody(groupId: groupId, targetUserId: targetUserId, currentUserId: currentUserId),
      onSuccess: (_) => getGroupMembers(groupId: groupId),
    );
  }

  Future<void> rejectMember({required String groupId, required String targetUserId, required String currentUserId}) async {
    await _handleApiCall<void>(
      apiCall: () => _socialGroupsService.rejectMember(groupId: groupId, targetUserId: targetUserId, currentUserId: currentUserId),
      onSuccess: (_) => getGroupMembers(groupId: groupId),
    );
  }

  Future<void> getGroupTags() async {
    await _handleApiCall<List<String>>(
      apiCall: _socialGroupsService.getGroupTags,
      onSuccess: (data) => _setState(tags: data),
    );
  }

  Future<void> getGroupStats() async {
    await _handleApiCall<GroupStatsModel>(
      apiCall: _socialGroupsService.getGroupStats,
      onSuccess: (data) => _setState(stats: data),
    );
  }

  // ====================== RESET & REFRESH ======================
  void onResetState() {
    _setState(
      isLoading: false,
      isSuccess: false,
      errorMessage: null,
      allGroups: [],
      joinedGroups: [],
      pendingGroups: [],
      notJoinedGroups: [],
      myGroups: [],
      members: [],
      stats: null,
      tags: [],
      selectedGroup: null,
    );
  }

  Future<void> refreshGroups() async {
    await getAllGroups();
  }
}
