import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/features/dashboard/model/default_dashboard_layout.dart';
import 'package:sossoldi/app/app.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/dashboard/model/dashboard_layout.dart';
import 'package:sossoldi/features/dashboard/widgets/monthly_balance_card.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/balance_trend.dart';

final _now = DateTime(2026, 10, 22, 10);

AppState _state() => AppState(repository: MockRepository(now: _now));

Future<void> _pumpApp(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  tester.platformDispatcher.localeTestValue = locale;
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearAllTestValues();
  });
  await tester.pumpWidget(SossoldiApp(state: _state()));
  await tester.pump();
}

BalanceTrend _trend(double net) => BalanceTrend(
  periodStart: DateTime(2026, 10),
  daysInPeriod: 31,
  currency: 'EUR',
  current: [0, net / 2, net],
  previous: [for (var i = 0; i < 31; i++) i * 10.0],
  income: net > 0 ? net : 0,
  expenses: net < 0 ? -net : 0,
);

Widget _card(BalanceTrend trend, {bool masked = false, double width = 171}) =>
    MaterialApp(
      theme: SossoldiTheme.light,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            height: 170,
            child: MonthlyBalanceCard(
              size: DashboardWidgetSize.s,
              title: 'Monthly balance',
              trend: trend,
              masked: masked,
            ),
          ),
        ),
      ),
    );

void main() {
  // These tests count on one widget on the Dashboard.
  setUp(() => startDashboardLayout = singleWidgetDashboardLayout);
  tearDown(() => startDashboardLayout = defaultDashboardLayout);
  group('app shell', () {
    testWidgets('shows the Dashboard with one widget and the bottom bar', (
      tester,
    ) async {
      await _pumpApp(tester);
      expect(find.text('Monthly balance'), findsOneWidget);
      expect(find.byType(MonthlyBalanceCard), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Finance'), findsOneWidget);
      expect(find.text('Investments'), findsOneWidget);
      expect(find.bySemanticsLabel('Add transaction'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the widget is S: half of the width minus the gap', (
      tester,
    ) async {
      await _pumpApp(tester);
      final size = tester.getSize(find.byType(MonthlyBalanceCard));
      expect(size.width, (390 - 2 * 16 - 16) / 2);
      expect(size.height, 170);
    });

    testWidgets('Finance and Investments open their pages', (tester) async {
      await _pumpApp(tester);
      await tester.tap(find.text('Finance'));
      await tester.pump();
      // Finance opens on its Overview.
      expect(find.text('Your accounts'), findsOneWidget);
      await tester.tap(find.text('Investments'));
      await tester.pump();
      expect(find.text('Portfolio value'), findsOneWidget);
      await tester.tap(find.text('Home'));
      await tester.pump();
      expect(find.text('Monthly balance'), findsOneWidget);
    });

    testWidgets('+ and Settings open their screens and go back', (
      tester,
    ) async {
      await _pumpApp(tester);
      await tester.tap(find.bySemanticsLabel('Add transaction'));
      await tester.pumpAndSettle();
      expect(find.text('New transaction'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Close'));
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsWidgets);
      expect(find.text('Dark mode'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Monthly balance'), findsOneWidget);
    });

    testWidgets('the eye button masks every amount, globally', (tester) async {
      await _pumpApp(tester);
      expect(find.text('••••'), findsNothing);
      await tester.tap(find.bySemanticsLabel('Hide amounts'));
      await tester.pump();
      expect(find.text('••••'), findsOneWidget);
      expect(find.bySemanticsLabel('Show amounts'), findsOneWidget);
      // The state lives in the app, so it holds on other tabs too.
      await tester.tap(find.text('Finance'));
      await tester.pump();
      await tester.tap(find.text('Home'));
      await tester.pump();
      expect(find.text('••••'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Show amounts'));
      await tester.pump();
      expect(find.text('••••'), findsNothing);
    });

    testWidgets('texts are translated to Italian', (tester) async {
      await _pumpApp(tester, locale: const Locale('it'));
      expect(find.text('Saldo mensile'), findsOneWidget);
      expect(find.text('Finanze'), findsOneWidget);
      expect(find.text('Investimenti'), findsOneWidget);
      expect(find.bySemanticsLabel('Aggiungi transazione'), findsOneWidget);
    });

    for (final brightness in Brightness.values) {
      testWidgets('renders in ${brightness.name} mode', (tester) async {
        await _pumpApp(tester, brightness: brightness);
        expect(tester.takeException(), isNull);
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
        final colors = brightness == Brightness.light
            ? SossoldiColors.light
            : SossoldiColors.dark;
        expect(scaffold.backgroundColor, colors.surfaceMed);
      });
    }

    testWidgets('fits a small phone without overflow', (tester) async {
      await _pumpApp(tester, size: const Size(320, 568));
      expect(tester.takeException(), isNull);
    });
  });

  group('monthly balance card S', () {
    testWidgets('shows the net amount', (tester) async {
      await tester.pumpWidget(_card(_trend(1000.2)));
      expect(find.text('€1,000.20'), findsOneWidget);
    });

    testWidgets('negative amount shows the minus sign', (tester) async {
      await tester.pumpWidget(_card(_trend(-1000.2)));
      expect(find.text('-€1,000.20'), findsOneWidget);
    });

    testWidgets('masked hides the amount but keeps the title', (tester) async {
      await tester.pumpWidget(_card(_trend(1000.2), masked: true));
      expect(find.text('••••'), findsOneWidget);
      expect(find.textContaining('1,000'), findsNothing);
      expect(find.text('Monthly balance'), findsOneWidget);
    });

    testWidgets('very large amounts shrink without overflowing', (
      tester,
    ) async {
      await tester.pumpWidget(_card(_trend(-123456789012.34)));
      expect(tester.takeException(), isNull);
      // The amount is laid out at its natural width and scaled down to the
      // box: the box must stay inside the card, minus its side padding.
      final box = tester.getSize(find.byType(FittedBox));
      expect(box.width, lessThanOrEqualTo(171 - 2 * 12));
      final natural = tester.getSize(find.byType(SossoldiAmount));
      expect(natural.width, greaterThan(171));
    });

    testWidgets('works with only the first day elapsed', (tester) async {
      await tester.pumpWidget(
        _card(
          BalanceTrend(
            periodStart: DateTime(2026, 10),
            daysInPeriod: 31,
            currency: 'EUR',
            current: const [-12.5],
            previous: const [0, 10, 20],
            income: 0,
            expenses: 12.5,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
