import 'package:flutter/material.dart';
import 'package:job_connect/features/mini_social/widgets/shared/social_app_bar.dart';
import 'package:job_connect/features/mini_social/widgets/social_search/search_input_field.dart';
import 'package:job_connect/features/mini_social/widgets/social_search/search_user_item.dart';

class SocialSearchScreen extends StatelessWidget {
  const SocialSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SocialAppBar(
        backgroundColor: Colors.white,
        title: 'Tìm kiếm',
        showActionIcon: false,
        leadingIcon: Icon(Icons.arrow_back_ios_new, color: Colors.black,),
        onLeadingPressed: () => Navigator.pop(context),
        centerTitle: false,
        titleFontSize: 28,
        titleColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SearchInputField(),
          Expanded(
            child: ListView(
              children: const [
                SearchUserItem(
                  avatar: 'https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png',
                  name: 'githubprojects',
                  subtitle: 'Github Projects',
                  desc:
                      'We\'re sharing/showcasing best of @github projects/repos. Follow to stay in loop.',
                  followers: '231K người theo dõi',
                ),
                SearchUserItem(
                  avatar: 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/Framer_logo.svg/512px-Framer_logo.svg.png',
                  name: 'framer.university',
                  subtitle: 'Framer University',
                  desc:
                      'I share Framer tutorials & resources. Mastered Framer and I’ll show how you can do it too....',
                  followers: '13K người theo dõi',
                ),
                SearchUserItem(
                  avatar: 'https://assets.materialup.com/uploads/c882e50e-8ee3-4c32-9021-bf01581dc16a/preview.png',
                  name: 'iqonicdesign',
                  subtitle: 'Iqonic Design',
                  desc:
                      '✨ Daily UI/UX inspirations\n💡 Discover new ideas for Websites\n💝 Freebies for Designers & Developers',
                  followers: '40.2K người theo dõi',
                ),
                SearchUserItem(
                  avatar: 'https://pbs.twimg.com/profile_images/1663555718885046274/KdF_EBAX_400x400.jpg',
                  name: 'daily_ai_smart_tools',
                  subtitle: 'AI Tools & News | Tech...',
                  desc:
                      '🔍 Exploring the future of technology through AI tools, breaking AI news, and the latest innovation....',
                  followers: '2.9K người theo dõi',
                ),
                SearchUserItem(
                  avatar: 'https://pbs.twimg.com/profile_images/1663555718885046274/KdF_EBAX_400x400.jpg',
                  name: 'daily_ai_smart_tools',
                  subtitle: 'AI Tools & News | Tech...',
                  desc:
                      '🔍 Exploring the future of technology through AI tools, breaking AI news, and the latest innovation....',
                  followers: '2.9K người theo dõi',
                ),
                SearchUserItem(
                  avatar: 'https://pbs.twimg.com/profile_images/1663555718885046274/KdF_EBAX_400x400.jpg',
                  name: 'daily_ai_smart_tools',
                  subtitle: 'AI Tools & News | Tech...',
                  desc: '🔍 Exploring the future of technology through AI tools, breaking AI news, and the latest innovation....',
                  followers: '2.9K người theo dõi',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
