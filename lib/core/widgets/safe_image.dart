import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:foodkitchen/core/utils/image_bytes.dart';

/// Displays in-memory [bytes] with [errorBuilder] fallback when decode fails.
class SafeMemoryImage extends StatelessWidget {
  final Uint8List? bytes;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget fallback;

  const SafeMemoryImage({
    super.key,
    required this.bytes,
    required this.fallback,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasDisplayableImageBytes(bytes)) {
      return fallback;
    }

    return Image.memory(
      bytes!,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

/// Displays a local [file] with [errorBuilder] fallback when decode fails.
class SafeFileImage extends StatelessWidget {
  final File? file;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget fallback;

  const SafeFileImage({
    super.key,
    required this.file,
    required this.fallback,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasDisplayableFileImage(file)) {
      return fallback;
    }

    return Image.file(
      file!,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

/// Displays a remote [url] with [errorBuilder] fallback when load/decode fails.
class SafeNetworkImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget fallback;

  const SafeNetworkImage({
    super.key,
    required this.url,
    required this.fallback,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasDisplayableNetworkUrl(url)) {
      return fallback;
    }

    return Image.network(
      url!,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

/// Circular avatar that safely renders memory, file, or network image sources.
class SafeCircleAvatar extends StatelessWidget {
  final double radius;
  final Uint8List? memoryBytes;
  final File? file;
  final String? networkUrl;
  final Widget fallback;
  final Color? backgroundColor;

  const SafeCircleAvatar({
    super.key,
    required this.radius,
    required this.fallback,
    this.memoryBytes,
    this.file,
    this.networkUrl,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final sizedFallback = SizedBox(width: size, height: size, child: fallback);

    Widget? image;
    if (hasDisplayableFileImage(file)) {
      image = SafeFileImage(
        file: file,
        width: size,
        height: size,
        fit: BoxFit.cover,
        fallback: sizedFallback,
      );
    } else if (hasDisplayableImageBytes(memoryBytes)) {
      image = SafeMemoryImage(
        bytes: memoryBytes,
        width: size,
        height: size,
        fit: BoxFit.cover,
        fallback: sizedFallback,
      );
    } else if (hasDisplayableNetworkUrl(networkUrl)) {
      image = SafeNetworkImage(
        url: networkUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        fallback: sizedFallback,
      );
    }

    if (image == null) {
      return sizedFallback;
    }

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: backgroundColor,
        child: image,
      ),
    );
  }
}
