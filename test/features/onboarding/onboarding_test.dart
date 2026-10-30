import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/app/app.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/onboarding/onboarding_accounts_screen.dart';
import 'package:sossoldi/features/onboarding/onboarding_splash_screen.dart';
import 'package:sossoldi/features/onboarding/onboarding_welcome_screen.dart';
import 'package:sossoldi/features/onboarding/sossoldi_logo.dart';
import 'package:sossoldi/mock/mock_repository.dart';

import '../../load_test_fonts.dart';

final _now = DateTime(2026, 10, 22, 10);

/// The app on the demo data, with the device in [device].
Future<AppState> _open(
  WidgetTester tester, {
  String device = 'en',
  Brightness? brightness,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.localeTestValue = Locale(device);
  tester.platformDispatcher.localesTestValue = [Locale(device)];
  if (brightness != null) {
    tester.platformDispatcher.platformBrightnessTestValue = brightness;
  }
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearAllTestValues();
  });
  final state = AppState(repository: MockRepository(now: _now));
  addTearDown(state.dispose);
  await tester.pumpWidget(SossoldiApp(state: state));
  await tester.pump();
  return state;
}

/// Opens the onboarding and waits for the splash to give way to the welcome.
Future<AppState> _welcome(
  WidgetTester tester, {
  String device = 'en',
  Brightness? brightness,
}) async {
  final state = await _open(tester, device: device, brightness: brightness);
  state.startOnboarding();
  await tester.pump();
  await _leaveSplash(tester);
  return state;
}

Future<AppState> _step1(WidgetTester tester, {String device = 'en'}) async {
  final state = await _welcome(tester, device: device);
  await tester.tap(find.byType(SossoldiButton).first);
  await tester.pumpAndSettle();
  return state;
}

Finder get _fields => find.byType(EditableText);

/// Lets the splash run: its time, the elements fading out, the pause and the
/// fade in of the welcome.
Future<void> _leaveSplash(WidgetTester tester) async {
  await tester.pump(OnboardingSplashScreen.duration);
  await tester.pump(
    OnboardingSplashScreen.exitDuration +
        OnboardingSplashScreen.exitGap +
        const Duration(milliseconds: 20),
  );
  await tester.pumpAndSettle();
}

Future<void> _pick(WidgetTester tester, String current, String next) async {
  await tester.tap(find.text(current));
  await tester.pumpAndSettle();
  await tester.tap(find.text(next).last);
  await tester.pumpAndSettle();
}

Future<void> _openForm(WidgetTester tester) async {
  await tester.tap(find.text('Create account'));
  await tester.pumpAndSettle();
}

Future<void> _fill(WidgetTester tester, String name, String amount) async {
  await tester.enterText(_fields.at(0), name);
  await tester.enterText(_fields.at(1), amount);
  await tester.pump();
}

Future<void> _save(WidgetTester tester) async {
  await tester.tap(find.byIcon(PhosphorIconsRegular.check));
  await tester.pumpAndSettle();
}

Future<void> _createAccount(
  WidgetTester tester,
  String name,
  String amount,
) async {
  final first = find.text('Create account');
  await tester.tap(
    first.evaluate().isNotEmpty ? first : find.text('Add account'),
  );
  await tester.pumpAndSettle();
  await _fill(tester, name, amount);
  await _save(tester);
}

