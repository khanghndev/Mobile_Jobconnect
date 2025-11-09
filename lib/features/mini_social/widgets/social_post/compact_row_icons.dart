import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CompactRowIcons extends StatelessWidget {
  final VoidCallback onExpand;
  final List<Map<String, dynamic>> icons;

  const CompactRowIcons({
    super.key,
    required this.onExpand,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: icons.map((item) {
                return GestureDetector(
                  onTap: item['onPressed'] as VoidCallback?,
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child:Container(
                      width: 44.w,
                      height: 44.h,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: IconButton(
                        icon: Icon(item['icon'] as IconData, color: item['color'] as Color),
                        onPressed: item['onPressed'] as VoidCallback?,
                      ),
                    )
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Container(
            width: 44.w,
            height: 44.h,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_drop_up, color: Colors.grey),
              onPressed: onExpand,
            ),
          ),
        ),
      ],
    );
  }
}