import 'package:intl/intl.dart';

String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

///**OUTPUT FORMAT: 3/4/2002 */

DateTime parseDate(String formattedDateString) {
  return DateFormat("dd/MM/yyyy").parse(formattedDateString);
}

String formatDateToMeetBackendDate(DateTime date) {
  return DateFormat('yyyy-MM-d').format(date);
}

DateTime formatStringDateToMeetBackendDate(String formattedDateString) {
  return DateFormat('yyyy-MM-d').parse(formattedDateString);
}
