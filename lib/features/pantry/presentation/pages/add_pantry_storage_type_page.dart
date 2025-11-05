import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_storage_type_entity.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';

class AddPantryStorageTypePage extends StatefulWidget {
  const AddPantryStorageTypePage({super.key});

  @override
  State<AddPantryStorageTypePage> createState() =>
      _AddPantryStorageTypePageState();
}

class _AddPantryStorageTypePageState extends State<AddPantryStorageTypePage> {
  late PantryBloc pantryBloc;
  late UserCubit userCubit;
  final TextEditingController _nameController = TextEditingController();
  List<String> _storageTypes = [];

  @override
  void initState() {
    super.initState();
    pantryBloc = context.read<PantryBloc>();
    userCubit = context.read<UserCubit>();
  }

  void _addNewType() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      AppToast.show("Please enter a storage type name.", ToastType.error);
      return;
    } else if (name.length < 3) {
      AppToast.show(
        "Name must be at least 3 characters long.",
        ToastType.error,
      );
      return;
    }

    setState(() {
      _storageTypes.add(name);
      _nameController.clear();
    });

    AppToast.show(
      "Storage type added to list.",
      ToastType.success,
      gravity: ToastGravity.TOP,
    );
  }

  void resetState() {
    setState(() {
      _storageTypes = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlannerBloc, PlannerState>(
      listener: (_, state) {},
      builder: (_, state) {
        return Scaffold(
          backgroundColor: const Color(0xffF9F9F9),
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: Padding(
              padding: gapSymmetric(horizontal: 20, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UpperTile(
                    verticalPadding: 0,
                    widget: Column(
                      children: [
                        gap(height: 20),
                        AppTextField(
                          onFieldSubmitted: (p0) => _addNewType(),
                          controller: _nameController,
                          label: 'Storage Type Name',
                          hintText: 'Enter storage type name',
                        ),
                        gap(height: 14),
                        _addMoreButton(context),
                        gap(height: 20),
                      ],
                    ),
                  ),
                  if (_storageTypes.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        physics: ScrollPhysics(),
                        padding: gapOnly(top: 14),
                        itemCount: _storageTypes.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final name = _storageTypes[index];
                          return Padding(
                            padding: gapOnly(bottom: 10),
                            child: UpperTile(
                              widget: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    name,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineMedium,
                                  ),
                                  CircularIconButton(
                                    onTap: () {
                                      setState(() {
                                        _storageTypes.removeAt(index);
                                      });
                                    },
                                    iconAsset: AppAssets.deleteSvg,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: ColoredBox(
            color: Colors.white,
            child: SafeArea(
              child: Padding(
                padding: gapOnly(left: 20, right: 20, bottom: 0, top: 14),
                child: GenericButtonWidget(
                  isLoading: state is PantryLoading,
                  text: "Add Storage Types",
                  onPressed: state is PantryLoading
                      ? () {}
                      : () {
                          if (_storageTypes.isEmpty) {
                            AppToast.show(
                              "Please add at least one storage type.",
                              ToastType.error,
                            );
                            return;
                          }

                          final pantryModel = PantryStorageTypeEntity(
                            kitchenId: userCubit.state.activeKitchenId,
                            storageTypes: _storageTypes,
                          );
                          AppToast.show(
                            "Submitted ${pantryModel.storageTypes}",
                            ToastType.success,
                            gravity: ToastGravity.TOP,
                          );
                          resetState();
                        },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leadingWidth: w(55),
      centerTitle: true,
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
      title: Text(
        "Add Storage Type",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  Center _addMoreButton(BuildContext context) {
    return Center(
      child: SizedBox(
        width: w(188),
        height: h(40),
        child: OutlinedButton.icon(
          onPressed: _addNewType,
          icon: SvgPicture.asset(
            AppAssets.addSvg,
            color: AppColors.primaryColor,
            width: w(18),
            height: h(18),
          ),
          label: Text(
            "Tap to add more",
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontSize: t(15),
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
