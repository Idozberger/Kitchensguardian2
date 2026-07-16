import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/dashboard/domain/entities/member.dart';
import 'package:foodkitchen/features/dashboard/presentation/pages/notification_page.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/member_tile.dart';

/// Sliver version of the kitchen members card - see the analogous
/// `SavedRecipesSection`/`GeneratedRecipesSection` for why a
/// `DecoratedSliver` + `SliverList` replaces the old boxed card with a
/// shrinkWrap `ListView.separated`, so it stays lazy inside the page's
/// `CustomScrollView`.
class MembersList extends StatelessWidget {
  final List<Member> members;
  const MembersList({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserCubit>().state;
    return SliverMainAxisGroup(
      slivers: [
        SliverPadding(
          padding: gapSymmetric(horizontal: 20, vertical: 14),
          sliver: DecoratedSliver(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(h(14)),
              border: Border.all(color: const Color(0xffD4D2D2)),
              color: Colors.white,
            ),
            sliver: SliverPadding(
              padding: gapAll(15),
              sliver: SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "All Kitchen members",
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        gap(height: 10),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index.isOdd) {
                          return Divider(color: Colors.grey.shade300);
                        }
                        final member = members[index ~/ 2];
                        return MemberTile(member: member, userState: userState);
                      },
                      childCount: members.isEmpty ? 0 : members.length * 2 - 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400, minHeight: 0),
            child: NotificationPage(
              showAppbar: false,
              shouldFetchMembers: false,
            ),
          ),
        ),
      ],
    );
  }
}
