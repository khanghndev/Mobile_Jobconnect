import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/features/home/widgets/home/featured_friend_item.dart';
import 'package:job_connect/features/profile/model/user_model.dart';

typedef FriendStatusGetter = Map<String, bool> Function(UserModel user);

class FeaturedFriendsList extends StatelessWidget {
  final List<UserModel> users;
  final FriendStatusGetter getFriendStatus;
  final void Function(UserModel user)? onSendRequest;
  final void Function(UserModel user)? onCancelRequest;
  final void Function(UserModel user)? onAcceptRequest;
  final void Function(UserModel user)? onRejectRequest;
  final void Function(UserModel user)? onUnfriend;
  final int maxItems;

  const FeaturedFriendsList({
    super.key,
    required this.users,
    required this.getFriendStatus,
    this.onSendRequest,
    this.onCancelRequest,
    this.onAcceptRequest,
    this.onRejectRequest,
    this.onUnfriend,
    this.maxItems = 100,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (users.isEmpty) {
      return Center(
        child: Text(
          'Chưa có bạn bè nào!',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final displayedUsers = users.length > maxItems ? users.sublist(0, maxItems) : users;

    return SizedBox(
      height: 250.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: displayedUsers.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final user = displayedUsers[index];
          final status = getFriendStatus(user);

          return FeaturedFriendItem(
            user: user,
            isFriend: status['isFriend'] ?? false,
            isRequestSent: status['isRequestSent'] ?? false,
            isRequestReceived: status['isRequestReceived'] ?? false,
            onSendRequest: (user) => onSendRequest?.call(user),
            onCancelRequest: (user) => onCancelRequest?.call(user),
            onAcceptRequest: (user) => onAcceptRequest?.call(user),
            onRejectRequest: (user) => onRejectRequest?.call(user),
            onUnfriend: (user) => onUnfriend?.call(user),
          );
        },
      ),
    );
  }
}
