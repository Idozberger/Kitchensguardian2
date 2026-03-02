import 'package:flutter/material.dart';

enum ItemRequestFilter { all, pending, approved, rejected }

extension ItemRequestFilterExt on ItemRequestFilter {
  String get label => switch (this) {
    ItemRequestFilter.all => 'All',
    ItemRequestFilter.pending => 'Pending',
    ItemRequestFilter.approved => 'Approved',
    ItemRequestFilter.rejected => 'Rejected',
  };

  String get value => switch (this) {
    ItemRequestFilter.all => 'all',
    ItemRequestFilter.pending => 'pending',
    ItemRequestFilter.approved => 'approved',
    ItemRequestFilter.rejected => 'rejected',
  };

  IconData get icon => switch (this) {
    ItemRequestFilter.all => Icons.inventory_2_outlined,
    ItemRequestFilter.pending => Icons.access_time,
    ItemRequestFilter.approved => Icons.check_circle_outline,
    ItemRequestFilter.rejected => Icons.cancel_outlined,
  };

  String get subtitle => switch (this) {
    ItemRequestFilter.all => 'Show all item requests',
    ItemRequestFilter.pending => 'Requests waiting for review',
    ItemRequestFilter.approved => 'Requests that were approved',
    ItemRequestFilter.rejected => 'Requests that were rejected',
  };
}
