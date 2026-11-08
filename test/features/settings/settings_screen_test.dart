import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/app/placeholder_screen.dart';
import 'package:sossoldi/features/settings/widget_showcase_screen.dart';
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

/// Settings > App settings.
Future<AppState> _openApp(WidgetTester tester) async {
  final state = await _open(tester);
  await tester.tap(find.text('App settings'));
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
    final state = await _openApp(tester);
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
    final state = await _openApp(tester);
    await _pick(tester, 'Device language', 'Italiano');
    expect(state.locale, const Locale('it'));
    expect(find.text('Impostazioni app'), findsOneWidget);
    expect(find.text('Modalità scura'), findsOneWidget);
    expect(find.text('Lingua'), findsOneWidget);
    expect(find.text('Valuta'), findsOneWidget);

    await _pick(tester, 'Italiano', 'English');
    expect(state.locale, const Locale('en'));
    expect(find.text('App settings'), findsOneWidget);

    await _pick(tester, 'English', 'Device language');
    expect(state.locale, isNull);
  });

  testWidgets('the currency changes the amounts on the Dashboard', (
    tester,
  ) async {
    final state = await _openApp(tester);
    await _pick(tester, 'EUR · €', 'USD · \$');
    expect(state.mainCurrency, 'USD');
    // Back to the hub, back to the Dashboard.
    for (var i = 0; i < 2; i++) {
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SossoldiHeaderButton && w.semanticLabel == 'Back',
        ),
      );
      await tester.pumpAndSettle();
    }
    expect(find.textContaining(r'$'), findsWidgets);
    expect(find.textContaining('€'), findsNothing);
  });

  testWidgets('every supported currency can be picked', (tester) async {
    final state = await _openApp(tester);
    var current = 'EUR · €';
    for (final next in const ['GBP · £', 'CHF · CHF', 'USD · \$', 'EUR · €']) {
      await _pick(tester, current, next);
      current = next;
    }
    expect(state.mainCurrency, 'EUR');
  });

  testWidgets('the hub has two rows with a chevron and nothing else', (
    tester,
  ) async {
    await _open(tester);
    expect(find.text('App settings'), findsOneWidget);
    expect(find.text('Prototype settings'), findsOneWidget);
    expect(find.byIcon(PhosphorIconsRegular.caretRight), findsNWidgets(2));
    expect(find.byType(SossoldiTag), findsNothing);
    expect(find.text('Dark mode'), findsNothing);
  });

  testWidgets('App settings: three blocks, chevrons only on pages', (
    tester,
  ) async {
    await _openApp(tester);
    for (final t in const [
      'Authentication',
      'Accounts',
      'Categories',
      'Budgets',
      'Import / Export',
      'Notifications',
      'Feedback',
      'Info',
    ]) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
    expect(find.byIcon(PhosphorIconsRegular.caretRight), findsNWidgets(8));
    expect(find.byType(SossoldiTag), findsNothing);
  });

  testWidgets('every destination opens and goes back to App settings', (
    tester,
  ) async {
    await _openApp(tester);
    for (final t in const [
      'Authentication',
      'Budgets',
      'Import / Export',
      'Notifications',
      'Feedback',
      'Info',
    ]) {
      await tester.tap(find.text(t));
      await tester.pumpAndSettle();
      expect(find.byType(PlaceholderScreen), findsOneWidget, reason: t);
      expect(find.text('Coming soon'), findsOneWidget, reason: t);
      expect(tester.takeException(), isNull, reason: t);
      await tester.tap(find.byIcon(PhosphorIconsRegular.arrowLeft));
      await tester.pumpAndSettle();
      expect(find.text('Dark mode'), findsOneWidget, reason: t);
    }
  });

  testWidgets('Prototype settings: actions without chevron, showcase with', (
    tester,
  ) async {
    await _open(tester);
    await tester.tap(find.text('Prototype settings'));
    await tester.pumpAndSettle();
    expect(find.text('Restart onboarding'), findsOneWidget);
    expect(find.text('Load demo data'), findsOneWidget);
    expect(find.text('Widget showcase'), findsOneWidget);
    expect(find.byIcon(PhosphorIconsRegular.caretRight), findsOneWidget);
    await tester.tap(find.text('Widget showcase'));
    await tester.pumpAndSettle();
    expect(find.byType(WidgetShowcaseScreen), findsOneWidget);
  });

  testWidgets('Load demo data closes the whole Settings stack', (tester) async {
    final state = await _open(tester);
    await tester.tap(find.text('Prototype settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Load demo data'));
    await tester.pumpAndSettle();
    expect(find.text('Prototype settings'), findsNothing);
    expect(state.onboardingActive, isFalse);
  });

  testWidgets('a new user opens the hub and every page without errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.localeTestValue = const Locale('it');
    tester.platformDispatcher.localesTestValue = [const Locale('it')];
    addTearDown(() {
      tester.view.reset();
      tester.platformDispatcher.clearAllTestValues();
    });
    final state = AppState(repository: MockRepository.newUser(now: _now));
    state.setDarkMode(true);
    await tester.pumpWidget(SossoldiApp(state: state));
    await tester.pump();
    await tester.tap(
      find.byWidgetPredicate(
        (w) => w is SossoldiHeaderButton && w.semanticLabel == 'Impostazioni',
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Impostazioni app'));
    await tester.pumpAndSettle();
    for (final t in const [
      'Autenticazione',
      'Budget',
      'Importa / Esporta',
      'Notifiche',
      'Feedback',
      'Info',
    ]) {
      await tester.tap(find.text(t));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: t);
      expect(find.text('In arrivo'), findsOneWidget, reason: t);
      await tester.tap(find.byIcon(PhosphorIconsRegular.arrowLeft));
      await tester.pumpAndSettle();
    }
  });
}
