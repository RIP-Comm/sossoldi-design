import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/dashboard/model/dashboard_layout.dart';
import 'package:sossoldi/features/dashboard/registry/dashboard_widget_definition.dart';
import 'package:sossoldi/features/dashboard/widgets/latest_transactions_widget.dart';
import 'package:sossoldi/features/dashboard/widgets/upcoming_recurring_widget.dart';
import 'package:sossoldi/l10n/l10n.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/transaction.dart';

final _now = DateTime(2026, 10, 22, 10);

Future<void> _pump(
  WidgetTester tester,
  Widget Function(DashboardWidgetInstance) build,
  String type,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    AppScope(
      state: AppState(repository: MockRepository(now: _now)),
      child: MaterialApp(
        theme: SossoldiTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 358,
              height: 358,
              child: build(DashboardWidgetInstance(settings: {'type': type})),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  test('the repository filters latest and upcoming by type', () {
    final repo = MockRepository(now: _now);
    for (final t in TransactionType.values) {
      expect(
        repo.latestTransactions(8, type: t).every((x) => x.type == t),
        isTrue,
      );
      expect(
        repo
            .upcomingRecurrences(includeToday: true, type: t)
            .every((o) => o.type == t),
        isTrue,
      );
    }
    expect(repo.latestTransactions(3), hasLength(3));
  });

  testWidgets('Latest transactions L: title, chip and only expenses', (
    tester,
  ) async {
    await _pump(
      tester,
      (i) => LatestTransactionsWidget(size: DashboardWidgetSize.l, instance: i),
      'expense',
    );
    expect(find.text('Latest transactions'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    final items = tester
        .widgetList<SossoldiTransactionItem>(
          find.byType(SossoldiTransactionItem),
        )
        .toList();
    expect(items, isNotEmpty);
    expect(items.every((i) => i.type == SossoldiTransactionType.expense), true);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Upcoming recurring: title and transfers only; empty text', (
    tester,
  ) async {
    await _pump(
      tester,
      (i) => UpcomingRecurringWidget(size: DashboardWidgetSize.m, instance: i),
      'transfer',
    );
    expect(find.text('Upcoming recurring'), findsOneWidget);
    expect(find.text('Transfers'), findsOneWidget);
    final items = tester.widgetList<SossoldiTransactionItem>(
      find.byType(SossoldiTransactionItem),
    );
    expect(
      items.every((i) => i.type == SossoldiTransactionType.transfer),
      true,
    );
    expect(tester.takeException(), isNull);
  });
}
