import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/app/app.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/account_edit.dart';
import 'package:sossoldi/mock/models/budget.dart';
import 'package:sossoldi/mock/models/category.dart';
import 'package:sossoldi/mock/models/category_edit.dart';

import '../load_test_fonts.dart';

final _now = DateTime(2026, 10, 22, 10);

/// A new user as the onboarding leaves it.
MockRepository _newUser({
  bool categories = true,
  bool asset = true,
  bool accounts = true,
}) {
  final repo = MockRepository.newUser(now: _now);
  if (accounts) {
    for (final (name, balance) in [('Checking', 1200.0), ('Savings', 0.0)]) {
      repo.addAccount(
        AccountDraft(
          name: name,
          initialBalance: balance,
          currency: 'EUR',
          color: CategoryColors.all.first,
          icon: PhosphorIconsRegular.bank,
        ),
      );
    }
  }
  if (categories) {
    repo.addCategory(
      CategorySave(
        category: CategoryDraft(
          type: CategoryType.expense,
          name: 'Housing',
          icon: PhosphorIconsRegular.house,
          color: CategoryColors.all[3],
        ),
        subcategories: const [SubcategoryDraft(name: 'Rent')],
        budgets: const [
          BudgetDraft(period: BudgetPeriod.monthly, amount: 500),
          BudgetDraft(period: BudgetPeriod.weekly, amount: 100),
        ],
      ),
    );
    repo.addCategory(
      CategorySave(
        category: CategoryDraft(
          type: CategoryType.income,
          name: 'Work',
          icon: PhosphorIconsRegular.suitcase,
          color: CategoryColors.all[13],
        ),
      ),
    );
  }
  if (asset) {
    repo.addOpeningAsset(
      assetId: repo.assetCatalog.first.id,
      quantity: 10,
      averageCost: 50,
    );
    repo.addOpeningAsset(manualName: 'Watch', quantity: 1, averageCost: 900);
  }
  return repo;
}

Future<AppState> _open(
  WidgetTester tester,
  MockRepository repo, {
  Brightness? brightness,
}) async {
  tester.view.physicalSize = const Size(390, 2600);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.localeTestValue = const Locale('en');
  tester.platformDispatcher.localesTestValue = const [Locale('en')];
  if (brightness != null) {
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
  }
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearAllTestValues();
  });
  final state = AppState(repository: repo);
  addTearDown(state.dispose);
  await tester.pumpWidget(SossoldiApp(state: state));
  await tester.pumpAndSettle();
  return state;
}

/// Every text on screen: none may be a broken number.
void _noBrokenNumbers(WidgetTester tester, String where) {
  final texts = [
    for (final e in find.byType(Text).evaluate()) ?(e.widget as Text).data,
  ];
  if (const bool.fromEnvironment('DUMP')) {
    // ignore: avoid_print
    print('--- $where: ${texts.join(' | ')}');
  }
  for (final t in texts) {
    expect(
      RegExp(r'NaN|Infinity|null|-0[,.]0|^-0$').hasMatch(t),
      isFalse,
      reason: '"$t" on $where',
    );
  }
}

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text).first);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: 'after tapping $text');
  _noBrokenNumbers(tester, text);
}

/// Opens every tab and sub-tab of the app.
Future<void> _walk(WidgetTester tester) async {
  expect(tester.takeException(), isNull, reason: 'Home');
  _noBrokenNumbers(tester, 'Home');
  // Settings and back.
  await tester.tap(find.byIcon(PhosphorIconsRegular.gearSix));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: 'Settings');
  // Settings > App settings > Accounts, and the page of an account if any.
  await tester.tap(find.text('App settings'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Accounts'));
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: 'Accounts');
  _noBrokenNumbers(tester, 'Accounts');
  var back = 3;
  final rows = find.byType(SossoldiAccountItem);
  if (rows.evaluate().isNotEmpty) {
    await tester.tap(rows.first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'Account page');
    _noBrokenNumbers(tester, 'Account page');
    back = 4;
  }
  for (var i = 0; i < back; i++) {
    await tester.tap(
      find
          .byIcon(
            i == 0 && back == 4
                ? PhosphorIconsRegular.caretLeft
                : PhosphorIconsRegular.arrowLeft,
          )
          .first,
    );
    await tester.pumpAndSettle();
  }

  await _tap(tester, 'Finance');
  for (final t in ['Overview', 'Transactions', 'Budget', 'Recurring']) {
    await _tap(tester, t);
    if (t == 'Transactions') {
      for (final v in ['Charts', 'List']) {
        await _tap(tester, v);
      }
    }
  }
  await _tap(tester, 'Investments');
  for (final t in ['Overview', 'Positions', 'Movements']) {
    await _tap(tester, t);
  }
  // Add transaction: the placeholder (the bar's "+" in Investments opens the
  // movement form).
  await _tap(tester, 'Home');
  await tester.tap(find.byIcon(PhosphorIconsRegular.plus).last);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: 'Add transaction');
}

void main() {
  setUpAll(loadTestFonts);

  for (final brightness in Brightness.values) {
    testWidgets('a new user with accounts, categories and assets: every '
        'screen opens ($brightness)', (tester) async {
      final repo = _newUser();
      await _open(tester, repo, brightness: brightness);
      await _walk(tester);
    });
  }

  testWidgets('a new user with accounts only', (tester) async {
    await _open(tester, _newUser(categories: false, asset: false));
    await _walk(tester);
  });

  testWidgets('a new user with nothing at all', (tester) async {
    await _open(
      tester,
      _newUser(accounts: false, categories: false, asset: false),
    );
    await _walk(tester);
  });
}
