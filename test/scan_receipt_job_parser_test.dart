import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/features/pantry/data/datasource/scan_receipt_job_parser.dart';

void main() {
  group('parseScanReceiptJob', () {
    test('finished status returns the result map', () {
      final outcome = parseScanReceiptJob({
        'status': 'finished',
        'result': {'message': 'ok', 'items': <Object?>[]},
      });

      expect(outcome.status, ScanReceiptJobStatus.finished);
      expect(outcome.result?['message'], 'ok');
    });

    test('failed status carries the error message', () {
      final outcome = parseScanReceiptJob({
        'status': 'failed',
        'message': 'AI could not read receipt',
      });

      expect(outcome.status, ScanReceiptJobStatus.failed);
      expect(outcome.message, 'AI could not read receipt');
    });

    test('queued/started status is pending', () {
      expect(
        parseScanReceiptJob({'status': 'queued'}).status,
        ScanReceiptJobStatus.pending,
      );
      expect(
        parseScanReceiptJob({'status': 'started'}).status,
        ScanReceiptJobStatus.pending,
      );
    });
  });

  group('parseScanReceiptItems', () {
    test('passes the thumbnail (catalog icon path) through untouched', () {
      final items = parseScanReceiptItems([
        <String, dynamic>{
          'name': 'Milk',
          'thumbnail': '/api/shared_ingredients/42/image',
        },
      ]);

      expect(items.single['thumbnail'], '/api/shared_ingredients/42/image');
    });

    test('non-list input returns an empty list', () {
      expect(parseScanReceiptItems(null), isEmpty);
    });
  });
}
