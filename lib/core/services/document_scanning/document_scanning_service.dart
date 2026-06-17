// ignore_for_file: use_build_context_synchronously
// Router navigation after scanner/permission futures; tighten with mounted checks later.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

part 'document_scanning_service_impl_part.dart';

class DocumentScannerService {
  static final DocumentScannerService _instance =
      DocumentScannerService._internal();

  factory DocumentScannerService() {
    return _instance;
  }

  DocumentScannerService._internal();

  final FlutterDocScanner _documentScanner = FlutterDocScanner();

  Future<String?> scanAndGetPath() => _docScannerScanAndGetPath(this);

  Future<void> scanDocument(BuildContext context, {bool replacement = false}) =>
      _docScannerScanDocument(this, context, replacement: replacement);

  Future<void> cleanupTempFiles() => _docScannerCleanupTempFiles(this);
}
