// ignore_for_file: use_build_context_synchronously
part of 'package:foodkitchen/core/services/document_scanning/document_scanning_service.dart';

Future<String> _docScannerGetCompressedImagePath(
  DocumentScannerService ds,
  String originalPath,
) async {
  final dir = await getTemporaryDirectory();
  final fileName = 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
  return '${dir.path}/$fileName';
}

Future<String?> _docScannerCompressImage(
  DocumentScannerService ds,
  String sourcePath,
) async {
  try {
    final outputPath = await _docScannerGetCompressedImagePath(ds, sourcePath);
    final originalFile = File(sourcePath);
    final originalSize = await originalFile.length();

    devLog(
      'Original image size: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB',
      name: 'DocumentScanner',
    );

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      sourcePath,
      outputPath,
      minWidth: 1280,
      minHeight: 960,
      quality: 70,
      format: CompressFormat.jpeg,
    );

    if (compressedFile != null && compressedFile.path.isNotEmpty) {
      final compressedSize = await File(compressedFile.path).length();
      devLog(
        'Compressed image size: ${(compressedSize / 1024).toStringAsFixed(2)} KB',
        name: 'DocumentScanner',
      );
      return compressedFile.path;
    }
    return null;
  } catch (e) {
    devLog('Image compression error: $e', name: 'DocumentScanner', error: e);
    return null;
  }
}

Future<bool> _docScannerRequestCameraPermission(
  DocumentScannerService ds,
) async {
  try {
    PermissionStatus status = await Permission.camera.status;

    if (!status.isGranted) {
      final result = await Permission.camera.request();
      if (!result.isGranted) {
        if (result.isDenied) {
          devLog('Camera permission denied', name: 'DocumentScanner');
          return false;
        }
        if (result.isPermanentlyDenied) {
          openAppSettings();
          return false;
        }
      }
      return result.isGranted;
    }
    return true;
  } catch (e) {
    devLog('Permission request error: $e', name: 'DocumentScanner', error: e);
    return false;
  }
}

Future<void> _docScannerNavigateToCapturedImageDetails(
  DocumentScannerService ds,
  BuildContext context,
  String imagePath, {
  bool replacement = false,
}) async {
  if (context.mounted) {
    if (replacement) {
      context.pushReplacementNamed(
        Routes.capturedImageDetails,
        extra: {'image_path': imagePath},
      );
    } else {
      context.pushNamed(
        Routes.capturedImageDetails,
        extra: {'image_path': imagePath},
      );
    }
  }
}

/// Shows a full-screen modal loading overlay. [onShown] receives the dialog's
/// [BuildContext] so dismissal uses the same navigator/route as the overlay
/// (the caller's context can sit under a nested navigator and fail to pop).
void _docScannerShowLoadingDialog(
  DocumentScannerService ds,
  BuildContext context,
  String message, {
  void Function(BuildContext dialogContext)? onShown,
}) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (dialogContext) {
      onShown?.call(dialogContext);
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              SizedBox(height: h(16)),
              Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: t(16)),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _docScannerShowErrorSnackBar(
  DocumentScannerService ds,
  BuildContext context,
  String message,
) {
  AppToast.show(message, ToastType.error, gravity: ToastGravity.TOP);
}

void _docScannerCloseLoadingDialog(
  DocumentScannerService ds,
  BuildContext dialogContext,
) {
  if (!dialogContext.mounted) return;
  final nav = Navigator.of(dialogContext, rootNavigator: true);
  if (nav.canPop()) {
    nav.pop();
  }
}

/// Ensures [showDialog]'s builder has run so [onShown] assigned a context.
/// On Android the compress step can finish in the same event-loop turn as
/// [showDialog]; without waiting for a frame, dismissal is skipped and the
/// overlay stays forever.
Future<void> _docScannerAwaitLoadingDialogContext({
  required BuildContext routeContext,
  required BuildContext? Function() currentDialogContext,
}) async {
  for (
    var i = 0;
    i < 15 && routeContext.mounted && currentDialogContext() == null;
    i++
  ) {
    await WidgetsBinding.instance.endOfFrame;
  }
}

bool _docScannerIsEmptyScanResult(Object? result) {
  if (result == null) return true;
  if (result is ImageScanResult) return result.images.isEmpty;
  if (result is List) return result.isEmpty;
  if (result is String) return result.isEmpty;
  return false;
}

String _docScannerResolveFilePath(String uri) {
  if (uri.startsWith('file://')) {
    return Uri.parse(uri).toFilePath();
  }
  return uri;
}

String? _docScannerFirstImageUriFromResult(dynamic result) {
  if (result is ImageScanResult) {
    return result.images.isNotEmpty ? result.images.first : null;
  }
  if (result is List && result.isNotEmpty) {
    final first = result.first;
    return first is String ? first : first?.toString();
  }
  if (result is String && result.isNotEmpty) {
    return result;
  }
  if (result is Map) {
    final images = result['images'];
    if (images is List && images.isNotEmpty) {
      final first = images.first;
      return first is String ? first : first?.toString();
    }
  }

  final str = result.toString();
  if (str.contains('imageUri=file:///')) {
    try {
      return '${str.split('imageUri=')[1].split('.jpg')[0]}.jpg';
    } catch (_) {}
  }
  return null;
}

