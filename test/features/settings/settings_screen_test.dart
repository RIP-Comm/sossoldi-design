import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/features/dashboard/model/default_dashboard_layout.dart';
import 'package:sossoldi/app/app.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/mock/mock_repository.dart';

import '../../load_test_fonts.dart';

final _now = DateTime(2026, 10, 22, 10);

Future<AppState> _open(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.localeTestValue = const Locale('en');
  tester.platformDispatcher.localesTestValue = [const Locale('en')];
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearAllTestValues();
  });
  final state = AppState(repository: MockRepository(now: _now));
  await tester.pumpWidget(SossoldiApp(state: state));
  await tester.pump();
  await tester.tap(
    find.byWidgetPredicate(
      (w) => w is SossoldiHeaderButton && w.semanticLabel == 'Settings',
    ),
  );
  await tester.pumpAndSettle();
  return state;
}

Future<void> _pick(WidgetTester tester, String current, String next) async {
  await tester.tap(find.text(current));
  await tester.pumpAndSettle();
  await tester.tap(find.text(next).last);
  await tester.pumpAndSettle();
}

void main() {
  // These tests count on one widget on the Dashboard.
  setUp(() => startDashboardLayout = singleWidgetDashboardLayout);
  tearDown(() => startDashboardLayout = defaultDashboardLayout);
  setUpAll(loadTestFonts);

  testWidgets('shows the theme switch, the language and the currency', (
    tester,
  ) async {
    final state = await _open(tester);
    expect(find.text('Dark mode'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Device language'), findsOneWidget);
    expect(find.text('Currency'), findsOneWidget);
    expect(find.textContaining('EUR'), findsOneWidget);
    expect(state.locale, isNull);
  });

  testWidgets('the language changes the whole app at once, and back', (
    tester,
  ) async {
    final state = await _open(tester);
    await _pick(tester, 'Device language', 'Italiano');
    expect(state.locale, const Locale('it'));
    expect(find.text('Impostazioni'), findsOneWidget);
    expect(find.text('Modalità scura'), findsOneWidget);
    expect(find.text('Lingua'), findsOneWidget);
    expect(find.text('Valuta'), findsOneWidget);

    await _pick(tester, 'Italiano', 'English');
    expect(state.locale, const Locale('en'));
    expect(find.text('Settings'), findsOneWidget);

    await _pick(tester, 'English', 'Device language');
    expect(state.locale, isNull);
  });

  testWidgets('the currency changes the amounts on the Dashboard', (
    tester,
  ) async {
    final state = await _open(tester);
    await _pick(tester, 'EUR · €', 'USD · \$');
    expect(state.mainCurrency, 'USD');
    // Go back with the header button.
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is SossoldiHeaderButton && w.semanticLabel == 'Back',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining(r'$'), findsWidgets);
    expect(find.textContaining('€'), findsNothing);
  });

  testWidgets('every supported currency can be picked', (tester) async {
    final state = await _open(tester);
    var current = 'EUR · €';
    for (final next in const ['GBP · £', 'CHF · CHF', 'USD · \$', 'EUR · €']) {
      await _pick(tester, current, next);
      current = next;
    }
    expect(state.mainCurrency, 'EUR');
  });
}
