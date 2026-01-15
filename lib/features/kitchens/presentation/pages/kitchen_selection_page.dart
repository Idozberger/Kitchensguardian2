// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/notifications/flutter_local_notifications_service.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_event.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_state.dart';
import 'package:foodkitchen/features/kitchens/presentation/pages/kitchen_page.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/create_kitchen.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/joined_kitchen_selection.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/kitchen_selection.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/kitchen_selection_appbar.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class KitchenSelectionPage extends StatefulWidget {
  const KitchenSelectionPage({super.key});

  @override
  State<KitchenSelectionPage> createState() => _KitchenSelectionPageState();
}

class _KitchenSelectionPageState extends State<KitchenSelectionPage> {
  late KitchenBloc kitchenBloc;
  late UserCubit userCubit;

  @override
  void initState() {
    kitchenBloc = context.read<KitchenBloc>();
    userCubit = context.read<UserCubit>();
    kitchenBloc.add(FetchKitchens());
    getNotificationPermission();
    super.initState();
  }

  Future<void> getNotificationPermission() async {
    await Future.delayed(Duration(seconds: 1));
    bool hasPermission = await NotificationService().isExactAlarmAllowed();
    if (!hasPermission && Platform.isAndroid) {
      showCustomGenericDialog(
        context: context,
        title: "Permission Required",
        subtitle:
            "This permission is required to schedule notifications for low-stock items, expiring items, and your plans accurately.",
        primaryButtonText: "Allow",
        secondaryButtonText: "Cancel",
        onPrimaryPressed: () async {
          await requestExactAlarmPermission();
          context.pop();
        },
        onSecondaryPressed: () {
          context.pop();
        },
      );
    }
  }

  Future<void> requestExactAlarmPermission() async {
    await NotificationService().requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: KitchenSelectionAppBar(),
      body: BlocConsumer<KitchenBloc, KitchenState>(
        listener: (_, state) {
          if (state is KitchenSuccess) {
            kitchenBloc.add(FetchKitchens());
          }
          if (state is OpenKitchen) {
            kitchenBloc.add(FetchKitchens());
            context.go(Routes.dashboard);
          } else if (state is KitchenFailure) {
            AppToast.show(state.errorMessage, ToastType.error);
            kitchenBloc.add(FetchKitchens());
          }
        },
        builder: (_, state) {
          if (state is KitchensLoading) {
            return Center(child: Lottie.asset(AppAssets.loader));
          }

          if (state is KitchensLoaded) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: gapSymmetric(horizontal: 20, vertical: 10),
                child: Column(
                  spacing: h(10),
                  children: [
                    JoinedKitchensSection(
                      kitchens: state.kitchens,
                      userCubit: userCubit,
                      kitchenBloc: kitchenBloc,
                    ),

                    CreateKitchenSection(),

                    YourKitchensSection(
                      kitchens: state.kitchens,
                      userCubit: userCubit,
                      kitchenBloc: kitchenBloc,
                    ),
                  ],
                ),
              ),
            );
          }

          return EmptyUsersView(
            onRetry: () {
              kitchenBloc.add(FetchKitchens());
            },
          );
        },
      ),
    );
  }
}
