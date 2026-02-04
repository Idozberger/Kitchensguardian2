String formatExpiry(String yyyymmdd) {
  try {
    if (yyyymmdd.isEmpty) return "";

    final now = DateTime.now();
    final expiryDate = DateTime.parse(yyyymmdd);

    Duration diff = expiryDate.difference(
      DateTime(now.year, now.month, now.day),
    );

    int totalDays = diff.inDays;

    if (totalDays < 0) return "Expired";

    totalDays = totalDays + 1;

    int months = totalDays ~/ 30;
    int days = totalDays % 30;

    if (months > 0 && days > 0) {
      return "$months month${months > 1 ? 's' : ''} $days day${days > 1 ? 's' : ''}";
    } else if (months > 0) {
      return "$months month${months > 1 ? 's' : ''}";
    } else {
      return "$days day${days > 1 ? 's' : ''}";
    }
  } catch (e) {
    return "Invalid date format";
  }
}
