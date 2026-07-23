// ignore_for_file: unnecessary_underscores, use_build_context_synchronously
// Large receipt flow: legacy underscores; context after scan/compress awaits.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:foodkitchen/core/ads/ad_service.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/di/service_locator.dart';
import 'package:foodkitchen/core/services/document_scanning/document_scanning_service.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';
import 'package:foodkitchen/features/pantry/presentation/models/pantry_items.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/confirm_button.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/image_preview.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/receipt_capture_item_form.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/receipt_capture_views.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'receipt_scanned_details_page_part.dart';

class CaptureDetailsPage extends StatefulWidget {
  final String imagePath;

  /// True when the page was reopened after the scan finished off-screen: the
  /// items are already in [ScanReceiptLoaded], so skip the ad + re-scan.
  final bool resume;
  const CaptureDetailsPage({
    super.key,
    required this.imagePath,
    this.resume = false,
  });

  @override
  State<CaptureDetailsPage> createState() => _CaptureDetailsPageState();
}

class _CaptureDetailsPageState extends State<CaptureDetailsPage> {
  late PantryBloc _pantryBloc;
  late UserCubit _userCubit;
  List<PantryItem> _items = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pantryBloc = context.read<PantryBloc>();
    _userCubit = context.read<UserCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.resume) {
        final state = _pantryBloc.state;
        if (state is ScanReceiptLoaded) _initializeItems(state.scanReceipt);
        return;
      }
      showAdLoadingDialog(context);
      scanReceipt();
    });
  }

  void showAdLoadingDialog(BuildContext context) async {
    if (context.read<UserCubit>().state.hasPremiumAccess) return;
    await Future<void>.delayed(Duration(milliseconds: 50));
    AdService.instance.loadAndShowInterstitial(
      context: context,
      onDismissed: () {},
    );
  }

  void scanReceipt() async {
    if (!File(widget.imagePath).existsSync()) {
      AppToast.show(
        "Receipt photo could not be found. Please retake the photo.",
        ToastType.error,
      );
      return;
    }

    final prefs = sl<SharedPreferences>();

    final countryCode = prefs.getString("country") ?? "USA";
    final currencyCode = prefs.getString("currency") ?? "USD";
    final kitchenId =
        prefs.getString("kitchen_id") ?? _userCubit.state.activeKitchenId;

    if (kitchenId.isEmpty) {
      AppToast.show("No active kitchen selected", ToastType.error);
      return;
    }

    _pantryBloc.add(
      ScanReceiptEvent(
        filePath: widget.imagePath,
        country: countryCode,
        currency: currencyCode,
        kitchenId: kitchenId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PantryBloc, PantryState>(
      listener: _handleStateChange,
      builder: (context, state) => Scaffold(
        appBar: receiptCaptureAppBar(context),
        body: _buildBody(state),
        bottomNavigationBar: _items.isNotEmpty && state is! PantryLoading
            ? ColoredBox(
                color: Colors.white,
                child: ConfirmButtonWidget(
                  onPressed: _validateAndSubmit,
                  isloading: state is PantryLoading,
                ),
              )
            : null,
      ),
    );
  }

  void _handleStateChange(BuildContext context, PantryState state) {
    if (state is PantryFailure) {
      if (_items.isEmpty) {
        setState(() => _errorMessage = state.errorMessage);
      } else {
        AppToast.show(state.errorMessage, ToastType.error);
      }
    } else if (state is PantrySuccess) {
      AppToast.show(
        "Items added to your kitchen successfully!",
        ToastType.success,
      );
      context.goNamed(
        Routes.dashboard,
        extra: {
          'fromNotification': false,
          'entryType': DashboardEntryType.normal,
        },
      );
    } else if (state is ScanReceiptLoaded) {
      _initializeItems(state.scanReceipt);
    }
  }

  Widget _buildBody(PantryState state) {
    if (_errorMessage != null) {
      return ReceiptCaptureErrorView(
        message: _errorMessage!,
        onRetry: () {
          setState(() => _errorMessage = null);
          scanReceipt();
        },
        onRetake: () =>
            DocumentScannerService().scanDocument(context, replacement: true),
      );
    }

    return SafeArea(
      child: switch (state) {
        PantryLoading() => const ReceiptCaptureLoadingView(),
        PantryScanItemsLoading() => const ReceiptCaptureScanningView(),
        ScanReceiptLoaded() =>
          _items.isEmpty
              ? const ReceiptCaptureEmptyView()
              : _buildItemsListView(),
        _ => const SizedBox(),
      },
    );
  }

  Widget _buildItemsListView() {
    return ReceiptItemsListView(
      imagePath: widget.imagePath,
      items: _items,
      userCubit: _userCubit,
      onItemRemoved: (item) => setState(() => _items.remove(item)),
      onFieldChanged: () => setState(() {}),
    );
  }

  void _initializeItems(ScanReceiptEntity scanReceipt) {
    if (_items.isNotEmpty) return;
    setState(() {
      _items = receiptMapScanToPantryItems(scanReceipt);
    });
    if (_items.any((item) => item.needsReview)) {
      AppToast.show(
        "Some items had low detection confidence — please review them before confirming.",
        ToastType.warning,
      );
    }
  }

  void _validateAndSubmit() {
    for (int i = 0; i < _items.length; i++) {
      final validation = receiptValidatePantryItem(_items[i], i);
      if (validation != null) {
        AppToast.show(validation, ToastType.error);
        return;
      }
    }
    _confirmItems();
  }

  Future<void> _confirmItems() async {
    final pantryModel = await receiptBuildPantryFromItems(
      items: _items,
      kitchenId: _userCubit.state.activeKitchenId,
    );
    _pantryBloc.add(PantryAddScannedItemEvent(pantry: pantryModel));
  }
}
