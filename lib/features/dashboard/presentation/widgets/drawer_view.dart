import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/delete_account_dialog.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/widgets/safe_image.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/logging/app_logger.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_otp_widget.dart';
//import 'package:foodkitchen/core/widgets/generic_premium_card_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/drawer_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

part 'drawer_view_part.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (_, userState) {
        return Drawer(
          width: w(307),
          child: SafeArea(
            child: Padding(
              padding: gapSymmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _appDrawerProfileSection(context),
                  /*gap(height: 20),
                  const PremiumCardWidget(),*/
                  gap(height: 20),
                  _appDrawerItems(context),
                  gap(height: 10),
                  _appDrawerLogoutButton(context),
                  gap(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
