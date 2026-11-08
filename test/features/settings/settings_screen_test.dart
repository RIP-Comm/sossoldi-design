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
      'Import / Export',
      'Notifications',
      'Feedback',
      'Info',
    ]) {
      expect(find.text(t), findsOneWidget, reason: t);
    }
    // Feedback opens an external form: its icon is not a chevron.
    expect(find.byIcon(PhosphorIconsRegular.caretRight), findsNWidgets(6));
    expect(find.byIcon(PhosphorIconsRegular.arrowSquareOut), findsOneWidget);
    expect(find.byType(SossoldiTag), findsNothing);
    expect(find.text('Open source, built by the community'), findsOneWidget);
    for (final icon in [
      PhosphorIconsFill.githubLogo,
      PhosphorIconsFill.linkedinLogo,
      PhosphorIconsFill.youtubeLogo,
      PhosphorIconsFill.discordLogo,
    ]) {
      expect(find.byIcon(icon), findsOneWidget);
    }
  });

  testWidgets('every destination opens and goes back to App settings', (
    tester,
  ) async {
    await _openApp(tester);
    for (final t in const ['Authentication', 'Import / Export']) {
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

  testWidgets('Info: version, team, contribute link and privacy policy', (
    tester,
  ) async {
    await _openApp(tester);
    await tester.tap(find.text('Info'));
    await tester.pumpAndSettle();
    expect(find.text('App version'), findsOneWidget);
    expect(find.text('2.0.0'), findsOneWidget);
    expect(find.text('See the team behind this app'), findsOneWidget);
    expect(find.text('Want to contribute?'), findsOneWidget);
    expect(find.byIcon(PhosphorIconsRegular.githubLogo), findsNothing);
    expect(find.byIcon(PhosphorIconsRegular.arrowSquareOut), findsOneWidget);
    // Collaborators and Privacy policy have a chevron; the version has none.
    expect(find.byIcon(PhosphorIconsRegular.caretRight), findsNWidgets(2));
    expect(find.text('Read more'), findsNothing);

    await tester.tap(find.text('Collaborators'));
    await tester.pumpAndSettle();
    expect(find.text('Meet the team'), findsOneWidget);
    expect(find.text('Marco Perugini'), findsOneWidget);
    expect(find.byIcon(PhosphorIconsRegular.globe), findsOneWidget);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -2000),
    );
    await tester.pumpAndSettle();
    expect(find.text('Federico Bruzzone'), findsOneWidget);
    expect(find.byIcon(PhosphorIconsRegular.linkedinLogo), findsWidgets);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, 3000),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(PhosphorIconsRegular.arrowLeft));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Privacy policy'));
    await tester.pumpAndSettle();
    expect(find.text('Contact us'), findsOneWidget);
    expect(find.text('help.sossoldi@gmail.com'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Notifications: the reminder opens its options', (tester) async {
    final state = await _openApp(tester);
    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Add transaction reminder'), findsOneWidget);
    expect(find.text('Recurring transaction added'), findsOneWidget);
    expect(find.text('Frequency'), findsNothing);

    await tester.tap(find.byType(SossoldiSwitch).first);
    await tester.pumpAndSettle();
    expect(state.transactionReminder.enabled, isTrue);
    // Daily: frequency and time, no day.
    expect(find.text('Frequency'), findsOneWidget);
    expect(find.text('Time'), findsOneWidget);
    expect(find.text('Day'), findsNothing);
    expect(find.text('09:00'), findsOneWidget);

    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Weekly').last);
    await tester.pumpAndSettle();
    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Monday'), findsOneWidget);

    await tester.tap(find.byType(SossoldiSwitch).last);
    await tester.pumpAndSettle();
    expect(state.recurringAddedNotice, isTrue);
  });

  testWidgets('Notifications: the time is chosen on the wheels', (
    tester,
  ) async {
    final state = await _openApp(tester);
    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SossoldiSwitch).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('09:00'));
    await tester.pumpAndSettle();
    expect(find.byType(SossoldiTimeWheels), findsOneWidget);
    // Drag the hours wheel up by two rows: 11.
    await tester.drag(
      find.text('09').first,
      const Offset(0, -2 * SossoldiTimeWheels.itemExtent),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(PhosphorIconsRegular.check));
    await tester.pumpAndSettle();
    expect(state.transactionReminder.time.hour, 11);
    expect(state.transactionReminder.time.minute, 0);
    expect(find.text('11:00'), findsOneWidget);
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
      'Importa / Esporta',
      'Notifiche',
      'Info',
    ]) {
      await tester.tap(find.text(t));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: t);
      if (t != 'Notifiche' && t != 'Info') {
        expect(find.text('In arrivo'), findsOneWidget, reason: t);
      }
      await tester.tap(find.byIcon(PhosphorIconsRegular.arrowLeft));
      await tester.pumpAndSettle();
    }
  });
}
