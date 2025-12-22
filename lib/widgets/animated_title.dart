import 'package:flutter/material.dart';

class AnimatedTitle extends StatefulWidget {
  final String text;

  const AnimatedTitle({super.key, required this.text});

  @override
  State<AnimatedTitle> createState() => _AnimatedTitleState();
}

class _AnimatedTitleState extends State<AnimatedTitle> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000), // Slower, elegant timing
      vsync: this,
    );

    // One consistent direction: Left -> Right
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.2, 0), // Start slightly left
      end: const Offset(0.05, 0),   // End slightly right (continue motion)
    ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuad, // Smooth linear-ish motion
    ));

    // Opacity Sequence: Fade In -> Hold -> Fade Out
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)), 
        weight: 20, // 20% of time to fade in
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 60, // 60% of time visible/holding
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)), 
        weight: 20, // 20% of time to fade out
      ),
    ]).animate(_controller);

    // Continuous loop in one direction
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Text(
          widget.text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28, 
            fontWeight: FontWeight.bold, // Semi-bold to Bold
            color: Color(0xFF264796), // Royal Blue
            letterSpacing: 2.0,
            fontFamily: 'Roboto', 
          ),
        ),
      ),
    );
  }
}
