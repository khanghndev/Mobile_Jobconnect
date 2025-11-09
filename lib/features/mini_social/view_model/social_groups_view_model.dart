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
        final uploadedMain = await _storageAppwriteService.uploadFile(
          mainFile,
          bucketId: bucketId,
        );
        final mainUrl = _storageAppwriteService.getFileViewUrl(
          uploadedMain.$id,
          bucketId: bucketId,
        );
        urls.add(mainUrl);
      }

      // Upload ảnh bìa nhóm
      if (coverImagePath.isNotEmpty) {
        final coverFile = File(coverImagePath);
        final uploadedCover = await _storageAppwriteService.uploadFile(
          coverFile,
          bucketId: bucketId,
        );
        final coverUrl = _storageAppwriteService.getFileViewUrl(
          uploadedCover.$id,
          bucketId: bucketId,
        );
        urls.add(coverUrl);
      }

      _setState(isLoading: false);
      return urls;
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> getGroupsWithJoinStatus({required String userId}) async {
    _setState(isLoading: true, isSuccess: false, errorMessage: null);
    try {
      // Lấy tất cả nhóm
      final allGroups = await _socialGroupsService.getAllGroups();

      // Lấy nhóm đã tham gia và nhóm đang chờ
      final joinedGroups = await _socialGroupsService.getJoinedGroups(userId: userId);
      final pendingGroups = await _socialGroupsService.getPendingGroups(userId: userId);

      // Tạo set id để lọc nhóm chưa tham gia
      final joinedIds = joinedGroups.map((g) => g.idGroup).toSet();
      final pendingIds = pendingGroups.map((g) => g.idGroup).toSet();

      // Nhóm chưa tham gia = allGroups - joined - pending
      final notJoinedGroups = allGroups
          .where((g) => !joinedIds.contains(g.idGroup) && !pendingIds.contains(g.idGroup))
          .toList();

      // Cập nhật state
      _setState(
        isLoading: false,
        isSuccess: true,
        allGroups: allGroups,
        joinedGroups: joinedGroups,
        pendingGroups: pendingGroups,
        notJoinedGroups: notJoinedGroups,
      );
    } on ServerException catch (e) {
      _setState(isLoading: false, errorMessage: e.err, isSuccess: false);
    } catch (e) {
      _setState(isLoading: false, errorMessage: e.toString(), isSuccess: false);
    }
  }

  // API FUNCTIONS
  Future<void> getAllGroups() async {
    await _handleApiCall<List<SocialGroupsModel>>(
      apiCall: _socialGroupsService.getAllGroups,
      onSuccess: (data) => _allGroups = data,
    );
  }

  Future<void> getJoinedGroups({required String userId}) async {
    await _handleApiCall<List<SocialGroupsModel>>(
      apiCall: () => _socialGroupsService.getJoinedGroups(userId: userId),
      onSuccess: (data) => _joinedGroups = data,
    );
  }

  Future<void> getPendingGroups({required String userId}) async {
    await _handleApiCall<List<SocialGroupsModel>>(
      apiCall: () => _socialGroupsService.getPendingGroups(userId: userId),
      onSuccess: (data) => _pendingGroups = data,
    );
  }

  Future<void> searchGroups(String keyword) async {
    await _handleApiCall<List<SocialGroupsModel>>(
      apiCall: () => _socialGroupsService.searchGroups(keyword: keyword),
      onSuccess: (data) => _allGroups = data,
    );
  }

  Future<void> getGroupById({required String id}) async {
    await _handleApiCall<SocialGroupsModel>(
      apiCall: () => _socialGroupsService.getGroupById(id: id),
      onSuccess: (data) => _selectedGroup = data,
    );
  }

  Future<SocialGroupsModel?> createGroup({
    required SocialGroupsModel group,
  }) async {
    SocialGroupsModel? createdGroup;
    await _handleApiCall<SocialGroupsModel>(
      apiCall: () => _socialGroupsService.createGroup(group: group),
      onSuccess: (data) {
        createdGroup = data;
        _allGroups.add(data);
      },
    );
    return createdGroup;
  }

  Future<SocialGroupsModel?> updateGroup({
    required String id,
    required SocialGroupsModel group,
  }) async {
    SocialGroupsModel? updatedGroup;
    await _handleApiCall<SocialGroupsModel>(
      apiCall: () => _socialGroupsService.updateGroup(id: id, group: group),
      onSuccess: (data) {
        updatedGroup = data;
        final index = _allGroups.indexWhere((g) => g.idGroup == id);
        if (index != -1) {
          _allGroups[index] = data;
        }
      },
    );
    return updatedGroup;
  }

  Future<void> deleteGroup({
    required String id,
  }) async {
    await _handleApiCall<void>(
      apiCall: () => _socialGroupsService.deleteGroup(id: id),
      onSuccess: (_) => _allGroups.removeWhere((g) => g.idGroup == id),
    );
  }

  Future<void> joinGroup({
    required String idGroup,
    required String userId,
  }) async {
    await _handleApiCall<void>(
      apiCall: () => _socialGroupsService.joinGroup(
        idGroup: idGroup,
        userId: userId,
      )
      ,
    );
  }

  Future<void> leaveGroup({
    required String id,
  }) async {
    await _handleApiCall<void>(
      apiCall: () => _socialGroupsService.leaveGroup(id: id),
    );
  }

  Future<void> getGroupMembers({
    required String groupId,
  }) async {
    await _handleApiCall<List<GroupMemberModel>>(
      apiCall: () => _socialGroupsService.getGroupMembers(groupId: groupId),
      onSuccess: (data) => _members = data,
    );
  }

  Future<void> updateMemberRole({
    required String groupId,
    required String userId,
    required String role,
  }) async {
    await _handleApiCall<void>(
      apiCall: () => _socialGroupsService.updateMemberRole(
        groupId: groupId,
        userId: userId,
        role: role,
      ),
    );
  }

  Future<void> removeMember({
    required String groupId,
    required String userId,
  }) async {
    await _handleApiCall<void>(
      apiCall: () => _socialGroupsService.removeMember(
        groupId: groupId,
        userId: userId,
      ),
      onSuccess: (_) => _members.removeWhere((m) => m.idUser == userId),
    );
  }

  Future<void> getGroupTags() async {
    await _handleApiCall<List<String>>(
      apiCall: _socialGroupsService.getGroupTags,
      onSuccess: (data) => _tags = data,
    );
  }

  Future<void> getGroupStats() async {
    await _handleApiCall<GroupStatsModel>(
      apiCall: _socialGroupsService.getGroupStats,
      onSuccess: (data) => _stats = data,
    );
  }

  // RESET & REFRESH
  void onResetState() {
    _setState(
      isLoading: false,
      isSuccess: false,
      errorMessage: null,
      allGroups: [],
      joinedGroups: [],
      notJoinedGroups: [],
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
