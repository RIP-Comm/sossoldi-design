import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/dashboard/model/dashboard_layout.dart';
import 'package:sossoldi/features/dashboard/widgets/upcoming_recurring_widget.dart';
import 'package:sossoldi/l10n/l10n.dart';
import 'package:sossoldi/mock/mock_repository.dart';

final _now = DateTime(2026, 10, 22, 10);

Future<void> _pump(
  WidgetTester tester,
  DashboardWidgetSize size, {
  MockRepository? repo,
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
}) async {
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
      state: AppState(repository: repo ?? MockRepository(now: _now)),
      child: MaterialApp(
        theme: brightness == Brightness.dark
            ? SossoldiTheme.dark
            : SossoldiTheme.light,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: w,
              height: h,
              child: UpcomingRecurringWidget(size: size),
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
    testWidgets('S shows 1 row, M 2 and L the most that fit (${b.name})', (
      tester,
    ) async {
      await _pump(tester, DashboardWidgetSize.s, brightness: b);
      expect(find.byType(SossoldiChip), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _pump(tester, DashboardWidgetSize.m, brightness: b);
      // With 12 px around, two rows of a date fit under the header.
      expect(find.byType(SossoldiTransactionItem), findsNWidgets(2));
      // 2 dates and the type chip of the header.
      expect(find.byType(SossoldiChip), findsNWidgets(3));

      await _pump(tester, DashboardWidgetSize.l, brightness: b);
      final rows = find.byType(SossoldiTransactionItem).evaluate().length;
      expect(rows, inInclusiveRange(5, 6));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('rows are in date order and the hidden switch masks amounts', (
    tester,
  ) async {
    await _pump(tester, DashboardWidgetSize.l);
    final items = tester
        .widgetList<SossoldiTransactionItem>(
          find.byType(SossoldiTransactionItem),
        )
        .toList();
    expect(items.every((i) => i.recurrenceLabel != null), isTrue);
    final repo = MockRepository(now: _now);
    final expected = repo.upcomingRecurrences(
      limit: items.length,
      includeToday: true,
    );
    expect(items.map((i) => i.amount), expected.map((o) => o.amount));
  });

  testWidgets('no recurring transactions: a neutral empty state in S, M, L', (
    tester,
  ) async {
    for (final size in DashboardWidgetSize.values) {
      await _pump(tester, size, repo: MockRepository.newUser(now: _now));
      expect(find.text('No recurring transactions'), findsOneWidget);
      expect(find.byType(SossoldiTransactionItem), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Italian title of the empty state', (tester) async {
    await _pump(
      tester,
      DashboardWidgetSize.m,
      repo: MockRepository.newUser(now: _now),
      locale: const Locale('it'),
    );
    expect(find.text('Nessuna ricorrenza'), findsOneWidget);
  });
}
