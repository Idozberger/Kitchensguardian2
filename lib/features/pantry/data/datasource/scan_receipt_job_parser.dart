import 'package:foodkitchen/core/utils/json_conversion.dart';

enum ScanReceiptJobStatus { pending, finished, failed }

class ScanReceiptJobOutcome {
  final ScanReceiptJobStatus status;
  final Map<String, dynamic>? result;
  final String message;

  const ScanReceiptJobOutcome({
    required this.status,
    this.result,
    this.message = '',
  });
}

/// Interprets one `GET /api/scan_recipt/jobs/{id}` poll response.
ScanReceiptJobOutcome parseScanReceiptJob(Map<String, dynamic> job) {
  final String status = readJsonString(job, 'status');

  if (status == 'finished') {
    return ScanReceiptJobOutcome(
      status: ScanReceiptJobStatus.finished,
      result: jsonObjectFromResponseData(job['result']),
    );
  }

  if (status == 'failed') {
    return ScanReceiptJobOutcome(
      status: ScanReceiptJobStatus.failed,
      message: readJsonString(job, 'message', fallback: 'Receipt scan failed'),
    );
  }

  return const ScanReceiptJobOutcome(status: ScanReceiptJobStatus.pending);
}

/// Normalizes each scanned item's raw JSON to a typed map. `thumbnail` is a
/// shared_ingredients catalog icon path (e.g. `/api/shared_ingredients/42/image`),
/// resolved to a full URL by the repository - left untouched here.
List<Map<String, dynamic>> parseScanReceiptItems(Object? itemsRaw) {
  final List<Object?> items = itemsRaw is List ? itemsRaw : [];

  return items.map(jsonObjectFromResponseData).toList();
}
