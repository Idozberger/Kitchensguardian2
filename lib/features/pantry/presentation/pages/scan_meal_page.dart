import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';

import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details_page.dart';

class ScanMealPage extends StatefulWidget {
  const ScanMealPage({super.key});

  @override
  State<ScanMealPage> createState() => _ScanMealPageState();
}

class _ScanMealPageState extends State<ScanMealPage> {
  CameraController? _controller;

  @override
  void initState() {
    _initCamera();
    super.initState();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(firstCamera, ResolutionPreset.medium);

    await _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  bool _isCapturing = false;

  Future<void> _captureAndNavigate() async {
    if (_isCapturing) return;
    _isCapturing = true;
    try {
      final image = await _controller!.takePicture();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) {
            return CaptureDetailsPage(imagePath: image.path);
          },
        ),
      );
    } catch (e) {
      debugPrint("Error capturing image: $e");
    } finally {
      _isCapturing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: gapSymmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Container(
                height: h(458),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(h(20)),
                ),
                child: _controller == null
                    ? const Center(child: CircularProgressIndicator())
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(h(20)),
                        child: CameraPreview(_controller!),
                      ),
              ),
              SizedBox(height: h(20)),
              Text(
                "Tap the button to scan receipt item in your pantry",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontSize: t(15),
                  color: Colors.black,
                ),
              ),
              SizedBox(height: h(35)),
              GestureDetector(
                onTap: () => _captureAndNavigate(),
                child: Container(
                  padding: gapAll(22),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(AppAssets.cameraSvg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
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
        "Meal Scan",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
      actions: [
        SizedBox(width: w(16)),
        CircularIconButton(iconAsset: AppAssets.flashSvg, onTap: () {}),
        SizedBox(width: w(16)),
      ],
    );
  }
}
