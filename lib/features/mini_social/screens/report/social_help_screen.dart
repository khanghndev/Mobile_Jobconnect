import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Trợ giúp & Phản hồi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _buildSearchBar(context),
          const SizedBox(height: 24),
          _buildHeaderWithIcon(
            context,
            'Câu hỏi thường gặp',
            Icons.question_answer_rounded,
          ),
          const SizedBox(height: 16),
          _buildFAQSection(context),
          const SizedBox(height: 16),
          _buildContactSection(context),
          const SizedBox(height: 32),
          _buildFeedbackButton(context),

          _buildSearchBar(context),
          
          const SizedBox(height: 16),
          _buildFAQSection(context),
          const SizedBox(height: 24),
          _buildHeaderWithIcon(
            context,
            'Liên hệ hỗ trợ',
            Icons.support_agent_rounded,
          ),
          const SizedBox(height: 16),
          _buildContactSection(context),
          const SizedBox(height: 32),
          _buildFeedbackButton(context),
        ],
      ),
    );
  }

  Widget _buildHeaderWithIcon(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 28),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm câu hỏi trợ giúp...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onSubmitted: (value) {},
      ),
    );
  }

  Widget _buildFAQSection(BuildContext context) {
    final List<Map<String, String>> faqItems = [
      {
        'question': 'Làm sao để tạo tài khoản trên JobSocial?',
        'answer':
            'Bạn có thể tạo tài khoản bằng cách:\n1. Chọn "Đăng ký"\n2. Điền email hoặc đăng nhập bằng Google/Facebook\n3. Tạo mật khẩu an toàn\n4. Nhấn "Hoàn tất" để sử dụng ứng dụng',
      },
      {
        'question': 'Làm sao để kết nối với nhà tuyển dụng?',
        'answer':
            'Bạn có thể:\n1. Vào trang cá nhân của nhà tuyển dụng\n2. Nhấn nút "Theo dõi" hoặc "Kết nối"\n3. Gửi tin nhắn trực tiếp để trao đổi công việc',
      },
      {
        'question': 'Tôi có thể chia sẻ bài viết tuyển dụng không?',
        'answer':
            'Hoàn toàn được. Bạn chỉ cần:\n1. Chọn bài viết tuyển dụng\n2. Nhấn nút "Chia sẻ"\n3. Chọn chia sẻ lên trang cá nhân hoặc gửi cho bạn bè',
      },
      {
        'question': 'Ứng dụng có thu phí khi ứng tuyển không?',
        'answer':
            'Ứng dụng JobSocial hoàn toàn miễn phí cho ứng viên khi tạo hồ sơ và ứng tuyển.\nMột số tính năng cao cấp (như làm nổi bật hồ sơ) có thể yêu cầu trả phí.',
      },
      {
        'question': 'Tôi quên mật khẩu thì làm thế nào?',
        'answer':
            'Bạn có thể:\n1. Chọn "Quên mật khẩu" tại màn hình đăng nhập\n2. Nhập email đã đăng ký\n3. Kiểm tra email để đặt lại mật khẩu mới',
      },
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: faqItems
              .map(
                (item) => _buildFAQItem(
                  context,
                  item['question']!,
                  item['answer']!,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        title: Text(
          question,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withValues(alpha:0.1),
          radius: 18,
          child: Icon(
            Icons.help_outline_rounded,
            color: Theme.of(context).primaryColor,
            size: 22,
          ),
        ),
        childrenPadding: const EdgeInsets.only(left: 60, right: 16, bottom: 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            answer,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.6,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildContactCard(
              context: context,
              icon: Icons.email_rounded,
              title: 'Email hỗ trợ',
              subtitle: 'support@jobsocial.com',
              color: Colors.blue,
              onTap: () {},
            ),
            _buildDivider(),
            _buildContactCard(
              context: context,
              icon: Icons.phone_rounded,
              title: 'Hotline',
              subtitle: '1900 8888',
              color: Colors.green,
              onTap: () {},
            ),
            _buildDivider(),
            _buildContactCard(
              context: context,
              icon: Icons.chat_rounded,
              title: 'Trung tâm trợ giúp',
              subtitle: 'Chat trực tiếp với CSKH',
              color: Colors.orange,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, indent: 70, endIndent: 16);
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Icon(icon, color: color, size: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.rate_review_rounded),
        label: const Text(
          'Gửi phản hồi cho JobSocial',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}
