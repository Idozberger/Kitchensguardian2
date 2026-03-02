import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'pending': const Color(0xFFFEF3C7),
      'approved': const Color(0xFFDCFCE7),
      'rejected': const Color(0xFFFEE2E2),
    };
    final textColors = {
      'pending': const Color(0xFFD97706),
      'approved': const Color(0xFF16A34A),
      'rejected': const Color(0xFFDC2626),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: w(8), vertical: h(3)),
      decoration: BoxDecoration(
        color: colors[status] ?? const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: t(10),
          color: textColors[status] ?? Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
