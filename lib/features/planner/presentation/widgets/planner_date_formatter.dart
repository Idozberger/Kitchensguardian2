import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:intl/intl.dart';

class PlannerDateFormatter {
  static String toDisplayFormat(String backendDate) {
    final date = DateTime.parse(backendDate);
    return DateFormat('EEEE dd, yyyy').format(date);
  }

  static String toBackendFormat(DateTime date) {
    return formatDateToMeetBackendDate(date);
  }

  static DateTime parseBackendDate(String backendDate) {
    return formatStringDateToMeetBackendDate(backendDate);
  }

  static DateTime getInitialDate(PlannerState state) {
    if (state.startDate?.isNotEmpty ?? false) {
      try {
        return parseBackendDate(state.startDate!);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  static DateTime getStartDate(PlannerState state) {
    final dateStr = (state.startDate?.isEmpty ?? true)
        ? toBackendFormat(DateTime.now())
        : state.startDate!;
    return parseBackendDate(dateStr);
  }
}