void main() {
  setUpAll(loadTestFonts);

  group('the way in', () {
    testWidgets('the app starts on the demo data, not on the onboarding', (
      tester,
    ) async {
      final state = await _open(tester);
      expect(state.onboardingActive, isFalse);
      expect(find.text('Set up the app'), findsNothing);
      expect(state.repository.accounts, hasLength(3));
    });

    testWidgets('the splash: logo, name and line; then it fades to welcome', (
      tester,
    ) async {
      final state = await _open(tester);
      state.startOnboarding();
      await tester.pump();
      expect(state.repository.accounts, isEmpty);
      expect(find.text('Welcome to'), findsOneWidget);
      expect(find.text('SOSSOLDI'), findsOneWidget);
      expect(
        find.text('The personal finance app of the Mr. RIP community'),
        findsOneWidget,
      );
      expect(find.byType(SossoldiLogo), findsOneWidget);
      // Not yet.
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.text('Set up the app'), findsNothing);
      await _leaveSplash(tester);
      expect(find.text('Set up the app'), findsOneWidget);
      expect(find.text('SOSSOLDI'), findsNothing);
    });

    testWidgets('the splash animates: the logo, then the text 200 ms later; '
        'everything out, a pause of 100 ms, then the welcome', (tester) async {
      final state = await _open(tester);
      state.startOnboarding();
      await tester.pump();
      double opacityOf(Finder inside) => tester
          .widget<Opacity>(
            find.ancestor(of: inside, matching: find.byType(Opacity)).first,
          )
          .opacity;
      double scaleOfLogo() => tester
          .widget<Transform>(
            find
                .ancestor(
                  of: find.byType(SossoldiLogo),
                  matching: find.byType(Transform),
                )
                .first,
          )
          .transform
          .getMaxScaleOnAxis();
      final logo = find.byType(SossoldiLogo);
      final text = find.text('SOSSOLDI');

      // At the start: nothing visible, the logo bigger than it will be.
      expect(opacityOf(logo), 0);
      expect(opacityOf(text), 0);
      expect(
        scaleOfLogo(),
        closeTo(OnboardingSplashScreen.logoStartScale, 1e-6),
      );

      // 100 ms: the logo is coming in, the text has not started (it waits
      // 200 ms).
      await tester.pump(const Duration(milliseconds: 100));
      expect(opacityOf(logo), greaterThan(0));
      expect(opacityOf(text), 0);
      final early = scaleOfLogo();
      expect(early, lessThan(OnboardingSplashScreen.logoStartScale));

      // 400 ms: the text is on its way, behind the logo.
      await tester.pump(const Duration(milliseconds: 300));
      expect(opacityOf(text), greaterThan(0));
      expect(opacityOf(text), lessThan(opacityOf(logo)));
      expect(scaleOfLogo(), lessThan(early));

      // Both end fully visible, the logo at its size.
      await tester.pump(const Duration(milliseconds: 700));
      expect(opacityOf(logo), 1);
      expect(opacityOf(text), 1);
      expect(scaleOfLogo(), closeTo(1, 1e-6));

      // At 1.5 s they start to go out together.
      await tester.pump(
        OnboardingSplashScreen.duration - const Duration(milliseconds: 1100),
      );
      await tester.pump(const Duration(milliseconds: 150));
      expect(opacityOf(logo), allOf(greaterThan(0), lessThan(1)));
      expect(opacityOf(text), allOf(greaterThan(0), lessThan(1)));

      // Gone; nothing yet for 100 ms; then the welcome.
      await tester.pump(const Duration(milliseconds: 160));
      expect(opacityOf(logo), 0);
      expect(opacityOf(text), 0);
      expect(find.text('Set up the app'), findsNothing);
      await tester.pump(const Duration(milliseconds: 60));
      expect(find.text('Set up the app'), findsNothing);
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();
      expect(find.text('Set up the app'), findsOneWidget);
    });

    testWidgets('the welcome has everything of the design', (tester) async {
      await _welcome(tester);
      expect(find.text('Set up the app'), findsOneWidget);
      expect(find.textContaining('A few steps and you'), findsOneWidget);
      // The line under the title is Body/Large.
      final subtitle = tester.widget<Text>(
        find.textContaining('A few steps and you'),
      );
      expect(
        subtitle.style?.fontSize,
        SossoldiTheme.light.extension<SossoldiTypography>()!.bodyLarge.fontSize,
      );
      expect(find.text('Choose language'), findsOneWidget);
      expect(find.text('English (default)'), findsOneWidget);
      expect(find.text('Start the setup'), findsOneWidget);
      expect(find.text('Or'), findsOneWidget);
      expect(find.text('Import data from another app'), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('the Settings rows restart the onboarding and load the demo', (
      tester,
    ) async {
      final state = await _open(tester);
      await tester.tap(
        find.byWidgetPredicate(
          (w) => w is SossoldiHeaderButton && w.semanticLabel == 'Settings',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Prototype'), findsOneWidget);
      await tester.tap(find.text('Restart onboarding'));
      await tester.pumpAndSettle();
      expect(state.onboardingActive, isTrue);
      expect(state.repository.accounts, isEmpty);
      // Settings is gone: the flow is on its own.
      expect(find.text('Settings'), findsNothing);
      expect(find.text('SOSSOLDI'), findsOneWidget);
      await _leaveSplash(tester);
      expect(find.text('Set up the app'), findsOneWidget);

      state.loadDemoData();
      await tester.pumpAndSettle();
      expect(state.onboardingActive, isFalse);
      expect(state.repository.accounts, hasLength(3));
      expect(find.text('Set up the app'), findsNothing);
    });
  });

  group('language', () {
    testWidgets('English on the device: English is the default', (
      tester,
    ) async {
      await _welcome(tester, device: 'en');
      expect(find.text('English (default)'), findsOneWidget);
    });

    testWidgets('Italian on the device: Italiano is preselected and default', (
      tester,
    ) async {
      await _welcome(tester, device: 'it');
      expect(find.text('Imposta l\'app'), findsNothing);
      expect(find.text('Configura l\'app'), findsOneWidget);
      expect(find.text('Italiano (predefinita)'), findsOneWidget);
    });

    testWidgets('a language the app does not have: English, as default', (
      tester,
    ) async {
      await _welcome(tester, device: 'fr');
      expect(find.text('Set up the app'), findsOneWidget);
      expect(find.text('English (default)'), findsOneWidget);
    });

    testWidgets('changing it changes the whole app, not only the screen', (
      tester,
    ) async {
      final state = await _welcome(tester, device: 'en');
      await tester.tap(find.text('English (default)'));
      await tester.pumpAndSettle();
      // Each option in its own language, the default marked.
      expect(find.text('Italiano'), findsOneWidget);
      await tester.tap(find.text('Italiano'));
      await tester.pumpAndSettle();
      expect(state.locale, const Locale('it'));
      expect(find.text('Configura l\'app'), findsOneWidget);
      expect(find.text('Inizia la configurazione'), findsOneWidget);
      // The default stays the language of the device.
      expect(find.text('Italiano'), findsOneWidget);

      // The next screen is in Italian too, and so is the app after it.
      await tester.tap(find.text('Inizia la configurazione'));
      await tester.pumpAndSettle();
      expect(find.text('Passo 1 di 3'), findsOneWidget);
      expect(find.text('I tuoi conti'), findsOneWidget);
      state.loadDemoData();
      await tester.pumpAndSettle();
      expect(find.text('Finanze'), findsWidgets);
    });

    testWidgets('and back to English', (tester) async {
      final state = await _welcome(tester, device: 'it');
      await _pick(tester, 'Italiano (predefinita)', 'English');
      expect(state.locale, const Locale('en'));
      expect(find.text('Set up the app'), findsOneWidget);
      expect(find.text('Italiano (default)'), findsNothing);
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(find.text('Italiano (default)'), findsOneWidget);
    });
  });

  group('import', () {
    testWidgets('leads to a placeholder, with a button back', (tester) async {
      await _welcome(tester);
      await tester.tap(find.text('Import data from another app'));
      await tester.pumpAndSettle();
      expect(find.text('Import data'), findsOneWidget);
      expect(find.text('Coming soon'), findsOneWidget);
      // This one has a back button; it goes back to the welcome.
      expect(find.byType(SossoldiHeaderButton), findsOneWidget);
      await tester.tap(find.byType(SossoldiHeaderButton));
      await tester.pumpAndSettle();
      expect(find.text('Set up the app'), findsOneWidget);
    });
  });

  group('step 1: main currency and accounts', () {
    testWidgets('without accounts: the empty card and no next step', (
      tester,
    ) async {
      await _step1(tester);
      expect(find.byType(OnboardingAccountsScreen), findsOneWidget);
      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(
        find.text('Select your currency and setup the accounts'),
        findsOneWidget,
      );
      expect(find.text('Select main currency'), findsOneWidget);
      expect(find.text('Euro € (default)'), findsOneWidget);
      expect(find.text('Your accounts'), findsOneWidget);
      expect(find.text('Create your first account'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
      expect(find.text('Next step'), findsNothing);
      expect(find.text('Add account'), findsNothing);
    });

    testWidgets('the currencies on offer, EUR the default', (tester) async {
      final state = await _step1(tester);
      await tester.tap(find.text('Euro € (default)'));
      await tester.pumpAndSettle();
      for (final name in [
        'US dollar \$',
        'British pound £',
        'Swiss franc CHF',
        'Brazilian real R\$',
        'UAE dirham',
        'Japanese yen ¥',
      ]) {
        expect(find.textContaining(name), findsOneWidget, reason: name);
      }
      await tester.tap(find.text('Brazilian real R\$'));
      await tester.pumpAndSettle();
      expect(state.mainCurrency, 'BRL');
      expect(state.repository.mainCurrency, 'BRL');
    });

    testWidgets('creating the first account: list, add link and next step', (
      tester,
    ) async {
      final state = await _step1(tester);
      await _openForm(tester);
      expect(find.text('New account'), findsOneWidget);
      await _fill(tester, 'Buddybank', '1000.20');
      await _save(tester);
      expect(find.text('New account'), findsNothing);
      expect(state.repository.accounts, hasLength(1));
      expect(find.text('Buddybank'), findsOneWidget);
      expect(find.text('€1,000.20'), findsOneWidget);
      expect(find.text('Add account'), findsOneWidget);
      expect(find.text('Next step'), findsOneWidget);
      expect(find.text('Create your first account'), findsNothing);
    });

    testWidgets('the main account: the first is main, the switch of another '
        'moves it, the main one has a disabled switch and the tag', (
      tester,
    ) async {
      final state = await _step1(tester);
      await _createAccount(tester, 'First', '100');
      expect(find.text('Main'), findsOneWidget);
      await _createAccount(tester, 'Second', '50');
      expect(state.repository.mainAccount!.name, 'First');
      expect(find.text('Main'), findsOneWidget);
      // The main one: switch on and disabled, with the reason.
      await tester.tap(find.text('First'));
      await tester.pumpAndSettle();
      expect(find.text('Main account'), findsOneWidget);
      expect(
        find.text('To change it, set another account as main'),
        findsOneWidget,
      );
      expect(
        tester.widget<SossoldiSwitch>(find.byType(SossoldiSwitch)).value,
        isTrue,
      );
      expect(
        tester.widget<SossoldiSwitch>(find.byType(SossoldiSwitch)).onChanged,
        isNull,
      );
      await tester.tap(find.byIcon(PhosphorIconsRegular.x));
      await tester.pumpAndSettle();
      // Another one: turn the switch on and save.
      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SossoldiSwitch));
      await tester.pump();
      await _save(tester);
      expect(state.repository.mainAccount!.name, 'Second');
      expect(state.repository.accounts.where((a) => a.isMain), hasLength(1));
    });

    testWidgets('accounts take the main currency; changing it later leaves '
        'them as they are', (tester) async {
      final state = await _step1(tester);
      await _createAccount(tester, 'Bank', '500');
      await _pick(tester, 'Euro € (default)', 'US dollar \$');
      await _createAccount(tester, 'Dollars', '50');
      expect(state.repository.accounts, hasLength(2));
      expect(state.repository.accounts.map((a) => a.currency), ['EUR', 'USD']);
      expect(find.text('€500.00'), findsOneWidget);
      expect(find.text('\$50.00'), findsOneWidget);
    });

    testWidgets('next step: step 2, then step 3; skipping ends the onboarding '
        'on the data of the new user', (tester) async {
      final state = await _step1(tester);
      await _createAccount(tester, 'Bank', '10');
      await tester.tap(find.text('Next step'));
      await tester.pumpAndSettle();
      expect(find.text('Step 2 of 3'), findsOneWidget);
      expect(find.text('Create your first category'), findsOneWidget);
      // Next step only comes with a category.
      expect(find.text('Next step'), findsNothing);
      await tester.tap(find.bySemanticsLabel('Add Housing'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next step'));
      await tester.pumpAndSettle();
      expect(find.text('Step 3 of 3'), findsOneWidget);
      await tester.tap(find.text('Skip this step'));
      await tester.pumpAndSettle();
      expect(state.onboardingActive, isFalse);
      // The app opens on what the user entered, not on the demo data.
      expect(state.repository.accounts.map((a) => a.name), ['Bank']);
      expect(state.repository.categories().single.name, 'Housing');
      expect(find.text('Step 3 of 3'), findsNothing);
      expect(find.text('Home'), findsOneWidget);
    });
  });

  group('the form of an account', () {
    testWidgets('what was typed stays when the keyboard comes and goes', (
      tester,
    ) async {
      await _step1(tester);
      await _openForm(tester);
      await tester.enterText(_fields.at(0), 'Bank');
      await tester.enterText(_fields.at(1), '250');
      await tester.pump();
      // The keyboard opens: the insets change and the sheet is built again.
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      tester.view.resetViewInsets();
      await tester.pumpAndSettle();
      expect(find.text('Bank'), findsOneWidget);
      expect(find.text('250'), findsOneWidget);
    });

    testWidgets('the amount asks for the numbers keyboard', (tester) async {
      await _step1(tester);
      await _openForm(tester);
      final amount = tester.widget<SossoldiTextInput>(
        find.byType(SossoldiTextInput).at(1),
      );
      expect(amount.keyboardType?.index, TextInputType.number.index);
      expect(amount.keyboardType?.decimal, isTrue);
      expect(amount.keyboardType?.signed, isNot(true));
    });

    testWidgets('has the fields of the design and the currency', (
      tester,
    ) async {
      await _step1(tester);
      await _openForm(tester);
      expect(find.text('Main info'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Your account name'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);
      // The currency is one for the whole app: no field in the account.
      expect(find.text('Currency'), findsNothing);
      expect(find.text('Icon and color'), findsOneWidget);
      expect(find.text('Tap to select'), findsOneWidget);
      // The Euro suffix of the amount, the check and the X.
      expect(find.text('€'), findsOneWidget);
      expect(find.byIcon(PhosphorIconsRegular.x), findsOneWidget);
      expect(find.byIcon(PhosphorIconsRegular.check), findsOneWidget);
      // Nothing to delete in a new account.
      expect(find.text('Delete account'), findsNothing);
    });

    testWidgets('the check is off until the data is valid', (tester) async {
      final state = await _step1(tester);
      await _openForm(tester);
      await _save(tester);
      expect(find.text('New account'), findsOneWidget);
      expect(state.repository.accounts, isEmpty);
      await tester.enterText(_fields.at(0), 'Bank');
      await tester.pump();
      await _save(tester);
      expect(find.text('New account'), findsOneWidget);
      expect(state.repository.accounts, isEmpty);
      await tester.enterText(_fields.at(1), '0');
      await tester.pump();
      await _save(tester);
      expect(state.repository.accounts, hasLength(1));
    });

    testWidgets('amounts: zero, negative and with a comma are accepted', (
      tester,
    ) async {
      final state = await _step1(tester);
      await _createAccount(tester, 'Zero', '0');
      await _createAccount(tester, 'Card', '-250,5');
      await _createAccount(tester, 'Big', '1.234,50');
      final balances = [
        for (final a in state.repository.accounts)
          state.repository.accountBalance(a.id),
      ];
      expect(balances, [0, -250.5, 1234.5]);
    });

    testWidgets('amounts: an empty or invalid one is an error', (tester) async {
      await _step1(tester);
      await _openForm(tester);
      await tester.enterText(_fields.at(0), 'Bank');
      await tester.enterText(_fields.at(1), 'abc');
      await tester.pump();
      expect(find.text('Enter a valid number'), findsOneWidget);
      await tester.enterText(_fields.at(1), '');
      await tester.pump();
      // Emptied after typing: it says it is missing.
      expect(find.text('Enter an amount'), findsOneWidget);
    });

    testWidgets('a name the user already has, in any case, is an error', (
      tester,
    ) async {
      final state = await _step1(tester);
      await _createAccount(tester, 'Savings', '10');
      await tester.tap(find.text('Add account'));
      await tester.pumpAndSettle();
      await _fill(tester, 'SAVINGS', '5');
      expect(
        find.text('You already have an account with this name'),
        findsOneWidget,
      );
      await _save(tester);
      expect(state.repository.accounts, hasLength(1));
      expect(find.text('New account'), findsOneWidget);
      await tester.enterText(_fields.at(0), 'Savings 2');
      await tester.pump();
      expect(
        find.text('You already have an account with this name'),
        findsNothing,
      );
      await _save(tester);
      expect(state.repository.accounts, hasLength(2));
    });

    testWidgets('a very long name does not break the form or the list', (
      tester,
    ) async {
      await _step1(tester);
      final name = 'A very long account name ' * 8;
      await _createAccount(tester, name, '12345678.90');
      expect(tester.takeException(), isNull);
      expect(find.textContaining('A very long account name'), findsOneWidget);
    });

    testWidgets('X closes it with nothing saved', (tester) async {
      final state = await _step1(tester);
      await _openForm(tester);
      await _fill(tester, 'Bank', '5');
      await tester.tap(find.byIcon(PhosphorIconsRegular.x));
      await tester.pumpAndSettle();
      expect(find.text('New account'), findsNothing);
      expect(state.repository.accounts, isEmpty);
    });

    testWidgets('icon and color: the icon grid and the sliders', (
      tester,
    ) async {
      // The first of the Finance group: at the top of the grid.
      final pick = CategoryIcons.groups.first.icons.first;
      final state = await _step1(tester);
      await _openForm(tester);
      expect(find.byType(SossoldiColorPicker), findsOneWidget);
      // The default: first color of the palette, the bank icon.
      var preview = tester.widget<Icon>(
        find.descendant(
          of: find.byType(SossoldiTappable).last,
          matching: find.byType(Icon),
        ),
      );
      expect(preview.icon, PhosphorIconsRegular.bank);
      expect(preview.color, CategoryColors.all.first.main);

      await tester.tap(find.text('Tap to select'));
      await tester.pumpAndSettle();
      expect(find.text('Choose an icon'), findsOneWidget);
      // A tab for each group of icons.
      expect(find.bySemanticsLabel('Finance'), findsOneWidget);
      expect(find.bySemanticsLabel('Travel and places'), findsOneWidget);
      expect(find.byIcon(pick), findsOneWidget);
      await tester.tap(find.byIcon(pick));
      await tester.pumpAndSettle();
      expect(find.text('Choose an icon'), findsNothing);

      await tester.drag(find.bySemanticsLabel('Hue'), const Offset(150, 0));
      await tester.pump();
      preview = tester.widget<Icon>(
        find.descendant(
          of: find.byType(SossoldiTappable).last,
          matching: find.byType(Icon),
        ),
      );
      expect(preview.icon, pick);
      expect(preview.color, isNot(CategoryColors.all.first.main));

      await _fill(tester, 'Pig', '1');
      await _save(tester);
      final a = state.repository.accounts.single;
      expect(a.icon, pick);
      expect(a.color.main, preview.color);
      // A free color gets its tint like the palette's.
      expect(a.color, CategoryColor.fromColor(preview.color!));
      // The list shows it.
      final shown = tester.widget<Icon>(
        find.descendant(
          of: find.byType(SossoldiAccountItem),
          matching: find.byType(Icon),
        ),
      );
      expect(shown.color, a.color.main);
      expect(shown.icon, pick);
    });
  });

  group('changing and deleting an account', () {
    testWidgets('tap on an account: the form in edit mode, with its data', (
      tester,
    ) async {
      await _step1(tester);
      await _createAccount(tester, 'Buddybank', '1000.2');
      await tester.tap(find.text('Buddybank'));
      await tester.pumpAndSettle();
      expect(find.text('Edit account'), findsOneWidget);
      expect(find.text('New account'), findsNothing);
      expect(find.text('Delete account'), findsOneWidget);
      expect(
        tester.widget<EditableText>(_fields.at(0)).controller.text,
        'Buddybank',
      );
      expect(
        tester.widget<EditableText>(_fields.at(1)).controller.text,
        '1000,2',
      );
    });

    testWidgets('changes are saved; its own name is not a duplicate', (
      tester,
    ) async {
      final state = await _step1(tester);
      await _createAccount(tester, 'Buddybank', '100');
      await tester.tap(find.text('Buddybank'));
      await tester.pumpAndSettle();
      // The same name again (other capitals) is fine: it is this account.
      await tester.enterText(_fields.at(0), 'BUDDYBANK');
      await tester.enterText(_fields.at(1), '250');
      await tester.pump();
      expect(
        find.text('You already have an account with this name'),
        findsNothing,
      );
      await _save(tester);
      expect(state.repository.accounts, hasLength(1));
      expect(state.repository.accounts.single.name, 'BUDDYBANK');
      expect(find.text('€250.00'), findsOneWidget);
    });

    testWidgets('not touching the sliders keeps the saved color exactly', (
      tester,
    ) async {
      final state = await _step1(tester);
      state.repository; // the repository of the flow
      await _createAccount(tester, 'Bank', '1');
      final saved = state.repository.accounts.single.color;
      // The palette color is the default; edit it and save without the sliders.
      await tester.tap(find.text('Bank'));
      await tester.pumpAndSettle();
      await tester.enterText(_fields.at(0), 'Bank 2');
      await tester.pump();
      await _save(tester);
      expect(state.repository.accounts.single.color, saved);
      expect(state.repository.accounts.single.color, CategoryColors.all.first);
    });

    testWidgets('delete asks first; Cancel keeps the account', (tester) async {
      final state = await _step1(tester);
      await _createAccount(tester, 'Bank', '1');
      await tester.tap(find.text('Bank'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Delete account'));
      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this account?'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(state.repository.accounts, hasLength(1));
      expect(find.text('Edit account'), findsOneWidget);
    });

    testWidgets('delete: the account goes; the last one brings back the empty '
        'state and hides the next step', (tester) async {
      final state = await _step1(tester);
      await _createAccount(tester, 'Bank', '1');
      expect(find.text('Next step'), findsOneWidget);
      await tester.tap(find.text('Bank'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Delete account'));
      await tester.tap(find.text('Delete account'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      expect(state.repository.accounts, isEmpty);
      expect(find.text('Edit account'), findsNothing);
      expect(find.text('Create your first account'), findsOneWidget);
      expect(find.text('Next step'), findsNothing);
    });
  });

  group('going back', () {
    testWidgets('the system back goes to the previous screen and keeps what '
        'was typed', (tester) async {
      final state = await _step1(tester);
      await _createAccount(tester, 'Bank', '100');
      await _pick(tester, 'Euro € (default)', 'Swiss franc CHF');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Set up the app'), findsOneWidget);
      expect(find.byType(OnboardingWelcomeScreen), findsOneWidget);
      expect(state.onboardingActive, isTrue);
      // Forward again: all of it is there.
      await tester.tap(find.text('Start the setup'));
      await tester.pumpAndSettle();
      expect(find.text('Bank'), findsOneWidget);
      expect(find.text('Swiss franc CHF'), findsOneWidget);
      expect(state.repository.accounts, hasLength(1));
    });

    testWidgets('back from the placeholder of step 2 goes to step 1', (
      tester,
    ) async {
      await _step1(tester);
      await _createAccount(tester, 'Bank', '100');
      await tester.tap(find.text('Next step'));
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(find.text('Bank'), findsOneWidget);
    });

    testWidgets('there is no back button on any screen', (tester) async {
      await _welcome(tester);
      expect(find.byIcon(PhosphorIconsRegular.arrowLeft), findsNothing);
      await tester.tap(find.text('Start the setup'));
      await tester.pumpAndSettle();
      expect(find.byIcon(PhosphorIconsRegular.arrowLeft), findsNothing);
      expect(find.byType(SossoldiHeaderButton), findsNothing);
    });

    testWidgets('back from the first screen leaves the flow for the demo', (
      tester,
    ) async {
      final state = await _welcome(tester);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(state.onboardingActive, isFalse);
      expect(state.repository.accounts, hasLength(3));
    });
  });

  group('between the repositories', () {
    testWidgets('nothing of the onboarding stays in the demo, and back', (
      tester,
    ) async {
      final state = await _step1(tester);
      await _createAccount(tester, 'Mine', '10');
      state.loadDemoData();
      await tester.pumpAndSettle();
      expect(
        state.repository.accounts.map((a) => a.name),
        isNot(contains('Mine')),
      );
      expect(state.repository.transactions, isNotEmpty);
      expect(state.mainCurrency, 'EUR');

      state.startOnboarding();
      await tester.pump();
      await _leaveSplash(tester);
      // A new onboarding starts empty, not with the last one's accounts.
      expect(state.repository.accounts, isEmpty);
      await tester.tap(find.text('Start the setup'));
      await tester.pumpAndSettle();
      expect(find.text('Create your first account'), findsOneWidget);
    });

    testWidgets('the language chosen stays in the app', (tester) async {
      final state = await _welcome(tester);
      await _pick(tester, 'English (default)', 'Italiano');
      state.loadDemoData();
      await tester.pumpAndSettle();
      expect(state.locale, const Locale('it'));
      expect(find.text('Finanze'), findsWidgets);
    });
  });

  for (final brightness in [Brightness.light, Brightness.dark]) {
    testWidgets('every screen and the form render in $brightness', (
      tester,
    ) async {
      final state = await _open(tester, brightness: brightness);
      state.setDarkMode(brightness == Brightness.dark);
      state.startOnboarding();
      await tester.pump();
      expect(tester.takeException(), isNull);
      await _leaveSplash(tester);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Start the setup'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _createAccount(tester, 'Bank', '10');
      await tester.tap(find.text('Add account'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Tap to select'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
