import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/design_system/design_system.dart';

Widget _app(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? SossoldiTheme.light,
  home: Scaffold(
    body: Center(child: SizedBox(width: 376, child: child)),
  ),
);

void main() {
  for (final (name, theme) in [
    ('light', SossoldiTheme.light),
    ('dark', SossoldiTheme.dark),
  ]) {
    testWidgets('overlay components render in $name', (tester) async {
      await tester.pumpWidget(
        _app(
          theme: theme,
          SingleChildScrollView(
            child: Column(
              children: [
                SossoldiBottomSheet(
                  toolbar: SossoldiBottomSheetToolbar.text(
                    title: 'Title',
                    onClose: () {},
                    closeLabel: 'Cancel',
                    onConfirm: () {},
                    confirmLabel: 'Done',
                  ),
                  child: const SizedBox(height: 40),
                ),
                const SossoldiModal(child: SizedBox(height: 40)),
                const SossoldiSnackbar(title: 'Info', description: 'Text'),
                const SossoldiAlert(title: 'Title', message: 'Message'),
                const SossoldiLoader(),
                const SossoldiProgressCircular(value: 0.3),
                const SossoldiProgressLinear(value: 0.3),
                const SossoldiAccordion(title: 'A', child: Text('Body')),
                SossoldiDropdown(
                  options: [SossoldiMenuItem(label: 'One', onTap: () {})],
                ),
                const SossoldiSearchField(
                  placeholder: 'Search',
                  clearSemanticLabel: 'Clear',
                ),
                const SossoldiAuthCode(),
              ],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('accordion toggles its content', (tester) async {
    await tester.pumpWidget(
      _app(const SossoldiAccordion(title: 'Title', child: Text('Body'))),
    );
    expect(find.text('Body'), findsNothing);
    await tester.tap(find.text('Title'));
    await tester.pumpAndSettle();
    expect(find.text('Body'), findsOneWidget);
  });

  testWidgets('auth code reports the full code once complete', (tester) async {
    String? code;
    await tester.pumpWidget(
      _app(SossoldiAuthCode(onCompleted: (c) => code = c)),
    );
    await tester.enterText(find.byType(TextField), '12a3');
    expect(code, isNull);
    await tester.enterText(find.byType(TextField), '1234');
    await tester.pump();
    expect(code, '1234');
    expect(find.text('•'), findsNWidgets(4));
  });

  testWidgets('search shows results while focused and reports taps', (
    tester,
  ) async {
    int? tapped;
    await tester.pumpWidget(
      _app(
        SossoldiSearchField(
          placeholder: 'Search',
          clearSemanticLabel: 'Clear',
          results: const ['Rent', 'Gym'],
          onResultTap: (i) => tapped = i,
        ),
      ),
    );
    expect(find.text('Gym'), findsNothing);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(find.text('Gym'), findsOneWidget);
    await tester.tap(find.text('Gym'));
    await tester.pump();
    expect(tapped, 1);
  });

  testWidgets('bottom sheet and modal open over the page', (tester) async {
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Column(
            children: [
              SossoldiButton(
                label: 'Sheet',
                onPressed: () => showSossoldiBottomSheet<void>(
                  context: context,
                  builder: (_) => const Text('Sheet body'),
                ),
              ),
              SossoldiButton(
                label: 'Modal',
                onPressed: () => showSossoldiModal<void>(
                  context: context,
                  builder: (_) => const Text('Modal body'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Sheet'));
    await tester.pumpAndSettle();
    expect(find.text('Sheet body'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Modal'));
    await tester.pumpAndSettle();
    expect(find.text('Modal body'), findsOneWidget);
  });
}
