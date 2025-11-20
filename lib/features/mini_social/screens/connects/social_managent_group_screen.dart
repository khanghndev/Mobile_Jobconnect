import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/features/mini_social/widgets/connect/group_member_item.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:job_connect/config/widgets/background_empty_state.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/config/widgets/custom_app_bar_title_large.dart';
import 'package:job_connect/config/widgets/custom_search_bar.dart';
import 'package:job_connect/features/mini_social/view_model/social_groups_view_model.dart';

class SocialManagentGroupScreen extends StatefulWidget {
  final String idUser;
  final String idGroup;

  const SocialManagentGroupScreen({
    super.key,
    required this.idUser,
    required this.idGroup,
  });

  @override
  State<SocialManagentGroupScreen> createState() =>
      _SocialManagentGroupScreenState();
}

class _SocialManagentGroupScreenState extends State<SocialManagentGroupScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0;
  bool _isLoadingTab = false;

  final List<String> _tabs = ["Quản trị viên", "Thành viên", "Chờ xác nhận"];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoadingTab = true);
    final groupVm = context.read<SocialGroupsViewModel>();
    await groupVm.getGroupMembers(groupId: widget.idGroup);
    if (mounted) setState(() => _isLoadingTab = false);
  }

  List _getFilteredMembers(SocialGroupsViewModel groupVm) {
    final keyword = _searchController.text.toLowerCase();
    List members = [];

    switch (_selectedTab) {
      case 0:
        members = groupVm.members
            .where((m) =>
                m.roleInGroup == 'owner' || m.roleInGroup == 'admin')
            .toList();
        break;
      case 1:
        members = groupVm.members
            .where((m) =>
                m.roleInGroup == 'member' && m.status == 'active')
            .toList();
        break;
      case 2:
        members =
            groupVm.members.where((m) => m.status == 'pending').toList();
        break;
    }

    if (keyword.isNotEmpty) {
      members = members.where((m) {
        return m.userName.toLowerCase().contains(keyword) ||
            (m.email?.toLowerCase().contains(keyword) ?? false);
      }).toList();
    }

    return members;
  }

  bool _canManageRole(String myRole) {
    return myRole == "owner" || myRole == "admin";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final groupVm = context.watch<SocialGroupsViewModel>();
    final filteredMembers = _getFilteredMembers(groupVm);

    final myRole =
        groupVm.members.firstWhere((m) => m.idUser == widget.idUser).roleInGroup;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppbarTitleLarge(title: 'Quản lý thành viên'),
      body: UnfocusWidget(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.h),
                child: CustomSearchBar(
                  controller: _searchController,
                  hintText: 'Tìm kiếm thành viên',
                  borderRadius: 30.r,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildCustomTabBar(),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadMembers,
                  child: _isLoadingTab
                      ? _buildShimmerList()
                      : filteredMembers.isEmpty
                          ? ListView(
                              physics:
                                  const AlwaysScrollableScrollPhysics(),
                              children: [
                                Center(
                                  child: BackgroundEmptyState(
                                    isSearching: true,
                                    onRefresh: _loadMembers,
                                    title: 'Thành Viên',
                                    subTitle:
                                        'Hiện tại chưa có thông tin thành viên.',
                                    iconData: Icons
                                        .supervised_user_circle_outlined,
                                  ),
                                ),
                              ],
                            )
                          : ListView.builder(
                              itemCount: filteredMembers.length,
                              itemBuilder: (context, index) {
                                final member = filteredMembers[index];
                                final isPending =
                                    member.status == 'pending';
                                final canApprove = _selectedTab == 2;

                                final canManageRoleButton =
                                    _canManageRole(myRole) &&
                                        member.roleInGroup != "owner";

                                return GroupMemberItem(
                                  member: member,
                                  canApprove: canApprove,
                                  canManageRole: canManageRoleButton,

                                  /// DUYỆT
                                  onApprove: canApprove && isPending
                                      ? () => groupVm.approveMember(
                                            groupId: widget.idGroup,
                                            targetUserId: member.idUser,
                                            currentUserId: widget.idUser,
                                          )
                                      : null,
                                  onReject: canApprove && isPending
                                      ? () => groupVm.rejectMember(
                                            groupId: widget.idGroup,
                                            targetUserId: member.idUser,
                                            currentUserId: widget.idUser,
                                          )
                                      : null,

                                  /// XÓA THÀNH VIÊN
                                  onRemove: member.idUser != widget.idUser &&
                                          member.roleInGroup != "owner"
                                      ? () {
                                          DialogUtils.showConfirmationDialog(
                                              context: context,
                                              title: "Xóa thành viên",
                                              message:
                                                  "Bạn có muốn xóa thành viên này?",
                                              icon: Icons
                                                  .delete_forever_rounded,
                                              backgroundColor: BackgroundColors
                                                  .backgroundErrorPrimary,
                                              onConfirm: () async {
                                                await groupVm.removeMember(
                                                  groupId: widget.idGroup,
                                                  targetUserId: member.idUser,
                                                  currentUserId:
                                                      widget.idUser,
                                                );
                                              });
                                        }
                                      : null,

                                  /// PROFILE
                                  onOpenProfile: () {
                                    context.push('/social/profile',
                                        extra: {'idUser': member.idUser});
                                  },

                                  /// CẤP ADMIN
                                  onPromoteAdmin: canManageRoleButton &&
                                          member.roleInGroup != "admin"
                                      ? () {
                                          DialogUtils
                                              .showConfirmationDialog(
                                            context: context,
                                            title: "Cấp quyền quản trị viên",
                                            message:
                                                "Bạn muốn cấp quyền quản trị viên cho ${member.userName}?",
                                            icon: Icons.upgrade_rounded,
                                            backgroundColor: Colors.blue,
                                            onConfirm: () async {
                                              groupVm.updateMemberRole(
                                                groupId: widget.idGroup,
                                                targetUserId: member.idUser,
                                                currentUserId:
                                                    widget.idUser,
                                                role: "admin",
                                              );
                                            },
                                          );
                                        }
                                      : null,

                                  /// HẠ QUYỀN -> MEMBER
                                  onDemoteMember: canManageRoleButton &&
                                          member.roleInGroup == "admin"
                                      ? () {
                                          DialogUtils
                                              .showConfirmationDialog(
                                            context: context,
                                            title: "Hạ xuống thành viên",
                                            message:
                                                "Bạn muốn hạ quyền quản trị của ${member.userName}?",
                                            icon: Icons.remove_circle,
                                            backgroundColor: Colors.orange,
                                            onConfirm: () async {
                                              groupVm.updateMemberRole(
                                                groupId: widget.idGroup,
                                                targetUserId: member.idUser,
                                                currentUserId:
                                                    widget.idUser,
                                                role: "member",
                                              );
                                            },
                                          );
                                        }
                                      : null,
                                );
                              },
                            ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: double.infinity,
                          height: 14.h,
                          color: Colors.white),
                      SizedBox(height: 6.h),
                      Container(
                          width: 100.w,
                          height: 12.h,
                          color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
