import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/constant/app_images.dart';
import 'package:job_connect/config/utils/dialog_utils.dart';
import 'package:job_connect/config/widgets/custom_search_bar.dart';
import 'package:job_connect/config/widgets/unfocus_widget.dart';
import 'package:job_connect/features/mini_social/model/conversation_model.dart';
import 'package:job_connect/features/mini_social/view_model/social_connection_view_model.dart';
import 'package:job_connect/features/mini_social/widgets/social_messenger/avatar_messenger_item.dart';
import 'package:job_connect/features/mini_social/widgets/social_messenger/messenger_item.dart';
import 'package:job_connect/features/mini_social/widgets/shimmer/social_conversation_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:job_connect/features/mini_social/view_model/conversation_view_model.dart';
import 'package:job_connect/features/mini_social/view_model/message_view_model.dart';
import 'package:job_connect/features/profile/view_model/user_view_model.dart';
import 'package:job_connect/features/mini_social/model/message_model.dart';
import 'package:job_connect/features/chat/screens/ai_chat_screen.dart';

class SocialMessengerScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String idUser;

  const SocialMessengerScreen({
    super.key,
    required this.isLoggedIn,
    required this.idUser,
  });

  @override
  State<SocialMessengerScreen> createState() => _SocialMessengerScreenState();
}

