// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DocumentScannerService {
  static final DocumentScannerService _instance =
      DocumentScannerService._internal();

  factory DocumentScannerService() {
    return _instance;
  }

  DocumentScannerService._internal();

  final FlutterDocScanner _documentScanner = FlutterDocScanner();

  Future<String> _getCompressedImagePath(String originalPath) async {
    final dir = await getTemporaryDirectory();
    final fileName = 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return '${dir.path}/$fileName';
  }

  Future<String?> _compressImage(String sourcePath) async {
    try {
      final outputPath = await _getCompressedImagePath(sourcePath);
      final originalFile = File(sourcePath);
      final originalSize = await originalFile.length();

      developer.log(
        'Original image size: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB',
        name: 'DocumentScanner',
      );

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        outputPath,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      if (compressedFile != null && compressedFile.path.isNotEmpty) {
        final compressedSize = await File(compressedFile.path).length();
        developer.log(
          'Compressed image size: ${(compressedSize / 1024).toStringAsFixed(2)} KB',
          name: 'DocumentScanner',
        );
        return compressedFile.path;
      }
      return null;
    } catch (e) {
      developer.log(
        'Image compression error: $e',
        name: 'DocumentScanner',
        error: e,
      );
      return null;
    }
  }

  Future<bool> _requestCameraPermission() async {
    try {
      PermissionStatus status = await Permission.camera.status;

      if (!status.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          if (result.isDenied) {
            developer.log('Camera permission denied', name: 'DocumentScanner');
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
      developer.log(
        'Permission request error: $e',
        name: 'DocumentScanner',
        error: e,
      );
      return false;
    }
  }

  Future<void> _navigateToCapturedImageDetails(
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

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Scaffold(
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
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    AppToast.show(message, ToastType.error, gravity: ToastGravity.TOP);
  }

  void _closeLoadingDialog(BuildContext context) {
    if (context.mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<String?> scanAndGetPath() async {
    try {
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        developer.log('Camera permission denied', name: 'DocumentScanner');
        return null;
      }

      dynamic result;
      if (Platform.isAndroid) {
        result = await _documentScanner.getScannedDocumentAsImages(page: 1);
      } else {
        result = await _documentScanner.getScanDocuments(page: 1);
      }

      if (result == null || (result is List && result.isEmpty)) {
        developer.log('No document scanned', name: 'DocumentScanner');
        return null;
      }

      String? path;
      if (Platform.isAndroid) {
        path = await _extractImagePath(result);
      } else if (result is List) {
        path = await _compressImage(result.first);
      } else if (result is String) {
        path = await _compressImage(result);
      } else if (result is Map && result['pdfUri'] != null) {
        path = result['pdfUri'].toString();
      }

      return path;
    } catch (e, st) {
      developer.log(
        'Document scan error: $e',
        name: 'DocumentScanner',
        error: e,
      );
      developer.log('Stack trace: $st', name: 'DocumentScanner');
      return null;
    }
  }

  Future<void> scanDocument(
    BuildContext context, {
    bool replacement = false,
  }) async {
    try {
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        _showErrorSnackBar(
          context,
          'Camera permission is required to scan documents',
        );
        return;
      }

      if (context.mounted) {
        _showLoadingDialog(context, 'Scanning document...');
      }

      // ignore: prefer_typing_uninitialized_variables
      var result;
      if (Platform.isAndroid) {
        result = await _documentScanner.getScannedDocumentAsImages(page: 1);
      } else {
        result = await _documentScanner.getScanDocuments(page: 1);
      }

      _closeLoadingDialog(context);

      if (result.isEmpty) {
        _showErrorSnackBar(context, 'No document scanned');
        return;
      }

      developer.log('Document scanned: $result', name: 'DocumentScanner');

      if (context.mounted) {
        _showLoadingDialog(context, 'Compressing image...');
      }

      String? compressedPath;
      if (Platform.isAndroid) {
        compressedPath = await _extractImagePath(result);
      } else {
        compressedPath = await _compressImage(result.first);
      }

      _closeLoadingDialog(context);

      final imagePath = compressedPath ?? result.first;

      await _navigateToCapturedImageDetails(
        context,
        imagePath,
        replacement: replacement,
      );
    } catch (e) {
      developer.log(
        'Document scan error: $e',
        name: 'DocumentScanner',
        error: e,
      );

      if (context.mounted) {
        _showErrorSnackBar(context, 'Scanning cancelled.');
      }
    }
  }

  Future<String?> _extractImagePath(dynamic result) async {
    try {
      return "${(result.toString().split("{Uri: [Page{imageUri=file:///")[1]).split(".jpg")[0]}.jpg";
    } catch (e) {
      developer.log(
        'Error extracting image path: $e',
        name: 'DocumentScanner',
        error: e,
      );
      return null;
    }
  }

  Future<void> cleanupTempFiles() async {
    try {
      final dir = await getTemporaryDirectory();
      final files = dir.listSync();

      for (final file in files) {
        if (file.path.contains('compressed_')) {
          await file.delete();
        }
      }

      developer.log('Temporary files cleaned up', name: 'DocumentScanner');
    } catch (e) {
      developer.log('Cleanup error: $e', name: 'DocumentScanner', error: e);
    }
  }
}
