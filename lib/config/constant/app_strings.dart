import 'package:flutter/material.dart';

class AppStrings {
  static const String appName = 'UniJobs';
  static const String appCV = 'Hồ sơ tìm việc';
  static const String search = 'Khám phá việc làm';
  static const String appSocial = 'UniSocial';
  static const String appMessage = 'Hộp thư';
  static const String appProfile = 'Trang cá nhân';

  //TODO: Nội dung Intro
  static final List<Map<String, dynamic>> introContent = [
    {
      'title': 'Tìm kiếm công việc mơ ước',
      'subtitle': 'Khám phá hàng ngàn cơ hội việc làm phù hợp với kỹ năng của bạn',
      'icon': Icons.search,
    },
    {
      'title': 'Kết nối với nhà tuyển dụng',
      'subtitle': 'Tương tác trực tiếp và xây dựng mạng lưới chuyên nghiệp',
      'icon': Icons.handshake,
    },
    {
      'title': 'Phát triển sự nghiệp',
      'subtitle': 'Công cụ và nguồn lực để nâng cao kỹ năng và đạt được mục tiêu',
      'icon': Icons.trending_up,
    },
  ];

  // TODO: NỘI DUNG BANNER
  static const List<Map<String, dynamic>> bannerItems = [
    {
      'image': 'assets/images/placeholder_banner_1.jpg',
      'color': Color(0xFF6A11CB), 
      'endColor': Color(0xFF2575FC),
      'title': 'Khám phá sự nghiệp',
      'value': 1,
      'description': 'Hàng ngàn cơ hội đang chờ đón bạn mỗi ngày.',
      'icon': Icons.explore_outlined,
    },
    {
      'image': 'assets/images/placeholder_banner_2.jpg',
      'color': Color(0xFFFC5C7D), 
      'endColor': Color(0xFF6A82FB),
      'title': 'AI tư vấn thông minh',
      'value': 2,
      'description': 'Chatbot định hướng, gợi ý công việc hoàn hảo.',
      'icon': Icons.psychology_alt_outlined,
    },
    {
      'image': 'assets/images/placeholder_banner_3.jpg',
      'color': Color(0xFF00C9FF), 
      'endColor': Color(0xFF92FE9D),
      'title': 'CV đột phá ấn tượng',
      'value': 3,
      'description': 'Tạo dấu ấn riêng, chinh phục nhà tuyển dụng.',
      'icon': Icons.auto_stories_outlined,
    },
    {
      'image': 'assets/images/placeholder_banner_4.jpg',
      'color': Color(0xFFFF8008),
      'endColor': Color(0xFFFFC837),
      'title': 'Mạng lưới doanh nghiệp',
      'value': 4,
      'description': 'Kết nối trực tiếp, mở rộng mối quan hệ.',
      'icon': Icons.hub_outlined,
    },
  ];

  // TODO: MẸO ỨNG TUYỂN
  static const List<String> applyTipsList = [
    "Đảm bảo CV của bạn được cập nhật và không có lỗi chính tả.",
    "Viết thư xin việc (Cover Letter) thể hiện sự quan tâm và phù hợp của bạn với vị trí.",
    "Kiểm tra kỹ thông tin trước khi gửi để tránh sai sót.",
    "Nhà tuyển dụng thường đánh giá cao sự chuyên nghiệp và cẩn thận.",
  ];

  // TODO: FAQ
  static const List<Map<String, String>> faqItemsNormal = [
    {
      'question': 'Làm sao để tạo tài khoản trên ${AppStrings.appName}?',
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
          'Ứng dụng ${AppStrings.appName} hoàn toàn miễn phí cho ứng viên khi tạo hồ sơ và ứng tuyển.\nMột số tính năng cao cấp (như làm nổi bật hồ sơ) có thể yêu cầu trả phí.',
    },
    {
      'question': 'Tôi quên mật khẩu thì làm thế nào?',
      'answer':
          'Bạn có thể:\n1. Chọn "Quên mật khẩu" tại màn hình đăng nhập\n2. Nhập email đã đăng ký\n3. Kiểm tra email để đặt lại mật khẩu mới',
    },
  ];

  // TODO: FAQ SOCIAL
  static const List<Map<String, String>> faqItemsSocial = [
    {
      'question': 'Làm sao để tạo tài khoản trên ${AppStrings.appName}?',
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

  // TODO: POLICY
  static const privacyPolicyItems = [
    {
      'title': 'Chính Sách Bảo Mật ${AppStrings.appName}',
      'content': 'Chúng tôi cam kết bảo vệ thông tin cá nhân của bạn khi sử dụng hệ thống ứng tuyển việc làm. '
          'Dưới đây là các thông tin chi tiết về cách chúng tôi thu thập, lưu trữ và sử dụng dữ liệu của bạn một cách minh bạch và an toàn.',
    },
    {
      'title': '1. Thu thập thông tin:',
      'content': '- Chúng tôi chỉ thu thập các thông tin cần thiết như tên, email, số điện thoại, và hồ sơ ứng tuyển của bạn để phục vụ mục đích tuyển dụng.',
    },
    {
      'title': '2. Sử dụng thông tin:',
      'content': '- Thông tin của bạn sẽ được sử dụng để kết nối bạn với nhà tuyển dụng phù hợp, cải thiện trải nghiệm của bạn trên hệ thống, và không được sử dụng cho bất kỳ mục đích nào khác mà không có sự đồng ý của bạn.',
    },
    {
      'title': '3. Bảo mật thông tin:',
      'content': '- Chúng tôi áp dụng các biện pháp bảo mật tiên tiến để đảm bảo thông tin cá nhân của bạn được bảo vệ an toàn khỏi truy cập trái phép, mất mát hoặc lạm dụng.',
    },
    {
      'title': '4. Quyền của bạn:',
      'content': '- Bạn có quyền truy cập, chỉnh sửa hoặc yêu cầu xóa thông tin cá nhân của mình bất kỳ lúc nào. Chúng tôi sẽ xử lý yêu cầu của bạn một cách nhanh chóng và minh bạch.',
    },
    {
      'title': '5. Liên hệ:',
      'content': '- Nếu bạn có bất kỳ câu hỏi hoặc thắc mắc nào về chính sách bảo mật, vui lòng liên hệ với chúng tôi qua email hỗ trợ hoặc các kênh liên lạc chính thức.',
    },
    {
      'title': '6. Cập nhật chính sách:',
      'content': '- Chính sách bảo mật này có thể được cập nhật định kỳ để phản ánh các thay đổi trong hoạt động của chúng tôi hoặc các yêu cầu pháp lý. Chúng tôi khuyến khích bạn kiểm tra lại chính sách này thường xuyên.',
    },
    {
      'title': '7. Đồng ý với chính sách:',
      'content': '- Bằng cách sử dụng hệ thống của chúng tôi, bạn đồng ý với các điều khoản trong chính sách bảo mật này. Nếu bạn không đồng ý, vui lòng ngừng sử dụng hệ thống.',
    },
  ];
}