class _SocialMessengerScreenState extends State<SocialMessengerScreen> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  bool _isInitialized = false;
  bool _isLoading = false;

  int _selectedTab = 0;
  final List<String> _tabs = ["Tin nhắn", "Chưa đọc", "Tin nhắn chờ"];
  String _searchKeyword = '';


  late ConversationViewModel conversationVm;
  late MessageViewModel msgVm;
  late UserViewModel userVm;
  late SocialConnectionViewModel socialConnectionVm;

  @override
  void initState() {
    super.initState();
    userVm = context.read<UserViewModel>();
    conversationVm = context.read<ConversationViewModel>();
    msgVm = context.read<MessageViewModel>();
    socialConnectionVm = context.read<SocialConnectionViewModel>();

    // Listener cho search
    _searchController.addListener(() {
      setState(() {
        _searchKeyword = _searchController.text.trim().toLowerCase();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDataOnce();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  Future<void> _initDataOnce() async {
    if (_isInitialized) return;
    setState(() => _isLoading = true);
    await _initData();
    setState(() {
      _isInitialized = true;
      _isLoading = false;
    });
  }

  Future<void> _initData() async {
    await userVm.getCurrentUser(widget.idUser);
    await conversationVm.fetchConversationsByUser(userId: widget.idUser);

    // Fetch tất cả user còn lại và last message
    for (var convo in conversationVm.conversations) {
      for (var memberId in convo.members) {
        if (memberId != widget.idUser &&
            !userVm.users.any((u) => u.idUser == memberId)) {
          final user = await userVm.fetchUserViewerById(memberId);
          if (user != null) userVm.users.add(user);
        }
      }
      await msgVm.fetchMessages(conversationId: convo.idConversation, limit: 50);
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isLoading = true);
    await _initData();
    setState(() => _isLoading = false);
  }

  void _onDeleteConversation(ConversationModel convo) {
    DialogUtils.showConfirmationDialog(
      context: context,
      title: "Xóa cuộc trò chuyện",
      message: "Bạn có muốn xóa cuộc trò chuyện này?",
      icon: Icons.delete,
      onConfirm: () async {
        conversationVm.removeConversation(convo.idConversation);
        conversationVm.removeMember(
          conversationId: convo.idConversation,
          userId: widget.idUser,
        );
      },
    );
  }

  ConversationModel? _findConversationWithUser(String otherUserId) {
    try {
      return conversationVm.conversations.firstWhere((c) =>
          c.members.contains(widget.idUser) && c.members.contains(otherUserId));
    } catch (_) {
      return null;
    }
  }

  String formatMessageContent(MessageModel msg, String senderName, String currentUserId) {
    final isMe = msg.idSender == currentUserId;

    final content = (msg.content.isNotEmpty) ? msg.content : "Bắt đầu cuộc trò chuyện";

    final isPostId = RegExp(r'^[a-f0-9]{32}$').hasMatch(msg.content);

    if (isPostId) {
      return isMe ? "Bạn: Đã gửi nhận việc" : "$senderName: Đã nhận việc";
    } else {
      return isMe ? "Bạn: $content" : "$senderName: $content";
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentUser = userVm.currentUser;

    if (_isLoading || currentUser == null) {
      return const Scaffold(
        body: Center(child: SocialConversationShimmer()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        minimum: EdgeInsets.all(16.r),
        child: UnfocusWidget(
          child: Column(
            children: [
              // Search bar
              CustomSearchBar(
                controller: _searchController,
                focusNode: _searchFocus,
                hintText: 'Tìm kiếm bạn bè',
                borderRadius: 20.r,
              ),
              SizedBox(height: 16.w,),
              // STORY CIRCLE
              Consumer<SocialConnectionViewModel>(
                builder: (context, socialVm, child) {
                    final friends = socialVm.friends;
                    return SizedBox(
                      height: 80.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: friends.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return AvatarMessengerItem(
                              name: currentUser.userName,
                              imageUrl:
                                  currentUser.avatarUrl ?? AppImages.defaultAvatar,
                              radius: 30.r,
                              onTap: () {
                                context.push(
                                  '/social/profile',
                                  extra: {'idUser': widget.idUser},
                                );
                              },
                            );
                          }
          
                          final friend = friends[index - 1];
          
                          return AvatarMessengerItem(
                            name: friend.name,
                            imageUrl: friend.avatar,
                            radius: 30.r,
                            onTap: () {
                              final convo = _findConversationWithUser(friend.id);
                              final currentAvatar =
                                  currentUser.avatarUrl ?? AppImages.defaultAvatar;
                              context.push(
                                '/social/messenger-detail',
                                extra: {
                                  'isLoggedIn': widget.isLoggedIn,
                                  'idUser': widget.idUser,
                                  'conversationId': convo?.idConversation ?? '',
                                  'otherUserName': friend.name,
                                  'otherUserId': friend.id,
                                  'otherUserAvatar': friend.avatar,
                                  'currentUserAvatar': currentAvatar
                                },
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
              ),
              SizedBox(height: 16.h),
              _buildCustomTabBar(),
              Expanded(child: _buildTabBody(currentUser)),
            ],
          ),
        ),
      ),
    );
  }

  /// CUSTOM TABBAR dạng chip bo tròn
  Widget _buildCustomTabBar() {
    return Row(
      children: List.generate(_tabs.length, (index) {
        final isSelected = _selectedTab == index;
        return Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedTab = index;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(50.r),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Body theo tab được chọn
  Widget _buildTabBody(currentUser) {
    switch (_selectedTab) {
      case 0: // Tất cả
        return _buildMessagesTab(currentUser, filter: (c, m) => true);
      case 1: // Chưa đọc
        return _buildMessagesTab(currentUser, filter: (c, m) =>
           msgVm.getMessages(c.idConversation).any((msg) =>
                msg.idConversation == c.idConversation && !msg.isRead));
      case 2: // Tin nhắn chờ
        return _buildMessagesTab(currentUser, filter: (c, m) {
          final otherUser = userVm.users.firstWhere(
            (u) =>
                c.members.contains(u.idUser) && u.idUser != widget.idUser,
            orElse: () => currentUser,
          );
          final isFriend = socialConnectionVm.friends.any((f) => f.id == otherUser.idUser);
          return !isFriend;
        });
      default:
        return Container();
    }
  }

  /// TAB: Danh sách Messenger với filter
  Widget _buildMessagesTab(currentUser, {required bool Function(ConversationModel convo, List<MessageModel> messages) filter}) {
    final fixedMessage = MessageModel(
      idMessage: "ai_chat",
      idConversation: "ai_chat",
      idSender: "ai_bot",
      content: "Hãy tâm sự về công việc với AI...",
      messageType: "text",
      sentAt: DateTime.now(),
      isRead: true,
    );
    final conversationVm = context.watch<ConversationViewModel>();
    final filteredConvos = conversationVm.conversations
      .where((c) => filter(c, msgVm.getMessages(c.idConversation)))
      .where((c) {
        if (_searchKeyword.isEmpty) return true;
        final otherUser = userVm.users.firstWhere(
          (u) => c.members.contains(u.idUser) && u.idUser != widget.idUser,
          orElse: () => userVm.currentUser!,
        );
        return otherUser.userName.toLowerCase().contains(_searchKeyword);
      })
      .toList();

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: 1 + filteredConvos.length,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return MessengerItem(
                    msg: fixedMessage,
                    name: "Chat với AI",
                    avatarUrl: AppImages.ai,
                    isAi: true,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AIChatScreen()),
                    ),
                  );
                }

                final convo = filteredConvos[index - 1];

                final lastMsg = msgVm.getMessages(convo.idConversation)
                    .where((m) => m.idConversation == convo.idConversation)
                    .fold<MessageModel?>(null, (prev, m) {
                  if (prev == null) return m;
                  return m.sentAt.isAfter(prev.sentAt) ? m : prev;
                });

                final otherUser = userVm.users.firstWhere(
                  (u) =>
                      convo.members.contains(u.idUser) &&
                      u.idUser != widget.idUser,
                  orElse: () => currentUser,
                );

                final unreadCount = msgVm.getMessages(convo.idConversation).where((m) =>m.idConversation == convo.idConversation && !m.isRead).length;
                final lastMsgDisplay = lastMsg ?? MessageModel(
                  idMessage: '',
                  idConversation: convo.idConversation,
                  idSender: otherUser.idUser,
                  content: 'Chưa có tin nhắn',
                  messageType: 'text',
                  sentAt: DateTime.now(),
                  isRead: true,
                );

                final displayText = formatMessageContent(
                  lastMsgDisplay,
                  otherUser.userName,
                  widget.idUser,
                );

                return MessengerItem(
                  key: ValueKey(convo.idConversation),
                  msg: MessageModel(
                    idMessage: lastMsgDisplay.idMessage,
                    idConversation: convo.idConversation,
                    idSender: lastMsgDisplay.idSender.isNotEmpty
                        ? lastMsgDisplay.idSender
                        : otherUser.idUser,
                    content: displayText,
                    messageType: lastMsgDisplay.messageType,
                    sentAt: lastMsgDisplay.sentAt,
                    isRead: lastMsgDisplay.isRead,
                    fileUrl: lastMsgDisplay.fileUrl,
                    fileName: lastMsgDisplay.fileName,
                    fileSize: lastMsgDisplay.fileSize,
                  ),
                  unreadCount: unreadCount,
                  name: otherUser.userName,
                  avatarUrl: otherUser.avatarUrl ?? "",
                  onDelete: () => _onDeleteConversation(convo),
                  onTap: () {
                    final currentAvatar = currentUser.avatarUrl ?? AppImages.defaultAvatar;
                    context.push(
                      '/social/messenger-detail',
                      extra: {
                        'isLoggedIn': widget.isLoggedIn,
                        'idUser': widget.idUser,
                        'conversationId': convo.idConversation,
                        'otherUserName': otherUser.userName,
                        'otherUserId': otherUser.idUser,
                        'otherUserAvatar':
                            otherUser.avatarUrl ?? AppImages.defaultAvatar,
                        'currentUserAvatar': currentAvatar,
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
