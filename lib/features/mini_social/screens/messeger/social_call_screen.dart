import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:job_connect/config/utils/image_url.dart';

class SocialCallScreen extends StatefulWidget {
  final String avatarUrl;
  final String userName;

  const SocialCallScreen({
    super.key,
    required this.avatarUrl,
    required this.userName,
  });

  @override
  State<SocialCallScreen> createState() => _SocialCallScreenState();
}

class _SocialCallScreenState extends State<SocialCallScreen>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  bool _accepted = false;

  late AnimationController _shakeController;

  // trạng thái toggle
  bool _isMicOn = true;
  bool _isSpeakerOn = false;

  // đếm thời gian
  Timer? _timer;
  Duration _callDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        _callDuration = Duration(seconds: _callDuration.inSeconds + 1);
      });
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final shakeAnimation =
        Tween(begin: -4.0.w, end: 4.0.w).animate(_shakeController);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background avatar
          Positioned.fill(
            child: Image.network(widget.avatarUrl, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.4)),
          ),

          // Nút thoát ra ngoài (close)
          Positioned(
            top: 40.h,
            left: 16.w,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 28.sp),
              onPressed: () {
                context.pop();
              },
            ),
          ),

          // Thông tin user
          Positioned(
            top: 120.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60.r,
                  backgroundImage: ImageUtils.getImageProvider(widget.avatarUrl),
                ),
                SizedBox(height: 16.h),
                Text(
                  widget.userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  _accepted ? _formatDuration(_callDuration) : "Đang gọi...",
                  style: TextStyle(color: Colors.white70, fontSize: 16.sp),
                ),
              ],
            ),
          ),

          // Controls
          Positioned(
            bottom: 80.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_accepted) ...[
                  // MIC
                  _buildActionButton(
                    _isMicOn ? Icons.mic : Icons.mic_off,
                    _isMicOn ? Colors.green : Colors.grey,
                    onTap: () {
                      setState(() => _isMicOn = !_isMicOn);
                      // TODO: xử lý mic on/off
                    },
                  ),
                  SizedBox(width: 24.w),

                  // END CALL
                  _buildActionButton(Icons.call_end, Colors.red, onTap: () {
                    context.pop();
                  }),
                  SizedBox(width: 24.w),

                  // SPEAKER
                  _buildActionButton(
                    _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                    _isSpeakerOn ? Colors.green : Colors.grey,
                    onTap: () {
                      setState(() => _isSpeakerOn = !_isSpeakerOn);
                      // TODO: xử lý bật/tắt loa ngoài
                    },
                  ),
                ] else ...[
                  // Thanh trượt để trả lời
                  Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        width: 220.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(40.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 28.w),
                            Text(
                              "Kéo để trả lời",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14.sp,
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios,
                                color: Colors.white54, size: 16.sp),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            _dragOffset += details.delta.dx;
                            if (_dragOffset < 0) _dragOffset = 0;
                            if (_dragOffset > 160.w) _dragOffset = 160.w;
                          });
                        },
                        onHorizontalDragEnd: (_) {
                          if (_dragOffset > 120.w) {
                            setState(() {
                              _accepted = true;
                              _startTimer(); // bắt đầu đếm khi nhấc máy
                            });
                          }
                          _dragOffset = 0;
                        },
                        child: AnimatedBuilder(
                          animation: shakeAnimation,
                          builder: (_, child) {
                            return Transform.translate(
                              offset: Offset(
                                _dragOffset +
                                    (_dragOffset == 0
                                        ? shakeAnimation.value
                                        : 0),
                                0,
                              ),
                              child: child,
                            );
                          },
                          child: Container(
                            width: 60.w,
                            height: 60.w,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.call,
                                color: Colors.white, size: 30.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 30.r,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 30.sp),
      ),
    );
  }
}
