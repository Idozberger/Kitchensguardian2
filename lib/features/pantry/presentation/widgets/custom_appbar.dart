import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

/// Custom AppBar
AppBar buildAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    leadingWidth: w(55),
    leading: Row(
      children: [
        SizedBox(width: w(16)),
        CircularIconButton(
          iconAsset: AppAssets.backArrowiOS,
          onTap: () => Navigator.pop(context),
        ),
      ],
    ),
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(h(70)),
      child: Padding(
        padding: gapSymmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: h(40),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    PermissionStatus status = await Permission.camera.status;

                    if (!status.isGranted) {
                      final result = await Permission.camera.request();
                      if (!result.isGranted) {
                        if (result.isPermanentlyDenied) {
                          openAppSettings();
                        }
                        return;
                      }
                    }

                    final documentOptions = DocumentScannerOptions(
                      documentFormat: DocumentFormat.jpeg,
                      mode: ScannerMode.base,
                      pageLimit: 1,
                      isGalleryImport: false,
                    );

                    final documentScanner = DocumentScanner(
                      options: documentOptions,
                    );

                    try {
                      final DocumentScanningResult result =
                          await documentScanner.scanDocument();

                      if (result.images.isNotEmpty) {
                        final image = result.images.first;

                        // ignore: use_build_context_synchronously
                        context.pushNamed(
                          Routes.capturedImageDetails,
                          extra: {"image_path": image},
                        );
                      }
                    } catch (e) {
                      debugPrint("Document scan error: $e");
                    } finally {
                      documentScanner.close();
                    }
                  },
                  icon: SvgPicture.asset(AppAssets.scanSvg),
                  label: Text(
                    "Scan",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: t(12),
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: w(10)),
            Expanded(
              child: SizedBox(
                height: h(40),
                child: ElevatedButton.icon(
                  onPressed: () => context.push(Routes.addItem),
                  icon: SvgPicture.asset(AppAssets.addSvg),
                  label: Text(
                    "Add Item",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: t(12),
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    title: Text("My Pantry", style: Theme.of(context).textTheme.headlineLarge),
  );
}
