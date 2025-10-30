import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_bloc.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_event.dart';
import 'package:foodkitchen/features/kitchens/presentation/bloc/kitchen_state.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/kitchen_tile.dart';

class InviteMemberPage extends StatefulWidget {
  const InviteMemberPage({super.key});

  @override
  State<InviteMemberPage> createState() => _InviteMemberPageState();
}

class _InviteMemberPageState extends State<InviteMemberPage> {
  late KitchenBloc kitchenBloc;
  late UserCubit userCubit;

  @override
  void initState() {
    super.initState();
    kitchenBloc = context.read<KitchenBloc>();
    userCubit = context.read<UserCubit>();
    _fetchAllUsers();
  }

  void _fetchAllUsers() {
    kitchenBloc.add(FetchAllUsers());
  }

  void _inviteUser({
    required String kitchenId,
    required String email,
    required int index,
  }) {
    kitchenBloc.add(
      InviteUserEvent(kitchenId: kitchenId, email: email, index: index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: BlocConsumer<KitchenBloc, KitchenState>(
        listener: (_, state) {
          if (state is AllUserLoaded) {
            if (state.errorMessage.isNotEmpty) {
              AppToast.show(state.errorMessage, ToastType.error);
            } else if (state.successMessage.isNotEmpty) {
              AppToast.show(state.successMessage, ToastType.success);
            }
          }
        },
        builder: (_, state) {
          if (state is AllUserLoaded) {
            if (state.isLoading) {
              return const LoadingView();
            }

            if (state.users.isEmpty) {
              return EmptyUsersView(
                onRetry: _fetchAllUsers,
                inviteUser: () => _inviteUser(
                  email: "syedzainnaqvi3324@gmail.com",
                  kitchenId: "6903027ad3fe5ee30352b23c",
                  index: 0,
                ),
              );
            }

            return UsersListView(usersState: state);
          }

          return ErrorView(onRetry: _fetchAllUsers);
        },
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
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
      title: Text(
        "All Users",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: AppColors.primaryColor),
    );
  }
}

class EmptyUsersView extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback inviteUser;
  const EmptyUsersView({
    super.key,
    required this.onRetry,
    required this.inviteUser,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapSymmetric(horizontal: 20, vertical: 14),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          UpperTile(
            widget: KitchenTile(
              allUsersView: true,
              isMember: false,
              buttonText: "Invite",
              onSecondaryActionTap: () {},
              onButtonPressed: inviteUser,
              imagePath: AppAssets.avatar,
              title: "Syed Zain",
              email: "syedzainnaqvi3324@gmail.com",
              membersText: "",
            ),
          ),
          // Text(
          //   "No users found!",
          //   style: Theme.of(context).textTheme.headlineMedium,
          // ),

          // TextButton(
          //   onPressed: onRetry,
          //   child: Text(
          //     "Try Again",
          //     style: Theme.of(
          //       context,
          //     ).textTheme.headlineMedium!.copyWith(color: Colors.blueGrey),
          //   ),
          // ),
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Something went wrong!"),
          gapVertical(6),
          TextButton(onPressed: onRetry, child: const Text("Try Again")),
        ],
      ),
    );
  }
}

class UsersListView extends StatelessWidget {
  final AllUserLoaded usersState;
  const UsersListView({super.key, required this.usersState});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: gapSymmetric(horizontal: 20, vertical: 14),
          child: UpperTile(
            verticalPadding: 0,
            horizontalPadding: 12,
            widget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: usersState.users
                  .map(
                    (user) => Padding(
                      padding: gapSymmetric(vertical: 12),
                      child: KitchenTile(
                        allUsersView: true,
                        isMember: false,
                        buttonText: "Invite",
                        onSecondaryActionTap: () {},
                        onButtonPressed: () {},
                        imagePath: AppAssets.avatar,
                        title: "${user.firstName} ${user.lastName}",
                        email: user.email,
                        membersText: "",
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
