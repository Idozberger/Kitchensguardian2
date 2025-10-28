import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:share_plus/share_plus.dart';

class ReferralCodePage extends StatelessWidget {
  const ReferralCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (_, state) {
        return Scaffold(
          backgroundColor: Color(0xffF9F9F9),
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: Padding(
              padding: gapSymmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: h(12),
                children: [
                  Text(
                    "Invite a friend!",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  Text(
                    "Share this referral link to your friends and followers",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: state.invitationCode),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Referral code copied to clipboard",
                            style: Theme.of(context).textTheme.headlineMedium!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      );
                    },
                    child: AppTextField(
                      suffixIcon: Icon(Icons.copy),
                      label: "Referral Code",
                      hintText: "Enter your referral code",
                      enabled: false,
                      controller: TextEditingController(
                        text: state.invitationCode,
                      ),
                    ),
                  ),
                  SizedBox(),
                  Center(
                    child: SizedBox(
                      height: h(40),

                      child: OutlinedButton(
                        onPressed: () {
                          Share.share(
                            "Join Kitchen's Guardian using my referral code: ${state.invitationCode}",
                          );
                        },
                        child: Text(
                          "Share Referral Code",
                          style: Theme.of(context).textTheme.headlineMedium!
                              .copyWith(color: AppColors.primaryColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: w(55),
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
      title: Text(
        "Kitchen Invitation",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
