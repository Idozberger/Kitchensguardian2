import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/kitchen_snippet.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/bloc/smart_kitchen_setup_bloc.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/bloc/smart_kitchen_setup_event.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/bloc/smart_kitchen_setup_state.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/widgets/confirm_button.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/widgets/header_section.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/widgets/section_card.dart';
import 'package:go_router/go_router.dart';

class SmartKitchenSetupPage extends StatefulWidget {
  final bool isRescanning;
  const SmartKitchenSetupPage({super.key, required this.isRescanning});

  @override
  State<SmartKitchenSetupPage> createState() => _SmartKitchenSetupPageState();
}

class _SmartKitchenSetupPageState extends State<SmartKitchenSetupPage> {
  late UserCubit _userCubit;
  late SmartKitchenSetupBloc bloc;
  @override
  void initState() {
    super.initState();
    _userCubit = context.read<UserCubit>();
    bloc = context.read<SmartKitchenSetupBloc>();
    context.read<SmartKitchenSetupBloc>().add(SmartKitchenSetupStarted());
  }

  void _onScan(SmartKitchenSetupState state, int i) {
    bloc.add(SmartKitchenSetupScanRequested(state.sections[i]));
  }

  void _onClear(SmartKitchenSetupState state, int i) {
    bloc.add(SmartKitchenSetupSectionCleared(state.sections[i]));
  }

  void _onConfirm(SmartKitchenSetupState state) {
    if (state.completedCount < 1) {
      AppToast.show(
        'At least 1 photo is required',
        ToastType.error,
        gravity: ToastGravity.TOP,
      );
      return;
    }
    bloc.add(
      SmartKitchenSetupConfirmed(
        context.read<UserCubit>().state.activeKitchenId,
      ),
    );
    context.push(Routes.kitchenAnalysisPage);
  }

  Widget _buildSectionList(SmartKitchenSetupState state) {
    return Column(
      children: List.generate(state.sections.length, (i) {
        final section = state.sections[i];

        return Padding(
          padding: gapOnly(bottom: 0),
          child: SectionCard(
            section: section,
            isScanning: state.isScanning && state.activeSectionId == section.id,
            onScan: () => _onScan(state, i),
            onClear: () => _onClear(state, i),
          ),
        );
      }),
    );
  }

  Widget _buildScaffold(BuildContext context, SmartKitchenSetupState state) {
    return PopScope(
      canPop: widget.isRescanning,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        AppToast.show(
          'Please complete the setup before leaving',
          ToastType.warning,
        );
      },

      child: Scaffold(
        appBar: AppBar(
          leadingWidth: w(55),
          centerTitle: true,
          leading: widget.isRescanning
              ? Row(
                  children: [
                    SizedBox(width: w(16)),
                    CircularIconButton(
                      iconAsset: AppAssets.backArrowiOS,
                      onTap: () => context.pop(),
                    ),
                  ],
                )
              : null,
          title: Text(
            "Kitchen Setup",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: gapSymmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                gapVertical(4),
                const HeaderSection(),
                gapVertical(16),
                _buildSectionList(state),
                gapVertical(100),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottom(state, context),
      ),
    );
  }

  SafeArea _buildBottom(SmartKitchenSetupState state, BuildContext context) {
    return SafeArea(
      child: ColoredBox(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            gapVertical(12),
            ConfirmButton(
              canConfirm: state.canConfirm,
              onConfirm: state.isSkipping
                  ? () {}
                  : state.completedCount > 0
                  ? () => _onConfirm(state)
                  : () {
                      AppToast.show(
                        'Please scan at least one section to continue',
                        ToastType.warning,
                        gravity: ToastGravity.TOP,
                      );
                    },
            ),
            if (_userCubit.state.userStorageAreas.isEmpty) ...[
              MaterialButton(
                onPressed: () => bloc.add(
                  SkipKitchenSetupEvent(
                    kitchenId: _userCubit.state.activeKitchenId,
                  ),
                ),
                child: state.isSkipping
                    ? Transform.scale(
                        scale: 0.7,
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      )
                    : Text(
                        "Skip",
                        style: Theme.of(
                          context,
                        ).textTheme.headlineMedium?.copyWith(),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "You can always do this later in the app",
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.greyColor),
                ),
              ),
            ],
            gapH(8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SmartKitchenSetupBloc, SmartKitchenSetupState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          AppToast.show(
            state.errorMessage!,
            ToastType.error,
            gravity: ToastGravity.TOP,
          );
        }

        if (state.skipSuccessMessage != null) {
          context.go(Routes.dashboard);
        }
      },
      builder: _buildScaffold,
    );
  }
}
