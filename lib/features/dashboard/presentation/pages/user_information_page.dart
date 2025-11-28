import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:lottie/lottie.dart';

class UserPage extends StatefulWidget {
  final String senderUserId;
  final String kitchenId;

  const UserPage({
    super.key,
    required this.senderUserId,
    required this.kitchenId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  bool _isLoading = true;
  String userName = '';
  String userEmail = '';
  String kitchenName = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.senderUserId)
          .get();
      final userData = userDoc.data();
      if (userData != null) {
        setState(() {
          userName = '${userData['first_name']} ${userData['last_name']}';
          userEmail = userData['email'];
        });
      }

      final kitchenDoc = await FirebaseFirestore.instance
          .collection('kitchens')
          .doc(widget.kitchenId)
          .get();
      final kitchenData = kitchenDoc.data();
      if (kitchenData != null) {
        setState(() {
          kitchenName = kitchenData['kitchen_name'];
          _isLoading = false;
        });
      }
    } catch (e) {
      log("Error fetching data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: Padding(
        padding: gapSymmetric(horizontal: 20, vertical: 20),
        child: _isLoading
            ? Center(child: Lottie.asset(AppAssets.loader))
            : Column(
                spacing: h(16),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildUserInfo(), _buildKitchenInfo()],
              ),
      ),
    );
  }

  Widget _buildUserInfo() {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "User Information",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Name:", style: Theme.of(context).textTheme.headlineLarge),
              Text(userName, style: Theme.of(context).textTheme.headlineMedium),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Email:"),
              Text(
                userEmail,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKitchenInfo() {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kitchen Information",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Kitchen Name:",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Text(
                kitchenName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ],
      ),
    );
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
        "User Information",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
