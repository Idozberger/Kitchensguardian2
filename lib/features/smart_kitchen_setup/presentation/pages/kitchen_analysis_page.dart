import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/utils/format_date_for_backend.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_event.dart';
import 'package:foodkitchen/features/pantry/presentation/models/pantry_items.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/add_item/add_item_page_chrome.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/add_item/add_item_pantry_item_form.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/domain/entities/scanned_item.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/bloc/smart_kitchen_setup_bloc.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/bloc/smart_kitchen_setup_event.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/bloc/smart_kitchen_setup_state.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/widgets/ai_analyzing_loader.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/widgets/kitchen_analysis_empty_items_placeholder.dart';
import 'package:go_router/go_router.dart';

part 'kitchen_analysis_page_part.dart';

class KitchenAnalysisPage extends StatefulWidget {
  final List<PantryItem> pantryItems;
  const KitchenAnalysisPage({super.key, this.pantryItems = const []});

  @override
  State<KitchenAnalysisPage> createState() => _KitchenAnalysisPageState();
}

class _KitchenAnalysisPageState extends State<KitchenAnalysisPage> {
  late PantryBloc _pantryBloc;
  late UserCubit _userCubit;
  late SmartKitchenSetupBloc smartKitchenSetupBloc;
  List<PantryItem> _items = [];

  @override
  void initState() {
    super.initState();
    _pantryBloc = context.read<PantryBloc>();
    _userCubit = context.read<UserCubit>();
    smartKitchenSetupBloc = context.read<SmartKitchenSetupBloc>();
  }

  void getScannedItems(SmartKitchenSetupState state) {
    if (_items.isEmpty && !state.isLoading) {
      for (final scanned in state.scannedItems) {
        _items.add(kitchenAnalysisMapScannedToPantryItem(scanned));
      }
      if (_items.any((item) => item.needsReview)) {
        AppToast.show(
          "Some items had low detection confidence — please review them before confirming.",
          ToastType.warning,
        );
      }
      setState(() {});
    }
  }

  void _retryScan() {
    setState(() => _items = []);
    smartKitchenSetupBloc.add(
      SmartKitchenSetupApiCalled(
        kitchenId: _userCubit.state.activeKitchenId,
        payload: smartKitchenSetupBloc.state.payload,
      ),
    );
  }

  void _addNewItem() {
    setState(() {
      if (widget.pantryItems.isNotEmpty) {
        _items = widget.pantryItems;
      } else {
        _items.add(
          PantryItem(
            nameController: TextEditingController(),
            qtyController: TextEditingController(),
            expireDate: TextEditingController(),
            manuFacturingDate: TextEditingController(),
          ),
        );
      }
    });
  }

  void _resetState() {
    setState(() {
      _items = [];
      _addNewItem();
    });
  }

