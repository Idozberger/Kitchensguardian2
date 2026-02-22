import 'package:flutter/material.dart';

class JoinRequestShimmer extends StatefulWidget {
  const JoinRequestShimmer({super.key});

  @override
  State<JoinRequestShimmer> createState() => _JoinRequestShimmerState();
}

class _JoinRequestShimmerState extends State<JoinRequestShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _shimmerBox(height: 48, width: 48, radius: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _shimmerBox(height: 14, width: double.infinity),
                            const SizedBox(height: 8),
                            _shimmerBox(height: 12, width: 180),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _shimmerBox({
    required double height,
    double? width,
    double radius = 12,
  }) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment(-1.2 + (_controller.value * 2.4), 0),
          end: Alignment(1.2 + (_controller.value * 2.4), 0),
          colors: const [
            Color(0xFFEAEAEA),
            Color(0xFFF5F5F5),
            Color(0xFFEAEAEA),
          ],
          stops: const [0.35, 0.5, 0.65],
        ).createShader(bounds);
      },
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: const Color(0xFFEAEAEA),
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
