import 'dart:developer';

import 'package:intl/intl.dart';

String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

///**OUTPUT FORMAT: 3/4/2002 */

DateTime parseDate(String formattedDateString) {
  return DateFormat("dd/MM/yyyy").parse(formattedDateString);
}

String formatDateToMeetBackendDate(DateTime date) {
  final formatted = DateFormat('yyyy-MM-dd').format(date);
  log("calling [formatDateToMeetBackendDate]: $date → $formatted");
  return formatted;
}

DateTime formatStringDateToMeetBackendDate(String formattedDateString) {
  log("Formatting date: $formattedDateString");
  return DateFormat('yyyy-MM-d').parse(formattedDateString);
}
