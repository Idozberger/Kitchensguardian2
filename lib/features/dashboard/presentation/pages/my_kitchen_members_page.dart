import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';

import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';

class MyKitchenMembersPage extends StatelessWidget {
  MyKitchenMembersPage({super.key});
  final List<Map<String, dynamic>> members = [
    {
      "name": "Emily David",
      "type": "(host)",
      "email": "emily.david@example.com",
    },
    {
      "name": "Alisha Dawood",
      "type": "(member)",
      "email": "alisha.dawood@example.com",
    },
    {
      "name": "Lawrence Dube",
      "type": "(member)",
      "email": "lawrence.dube@example.com",
    },
    {
      "name": "Garry Elis",
      "type": "(member)",
      "email": "garry.elis@example.com",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
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
                  gap(height: 20),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: members.length,
                    separatorBuilder: (context, index) =>
                        Divider(thickness: 1, color: Colors.grey.shade300),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return ListTile(
                        leading: Image.asset(AppAssets.avatar),
                        dense: true,
                        contentPadding: gapZero,
                        title: Row(
                          children: [
                            Text(
                              member["name"],
                              style: Theme.of(context).textTheme.headlineLarge!
                                  .copyWith(fontSize: t(16)),
                            ),
                            Text(
                              member["type"],
                              style: Theme.of(context).textTheme.headlineMedium!
                                  .copyWith(fontSize: t(12)),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          member["email"],
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium!.copyWith(fontSize: t(13)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
