import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/design_system.dart';

Widget _app(ThemeData theme, Widget child) => MaterialApp(
  theme: theme,
  home: Scaffold(
    body: Center(child: SizedBox(width: 320, child: child)),
  ),
);

const _icon = PhosphorIconsRegular.sticker;

final _all = <String, Widget>{
  'button': Wrap(
    children: [
      for (final type in SossoldiButtonType.values)
        for (final size in SossoldiButtonSize.values)
          SossoldiButton(
            label: 'Button',
            type: type,
            size: size,
            iconLeft: _icon,
            iconRight: _icon,
            onPressed: () {},
          ),
      const SossoldiButton(label: 'Off', onPressed: null),
    ],
  ),
  'icon button': Wrap(
    children: [
      for (final size in SossoldiIconButtonSize.values)
        for (final type in SossoldiIconButtonType.values)
          for (final variant in SossoldiIconButtonVariant.values)
            SossoldiIconButton(
              icon: _icon,
              size: size,
              type: type,
              variant: variant,
              semanticLabel: 'x',
              onPressed: () {},
            ),
    ],
  ),
  'chips and tags': Wrap(
    children: [
      for (final t in SossoldiChipType.values)
        SossoldiChip(label: 'Chip', type: t, iconLeft: _icon),
      for (final t in SossoldiTagType.values)
        SossoldiTag(label: 'Tag', type: t, hasStroke: true),
      SossoldiFilterChip(name: 'Name', value: 'Text', onRemove: () {}),
    ],
  ),
  'fields': const Column(
    children: [
      SossoldiTextInput(label: 'Label', placeholder: 'Placeholder'),
      SossoldiTextarea(placeholder: 'Placeholder'),
    ],
  ),
  'navigation': Column(
    children: [
      SossoldiTabNavigation(
        tabs: const [SossoldiTabData.text('A'), SossoldiTabData.text('B')],
        selectedIndex: 0,
        onChanged: (_) {},
      ),
      SossoldiUnitNavigator(label: 'Unit', selected: true, onTap: () {}),
    ],
  ),
};

void main() {
  for (final (themeName, theme) in [
    ('light', SossoldiTheme.light),
    ('dark', SossoldiTheme.dark),
  ]) {
    for (final MapEntry(key: name, value: widget) in _all.entries) {
      testWidgets('$name renders in $themeName', (tester) async {
        await tester.pumpWidget(_app(theme, widget));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('checkbox cycles unchecked -> checked -> unchecked', (
    tester,
  ) async {
    bool? value = false;
    await tester.pumpWidget(
      _app(
        SossoldiTheme.light,
        StatefulBuilder(
          builder: (context, setState) => SossoldiCheckbox(
            value: value,
            label: 'Label',
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Label'));
    await tester.pump();
    expect(value, isTrue);
    await tester.tap(find.text('Label'));
    expect(value, isFalse);
  });

  testWidgets('switch toggles and ignores taps when disabled', (tester) async {
    var value = false;
    await tester.pumpWidget(
      _app(
        SossoldiTheme.light,
        SossoldiSwitch(value: value, onChanged: (v) => value = v),
      ),
    );
    await tester.tap(find.byType(SossoldiSwitch));
    expect(value, isTrue);

    await tester.pumpWidget(
      _app(
        SossoldiTheme.light,
        const SossoldiSwitch(value: false, onChanged: null),
      ),
    );
    await tester.tap(find.byType(SossoldiSwitch));
    expect(value, isTrue);
  });

  testWidgets('select opens, picks an option and closes', (tester) async {
    int? value;
    await tester.pumpWidget(
      _app(
        SossoldiTheme.light,
        StatefulBuilder(
          builder: (context, setState) => SossoldiSelect<int>(
            items: const [
              SossoldiSelectItem(value: 1, label: 'One'),
              SossoldiSelectItem(value: 2, label: 'Two'),
            ],
            value: value,
            placeholder: 'Select one',
            onChanged: (v) => setState(() => value = v),
          ),
        ),
      ),
    );
    expect(find.text('Two'), findsNothing);
    await tester.tap(find.text('Select one'));
    await tester.pump();
    // The options list is as wide as the field (320 in this test).
    expect(
      tester
          .getSize(
            find
                .ancestor(of: find.text('One'), matching: find.byType(Column))
                .last,
          )
          .width,
      lessThanOrEqualTo(320),
    );
    await tester.tap(find.text('Two'));
    await tester.pump();
    expect(value, 2);
    expect(find.text('One'), findsNothing);
    expect(find.text('Two'), findsOneWidget);
  });

  testWidgets('text input clear button empties the field', (tester) async {
    final controller = TextEditingController(text: 'abc');
    await tester.pumpWidget(
      _app(
        SossoldiTheme.light,
        SossoldiTextInput(controller: controller, clearSemanticLabel: 'Clear'),
      ),
    );
    await tester.tap(find.bySemanticsLabel('Clear'));
    await tester.pump();
    expect(controller.text, isEmpty);
    expect(find.bySemanticsLabel('Clear'), findsNothing);
  });

  testWidgets('tab navigation reports the tapped index', (tester) async {
    var index = 0;
    await tester.pumpWidget(
      _app(
        SossoldiTheme.light,
        SossoldiTabNavigation(
          tabs: const [SossoldiTabData.text('A'), SossoldiTabData.text('B')],
          selectedIndex: index,
          onChanged: (i) => index = i,
        ),
      ),
    );
    await tester.tap(find.text('B'));
    expect(index, 1);
  });
}
