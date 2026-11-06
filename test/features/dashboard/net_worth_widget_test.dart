import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/dashboard/dashboard_controller.dart';
import 'package:sossoldi/features/dashboard/model/dashboard_layout.dart';
import 'package:sossoldi/features/dashboard/registry/dashboard_widget_definition.dart';
import 'package:sossoldi/features/dashboard/widgets/net_worth_widget.dart';
import 'package:sossoldi/l10n/l10n.dart';
import 'package:sossoldi/mock/mock_repository.dart';

final _now = DateTime(2026, 10, 22, 10);

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
          DashboardItem(id: 'x', widgetId: 'net_worth', size: size),
        ]),
      );
  final state = AppState(repository: repo ?? MockRepository(now: _now));
  if (hide) state.toggleHideAmounts();
  await tester.pumpWidget(
    AppScope(
      state: state,
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
                builder: (context, _) => NetWorthWidget(
                  size: size,
                  instance: DashboardWidgetInstance(
                    settings: c.layout.items.first.settings,
                    editing: editing,
                    onSettingChanged: (k, v) => c.setSetting('x', k, v),
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
}

void main() {
  for (final b in Brightness.values) {
    testWidgets('S, M and L draw without overflow (${b.name})', (tester) async {
      for (final size in DashboardWidgetSize.values) {
        await _pump(tester, size, brightness: b);
        expect(find.text('Net worth'), findsOneWidget);
        expect(find.byType(SossoldiTrendChart), findsOneWidget);
        // Year to date everywhere: S as a label, M and L as the chip.
        expect(find.text('YTD'), findsOneWidget);
        expect(find.byType(SossoldiChangeIndicator), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  }

  testWidgets('the period survives a resize; 5Y is disabled', (tester) async {
    final c = DashboardController(
      layout: const DashboardLayout([
        DashboardItem(
          id: 'x',
          widgetId: 'net_worth',
          size: DashboardWidgetSize.m,
        ),
      ]),
    );
    await _pump(tester, DashboardWidgetSize.m, controller: c);
    await tester.tap(find.text('YTD'));
    await tester.pumpAndSettle();
    final fiveYears = tester.widget<SossoldiMenuItem>(
      find.widgetWithText(SossoldiMenuItem, '5Y'),
    );
    expect(fiveYears.enabled, isFalse);
    await tester.tap(find.text('3M').last);
    await tester.pumpAndSettle();
    expect(find.text('3M'), findsOneWidget);
    expect(c.layout.items.first.settings, {'period': 'threeMonths'});
    c.resize('x', DashboardWidgetSize.l);
    await tester.pumpWidget(const SizedBox());
    await _pump(tester, DashboardWidgetSize.l, controller: c);
    expect(find.text('3M'), findsOneWidget);
  });

  testWidgets('the chip is disabled while editing', (tester) async {
    await _pump(tester, DashboardWidgetSize.m, editing: true);
    await tester.tap(find.text('YTD'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(SossoldiMenuItem), findsNothing);
  });

  testWidgets('hidden amounts are masked', (tester) async {
    await _pump(tester, DashboardWidgetSize.m, hide: true);
    expect(find.textContaining('€', findRichText: true), findsNothing);
  });

  testWidgets('a new user: 0, no change, neutral empty chart', (tester) async {
    await _pump(
      tester,
      DashboardWidgetSize.m,
      repo: MockRepository.newUser(now: _now),
    );
    expect(find.byType(SossoldiChangeIndicator), findsNothing);
    expect(find.byType(SossoldiTrendChart), findsNothing);
    expect(find.text('Not enough history yet'), findsOneWidget);
    expect(find.textContaining('0.00', findRichText: true), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tap on the chart: the tooltip shows the date and the value', (
    tester,
  ) async {
    await _pump(tester, DashboardWidgetSize.l);
    expect(find.byType(SossoldiChartTooltip), findsNothing);
    final chart = find.byType(SossoldiTrendChart);
    await tester.tapAt(tester.getCenter(chart));
    await tester.pump();
    final tip = tester.widget<SossoldiChartTooltip>(
      find.byType(SossoldiChartTooltip),
    );
    expect(tip.title, isNotEmpty);
    expect(tip.rows, hasLength(1));
    expect(tip.rows.single.$2, 'Net worth');
    expect(tester.takeException(), isNull);
    // The last point is today: the current value.
    await tester.tapAt(tester.getTopRight(chart) - const Offset(1, -10));
    await tester.pump();
    final last = tester.widget<SossoldiChartTooltip>(
      find.byType(SossoldiChartTooltip),
    );
    expect(last.rows.single.$3, MockRepository(now: _now).netWorth);
  });

  testWidgets('the chip is at the top right, above the value', (tester) async {
    await _pump(tester, DashboardWidgetSize.m);
    final chip = tester.getTopRight(find.text('YTD'));
    final amount = tester.getTopLeft(find.byType(SossoldiAmount));
    expect(chip.dy, lessThan(amount.dy));
    expect(chip.dx, greaterThan(300));
  });
}
