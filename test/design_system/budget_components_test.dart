import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../load_test_fonts.dart';

Widget _wrap(
  Widget child, {
  Brightness brightness = Brightness.light,
  double width = 358,
}) => MaterialApp(
  theme: brightness == Brightness.dark
      ? SossoldiTheme.dark
      : SossoldiTheme.light,
  home: Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(width: width, child: child),
    ),
  ),
);

const _c = Color(0xFFB655F6);
const _t = Color(0xFFEACFFC);

SossoldiBudgetItem _item({
  String title = 'Groceries',
  SossoldiBudgetTone tone = SossoldiBudgetTone.ok,
  bool prominent = false,
  String? period,
  VoidCallback? onTap,
  double value = .5,
  bool exceeded = false,
}) => SossoldiBudgetItem(
  title: title,
  percent: '50%',
  remaining: '120,00 € left',
  tone: tone,
  prominent: prominent,
  periodLabel: period,
  onTap: onTap,
  bar: SossoldiBudgetBar(
    value: value,
    color: _c,
    trackColor: _t,
    exceeded: exceeded,
  ),
);

TextStyle _styleOf(WidgetTester tester, String text) {
  final rich = tester
      .widgetList<RichText>(find.byType(RichText))
      .firstWhere((r) => r.text.toPlainText().contains(text));
  TextStyle? found;
  rich.text.visitChildren((span) {
    if (span is TextSpan && (span.text ?? '').contains(text)) {
      found = span.style;
    }
    return true;
  });
  return found ?? rich.text.style!;
}

