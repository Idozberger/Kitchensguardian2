import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';

typedef PantrySubmitLoadingPredicate = bool Function(PantryState state);

class AddItemPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AddItemPageAppBar({
    super.key,
    required this.isMember,
    required this.onBack,
    this.titleOverride,
  });

  final bool isMember;
  final VoidCallback onBack;
  final String? titleOverride;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final title = titleOverride ?? (isMember ? "Request Item" : "Add Item");
    return AppBar(
      leadingWidth: w(55),
      centerTitle: true,
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(iconAsset: AppAssets.backArrowiOS, onTap: onBack),
        ],
      ),
      title: Text(title, style: Theme.of(context).textTheme.headlineLarge),
    );
  }
}

/// Submit footer with pantry loading state; reusable from add-item and kitchen analysis flows.
class PantryItemSubmitFooter extends StatelessWidget {
  const PantryItemSubmitFooter({
    super.key,
    required this.showAddMore,
    required this.submitLabel,
    required this.onAddMore,
    required this.onSubmit,
    this.isSubmitting,
  });

  final bool showAddMore;
  final String submitLabel;
  final VoidCallback onAddMore;
  final VoidCallback onSubmit;
  final PantrySubmitLoadingPredicate? isSubmitting;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PantryBloc, PantryState>(
      builder: (context, state) {
        final loading = isSubmitting != null
            ? isSubmitting!(state)
            : state is SubmittingItemLoading;
        return SafeArea(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
            padding: gapOnly(left: 20, right: 20, bottom: 14, top: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showAddMore) _AddMoreButton(onPressed: onAddMore),
                SizedBox(height: h(22)),
                GenericButtonWidget(
                  isLoading: loading,
                  text: submitLabel,
                  onPressed: loading ? () {} : onSubmit,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AddItemPageBottomBar extends StatelessWidget {
  const AddItemPageBottomBar({
    super.key,
    required this.showAddMore,
    required this.isMember,
    required this.onAddMore,
    required this.onSubmit,
  });

  final bool showAddMore;
  final bool isMember;
  final VoidCallback onAddMore;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return PantryItemSubmitFooter(
      showAddMore: showAddMore,
      submitLabel: isMember ? "Request Item" : "Add Item",
      onAddMore: onAddMore,
      onSubmit: onSubmit,
    );
  }
}

class _AddMoreButton extends StatelessWidget {
  const _AddMoreButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: w(188),
        height: h(40),
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: SvgPicture.asset(
            AppAssets.addSvg,
            colorFilter: ColorFilter.mode(
              AppColors.primaryColor,
              BlendMode.srcIn,
            ),
            width: w(18),
            height: h(18),
          ),
          label: Text(
            "Tap to add more",
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontSize: t(15),
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
