import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_shell_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/dashboard/model/dashboard_layout.dart';
import 'package:sossoldi/features/dashboard/model/default_dashboard_layout.dart';
import 'package:sossoldi/features/dashboard/registry/dashboard_widget_definition.dart';
import 'package:sossoldi/features/dashboard/registry/dashboard_widget_ids.dart';
import 'package:sossoldi/features/dashboard/registry/dashboard_widget_registry.dart';
import 'package:sossoldi/features/dashboard/widgets/budget_status_card.dart';
import 'package:sossoldi/features/dashboard/widgets/insight_widget.dart';
import 'package:sossoldi/features/finance/budget/budget_detail_screen.dart';
import 'package:sossoldi/l10n/l10n.dart';
import 'package:sossoldi/mock/data/account_data.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/budget.dart';
import 'package:sossoldi/mock/models/transaction.dart';

final _morning = DateTime(2026, 10, 22, 10);

Transaction _tx(
  int daysAgo,
  double amount, {
  String category = 'cat_groceries',
}) => Transaction(
  id: 'tx_w_$daysAgo$amount',
  type: TransactionType.expense,
  amount: amount,
  currency: 'EUR',
  date: DateTime(2026, 10, 22 - daysAgo),
  description: 'test',
  accountId: checkingAccountId,
  categoryId: category,
);

const _groceries = Budget(
  id: 'bud_cat_groceries_monthly',
  categoryId: 'cat_groceries',
  amount: 100,
  currency: 'EUR',
  period: BudgetPeriod.monthly,
);

MockRepository _repo({
  List<Transaction>? transactions,
  List<Budget> budgets = const [_groceries],
  DateTime Function()? clock,
}) => MockRepository(
  now: _morning,
  clock: clock,
  transactions: (_, _) =>
      transactions ?? [_tx(1, 150), _tx(0, 5, category: 'cat_home')],
  budgets: (_, _) => budgets,
  recurring: (_) => const [],
  investments: (_, _) => (holdings: const [], movements: const []),
);

Future<AppState> _pump(
  WidgetTester tester,
  DashboardWidgetSize size, {
  MockRepository? repo,
  Brightness brightness = Brightness.light,
  bool editing = false,
  bool hide = false,
  String locale = 'en',
  bool preview = false,
  VoidCallback? onOpenInvestments,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final (w, h) = switch (size) {
    DashboardWidgetSize.s => (171.0, 170.0),
    _ => (358.0, 170.0),
  };
  final state = AppState(repository: repo ?? _repo());
  if (hide) state.toggleHideAmounts();
  await tester.pumpWidget(
    AppScope(
      state: state,
      child: MaterialApp(
        theme: brightness == Brightness.dark
            ? SossoldiTheme.dark
            : SossoldiTheme.light,
        locale: Locale(locale),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AppShellScope(
            openInvestmentsOverview: onOpenInvestments ?? () {},
            child: Center(
              child: SizedBox(
                width: w,
                height: h,
                child: InsightWidget(
                  size: size,
                  instance: DashboardWidgetInstance(
                    editing: editing,
                    preview: preview,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return state;
}

void main() {
  for (final b in Brightness.values) {
    for (final locale in ['en', 'it']) {
      testWidgets('S draws without overflow (${b.name}, $locale)', (
        tester,
      ) async {
        for (final size in [DashboardWidgetSize.s]) {
          await _pump(tester, size, brightness: b, locale: locale);
          expect(find.byType(InsightWidget), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        }
      });
    }
  }

  testWidgets(
    'budget: the chip, the amount over and the bar of the Budget tab',
    (tester) async {
      await _pump(tester, DashboardWidgetSize.s);
      expect(find.text('Groceries over budget'), findsOneWidget);
      expect(find.text('150%'), findsOneWidget);
      expect(find.textContaining('50.00'), findsOneWidget);
      expect(find.byType(BudgetPercentBadge), findsOneWidget);
      expect(find.byType(SossoldiBudgetBar), findsOneWidget);
    },
  );

  testWidgets('Hidden Mode masks the amounts, the percentages stay', (
    tester,
  ) async {
    await _pump(tester, DashboardWidgetSize.s, hide: true);
    expect(find.textContaining('50.00'), findsNothing);
    expect(find.textContaining('••••'), findsWidgets);
    expect(find.textContaining('150%'), findsOneWidget);
  });

  testWidgets('the tap on the card opens it too', (tester) async {
    await _pump(tester, DashboardWidgetSize.s);
    await tester.tap(find.text('Groceries over budget'));
    await tester.pumpAndSettle();
    expect(find.byType(BudgetDetailScreen), findsOneWidget);
  });

  testWidgets('in edit mode nothing opens', (tester) async {
    await _pump(tester, DashboardWidgetSize.s, editing: true);
    await tester.tap(find.text('Groceries over budget'));
    await tester.pumpAndSettle();
    expect(find.byType(BudgetDetailScreen), findsNothing);
  });

  testWidgets('"All good" has no action', (tester) async {
    final repo = _repo(budgets: const [], transactions: [_tx(0, 5)]);
    await _pump(tester, DashboardWidgetSize.s, repo: repo);
    expect(find.text('All good for today'), findsOneWidget);
    // The detail stays under the title and goes to a second line.
    expect(find.text('Nothing needs your attention'), findsOneWidget);
  });

  testWidgets('a new user is asked for the first transaction', (tester) async {
    await _pump(
      tester,
      DashboardWidgetSize.s,
      repo: MockRepository.newUser(now: _morning),
    );
    expect(find.text('Add your first transaction'), findsOneWidget);
    expect(find.text('Start tracking your finances'), findsOneWidget);
  });

  testWidgets('it follows the data when the repository changes', (
    tester,
  ) async {
    final repo = _repo();
    await _pump(tester, DashboardWidgetSize.s, repo: repo);
    expect(find.text('Groceries over budget'), findsOneWidget);
    repo.deleteBudget(_groceries.id);
    await tester.pump();
    expect(find.text('Groceries over budget'), findsNothing);
  });

  testWidgets('it follows the clock: the evening, and the return to the app', (
    tester,
  ) async {
    var now = _morning;
    final repo = _repo(
      budgets: const [],
      transactions: [_tx(1, 5)],
      clock: () => now,
    );
    await _pump(tester, DashboardWidgetSize.s, repo: repo);
    expect(find.text('Nothing recorded today'), findsNothing);
    // The timer set for 18:00 fires with the clock at 19:00.
    now = DateTime(2026, 10, 22, 19);
    await tester.pump(const Duration(hours: 8));
    expect(find.text('Nothing recorded today'), findsOneWidget);
    // Back in the foreground the next day: the last one is 2 days old, quiet.
    now = DateTime(2026, 10, 23, 9);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('Nothing recorded today'), findsNothing);
  });

  testWidgets('the add-widget preview shows a fixed example', (tester) async {
    await _pump(tester, DashboardWidgetSize.s, preview: true);
    expect(find.byType(SossoldiChangeIndicator), findsOneWidget);
    expect(find.text('Portfolio down today'), findsOneWidget);
    expect(find.text('Groceries over budget'), findsNothing);
  });

  test('registered in S only, in the initial layout', () {
    final def = dashboardWidgetRegistry.byId(DashboardWidgetIds.insight)!;
    expect(def.supportedSizes, {DashboardWidgetSize.s});
    expect(
      defaultDashboardLayout.items.map((i) => i.widgetId),
      contains(DashboardWidgetIds.insight),
    );
  });
}
