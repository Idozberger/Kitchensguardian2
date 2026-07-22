import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';
import 'package:go_router/go_router.dart';

enum _ScanStatus { none, scanning, ready }

/// App-wide overlay mounted in the authenticated `ShellRoute`. Lets the user
/// leave the receipt scan screen and keep browsing: shows "Scanning…" while a
/// scan runs and "Receipt ready — N items" (tap to review) when it finishes.
///
/// Driven by [PantryBloc] scan states only (see [BlocListener.listenWhen]) —
/// a [BlocBuilder] would clear the banner on unrelated pantry emissions.
class ScanStatusBanner extends StatefulWidget {
  final Widget child;
  const ScanStatusBanner({super.key, required this.child});

  @override
  State<ScanStatusBanner> createState() => _ScanStatusBannerState();
}

class _ScanStatusBannerState extends State<ScanStatusBanner> {
  _ScanStatus _status = _ScanStatus.none;
  int _count = 0;
  String _imagePath = '';
  bool _dismissed = false;

  /// Suppress the overlay while the user is on the scan page itself — that page
  /// already renders the scanning view / items list inline.
  bool get _onCapturePage =>
      GoRouter.of(context).routerDelegate.currentConfiguration.uri.path ==
      Routes.capturedImageDetails;

  @override
  Widget build(BuildContext context) {
    final showOverlay =
        _status != _ScanStatus.none && !_dismissed && !_onCapturePage;

    return BlocListener<PantryBloc, PantryState>(
      listenWhen: (_, current) =>
          current is PantryScanItemsLoading ||
          current is ScanReceiptLoaded ||
          current is PantrySuccess,
      listener: (context, state) => setState(() {
        if (state is PantryScanItemsLoading) {
          _status = _ScanStatus.scanning;
          _dismissed = false;
        } else if (state is ScanReceiptLoaded) {
          _status = _ScanStatus.ready;
          _count = state.scanReceipt.items.length;
          _imagePath = state.imagePath;
          _dismissed = false;
        } else if (state is PantrySuccess) {
          _status = _ScanStatus.none;
        }
      }),
      // Compact pill overlaid in the app-bar band, starting to the right of the
      // back button so it never covers it.
      child: Stack(
        children: [
          widget.child,
          if (showOverlay)
            Positioned(
              top: 0,
              left: w(56),
              right: w(10),
              child: SafeArea(
                bottom: false,
                child: Align(alignment: Alignment.centerLeft, child: _banner()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _banner() {
    final isReady = _status == _ScanStatus.ready;
    return Padding(
      padding: EdgeInsets.only(top: h(6)),
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: isReady ? _openReview : null,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: w(10), vertical: h(6)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isReady)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primaryColor,
                    size: t(16),
                  )
                else
                  SizedBox(
                    width: t(14),
                    height: t(14),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor,
                      ),
                    ),
                  ),
                SizedBox(width: w(8)),
                Flexible(
                  child: Text(
                    isReady
                        ? 'Receipt ready — $_count ${_count == 1 ? "item" : "items"} · Review'
                        : 'Scanning receipt…',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: t(12),
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (isReady)
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.greyColor,
                    size: t(18),
                  ),
                GestureDetector(
                  onTap: () => setState(() => _dismissed = true),
                  child: Padding(
                    padding: EdgeInsets.only(left: w(6)),
                    child: Icon(
                      Icons.close,
                      color: AppColors.greyColor,
                      size: t(15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openReview() {
    setState(() => _dismissed = true);
    context.pushNamed(
      Routes.capturedImageDetails,
      extra: {'image_path': _imagePath, 'resume': true},
    );
  }
}