  void _handleFinalizeSuccess(String message) {
    AppToast.show(message, ToastType.success);
    final kitchenId = _userCubit.state.activeKitchenId;
    smartKitchenSetupBloc.add(AddDefaultStoragesEvent(kitchenId: kitchenId));
    _pantryBloc.add(GetPantryItemsEvent(kitchenId: kitchenId));
    smartKitchenSetupBloc.add(SmartKitchenSetupFinalizeAcknowledged());
    context.go(Routes.dashboard);
    _resetState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          await Future<void>.delayed(Duration.zero);
          _handleBackNavigation();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AddItemPageAppBar(
          isMember: false,
          titleOverride: "Confirm Items",
          onBack: _handleBackNavigation,
        ),
        body: BlocConsumer<SmartKitchenSetupBloc, SmartKitchenSetupState>(
          listener: (context, state) {
            if (state.finalizeSuccessMessage != null) {
              _handleFinalizeSuccess(state.finalizeSuccessMessage!);
            } else if (state.scannedItems.isNotEmpty) {
              getScannedItems(state);
            } else if (state.errorMessage != null) {
              AppToast.show(state.errorMessage!, ToastType.error);
            }
          },
          builder: (context, smartKitchenSetupState) {
            final isBusy =
                smartKitchenSetupState.isLoading ||
                smartKitchenSetupState.isFinalizing;

            return isBusy
                ? const AiAnalyzingLoader()
                : SafeArea(
                    child: Padding(
                      padding: gapSymmetric(horizontal: 20, vertical: 0),
                      child: Column(
                        children: [
                          gap(height: 14),
                          Expanded(
                            child: BlocBuilder<UserCubit, UserState>(
                              builder: (context, userState) {
                                if (_items.isEmpty) {
                                  return KitchenAnalysisEmptyItemsPlaceholder(
                                    errorMessage:
                                        smartKitchenSetupState.errorMessage,
                                    onRetry: _retryScan,
                                    onAddManually: _addNewItem,
                                  );
                                }

                                return ListView.builder(
                                  padding: gapZero,
                                  shrinkWrap: true,
                                  itemCount: _items.length,
                                  itemBuilder: (context, index) {
                                    final item = _items[index];
                                    return Padding(
                                      padding: gapOnly(bottom: 12),
                                      child: Stack(
                                        children: [
                                          UpperTile(
                                            borderColor: item.needsReview
                                                ? Colors.orange
                                                : null,
                                            widget: AddItemPantryItemForm(
                                              item: item,
                                              userState: userState,
                                              isMember: false,
                                              isFirstItem: _items.first == item,
                                              updateState: setState,
                                              onRemove: () => setState(
                                                () => _items.remove(item),
                                              ),
                                            ),
                                          ),
                                          if (item.needsReview)
                                            const Positioned(
                                              top: 6,
                                              right: 6,
                                              child: Icon(
                                                Icons.warning_amber_rounded,
                                                color: Colors.orange,
                                                size: 20,
                                              ),
                                            ),
                                          if (item.libraryMatch != null)
                                            const Positioned(
                                              top: 6,
                                              left: 6,
                                              child: Tooltip(
                                                message:
                                                    'Matched from shared ingredient library',
                                                child: Icon(
                                                  Icons.verified,
                                                  color: Colors.green,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
          },
        ),
        bottomNavigationBar:
            BlocBuilder<SmartKitchenSetupBloc, SmartKitchenSetupState>(
              builder: (context, smartKitchenState) {
                if (_items.isEmpty ||
                    smartKitchenState.isLoading ||
                    smartKitchenState.isFinalizing) {
                  return const SizedBox.shrink();
                }
                return PantryItemSubmitFooter(
                  showAddMore: true,
                  submitLabel: "Add Item",
                  onAddMore: _addNewItem,
                  onSubmit: _handleSubmitItems,
                );
              },
            ),
      ),
    );
  }

  Future<void> _handleSubmitItems() async {
    for (int i = 0; i < _items.length; i++) {
      final item = _items[i];
      final validation = kitchenAnalysisValidateRow(item);
      if (validation != null) {
        AppToast.show(validation, ToastType.error);
        return;
      }
    }

    final payload = _items.map(kitchenAnalysisToEditPayload).toList();
    smartKitchenSetupBloc.add(
      SmartKitchenSetupFinalizeReviewed(items: payload),
    );
  }

  void _handleBackNavigation() {
    if (_items.isEmpty) {
      _goBack();
      return;
    }

    final hasUserInput = _items.any(
      (item) =>
          item.file != null ||
          item.nameController.text.trim().isNotEmpty ||
          item.qtyController.text.trim().isNotEmpty ||
          (item.unit != null && item.unit!.isNotEmpty) ||
          (item.pantry != null && item.pantry!.isNotEmpty) ||
          item.expireDate.text.isNotEmpty,
    );

    if (hasUserInput) {
      _showConfirmDialog(
        title: "Go Back",
        subtitle:
            "If you go back, the items you just added will be removed. Continue?",
        onConfirm: () {
          Navigator.of(context).pop();
          _goBack();
        },
      );
    } else {
      _goBack();
    }
  }

  void _goBack() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = GoRouter.of(context);
      if (router.canPop()) {
        router.pop();
      }
    });
  }

  Future<void> _showConfirmDialog({
    required String title,
    required String subtitle,
    required VoidCallback onConfirm,
  }) {
    return showCustomGenericDialog(
      context: context,
      title: title,
      subtitle: subtitle,
      primaryButtonText: "Yes",
      secondaryButtonText: "Cancel",
      onPrimaryPressed: onConfirm,
      onSecondaryPressed: () => context.pop(),
    );
  }
}
