import 'dart:io';
import 'dart:typed_data';

/// Returns true when [bytes] are non-empty and look like a supported image format.
bool hasDisplayableImageBytes(Uint8List? bytes) {
  if (bytes == null || bytes.isEmpty) return false;
  return _looksLikeImageBytes(bytes);
}

bool _looksLikeImageBytes(Uint8List bytes) {
  if (bytes.length < 3) return false;

  // JPEG
  if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) return true;

  // PNG
  if (bytes.length >= 4 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47) {
    return true;
  }

  // GIF
  if (bytes.length >= 4 &&
      bytes[0] == 0x47 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x38) {
    return true;
  }

  // WebP (RIFF....WEBP)
  if (bytes.length >= 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50) {
    return true;
  }

  return false;
}

/// Returns true when [file] exists on disk and has content.
bool hasDisplayableFileImage(File? file) {
  if (file == null) return false;
  try {
    return file.existsSync() && file.lengthSync() > 0;
  } catch (_) {
    return false;
  }
}

/// Returns true when [url] is a non-empty http(s) URL.
bool hasDisplayableNetworkUrl(String? url) {
  if (url == null || url.trim().isEmpty) return false;
  final uri = Uri.tryParse(url.trim());
  return uri != null &&
      uri.hasScheme &&
      (uri.scheme == 'http' || uri.scheme == 'https');
}
