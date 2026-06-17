// ignore_for_file: library_prefixes
// `dart:math` imported as Math to avoid clashing with local identifiers.

import 'dart:async';
import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/kitchen_snippet.dart';
import 'package:lottie/lottie.dart';

class AiAnalyzingLoader extends StatefulWidget {
  const AiAnalyzingLoader({super.key});

  @override
  State<AiAnalyzingLoader> createState() => AiAnalyzingLoaderState();
}

class AiAnalyzingLoaderState extends State<AiAnalyzingLoader> {
  final List<String> _messages = [
    'Scanning your kitchen...',
    'Identifying ingredients...',
    'Checking expiry patterns...',
    'Building your pantry list...',
    'Almost done...',
  ];

  int _currentMessageIndex = 0;
  late Timer _messageTimer;

  @override
  void initState() {
    super.initState();

    _messageTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _messages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            "assets/lotties/loader.json",
            width: 280,
            height: 124,
            fit: BoxFit.cover,
          ),
          gapH(64),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withValues(alpha: 0.6),
              ],
            ).createShader(bounds),
            child: const Text(
              'AI is analyzing',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),

          const SizedBox(height: 10),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              _messages[_currentMessageIndex],
              key: ValueKey(_currentMessageIndex),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF888EA8),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          const SizedBox(height: 32),

          const _AnimatedDots(),
          gapH(124),
        ],
      ),
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots();

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
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
      builder: (_, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final value = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = Math.sin(value * Math.pi).clamp(0.2, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.withValues(alpha: opacity),
              ),
            );
          }),
        );
      },
    );
  }
}
