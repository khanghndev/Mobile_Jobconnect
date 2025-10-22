import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:job_connect/config/constant/app_colors.dart';
import 'package:job_connect/features/mini_social/screens/home/social_feed_screen.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/flying_emoji.dart';
import 'package:job_connect/features/mini_social/widgets/social_feed/reaction_bar.dart';

class StoryViewer extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;

  const StoryViewer({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  late int currentIndex;
  Timer? _timer;
  double progress = 0.0;
  bool isPaused = false;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _startProgress();
  }

  void _startProgress() {
    _timer?.cancel();
    progress = 0.0;
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!isPaused) {
        setState(() {
          progress += 0.005; // 20 giây/story
          if (progress >= 1.0) _nextStory();
        });
      }
    });
  }

  void _nextStory() {
    if (currentIndex < widget.stories.length - 1) {
      setState(() => currentIndex++);
      _startProgress();
    } else {
      _timer?.cancel();
      Future.microtask(() {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  void _previousStory() {
    if (currentIndex > 0) {
      setState(() => currentIndex--);
      _startProgress();
    }
  }

  void _showFlyingEmoji(String emoji) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(builder: (_) => FlyingEmoji(emoji: emoji));
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[currentIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onLongPress: () => setState(() => isPaused = true),
        onLongPressUp: () => setState(() => isPaused = false),
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) _nextStory();
            if (details.primaryVelocity! > 0) _previousStory();
          }
        },
        child: Stack(
          children: [
            Center(
              child: Image.asset(
                story.imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              top: 40.h,
              left: 16.w,
              right: 16.w,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            Positioned(
              top: 70.h,
              left: 16.w,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundImage: AssetImage(story.imageUrl),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    story.name,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: TextColors.textBrandOnbrand,
                        ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 40.h,
              right: 16.w,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ReactionBar(
                controller: _messageController,
                onEmojiTap: _showFlyingEmoji,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
