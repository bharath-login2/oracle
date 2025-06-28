import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

class BlinkingText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;

  const BlinkingText({
    super.key,
    required this.text,
    this.style,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<BlinkingText> createState() => _BlinkingTextState();
}

class _BlinkingTextState extends State<BlinkingText>
    with SingleTickerProviderStateMixin {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _startBlinking();
  }

  void _startBlinking() {
    Timer.periodic(widget.duration, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _visible = !_visible;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: widget.duration,
      child: Text(widget.text, style: widget.style),
    );
  }
}
