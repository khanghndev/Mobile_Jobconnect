import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/enum/messenger_type.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/config/utils/get_adaptive_back_icon.dart';
import 'package:job_connect/config/utils/pick_image.dart';
import 'package:job_connect/config/widgets/custom_input_field.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/mini_social/widgets/bottom_sheet/message_action_bottom_sheet.dart';
import 'package:job_connect/features/mini_social/widgets/social_messenger/chat_message_item.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:job_connect/config/utils/image_url.dart';
import 'package:job_connect/features/mini_social/view_model/message_view_model.dart';
import 'package:job_connect/features/mini_social/model/message_model.dart';

class SocialMessengerDetailScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;
  final String otherUserId;
  final String conversationId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String? currentUserAvatar;

  const SocialMessengerDetailScreen({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
    required this.otherUserId,
    required this.conversationId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.currentUserAvatar,
  });

  @override
  State<SocialMessengerDetailScreen> createState() => _SocialMessengerDetailScreenState();
}

class _SocialMessengerDetailScreenState extends State<SocialMessengerDetailScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _editController = TextEditingController();
  File? _pickedImage; // ảnh preview
  File? _pickedFile;
  int? _editingMsgIndex;
  int? _selectedMsgIndex;
  final List<MessageModel> _pinnedMessages = [];

  bool _isPinnedExpanded = true;
  late MessageViewModel msgVm;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    msgVm = context.read<MessageViewModel>();
    msgVm.joinConversation(widget.conversationId);
    _fetchMessages();
    if (widget.idUser != widget.otherUserId) {
      msgVm.markMessagesAsRead(
        conversationId: widget.conversationId,
        readerId: widget.idUser,
      );
    }

    // Listener để scroll khi có tin nhắn mới realtime
    msgVm.addListener(_scrollOnNewMessage);
  }

  void _scrollOnNewMessage() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    msgVm.leaveConversation(widget.conversationId);
    msgVm.removeListener(_scrollOnNewMessage);
    _inputController.dispose();
    _editController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    // Xóa dữ liệu cũ trước khi fetch
    msgVm.clearMessages(widget.conversationId);
    await msgVm.fetchMessages(conversationId: widget.conversationId);
    _scrollOnNewMessage();
  }

  /// Gửi text hoặc ảnh hoặc file
  Future<void> _onSendMessage() async {
    final text = _inputController.text.trim();

    // 1. Gửi ảnh nếu có
    if (_pickedImage != null) {
      final fileUrl = await msgVm.uploadFile(
        file: _pickedImage!, 
        messageType: MessengerType.image.name
      ); // upload ảnh lên Appwrite(_pickedImage!.path);

      await msgVm.sendMessageViaSignalR(
        conversationId: widget.conversationId,
        content: _pickedImage!.path.split("/").last,
        messageType: MessengerType.image.name,
        fileUrl: fileUrl,
        fileName: _pickedImage!.path.split("/").last,
        fileSize: await _pickedImage!.length(),
      );

      setState(() => _pickedImage = null);
      _scrollOnNewMessage();
    }

    // 2. Gửi file nếu có
    if (_pickedFile != null) {
      final fileUrl = await msgVm.uploadFile(
        file: _pickedFile!,
        messageType: MessengerType.file.name,
      ); // upload file lên Appwrite

      await msgVm.sendMessageViaSignalR(
        conversationId: widget.conversationId,
        content: _pickedFile!.path.split("/").last,
        messageType: MessengerType.file.name,
        fileUrl: fileUrl,
        fileName: _pickedFile!.path.split("/").last,
        fileSize: await _pickedFile!.length(),
      );

      setState(() => _pickedFile = null);
      _scrollOnNewMessage();
    }

    // 3. Gửi text
    if (text.isNotEmpty) {
      await msgVm.sendMessageViaSignalR(
        conversationId: widget.conversationId,
        content: text,
        messageType: MessengerType.text.name,
      );

      _inputController.clear();
      _scrollOnNewMessage();
    }
  }

  void _startEditMessage(int index) {
    final messages = msgVm.getMessages(widget.conversationId);
    final msg = messages[index];
    if (msg.idSender != widget.idUser) return;
    _editController.text = msg.content;
    setState(() => _editingMsgIndex = index);
  }

  void _recallMessage(int index) {
    final messages = msgVm.getMessages(widget.conversationId);
    final msg = messages[index];
    if (msg.idSender != widget.idUser) return;

    final updated = msg.copyWith(content: "Đã thu hồi tin nhắn");
    msgVm.updateMessage(widget.conversationId, index, updated);
  }

  void _showMessageOptions(BuildContext context, MessageModel msg) {
    final messages = msgVm.getMessages(widget.conversationId);
    final index = messages.indexOf(msg);

    MessageActionSheet.show(
      context,
      isPinned: _pinnedMessages.contains(msg),
      isOwnMessage: msg.idSender == widget.idUser,
      onPinToggle: () {
        setState(() {
          if (_pinnedMessages.contains(msg)) {
            _pinnedMessages.remove(msg);
          } else {
            _pinnedMessages.add(msg);
          }
        });
      },
      onRecall: () {
        if (index != -1) _recallMessage(index);
      },
      onEdit: () {
        if (index != -1) _startEditMessage(index);
      },
    );
  }

  /// Pick ảnh chỉ preview
  Future<void> _onPickImage(ImageSource source) async {
    final Uint8List? bytes = await pickImage(context, imageSource: source);
    if (bytes != null) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(bytes);
      setState(() {
        _pickedImage = file;
      });
    }
  }

  Future<void> _onPickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = File(result.files.first.path!);
      setState(() {
        _pickedFile = file;
      });
    }
  }

  void _onOpenProfile(String idUser) {
    context.push('/social/profile', extra: {'idUser': idUser});
  }

  @override
  Widget build(BuildContext context) {
   final messages = context.watch<MessageViewModel>().getMessages(widget.conversationId);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: UnfocusWidget(
          child: Column(
            children: [
              /// HEADER
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Icon(getAdaptiveBackIcon(context), size: 24.sp),
                    ),
                    SizedBox(width: 16.w,),
                    GestureDetector(
                      onTap: () => _onOpenProfile(widget.otherUserId),
                      child: CircleAvatar(
                        backgroundImage: ImageUtils.getImageProvider(widget.otherUserAvatar ?? AppImages.defaultAvatar),
                        radius: 20.r,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _onOpenProfile(widget.otherUserId),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.otherUserName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold)
                              ),
                            Text(
                              "Hiện đang hoạt động",
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Icon(Icons.more_horiz, size: 24.sp,),
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
                                "📌 ${msg.content}",
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
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(12.w),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.idSender.trim() == widget.idUser.trim();

                    if (_editingMsgIndex == index) return Container();

                    final idUser = isMe ? widget.idUser : widget.otherUserId;
                    final avatarUrl = isMe
                        ? widget.currentUserAvatar ?? AppImages.defaultAvatar
                        : widget.otherUserAvatar ?? AppImages.defaultAvatar;

                    final showDetails = _selectedMsgIndex == index;

                    return ChatMessageItem(
                      msg: msg,
                      isMe: isMe,
                      idUser: idUser,
                      avatarUrl: avatarUrl,
                      showDetails: showDetails,
                      onLongPress: () => _showMessageOptions(context, msg),
                      onTap: () {
                        setState(() {
                          _selectedMsgIndex =
                              _selectedMsgIndex == index ? null : index;
                        });

                        if (!isMe && !msg.isRead) {
                          msgVm.markMessagesAsRead(
                            conversationId: widget.conversationId,
                            readerId: widget.idUser,
                          );
                        }
                      },
                      onOpenProfile: () => _onOpenProfile(idUser),
                    );
                  },
                ),
              ),

              /// HIỂN THỊ FILE / ẢNH ĐÃ CHỌN
              if (_pickedImage != null || _pickedFile != null)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: GestureDetector(
                          onTap: () {
                            if (_pickedImage != null) {
                              DialogUtils.showImageViewer(
                                context,
                                [_pickedImage!.path], 
                                0,
                                canDelete: false,
                              );
                            }
                          },
                          child: _pickedImage != null
                              ? Image.file(
                                  _pickedImage!,
                                  width: 120.w,
                                  height: 120.w,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 200.w,
                                  height: 120.w,
                                  color: Colors.grey.shade200,
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.insert_drive_file, size: 40.sp, color: Colors.grey),
                                      SizedBox(height: 4.h),
                                      Text(
                                        _pickedFile!.path.split("/").last,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12.sp, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _pickedImage = null;
                            _pickedFile = null;
                          }),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                color: Colors.white,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _onPickImage(ImageSource.gallery),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Icon(Icons.image,color: theme.primaryColor, size: 24.sp),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onPickImage(ImageSource.camera),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Icon(Icons.camera_alt,
                        color: theme.primaryColor, size: 24.sp),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onPickFile(),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Icon(Icons.file_copy,
                        color: theme.primaryColor, size: 24.sp),
                      ),
                    ),
                    Expanded(
                      child: CustomInputField(
                        controller: _inputController,
                        keyboardType: TextInputType.text,
                        hintText: 'Viết tin nhắn...',
                        suffixIcon: Icon(Icons.sentiment_satisfied_alt, size: 22.sp, color: Colors.grey),
                        contentPadding: EdgeInsets.all(16.w),
                      ),
                    ),
                    GestureDetector(
                      onTap: _onSendMessage,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Icon(Icons.send, color: theme.primaryColor, size: 24.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
