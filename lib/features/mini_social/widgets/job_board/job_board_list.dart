import 'package:flutter/material.dart';

class Story {
  final String imageUrl;
  final String name;
  final bool isDraft;

  Story({required this.imageUrl, required this.name, this.isDraft = false});
}

class StoriesWidget extends StatelessWidget {
  final List<Story> stories = [
    Story(
      imageUrl: 'https://i.pravatar.cc/150?img=1',
      name: 'Tạo tin',
      isDraft: true,
    ),
    Story(
      imageUrl: 'https://i.pravatar.cc/150?img=2',
      name: 'Phùng Thanh Thảo',
    ),
    Story(
      imageUrl: 'https://i.pravatar.cc/150?img=3',
      name: 'Nhi Phương',
    ),
    Story(
      imageUrl: 'https://i.pravatar.cc/150?img=4',
      name: 'Anh Khoa',
    ),
    Story(
      imageUrl: 'https://i.pravatar.cc/150?img=4',
      name: 'Anh Khoa',
    ),
    Story(
      imageUrl: 'https://i.pravatar.cc/150?img=4',
      name: 'Anh Khoa',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return Container(
            width: 110,
            margin: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        story.imageUrl,
                        height: 160,
                        width: 110,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (story.isDraft)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Bản nháp',
                            style: TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                    if (story.isDraft)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 16,
                          child: Icon(Icons.add, color: Colors.blue),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  story.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Stories Demo')),
      body: StoriesWidget(),
    ),
  ));
}
