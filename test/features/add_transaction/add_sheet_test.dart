import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/account_edit.dart';
import 'package:sossoldi/mock/models/category_edit.dart';
import 'package:sossoldi/mock/models/category.dart';

import '../../load_test_fonts.dart';

final _now = DateTime(2026, 10, 22, 10);

Future<MockRepository> _pump(
  WidgetTester tester, {
  MockRepository? repository,
  String locale = 'en',
  bool dark = false,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.localeTestValue = Locale(locale);
  tester.platformDispatcher.localesTestValue = [Locale(locale)];
  if (dark) {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
  }
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearAllTestValues();
  });
  final repo = repository ?? MockRepository(now: _now);
  await tester.pumpWidget(SossoldiApp(state: AppState(repository: repo)));
  await tester.pump();
  return repo;
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.bySemanticsLabel('Add transaction'));
  await tester.pumpAndSettle();
}

/// The check of the toolbar of the sheet.
Finder _confirm() => find.descendant(
  of: find.byType(SossoldiBottomSheetToolbar),
  matching: find.byIcon(PhosphorIconsRegular.check),
);

bool _confirmEnabled(WidgetTester tester) => tester
    .widget<SossoldiBottomSheetToolbar>(find.byType(SossoldiBottomSheetToolbar))
    .confirmEnabled;

Finder _amount() => find.descendant(
  of: find.byType(SossoldiAmountInput),
  matching: find.byType(TextField),
);

void main() {
  setUpAll(loadTestFonts);

  testWidgets(
    'an expense: amount, category, Add; it shows everywhere and Undo takes it back',
    (tester) async {
      final repo = await _pump(tester);
      final balance = repo.accountBalance(repo.mainAccount!.id);
      final count = repo.transactions.length;
      await _open(tester);
      expect(find.text('New transaction'), findsOneWidget);
      // The amount has the focus and the fixed minus.
      expect(find.text('−'), findsOneWidget);
      await tester.enterText(_amount(), '12,50');
      await tester.pump();
      // The check stays off until a category is chosen.
      expect(_confirmEnabled(tester), isFalse);
      final first = repo.categoriesByUsage(CategoryType.expense).first;
      await tester.tap(find.widgetWithText(SossoldiUnitNavigator, first.name));
      await tester.pump();
      await tester.tap(_confirm());
      await tester.pumpAndSettle();
      expect(find.text('New transaction'), findsNothing);
      expect(repo.transactions, hasLength(count + 1));
      expect(repo.accountBalance(repo.mainAccount!.id), balance - 12.5);
      expect(repo.transactions.first.categoryId, first.id);
      expect(find.text('Transaction added'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(repo.transactions, hasLength(count));
      expect(repo.accountBalance(repo.mainAccount!.id), balance);
    },
  );

  testWidgets('the title menu switches to the movement form and back', (
    tester,
  ) async {
    await _pump(tester);
    await _open(tester);
    await tester.tap(find.text('New transaction'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Investment movement'));
    await tester.pumpAndSettle();
    expect(find.text('New movement'), findsOneWidget);
    expect(find.text('Add and create another'), findsNothing);
    await tester.tap(find.text('New movement'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Transaction'));
    await tester.pumpAndSettle();
    expect(find.text('New transaction'), findsOneWidget);
  });

  AccountDraft draftOf(String name, String currency) => AccountDraft(
    name: name,
    initialBalance: 1000,
    currency: currency,
    color: CategoryColors.all[3],
    icon: PhosphorIconsRegular.bank,
  );

  testWidgets(
    'a transfer between currencies proposes the amount received and keeps it',
    (tester) async {
      final repo = MockRepository.newUser(now: _now);
      final eur = repo.addAccount(draftOf('Euros', 'EUR')).account!;
      final usd = repo.addAccount(draftOf('Dollars', 'USD')).account!;
      await _pump(tester, repository: repo);
      await _open(tester);
      await tester.tap(find.text('Transfer'));
      await tester.pump();
      expect(find.text('From'), findsOneWidget);
      expect(find.text('Amount received'), findsOneWidget);
      await tester.enterText(_amount(), '100');
      await tester.pump();
      final proposed = repo.convert(100, 'EUR', 'USD');
      final received = find.descendant(
        of: find.widgetWithText(SossoldiTextInput, 'Amount received'),
        matching: find.byType(TextField),
      );
      expect(
        double.parse(tester.widget<TextField>(received).controller!.text),
        proposed,
      );
      // The user changes the amount received: it is kept.
      await tester.enterText(received, '120');
      await tester.pump();
      await tester.tap(_confirm());
      await tester.pumpAndSettle();
      expect(repo.accountBalance(eur.id), 900);
      expect(repo.accountBalance(usd.id), 1120);
    },
  );

  testWidgets('swapping From and To', (tester) async {
    final repo = MockRepository.newUser(now: _now);
    final a = repo.addAccount(draftOf('Alpha', 'EUR')).account!;
    final b = repo.addAccount(draftOf('Beta', 'EUR')).account!;
    await _pump(tester, repository: repo);
    await _open(tester);
    await tester.tap(find.text('Transfer'));
    await tester.pump();
    await tester.enterText(_amount(), '30');
    await tester.tap(find.bySemanticsLabel('Swap accounts'));
    await tester.pump();
    await tester.tap(_confirm());
    await tester.pumpAndSettle();
    expect(repo.accountBalance(b.id), 970);
    expect(repo.accountBalance(a.id), 1030);
  });

  testWidgets('a new user with a single account cannot transfer', (
    tester,
  ) async {
    final repo = MockRepository.newUser(now: _now);
    repo.addAccount(draftOf('Only', 'EUR'));
    await _pump(tester, repository: repo);
    await _open(tester);
    // No categories either: the form says so.
    expect(find.text('You have no expense categories yet.'), findsOneWidget);
    await tester.tap(find.text('Transfer'));
    await tester.pump();
    expect(
      find.text('To make a transfer you need at least two accounts.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'a recurring expense from a future date plans it without a transaction',
    (tester) async {
      final repo = MockRepository.newUser(now: _now);
      repo.addAccount(draftOf('Only', 'EUR'));
      repo.addCategory(
        CategorySave(
          category: CategoryDraft(
            type: CategoryType.expense,
            name: 'Rent',
            icon: PhosphorIconsRegular.house,
            color: CategoryColors.all.first,
          ),
        ),
      );
      await _pump(tester, repository: repo);
      await _open(tester);
      await tester.enterText(_amount(), '800');
      await tester.tap(find.widgetWithText(SossoldiUnitNavigator, 'Rent'));
      await tester.pump();
      await tester.ensureVisible(find.byType(SossoldiSwitch));
      await tester.tap(find.byType(SossoldiSwitch));
      await tester.pump();
      expect(find.text('Frequency'), findsOneWidget);
      expect(find.text('Start date'), findsOneWidget);
      await tester.tap(_confirm());
      await tester.pumpAndSettle();
      // Starts today: the recurrence and the first transaction.
      expect(repo.recurringTransactions(), hasLength(1));
      expect(repo.transactions, hasLength(1));
    },
  );

  testWidgets('Italian and dark: long names and big amounts do not overflow', (
    tester,
  ) async {
    await _pump(tester, locale: 'it', dark: true);
    await tester.tap(find.bySemanticsLabel('Aggiungi transazione'));
    await tester.pumpAndSettle();
    expect(find.text('Nuova transazione'), findsOneWidget);
    await tester.enterText(_amount(), '123456789,99');
    await tester.pump();
    await tester.tap(find.text('Trasferimento'));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
