import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/dashboard/model/default_dashboard_layout.dart';
import 'package:sossoldi/features/finance/recurring/recurring_detail_screen.dart';
import 'package:sossoldi/features/transactions/transaction_detail_screen.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/transaction.dart';

import '../../load_test_fonts.dart';

final _now = DateTime(2026, 10, 22, 10);

Future<void> _open(
  WidgetTester tester,
  AppState state,
  String id, {
  bool dark = false,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  if (dark) state.setDarkMode(true);
  await tester.pumpWidget(SossoldiApp(state: state));
  await tester.pump();
  Navigator.of(tester.element(find.byType(Scaffold).first))
      .push(TransactionDetailScreen.route(id));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => startDashboardLayout = singleWidgetDashboardLayout);
  tearDown(() => startDashboardLayout = defaultDashboardLayout);
  setUpAll(loadTestFonts);

  for (final dark in [false, true]) {
    testWidgets('shows description, account and Edit (dark: $dark)', (
      tester,
    ) async {
      final state = AppState(repository: MockRepository(now: _now));
      final repo = state.repository;
      final t = repo.latestTransactions(1).first;
      await _open(tester, state, t.id, dark: dark);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      if (t.description.trim().isNotEmpty) {
        expect(find.text(t.description), findsOneWidget);
      }
      expect(find.textContaining(repo.account(t.accountId).name), findsWidgets);
    });
  }

  testWidgets('a transfer shows both accounts', (tester) async {
    final state = AppState(repository: MockRepository(now: _now));
    final repo = state.repository;
    final t = repo
        .transactionsInPeriod(DateTime(2026, 1, 1), _now)
        .firstWhere((t) => t.type == TransactionType.transfer);
    await _open(tester, state, t.id);
    expect(
      find.text(
        '${repo.account(t.accountId).name} → '
        '${repo.account(t.toAccountId!).name}',
      ),
      findsOneWidget,
    );
  });

  Transaction recurringOne(MockRepository repo) => repo.transactions.firstWhere(
    (t) => t.recurringId != null && repo.recurringOrNull(t.recurringId) != null,
  );

  testWidgets('a recurring one shows the chip and the button to its page', (
    tester,
  ) async {
    final state = AppState(repository: MockRepository(now: _now));
    final t = recurringOne(state.repository);
    await _open(tester, state, t.id);
    expect(find.byType(SossoldiChip), findsOneWidget);
    await tester.tap(find.text('Show recurrence'));
    await tester.pumpAndSettle();
    expect(find.byType(RecurringDetailScreen), findsOneWidget);
  });

  testWidgets('a normal one has no chip and Edit opens the form at once', (
    tester,
  ) async {
    final state = AppState(repository: MockRepository(now: _now));
    final t = state.repository.transactions.firstWhere(
      (t) => t.recurringId == null && t.type == TransactionType.expense,
    );
    await _open(tester, state, t.id);
    expect(find.byType(SossoldiChip), findsNothing);
    // The receipt is as wide as the page, with a short content too.
    expect(tester.getSize(find.byType(SossoldiReceipt)).width, 390 - 32);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit transaction'), findsOneWidget);
  });

  testWidgets('a recurring one: Edit is a dropdown; "the recurrence" opens '
      'its page', (tester) async {
    final state = AppState(repository: MockRepository(now: _now));
    final t = recurringOne(state.repository);
    await _open(tester, state, t.id);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Only this transaction'), findsOneWidget);
    await tester.tap(find.text('The recurrence (next ones)'));
    await tester.pumpAndSettle();
    expect(find.byType(RecurringDetailScreen), findsOneWidget);
  });

  testWidgets('"only this" edits the single one; the new amount shows', (
    tester,
  ) async {
    final state = AppState(repository: MockRepository(now: _now));
    final repo = state.repository;
    final t = recurringOne(repo);
    await _open(tester, state, t.id);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Only this transaction'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, '77,5');
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Save transaction'));
    await tester.pumpAndSettle();
    expect(repo.transaction(t.id).amount, 77.5);
    expect(repo.transaction(t.id).recurringId, t.recurringId);
    expect(find.text('Transaction updated'), findsOneWidget);
  });

  testWidgets('Delete asks first, then removes it and closes the page', (
    tester,
  ) async {
    final state = AppState(repository: MockRepository(now: _now));
    final repo = state.repository;
    final t = repo.transactions.firstWhere(
      (t) => t.recurringId == null && t.type == TransactionType.expense,
    );
    final count = repo.transactions.length;
    await _open(tester, state, t.id);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Delete transaction'),
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('Delete transaction'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this transaction?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(repo.transactions.length, count - 1);
    expect(find.byType(TransactionDetailScreen), findsNothing);
  });
}
