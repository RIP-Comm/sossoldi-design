import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/dashboard/dashboard_controller.dart';
import 'package:sossoldi/features/dashboard/model/dashboard_layout.dart';
import 'package:sossoldi/features/dashboard/registry/dashboard_widget_definition.dart';
import 'package:sossoldi/features/dashboard/widgets/budget_status_widget.dart';
import 'package:sossoldi/l10n/l10n.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/budget.dart';

final _now = DateTime(2026, 10, 22, 10);

AppState _state(MockRepository repo, bool hide) {
  final state = AppState(repository: repo);
  if (hide) state.toggleHideAmounts();
  return state;
}

Future<void> _pump(
  WidgetTester tester,
  DashboardWidgetSize size, {
  MockRepository? repo,
  Brightness brightness = Brightness.light,
  DashboardController? controller,
  bool editing = false,
  bool hide = false,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final (w, h) = switch (size) {
    DashboardWidgetSize.s => (171.0, 170.0),
    DashboardWidgetSize.m => (358.0, 170.0),
    DashboardWidgetSize.l => (358.0, 358.0),
  };
  final c =
      controller ??
      DashboardController(
        layout: DashboardLayout([
          DashboardItem(id: 'x', widgetId: 'budget_status', size: size),
        ]),
      );
  await tester.pumpWidget(
    AppScope(
      state: _state(repo ?? MockRepository(now: _now), hide),
      child: MaterialApp(
        theme: brightness == Brightness.dark
            ? SossoldiTheme.dark
            : SossoldiTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: w,
              height: h,
              child: ListenableBuilder(
                listenable: c,
                builder: (context, _) {
                  final item = c.layout.items.first;
                  return BudgetStatusWidget(
                    size: size,
                    instance: DashboardWidgetInstance(
                      settings: item.settings,
                      editing: editing,
                      onSettingChanged: (k, v) => c.setSetting('x', k, v),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  for (final b in Brightness.values) {
    testWidgets('S 1 budget, M 3, L up to 6, no overflow (${b.name})', (
      tester,
    ) async {
      await _pump(tester, DashboardWidgetSize.s, brightness: b);
      expect(find.byType(SossoldiBudgetBar), findsOneWidget);
      expect(find.text('Budget'), findsNothing);
      expect(tester.takeException(), isNull);

      await _pump(tester, DashboardWidgetSize.m, brightness: b);
      expect(find.byType(SossoldiBudgetBar), findsNWidgets(3));
      expect(find.text('Budget'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _pump(tester, DashboardWidgetSize.l, brightness: b);
      expect(
        find.byType(SossoldiBudgetBar).evaluate().length,
        inInclusiveRange(5, 6),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('first row is the most relevant budget and says "over"', (
    tester,
  ) async {
    final repo = MockRepository(now: _now);
    final first = repo.budgetsByRelevance(limit: 1).single;
    await _pump(tester, DashboardWidgetSize.m, repo: repo);
    expect(find.textContaining('over', findRichText: true), findsWidgets);
    expect(
      find.text(repo.category(first.budget.categoryId).name),
      findsWidgets,
    );
  });

  testWidgets('the filter keeps only monthly budgets in every size', (
    tester,
  ) async {
    final repo = MockRepository(now: _now);
    final c = DashboardController(
      layout: const DashboardLayout([
        DashboardItem(
          id: 'x',
          widgetId: 'budget_status',
          size: DashboardWidgetSize.l,
          settings: {'period': 'monthly'},
        ),
      ]),
    );
    await _pump(tester, DashboardWidgetSize.l, repo: repo, controller: c);
    final monthly = repo.budgetsByRelevance(period: BudgetPeriod.monthly);
    expect(
      find.byType(SossoldiBudgetBar),
      findsNWidgets(monthly.length.clamp(0, 6)),
    );
    expect(find.text('Weekly'), findsNothing);
    expect(find.text('Yearly'), findsNothing);
    // The chip shows the choice and the setting survives a resize.
    c.resize('x', DashboardWidgetSize.s);
    expect(c.layout.items.first.settings, {'period': 'monthly'});
    await _pump(tester, DashboardWidgetSize.s, repo: repo, controller: c);
    expect(find.byType(SossoldiBudgetBar), findsOneWidget);
    expect(find.text('Weekly'), findsNothing);
  });

  testWidgets('the menu changes the type; disabled while editing', (
    tester,
  ) async {
    await _pump(tester, DashboardWidgetSize.m);
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Monthly').last);
    await tester.pumpAndSettle();
    expect(find.text('All'), findsNothing);
    expect(find.text('Monthly'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
    await _pump(tester, DashboardWidgetSize.m, editing: true);
    expect(find.text('All'), findsOneWidget);
    await tester.tap(find.text('All'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(SossoldiMenuItem), findsNothing);
  });

  testWidgets('empty states: no budgets, none of the chosen type', (
    tester,
  ) async {
    await _pump(
      tester,
      DashboardWidgetSize.m,
      repo: MockRepository.newUser(now: _now),
    );
    expect(find.text('No budgets yet'), findsOneWidget);

    final c = DashboardController(
      layout: const DashboardLayout([
        DashboardItem(
          id: 'x',
          widgetId: 'budget_status',
          size: DashboardWidgetSize.m,
          settings: {'period': 'semiannual'},
        ),
      ]),
    );
    await _pump(tester, DashboardWidgetSize.m, controller: c);
    expect(find.text('No semiannual budgets'), findsOneWidget);
  });

  testWidgets('hidden amounts are masked', (tester) async {
    await _pump(tester, DashboardWidgetSize.m, hide: true);
    expect(find.textContaining('••••', findRichText: true), findsWidgets);
    expect(find.textContaining('€', findRichText: true), findsNothing);
  });
}
