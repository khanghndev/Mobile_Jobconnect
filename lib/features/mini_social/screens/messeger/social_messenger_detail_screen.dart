import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SocialMessengerDetailScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;

  const SocialMessengerDetailScreen({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
  });

  @override
  State<SocialMessengerDetailScreen> createState() =>
      _SocialMessengerDetailScreenState();
}

class _SocialMessengerDetailScreenState
    extends State<SocialMessengerDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _editController = TextEditingController();

  final List<_Message> _messages = [
    _Message(text: "Hello 👋", isMe: false, time: DateTime.now()),
    _Message(text: "Chào bạn", isMe: true, time: DateTime.now()),
  ];

  final List<_Message> _pinnedMessages = [];

  int? _selectedMsgIndex;
  int? _editingMsgIndex;
  bool _isPinnedExpanded = true;

  void _sendMessage() {
    //TODO: gửi tin nhắn
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        _Message(text: text, isMe: true, time: DateTime.now()),
      );
    });

    _controller.clear();

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _messages.add(
          _Message(
            text: "Bot trả lời: $text",
            isMe: false,
            time: DateTime.now(),
          ),
        );
      });
    });
  }

  void _makeCall({required bool isVideo}) {
    //TODO: gọi điện
    setState(() {
      _messages.add(
        _Message(
          text: isVideo ? "Cuộc gọi video" : "Cuộc gọi thoại",
          isMe: true,
          time: DateTime.now(),
          type: MessageType.call,
          isVideo: isVideo,
          isMissed: false,
          duration: "2:13",
        ),
      );
    });

    context.push(
      '/call',
      extra: {
        'avatarUrl': "https://i.imgur.com/BoN9kdC.png",
        'userName': "Trọng Khang",
        'isVideo': isVideo,
      },
    );
  }

  void _startEditMessage(int index) {
    //TODO: bắt đầu sửa tin nhắn
    if (!_messages[index].isMe) return;
    _editController.text = _messages[index].text;
    setState(() {
      _editingMsgIndex = index;
    });
  }

  void _confirmEditMessage() {
    //TODO: xác nhận sửa tin nhắn
    if (_editingMsgIndex == null) return;
    final text = _editController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages[_editingMsgIndex!] =
          _messages[_editingMsgIndex!].copyWith(text: text, isEdited: true);
      _editingMsgIndex = null;
      _editController.clear();
    });
  }

  void _recallMessage(int index) {
    //TODO: thu hồi tin nhắn
    if (!_messages[index].isMe) return;
    setState(() {
      _messages[index] = _messages[index].copyWith(isRecalled: true);
    });
  }

  void _pinMessage(_Message msg) {
    //TODO: ghim tin nhắn
    if (!_pinnedMessages.contains(msg)) {
      setState(() {
        _pinnedMessages.add(msg);
      });
    }
  }

  void _unpinMessage(_Message msg) {
    //TODO: bỏ ghim tin nhắn
    setState(() {
      _pinnedMessages.remove(msg);
    });
  }

  void _showMessageOptions(BuildContext context, int index) async {
    //TODO: show bottomsheet tùy chọn tin nhắn
    final msg = _messages[index];

    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(
                  _pinnedMessages.contains(msg)
                      ? Icons.push_pin_outlined
                      : Icons.push_pin,
                  color: Colors.orange,
                ),
                title: Text(
                  _pinnedMessages.contains(msg)
                      ? "Bỏ ghim tin nhắn"
                      : "Ghim tin nhắn",
                ),
                onTap: () => Navigator.pop(
                  ctx,
                  _pinnedMessages.contains(msg) ? "unpin" : "pin",
                ),
              ),
              if (msg.isMe && msg.type == MessageType.text) ...[
                ListTile(
                  leading: const Icon(Icons.undo, color: Colors.red),
                  title: const Text("Thu hồi"),
                  onTap: () => Navigator.pop(ctx, "recall"),
                ),
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.blue),
                  title: const Text("Sửa"),
                  onTap: () => Navigator.pop(ctx, "edit"),
                ),
              ],
            ],
          ),
        );
      },
    );

    if (result == "recall") {
      _recallMessage(index);
    } else if (result == "edit") {
      _startEditMessage(index);
    } else if (result == "pin") {
      _pinMessage(msg);
    } else if (result == "unpin") {
      _unpinMessage(msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context), //TODO: back
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  CircleAvatar(
                    backgroundImage:
                        const NetworkImage("https://i.imgur.com/BoN9kdC.png"),
                    radius: 20.r,
                  ),
                  SizedBox(width: 10.w),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Trọng Khang",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("Hiện đang hoạt động",
                            style:
                                TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _makeCall(isVideo: true),
                    icon: const Icon(Icons.video_call_outlined),
                    iconSize: 28.sp,
                  ),
                  IconButton(
                    onPressed: () => _makeCall(isVideo: false),
                    icon: const Icon(Icons.call),
                  ),
                ],
              ),
            ),

            Divider(height: 1.h),

            /// PINNED MESSAGES
            if (_pinnedMessages.isNotEmpty)
              Container(
                color: Colors.yellow.shade100,
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPinnedExpanded = !_isPinnedExpanded;
                        });
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.push_pin, color: Colors.orange),
                          SizedBox(width: 6.w),
                          Text(
                            "Tin nhắn đã ghim (${_pinnedMessages.length})",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _isPinnedExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                    if (_isPinnedExpanded)
                      ..._pinnedMessages.map((msg) => Padding(
                            padding: EdgeInsets.only(left: 28.w, top: 4.h),
                            child: Text(
                              "📌 ${msg.text}",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                fontSize: 13.sp,
                              ),
                            ),
                          )),
                  ],
                ),
              ),

            /// CHAT CONTENT
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(12.w),
                children: [
                  ..._messages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final msg = entry.value;

                    return Column(
                      crossAxisAlignment: msg.isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        if (_selectedMsgIndex == index)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            child: Center(
                              child: Text(
                                _formatTime(msg.time),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),

                        /// Nếu đang sửa
                        if (_editingMsgIndex == index)
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 4.h),
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Column(
                              children: [
                                TextField(
                                  controller: _editController,
                                  decoration: const InputDecoration(
                                    hintText: "Sửa tin nhắn...",
                                    border: InputBorder.none,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _editingMsgIndex = null;
                                          _editController.clear();
                                        });
                                      },
                                      child: const Text("Hủy"),
                                    ),
                                    ElevatedButton(
                                      onPressed: _confirmEditMessage,
                                      child: const Text("Lưu"),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedMsgIndex =
                                    _selectedMsgIndex == index ? null : index;
                              });
                            },
                            onLongPress: () =>
                                _showMessageOptions(context, index),
                            child: Align(
                              alignment: msg.isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 4.h),
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: msg.isRecalled
                                      ? Colors.transparent
                                      : (msg.isMe
                                          ? Colors.lightBlue
                                          : Colors.grey[200]),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: msg.isRecalled
                                      ? Border.all(color: Colors.grey)
                                      : null,
                                ),
                                child: msg.isRecalled
                                    ? Text(
                                        "Đã thu hồi tin nhắn",
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey,
                                          fontSize: 13.sp,
                                        ),
                                      )
                                    : (msg.type == MessageType.call
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                msg.isMissed
                                                    ? Icons.call_missed
                                                    : (msg.isVideo
                                                        ? Icons
                                                            .videocam_outlined
                                                        : Icons.call),
                                                color: msg.isMissed
                                                    ? Colors.red
                                                    : (msg.isMe
                                                        ? Colors.white
                                                        : Colors.green),
                                                size: 18.sp,
                                              ),
                                              SizedBox(width: 6.w),
                                              Text(
                                                msg.isMissed
                                                    ? (msg.isVideo
                                                        ? "Đã bỏ lỡ cuộc gọi video"
                                                        : "Đã bỏ lỡ cuộc gọi thoại")
                                                    : "${msg.text} • ${msg.duration ?? ""}",
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                  color: msg.isMe
                                                      ? Colors.white
                                                      : (msg.isMissed
                                                          ? Colors.red
                                                          : Colors.black87),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (msg.isEdited)
                                                Icon(Icons.edit,
                                                    size: 14.sp,
                                                    color: Colors.white),
                                              SizedBox(width: 4.w),
                                              Flexible(
                                                child: Text(
                                                  msg.text,
                                                  style: TextStyle(
                                                    color: msg.isMe
                                                        ? Colors.white
                                                        : Colors.black87,
                                                    fontSize: 14.sp,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            /// INPUT BAR
            Container(
              padding:EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      //TODO: mở camera
                    },
                    icon: const Icon(Icons.camera_alt_outlined,
                        color: Colors.blue),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Nhắn tin...",
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      //TODO: mở emoji picker
                    },
                    icon: const Icon(Icons.emoji_emotions_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      //TODO: mở gallery
                    },
                    icon: const Icon(Icons.image_outlined),
                  ),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} "
        "${time.day}/${time.month}/${time.year}";
  }
}

enum MessageType { text, call }

class _Message {
  final String text;
  final bool isMe;
  final DateTime time;
  final bool isEdited;
  final bool isRecalled;
  final MessageType type;
  final bool isVideo;
  final bool isMissed;
  final String? duration;

  _Message({
    required this.text,
    required this.isMe,
    required this.time,
    this.isEdited = false,
    this.isRecalled = false,
    this.type = MessageType.text,
    this.isVideo = false,
    this.isMissed = false,
    this.duration,
  });

  _Message copyWith({
    String? text,
    bool? isEdited,
    bool? isRecalled,
  }) {
    return _Message(
      text: text ?? this.text,
      isMe: isMe,
      time: time,
      isEdited: isEdited ?? this.isEdited,
      isRecalled: isRecalled ?? this.isRecalled,
      type: type,
      isVideo: isVideo,
      isMissed: isMissed,
      duration: duration,
    );
  }
}
