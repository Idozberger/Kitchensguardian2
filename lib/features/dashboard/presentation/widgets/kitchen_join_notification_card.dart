import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';

part 'kitchen_join_notification_card_part.dart';

class KitchenJoinNotificationCard extends StatelessWidget {
  const KitchenJoinNotificationCard({
    super.key,
    required this.id,
    required this.kitchenId,
    required this.title,
    required this.senderName,
    required this.senderUserId,
    required this.body,
    required this.date,
    required this.joiningStatus,
    required this.isActioned,
    required this.isApproveLoading,
    required this.isDeclineLoading,
    required this.onTap,
    required this.onApprove,
    required this.onDecline,
    required this.isLocked,
  });

  final dynamic id;
  final String kitchenId;
  final String title;
  final String senderName;
  final String senderUserId;
  final String body;
  final String date;
  final String joiningStatus;
  final bool isActioned;
  final bool isApproveLoading;
  final bool isDeclineLoading;
  final VoidCallback onTap;
  final VoidCallback onApprove;
  final VoidCallback onDecline;
  final bool isLocked;

  @override
  Widget build(BuildContext context) => kitchenJoinCardRoot(context);
}
