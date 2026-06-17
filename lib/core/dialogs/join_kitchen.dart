import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_otp_widget.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_event.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_state.dart';

/// Shared UI for entering an invitation code (used from Home and Kitchen flows).
class JoinKitchenInviteForm extends StatefulWidget {
  const JoinKitchenInviteForm({
    super.key,
    required this.isLoading,
    required this.onSubmitWithCode,
    this.logOtpDigits = false,
  });

  final bool isLoading;
  final void Function(String code) onSubmitWithCode;
  final bool logOtpDigits;

  @override
  State<JoinKitchenInviteForm> createState() => _JoinKitchenInviteFormState();
}

class _JoinKitchenInviteFormState extends State<JoinKitchenInviteForm> {
  String? _code;

  void _submit() {
    final code = _code;
    if (code == null || code.isEmpty) {
      AppToast.show('Code is required', ToastType.error);
      return;
    }
    widget.onSubmitWithCode(code);
  }

  @override
  Widget build(BuildContext context) {
    return GenericDialog(
      borderRadius: h(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reffer Code',
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: t(20),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context, true),
                icon: SvgPicture.asset(AppAssets.cancelSvg),
              ),
            ],
          ),
          SizedBox(height: h(10)),
          OtpField(
            onChanged: (pin) {
              _code = pin;
              if (widget.logOtpDigits) {
                devPrint('Entered OTP: $pin');
              }
            },
            isJoining: true,
            preFilledStar: true,
            onCompleted: (invitationCodeInput) {
              setState(() => _code = invitationCodeInput);
            },
          ),
          SizedBox(height: h(10)),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: w(147),
              height: h(40),
              child: GenericButtonWidget(
                isLoading: widget.isLoading,
                onPressed: _submit,
                text: 'Join',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Join from home (e.g. create/join tile) — uses [HomeBloc] + [SubmitKitchenJoinRequest] path.
Future<dynamic> showJoinKitchenDialogForHome(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return BlocConsumer<HomeBloc, HomeState>(
        listener: (_, state) {
          if (state.successMessage != null) {
            Navigator.pop(dialogContext, true);
          }
        },
        builder: (ctx, homeState) {
          return JoinKitchenInviteForm(
            isLoading: homeState.isLoading,
            logOtpDigits: false,
            onSubmitWithCode: (code) {
              ctx.read<HomeBloc>().add(JoinKitchenEventForHome(code));
            },
          );
        },
      );
    },
  );
}

/// Join from kitchens feature — uses [KitchenBloc] HTTP join.
Future<dynamic> showJoinKitchenDialogForKitchen(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return BlocConsumer<KitchenBloc, KitchenState>(
        listener: (_, state) {
          if (state is KitchenFailure || state is KitchenSuccess) {
            Navigator.pop(dialogContext, true);
          }
        },
        builder: (ctx, state) {
          return JoinKitchenInviteForm(
            isLoading: state is KitchensLoading,
            logOtpDigits: true,
            onSubmitWithCode: (code) {
              ctx.read<KitchenBloc>().add(JoinKitchenEvent(code));
            },
          );
        },
      );
    },
  );
}
