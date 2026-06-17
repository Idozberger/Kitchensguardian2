import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:intl/intl.dart';

String formatDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);

///**OUTPUT FORMAT: 3/4/2002 */

DateTime parseDate(String formattedDateString) {
  return DateFormat("dd/MM/yyyy").parse(formattedDateString);
}

String formatDateToMeetBackendDate(DateTime date) {
  final formatted = DateFormat('yyyy-MM-dd').format(date);
  devLog("calling [formatDateToMeetBackendDate]: $date → $formatted");
  return formatted;
}

DateTime formatStringDateToMeetBackendDate(String formattedDateString) {
  devLog("Formatting date: $formattedDateString");
  return DateFormat('yyyy-MM-d').parse(formattedDateString);
}
