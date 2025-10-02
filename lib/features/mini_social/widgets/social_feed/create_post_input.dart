import 'package:flutter/material.dart';

class UserInfoModel {
  final String avatarUrl;
  final String username;
  final String placeholder;

  UserInfoModel({
    required this.avatarUrl,
    required this.username,
    required this.placeholder,
  });
}

class CreatePostInput extends StatelessWidget {
  final UserInfoModel user;
  final VoidCallback? onCreatePost;
  final VoidCallback? onSearch;

  const CreatePostInput({
    super.key,
    required this.user,
    this.onCreatePost,
    this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onCreatePost,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(user.avatarUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.placeholder,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.search_rounded, color: Colors.grey),
              onPressed: onSearch,
            ),
          ],
        ),
      ),
    );
  }
}