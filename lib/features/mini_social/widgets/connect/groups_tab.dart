import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/enum/join_status.dart';
import 'package:job_connect/config/widgets/background_empty_state.dart';
import 'package:job_connect/config/widgets/background_error_state.dart';
import 'package:job_connect/config/widgets/custom_buttom_leading_icon.dart';
import 'package:job_connect/config/widgets/section_title.dart';
import 'package:job_connect/features/mini_social/model/social_groups_model.dart';
import 'package:job_connect/features/mini_social/widgets/connect/group_item_card.dart';
import 'package:job_connect/features/mini_social/widgets/connect/groups_tab_shimmer.dart';

class GroupsTab extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final List<SocialGroupsModel> joinedGroups;
  final List<SocialGroupsModel> notJoinedGroups;
  final List<SocialGroupsModel> pendingGroups;
  final Future<void> Function() onRefresh;
  final void Function(SocialGroupsModel group)? onJoinGroup;
  final void Function(String id)? onTapGroup;
  final VoidCallback? onCreateGroup;

  const GroupsTab({
    super.key,
    required this.isLoading,
    required this.errorMessage,
    required this.joinedGroups,
    required this.pendingGroups,
    required this.notJoinedGroups,
    required this.onRefresh,
    this.onJoinGroup,
    this.onTapGroup,
    this.onCreateGroup,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isLoading) return const GroupsTabShimmer();

    if (errorMessage != null) {
      return BackgroundErrorState(
        title: 'Lỗi khi tải danh sách nhóm: $errorMessage',
        onRetry: onRefresh,
      );
    }

    if (joinedGroups.isEmpty && notJoinedGroups.isEmpty) {
      return BackgroundEmptyState(
        onRefresh: onRefresh,
        title: 'Không có nhóm nào để hiển thị',
        iconData: Icons.group,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        children: [
          if (joinedGroups.isNotEmpty) ...[
            const SectionTitle(
              title: 'Nhóm đã tham gia',
              icon: Icons.group_outlined,
            ),
            SizedBox(height: 12.h),
            ...joinedGroups.map(
              (group) => GroupItemCard(
                group: group,
                joinStatus: JoinStatus.joined,
                onTap: onTapGroup,
              ),
            ),
            SizedBox(height: 20.h),
          ],
          if (pendingGroups.isNotEmpty) ...[
            const SectionTitle(
              title: 'Nhóm đang chờ duyệt',
              icon: Icons.lock_clock,
            ),
            SizedBox(height: 12.h),
            ...pendingGroups.map(
              (group) => GroupItemCard(
                group: group,
                joinStatus: JoinStatus.pending,
                onTap: onTapGroup,
              ),
            ),
            SizedBox(height: 20.h),
          ],
          if (notJoinedGroups.isNotEmpty) ...[
            const SectionTitle(
              title: 'Nhóm có thể tham gia',
              icon: Icons.group_add_outlined,
            ),
            SizedBox(height: 12.h),
            ...notJoinedGroups.map(
              (group) => GroupItemCard(
                group: group,
                joinStatus: JoinStatus.canJoin,
                onJoinGroup: onJoinGroup,
                onTap: onTapGroup,
              ),
            ),
          ],

          SizedBox(height: 20.h),
          CustomButtomLeadingIcon(
            onPressed: onCreateGroup ?? () {},
            text: 'Tạo nhóm mới',
            icon: Icons.create_outlined,
            iconColor: theme.colorScheme.onPrimary,
            backgroundColor: theme.primaryColor,
            textColor: theme.colorScheme.onPrimary,
            borderRadius: 50.r,
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}