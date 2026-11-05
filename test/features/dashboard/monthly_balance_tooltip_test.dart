import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/dashboard/model/dashboard_layout.dart';
import 'package:sossoldi/features/dashboard/widgets/monthly_balance_widget.dart';
import 'package:sossoldi/l10n/l10n.dart';
import 'package:sossoldi/mock/mock_repository.dart';

final _now = DateTime(2026, 10, 22, 10);

void main() {
  for (final size in DashboardWidgetSize.values) {
    testWidgets(
      'tap on the chart shows the day and both months (${size.name})',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final (w, h) = switch (size) {
          DashboardWidgetSize.s => (171.0, 170.0),
          DashboardWidgetSize.m => (358.0, 170.0),
          DashboardWidgetSize.l => (358.0, 358.0),
        };
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
                    width: w,
                    height: h,
                    child: MonthlyBalanceWidget(size: size),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        final chart = find.byType(SossoldiTrendChart);
        // The left edge is the 1st; the tooltip names the day.
        await tester.tapAt(tester.getTopLeft(chart) + const Offset(1, 20));
        await tester.pump();
        if (size == DashboardWidgetSize.s) {
          // The S has no tooltip.
          expect(find.byType(SossoldiChartTooltip), findsNothing);
          return;
        }
        final tip = tester.widget<SossoldiChartTooltip>(
          find.byType(SossoldiChartTooltip),
        );
        expect(tip.title, 'Oct 1');
        expect(tip.rows.map((r) => r.$2), ['This month', 'Last month']);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
