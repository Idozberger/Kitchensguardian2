import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_state.dart';

import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyKitchenMembersPage extends StatefulWidget {
  const MyKitchenMembersPage({super.key});

  @override
  State<MyKitchenMembersPage> createState() => _MyKitchenMembersPageState();
}

class _MyKitchenMembersPageState extends State<MyKitchenMembersPage> {
  late DashboardBloc dashboardBloc;
  late UserCubit userCubit;
  int? selectedMemberIndex;

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
    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardFailure) {
          getAllKitchenMembers();
          AppToast.show(state.message, ToastType.error);
        }
        if (state is DashboardSuccess) {
          getAllKitchenMembers();
          AppToast.show(state.successMessage, ToastType.error);
        }
      },
      builder: (context, state) {
        if (state is DashboardLoading) {
          return Scaffold(
            backgroundColor: const Color(0xffF9F9F9),
            appBar: _buildAppBar(context),
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            ),
          );
        } else if (state is DashboardLoaded) {
          return Scaffold(
            backgroundColor: const Color(0xffF9F9F9),
            appBar: _buildAppBar(context),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: gapSymmetric(horizontal: 20, vertical: 20),
                  child: UpperTile(
                    widget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "All kitchen members",
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        gap(height: 10),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.kitchenMembers.length,
                          separatorBuilder: (context, index) => Divider(
                            thickness: 1,
                            color: Colors.grey.shade300,
                          ),
                          itemBuilder: (context, index) {
                            final member = state.kitchenMembers[index];
                            final isSelected = selectedMemberIndex == index;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selectedMemberIndex == index) {
                                    selectedMemberIndex = null;
                                  } else {
                                    selectedMemberIndex = index;
                                  }
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryColor.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  leading: Image.asset(AppAssets.avatar),
                                  dense: true,
                                  contentPadding: gapZero,
                                  title: Row(
                                    children: [
                                      Text(
                                        member.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineLarge!
                                            .copyWith(fontSize: t(16)),
                                      ),
                                      Text(
                                        " (${member.type})",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium!
                                            .copyWith(fontSize: t(12)),
                                      ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    member.userId,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineMedium!
                                        .copyWith(fontSize: t(13)),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        if (userCubit.state.role != "member") gap(height: 20),
                        if (userCubit.state.role != "member")
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: SizedBox(
                                  width: double.infinity,
                                  height: h(40),
                                  child: OutlinedButton(
                                    onPressed: selectedMemberIndex == null
                                        ? () {
                                            AppToast.show(
                                              "Select Member First",
                                              ToastType.info,
                                            );
                                          }
                                        : () {
                                            final member = state
                                                .kitchenMembers[selectedMemberIndex!];
                                            dashboardBloc.add(
                                              KickMemberEvent(
                                                activeKitchenId: userCubit
                                                    .state
                                                    .activeKitchenId,
                                                memberId: member.userId,
                                              ),
                                            );
                                          },
                                    child: Text(
                                      "Kick",
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium!
                                          .copyWith(
                                            fontSize: t(13),
                                            color: selectedMemberIndex == null
                                                ? Colors.grey
                                                : AppColors.primaryColor,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: w(10)),
                              Flexible(
                                child: GenericButtonWidget(
                                  onPressed: selectedMemberIndex == null
                                      ? () {
                                          AppToast.show(
                                            "Select Member First",
                                            ToastType.info,
                                          );
                                        }
                                      : () {
                                          final member = state
                                              .kitchenMembers[selectedMemberIndex!];
                                          dashboardBloc.add(
                                            MakeCohostEvent(
                                              activeKitchenId: userCubit
                                                  .state
                                                  .activeKitchenId,
                                              memberId: member.userId,
                                            ),
                                          );
                                        },
                                  text: "Make Co-Host",
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: const Color(0xffF9F9F9),
            appBar: _buildAppBar(context),
            body: const Center(child: Text("Please select the kitchen!")),
          );
        }
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: w(55),
      centerTitle: true,
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
    );
  }
}
