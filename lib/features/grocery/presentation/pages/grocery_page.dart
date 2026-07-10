import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/unit_system_change_listener.dart';
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
  late final UserCubit _userCubit;
  late final GroceryBloc _groceryBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userCubit = context.read<UserCubit>();
    _groceryBloc = context.read<GroceryBloc>();
    _searchController.addListener(() => setState(() {}));
    _loadInitialData();
  }

  void _loadInitialData() {
    final kitchenId = _userCubit.state.activeKitchenId;
    if (kitchenId.isEmpty) return;

    _groceryBloc
      ..add(RequestedGroceryEvent(kitchenId: kitchenId))
      ..add(GetAiGeneratedItemsEvent(kitchenId: kitchenId));
  }

  @override
  Widget build(BuildContext context) {
    return UnitSystemChangeListener(
      onChanged: _loadInitialData,
      child: BlocListener<GroceryBloc, GroceryState>(
        listener: _handleStateChanges,
        child: BlocBuilder<GroceryBloc, GroceryState>(
          builder: (context, state) => Scaffold(
            backgroundColor: const Color(0xFFF9F9F9),
            body: GroceryBody(
              state: state,
              userCubit: _userCubit,
              groceryBloc: _groceryBloc,
              controller: _searchController,
            ),
          ),
        ),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, GroceryState state) {
    if (state.errorMessage != null) {
      AppToast.show(state.errorMessage!, ToastType.error);
    } else if (state.successMessage != null) {
      AppToast.show(state.successMessage!, ToastType.success);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