Future<String?> _docScannerScanAndGetPath(DocumentScannerService ds) async {
  try {
    final hasPermission = await _docScannerRequestCameraPermission(ds);
    if (!hasPermission) {
      devLog('Camera permission denied', name: 'DocumentScanner');
      return null;
    }

    dynamic result;
    if (Platform.isAndroid) {
      result = await ds._documentScanner.getScannedDocumentAsImages(page: 1);
    } else {
      result = await ds._documentScanner.getScanDocuments(page: 1);
    }

    if (_docScannerIsEmptyScanResult(result)) {
      devLog('No document scanned', name: 'DocumentScanner');
      return null;
    }

    String? path;
    if (Platform.isAndroid) {
      path = await _docScannerExtractImagePath(ds, result);
    } else if (result is List) {
      final Object? first = result.isNotEmpty ? result.first : null;
      final String? source = first is String ? first : first?.toString();
      if (source != null && source.isNotEmpty) {
        path = await _docScannerCompressImage(ds, source);
      }
    } else if (result is String) {
      path = await _docScannerCompressImage(ds, result);
    } else if (result is Map && result['pdfUri'] != null) {
      path = result['pdfUri'].toString();
    }

    return path;
  } catch (e, st) {
    devLog('Document scan error: $e', name: 'DocumentScanner', error: e);
    devLog('Stack trace: $st', name: 'DocumentScanner');
    return null;
  }
}

Future<void> _docScannerScanDocument(
  DocumentScannerService ds,
  BuildContext context, {
  bool replacement = false,
}) async {
  BuildContext? scanningDialogContext;
  BuildContext? compressingDialogContext;

  try {
    final hasPermission = await _docScannerRequestCameraPermission(ds);
    if (!hasPermission) {
      _docScannerShowErrorSnackBar(
        ds,
        context,
        'Camera permission is required to scan documents',
      );
      return;
    }

    if (context.mounted) {
      _docScannerShowLoadingDialog(
        ds,
        context,
        'Scanning document...',
        onShown: (dialogCtx) => scanningDialogContext = dialogCtx,
      );
      await _docScannerAwaitLoadingDialogContext(
        routeContext: context,
        currentDialogContext: () => scanningDialogContext,
      );
    }

    Object? result;
    if (Platform.isAndroid) {
      result = await ds._documentScanner.getScannedDocumentAsImages(page: 1);
    } else {
      result = await ds._documentScanner.getScanDocuments(page: 1);
    }

    if (scanningDialogContext != null) {
      _docScannerCloseLoadingDialog(ds, scanningDialogContext!);
      scanningDialogContext = null;
    }

    if (_docScannerIsEmptyScanResult(result)) {
      _docScannerShowErrorSnackBar(ds, context, 'No document scanned');
      return;
    }

    devLog('Document scanned: $result', name: 'DocumentScanner');

    if (context.mounted) {
      _docScannerShowLoadingDialog(
        ds,
        context,
        'Compressing image...',
        onShown: (dialogCtx) => compressingDialogContext = dialogCtx,
      );
      await _docScannerAwaitLoadingDialogContext(
        routeContext: context,
        currentDialogContext: () => compressingDialogContext,
      );
    }

    String? imagePath;
    if (Platform.isAndroid) {
      final extractedPath = await _docScannerExtractImagePath(ds, result);
      if (extractedPath != null) {
        imagePath = await _docScannerCompressImage(ds, extractedPath);
        imagePath ??= extractedPath;
      }
    } else if (result is List && result.isNotEmpty) {
      final Object? first = result.first;
      final String source = first is String ? first : first?.toString() ?? '';
      imagePath = await _docScannerCompressImage(ds, source);
    }

    if (compressingDialogContext != null) {
      _docScannerCloseLoadingDialog(ds, compressingDialogContext!);
      compressingDialogContext = null;
    }

    if (imagePath == null || imagePath.isEmpty) {
      _docScannerShowErrorSnackBar(
        ds,
        context,
        'Failed to process scanned image',
      );
      return;
    }

    await _docScannerNavigateToCapturedImageDetails(
      ds,
      context,
      imagePath,
      replacement: replacement,
    );
  } catch (e) {
    devLog('Document scan error: $e', name: 'DocumentScanner', error: e);

    if (context.mounted) {
      _docScannerShowErrorSnackBar(ds, context, 'Scanning cancelled.');
    }
  } finally {
    if (scanningDialogContext != null) {
      _docScannerCloseLoadingDialog(ds, scanningDialogContext!);
      scanningDialogContext = null;
    }
    if (compressingDialogContext != null) {
      _docScannerCloseLoadingDialog(ds, compressingDialogContext!);
      compressingDialogContext = null;
    }
  }
}

Future<String?> _docScannerExtractImagePath(
  DocumentScannerService ds,
  dynamic result,
) async {
  try {
    final uri = _docScannerFirstImageUriFromResult(result);
    if (uri == null || uri.isEmpty) return null;

    final path = _docScannerResolveFilePath(uri);
    if (!await File(path).exists()) {
      devLog(
        'Scanned image file does not exist: $path',
        name: 'DocumentScanner',
      );
      return null;
    }
    return path;
  } catch (e) {
    devLog(
      'Error extracting image path: $e',
      name: 'DocumentScanner',
      error: e,
    );
    return null;
  }
}

Future<void> _docScannerCleanupTempFiles(DocumentScannerService ds) async {
  try {
    final dir = await getTemporaryDirectory();
    final files = dir.listSync();

    for (final file in files) {
      if (file.path.contains('compressed_')) {
        await file.delete();
      }
    }

    devLog('Temporary files cleaned up', name: 'DocumentScanner');
  } catch (e) {
    devLog('Cleanup error: $e', name: 'DocumentScanner', error: e);
  }
}
