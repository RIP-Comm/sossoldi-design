import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/design_system.dart';

// The selected option of a list, dropdown or select.
void main() {
  group('menu item: selected option', () {
    Widget wrap(Widget child, {Brightness b = Brightness.light}) => MaterialApp(
      theme: b == Brightness.dark ? SossoldiTheme.dark : SossoldiTheme.light,
      home: Scaffold(body: SizedBox(width: 300, child: child)),
    );

    ShapeDecoration decorationOf(WidgetTester tester) {
      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(SossoldiMenuItem),
              matching: find.byType(Container),
            )
            .first,
      );
      return container.decoration! as ShapeDecoration;
    }

    testWidgets('has the selected primary fill and a check on the right', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const SossoldiMenuItem(
            label: 'Monthly',
            selected: true,
            onTap: _noop,
          ),
        ),
      );
      final colors = SossoldiTheme.light.extension<SossoldiColors>()!;
      expect(decorationOf(tester).color, colors.selectedPrimarySurface);
      expect(find.byIcon(PhosphorIconsRegular.check), findsOneWidget);
      final check = tester.widget<Icon>(
        find.byIcon(PhosphorIconsRegular.check),
      );
      expect(check.color, colors.primary.text);
      // The check sits at the right edge.
      final row = tester.getRect(find.byType(SossoldiMenuItem));
      expect(
        tester.getRect(find.byIcon(PhosphorIconsRegular.check)).right,
        lessThanOrEqualTo(row.right),
      );
      expect(
        tester.getCenter(find.byIcon(PhosphorIconsRegular.check)).dx,
        greaterThan(row.center.dx),
      );
    });

    testWidgets('an item that is not selected is plain, with no check', (
      tester,
    ) async {
      for (final selected in [null, false]) {
        await tester.pumpWidget(
          wrap(
            SossoldiMenuItem(label: 'Weekly', selected: selected, onTap: _noop),
          ),
        );
        final colors = SossoldiTheme.light.extension<SossoldiColors>()!;
        expect(decorationOf(tester).color, colors.surfaceHigh);
        expect(find.byIcon(PhosphorIconsRegular.check), findsNothing);
      }
    });

    testWidgets('a trailing control replaces the check', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SossoldiMenuItem(
            label: 'Dark mode',
            selected: true,
            trailing: Icon(Icons.circle),
            onTap: _noop,
          ),
        ),
      );
      expect(find.byIcon(PhosphorIconsRegular.check), findsNothing);
      expect(find.byIcon(Icons.circle), findsOneWidget);
    });

    testWidgets('works in dark mode', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SossoldiMenuItem(
            label: 'Monthly',
            selected: true,
            onTap: _noop,
          ),
          b: Brightness.dark,
        ),
      );
      final colors = SossoldiTheme.dark.extension<SossoldiColors>()!;
      expect(decorationOf(tester).color, colors.selectedPrimarySurface);
      expect(
        colors.selectedPrimarySurface,
        isNot(
          SossoldiTheme.light
              .extension<SossoldiColors>()!
              .selectedPrimarySurface,
        ),
      );
    });

    testWidgets('the select marks the current option when opened', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          SossoldiSelect<int>(
            value: 2,
            onChanged: (_) {},
            items: const [
              SossoldiSelectItem(value: 1, label: 'Weekly'),
              SossoldiSelectItem(value: 2, label: 'Monthly'),
              SossoldiSelectItem(value: 3, label: 'Yearly'),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();
      final items = tester
          .widgetList<SossoldiMenuItem>(find.byType(SossoldiMenuItem))
          .toList();
      expect(items.map((i) => i.selected), [false, true, false]);
      expect(find.byIcon(PhosphorIconsRegular.check), findsOneWidget);
    });

    test('the token is the primary 93 tint in light', () {
      final colors = SossoldiTheme.light.extension<SossoldiColors>()!;
      expect(colors.selectedPrimarySurface, SossoldiPrimitives.primary93);
      expect(colors.selectedPrimarySurface, isNot(colors.selectedSurface));
    });
  });
}

void _noop() {}
