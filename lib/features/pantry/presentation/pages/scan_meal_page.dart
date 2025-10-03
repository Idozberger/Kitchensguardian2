import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/list_tile.dart';
import 'package:go_router/go_router.dart';

class ScanMealPage extends StatefulWidget {
  const ScanMealPage({super.key});

  @override
  State<ScanMealPage> createState() => _ScanMealPageState();
}

class _ScanMealPageState extends State<ScanMealPage> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(firstCamera, ResolutionPreset.medium);

    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureAndNavigate() async {
    try {
      // await _initializeControllerFuture;
      // final image = await _controller!.takePicture();

      // if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CaptureDetailsPage(imagePath: null)),
      );
    } catch (e) {
      debugPrint("Error capturing image: $e");
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
                    : FutureBuilder(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(h(20)),
                              child: CameraPreview(_controller!),
                            );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
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
                onTap: _captureAndNavigate,
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

class CaptureDetailsPage extends StatelessWidget {
  final String? imagePath;
  const CaptureDetailsPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: gapAll(20),
          child: Column(
            children: [
              Container(
                height: h(400),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black,
                  image: imagePath != null
                      ? DecorationImage(
                          image: FileImage(File(imagePath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              SizedBox(height: h(12)),
              CounterListWidget(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: gapAll(20),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GenericButtonWidget(
                onPressed: () {
                  context.go(Routes.dashboard);
                },
                text: "Confirm",
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
        CircularIconButton(iconAsset: AppAssets.cameraSwitchSvg, onTap: () {}),
        SizedBox(width: w(16)),
      ],
    );
  }
}

class CounterListWidget extends StatefulWidget {
  const CounterListWidget({super.key});

  @override
  State<CounterListWidget> createState() => _CounterListWidgetState();
}

class _CounterListWidgetState extends State<CounterListWidget> {
  List<int> counters = [1, 1];

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: UpperTile(
        widget: Column(
          children: [
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: counters.length,
                separatorBuilder: (context, index) => Padding(
                  padding: gapSymmetric(vertical: 10),
                  child: const Divider(color: Color(0xFFF4F4F4), height: 1),
                ),
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: ListItemWidget(
                          text: "Chicken",
                          crossAlignment: CrossAxisAlignment.center,
                        ),
                      ),

                      /// increment/decrement row
                      Row(
                        children: [
                          _iconButtonContainer(
                            iconPath: AppAssets.decreamentSvg,
                            onTap: () {
                              if (counters[index] > 0) {
                                setState(() {
                                  counters[index]--;
                                });
                              }
                            },
                          ),
                          SizedBox(width: w(8)),
                          Text(
                            "${counters[index]}",
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontSize: t(10),
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          SizedBox(width: w(8)),
                          _iconButtonContainer(
                            iconPath: AppAssets.increamentSvg,
                            onTap: () {
                              setState(() {
                                counters[index]++;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButtonContainer({
    required String iconPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD4D2D2)),
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(iconPath),
      ),
    );
  }
}
