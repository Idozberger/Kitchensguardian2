import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/core/widgets/safe_image.dart';

/// In flutter_test every HTTP image request fails, so `Image.network` always
/// lands in `errorBuilder` — which is exactly the "catalog icon still
/// generating (404)" case this widget retries.
void main() {
  Widget host(String url) => MaterialApp(
    home: SafeNetworkImage(
      url: url,
      fallback: const Text('placeholder'),
      width: 24,
      height: 24,
    ),
  );

  int attemptKeyOf(WidgetTester tester) =>
      (tester.widget<Image>(find.byType(Image)).key as ValueKey<int>).value;

  testWidgets('shows fallback and retries a failed load', (tester) async {
    await tester.pumpWidget(host('https://example.com/api/shared/1/image'));
    await tester.pump();

    expect(find.text('placeholder'), findsOneWidget);
    expect(attemptKeyOf(tester), 0);

    // First retry fires after 2s.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(attemptKeyOf(tester), 1);

    // Retries are bounded: 2s + 5s + 10s, then it gives up.
    await tester.pump(const Duration(seconds: 5));
    await tester.pump();
    await tester.pump(const Duration(seconds: 10));
    await tester.pump();
    expect(attemptKeyOf(tester), 3);

    await tester.pump(const Duration(seconds: 60));
    await tester.pump();
    expect(attemptKeyOf(tester), 3);
    expect(find.text('placeholder'), findsOneWidget);
  });

  testWidgets('empty url renders fallback without an Image', (tester) async {
    await tester.pumpWidget(host(''));
    await tester.pump();

    expect(find.text('placeholder'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}
