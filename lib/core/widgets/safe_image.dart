import 'dart:async';
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

/// Retry delays for a failed remote image load. Catalog icons are generated in
/// a background job after the item is saved, so the URL can 404 for a few
/// seconds before the image exists.
// ponytail: bounded 3 retries, fixed delays; no backoff/jitter until a real
// case needs it.
const List<Duration> _networkImageRetryDelays = [
  Duration(seconds: 2),
  Duration(seconds: 5),
  Duration(seconds: 10),
];

/// Displays a remote [url] with [errorBuilder] fallback when load/decode fails.
///
/// A failed load is retried a few times: the widget evicts the URL from the
/// image cache and rebuilds, so icons that are still being generated backend
/// side appear without the user reopening the screen.
class SafeNetworkImage extends StatefulWidget {
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
  State<SafeNetworkImage> createState() => _SafeNetworkImageState();
}

class _SafeNetworkImageState extends State<SafeNetworkImage> {
  int _attempt = 0;
  Timer? _retry;

  @override
  void didUpdateWidget(SafeNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _retry?.cancel();
      _retry = null;
      _attempt = 0;
    }
  }

  @override
  void dispose() {
    _retry?.cancel();
    super.dispose();
  }

  void _scheduleRetry(String url) {
    if (_attempt >= _networkImageRetryDelays.length) return;
    if (_retry?.isActive ?? false) return;

    _retry = Timer(_networkImageRetryDelays[_attempt], () async {
      await NetworkImage(url).evict();
      if (!mounted) return;
      setState(() => _attempt++);
    });
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.url;
    if (!hasDisplayableNetworkUrl(url)) {
      return widget.fallback;
    }

    return Image.network(
      url!,
      key: ValueKey(_attempt),
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      errorBuilder: (_, _, _) {
        _scheduleRetry(url);
        return widget.fallback;
      },
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
