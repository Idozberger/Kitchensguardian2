import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/dashboard/domain/entities/member.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/notification_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/member_tile.dart';

class MembersList extends StatelessWidget {
  final List<Member> members;
  const MembersList({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserCubit>().state;
    return Column(
      children: [
        Padding(
          padding: gapSymmetric(horizontal: 20, vertical: 14),
          child: UpperTile(
            widget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "All Kitchen members",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                gap(height: 10),
                ListView.separated(
                  padding: gapZero,
                  shrinkWrap: true,

                  itemCount: members.length,
                  separatorBuilder: (_, _) =>
                      Divider(color: Colors.grey.shade300),
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return MemberTile(member: member, userState: userState);
                  },
                ),
              ],
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 400, minHeight: 0),
          child: NotificationPage(showAppbar: false),
        ),
      ],
    );
  }
}
