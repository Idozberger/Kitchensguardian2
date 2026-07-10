import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/usecase/get_current_user.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/network/profile_response_cache.dart';
import 'package:foodkitchen/core/services/di/service_locator.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/profile/domain/usecases/delete_account.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _deleteAccountWarningMessage =
    'Deleting your account is a permanent action. Once deleted:\n\n'
    '• All your personal data, preferences, and activity history will be permanently erased\n\n'
    'This action cannot be undone.\n'
    "If you're experiencing issues or have concerns, please contact our support team—we're here to help.\n\n"
    'Do you still want to proceed with deleting your account?';

Future<void> showDeleteAccountDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return _DeleteAccountDialog(
        onDelete: () {
          dialogContext.pop();
          unawaited(_performDeleteAccount(context));
        },
      );
    },
  );
}

Future<void> _performDeleteAccount(BuildContext context) async {
  if (!context.mounted) return;

  final rootNavigator = Navigator.of(context, rootNavigator: true);

  unawaited(
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        ),
      ),
    ),
  );

  await WidgetsBinding.instance.endOfFrame;

  final result = await sl<DeleteAccount>()(NoParams());

  if (rootNavigator.mounted && rootNavigator.canPop()) {
    rootNavigator.pop();
  }

  if (!context.mounted) return;

  await result.fold(
    (failure) async {
      AppToast.show(failure.userMessage, ToastType.error);
    },
    (message) async {
      sl<ProfileResponseCache>().invalidate();
      context.read<UserCubit>().clearUser();
      await sl<SharedPreferences>().clear();

      if (!context.mounted) return;
      context.go(Routes.signIn);
      AppToast.show(message, ToastType.success);
    },
  );
}

class _DeleteAccountDialog extends StatelessWidget {
  const _DeleteAccountDialog({required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GenericDialog(
      borderRadius: h(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Delete Account',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: t(14),
            ),
          ),
          gap(height: h(10)),
          Text(
            _deleteAccountWarningMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: t(12),
              color: const Color(0xff7B7B7B),
            ),
          ),
          gap(height: h(10)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: SizedBox(
                  height: h(40),
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Cancel',
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(
                            fontSize: t(12),
                            color: AppColors.primaryColor,
                          ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: w(10)),
              Flexible(
                child: GenericButtonWidget(onPressed: onDelete, text: 'Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
