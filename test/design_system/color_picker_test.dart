import 'dart:ui' show Color, SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/design_system.dart';

Widget _app(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? SossoldiTheme.light,
  home: Scaffold(
    body: Center(child: SizedBox(width: 358, child: child)),
  ),
);

int _channel(double v) => (v * 255).round();

void main() {
  group('CategoryColor from any color', () {
    test('the tint has the same hue and saturation at lightness 90%', () {
      const main = Color(0xFF123456);
      final c = CategoryColor.fromColor(main);
      expect(c.main, main);
      final mainHsl = HSLColor.fromColor(main);
      final tintHsl = HSLColor.fromColor(c.tint);
      expect(tintHsl.lightness, closeTo(0.9, 0.01));
      expect(tintHsl.hue, closeTo(mainHsl.hue, 2));
      expect(tintHsl.saturation, closeTo(mainHsl.saturation, 0.03));
    });

    test('derived like the palette: every palette tint is what it gives', () {
      for (final c in CategoryColors.all) {
        final d = CategoryColor.fromColor(c.main).tint;
        expect(
          (_channel(d.r) - _channel(c.tint.r)).abs(),
          lessThanOrEqualTo(1),
        );
        expect(
          (_channel(d.g) - _channel(c.tint.g)).abs(),
          lessThanOrEqualTo(1),
        );
        expect(
          (_channel(d.b) - _channel(c.tint.b)).abs(),
          lessThanOrEqualTo(1),
        );
      }
    });

    test('in dark mode the tint is the color at 0.2 of opacity', () {
      final c = CategoryColor.fromColor(const Color(0xFF123456));
      expect(
        c.tintFor(Brightness.dark),
        const Color(0xFF123456).withValues(alpha: CategoryColor.darkTintAlpha),
      );
    });

    test('palette colors keep their drawn tints and compare by value', () {
      final c = CategoryColors.all[5];
      expect(c.tint, const Color(0xFFFEE8CD));
      expect(CategoryColor(c.main, c.tint), c);
      expect(
        CategoryColor.fromColor(c.main),
        isNot(CategoryColor(c.main, const Color(0xFFFFFFFF))),
      );
    });
  });

  group('CategoryColorSpace (HCT, fixed tone)', () {
    test('every position gives a color at the same tone', () {
      for (var h = 0; h <= 20; h++) {
        for (final s in [0.0, 0.5, 1.0]) {
          final color = CategoryColorSpace.colorAt(h / 20, s);
          expect(
            Hct.fromInt(color.toARGB32()).tone,
            closeTo(CategoryColorSpace.tone, 1.5),
          );
        }
      }
    });

    test('the ends stay in the family of the palette', () {
      // The palette goes from 29 to 97 of chroma and from 32 to 88 of tone.
      var lowest = double.infinity;
      var highest = 0.0;
      for (var h = 0; h <= 40; h++) {
        final low = Hct.fromInt(
          CategoryColorSpace.colorAt(h / 40, 0).toARGB32(),
        );
        final high = Hct.fromInt(
          CategoryColorSpace.colorAt(h / 40, 1).toARGB32(),
        );
        lowest = lowest < low.chroma ? lowest : low.chroma;
        highest = highest > high.chroma ? highest : high.chroma;
        expect(high.chroma, greaterThan(low.chroma));
      }
      expect(lowest, greaterThanOrEqualTo(25));
      expect(highest, lessThanOrEqualTo(100));
    });

    test('the lowest saturation is never grey', () {
      for (var h = 0; h <= 40; h++) {
        final c = Hct.fromInt(CategoryColorSpace.colorAt(h / 40, 0).toARGB32());
        expect(c.chroma, greaterThan(24));
      }
    });

    test('a position comes back to itself through the color', () {
      for (var h = 0; h <= 20; h++) {
        for (final s in [0.0, 0.3, 0.7, 1.0]) {
          final color = CategoryColorSpace.colorAt(h / 20, s);
          final back = CategoryColorSpace.positionsOf(color);
          expect(back.hue, closeTo(h / 20, 0.02));
          expect(back.saturation, closeTo(s, 0.08));
        }
      }
    });

    test('a palette color goes to the closest position, inside the limits', () {
      for (final c in CategoryColors.all) {
        final p = CategoryColorSpace.positionsOf(c.main);
        expect(p.hue, inInclusiveRange(0, 1));
        expect(p.saturation, inInclusiveRange(0, 1));
        // The slider hue is the hue of the color (the ends are red).
        final hue = Hct.fromInt(c.main.toARGB32()).hue;
        final slider = CategoryColorSpace.hueAt(p.hue);
        final diff = (hue - slider).abs();
        expect(diff < 180 ? diff : 360 - diff, lessThan(12));
      }
    });
  });

  group('SossoldiColorPicker', () {
    final start = CategoryColors.all[8].main;

    testWidgets('does not change the color until a slider moves', (
      tester,
    ) async {
      final changes = <Color>[];
      await tester.pumpWidget(
        _app(SossoldiColorPicker(color: start, onChanged: changes.add)),
      );
      await tester.pumpAndSettle();
      expect(changes, isEmpty);
    });

    testWidgets('the hue slider changes the hue, the other the saturation', (
      tester,
    ) async {
      final changes = <Color>[];
      await tester.pumpWidget(
        _app(
          SossoldiColorPicker(
            color: start,
            onChanged: changes.add,
            hueSemanticLabel: 'Hue',
            saturationSemanticLabel: 'Saturation',
          ),
        ),
      );
      await tester.drag(find.bySemanticsLabel('Hue'), const Offset(120, 0));
      await tester.pump();
      expect(changes, isNotEmpty);
      final afterHue = Hct.fromInt(changes.last.toARGB32());
      final startHct = Hct.fromInt(start.toARGB32());
      expect((afterHue.hue - startHct.hue).abs(), greaterThan(10));
      expect(afterHue.tone, closeTo(CategoryColorSpace.tone, 1.5));

      final hueBefore = afterHue.hue;
      await tester.drag(
        find.bySemanticsLabel('Saturation'),
        const Offset(-300, 0),
      );
      await tester.pump();
      final low = Hct.fromInt(changes.last.toARGB32());
      expect(low.hue, closeTo(hueBefore, 3));
      await tester.drag(
        find.bySemanticsLabel('Saturation'),
        const Offset(300, 0),
      );
      await tester.pump();
      final high = Hct.fromInt(changes.last.toARGB32());
      expect(high.chroma, greaterThan(low.chroma));
    });

    testWidgets('a tap on the track moves the knob there', (tester) async {
      final changes = <Color>[];
      await tester.pumpWidget(
        _app(
          SossoldiColorPicker(
            color: start,
            onChanged: changes.add,
            hueSemanticLabel: 'Hue',
          ),
        ),
      );
      final box = tester.getRect(find.bySemanticsLabel('Hue'));
      await tester.tapAt(Offset(box.left + 4, box.center.dy));
      await tester.pump();
      expect(changes, hasLength(1));
      expect(
        changes.single,
        CategoryColorSpace.colorAt(
          0,
          CategoryColorSpace.positionsOf(start).saturation,
        ),
      );
    });

    testWidgets('a color that comes from outside moves the sliders', (
      tester,
    ) async {
      final changes = <Color>[];
      Widget build(Color color) => _app(
        SossoldiColorPicker(
          color: color,
          onChanged: changes.add,
          hueSemanticLabel: 'Hue',
        ),
      );
      await tester.pumpWidget(build(CategoryColors.all[0].main));
      final before = tester.getSemantics(find.bySemanticsLabel('Hue')).value;
      await tester.pumpWidget(build(CategoryColors.all[25].main));
      final after = tester.getSemantics(find.bySemanticsLabel('Hue')).value;
      expect(after, isNot(before));
      expect(changes, isEmpty);
    });

    testWidgets('the screen reader can move a slider', (tester) async {
      final changes = <Color>[];
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          SossoldiColorPicker(
            color: start,
            onChanged: changes.add,
            hueSemanticLabel: 'Hue',
          ),
        ),
      );
      tester.semantics.performAction(
        find.semantics.byLabel('Hue'),
        SemanticsAction.increase,
      );
      await tester.pump();
      expect(changes, hasLength(1));
      handle.dispose();
    });

    for (final (name, theme) in [
      ('light', SossoldiTheme.light),
      ('dark', SossoldiTheme.dark),
    ]) {
      testWidgets('renders in $name', (tester) async {
        await tester.pumpWidget(
          _app(
            theme: theme,
            SossoldiColorPicker(color: start, onChanged: (_) {}),
          ),
        );
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('SossoldiIconPicker', () {
    Widget picker(
      void Function(IconData) onSelected, {
      IconData? selected = PhosphorIconsRegular.bank,
    }) => _app(
      SizedBox(
        height: 500,
        child: SossoldiIconPicker(
          selected: selected,
          color: CategoryColors.all[3],
          onSelected: onSelected,
          groupLabel: (id) => id.name,
        ),
      ),
    );

    // The first icon of a group is at the top of its grid, so it is built.
    IconData first(CategoryIconGroupId id) =>
        CategoryIcons.groups.firstWhere((g) => g.id == id).icons.first;

    testWidgets('a tab for each group, the grid of the one with the selected '
        'icon', (tester) async {
      IconData? picked;
      await tester.pumpWidget(picker((i) => picked = i));
      for (final g in CategoryIcons.groups) {
        expect(find.bySemanticsLabel(g.id.name), findsOneWidget);
      }
      // The bank is in Finance, the first group.
      final icon = first(CategoryIconGroupId.finance);
      expect(find.byIcon(icon), findsOneWidget);
      await tester.tap(find.byIcon(icon));
      expect(picked, icon);
    });

    testWidgets('a tab shows the icons of its group, not of the others', (
      tester,
    ) async {
      await tester.pumpWidget(picker((_) {}));
      final finance = first(CategoryIconGroupId.finance);
      final travel = first(CategoryIconGroupId.travel);
      expect(find.byIcon(travel), findsNothing);
      await tester.tap(find.bySemanticsLabel(CategoryIconGroupId.travel.name));
      await tester.pump();
      expect(find.byIcon(travel), findsOneWidget);
      expect(find.byIcon(finance), findsNothing);
    });

    testWidgets('it opens on the group of the selected icon', (tester) async {
      final travel = first(CategoryIconGroupId.travel);
      await tester.pumpWidget(picker((_) {}, selected: travel));
      expect(find.byIcon(travel), findsOneWidget);
      expect(find.byIcon(first(CategoryIconGroupId.finance)), findsNothing);
    });

    test('a thousand icons in groups, none twice, none of the arrows', () {
      expect(CategoryIcons.all.length, greaterThan(900));
      expect(CategoryIcons.all.toSet(), hasLength(CategoryIcons.all.length));
      for (final g in CategoryIcons.groups) {
        expect(g.icons, isNotEmpty, reason: g.id.name);
      }
      expect(
        CategoryIcons.all,
        isNot(contains(PhosphorIconsRegular.arrowLeft)),
      );
      expect(
        CategoryIcons.all,
        isNot(contains(PhosphorIconsRegular.caretDown)),
      );
      // The icons of the demo accounts are all there.
      for (final icon in [
        PhosphorIconsRegular.bank,
        PhosphorIconsRegular.piggyBank,
        PhosphorIconsRegular.chartLineUp,
      ]) {
        expect(CategoryIcons.groupOf(icon), isNotNull);
      }
    });
  });

  group('bottom sheet toolbar, disabled check', () {
    testWidgets('a disabled check does nothing; an enabled one confirms', (
      tester,
    ) async {
      var confirmed = 0;
      Widget build(bool enabled) => _app(
        SossoldiBottomSheetToolbar.icon(
          title: 'T',
          onClose: () {},
          closeSemanticLabel: 'Close',
          onConfirm: () => confirmed++,
          confirmSemanticLabel: 'Save',
          confirmEnabled: enabled,
        ),
      );
      await tester.pumpWidget(build(false));
      await tester.tap(find.byIcon(PhosphorIconsRegular.check));
      expect(confirmed, 0);
      await tester.pumpWidget(build(true));
      await tester.tap(find.byIcon(PhosphorIconsRegular.check));
      expect(confirmed, 1);
    });
  });
}
