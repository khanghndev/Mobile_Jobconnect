import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_colors.dart';

class StoryModel {
  final String name;
  final String url;
  final bool isLocked;

  StoryModel({
    required this.name,
    required this.url,
    required this.isLocked,
  });
}

class MessageModel {
  final String? avatar;
  final IconData? icon;
  final Color? color;
  final String name;
  final String lastMessage;
  final String? badge;
  final bool? isVideo;

  MessageModel({
    this.avatar,
    this.icon,
    this.color,
    required this.name,
    required this.lastMessage,
    this.badge,
    this.isVideo,
  });
}

class SocialMessengerScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;

  const SocialMessengerScreen({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
  });

  @override
  State<SocialMessengerScreen> createState() => _SocialMessengerScreenState();
}

class _SocialMessengerScreenState extends State<SocialMessengerScreen> {
  final List<StoryModel> fakeStories = [
    StoryModel(name: "Tôi", url: "https://i.imgur.com/BoN9kdC.png", isLocked: false),
    StoryModel(name: "Kỷ niệm xưa", url: "https://i.imgur.com/BoN9kdC.png", isLocked: true),
    StoryModel(name: "Cream_dSi", url: "https://i.imgur.com/BoN9kdC.png", isLocked: false),
    StoryModel(name: "꽃거지", url: "https://i.imgur.com/BoN9kdC.png", isLocked: false),
    StoryModel(name: "Jenny", url: "https://i.imgur.com/BoN9kdC.png", isLocked: false),
  ];

  final List<MessageModel> fakeMessages = [
    MessageModel(
      icon: Icons.group,
      color: Colors.blue,
      name: "Những Follower mới",
      lastMessage: "Tiệm Pizza màu xanh đã bắt đầu foll...",
    ),
    MessageModel(
      icon: Icons.notifications,
      color: Colors.pink,
      name: "Hoạt động",
      lastMessage: "Trọng Khang đã nhắc đến bạn...",
      badge: "19",
    ),
    MessageModel(
      avatar: "https://i.imgur.com/BoN9kdC.png",
      name: "Trọng Khang",
      lastMessage: "Vừa gửi",
      isVideo: true,
    ),
    MessageModel(
      avatar: "https://i.imgur.com/BoN9kdC.png",
      name: "ngoczuynw25",
      lastMessage: "Chia sẻ bài đăng này...",
    ),
    MessageModel(
      avatar: "https://i.imgur.com/BoN9kdC.png",
      name: "Lztrunn",
      lastMessage: "Cmt cho mình · 8 tháng 9",
      badge: "2",
    ),
    MessageModel(
      avatar: "https://i.imgur.com/BoN9kdC.png",
      name: "Alice",
      lastMessage: "Hey, how are you?",
    ),
  ];

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          padding: EdgeInsets.all(12.w),
          children: [
            SizedBox(height: 12.h),
            SizedBox(
              height: 90.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: fakeStories.length,
                itemBuilder: (context, index) {
                  final story = fakeStories[index];
                  return _buildStory(
                    context: context,
                    name: index == 0 ? "Minh Tiến" : story.name,
                    url: story.url,
                    isLocked: story.isLocked,
                    onTap: () {
                      context.push(
                        '/messenger-detail',
                        extra: {
                          'isLoggedIn': widget.isLoggedIn,
                          'idUser': widget.idUser,
                        },
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 12.h),
            ...fakeMessages.map((msg) {
              return _buildMessageItem(
                context: context,
                msg: msg,
                onTap: () {
                  context.push(
                    '/messenger-detail',
                    extra: {
                      'isLoggedIn': widget.isLoggedIn,
                      'idUser': widget.idUser,
                    },
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStory({
    required BuildContext context,
    required String name,
    required String url,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(right: 12.w),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 30.r,
                  backgroundImage: NetworkImage(url),
                ),
                if (isLocked)
                  Icon(Icons.lock, size: 20.sp, color: IconColors.iconBrandOnbrand),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: TextColors.textDefaultPrimary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem({
    required BuildContext context,
    required MessageModel msg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        leading: msg.avatar != null
            ? CircleAvatar(
                radius: 28.r,
                backgroundImage: NetworkImage(msg.avatar!),
              )
            : CircleAvatar(
                radius: 28.r,
                backgroundColor: msg.color ??
                    BackgroundColors.backgroundDefaultPrimarySub.withValues(alpha: 0.1),
                child: Icon(msg.icon, color: IconColors.iconBrandOnbrand, size: 20.sp),
              ),
        title: Text(
          msg.name,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: TextColors.textDefaultPrimary,
              ),
        ),
        subtitle: Text(
          msg.lastMessage,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                color: TextColors.textDefaultSecondary,
              ),
        ),
        trailing: msg.badge != null
            ? CircleAvatar(
                radius: 12.r,
                backgroundColor: BackgroundColors.backgroundBadgeDefault,
                child: Text(
                  msg.badge!,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: TextColors.textBrandOnbrand,
                      ),
                ),
              )
            : msg.isVideo == true
                ? Icon(Icons.party_mode_outlined,
                    color: IconColors.iconDefaultPrimary.withValues(alpha: 0.5),
                    size: 18.sp)
                : null,
      ),
    );
  }
}
