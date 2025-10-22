import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/widgets/custom_search_bar.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.h),
              child: CustomSearchBar(
                hintText: 'Tìm kiếm bạn bè',
              ),
            ),
            Expanded(
              child: ListView(
                children: const [
                  SearchUserItem(
                    avatar: 'https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png',
                    name: 'githubprojects',
                    subtitle: 'Github Projects',
                    followers: '231K người theo dõi',
                  ),
                  SearchUserItem(
                    avatar: 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/Framer_logo.svg/512px-Framer_logo.svg.png',
                    name: 'framer.university',
                    subtitle: 'Framer University',
                    followers: '13K người theo dõi',
                  ),
                  SearchUserItem(
                    avatar: 'https://assets.materialup.com/uploads/c882e50e-8ee3-4c32-9021-bf01581dc16a/preview.png',
                    name: 'iqonicdesign',
                    subtitle: 'Iqonic Design',
                    followers: '40.2K người theo dõi',
                  ),
                  SearchUserItem(
                    avatar: 'https://pbs.twimg.com/profile_images/1663555718885046274/KdF_EBAX_400x400.jpg',
                    name: 'daily_ai_smart_tools',
                    subtitle: 'AI Tools & News | Tech...',
                    followers: '2.9K người theo dõi',
                  ),
                  SearchUserItem(
                    avatar: 'https://pbs.twimg.com/profile_images/1663555718885046274/KdF_EBAX_400x400.jpg',
                    name: 'daily_ai_smart_tools',
                    subtitle: 'AI Tools & News | Tech...',
                    followers: '2.9K người theo dõi',
                  ),
                  SearchUserItem(
                    avatar: 'https://pbs.twimg.com/profile_images/1663555718885046274/KdF_EBAX_400x400.jpg',
                    name: 'daily_ai_smart_tools',
                    subtitle: 'AI Tools & News | Tech...',
                    followers: '2.9K người theo dõi',
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
