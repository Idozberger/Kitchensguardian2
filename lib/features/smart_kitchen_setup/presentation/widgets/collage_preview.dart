import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodkitchen/core/utils/image_bytes.dart';
import 'package:foodkitchen/core/widgets/safe_image.dart';

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

  Widget get _fallback => Container(
    color: _surface,
    child: Icon(Icons.image_outlined, color: _textLow, size: 28),
  );

  @override
  Widget build(BuildContext context) {
    if (hasDisplayableNetworkUrl(path)) {
      return SafeNetworkImage(
        url: path,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        fallback: _fallback,
      );
    }

    final file = File(path.replaceFirst('file://', ''));
    return SafeFileImage(
      file: file,
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      fallback: _fallback,
    );
  }
}
