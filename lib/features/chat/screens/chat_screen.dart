import 'package:flutter/material.dart';
import 'package:job_connect/config/constant/api_constants.dart';
import 'package:job_connect/features/profile/model/user_model.dart';
import 'package:job_connect/config/services/api_service.dart';
import 'package:job_connect/features/chat/screens/chat_detail_screen.dart';
//import 'package:intl/intl.dart'; // Thêm package để định dạng thời gian

class ChatScreen extends StatefulWidget {
  final bool isLoggedIn;
  final String? idUser;
  const ChatScreen({
    super.key,
    required this.isLoggedIn,
    this.idUser,
  });

  @override
  ChatPage createState() => ChatPage();
}

class ChatPage extends State<ChatScreen> {
  final _apiService = ApiService( );
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = "Tất cả"; // Để quản lý tab đang active

  // Dữ liệu mẫu với thông tin nhà tuyển dụng
  final List<Map<String, dynamic>> _allChats = [
    {
      "id": "1",
      "name": "FPT Software",
      "position": "Frontend Developer",
      "message": "Cảm ơn bạn đã ứng tuyển. Khi nào bạn có thể phỏng vấn?",
      "time": "08:30 AM", // Thêm AM/PM cho rõ ràng
      "unread": true,
      "avatar": "F",
      "isOnline": true,
      "jobStatus": "Đã phản hồi", // "Mời phỏng vấn"
    },
    {
      "id": "2",
      "name": "VNG Corporation",
      "position": "UI/UX Designer",
      "message": "Hồ sơ của bạn đã được chúng tôi xem xét.",
      "time": "09:15 AM",
      "unread": true,
      "avatar": "V",
      "isOnline": false,
      "jobStatus": "Đang xem xét",
    },
    {
      "id": "3",
      "name": "Tiki",
      "position": "Backend Developer",
      "message": "Chúng tôi muốn mời bạn tham gia buổi phỏng vấn online.",
      "time": "Hôm qua", // Sử dụng "Hôm qua" cho dễ hiểu
      "unread": false,
      "avatar": "T",
      "isOnline": true,
      "jobStatus": "Mời phỏng vấn",
    },
    {
      "id": "4",
      "name": "Momo",
      "position": "Mobile Developer",
      "message":
          "Cảm ơn bạn đã tham gia phỏng vấn. Chúng tôi sẽ thông báo kết quả sớm.",
      "time": "12/07", // Sử dụng ngày cho tin nhắn cũ hơn
      "unread": false,
      "avatar": "M",
      "isOnline": false,
      "jobStatus": "Đã phỏng vấn",
    },
    {
      "id": "5",
      "name": "ShopeeFood",
      "position": "Data Analyst",
      "message": "Bạn có câu hỏi nào về vị trí ứng tuyển không?",
      "time": "10/07",
      "unread": false,
      "avatar": "S",
      "isOnline": true,
      "jobStatus": "Đã phản hồi",
    },
  ];

  List<Map<String, dynamic>> _filteredChats = [];

