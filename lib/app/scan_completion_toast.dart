import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';
import 'package:go_router/go_router.dart';

/// Mounted in the authenticated `ShellRoute`. Receipt scanning keeps running
/// after the user leaves the capture page, so this reports the outcome: a toast
/// plus, on success, reopening the review page with the scanned items. Nothing
/// is rendered — there is no progress overlay while the scan runs.
class ScanCompletionToast extends StatefulWidget {
  final Widget child;
  const ScanCompletionToast({super.key, required this.child});

  @override
  State<ScanCompletionToast> createState() => _ScanCompletionToastState();
}

class _ScanCompletionToastState extends State<ScanCompletionToast> {
  /// Tells a failed scan apart from every other pantry error, which belongs to
  /// the screen that caused it.
  bool _scanInFlight = false;

  /// The capture page reports scan progress and errors inline, so stay quiet
  /// while the user is still on it.
  bool get _onCapturePage =>
      GoRouter.of(context).routerDelegate.currentConfiguration.uri.path ==
      Routes.capturedImageDetails;

  void _onPantryState(BuildContext context, PantryState state) {
    if (state is PantryScanItemsLoading) {
      _scanInFlight = true;
      return;
    }

    if (state is ScanReceiptLoaded) {
      final count = state.scanReceipt.items.length;
      if (!_onCapturePage) {
        AppToast.show(
          'Receipt scanned — $count ${count == 1 ? "item" : "items"}',
          ToastType.success,
        );
        // `resume` seeds the page from this state instead of re-scanning.
        context.pushNamed(
          Routes.capturedImageDetails,
          extra: {'image_path': state.imagePath, 'resume': true},
        );
      }
    } else if (state is PantryFailure && _scanInFlight && !_onCapturePage) {
      AppToast.show(state.errorMessage, ToastType.error);
    }

    _scanInFlight = false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PantryBloc, PantryState>(
      listenWhen: (_, current) =>
          current is PantryScanItemsLoading ||
          current is ScanReceiptLoaded ||
          current is PantryFailure ||
          current is PantrySuccess,
      listener: _onPantryState,
      child: widget.child,
    );
  }
}
