import 'package:flutter/material.dart';

class SocialMessengerItemScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;

  const SocialMessengerItemScreen({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
  });

  @override
  State<SocialMessengerItemScreen> createState() =>
      _SocialMessengerItemScreenState();
}

class _SocialMessengerItemScreenState extends State<SocialMessengerItemScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // không AppBar mặc định, mình tự custom header
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  const CircleAvatar(
                    backgroundImage: NetworkImage(
                      "https://i.imgur.com/BoN9kdC.png",
                    ),
                    radius: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Trọng Khang",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Hiện đang hoạt động",
                            style:
                                TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.call), // đổi flag -> call
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Nội dung chat
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  // Tin nhắn người khác
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        backgroundImage:
                            NetworkImage("https://i.imgur.com/BoN9kdC.png"),
                        radius: 16,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Không thể xem bài đăng này của @a quát em à !",
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Tin nhắn của mình
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "sao bên m toàn mấy em du bu",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Thanh nhập tin nhắn
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt_outlined,
                        color: Colors.blue),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Nhắn tin...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.emoji_emotions_outlined),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.image_outlined),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.mic_none),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
