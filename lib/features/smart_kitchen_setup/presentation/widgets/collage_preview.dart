import 'dart:io';
import 'package:flutter/material.dart';

class CollagePreview extends StatelessWidget {
  final List<String> paths;
  final Color accent;
  final VoidCallback onAdd;

  const CollagePreview({
    super.key,
    required this.paths,
    required this.accent,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final display = paths.take(5).toList();

    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: display.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 80,
              height: 80,
              child: _CollageImage(path: display[i]),
            ),
          );
        },
      ),
    );
  }
}

class _CollageImage extends StatelessWidget {
  final String path;
  const _CollageImage({required this.path});

  final Color _surface = const Color(0xFF1A1D27);
  final Color _textLow = const Color(0xFF555A70);

  @override
  Widget build(BuildContext context) {
    try {
      if (path.startsWith('http')) {
        return Image.network(path, fit: BoxFit.cover);
      }
      final file = File(path.replaceFirst('file://', ''));
      return Image.file(file, fit: BoxFit.cover);
    } catch (_) {
      return Container(
        color: _surface,
        child: Icon(Icons.image_outlined, color: _textLow, size: 28),
      );
    }
  }
}
