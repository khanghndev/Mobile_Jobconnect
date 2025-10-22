import 'package:flutter/material.dart';
import 'package:job_connect/config/utils/image_url.dart';

class SearchUserItem extends StatefulWidget {
  final String avatar;
  final String name;
  final String subtitle;
  final String followers;
  final VoidCallback? onFollow; // Callback khi bấm nút

  const SearchUserItem({
    super.key,
    required this.avatar,
    required this.name,
    required this.subtitle,
    required this.followers,
    this.onFollow,
  });

  @override
  State<SearchUserItem> createState() => _SearchUserItemState();
}

class _SearchUserItemState extends State<SearchUserItem> {
  bool _isFollowed = false;

  void _toggleFollow() {
    widget.onFollow?.call(); // Gọi callback nếu có
    setState(() {
      _isFollowed = !_isFollowed; // Đổi trạng thái
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: ImageUtils.getImageProvider(widget.avatar),
            radius: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.name,
                    style: const TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
                Text(widget.subtitle,
                    style: const TextStyle(
                        color: Colors.black, fontSize: 12)),
                const SizedBox(height: 4),
                Text(widget.followers,
                    style: const TextStyle(
                        color: Colors.black, fontSize: 12)),
              ],
            ),
          ),
          TextButton(
            onPressed: _toggleFollow,
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              foregroundColor:
                  _isFollowed ? Colors.grey : Colors.blue,
              side: BorderSide(
                  color: _isFollowed ? Colors.grey : Colors.blue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              _isFollowed ? "Đã theo dõi" : "Theo dõi",
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
