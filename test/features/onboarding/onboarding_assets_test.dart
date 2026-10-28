import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/app/app.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/onboarding/onboarding_splash_screen.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/account.dart';
import 'package:sossoldi/mock/models/account_edit.dart';

import '../../load_test_fonts.dart';

final _now = DateTime(2026, 10, 22, 10);

/// The onboarding on step 3: a new user with an account and a category.
Future<AppState> _step3(
  WidgetTester tester, {
  Brightness? brightness,
  String device = 'en',
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
  state.startOnboarding();
  await tester.pump();
  await tester.pump(OnboardingSplashScreen.duration);
  await tester.pump(
    OnboardingSplashScreen.exitDuration +
        OnboardingSplashScreen.exitGap +
        const Duration(milliseconds: 20),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byType(SossoldiButton).first);
  await tester.pumpAndSettle();
  state.repository.addAccount(
    AccountDraft(
      name: 'Checking',
      initialBalance: 100,
      currency: 'EUR',
      color: CategoryColors.all.first,
      icon: PhosphorIconsRegular.bank,
      type: AccountType.checking,
    ),
  );
  await tester.pump();
  await tester.tap(find.byIcon(PhosphorIconsRegular.caretRight));
  await tester.pumpAndSettle();
  state.repository.addSuggestedCategory(
    state.repository.suggestedCategoriesLeft().first,
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(PhosphorIconsRegular.caretRight));
  await tester.pumpAndSettle();
  return state;
}

Finder get _fields => find.byType(EditableText);

String _firstEtf(MockRepository repo) => repo.assetCatalog
    .firstWhere((a) => a.name.contains('Vanguard') || a.ticker == 'VWCE')
    .id;

void main() {
  setUpAll(loadTestFonts);

  testWidgets('empty: header, empty card and the skip link', (tester) async {
    await _step3(tester);
    expect(find.text('Step 3 of 3'), findsOneWidget);
    expect(
      find.text('And your investments and keep track of them in the app'),
      findsOneWidget,
    );
    expect(find.text('Your assets'), findsOneWidget);
    expect(find.text('No asset yet'), findsOneWidget);
    expect(find.text('Add asset'), findsOneWidget);
    expect(find.text('Skip this step'), findsOneWidget);
    expect(find.text('Start tracking'), findsNothing);
  });

  testWidgets('with assets: the list, "Add asset" and "Start tracking"', (
    tester,
  ) async {
    final state = await _step3(tester);
    final repo = state.repository;
    repo.addOpeningAsset(
      assetId: _firstEtf(repo),
      quantity: 212,
      averageCost: 36.312,
    );
    await tester.pumpAndSettle();
    expect(find.text('No asset yet'), findsNothing);
    expect(find.text('Skip this step'), findsNothing);
    expect(find.text('Start tracking'), findsOneWidget);
    expect(find.text('Add asset'), findsOneWidget);
    // The row: value = quantity x PMC (not the market value), the details.
    final row = tester.widget<SossoldiAssetItem>(
      find.byType(SossoldiAssetItem),
    );
    expect(row.value, closeTo(212 * 36.312, 0.01));
    expect(row.details.map((d) => d.$1), ['Quantity:', 'PMC:']);
    expect(row.details.first.$2, '212');
    expect(row.typeLabel, 'ETF');
  });

  testWidgets('the form of an asset: fields, validation and saving', (
    tester,
  ) async {
    final state = await _step3(tester);
    final repo = state.repository;
    await tester.tap(find.text('Add asset'));
    await tester.pumpAndSettle();
    expect(find.text('New asset'), findsOneWidget);
    for (final t in [
      'Main details',
      'Type',
      'Asset',
      'Amount',
      'Average purchase price',
      'Counts for Net Worth',
    ]) {
      expect(find.text(t), findsOneWidget);
    }
    // The switch starts on, the check off.
    expect(
      tester.widget<SossoldiSwitchRow>(find.byType(SossoldiSwitchRow)).value,
      isTrue,
    );
    SossoldiBottomSheetToolbar toolbar() =>
        tester.widget(find.byType(SossoldiBottomSheetToolbar));
    expect(toolbar().confirmEnabled, isFalse);

    // A manual asset: the name, the amount and the price.
    await tester.tap(find.text('Select asset type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manual asset').hitTestable().last);
    await tester.pumpAndSettle();
    await tester.enterText(_fields.at(0), 'Stamps');
    await tester.enterText(_fields.at(1), '0');
    await tester.pump();
    expect(find.text('The amount must be greater than zero'), findsOneWidget);
    await tester.enterText(_fields.at(1), '0,123456789');
    await tester.pump();
    expect(find.text('At most 8 decimals'), findsOneWidget);
    await tester.enterText(_fields.at(1), '2,5');
    await tester.enterText(_fields.at(2), '100');
    await tester.pump();
    expect(toolbar().confirmEnabled, isTrue);
    await tester.tap(find.byIcon(PhosphorIconsRegular.check).last);
    await tester.pumpAndSettle();
    expect(find.text('New asset'), findsNothing);
    final h = repo.openingAssets.single;
    expect(h.manualName, 'Stamps');
    expect(h.quantity, 2.5);
    expect(h.averageCost, 100);
    expect(find.text('STAMPS'), findsOneWidget);
  });

  testWidgets('a duplicate shows an inline error and cannot be saved', (
    tester,
  ) async {
    final state = await _step3(tester);
    final repo = state.repository;
    repo.addOpeningAsset(manualName: 'Stamps', quantity: 1, averageCost: 5);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add asset'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select asset type'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manual asset').hitTestable().last);
    await tester.pumpAndSettle();
    await tester.enterText(_fields.at(0), 'stamps');
    await tester.enterText(_fields.at(1), '1');
    await tester.enterText(_fields.at(2), '1');
    await tester.pump();
    expect(
      find.text('You already have a manual asset with this name'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<SossoldiBottomSheetToolbar>(
            find.byType(SossoldiBottomSheetToolbar),
          )
          .confirmEnabled,
      isFalse,
    );
    expect(repo.openingAssets, hasLength(1));
  });

  testWidgets('editing: type and asset are fixed; delete asks and removes', (
    tester,
  ) async {
    final state = await _step3(tester);
    final repo = state.repository;
    repo.addOpeningAsset(manualName: 'Stamps', quantity: 2, averageCost: 50);
    await tester.pumpAndSettle();
    await tester.tap(find.text('STAMPS'));
    await tester.pumpAndSettle();
    expect(find.text('Edit asset'), findsOneWidget);
    expect(find.text('Delete asset'), findsOneWidget);
    // Change the quantity and the flag.
    await tester.enterText(_fields.at(1), '4');
    await tester.pump();
    await tester.tap(find.byType(SossoldiSwitch));
    await tester.pump();
    await tester.tap(find.byIcon(PhosphorIconsRegular.check).last);
    await tester.pumpAndSettle();
    final h = repo.openingAssets.single;
    expect(h.quantity, 4);
    expect(h.countsForNetWorth, isFalse);
    // Delete.
    await tester.tap(find.text('STAMPS'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Delete asset'));
    await tester.tap(find.text('Delete asset'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this asset?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(repo.openingAssets, isEmpty);
    expect(repo.holdings, isEmpty);
    expect(find.text('No asset yet'), findsOneWidget);
  });

  testWidgets('back goes to step 2 keeping the data', (tester) async {
    final state = await _step3(tester);
    state.repository.addOpeningAsset(
      manualName: 'Stamps',
      quantity: 1,
      averageCost: 5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 3'), findsOneWidget);
    expect(state.repository.categories(), hasLength(1));
    await tester.tap(find.byIcon(PhosphorIconsRegular.caretRight));
    await tester.pumpAndSettle();
    expect(find.text('STAMPS'), findsOneWidget);
  });

  testWidgets('start tracking closes the flow on the new user, on Home; the '
      'system back does not return', (tester) async {
    final state = await _step3(tester);
    final repo = state.repository;
    repo.addOpeningAsset(manualName: 'Stamps', quantity: 1, averageCost: 5);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start tracking'));
    await tester.pumpAndSettle();
    expect(state.onboardingActive, isFalse);
    expect(identical(state.repository, repo), isTrue);
    expect(find.text('Step 3 of 3'), findsNothing);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Monthly balance'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(state.onboardingActive, isFalse);
    expect(find.text('Step 2 of 3'), findsNothing);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('skipping ends the flow with no assets', (tester) async {
    final state = await _step3(tester);
    await tester.tap(find.text('Skip this step'));
    await tester.pumpAndSettle();
    expect(state.onboardingActive, isFalse);
    expect(state.repository.holdings, isEmpty);
    expect(find.text('Home'), findsOneWidget);
    // Load demo data is still the way back to the full data.
    state.loadDemoData();
    await tester.pumpAndSettle();
    expect(state.repository.accounts, hasLength(3));
  });

  for (final brightness in Brightness.values) {
    testWidgets('step 3 and its form render in $brightness', (tester) async {
      final state = await _step3(tester, brightness: brightness);
      state.repository.addOpeningAsset(
        assetId: _firstEtf(state.repository),
        quantity: 0.00012345,
        averageCost: 36.312,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Add asset'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('in Italian', (tester) async {
    await _step3(tester, device: 'it');
    expect(find.text('Passo 3 di 3'), findsOneWidget);
    expect(find.text('I tuoi asset'), findsOneWidget);
    expect(find.text('Salta questo passo'), findsOneWidget);
  });
}
