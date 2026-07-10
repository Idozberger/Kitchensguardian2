import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/widgets/generic_dropdown_widget.dart';

/// Guards the measurement-system picker added for BRD UC-03 / UC-04.
///
/// The risky part is [PopupDropdownField] inside a dialog: it renders its
/// option list into the Navigator's Overlay, while [GenericDialog] wraps its
/// child in a ClipRRect. If the overlay were a descendant of that clip, the
/// options would be clipped or painted under the dialog.
void main() {
  group('unit system mappers', () {
    test('options are the raw API values the backend accepts', () {
      expect(unitSystemOptions, ['metric', 'imperial']);
    });

    test('display label capitalizes without changing the sent value', () {
      expect(unitSystemDisplayLabel('metric'), 'Metric');
      expect(unitSystemDisplayLabel('imperial'), 'Imperial');
      expect(unitSystemToApi(UnitSystem.imperial), 'imperial');
      expect(unitSystemFromApi('imperial'), UnitSystem.imperial);
      expect(unitSystemFromApi('nonsense'), UnitSystem.metric);
    });
  });

  testWidgets('picker opens inside a dialog and returns the raw API value', (
    tester,
  ) async {
    String? picked;
    String current = unitSystemToApi(UnitSystem.metric);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => GenericDialog(
                  child: StatefulBuilder(
                    builder: (_, setInnerState) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupDropdownField(
                          label: 'Measurement System',
                          hint: 'Select system',
                          value: current,
                          items: unitSystemOptions,
                          displayLabel: unitSystemDisplayLabel,
                          onChanged: (value) {
                            picked = value;
                            setInnerState(() => current = value!);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Closed field shows the capitalized current value; no option list yet.
    expect(find.text('Metric'), findsOneWidget);
    expect(find.text('Imperial'), findsNothing);

    // Open the dropdown.
    await tester.tap(find.text('Metric'));
    await tester.pumpAndSettle();

    // Both options are laid out — the overlay escaped the dialog's ClipRRect.
    expect(find.text('Imperial'), findsOneWidget);
    expect(find.text('Metric'), findsWidgets);

    await tester.tap(find.text('Imperial'));
    await tester.pumpAndSettle();

    // onChanged hands back the raw API value, not the display label.
    expect(picked, 'imperial');
    expect(find.text('Imperial'), findsOneWidget);
  });
}
