import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chính Sách Bảo Mật')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Chính Sách Bảo Mật',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Chúng tôi cam kết bảo vệ thông tin cá nhân của bạn khi sử dụng hệ thống ứng tuyển việc làm. '
                'Dưới đây là các thông tin chi tiết về cách chúng tôi thu thập, lưu trữ và sử dụng dữ liệu của bạn một cách minh bạch và an toàn.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '1. Thu thập thông tin:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '- Chúng tôi chỉ thu thập các thông tin cần thiết như tên, email, số điện thoại, và hồ sơ ứng tuyển của bạn để phục vụ mục đích tuyển dụng.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '2. Sử dụng thông tin:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '- Thông tin của bạn sẽ được sử dụng để kết nối bạn với nhà tuyển dụng phù hợp, cải thiện trải nghiệm của bạn trên hệ thống, và không được sử dụng cho bất kỳ mục đích nào khác mà không có sự đồng ý của bạn.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '3. Bảo mật thông tin:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '- Chúng tôi áp dụng các biện pháp bảo mật tiên tiến để đảm bảo thông tin cá nhân của bạn được bảo vệ an toàn khỏi truy cập trái phép, mất mát hoặc lạm dụng.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '4. Quyền của bạn:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '- Bạn có quyền truy cập, chỉnh sửa hoặc yêu cầu xóa thông tin cá nhân của mình bất kỳ lúc nào. Chúng tôi sẽ xử lý yêu cầu của bạn một cách nhanh chóng và minh bạch.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '5. Liên hệ:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '- Nếu bạn có bất kỳ câu hỏi hoặc thắc mắc nào về chính sách bảo mật, vui lòng liên hệ với chúng tôi qua email hỗ trợ hoặc các kênh liên lạc chính thức.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '6. Cập nhật chính sách:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '- Chính sách bảo mật này có thể được cập nhật định kỳ để phản ánh các thay đổi trong hoạt động của chúng tôi hoặc các yêu cầu pháp lý. Chúng tôi khuyến khích bạn kiểm tra lại chính sách này thường xuyên.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '7. Đồng ý với chính sách:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '- Bằng cách sử dụng hệ thống của chúng tôi, bạn đồng ý với các điều khoản trong chính sách bảo mật này. Nếu bạn không đồng ý, vui lòng ngừng sử dụng hệ thống.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
