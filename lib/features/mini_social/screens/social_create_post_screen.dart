import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _showFullOptions = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tạo bài viết",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: TextButton(
              style: TextButton.styleFrom(
                minimumSize: Size(40.w, 30.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                backgroundColor: theme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              onPressed: () {},
              child: Text("Post", style: TextStyle(color: Colors.white, fontSize: 14.sp)),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
                ),
                SizedBox(width: 10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Martin Kenter", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp)),
                    Row(
                      children: [
                        Icon(Icons.verified, color: Colors.blue, size: 16.r),
                        SizedBox(width: 4.w),
                        Text("Verified", style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: TextField(
                controller: _controller,
                maxLines: null,
                cursorColor: Colors.blue[200], // Tuỳ chọn màu con trỏ nếu muốn
                style: TextStyle(fontSize: 16.sp), // Tuỳ chỉnh text style nếu cần
                decoration: const InputDecoration(
                  hintText: "What do you want to talk about?",
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  filled: false, // Không có nền riêng
                  isCollapsed: true, // Giảm padding mặc định
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () => setState(() => _showFullOptions = false),
              ),
            ),
          ),

          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: const Border(top: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: _showFullOptions ? _buildExpandedGrid() : _buildCompactRow(),
    );
  }

  Widget _buildCompactRow() {
    final icons = [
      {'icon': Icons.image, 'color': Colors.blue},
      {'icon': Icons.gif_box, 'color': Colors.lightBlue},
      {'icon': Icons.poll, 'color': Colors.green},
      {'icon': Icons.favorite, 'color': Colors.redAccent},
      {'icon': Icons.campaign, 'color': Colors.orange},
      {'icon': Icons.event, 'color': Colors.purple},
      {'icon': Icons.celebration, 'color': Colors.teal},
    ];

    return Row(
      children: [
        // Phần cuộn được
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: icons.map((item) {
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: _buildCircleIcon(
                    icon: item['icon'] as IconData,
                    color: item['color'] as Color,
                    onPressed: () {},
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Icon cố định cuối cùng
        Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: _buildCircleIcon(
            icon: Icons.arrow_drop_up,
            color: Colors.grey,
            onPressed: () => setState(() => _showFullOptions = true),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedGrid() {
    final options = [
      {'icon': Icons.image, 'label': 'Photo/Video', 'color': Colors.blue},
      {'icon': Icons.gif_box, 'label': 'GIF', 'color': Colors.lightBlue},
      {'icon': Icons.poll, 'label': 'Poll', 'color': Colors.green},
      {'icon': Icons.favorite, 'label': 'Adoption', 'color': Colors.redAccent},
      {'icon': Icons.campaign, 'label': 'Lost Notice', 'color': Colors.orange},
      {'icon': Icons.event, 'label': 'Event', 'color': Colors.purple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 100.w,
            height: 3.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          )
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Add to your post", style: TextStyle(fontWeight: FontWeight.w600)),
            IconButton(
            icon: const Icon(Icons.arrow_drop_down),
            onPressed: () => setState(() => _showFullOptions = false),
          ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12.h,
            crossAxisSpacing: 12.w,
            childAspectRatio: 2,
          ),
          itemBuilder: (_, i) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        options[i]['icon'] as IconData, 
                        color: options[i]['color'] as Color,
                        size: 30,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        options[i]['label'] as String,
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const Icon(Icons.add),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCircleIcon({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Container(
      width: 44.w,
      height: 44.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }
}
