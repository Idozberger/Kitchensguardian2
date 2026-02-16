import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_state.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/features/dashboard/domain/entities/member.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/member_popup_menu.dart';

class MemberTile extends StatelessWidget {
  final Member member;
  final UserState userState;
  const MemberTile({super.key, required this.member, required this.userState});

  @override
  Widget build(BuildContext context) {
    final dashboardBloc = context.read<DashboardBloc>();

    return ListTile(
      dense: true,
      contentPadding: gapZero,
      leading: Image.asset(AppAssets.avatar),
      title: Row(
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: w(114)),
            child: Text(
              member.name,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            " (${member.type})",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
      subtitle: Text(
        member.userId,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing:
          userState.role != "member" &&
              userState.userId != member.userId &&
              member.type != "host"
          ? MemberPopupMenu(
              onDemoteCoHost: () => dashboardBloc.add(
                DemoteCohostEvent(
                  activeKitchenId: userState.activeKitchenId,
                  memberId: member.userId,
                ),
              ),
              onMakeCoHost: () => dashboardBloc.add(
                MakeCohostEvent(
                  activeKitchenId: userState.activeKitchenId,
                  memberId: member.userId,
                ),
              ),
              onKick: () => dashboardBloc.add(
                KickMemberEvent(
                  activeKitchenId: userState.activeKitchenId,
                  memberId: member.userId,
                ),
              ),
            )
          : null,
    );
  }
}
