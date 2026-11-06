import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_shell_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/dashboard/dashboard_controller.dart';
import 'package:sossoldi/features/dashboard/model/dashboard_layout.dart';
import 'package:sossoldi/features/dashboard/registry/dashboard_widget_definition.dart';
import 'package:sossoldi/features/dashboard/widgets/investments_widget.dart';
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
  VoidCallback? onOpen,
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
          DashboardItem(id: 'x', widgetId: 'investments', size: size),
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
          body: AppShellScope(
            openInvestmentsOverview: onOpen ?? () {},
            child: Center(
              child: SizedBox(
                width: w,
                height: h,
                child: ListenableBuilder(
                  listenable: c,
                  builder: (context, _) => InvestmentsWidget(
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
    ),
  );
  await tester.pump();
}

void main() {
  for (final b in Brightness.values) {
    testWidgets('S, M and L draw without overflow (${b.name})', (tester) async {
      for (final size in DashboardWidgetSize.values) {
        await _pump(tester, size, brightness: b);
        expect(find.text('Investments'), findsOneWidget);
        expect(find.byType(SossoldiChangeIndicator), findsOneWidget);
        final isL = size == DashboardWidgetSize.l;
        expect(find.byType(SossoldiValueChart), findsNWidgets(isL ? 1 : 0));
        expect(find.byType(SossoldiTrendChart), findsNWidgets(isL ? 0 : 1));
        expect(find.byType(SossoldiChartLegend), findsNWidgets(isL ? 1 : 0));
        // Year to date everywhere: S as a label, M and L as the chip.
        expect(find.text('YTD'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    });
  }

  testWidgets('the period survives a resize and the chart follows', (
    tester,
  ) async {
    final c = DashboardController(
      layout: const DashboardLayout([
        DashboardItem(
          id: 'x',
          widgetId: 'investments',
          size: DashboardWidgetSize.l,
        ),
      ]),
    );
    await _pump(tester, DashboardWidgetSize.l, controller: c);
    await tester.tap(find.text('YTD').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('1Y').last);
    await tester.pumpAndSettle();
    expect(c.layout.items.first.settings, {'period': 'year'});
    c.resize('x', DashboardWidgetSize.m);
    await tester.pumpWidget(const SizedBox());
    await _pump(tester, DashboardWidgetSize.m, controller: c);
    c.resize('x', DashboardWidgetSize.l);
    await tester.pumpWidget(const SizedBox());
    await _pump(tester, DashboardWidgetSize.l, controller: c);
    expect(find.text('1Y'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the chip is disabled while editing; no tap through', (
    tester,
  ) async {
    var opened = 0;
    await _pump(
      tester,
      DashboardWidgetSize.l,
      editing: true,
      onOpen: () => opened++,
    );
    await tester.tap(find.text('YTD').first, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(SossoldiMenuItem), findsNothing);
    await tester.tap(find.text('Investments'));
    expect(opened, 0);
  });

  testWidgets('a tap on the figures opens Investments', (tester) async {
    var opened = 0;
    await _pump(tester, DashboardWidgetSize.m, onOpen: () => opened++);
    await tester.tap(find.text('Investments'));
    expect(opened, 1);
  });

  testWidgets('hidden amounts are masked', (tester) async {
    await _pump(tester, DashboardWidgetSize.m, hide: true);
    expect(find.textContaining('€', findRichText: true), findsNothing);
  });

  testWidgets('a new user: neutral empty state, no change', (tester) async {
    for (final size in DashboardWidgetSize.values) {
      await _pump(tester, size, repo: MockRepository.newUser(now: _now));
      expect(find.text('No investments yet'), findsOneWidget);
      expect(find.byType(SossoldiChangeIndicator), findsNothing);
      expect(find.byType(SossoldiValueChart), findsNothing);
      expect(find.byType(SossoldiTrendChart), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('change indicator: zero base shows the amount in the chip', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SossoldiTheme.light,
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: Column(
            children: [
              SossoldiChangeIndicator(amount: 50, currencyCode: 'EUR'),
              SossoldiChangeIndicator(
                amount: -3,
                currencyCode: 'EUR',
                percent: -0.02,
              ),
              SossoldiChangeIndicator(
                amount: 0,
                currencyCode: 'EUR',
                percent: 0,
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('+€50.00'), findsOneWidget);
    // Only the amount, in the chip: no plain text beside it.
    expect(find.byType(Text), findsNWidgets(1 + 2 + 2));
    expect(find.text('-2.00%'), findsOneWidget);
    expect(find.text('0.00%'), findsOneWidget);
  });
}
