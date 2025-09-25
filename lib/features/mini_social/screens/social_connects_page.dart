import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ConnectsPage extends StatefulWidget {
  const ConnectsPage({super.key});

  @override
  State<ConnectsPage> createState() => _ConnectsPageState();
}

class _ConnectsPageState extends State<ConnectsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> invitedFriends = [
    {
      "name": "Rajeev Menon",
      "avatar": "https://i.pravatar.cc/150?img=1",
      "joinedDate": "Tham gia hôm nay",
      "points": 1000
    },
    {
      "name": "Karthik",
      "avatar": "https://i.pravatar.cc/150?img=2",
      "joinedDate": "Tham gia hôm nay",
      "points": 1000
    },
    {
      "name": "Priya",
      "avatar": "https://i.pravatar.cc/150?img=3",
      "joinedDate": "Tham gia hôm nay",
      "points": 1000
    },
    {
      "name": "Vijay Kumar",
      "avatar": "https://i.pravatar.cc/150?img=4",
      "joinedDate": "Tham gia hôm qua",
      "points": 1000
    },
    {
      "name": "Vinoth",
      "avatar": "https://i.pravatar.cc/150?img=5",
      "joinedDate": "Tham gia hôm qua",
      "points": 1000
    },
    {
      "name": "Samyuktha",
      "avatar": "https://i.pravatar.cc/150?img=6",
      "joinedDate": "Tham gia 26/08/2024",
      "points": 1000
    },
    {
      "name": "Varna",
      "avatar": "https://i.pravatar.cc/150?img=7",
      "joinedDate": "Tham gia 13/08/2024",
      "points": 1000
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Kết nối việc làm",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: Colors.black),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.h),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.transparent,
              indicator: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(24.r),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              labelStyle:
                  TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
              unselectedLabelStyle:
                  TextStyle(fontWeight: FontWeight.w500, fontSize: 14.sp),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Text("Giới thiệu của bạn"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Text("Tham gia nhóm (${invitedFriends.length})"),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildYourReferralsTab(),
          _buildInvitedFriendsTab(),
        ],
      ),
    );
  }

  Widget _buildYourReferralsTab() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Expanded(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/connect.png',
                  fit: BoxFit.cover,
                  height: 200.h,
                ),
                SizedBox(height: 20.h),
                Text(
                  "Mời bạn bè ngay, nhận 1,000 điểm cho mỗi người bạn!",
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("SUJITH0826",
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                              const ClipboardData(text: "SUJITH0826"));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Đã sao chép mã giới thiệu"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Text(
                          "Sao chép",
                          style:
                              TextStyle(color: Colors.blue, fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "Mời bạn bè của bạn\nGửi liên kết giới thiệu cá nhân cho bạn bè.",
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "Nhận điểm thưởng\nMỗi người bạn tham gia sẽ giúp bạn nhận 1,000 điểm.",
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
              onPressed: () {},
              child: Text("Chia sẻ mã giới thiệu",
                  style: TextStyle(fontSize: 16.sp)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInvitedFriendsTab() {
  return Column(
    children: [
      SizedBox(height: 20.h),
      Expanded(
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: invitedFriends.length,
          itemBuilder: (context, index) {
            final friend = invitedFriends[index];

            return Dismissible(
              key: ValueKey("${friend["name"]}_$index"),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 16.w),
                color: Colors.red,
                child: Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                setState(() => invitedFriends.removeAt(index));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Đã xóa khỏi danh sách")),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                constraints: BoxConstraints(minHeight: 68.h), // đảm bảo cao đều
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24.r,
                      backgroundImage: NetworkImage(friend["avatar"]),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            friend["name"],
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            friend["joinedDate"],
                            style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: xử lý tham gia ngay
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        minimumSize: Size(0, 36.h), // nút cao ổn định, giữa hàng
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Icon(Icons.person_add, color: Colors.white, size: 20.sp)
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      Padding(
        padding: EdgeInsets.all(16.w),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.r),
              ),
            ),
            onPressed: () {
              // TODO: xử lý tạo nhóm
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.group_add, size: 24.sp),
                SizedBox(width: 8.w),
                Text(
                  "Tạo nhóm của bạn",
                  style: TextStyle(fontSize: 16.sp),
                ),
              ],
            )
          ),
        ),
      ),
    ],
  );
}


}
