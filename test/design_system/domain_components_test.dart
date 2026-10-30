import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/design_system/design_system.dart';

Widget _app(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? SossoldiTheme.light,
  home: Scaffold(
    body: Center(child: SizedBox(width: 358, child: child)),
  ),
);

Color? _colorOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style?.color;

void main() {
  testWidgets(
    'a transaction row without description is as tall as one with it',
    (tester) async {
      Widget item(String description) => SossoldiTransactionItem(
        type: SossoldiTransactionType.expense,
        leading: const SizedBox(),
        description: description,
        account: 'Main',
        amount: 10,
        currencyCode: 'EUR',
      );
      await tester.pumpWidget(
        _app(Column(children: [item('Groceries'), item('')])),
      );
      final rows = find.byType(SossoldiTransactionItem);
      expect(
        tester.getSize(rows.at(0)).height,
        tester.getSize(rows.at(1)).height,
      );
    },
  );

  testWidgets('amount formats with the locale and colors by sign', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SossoldiTheme.light,
        locale: const Locale('it'),
        supportedLocales: const [Locale('it')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const Column(
          children: [
            SossoldiAmount(
              value: -1000.2,
              currencyCode: 'EUR',
              tone: SossoldiAmountTone.signed,
            ),
            SossoldiAmount(
              value: 5,
              currencyCode: 'EUR',
              tone: SossoldiAmountTone.signed,
            ),
            SossoldiAmount(value: 5, currencyCode: 'EUR', masked: true),
          ],
        ),
      ),
    );
    final colors = SossoldiColors.light;
    expect(find.text('-1.000,20\u00a0€'), findsOneWidget);
    expect(_colorOf(tester, '-1.000,20\u00a0€'), colors.expense.text);
    expect(_colorOf(tester, '5,00\u00a0€'), colors.income.text);
    expect(find.text('••••'), findsOneWidget);
  });

  testWidgets('transaction item signs the amount by type', (tester) async {
    await tester.pumpWidget(
      _app(
        const Column(
          children: [
            SossoldiTransactionItem(
              type: SossoldiTransactionType.expense,
              leading: SizedBox(),
              description: 'Groceries',
              account: 'Main',
              amount: 10,
              currencyCode: 'EUR',
            ),
            SossoldiTransactionItem(
              type: SossoldiTransactionType.transfer,
              leading: SizedBox(),
              description: 'Savings',
              account: 'Main',
              toAccount: 'Savings',
              amount: 20,
              currencyCode: 'EUR',
              recurrenceLabel: '31 May',
            ),
          ],
        ),
      ),
    );
    expect(find.text('-€10.00'), findsOneWidget);
    expect(_colorOf(tester, '€20.00'), SossoldiColors.light.primary.text);
    expect(find.text('31 May'), findsOneWidget);
  });

  testWidgets('category expands and collapses its subcategories', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const SossoldiCategoryItem(
          name: 'Housing',
          leading: SizedBox(),
          subcategories: [
            SossoldiSubcategory(name: 'Rent', leading: SizedBox()),
          ],
        ),
      ),
    );
    expect(find.text('Rent'), findsNothing);
    await tester.tap(find.text('Housing'));
    await tester.pumpAndSettle();
    expect(find.text('Rent'), findsOneWidget);
    await tester.tap(find.text('Housing'));
    await tester.pumpAndSettle();
    expect(find.text('Rent'), findsNothing);
  });

  for (final (name, theme) in [
    ('light', SossoldiTheme.light),
    ('dark', SossoldiTheme.dark),
  ]) {
    testWidgets('domain components render in $name', (tester) async {
      await tester.pumpWidget(
        _app(
          theme: theme,
          Column(
            children: [
              const SossoldiAvatar.initials(
                initials: 'dn',
                badge: SossoldiAvatarBadge.bottomRight,
              ),
              const SossoldiAccountItem(
                name: 'Main',
                balance: 1000,
                currencyCode: 'EUR',
                variation: -20,
                hasStroke: true,
              ),
              const SossoldiAssetItem(
                name: 'Vanguard',
                typeLabel: 'etf',
                identifier: 'VWCE',
                chart: SossoldiRightChart(
                  points: [1, 3, 2, 4],
                  value: 100,
                  currencyCode: 'EUR',
                  change: -0.01,
                ),
              ),
              SossoldiListAddButton(label: 'Add', onPressed: () {}),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('DN'), findsOneWidget);
      expect(find.text('ETF'), findsOneWidget);
    });
  }
}
