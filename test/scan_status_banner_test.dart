import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/app/scan_status_banner.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt.dart';
import 'package:foodkitchen/features/pantry/presentation/bloc/pantry_state.dart';

void main() {
  group('nextScanStatus', () {
    test('a failed scan clears the banner instead of spinning forever', () {
      expect(
        nextScanStatus(ScanStatus.scanning, PantryFailure('Scan timed out')),
        ScanStatus.none,
      );
    });

    test('an unrelated pantry failure leaves the banner alone', () {
      expect(
        nextScanStatus(ScanStatus.ready, PantryFailure('Delete failed')),
        ScanStatus.ready,
      );
      expect(
        nextScanStatus(ScanStatus.none, PantryFailure('Delete failed')),
        ScanStatus.none,
      );
    });

    test('scan lifecycle: loading -> loaded -> saved', () {
      expect(
        nextScanStatus(ScanStatus.none, PantryScanItemsLoading()),
        ScanStatus.scanning,
      );
      expect(
        nextScanStatus(
          ScanStatus.scanning,
          ScanReceiptLoaded(
            ScanReceiptEntity(successMessage: 'ok', items: const []),
            '/tmp/receipt.jpg',
          ),
        ),
        ScanStatus.ready,
      );
      expect(
        nextScanStatus(ScanStatus.ready, PantrySuccess('Items added')),
        ScanStatus.none,
      );
    });
  });
}
