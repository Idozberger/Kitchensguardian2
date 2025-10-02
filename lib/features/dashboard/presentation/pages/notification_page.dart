import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: gapSymmetric(horizontal: 20, vertical: 20),

          child: ListView.separated(
            itemCount: 7,
            shrinkWrap: true,

            separatorBuilder: (context, index) {
              return Divider(color: Color(0xffF4F4F4));
            },
            padding: gapZero,
            itemBuilder: (context, index) {
              return Padding(
                padding: gapSymmetric(vertical: 15),
                child: RequiredText(
                  text:
                      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ${index + 1}",
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leadingWidth: w(55),
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),

      title: Text(
        "Notifications",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}

class RequiredText extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;

  const RequiredText({super.key, required this.text, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: gapOnly(top: 4),
          child: Container(
            width: 8,
            height: 8,
            margin: EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: w(7)),
        Flexible(
          child: Text(
            text,

            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: t(15),
              fontWeight: FontWeight.w400,
              color: Color(0xff787878),
            ),
          ),
        ),
      ],
    );
  }
}
