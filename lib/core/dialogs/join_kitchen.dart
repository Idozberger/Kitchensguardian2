import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_otp_widget.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_event.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';

Future<dynamic> showJoinKitchenDialog(BuildContext context) {
  String? invitaionCode;
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            Navigator.pop(context, true);
          }
        },
        builder: (_, homeState) {
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
                  preFilledStar: true,
                  onCompleted: (invitationCode) {
                    invitaionCode = invitationCode;
                  },
                ),
                SizedBox(height: h(10)),
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: w(147),
                    height: h(40),
                    child: GenericButtonWidget(
                      isLoading: homeState.isLoading,
                      onPressed: () {
                        if (invitaionCode != null) {
                          context.read<HomeBloc>().add(
                            JoinKitchenEvent(invitaionCode!),
                          );
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
