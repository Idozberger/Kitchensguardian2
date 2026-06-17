import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/dialogs/join_kitchen.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/di/service_locator.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_bloc.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_event.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/kitchens/domain/entities/kitchen.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_event.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_state.dart';
import 'package:foodkitchen/features/kitchens/presentation/dialogs/create_kitchen.dart';
import 'package:foodkitchen/features/kitchens/presentation/pages/kitchen_joining_status.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/kitchen_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'kitchen_page_part.dart';

class KitchenPage extends StatefulWidget {
  const KitchenPage({super.key});

  @override
  State<KitchenPage> createState() => _KitchenPageState();
}

class _KitchenPageState extends State<KitchenPage> {
  late final KitchenBloc _kitchenBloc;
  late final UserCubit _userCubit;

  @override
  void initState() {
    super.initState();
    _kitchenBloc = context.read<KitchenBloc>();
    _userCubit = context.read<UserCubit>();
    _loadAllKitchens();
  }

  void _loadAllKitchens() {
    _kitchenBloc.add(FetchKitchens());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: buildKitchenPageAppBar(),
      body: BlocConsumer<KitchenBloc, KitchenState>(
        listener: _handleStateChanges,
        builder: buildKitchenPageBody,
      ),
    );
  }

  void _handleStateChanges(BuildContext context, KitchenState state) {
    if (state is OpenKitchen || state is KitchenSuccess) {
      _loadAllKitchens();
      if (state is KitchenSuccess) {
        AppToast.show(state.successMessage, ToastType.success);
      }
    }
    if (state is KitchenFailure) {
      AppToast.show(state.errorMessage, ToastType.error);
      _loadAllKitchens();
    }
  }
}

class EmptyUsersView extends StatelessWidget {
  final VoidCallback onRetry;

  const EmptyUsersView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapSymmetric(horizontal: 20, vertical: 14),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Something went wrong",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            TextButton(
              onPressed: onRetry,
              child: Text(
                "Try Again",
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(color: Colors.blueGrey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
