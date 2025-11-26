import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:math' as math;

import 'package:job_connect/config/constant/app_strings.dart';
import 'package:job_connect/config/widgets/custom_app_bar.dart';

typedef RefreshCallback = Future<void> Function();

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({
    super.key,
  });

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isLoadingScreen = true;

  late final GenerativeModel _model;
  late ChatSession _chat;
  final String _apiKey = dotenv.env['CHATBOT_API_KEY'] ?? "YOUR_CHATBOT_API_KEY_FALLBACK";

  late AnimationController _typingAnimationController; 

  @override
  void initState() {
    super.initState();

    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.75,
        maxOutputTokens: 350,
      ),
      systemInstruction: Content.text(AppStrings.systemPrompt),
    );

    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _initializeChat();
  }

  void _initializeChat() async {
    if (mounted) {
      setState(() {
        _isLoadingScreen = true;
        _messages.clear();
      });
    }
    _chat = _model.startChat(history: []);
    _addBotMessage(
      'Xin chào! Tôi là trợ lý AI tuyển dụng của ${AppStrings.appName}. Tôi có thể giúp bạn những gì liên quan đến định hướng nghề nghiệp, tìm việc, CV, hoặc phỏng vấn trong lĩnh vực IT, Thiết kế, và Marketing?',
      hasOptions: true,
      options: [
        'Tìm việc Frontend Developer',
        'Tư vấn về UI/UX Design',
        'Hỏi về Content Marketing',
        'Cách viết CV ấn tượng?',
      ],
    );
    if (mounted) setState(() => _isLoadingScreen = false);
  }

  Future<void> _onRefresh() async {
    _initializeChat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      // Tăng nhẹ delay
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350), // Tăng duration
          curve: Curves.easeOutQuad, // Curve mượt hơn
        );
      }
    });
  }

  void _addBotMessage(
    String message, {
    bool hasOptions = false,
    List<String> options = const [],
  }) {
    if (mounted) {
      setState(
        () => _messages.add(
          ChatMessage(
            message: message,
            isUser: false,
            hasOptions: hasOptions,
            options: options,
            onOptionTap: _handleOptionTap,
          ),
        ),
      );
    }
    _scrollToBottom();
  }

  void _handleOptionTap(String option) {
    _addMessage(option, isUser: true, isOption: true); // Thêm cờ isOption
    _processMessageForAI(option);
  }

  void _addMessage(String text, {required bool isUser, bool isOption = false}) {
    if (mounted) {
      setState(
        () => _messages.add(
          ChatMessage(message: text, isUser: isUser, isOptionMessage: isOption),
        ),
      );
    }
    _scrollToBottom();
  }

  Future<void> _processMessageForAI(String text) async {
    if (_apiKey == "YOUR_CHATBOT_API_KEY_FALLBACK" || _apiKey.isEmpty) {
      _addBotMessage(
        "Xin lỗi, dịch vụ AI chưa được cấu hình đúng. Vui lòng liên hệ quản trị viên.",
      );
      return;
    }
    if (mounted) setState(() => _isTyping = true);
    await _sendMessageToChatBot(text);
    if (mounted) setState(() => _isTyping = false);
  }

  List<String> _generateQuickOptions(
    String userMessage,
    String aiResponseText,
  ) {
    String lowerUserMessage = userMessage.toLowerCase();
    String lowerAiResponse = aiResponseText.toLowerCase();
    List<String> options = [];

    // Ưu tiên các gợi ý dựa trên câu hỏi của người dùng trước
    final Map<List<String>, List<String>> userKeywordsToOptions = {
      ['frontend', 'react', 'vue', 'angular']: [
        "Mức lương Frontend Dev?",
        "Công ty nào tuyển Frontend?",
        "Học thêm gì cho Frontend?",
        "So sánh React và Vue?",
      ],
      ['backend', 'java', 'python', 'node', 'php', 'api']: [
        "Backend dùng ngôn ngữ nào hot?",
        "Tìm hiểu về Microservices.",
        "Lộ trình Backend Developer?",
        "Công cụ cho Backend?",
      ],
      ['mobile', 'flutter', 'react native', 'android', 'ios']: [
        "Học Flutter mất bao lâu?",
        "So sánh Flutter và React Native?",
        "Xu hướng phát triển Mobile App?",
        "Công ty Mobile hàng đầu?",
      ],
      ['ui/ux', 'figma', 'adobe xd', 'user experience', 'user interface']: [
        "Quy trình thiết kế UI/UX?",
        "Tài liệu học Figma?",
        "Portfolio UI/UX gồm những gì?",
        "Case study UI/UX hay?",
      ],
      ['graphic design', 'photoshop', 'illustrator', 'logo', 'banner']: [
        "Học Graphic Design ở đâu?",
        "Các loại hình Graphic Design?",
        "Làm Freelance Graphic Design?",
        "Công cụ thay thế Photoshop?",
      ],
      ['digital marketing', 'seo', 'sem', 'content', 'social media', 'ads']: [
        "Cách tối ưu SEO Onpage?",
        "Chạy quảng cáo Facebook hiệu quả?",
        "Xây dựng chiến lược Content Marketing?",
        "Công cụ Digital Marketing?",
      ],
      ['cv', 'resume', 'phỏng vấn', 'interview', 'xin việc', 'apply']: [
        "Mẹo viết CV cho Fresher?",
        "Cách trả lời câu hỏi khó khi phỏng vấn?",
        "Những lỗi cần tránh khi đi phỏng vấn?",
        "Chuẩn bị gì trước ngày phỏng vấn?",
      ],
      ['lương', 'mức lương', 'salary', 'thu nhập']: [
        "Mức lương IT hiện nay?",
        "Cách deal lương hiệu quả?",
        "Lương Fresher bao nhiêu?",
        "Các yếu tố ảnh hưởng đến lương?",
      ],
      ['học', 'khóa học', 'lộ trình', 'bắt đầu', 'tài liệu']: [
        "Nên học ngôn ngữ lập trình nào trước?",
        "Tài liệu tự học UI/UX?",
        "Lộ trình cho người mới bắt đầu Marketing?",
        "Khóa học Data Science uy tín?",
      ],
    };

    for (var entry in userKeywordsToOptions.entries) {
      if (entry.key.any((keyword) => lowerUserMessage.contains(keyword))) {
        options.addAll(entry.value);
      }
    }

    // Sau đó, thêm các gợi ý dựa trên phản hồi của AI (ít ưu tiên hơn)
    final Map<List<String>, List<String>> aiKeywordsToOptions = {
      ['cơ hội', 'việc làm', 'công ty', 'vị trí']: [
        "Gợi ý công ty phù hợp?",
        "Tìm việc làm remote?",
        "Các vị trí đang tuyển nhiều?",
        "Mô tả thêm về công việc này.",
      ],
      ['kỹ năng', 'kinh nghiệm', 'học thêm', 'cải thiện']: [
        "Cần kỹ năng gì cho vị trí X?",
        "Làm sao để có kinh nghiệm thực tế?",
        "Nên học chứng chỉ nào?",
        "Cách cải thiện kỹ năng Y?",
      ],
      // Thêm các từ khóa và gợi ý khác dựa trên các chủ đề AI thường trả lời
    };

    for (var entry in aiKeywordsToOptions.entries) {
      if (entry.key.any((keyword) => lowerAiResponse.contains(keyword))) {
        options.addAll(entry.value);
      }
    }

    // Nếu không có gợi ý nào, thêm các câu hỏi chung chung hơn
    if (options.isEmpty) {
      if (lowerUserMessage.contains("it") ||
          lowerUserMessage.contains("lập trình")) {
        options.addAll([
          "Công nghệ nào đang là xu hướng?",
          "Hỏi về DevOps.",
          "Tìm hiểu về An toàn thông tin.",
        ]);
      } else if (lowerUserMessage.contains("thiết kế")) {
        options.addAll([
          "Xu hướng thiết kế 2024?",
          "Nguồn cảm hứng cho Designer?",
          "Học 3D Modeling có khó không?",
        ]);
      } else if (lowerUserMessage.contains("marketing")) {
        options.addAll([
          "Tìm hiểu về Branding.",
          "Nghiên cứu thị trường là gì?",
          "Các KPI trong Marketing?",
        ]);
      } else {
        options.addAll([
          "Kể thêm về ${AppStrings.appName}.",
          "Quy trình tuyển dụng thường thế nào?",
          "Tôi có câu hỏi khác.",
        ]);
      }
    }

    // Loại bỏ trùng lặp, trộn và lấy số lượng giới hạn
    List<String> uniqueOptions = options.toSet().toList();
    uniqueOptions.shuffle(math.Random()); // Trộn ngẫu nhiên
    return uniqueOptions.take(3).toList(); // Hiển thị tối đa 3 gợi ý
  }

  Future<void> _sendMessageToChatBot(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      final aiResponseText = response.text;

      if (aiResponseText != null && aiResponseText.isNotEmpty) {
        List<String> quickOptions = _generateQuickOptions(
          message,
          aiResponseText,
        ); // Truyền cả tin nhắn người dùng
        _addBotMessage(
          aiResponseText,
          hasOptions: quickOptions.isNotEmpty,
          options: quickOptions,
        );
      } else {
        _addBotMessage(
          'Xin lỗi, tôi không nhận được phản hồi từ AI. Vui lòng thử lại.',
        );
      }
    } catch (e) {
      print('Lỗi khi gửi tin nhắn đến ChatBot: $e');
      String errorMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại sau.';
      if (e is GenerativeAIException) {
        errorMessage = 'Lỗi từ ChatBot: ${e.message}.';
        if (e.message.toLowerCase().contains('api key not valid')) {
          errorMessage =
              'API Key không hợp lệ. Vui lòng kiểm tra lại trong file .env.';
        } else if (e.message.toLowerCase().contains('quota') ||
            e.message.toLowerCase().contains('limit')) {
          errorMessage =
              'Đã đạt giới hạn yêu cầu tới AI. Vui lòng thử lại sau ít phút.';
        }
      }
      _addBotMessage(errorMessage);
    }
  }

  void _handleSubmitted(String text) async {
    final String trimmedText = text.trim();
    if (trimmedText.isEmpty) return;
    _messageController.clear();
    FocusScope.of(context).unfocus(); // Ẩn bàn phím
    _addMessage(trimmedText, isUser: true);
    _processMessageForAI(trimmedText);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppbar(
        title: Row(
          // Thêm icon vào AppBar
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.smart_toy_outlined,
              color: Colors.white.withValues(alpha:0.9),
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              'AI Tư Vấn ${AppStrings.appName}',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: theme.primaryColor,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: Colors.white.withValues(alpha:0.9),
            ),
            tooltip: 'Bắt đầu lại cuộc trò chuyện',
            onPressed:
                _isLoadingScreen
                    ? null
                    : _onRefresh, // Disable khi đang loading
            splashRadius: 22,
          ),
        ],
      ),
      body: Column(
        children: [
          // Bỏ Container thông tin bot ở đây, đã có ở AppBar
          Expanded(
            child:
                _isLoadingScreen
                    ? Center(
                      child: SpinKitRipple(
                        color: theme.primaryColor,
                        size: 60.0,
                      ),
                    ) // Animation loading khác
                    : GestureDetector(
                      // Để ẩn bàn phím khi chạm ra ngoài ListView
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 16.0,
                        ), // Tăng padding
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          // Animation cho từng tin nhắn
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 350),
                            child: SlideAnimation(
                              verticalOffset: 40.0,
                              child: FadeInAnimation(child: _messages[index]),
                            ),
                          );
                        },
                      ),
                    ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 16.0,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16, // Tăng kích thước avatar
                    backgroundColor: theme.primaryColor.withValues(alpha:0.1),
                    child: Image.asset(
                      'assets/images/ai_assistant.png',
                      height: 20,
                      color: theme.primaryColor,
                      errorBuilder:
                          (ctx, err, _) => Icon(
                            Icons.android_rounded,
                            size: 18,
                            color: theme.primaryColor,
                          ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[700] : Colors.white,
                      borderRadius: BorderRadius.circular(
                        20,
                      ).copyWith(bottomLeft: const Radius.circular(5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.07),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SpinKitThreeBounce(
                          color: theme.primaryColor,
                          size: 18.0,
                        ), // Kích thước nhỏ hơn
                        const SizedBox(width: 10),
                        Text(
                          'AI đang nhập...',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha:0.8),
                            fontSize: 14.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Container(
            // Khu vực nhập liệu
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: theme.cardColor, // Màu nền từ theme
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha:0.1),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
              // border: Border(top: BorderSide(color: theme.dividerColor, width: 0.8)) // Có thể thêm border top
            ),
            child: SafeArea(
              // Đảm bảo không bị che bởi bottom system UI
              top: false, // Chỉ áp dụng cho bottom
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end, // Căn các item theo bottom
                children: [
                  // IconButton( // Nút đính kèm (tùy chọn)
                  //   icon: Icon(Icons.add_circle_outline_rounded, color: theme.primaryColor, size: 28),
                  //   tooltip: 'Thêm tùy chọn',
                  //   onPressed: () { /*   Mở menu đính kèm */ },
                  //   padding: const EdgeInsets.all(10),
                  // ),
                  // const SizedBox(width: 4),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Đặt câu hỏi cho AI...',
                        hintStyle: TextStyle(
                          color: theme.hintColor.withValues(alpha:0.7),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: theme.dividerColor,
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: theme.dividerColor.withValues(alpha:0.7),
                            width: 1.2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceVariant.withValues(alpha:
                          0.4,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: theme.iconTheme.color?.withValues(alpha:0.6),
                            size: 20,
                          ),
                          onPressed: () => _messageController.clear(),
                          tooltip: "Xóa nội dung",
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      minLines: 1,
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: _handleSubmitted,
                      textInputAction: TextInputAction.send,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: theme.primaryColor,
                    shape: const CircleBorder(),
                    elevation: 2,
                    shadowColor: theme.primaryColor.withValues(alpha:0.4),
                    child: InkWell(
                      onTap:
                          _messageController.text.trim().isEmpty
                              ? null
                              : () {
                                _handleSubmitted(_messageController.text);
                                FocusScope.of(
                                  context,
                                ).requestFocus(FocusNode());
                              },
                      customBorder: const CircleBorder(),
                      splashColor: Colors.white.withValues(alpha:0.3),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ChatMessage Widget
class ChatMessage extends StatelessWidget {
  final String message;
  final bool isUser;
  final bool hasOptions;
  final List<String> options;
  final Function(String)? onOptionTap;
  final bool
  isOptionMessage; // Cờ để xác định đây là tin nhắn từ việc chọn option

  const ChatMessage({
    Key? key,
    required this.message,
    required this.isUser,
    this.hasOptions = false,
    this.options = const [],
    this.onOptionTap,
    this.isOptionMessage = false, // Mặc định là false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final userBubbleColor = theme.primaryColor;
    final botBubbleColor =
        isDarkMode ? const Color(0xFF3A3A3C) : Colors.white; // Màu bot bubble
    final botTextColor =
        isDarkMode
            ? Colors.white.withValues(alpha:0.9)
            : theme.textTheme.bodyLarge!.color;
    final optionBubbleColor = theme.primaryColor.withValues(alpha:
      0.15,
    ); // Màu cho tin nhắn option của user
    final optionTextColor = theme.primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // Tăng padding dọc
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(
                left: 0,
                bottom: 6,
                right: 0,
              ), // Điều chỉnh padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: theme.primaryColor.withValues(alpha:0.1),
                    child: Image.asset(
                      'assets/images/ai_assistant.png',
                      height: 19,
                      color: theme.primaryColor,
                      errorBuilder:
                          (ctx, err, _) => Icon(
                            Icons.android_rounded,
                            size: 17,
                            color: theme.primaryColor,
                          ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'AI ${AppStrings.appName}', // Tên ngắn gọn hơn
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha:
                        0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ), // Giảm độ rộng tối đa
              margin: EdgeInsets.only(
                left:
                    isUser
                        ? (MediaQuery.of(context).size.width * 0.18)
                        : 0, // Điều chỉnh margin
                right: isUser ? 0 : (MediaQuery.of(context).size.width * 0.18),
                top:
                    isUser && !isOptionMessage
                        ? 4
                        : 0, // Thêm top margin cho user message (không phải option)
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color:
                    isUser
                        ? (isOptionMessage
                            ? optionBubbleColor
                            : userBubbleColor)
                        : botBubbleColor,
                borderRadius: BorderRadius.only(
                  // Bo góc tùy chỉnh
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft:
                      isUser
                          ? const Radius.circular(20)
                          : const Radius.circular(5),
                  bottomRight:
                      isUser
                          ? const Radius.circular(5)
                          : const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha:isUser ? 0.12 : 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                message,
                style: TextStyle(
                  color:
                      isUser
                          ? (isOptionMessage ? optionTextColor : Colors.white)
                          : botTextColor,
                  fontSize: 16, // Font lớn hơn
                  height: 1.45, // Tăng chiều cao dòng
                  fontWeight:
                      isUser && isOptionMessage
                          ? FontWeight.w500
                          : (isUser ? FontWeight.normal : FontWeight.normal),
                ),
              ),
            ),
          ),
          if (hasOptions && options.isNotEmpty && !isUser)
            Container(
              margin: const EdgeInsets.only(
                top: 14,
                left: 0,
                right: 0,
                bottom: 6,
              ),
              alignment: Alignment.centerLeft,
              child: SingleChildScrollView(
                // Cho phép cuộn ngang nếu nhiều options
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  // Sử dụng Row thay vì Wrap để đảm bảo trên một hàng
                  children:
                      options.map((option) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            right: 10.0,
                          ), // Khoảng cách giữa các chip
                          child: ActionChip(
                            label: Text(option),
                            onPressed: () => onOptionTap?.call(option),
                            backgroundColor: theme.colorScheme.primaryContainer
                                .withValues(alpha:0.6), // Màu nền chip
                            labelStyle: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600, // Đậm hơn
                              fontSize: 13.5, // Font lớn hơn
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(
                                color: theme.colorScheme.primary.withValues(alpha:
                                  0.4,
                                ),
                                width: 1.2,
                              ), // Border rõ hơn
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ), // Tăng padding
                            elevation: 1, // Thêm elevation
                            pressElevation: 3,
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
