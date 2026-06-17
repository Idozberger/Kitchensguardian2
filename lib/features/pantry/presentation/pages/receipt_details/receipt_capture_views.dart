import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/document_scanning/document_scanning_service.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/animated_dots.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class ReceiptCaptureLoadingView extends StatelessWidget {
  const ReceiptCaptureLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        AppAssets.loader,
        height: h(400),
        fit: BoxFit.contain,
      ),
    );
  }
}

class ReceiptCaptureScanningView extends StatelessWidget {
  const ReceiptCaptureScanningView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: gapAll(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: w(140),
                  height: h(140),
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor.withValues(alpha: 0.3),
                    ),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.7, end: 1.0),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeInOut,
                  builder: (_, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: w(100),
                        height: h(100),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor.withValues(alpha: 0.6),
                              AppColors.primaryColor.withValues(alpha: 0.2),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Lottie.asset(
                  AppAssets.loader,
                  width: w(120),
                  height: h(120),
                  fit: BoxFit.contain,
                ),
              ],
            ),
            SizedBox(height: h(40)),
            Text(
              "Scanning your receipt...",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: t(22),
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: h(16)),
            AnimatedDotsText(
              text: "Analyzing items with AI",
              style: TextStyle(
                fontSize: t(15),
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            SizedBox(height: h(20)),
            Text(
              "This usually takes a few seconds",
              style: TextStyle(fontSize: t(13), color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiptCaptureEmptyView extends StatelessWidget {
  const ReceiptCaptureEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: gapSymmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.groceryEmpty,
              width: w(220),
              height: h(220),
              fit: BoxFit.contain,
            ),
            SizedBox(height: h(32)),
            Text(
              "No items detected",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: t(24),
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: h(16)),
            Text(
              "We couldn't recognize any items from this receipt.\nTry taking a clearer photo or add items manually.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: t(15),
                color: Colors.grey.shade600,
                height: 1.6,
              ),
            ),
            SizedBox(height: h(48)),
            GenericButtonWidget(
              onPressed: () => DocumentScannerService().scanDocument(
                context,
                replacement: true,
              ),
              text: "Retake",
            ),
            SizedBox(height: h(16)),
            TextButton(
              onPressed: () => context.pushNamed(Routes.addItem),
              child: Text(
                "Add Items Manually",
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: t(15),
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceiptCaptureErrorView extends StatelessWidget {
  const ReceiptCaptureErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    required this.onRetake,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onRetake;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: gapSymmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Oops!",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: t(24),
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            SizedBox(height: h(12)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: t(15), color: Colors.grey.shade700),
            ),
            SizedBox(height: h(32)),
            GenericButtonWidget(onPressed: onRetry, text: "Retry"),
            SizedBox(height: h(16)),
            TextButton(
              onPressed: onRetake,
              child: Text(
                "Retake",
                style: TextStyle(
                  fontSize: t(15),
                  color: AppColors.primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

PreferredSizeWidget receiptCaptureAppBar(BuildContext context) {
  return AppBar(
    leadingWidth: w(55),
    leading: Row(
      children: [
        SizedBox(width: w(16)),
        CircularIconButton(
          iconAsset: AppAssets.backArrowiOS,
          onTap: () => context.pop(),
        ),
      ],
    ),
    title: Text(
      "Receipt Scan",
      style: Theme.of(context).textTheme.headlineLarge,
    ),
    actions: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: w(16)),
        child: CircularIconButton(
          iconAsset: AppAssets.cameraSwitchSvg,
          onTap: () =>
              DocumentScannerService().scanDocument(context, replacement: true),
        ),
      ),
    ],
  );
}
