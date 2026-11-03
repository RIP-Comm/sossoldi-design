import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi_inspector/main.dart';
import 'package:sossoldi_inspector/scenes.dart';

Future<void> _pumpInspector(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1440, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const InspectorApp());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('every scene opens in light and dark', (tester) async {
    await _pumpInspector(tester);
    for (final dark in [false, true]) {
      if (dark) {
        await tester.tap(find.byIcon(PhosphorIconsRegular.moon));
        await tester.pump(const Duration(seconds: 1));
      }
      for (final scene in sceneGroups.expand((g) => g.scenes)) {
        await tester.tap(find.text(scene.title).first);
        // Sheets and pages open after the first frame, then animate.
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 500));
        }
        expect(tester.takeException(), isNull, reason: scene.id);
      }
    }
  });

  testWidgets('a click on the phone shows the measures of the text', (
    tester,
  ) async {
    await _pumpInspector(tester);
    // The headline amount of the Monthly balance widget.
    final amount = find.text('-€1,056.96').first;
    await tester.tapAt(tester.getCenter(amount));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('LAYOUT'), findsOneWidget);
    expect(find.text('TEXT'), findsOneWidget);
    expect(find.text('headlineSmall'), findsOneWidget);
    expect(find.text('textHigh'), findsOneWidget);
  });

  testWidgets('Component picks the whole design system component', (
    tester,
  ) async {
    await _pumpInspector(tester);
    await tester.tap(find.byIcon(PhosphorIconsRegular.selection));
    await tester.pump();
    await tester.tap(find.text('Component'));
    await tester.pump();
    await tester.tapAt(tester.getCenter(find.text('Pharmacy').first));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('SossoldiTransactionItem'), findsOneWidget);
    expect(find.text('Component'), findsOneWidget); // the tag
    expect(find.text('PADDING'), findsOneWidget);
    expect(find.text('AUTO LAYOUT'), findsOneWidget);
  });

  testWidgets('the pick tool hides in Interact and comes back', (
    tester,
  ) async {
    await _pumpInspector(tester);
    expect(find.byIcon(PhosphorIconsRegular.selection), findsOneWidget);
    await tester.tap(find.byIcon(PhosphorIconsRegular.handPointing));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byIcon(PhosphorIconsRegular.selection), findsNothing);
    await tester.tap(find.byIcon(PhosphorIconsRegular.cursor));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byIcon(PhosphorIconsRegular.selection), findsOneWidget);
  });

  testWidgets('zoom and a wide panel keep working', (tester) async {
    await _pumpInspector(tester);
    await tester.tap(find.text('Fit'));
    await tester.pump();
    await tester.tap(find.text('150%'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('150%'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
