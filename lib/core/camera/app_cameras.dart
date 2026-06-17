import 'package:camera/camera.dart';
import 'package:foodkitchen/core/logging/app_logger.dart';

/// Lazily populated by [ensureAppCamerasLoaded]; avoid loading at app cold start.
List<CameraDescription> appCameras = [];

Future<void> ensureAppCamerasLoaded() async {
  if (appCameras.isNotEmpty) return;
  try {
    appCameras = await availableCameras();
  } catch (e, st) {
    AppLogger.recordNonFatal(e, st, reason: 'ensureAppCamerasLoaded');
  }
}
