import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_shell_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/dashboard/dashboard_controller.dart';
import 'package:sossoldi/features/dashboard/model/dashboard_layout.dart';
import 'package:sossoldi/features/dashboard/registry/dashboard_widget_definition.dart';
import 'package:sossoldi/features/dashboard/widgets/allocation_widget.dart';
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
          DashboardItem(id: 'x', widgetId: 'allocation', size: size),
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
                  builder: (context, _) => AllocationWidget(
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
        expect(find.text('Allocation'), findsOneWidget);
        expect(find.byType(SossoldiDonutChart), findsOneWidget);
        expect(
          find.byType(SossoldiTabNavigation),
          findsNWidgets(size == DashboardWidgetSize.l ? 1 : 0),
        );
        expect(tester.takeException(), isNull, reason: size.name);
        await tester.pumpWidget(const SizedBox());
      }
    });
  }

  testWidgets('single asset view in L, kept through S and M', (tester) async {
    final c = DashboardController(
      layout: const DashboardLayout([
        DashboardItem(
          id: 'x',
          widgetId: 'allocation',
          size: DashboardWidgetSize.l,
        ),
      ]),
    );
    await _pump(tester, DashboardWidgetSize.l, controller: c);
    await tester.tap(find.text('Single asset'));
    await tester.pumpAndSettle();
    expect(c.layout.items.first.settings, {'mode': 'singleAsset'});
    // Eight legend rows still fit in L.
    expect(tester.takeException(), isNull);
    for (final size in [DashboardWidgetSize.m, DashboardWidgetSize.s]) {
      c.resize('x', size);
      await tester.pumpWidget(const SizedBox());
      await _pump(tester, size, controller: c);
      expect(c.layout.items.first.settings, {'mode': 'singleAsset'});
      expect(tester.takeException(), isNull);
    }
    c.resize('x', DashboardWidgetSize.l);
    await tester.pumpWidget(const SizedBox());
    await _pump(tester, DashboardWidgetSize.l, controller: c);
    final tabs = tester.widget<SossoldiTabNavigation>(
      find.byType(SossoldiTabNavigation),
    );
    expect(tabs.selectedIndex, 1);
  });

  testWidgets('the selector is disabled while editing; no tap through', (
    tester,
  ) async {
    var opened = 0;
    await _pump(
      tester,
      DashboardWidgetSize.l,
      editing: true,
      onOpen: () => opened++,
    );
    await tester.tap(find.text('Single asset'), warnIfMissed: false);
    await tester.pump();
    expect(find.byType(SossoldiTabNavigation), findsOneWidget);
    expect(opened, 0);
  });

  testWidgets('a tap opens Investments', (tester) async {
    var opened = 0;
    await _pump(tester, DashboardWidgetSize.m, onOpen: () => opened++);
    await tester.tap(find.text('Allocation'));
    expect(opened, 1);
  });

  testWidgets('L amounts are masked with hidden amounts', (tester) async {
    await _pump(tester, DashboardWidgetSize.l, hide: true);
    expect(find.textContaining('€', findRichText: true), findsNothing);
    expect(find.text('••••'), findsWidgets);
  });

  testWidgets('a new user: neutral empty state and an empty donut', (
    tester,
  ) async {
    for (final size in DashboardWidgetSize.values) {
      await _pump(tester, size, repo: MockRepository.newUser(now: _now));
      expect(find.text('No investments yet'), findsOneWidget);
      expect(find.byType(SossoldiDonutChart), findsOneWidget);
      expect(
        tester
            .widget<SossoldiDonutChart>(find.byType(SossoldiDonutChart))
            .segments,
        isEmpty,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });
}
