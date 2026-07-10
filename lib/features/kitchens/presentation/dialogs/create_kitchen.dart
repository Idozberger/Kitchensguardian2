import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_dropdown_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_event.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_state.dart';

Future<dynamic> showCreateKitchenDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => const _CreateKitchenDialogContent(),
  );
}

class _CreateKitchenDialogContent extends StatefulWidget {
  const _CreateKitchenDialogContent();

  @override
  State<_CreateKitchenDialogContent> createState() =>
      _CreateKitchenDialogContentState();
}

class _CreateKitchenDialogContentState
    extends State<_CreateKitchenDialogContent> {
  late final TextEditingController _kitchenNameController;

  /// Measurement system chosen at creation (BRD UC-03); defaults to metric.
  UnitSystem _unitSystem = UnitSystem.metric;

  @override
  void initState() {
    super.initState();
    _kitchenNameController = TextEditingController();
  }

  @override
  void dispose() {
    _kitchenNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<KitchenBloc, KitchenState>(
      listener: _handleStateChange,
      builder: (context, state) => _buildDialog(state),
    );
  }

  void _handleStateChange(BuildContext context, KitchenState state) {
    if (state is KitchenSuccess) {
      Navigator.pop(context, true);
    }
  }

  Widget _buildDialog(KitchenState state) {
    return GenericDialog(
      borderRadius: h(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          SizedBox(height: h(10)),
          _buildTextField(),
          SizedBox(height: h(10)),
          _buildUnitSystemField(),
          SizedBox(height: h(10)),
          _buildCreateButton(state),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Kitchen Name",
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: t(20),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context, true),
          icon: SvgPicture.asset(AppAssets.cancelSvg),
        ),
      ],
    );
  }

  Widget _buildTextField() {
    return AppTextField(
      isLabled: false,
      label: "e.g: Emily Kitchen",
      hintText: "e.g: Emily Kitchen",
      controller: _kitchenNameController,
    );
  }

  Widget _buildUnitSystemField() {
    return PopupDropdownField(
      label: "Measurement System",
      hint: "Select system",
      value: unitSystemToApi(_unitSystem),
      items: unitSystemOptions,
      displayLabel: unitSystemDisplayLabel,
      onChanged: (value) {
        if (value == null) return;
        setState(() => _unitSystem = unitSystemFromApi(value));
      },
    );
  }

  Widget _buildCreateButton(KitchenState state) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: w(147),
        height: h(40),
        child: GenericButtonWidget(
          isLoading: state is KitchensLoading,
          onPressed: _handleCreatePressed,
          text: "Create",
        ),
      ),
    );
  }

  void _handleCreatePressed() {
    final kitchenName = _kitchenNameController.text.trim();

    if (kitchenName.isEmpty) {
      AppToast.show("Kitchen name cannot be empty", ToastType.error);
      return;
    }

    context.read<KitchenBloc>().add(
      CreateKitchenEvent(kitchenName, unitSystem: _unitSystem),
    );
  }
}
