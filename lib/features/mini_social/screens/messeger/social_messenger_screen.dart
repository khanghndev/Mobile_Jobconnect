import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/features/mini_social/screens/messeger/social_messenger_item_screen.dart';

// Model dữ liệu
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
    StoryModel(
      name: "Tôi",
      url: "https://i.imgur.com/BoN9kdC.png",
      isLocked: false,
    ),
    StoryModel(
      name: "Kỷ niệm xưa",
      url: "https://i.imgur.com/BoN9kdC.png",
      isLocked: true,
    ),
    StoryModel(
      name: "Cream_dSi",
      url: "https://i.imgur.com/BoN9kdC.png",
      isLocked: false,
    ),
    StoryModel(
      name: "꽃거지",
      url: "https://i.imgur.com/BoN9kdC.png",
      isLocked: false,
    ),
    StoryModel(
      name: "Cream_dSi",
      url: "https://i.imgur.com/BoN9kdC.png",
      isLocked: false,
    ),
    StoryModel(
      name: "꽃거지",
      url: "https://i.imgur.com/BoN9kdC.png",
      isLocked: false,
    ),
    StoryModel(
      name: "Cream_dSi",
      url: "https://i.imgur.com/BoN9kdC.png",
      isLocked: false,
    ),
    StoryModel(
      name: "꽃거지",
      url: "https://i.imgur.com/BoN9kdC.png",
      isLocked: false,
    ),
    StoryModel(
      name: "Cream_dSi",
      url: "https://i.imgur.com/BoN9kdC.png",
      isLocked: false,
    ),
    StoryModel(
      name: "꽃거지",
      url: "https://i.imgur.com/BoN9kdC.png",
      isLocked: false,
    ),
  ];

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: fakeStories.length,
                itemBuilder: (context, index) {
                  final story = fakeStories[index];
                  if(index == 0) {
                    return _buildStory(
                      name: 'Minh Tiến',
                      url: story.url,
                      isLocked: story.isLocked,
                      onTap: () {
                        
                      },
                    );
                  }
                  return _buildStory(
                    name: story.name,
                    url: story.url,
                    isLocked: story.isLocked,
                    onTap: () {
                      print("Bấm vào story: ${story.name}");
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // 👉 Các item hệ thống
            _buildMessageItem(
              icon: Icons.group,
              color: Colors.blue,
              title: "Những Follower mới",
              latsMessage: "Tiệm Pizza màu xanh đã bắt đầu foll...",
              onTap: () {
                
              },
            ),
            _buildMessageItem(
              icon: Icons.notifications,
              color: Colors.pink,
              title: "Hoạt động",
              latsMessage: "Trọng Khang đã nhắc đến bạn...",
              badge: "19",
              onTap: () {
                context.push(
                  '/messenger-item',
                  extra: {
                    'isLoggedIn': widget.isLoggedIn,
                    'idUser': widget.idUser,
                  }
                );
              },
            ),
            _buildUserMessage(
              avatar: "https://i.imgur.com/BoN9kdC.png",
              name: "Trọng Khang",
              latsMessage: "Vừa gửi",
              isVideo: true,
              onTap: () {
                context.push(
                  '/messenger-item',
                  extra: {
                    'isLoggedIn': widget.isLoggedIn,
                    'idUser': widget.idUser,
                  }
                );
              },         
            ),
            _buildUserMessage(
              avatar: "https://i.imgur.com/BoN9kdC.png",
              name: "ngoczuynw25",
              latsMessage: "Chia sẻ bài đăng này...",
              onTap: () {
                context.push(
                  '/messenger-item',
                  extra: {
                    'isLoggedIn': widget.isLoggedIn,
                    'idUser': widget.idUser,
                  }
                );
              },
            ),
                        
            _buildUserMessage(
              avatar: "https://i.imgur.com/BoN9kdC.png",
              name: "Lztrunn",
              latsMessage: "Cmt cho mình · 8 tháng 9",
              badge: "2",
              onTap: () {
                
              },
            ),
             _buildUserMessage(
              avatar: "https://i.imgur.com/BoN9kdC.png",
              name: "Lztrunn",
              latsMessage: "Cmt cho mình · 8 tháng 9",
              badge: "2",
              onTap: () {
                context.push(
                  '/messenger-item',
                  extra: {
                    'isLoggedIn': widget.isLoggedIn,
                    'idUser': widget.idUser,
                  }
                );
              },
            ),
             _buildUserMessage(
              avatar: "https://i.imgur.com/BoN9kdC.png",
              name: "Lztrunn",
              latsMessage: "Cmt cho mình · 8 tháng 9",
              badge: "2",
              onTap: () {
                context.push(
                  '/messenger-item',
                  extra: {
                    'isLoggedIn': widget.isLoggedIn,
                    'idUser': widget.idUser,
                  }
                );
              },           
            ),
             _buildUserMessage(
              avatar: "https://i.imgur.com/BoN9kdC.png",
              name: "Lztrunn",
              latsMessage: "Cmt cho mình · 8 tháng 9",
              badge: "2",
              onTap: () {
                context.push(
                  '/messenger-item',
                  extra: {
                    'isLoggedIn': widget.isLoggedIn,
                    'idUser': widget.idUser,
                  }
                );
              },            
            ),
             _buildUserMessage(
              avatar: "https://i.imgur.com/BoN9kdC.png",
              name: "Lztrunn",
              latsMessage: "Cmt cho mình · 8 tháng 9",
              badge: "2",
              onTap: () {
                context.push(
                  '/messenger-item',
                  extra: {
                    'isLoggedIn': widget.isLoggedIn,
                    'idUser': widget.idUser,
                  }
                );
              },            
            ),
             _buildUserMessage(
              avatar: "https://i.imgur.com/BoN9kdC.png",
              name: "Lztrunn",
              latsMessage: "Cmt cho mình · 8 tháng 9",
              badge: "2",
              onTap: () {
                context.push(
                  '/messenger-item',
                  extra: {
                    'isLoggedIn': widget.isLoggedIn,
                    'idUser': widget.idUser,
                  }
                );
              },            
            ),
             _buildUserMessage(
              avatar: "https://i.imgur.com/BoN9kdC.png",
              name: "Lztrunn",
              latsMessage: "Cmt cho mình · 8 tháng 9",
              badge: "2",
              onTap: () {
                context.push(
                  '/messenger-item',
                  extra: {
                    'isLoggedIn': widget.isLoggedIn,
                    'idUser': widget.idUser,
                  }
                );
              },            
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStory({ required String name, required String url, required VoidCallback onTap, bool isLocked = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            GestureDetector(
              onTap: onTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(url),
                  ),
                  if (isLocked)
                    const Icon(Icons.lock, size: 20, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(name, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem({
    required IconData icon,
    required Color color,
    required String title,
    required String latsMessage,
    required Function() onTap,
    String? badge,
    bool dot = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        leading: CircleAvatar(
          radius: 32,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(latsMessage, overflow: TextOverflow.ellipsis),
        trailing: badge != null
            ? CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Text(
                  badge,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              )
            : dot
                ? const CircleAvatar(
                    radius: 6,
                    backgroundColor: Colors.red,
                  )
                : null,
      ),
    );
  }

  Widget _buildUserMessage({
    required String avatar,
    required String name,
    required String latsMessage,
    required Function() onTap,
    String? badge,
    bool? isVideo = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(avatar),
          radius: 32,
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(latsMessage, overflow: TextOverflow.ellipsis),
        trailing: badge != null
            ? CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Text(
                  badge,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              )
            : isVideo == true ? Icon( Icons.party_mode_outlined, color: Colors.grey) : null,
      ),
    );
  }
}
