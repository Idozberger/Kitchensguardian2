import 'package:flutter/widgets.dart';

class AnimatedDotsText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const AnimatedDotsText({super.key, required this.text, this.style});

  @override
  State<AnimatedDotsText> createState() => _AnimatedDotsTextState();
}

class _AnimatedDotsTextState extends State<AnimatedDotsText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _controller.addListener(() {
      final count = (_controller.value * 4).floor();
      if (count != _dotCount) {
        setState(() => _dotCount = count);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      "${widget.text}${'.' * _dotCount}",
      style: widget.style,
      textAlign: TextAlign.center,
    );
  }
}
