import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/widgets/reusable_bottom_sheet.dart';

class GroupHeader extends StatefulWidget {
  final String groupName;
  final String visibilityText;
  final String memberCountText;
  final bool isJoinSheetOpen;
  final String selectedFilter;
  final List<FilterOption> controlOptions;
  final Function(String value) onSelected;
  final VoidCallback onInviteFriend;

  const GroupHeader({
    super.key,
    required this.groupName,
    required this.visibilityText,
    required this.memberCountText,
    required this.isJoinSheetOpen,
    required this.selectedFilter,
    required this.controlOptions,
    required this.onSelected,
    required this.onInviteFriend,
  });

  @override
  State<GroupHeader> createState() => _GroupHeaderState();
}

class _GroupHeaderState extends State<GroupHeader> {
  late bool _isJoinSheetOpen;

  @override
  void initState() {
    super.initState();
    _isJoinSheetOpen = widget.isJoinSheetOpen;
  }

  void _openJoinOptions() {
    setState(() => _isJoinSheetOpen = true);
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (_) => ReusableBottomSheet(
        options: widget.controlOptions,
        selectedValue: widget.selectedFilter,
        showRadio: false,
        onSelected: (value) {
          widget.onSelected(value);
        },
      ),
    ).whenComplete(() {
      setState(() => _isJoinSheetOpen = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Tên nhóm
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            widget.groupName,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        /// Info nhóm
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Icon(
                Icons.lock_open,
                size: 20.sp,
                color: Colors.grey,
              ),
              SizedBox(width: 6.w),
              Text(
                "${widget.visibilityText} • ${widget.memberCountText}",
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
              ),
            ],
          ),
        ),

        /// Nút tham gia & mời bạn bè
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _openJoinOptions,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: BorderSide(color: Colors.grey.shade400, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  label: const Text("Đã tham gia"),
                  icon: Icon(
                    _isJoinSheetOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onInviteFriend,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade400, width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  icon: const Icon(Icons.person_add_alt, size: 20),
                  label: const Text("Mời bạn bè"),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}