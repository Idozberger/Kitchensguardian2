import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_state.dart';
import 'package:foodkitchen/features/grocery/presentation/pages/grocery_parts/grocery_body.dart';

class GroceryPage extends StatefulWidget {
  const GroceryPage({super.key});

  @override
  State<GroceryPage> createState() => _GroceryPageState();
}

class _GroceryPageState extends State<GroceryPage> {
  late final UserCubit userCubit;
  late final GroceryBloc groceryBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userCubit = context.read<UserCubit>();
    groceryBloc = context.read<GroceryBloc>();
    _searchController.addListener(() => setState(() {}));
    _fetchInitialData();
  }

  void _fetchInitialData() {
    final kitchenId = userCubit.state.activeKitchenId;
    if (kitchenId.isEmpty) return;
    groceryBloc
      ..add(RequestedGroceryEvent(kitchenId: kitchenId))
      ..add(GetAiGeneratedItemsEvent(kitchenId: kitchenId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroceryBloc, GroceryState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          AppToast.show(state.errorMessage!, ToastType.error);
        } else if (state.successMessage != null) {
          AppToast.show(state.successMessage!, ToastType.success);
        }
      },
      child: BlocBuilder<GroceryBloc, GroceryState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: const Color(0xffF9F9F9),
            body: GroceryBody(
              state: state,
              userCubit: userCubit,
              groceryBloc: groceryBloc,
              controller: _searchController,
            ),
            floatingActionButton: FloatingActionButton(
              key: UniqueKey(),
              tooltip: "Add Custom Items",
              backgroundColor: AppColors.primaryColor,
              shape: const CircleBorder(),
              onPressed: () => AppToast.show(
                "This feature is under progress.",
                ToastType.info,
              ),
              child: const Icon(Icons.add, color: Colors.black),
            ),
          );
        },
      ),
    );
  }
}
