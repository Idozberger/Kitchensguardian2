// ignore_for_file: use_build_context_synchronously
// Camera lifecycle and capture futures finish before navigation; guard later.

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/camera/app_cameras.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/camera_permission_denied.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/document_scanning/document_scanning_service.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanMealPage extends StatefulWidget {
  const ScanMealPage({super.key});

  @override
  State<ScanMealPage> createState() => _ScanMealPageState();
}

class _ScanMealPageState extends State<ScanMealPage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  String? capturedImagePath;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.status;

    if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        _initializeCameraController();
      } else if (result.isPermanentlyDenied) {
        showPermissionDialog(context);
      } else {
        _showDeniedSnackBar();
      }
      return;
    }

    if (status.isPermanentlyDenied) {
      showPermissionDialog(context);
      return;
    }

    if (status.isGranted) {
      _initializeCameraController();
    }
  }

  Future<void> _initializeCameraController() async {
    await ensureAppCamerasLoaded();
    if (appCameras.isEmpty) return;

    _controller = CameraController(
      appCameras[0],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      devPrint('Camera init error: $e');
      _controller?.dispose();
    }
  }

  void _showDeniedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Camera permission denied. Please enable it to use scanning.',
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _captureImage() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isCapturing) {
      return;
    }
    setState(() => _isCapturing = true);

    try {
      final image = await _controller!.takePicture();
      final compressedPath = await DocumentScannerService().compressImage(
        image.path,
      );
      final finalPath = compressedPath ?? image.path;
      setState(() => capturedImagePath = finalPath);

      context.pushNamed(
        Routes.capturedImageDetails,
        extra: {"image_path": finalPath},
      );
    } catch (e) {
      devPrint("Capture error: $e");
    } finally {
      setState(() => _isCapturing = false);
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;
    try {
      final isTorch = _controller!.value.flashMode == FlashMode.torch;
      await _controller!.setFlashMode(
        isTorch ? FlashMode.off : FlashMode.torch,
      );
      setState(() {});
    } catch (e) {
      devPrint("Flash toggle error: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: gapSymmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              _buildCameraPreview(),
              SizedBox(height: h(20)),
              _buildDescription(),
              SizedBox(height: h(35)),
              _buildCaptureButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      height: h(458),
      width: w(400),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(h(20)),
      ),
      child: !_isCameraInitialized
          ? Center(child: Lottie.asset(AppAssets.loader))
          : ClipRRect(
              borderRadius: BorderRadius.circular(h(20)),
              child: CameraPreview(_controller!),
            ),
    );
  }

  Widget _buildDescription() => Text(
    "Tap the button to scan receipt item in your pantry",
    textAlign: TextAlign.center,
    style: Theme.of(
      context,
    ).textTheme.headlineMedium!.copyWith(fontSize: t(15), color: Colors.black),
  );

  Widget _buildCaptureButton() => GestureDetector(
    onTap: _captureImage,
    child: Container(
      padding: gapAll(22),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(AppAssets.cameraSvg),
    ),
  );

  AppBar _buildAppBar() {
    return AppBar(
      leadingWidth: w(55),
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      title: Text(
        "Scan Receipt",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      actions: [
        CircularIconButton(iconAsset: AppAssets.flashSvg, onTap: _toggleFlash),
        SizedBox(width: w(16)),
      ],
    );
  }
}
