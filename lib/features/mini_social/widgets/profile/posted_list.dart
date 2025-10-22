import 'package:flutter/material.dart';
import 'package:job_connect/features/mini_social/screens/home/social_profile_screen.dart';
import 'package:job_connect/features/mini_social/widgets/profile/posted_card.dart';

class DiscoverList extends StatefulWidget {
  final List<DiscoverCardModel> cards;
  final bool isExpanded;
  final VoidCallback onToggle;

  const DiscoverList({
    super.key,
    required this.cards,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<DiscoverList> createState() => _DiscoverListState();
}

class _DiscoverListState extends State<DiscoverList> with SingleTickerProviderStateMixin{
  late AnimationController _controller; 
  late Animation<Offset> _offsetAnimation; 
  late Animation<double> _fadeAnimation;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), // trượt từ dưới lên
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // chạy animation ngay khi mở màn
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.isExpanded 
                  ? widget.cards.length 
                  : (widget.cards.length > 8 ? 8 : widget.cards.length),
                itemBuilder: (context, index){
                  return DiscoverCard(card: widget.cards[index]);
                }
              ),
            ),
          ],
        ),
      ),
    );
  }
}
