import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/app/app.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/accounts/account_detail_screen.dart';
import 'package:sossoldi/features/accounts/accounts_screen.dart';
import 'package:sossoldi/features/dashboard/model/default_dashboard_layout.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/account_edit.dart';
import 'package:sossoldi/mock/models/transaction.dart';
import 'package:sossoldi/mock/models/transaction_edit.dart';

import '../../load_test_fonts.dart';

final _now = DateTime(2026, 10, 22, 10);

AccountDraft _draft(
  String name, {
  double amount = 100,
  String currency = 'EUR',
}) => AccountDraft(
  name: name,
  initialBalance: amount,
  currency: currency,
  color: CategoryColors.all[3],
  icon: PhosphorIconsRegular.bank,
);

/// Opens Settings > Accounts on [state]'s repository.
Future<void> _open(
  WidgetTester tester,
  AppState state, {
  String locale = 'en',
  bool dark = false,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.localeTestValue = Locale(locale);
  tester.platformDispatcher.localesTestValue = [Locale(locale)];
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearAllTestValues();
  });
  if (dark) state.setDarkMode(true);
  await tester.pumpWidget(SossoldiApp(state: state));
  await tester.pump();
  await tester.tap(
    find.byWidgetPredicate(
      (w) =>
          w is SossoldiHeaderButton &&
          (w.semanticLabel == 'Settings' || w.semanticLabel == 'Impostazioni'),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(
    find.text(locale == 'en' ? 'App settings' : 'Impostazioni app'),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(locale == 'en' ? 'Accounts' : 'Conti'));
  await tester.pumpAndSettle();
}

AppState _demo() => AppState(repository: MockRepository(now: _now));

void main() {
  setUp(() => startDashboardLayout = singleWidgetDashboardLayout);
  tearDown(() => startDashboardLayout = defaultDashboardLayout);
  setUpAll(loadTestFonts);

  testWidgets('the list: one row per account, main tag, chevrons, order', (
    tester,
  ) async {
    final state = _demo();
    await _open(tester, state);
    expect(find.byType(AccountsScreen), findsOneWidget);
    final rows = find.byType(SossoldiAccountItem);
    expect(rows, findsNWidgets(3));
    expect(find.byIcon(PhosphorIconsRegular.caretRight), findsNWidgets(3));
    expect(find.text('Main'), findsOneWidget);
    // A tag with a stroke, so it reads as a tag.
    expect(
      tester
          .widget<SossoldiTag>(find.widgetWithText(SossoldiTag, 'Main'))
          .hasStroke,
      isTrue,
    );
    expect(find.text('Add account'), findsOneWidget);
    // The order is the repository's.
    final expected = [
      for (final a in state.repository.accountsByBalance()) a.account.name,
    ];
    final shown = [
      for (final w in tester.widgetList<SossoldiAccountItem>(rows)) w.name,
    ];
    expect(shown, expected);
    expect(
      tester
          .widgetList<SossoldiAccountItem>(rows)
          .every((w) => w.variation == null),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a tap opens the page of the account, back returns to the list', (
    tester,
  ) async {
    final state = _demo();
    await _open(tester, state);
    await tester.tap(find.text('Everyday account'));
    await tester.pumpAndSettle();
    expect(find.byType(AccountDetailScreen), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.byType(SossoldiTrendChart), findsOneWidget);
    // The history of this account is about six months: it opens on All.
    expect(find.text('All'), findsOneWidget);
    expect(find.text('YTD'), findsNothing);
    expect(find.byType(SossoldiSearchField), findsOneWidget);
    // No date filter by default: no chip, and more than one page.
    expect(find.byType(SossoldiFilterChip), findsNothing);
    expect(find.byType(SossoldiPagination), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byIcon(PhosphorIconsRegular.caretLeft).first);
    await tester.pumpAndSettle();
    expect(find.byType(AccountsScreen), findsOneWidget);
  });

  testWidgets(
    'the period chip changes the chart; unavailable ones are disabled',
    (tester) async {
      final state = _demo();
      await _open(tester, state);
      await tester.tap(find.text('Everyday account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      // The history of this account is about six months: 5Y is dimmed.
      final fiveYears = tester.widget<SossoldiMenuItem>(
        find.widgetWithText(SossoldiMenuItem, '5Y'),
      );
      expect(fiveYears.enabled, isFalse);
      // Year to date is not covered either, and it is not the default.
      expect(
        tester
            .widget<SossoldiMenuItem>(
              find.widgetWithText(SossoldiMenuItem, 'YTD'),
            )
            .enabled,
        isFalse,
      );
      await tester.tap(find.text('3M').last);
      await tester.pumpAndSettle();
      expect(find.text('3M'), findsOneWidget);
      expect(find.text('All'), findsNothing);
    },
  );

  testWidgets('the search and the filters are those of the page', (
    tester,
  ) async {
    final state = _demo();
    await _open(tester, state);
    await tester.tap(find.text('Everyday account'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).first, 'zzzzzz');
    await tester.pumpAndSettle();
    expect(find.text('No transactions found'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.text('No transactions found'), findsNothing);
    // The filters sheet has no account section: the account is fixed.
    await tester.tap(find.bySemanticsLabel('Filters'));
    await tester.pumpAndSettle();
    expect(find.text('Type'), findsOneWidget);
    expect(find.text('Account'), findsNothing);
  });

  testWidgets('edit opens the form; a change shows on the page', (
    tester,
  ) async {
    final state = AppState(repository: MockRepository.newUser(now: _now));
    state.repository.addAccount(_draft('Cash', amount: 40));
    await _open(tester, state);
    await tester.tap(find.text('Cash'));
    await tester.pumpAndSettle();
    expect(find.text('Not enough history yet'), findsOneWidget);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit account'), findsOneWidget);
    final id = state.repository.accounts.single.id;
    state.repository.updateAccount(id, _draft('Wallet', amount: 40));
    await tester.pumpAndSettle();
    // Close the form with the X and look at the page.
    await tester.tap(find.byIcon(PhosphorIconsRegular.x));
    await tester.pumpAndSettle();
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Cash'), findsNothing);
  });

  testWidgets('deleting the account closes its page, back to the list', (
    tester,
  ) async {
    final state = AppState(repository: MockRepository.newUser(now: _now));
    state.repository.addAccount(_draft('Cash'));
    state.repository.addAccount(_draft('Bank', amount: 5));
    await _open(tester, state);
    await tester.tap(find.text('Cash'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Delete account'));
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(AccountDetailScreen), findsNothing);
    expect(find.byType(AccountsScreen), findsOneWidget);
    expect(find.text('Cash'), findsNothing);
    expect(find.text('Bank'), findsOneWidget);
  });

  testWidgets('an account used by transactions cannot be deleted', (
    tester,
  ) async {
    final state = _demo();
    await _open(tester, state);
    await tester.tap(find.text('Everyday account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Delete account'));
    await tester.tap(find.text('Delete account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete').last);
    await tester.pumpAndSettle();
    expect(
      state.repository.accounts.any((a) => a.name == 'Everyday account'),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('an account deleted while its page is open closes it quietly', (
    tester,
  ) async {
    final state = AppState(repository: MockRepository.newUser(now: _now));
    state.repository.addAccount(_draft('Cash'));
    state.repository.addAccount(_draft('Bank', amount: 5));
    await _open(tester, state);
    await tester.tap(find.text('Cash'));
    await tester.pumpAndSettle();
    final id = state.repository.accounts.first.id;
    state.repository.deleteAccount(id);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(AccountDetailScreen), findsNothing);
    expect(find.byType(AccountsScreen), findsOneWidget);
  });

  testWidgets('no account: a neutral empty state and the add link', (
    tester,
  ) async {
    await _open(
      tester,
      AppState(repository: MockRepository.newUser(now: _now)),
    );
    expect(find.text('No accounts yet'), findsOneWidget);
    expect(find.text('Add account'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Add account'));
    await tester.pumpAndSettle();
    expect(find.text('New account'), findsOneWidget);
  });

  testWidgets('a cross-currency transfer shows what moved each account', (
    tester,
  ) async {
    final repo = MockRepository.newUser(now: _now);
    final eur = repo.addAccount(_draft('Euro', amount: 1000)).account!.id;
    final usd = repo
        .addAccount(_draft('Dollars', amount: 0, currency: 'USD'))
        .account!
        .id;
    repo.addTransaction(
      TransactionDraft(
        type: TransactionType.transfer,
        amount: 100,
        accountId: eur,
        toAccountId: usd,
        toAmount: 111,
        date: DateTime(2026, 10, 20),
      ),
    );
    final state = AppState(repository: repo);
    await _open(tester, state);
    await tester.tap(find.text('Dollars'));
    await tester.pumpAndSettle();
    final item = tester.widget<SossoldiTransactionItem>(
      find.byType(SossoldiTransactionItem),
    );
    expect(item.amount, 111);
    expect(item.currencyCode, 'USD');
    await tester.tap(find.byIcon(PhosphorIconsRegular.caretLeft));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Euro'));
    await tester.pumpAndSettle();
    final out = tester.widget<SossoldiTransactionItem>(
      find.byType(SossoldiTransactionItem),
    );
    expect(out.amount, 100);
    expect(out.currencyCode, 'EUR');
  });

  testWidgets('Hidden Mode masks the balances on the list and the page', (
    tester,
  ) async {
    final state = _demo()..toggleHideAmounts();
    await _open(tester, state);
    expect(find.text('••••'), findsWidgets);
    expect(find.textContaining('€'), findsNothing);
    await tester.tap(find.text('Everyday account'));
    await tester.pumpAndSettle();
    expect(find.text('••••'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  for (final dark in [false, true]) {
    testWidgets('long names, Italian, ${dark ? 'dark' : 'light'}', (
      tester,
    ) async {
      final repo = MockRepository.newUser(now: _now);
      repo.addAccount(
        _draft(
          'Un conto con un nome davvero molto molto lungo per vedere se va a capo',
          amount: -1234567.89,
        ),
      );
      repo.addAccount(_draft('Dollari', amount: 20, currency: 'USD'));
      await _open(
        tester,
        AppState(repository: repo),
        locale: 'it',
        dark: dark,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Principale'), findsOneWidget);
      await tester.tap(find.textContaining('Un conto con'));
      await tester.pumpAndSettle();
      expect(find.text('Modifica'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the main currency changes the order and the list follows', (
    tester,
  ) async {
    final state = _demo();
    await _open(tester, state);
    state.setMainCurrency('USD');
    await tester.pumpAndSettle();
    final shown = [
      for (final w in tester.widgetList<SossoldiAccountItem>(
        find.byType(SossoldiAccountItem),
      ))
        w.name,
    ];
    expect(shown, [
      for (final a in state.repository.accountsByBalance()) a.account.name,
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Manage of the Finance Overview opens the Accounts page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.localeTestValue = const Locale('en');
    tester.platformDispatcher.localesTestValue = [const Locale('en')];
    addTearDown(() {
      tester.view.reset();
      tester.platformDispatcher.clearAllTestValues();
    });
    await tester.pumpWidget(SossoldiApp(state: _demo()));
    await tester.pump();
    await tester.tap(find.text('Finance'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Manage').first);
    await tester.tap(find.text('Manage').first);
    await tester.pumpAndSettle();
    expect(find.byType(AccountsScreen), findsOneWidget);
    await tester.tap(find.byIcon(PhosphorIconsRegular.arrowLeft));
    await tester.pumpAndSettle();
    expect(find.byType(AccountsScreen), findsNothing);
    expect(find.text('Finance'), findsWidgets);
  });

  testWidgets('a tap on an account of the Finance Overview opens its page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.localeTestValue = const Locale('en');
    tester.platformDispatcher.localesTestValue = [const Locale('en')];
    addTearDown(() {
      tester.view.reset();
      tester.platformDispatcher.clearAllTestValues();
    });
    await tester.pumpWidget(SossoldiApp(state: _demo()));
    await tester.pump();
    await tester.tap(find.text('Finance'));
    await tester.pumpAndSettle();
    final row = find.widgetWithText(SossoldiAccountItem, 'Everyday account');
    await tester.ensureVisible(row);
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(find.byType(AccountDetailScreen), findsOneWidget);
    expect(find.byType(SossoldiTrendChart), findsOneWidget);
    expect(tester.takeException(), isNull);
    // Back returns to the Overview.
    await tester.tap(find.byIcon(PhosphorIconsRegular.caretLeft).first);
    await tester.pumpAndSettle();
    expect(find.byType(AccountDetailScreen), findsNothing);
    expect(
      find.widgetWithText(SossoldiAccountItem, 'Everyday account'),
      findsOneWidget,
    );
  });
}
