import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_otp_widget.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_event.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_state.dart';

Future<dynamic> showJoinKitchenDialog(BuildContext context) {
  String? invitaionCode;

  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return BlocConsumer<KitchenBloc, KitchenState>(
        listener: (context, state) {
          if (state is KitchenFailure || state is KitchenSuccess) {
            Navigator.pop(context, true);
          }
        },
        builder: (_, state) {
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
                      "Reffer Code",
                      style: Theme.of(context).textTheme.headlineLarge!
                          .copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: t(20),
                          ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      icon: SvgPicture.asset(AppAssets.cancelSvg),
                    ),
                  ],
                ),
                SizedBox(height: h(10)),
                OtpField(
                  isJoining: true,
                  preFilledStar: true,
                  onCompleted: (invitationCodeInput) {
                    invitaionCode = invitationCodeInput;
                  },
                ),
                SizedBox(height: h(10)),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: w(147),
                    height: h(40),
                    child: GenericButtonWidget(
                      isLoading: state is KitchensLoading,
                      onPressed: () {
                        if (invitaionCode != null &&
                            invitaionCode!.isNotEmpty) {
                          context.read<KitchenBloc>().add(
                            JoinKitchenEvent(invitaionCode!),
                          );
                        } else {
                          AppToast.show("Code is required", ToastType.error);
                        }
                      },
                      text: "Join",
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