void main() {
  setUpAll(loadTestFonts);

  group('budget bar', () {
    testWidgets('is 8px high and takes the width it is given', (tester) async {
      await tester.pumpWidget(
        _wrap(const SossoldiBudgetBar(value: .4, color: _c, trackColor: _t)),
      );
      final size = tester.getSize(find.byType(SossoldiBudgetBar));
      expect(size, const Size(358, 8));
    });

    testWidgets('any value, even out of range or NaN, draws without errors', (
      tester,
    ) async {
      for (final v in [-1.0, 0.0, .5, 1.0, 2.0, double.nan]) {
        await tester.pumpWidget(
          _wrap(SossoldiBudgetBar(value: v, color: _c, trackColor: _t)),
        );
        expect(tester.takeException(), isNull, reason: '$v');
      }
    });

    testWidgets('exceeded draws with the error outline, in both themes', (
      tester,
    ) async {
      for (final b in Brightness.values) {
        await tester.pumpWidget(
          _wrap(
            const SossoldiBudgetBar(
              value: 1,
              color: _c,
              trackColor: _t,
              exceeded: true,
            ),
            brightness: b,
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('segmented bar', () {
    testWidgets('draws any number of parts, even none or empty ones', (
      tester,
    ) async {
      for (final n in [0, 1, 7, 40]) {
        await tester.pumpWidget(
          _wrap(
            SossoldiSegmentedBar(
              segments: [
                for (var i = 0; i < n; i++)
                  SossoldiBarSegment(
                    share: i == 0 ? 0 : 0.5 / n,
                    color: _c,
                    exceeded: i % 3 == 0,
                  ),
              ],
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: '$n parts');
      }
      expect(tester.getSize(find.byType(SossoldiSegmentedBar)).height, 8);
    });

    testWidgets('shares that add up to more than the bar are cut at its end', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SossoldiSegmentedBar(
            segments: [
              SossoldiBarSegment(share: .7, color: _c),
              SossoldiBarSegment(share: .7, color: _t, exceeded: true),
              SossoldiBarSegment(share: double.nan, color: _c),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in both themes with the neutral remainder', (
      tester,
    ) async {
      for (final b in Brightness.values) {
        await tester.pumpWidget(
          _wrap(
            const SossoldiSegmentedBar(
              segments: [SossoldiBarSegment(share: .3, color: _c)],
            ),
            brightness: b,
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('a label is read to screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _wrap(
          const SossoldiSegmentedBar(
            semanticLabel: 'Budgets',
            segments: [SossoldiBarSegment(share: .5, color: _c)],
          ),
        ),
      );
      expect(find.bySemanticsLabel('Budgets'), findsOneWidget);
      handle.dispose();
    });
  });

  group('budget item', () {
    testWidgets('title, percentage, what is left', (tester) async {
      await tester.pumpWidget(_wrap(_item()));
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.textContaining('50%', findRichText: true), findsOneWidget);
      expect(
        find.textContaining('120,00 € left', findRichText: true),
        findsOneWidget,
      );
      expect(find.byType(SossoldiChip), findsNothing);
    });

    testWidgets('a period chip is optional', (tester) async {
      await tester.pumpWidget(_wrap(_item(period: 'Monthly')));
      expect(find.widgetWithText(SossoldiChip, 'Monthly'), findsOneWidget);
    });

    testWidgets('the tone colors the figures', (tester) async {
      final colors = <SossoldiBudgetTone, Color?>{};
      for (final tone in SossoldiBudgetTone.values) {
        await tester.pumpWidget(_wrap(_item(tone: tone)));
        colors[tone] = _styleOf(tester, '50%').color;
      }
      final theme = SossoldiTheme.light.extension<SossoldiColors>()!;
      expect(colors[SossoldiBudgetTone.ok], theme.textHigh);
      expect(colors[SossoldiBudgetTone.warning], theme.warning.text);
      expect(colors[SossoldiBudgetTone.exceeded], theme.error.text);
    });

    testWidgets('exceeded colors the remaining text too', (tester) async {
      await tester.pumpWidget(_wrap(_item(tone: SossoldiBudgetTone.exceeded)));
      final theme = SossoldiTheme.light.extension<SossoldiColors>()!;
      expect(_styleOf(tester, 'left').color, theme.error.text);
      await tester.pumpWidget(_wrap(_item(tone: SossoldiBudgetTone.warning)));
      expect(_styleOf(tester, 'left').color, theme.textMed);
    });

    testWidgets('exceeded: the percentage is in an error chip', (tester) async {
      await tester.pumpWidget(_wrap(_item(tone: SossoldiBudgetTone.exceeded)));
      final chip = tester.widget<SossoldiChip>(find.byType(SossoldiChip));
      expect(chip.type, SossoldiChipType.error);
      expect(chip.label, '50%');
      expect(find.text('120,00 € left'), findsOneWidget);
    });

    testWidgets('only exceeded rows have the chip; the overall one does not', (
      tester,
    ) async {
      for (final tone in [SossoldiBudgetTone.ok, SossoldiBudgetTone.warning]) {
        await tester.pumpWidget(_wrap(_item(tone: tone)));
        expect(find.byType(SossoldiChip), findsNothing, reason: '$tone');
      }
      await tester.pumpWidget(
        _wrap(_item(tone: SossoldiBudgetTone.exceeded, prominent: true)),
      );
      expect(find.byType(SossoldiChip), findsNothing);
    });

    testWidgets('chip row with a long amount does not overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          SossoldiBudgetItem(
            title: 'A category with a really very long name indeed',
            percent: '1234%',
            remaining: '123.456.789,00 € over',
            tone: SossoldiBudgetTone.exceeded,
            bar: const SossoldiBudgetBar(value: 1, color: _c, trackColor: _t),
          ),
          width: 300,
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('prominent has a larger title', (tester) async {
      await tester.pumpWidget(_wrap(_item(title: 'Overall budget')));
      final small = tester
          .widget<Text>(find.text('Overall budget'))
          .style!
          .fontSize!;
      await tester.pumpWidget(
        _wrap(_item(title: 'Overall budget', prominent: true)),
      );
      final large = tester
          .widget<Text>(find.text('Overall budget'))
          .style!
          .fontSize!;
      expect(large, greaterThan(small));
    });

    testWidgets('tapping calls onTap only when there is one', (tester) async {
      var taps = 0;
      await tester.pumpWidget(_wrap(_item(onTap: () => taps++)));
      await tester.tap(find.text('Groceries'));
      expect(taps, 1);
      await tester.pumpWidget(_wrap(_item()));
      expect(find.byType(SossoldiTappable), findsNothing);
    });

    testWidgets('a long name and a long amount do not overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          SossoldiBudgetItem(
            title: 'A category with a really very long name indeed',
            percent: '1234%',
            remaining: '123.456.789,00 € over',
            tone: SossoldiBudgetTone.exceeded,
            bar: const SossoldiBudgetBar(value: 1, color: _c, trackColor: _t),
          ),
          width: 300,
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('works in dark mode', (tester) async {
      await tester.pumpWidget(
        _wrap(
          _item(tone: SossoldiBudgetTone.warning),
          brightness: Brightness.dark,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('danger button', () {
    testWidgets('fill, outline and ghost use the error colors', (tester) async {
      for (final type in SossoldiButtonType.values) {
        await tester.pumpWidget(
          _wrap(
            SossoldiButton(
              label: 'Delete',
              type: type,
              tone: SossoldiButtonTone.danger,
              onPressed: () {},
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Delete'), findsOneWidget);
      }
      await tester.pumpWidget(
        _wrap(
          SossoldiButton(
            label: 'Delete',
            tone: SossoldiButtonTone.danger,
            onPressed: () {},
          ),
        ),
      );
      final box = tester.widget<Container>(
        find.descendant(
          of: find.byType(SossoldiButton),
          matching: find.byType(Container),
        ),
      );
      final colors = SossoldiTheme.light.extension<SossoldiColors>()!;
      expect((box.decoration as ShapeDecoration).color, colors.error.stroke);
    });

    testWidgets('the primary tone is unchanged', (tester) async {
      await tester.pumpWidget(
        _wrap(SossoldiButton(label: 'Go', onPressed: () {})),
      );
      final box = tester.widget<Container>(
        find.descendant(
          of: find.byType(SossoldiButton),
          matching: find.byType(Container),
        ),
      );
      final colors = SossoldiTheme.light.extension<SossoldiColors>()!;
      expect((box.decoration as ShapeDecoration).color, colors.primary.surface);
    });
  });
}
