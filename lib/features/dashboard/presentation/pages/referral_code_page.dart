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
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          appBar: _buildAppBar(context),
          body: SafeArea(
            child: Padding(
              padding: gapSymmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: h(12),
                children: [
                  _buildHeader(context),
                  _buildReferralCodeField(context, state.invitationCode),
                  SizedBox(height: h(8)),
                  _buildShareButton(context, state.invitationCode),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: h(8),
      children: [
        Text(
          "Invite a friend!",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        Text(
          "Share this referral link to your friends and followers",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ],
    );
  }

  Widget _buildReferralCodeField(BuildContext context, String code) {
    return GestureDetector(
      onTap: () => _copyToClipboard(context, code),
      child: AppTextField(
        suffixIcon: const Icon(Icons.copy),
        label: "Referral Code",
        hintText: "Enter your referral code",
        enabled: false,
        controller: TextEditingController(text: code),
      ),
    );
  }

  Widget _buildShareButton(BuildContext context, String code) {
    return Center(
      child: SizedBox(
        height: h(40),
        child: OutlinedButton(
          onPressed: () => _handleShare(code),
          child: Text(
            "Share Referral Code",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: AppColors.primaryColor),
          ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Referral code copied to clipboard",
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _handleShare(String code) async {
    await Share.share("Join Kitchen's Guardian using my referral code: $code");
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