  UserModel? _account;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _filteredChats = _allChats; // Khởi tạo ban đầu
    _initializeData();
    _searchController.addListener(_filterChats);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterChats);
    _searchController.dispose();
    super.dispose();
  }

  void _filterChats() {
    final query = _searchController.text.toLowerCase();
    // print("--- Filtering ---");
    // print("Query: '$query'");
    // print("Selected Filter: '$_selectedFilter'");

    setState(() {
      _filteredChats =
          _allChats.where((chat) {
            // --- Phần Search ---
            final bool searchMatches;
            if (query.isEmpty) {
              searchMatches = true; // Nếu không tìm kiếm gì, coi như khớp
            } else {
              // Kiểm tra null trước khi gọi toLowerCase() và contains()
              final nameMatches =
                  chat["name"]?.toString().toLowerCase().contains(query) ??
                  false;
              final messageMatches =
                  chat["message"]?.toString().toLowerCase().contains(query) ??
                  false;
              final positionMatches =
                  chat["position"]?.toString().toLowerCase().contains(query) ??
                  false;
              searchMatches = nameMatches || messageMatches || positionMatches;
            }

            // --- Phần Filter theo Tab ---
            bool filterMatches =
                false; // Khởi tạo là false để đảm bảo có điều kiện khớp

            if (_selectedFilter == "Tất cả") {
              filterMatches =
                  true; // QUAN TRỌNG: Nếu là "Tất cả", luôn khớp điều kiện filter
            } else if (_selectedFilter == "Chưa đọc") {
              // Giả sử "unread" luôn là bool và không null. Nếu có thể null, cần kiểm tra.
              filterMatches = chat["unread"] == true;
            } else if (_selectedFilter == "Đã ứng tuyển") {
              // Xử lý cẩn thận với chat["jobStatus"] có thể là null
              final jobStatus =
                  chat["jobStatus"]?.toString(); // Lấy giá trị an toàn
              if (jobStatus != null) {
                // Chỉ thực hiện kiểm tra nếu jobStatus không null
                filterMatches = [
                  "Đã phản hồi",
                  "Mời phỏng vấn",
                  "Đã phỏng vấn",
                ].contains(jobStatus);
              } else {
                filterMatches =
                    false; // Nếu jobStatus là null, nó không khớp với điều kiện "Đã ứng tuyển"
              }
            }

            // Debugging cho từng chat item
            // print("Chat: ${chat['name']}, search: $searchMatches, jobStatus: ${chat['jobStatus']}, selectedFilter: $_selectedFilter, filterLogicResult: $filterMatches, FINAL: ${searchMatches && filterMatches}");

            return searchMatches && filterMatches;
          }).toList();

      // print("Filtered chats count: ${_filteredChats.length}");
      // if (_filteredChats.isEmpty && _allChats.isNotEmpty && _searchController.text.isEmpty) {
      //   print("All chats are being filtered out by TAB SELECTION. Check filter logic for '$_selectedFilter'.");
      // }
    });
  }

  Future<void> _initializeData() async {
    await _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    try {
      await Future.wait([_fetchAccount(), fetchChatsFromApi()]); // Gọi API chat
    } catch (e) {
      print("Error loading all data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _filterChats(); // Áp dụng filter ban đầu sau khi tải dữ liệu
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadAllData();
  }

  Future<void> _fetchAccount() async {
    if (widget.idUser == null || widget.idUser!.isEmpty) {
      // Có thể gán _account = null hoặc xử lý mặc định
      return;
    }
    try {
      final data = await _apiService.get(
        endpoint: '${ApiConstants.userEndpoint}/${widget.idUser}',
      );
      if (data.isNotEmpty) {
        if (mounted) {
          setState(() {
            _account = UserModel.fromJson(data.first);
          });
        }
      } else {
        print('No account data found or data is empty');
      }
    } catch (e) {
      print('Error fetching account: $e');
      // Xử lý lỗi, ví dụ hiển thị SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải thông tin tài khoản.')),
        );
      }
    }
  }

  // Đổi tên hàm để tránh trùng với biến chats
  Future<void> fetchChatsFromApi() async {
    // Giả lập gọi API, bạn sẽ thay thế bằng logic gọi API thật
    // await Future.delayed(const Duration(seconds: 1));
    // if (mounted) {
    //   setState(() {
    //     // Gán dữ liệu từ API vào _allChats nếu có
    //     // _allChats = fetchedChatsFromApi;
    //     _filteredChats = _allChats; // Cập nhật lại _filteredChats
    //   });
    // }
    print('Fetching chats from API...'); // Trong thực tế, bạn sẽ gọi API ở đây
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Màu nền nhẹ nhàng hơn
      appBar: AppBar(
        elevation: 0.5, // Bóng mờ nhẹ cho appbar
        title: const Text(
          "Tin nhắn tuyển dụng",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF212529),
          ),
        ),
        backgroundColor: Colors.white,
        // foregroundColor: Colors.black, // Bỏ dòng này để title có màu riêng
        automaticallyImplyLeading: false, // Bỏ nút back
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(
            65.0,
          ), // Tăng chiều cao cho thanh tìm kiếm
          child: Container(
            color: Colors.white, // Nền trắng cho khu vực tìm kiếm
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm nhà tuyển dụng, tin nhắn...',
                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey[600],
                    size: 22,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100], // Màu nền cho TextField
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0), // Bo tròn hơn
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Phần tabs lọc tin nhắn
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround, // Canh đều các tab
                      children: [
                        _buildFilterTab(
                          "Tất cả",
                          _selectedFilter == "Tất cả",
                          () {
                            setState(() {
                              _selectedFilter = "Tất cả";
                              _filterChats();
                            });
                          },
                        ),
                        _buildFilterTab(
                          "Chưa đọc",
                          _selectedFilter == "Chưa đọc",
                          () {
                            setState(() {
                              _selectedFilter = "Chưa đọc";
                              _filterChats();
                            });
                          },
                        ),
                        _buildFilterTab(
                          "Đã ứng tuyển",
                          _selectedFilter == "Đã ứng tuyển",
                          () {
                            setState(() {
                              _selectedFilter = "Đã ứng tuyển";
                              _filterChats();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  // Danh sách tin nhắn
                  Expanded(
                    child:
                        _filteredChats.isEmpty
                            ? _buildEmptyChatState()
                            : ListView.separated(
                              padding: const EdgeInsets.only(top: 8),
                              itemCount: _filteredChats.length,
                              separatorBuilder:
                                  (context, index) => Divider(
                                    height: 1,
                                    indent:
                                        80, // Tăng indent cho phù hợp với avatar
                                    endIndent: 16,
                                    color: Colors.grey[200],
                                  ),
                              itemBuilder: (context, index) {
                                final chat = _filteredChats[index];
                                return _buildChatTile(chat, context);
                              },
                            ),
                  ),
                ],
              ),
    );
  }

  Widget _buildEmptyChatState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              _searchController.text.isEmpty && _selectedFilter == "Tất cả"
                  ? "Chưa có cuộc trò chuyện nào"
                  : "Không tìm thấy tin nhắn phù hợp",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _searchController.text.isEmpty && _selectedFilter == "Tất cả"
                  ? "Bắt đầu ứng tuyển để nhận tin nhắn từ nhà tuyển dụng."
                  : "Thử tìm kiếm với từ khóa khác hoặc thay đổi bộ lọc.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ), // Tăng padding
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withValues(alpha:0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(25), // Bo tròn nhiều hơn
          border:
              isActive
                  ? Border.all(color: Colors.blue[600]!, width: 1.5)
                  : Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.blue[700] : Colors.grey[700],
            fontWeight:
                isActive
                    ? FontWeight.bold
                    : FontWeight.w500, // Điều chỉnh độ đậm
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(Map<String, dynamic> chat, BuildContext context) {
    return Material(
      // Bọc ListTile bằng Material để có hiệu ứng ripple
      color:
          chat["unread"]!
              ? Colors.blue.withValues(alpha:0.03)
              : Colors.white, // Nền nhẹ cho tin chưa đọc
      child: InkWell(
        // Sử dụng InkWell để có hiệu ứng khi nhấn
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChatDetailScreen(
                    chat: chat,
                    onReadMessages: (chatId) {
                      // Truyền callback
                      // Tìm chat trong _allChats và cập nhật unread = false
                      final chatIndex = _allChats.indexWhere(
                        (c) => c["id"] == chatId,
                      );
                      if (chatIndex != -1 &&
                          (_allChats[chatIndex]['unread'] ?? false)) {
                        if (mounted) {
                          // Kiểm tra mounted trước khi setState
                          setState(() {
                            _allChats[chatIndex]['unread'] = false;
                            _filterChats(); // Cập nhật lại danh sách hiển thị
                          });
                        }
                      }
                    },
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ), // Tăng padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: _getAvatarColor(chat["id"]),
                    child: Text(
                      chat["avatar"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22, // Tăng kích thước avatar text
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (chat["isOnline"])
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent[400], // Màu online sáng hơn
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2.5,
                          ), // Viền dày hơn
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            chat["name"],
                            style: TextStyle(
                              fontWeight:
                                  chat["unread"]!
                                      ? FontWeight.bold
                                      : FontWeight.w600, // Tăng độ đậm
                              fontSize: 16.5, // Tăng kích thước font
                              color: const Color(0xFF343A40), // Màu chữ đậm hơn
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          chat["time"],
                          style: TextStyle(
                            color:
                                chat["unread"]!
                                    ? Colors.blue[700]
                                    : Colors.grey[600],
                            fontSize: 12.5, // Tăng kích thước font
                            fontWeight:
                                chat["unread"]!
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      chat["position"], // Hiển thị vị trí ứng tuyển
                      style: TextStyle(color: Colors.grey[700], fontSize: 13.5),
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat["message"],
                            style: TextStyle(
                              color:
                                  chat["unread"]!
                                      ? Colors.black87
                                      : Colors.grey[700], // Màu tin nhắn
                              fontWeight:
                                  chat["unread"]!
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                              fontSize: 14, // Tăng kích thước font
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (chat["unread"]!)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            width: 9, // Tăng kích thước chấm unread
                            height: 9,
                            decoration: BoxDecoration(
                              color: Colors.blue[600],
                              shape: BoxShape.circle,
                            ),
                          ),
                        // Hiển thị jobStatus ở đây nếu muốn thay vì trong subtitle của ListTile cũ
                        if (chat["jobStatus"] != null &&
                            chat["jobStatus"].isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                chat["jobStatus"],
                              ).withValues(alpha:0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStatusColor(
                                  chat["jobStatus"],
                                ).withValues(alpha:0.5),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              chat["jobStatus"],
                              style: TextStyle(
                                color: _getStatusColor(chat["jobStatus"]),
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
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

  Color _getAvatarColor(String id) {
    final List<Color> colors = [
      Colors.blueGrey[700]!,
      Colors.indigo[600]!,
      Colors.deepOrange[600]!,
      Colors.teal[600]!,
      Colors.brown[500]!,
      // Bạn có thể thêm nhiều màu hơn nếu cần
    ];

    // Sửa ở đây:
    int parsedId =
        int.tryParse(id) ?? 0; // Chuyển đổi id sang int, nếu lỗi thì dùng 0
    int colorIndex =
        parsedId % colors.length; // Lấy modulo với độ dài danh sách

    // Thêm một bước kiểm tra để đảm bảo index luôn hợp lệ (mặc dù modulo thường đã xử lý)
    // nhưng để chắc chắn hơn nếu parsedId có thể âm (mặc dù trong trường hợp id chat thường là dương)
    if (colorIndex < 0) {
      colorIndex += colors.length;
    }

    return colors[colorIndex];
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Đã phản hồi":
        return Colors.blue[700]!;
      case "Đang xem xét":
        return Colors.orange[700]!;
      case "Mời phỏng vấn":
        return Colors.green[600]!;
      case "Đã phỏng vấn":
        return Colors.purple[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
