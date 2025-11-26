// Màn hình chi tiết cuộc trò chuyện
import 'dart:async'; // Để sử dụng Future.delayed
import 'dart:ui';

import 'package:flutter/material.dart';
// import 'package:intl/intl.dart'; // Nếu bạn muốn định dạng ngày tháng phức tạp hơn

class ChatDetailScreen extends StatefulWidget {
  final Map<String, dynamic> chat;
  final Function(String chatId)? onReadMessages; // Callback để báo đã đọc

  const ChatDetailScreen({
    super.key,
    required this.chat,
    this.onReadMessages, // Nhận callback
  });

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = []; // Khởi tạo rỗng
  bool _isLoadingMessages = true; // Trạng thái loading tin nhắn
  bool _isSendingMessage = false; // Trạng thái đang gửi tin nhắn

  @override
  void initState() {
    super.initState();
    _fetchChatMessages(); // Gọi hàm fetch tin nhắn
    // Gọi callback báo đã đọc tin nhắn khi màn hình được khởi tạo
    if (widget.onReadMessages != null && (widget.chat['unread'] ?? false)) {
      // Delay một chút để đảm bảo UI đã build xong trước khi pop (nếu có logic pop ngay)
      // Hoặc có thể gọi trực tiếp nếu logic của bạn cho phép
      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onReadMessages!(widget.chat["id"]);
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchChatMessages() async {
    if (!mounted) return;
    setState(() {
      _isLoadingMessages = true;
    });

    // --- MÔ PHỎNG GỌI API ---
    await Future.delayed(const Duration(seconds: 1)); // Giả lập độ trễ mạng

    // Dữ liệu mẫu, trong thực tế bạn sẽ parse từ response API
    final List<Map<String, dynamic>> fetchedMessages = [
      {
        "id": "msg1",
        "sender": "recruiter",
        "text":
            "Chào bạn, cảm ơn bạn đã quan tâm đến vị trí ${widget.chat["position"]} tại ${widget.chat["name"]}.",
        "time": "08:30 AM",
        "timestamp":
            DateTime.now()
                .subtract(const Duration(hours: 2, minutes: 30))
                .millisecondsSinceEpoch,
      },
      {
        "id": "msg2",
        "sender": "recruiter",
        "text": "Hồ sơ của bạn đã được chúng tôi xem xét và đánh giá cao.",
        "time": "08:31 AM",
        "timestamp":
            DateTime.now()
                .subtract(const Duration(hours: 2, minutes: 29))
                .millisecondsSinceEpoch,
      },
      {
        "id": "msg3",
        "sender": "user",
        "text": "Dạ, em cảm ơn quý công ty đã xem xét hồ sơ của em.",
        "time": "08:35 AM",
        "timestamp":
            DateTime.now()
                .subtract(const Duration(hours: 2, minutes: 25))
                .millisecondsSinceEpoch,
      },
      {
        "id": "msg4",
        "sender": "recruiter",
        "text": widget.chat["message"], // Tin nhắn cuối cùng từ danh sách chat
        "time": widget.chat["time"],
        "timestamp":
            DateTime.now()
                .subtract(const Duration(hours: 1))
                .millisecondsSinceEpoch, // Cần timestamp thực tế
      },
      if (widget.chat["jobStatus"] == "Mời phỏng vấn" ||
          widget.chat["jobStatus"] == "Đã phỏng vấn")
        {
          "id": "msg5",
          "sender": "user",
          "text": "Dạ, em có thể tham gia phỏng vấn vào thứ 5 tuần này ạ.",
          "time": "10:15 AM",
          "timestamp": DateTime.now().millisecondsSinceEpoch,
        },
    ];
    // --- KẾT THÚC MÔ PHỎNG ---

    if (mounted) {
      setState(() {
        _messages = fetchedMessages;
        _isLoadingMessages = false;
      });
      _scrollToBottom(
        isAnimated: false,
      ); // Cuộn xuống dưới sau khi tải tin nhắn
    }
  }

  void _scrollToBottom({bool isAnimated = true, int delayMs = 100}) {
    // Delay một chút để đảm bảo ListView đã cập nhật xong item count
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (_scrollController.hasClients) {
        if (isAnimated) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSendingMessage) return;

    if (mounted) {
      setState(() {
        _isSendingMessage = true;
      });
    }

    final newMessage = {
      "id": "temp_${DateTime.now().millisecondsSinceEpoch}", // ID tạm thời
      "sender": "user",
      "text": text,
      "time": _formatTime(DateTime.now()), // Định dạng thời gian hiện tại
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "status": "sending", // Trạng thái gửi
    };

    // Thêm tin nhắn vào UI ngay lập tức với trạng thái "sending"
    if (mounted) {
      setState(() {
        _messages.add(newMessage);
        _messageController.clear();
      });
      _scrollToBottom();
    }

    // --- MÔ PHỎNG GỌI API GỬI TIN NHẮN ---
    await Future.delayed(const Duration(seconds: 1)); // Giả lập độ trễ mạng
    bool success = true; // Giả sử gửi thành công
    // --- KẾT THÚC MÔ PHỎNG ---

    if (mounted) {
      setState(() {
        // Cập nhật trạng thái tin nhắn sau khi có kết quả từ server
        final messageIndex = _messages.indexWhere(
          (msg) => msg["id"] == newMessage["id"],
        );
        if (messageIndex != -1) {
          _messages[messageIndex]["status"] = success ? "sent" : "failed";
          if (success) {
            _messages[messageIndex]["id"] =
                "server_${DateTime.now().millisecondsSinceEpoch}"; // Cập nhật ID từ server (nếu có)
          }
        }
        _isSendingMessage = false;
      });
    }
  }

  String _formatTime(DateTime dateTime) {
    // Sử dụng intl package nếu cần định dạng phức tạp hơn
    String period = dateTime.hour < 12 ? 'AM' : 'PM';
    int hour = dateTime.hour % 12;
    if (hour == 0) hour = 12; // 0h là 12 AM, 12h là 12 PM
    return "${hour.toString()}:${dateTime.minute.toString().padLeft(2, '0')} $period";
  }

  // Hàm kiểm tra xem có nên hiển thị dấu phân cách ngày không
  bool _shouldShowDateSeparator(int currentIndex) {
    if (currentIndex == 0) return true; // Luôn hiển thị cho tin nhắn đầu tiên
    final currentMessageTimestamp = DateTime.fromMillisecondsSinceEpoch(
      _messages[currentIndex]["timestamp"],
    );
    final previousMessageTimestamp = DateTime.fromMillisecondsSinceEpoch(
      _messages[currentIndex - 1]["timestamp"],
    );
    // So sánh ngày, tháng, năm
    return currentMessageTimestamp.year != previousMessageTimestamp.year ||
        currentMessageTimestamp.month != previousMessageTimestamp.month ||
        currentMessageTimestamp.day != previousMessageTimestamp.day;
  }

  String _formatDateSeparator(DateTime dateTime) {
    final now = DateTime.now();
    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return "Hôm nay";
    } else if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day - 1) {
      return "Hôm qua";
    }
    // Sử dụng intl.DateFormat cho định dạng phức tạp hơn nếu muốn
    return "${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Màu nền chat hiện đại hơn
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1D2129), // Màu chữ AppBar
        leading: IconButton(
          // Thêm nút back rõ ràng
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _getAvatarColor(
                widget.chat["id"]?.toString() ?? "0",
              ),
              child: Text(
                widget.chat["avatar"]?.toString() ?? "?",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chat["name"]?.toString() ?? "Nhà tuyển dụng",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600, // Đậm hơn chút
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.chat["isOnline"] ?? false)
                    Text(
                      "Đang hoạt động",
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.green[600],
                      ),
                    )
                  else
                    Text(
                      "Ngoại tuyến",
                      style: TextStyle(fontSize: 11.5, color: Colors.grey[500]),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined, size: 22),
            tooltip: "Gọi",
            onPressed: () {
              /*   Logic gọi */
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, size: 22),
            tooltip: "Thông tin",
            onPressed: () {
              /*   Hiển thị thông tin chi tiết */
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Khu vực thông tin việc làm
          if (widget.chat["position"] != null &&
              widget.chat["jobStatus"] != null)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    /*   Điều hướng đến chi tiết công việc */
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10), // Giảm padding chút
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha:0.05), // Màu nền nhẹ hơn
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.withValues(alpha:0.15)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.work_outline_rounded,
                          color: Colors.blue[600],
                          size: 26,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.chat["position"]} tại ${widget.chat["name"]}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.blue[700],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    widget.chat["jobStatus"]?.toString() ?? "",
                                  ).withValues(alpha:0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  widget.chat["jobStatus"]?.toString() ?? "N/A",
                                  style: TextStyle(
                                    color: _getStatusColor(
                                      widget.chat["jobStatus"]?.toString() ??
                                          "",
                                    ),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.blue[600],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          // Phần chat
          Expanded(
            child:
                _isLoadingMessages
                    ? const Center(child: CircularProgressIndicator())
                    : _messages.isEmpty
                    ? Center(
                      child: Text(
                        "Chưa có tin nhắn nào.",
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                    )
                    : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final showDateSeparator = _shouldShowDateSeparator(
                          index,
                        );

                        return Column(
                          children: [
                            if (showDateSeparator)
                              _buildDateSeparator(
                                DateTime.fromMillisecondsSinceEpoch(
                                  message["timestamp"],
                                ),
                              ),
                            if (message["sender"] == "recruiter")
                              _buildReceivedMessage(
                                message["text"],
                                message["time"],
                              )
                            else
                              _buildSentMessage(
                                message["text"],
                                message["time"],
                                message["status"],
                              ),
                          ],
                        );
                      },
                    ),
          ),
          // Phần nhập tin nhắn
          _buildMessageInputField(),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha:0.15), // Màu nền cho dấu ngày
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDateSeparator(date),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha:0.08),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        // Đảm bảo không bị che bởi bottom navigation/notch
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end, // Canh các item theo cuối
          children: [
            IconButton(
              icon: Icon(
                Icons.add_photo_alternate_outlined,
                color: Colors.blue[600],
                size: 26,
              ),
              tooltip: "Gửi ảnh",
              onPressed:
                  _isSendingMessage
                      ? null
                      : () {
                        /*   Logic gửi ảnh */
                      },
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(
                  bottom: 2,
                ), //  Padding để TextField không quá sát
                child: TextField(
                  controller: _messageController,
                  maxLines: null, // Cho phép nhiều dòng
                  keyboardType: TextInputType.multiline,
                  textInputAction:
                      TextInputAction
                          .newline, //  Thêm nút xuống dòng trên bàn phím nếu cần
                  decoration: InputDecoration(
                    hintText: "Nhập tin nhắn...",
                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(
                        color: Colors.blue[600]!,
                        width: 1.5,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white, //  Nền trắng cho TextField
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10, // Điều chỉnh padding dọc
                    ),
                    suffixIcon: IconButton(
                      // Icon gửi tích hợp vào TextField
                      icon: Icon(
                        Icons.emoji_emotions_outlined,
                        color: Colors.grey[500],
                        size: 22,
                      ),
                      onPressed:
                          _isSendingMessage
                              ? null
                              : () {
                                /*   Logic chọn emoji */
                              },
                    ),
                  ),
                  onSubmitted: _isSendingMessage ? null : (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon:
                  _isSendingMessage
                      ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                      : Icon(
                        Icons.send_rounded,
                        color: Colors.blue[600],
                        size: 28,
                      ),
              tooltip: "Gửi",
              onPressed: _isSendingMessage ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceivedMessage(String message, String time) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ), // Giới hạn chiều rộng
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  topLeft: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14.5,
                  height: 1.35,
                  color: Color(0xFF1D2129),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8),
              child: Text(
                time,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSentMessage(String message, String time, String? status) {
    IconData statusIcon;
    Color statusColor = Colors.grey[500]!;

    switch (status) {
      case "sending":
        statusIcon = Icons.access_time_rounded;
        statusColor = Colors.grey[500]!;
        break;
      case "sent":
        statusIcon = Icons.done_rounded; // Đã gửi
        statusColor = Colors.grey[500]!;
        break;
      case "delivered": // Bạn có thể thêm trạng thái "delivered"
        statusIcon = Icons.done_all_rounded;
        statusColor = Colors.grey[500]!;
        break;
      case "read": // Và "read"
        statusIcon = Icons.done_all_rounded;
        statusColor = Colors.blue[600]!; // Màu xanh khi đã đọc
        break;
      case "failed":
        statusIcon = Icons.error_outline_rounded;
        statusColor = Colors.red[400]!;
        break;
      default: // Mặc định (nếu status null hoặc không khớp)
        statusIcon = Icons.done_rounded; // Hoặc không hiển thị gì cả
    }

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue[600],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha:0.15),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  height: 1.35,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 4,
                right: 0,
              ), //  Điều chỉnh padding
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  if (status != null) ...[
                    // Chỉ hiển thị icon nếu có status
                    const SizedBox(width: 4),
                    Icon(statusIcon, size: 15, color: statusColor),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(String id) {
    final List<Color> colors = [
      Colors.blueGrey[600]!,
      Colors.indigo[500]!,
      Colors.deepOrange[500]!,
      Colors.teal[500]!,
      Colors.brown[400]!,
      Colors.purple[400]!,
      Colors.red[400]!,
    ];
    int parsedId = int.tryParse(id) ?? 0;
    int colorIndex =
        parsedId.abs() % colors.length; // Sử dụng abs() để đảm bảo id dương
    return colors[colorIndex];
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      // Chuyển sang lowercase để đối chiếu dễ hơn
      case "đã phản hồi":
        return Colors.blue[600]!;
      case "đang xem xét":
        return Colors.orange[600]!;
      case "mời phỏng vấn":
        return Colors.green[500]!;
      case "đã phỏng vấn":
        return Colors.purple[500]!;
      default:
        return Colors.grey[500]!;
    }
  }
}
