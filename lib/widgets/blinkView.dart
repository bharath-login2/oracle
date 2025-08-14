import 'package:flutter/material.dart';

class BlinkingViewText extends StatefulWidget {
  const BlinkingViewText({super.key});

  @override
  State<BlinkingViewText> createState() => _BlinkingViewTextState();
}

class _BlinkingViewTextState extends State<BlinkingViewText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: const Text(
        "View",
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
