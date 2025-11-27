import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/empty_members_view.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/members_list.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyKitchenMembersPage extends StatefulWidget {
  const MyKitchenMembersPage({super.key});

  @override
  State<MyKitchenMembersPage> createState() => _MyKitchenMembersPageState();
}

class _MyKitchenMembersPageState extends State<MyKitchenMembersPage> {
  late DashboardBloc dashboardBloc;
  late UserCubit userCubit;

  @override
  void initState() {
    dashboardBloc = context.read<DashboardBloc>();
    userCubit = context.read<UserCubit>();
    getAllKitchenMembers();
    super.initState();
  }

  void getAllKitchenMembers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? activeKitchenId = prefs.getString('kitchen_id');

    dashboardBloc.add(
      GetKitchenMembersEvent(activeKitchenId: activeKitchenId ?? ""),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardFailure) {
            AppToast.show(state.message, ToastType.error);
          } else if (state is DashboardSuccess) {
            AppToast.show(state.successMessage, ToastType.success);
          }
        },
        builder: (context, state) {
          if (state is DashboardLoading) {
            return Center(child: Lottie.asset(AppAssets.loader));
          } else if (state is DashboardLoaded) {
            return SingleChildScrollView(
              child: MembersList(members: state.kitchenMembers),
            );
          } else {
            return const EmptyMembersView();
          }
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
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
      "Kitchen Members",
      style: Theme.of(context).textTheme.headlineLarge,
    ),
    centerTitle: true,
  );
}
