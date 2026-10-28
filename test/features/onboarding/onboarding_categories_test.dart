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
import 'package:sossoldi/mock/models/budget.dart';
import 'package:sossoldi/mock/models/category.dart';

import '../../load_test_fonts.dart';

final _now = DateTime(2026, 10, 22, 10);

/// The onboarding on step 2: a new user with one account, which opens Next
/// step on step 1.
Future<AppState> _step2(
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
  return state;
}

Finder get _fields => find.byType(EditableText);

Future<void> _check(WidgetTester tester) async {
  await tester.tap(find.byIcon(PhosphorIconsRegular.check).last);
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadTestFonts);

  testWidgets('empty: header, empty card and all the suggestions', (
    tester,
  ) async {
    await _step2(tester);
    expect(find.text('Step 2 of 3'), findsOneWidget);
    expect(
      find.text(
        'Now it’s time to create your categories and the related budgets',
      ),
      findsOneWidget,
    );
    expect(find.text('Your categories'), findsOneWidget);
    expect(find.text('Create your first category'), findsOneWidget);
    expect(find.text('Create category'), findsOneWidget);
    expect(find.text('Suggested'), findsOneWidget);
    for (final name in [
      'Housing',
      'Groceries',
      'Stuff',
      'Health',
      'Travel',
      'Transportation',
      'Work',
      'Extra',
    ]) {
      expect(find.text(name), findsOneWidget);
    }
    expect(find.text('Next step'), findsNothing);
    expect(find.text('Add category'), findsNothing);
  });

  testWidgets('the + creates the category at once, with no subcategories, '
      'in its own group of "Your categories"', (tester) async {
    final state = await _step2(tester);
    await tester.tap(find.bySemanticsLabel('Add Housing'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Add Work'));
    await tester.pumpAndSettle();
    final repo = state.repository;
    expect(repo.categories().map((c) => c.name), ['Housing', 'Work']);
    for (final c in repo.categories()) {
      expect(repo.subcategoriesOf(c.id), isEmpty);
    }
    expect(find.text('Create your first category'), findsNothing);
    expect(find.bySemanticsLabel('Add Housing'), findsNothing);
    expect(find.text('Add category'), findsOneWidget);
    expect(find.text('Next step'), findsOneWidget);
    // Expenses and Income appear in both sections (not Suggested's own
    // groups when empty).
    expect(find.text('Expenses'), findsNWidgets(2));
    expect(find.text('Income'), findsNWidgets(2));
    // No subcategories, no caret.
    expect(find.bySemanticsLabel('Show subcategories'), findsNothing);
  });

  testWidgets('a category with subcategories opens them with the caret', (
    tester,
  ) async {
    final state = await _step2(tester);
    final repo = state.repository;
    final id = repo
        .addSuggestedCategory(repo.suggestedCategoriesLeft().first)
        .category!
        .id;
    repo.addSubcategory(id, 'Rent');
    await tester.pumpAndSettle();
    expect(find.text('Rent'), findsNothing);
    await tester.tap(find.bySemanticsLabel('Show subcategories'));
    await tester.pumpAndSettle();
    expect(find.text('Rent'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Hide subcategories'));
    await tester.pumpAndSettle();
    expect(find.text('Rent'), findsNothing);
  });

  testWidgets('the back arrow next to the title goes to step 1', (
    tester,
  ) async {
    await _step2(tester);
    await tester.tap(find.bySemanticsLabel('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 3'), findsOneWidget);
  });

  testWidgets('with every suggestion added the section goes away', (
    tester,
  ) async {
    final state = await _step2(tester);
    for (final s in state.repository.suggestedCategoriesLeft()) {
      state.repository.addSuggestedCategory(s);
    }
    await tester.pumpAndSettle();
    expect(find.text('Suggested'), findsNothing);
    // Only the groups of "Your categories" are left.
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
  });

  testWidgets('a category made by hand: budget, subcategory, edit, delete', (
    tester,
  ) async {
    final state = await _step2(tester);
    final repo = state.repository;
    await tester.tap(find.text('Create category'));
    await tester.pumpAndSettle();
    expect(find.text('New category'), findsOneWidget);
    // Nothing valid yet: the check is off.
    expect(
      tester
          .widget<SossoldiBottomSheetToolbar>(
            find.byType(SossoldiBottomSheetToolbar),
          )
          .confirmEnabled,
      isFalse,
    );
    await tester.enterText(_fields.at(0), 'Pets');
    await tester.pump();

    // A budget, in its own sheet on top of this one.
    await _scrollTo(tester, find.text('Add budget'));
    await tester.tap(find.text('Add budget'));
    await tester.pumpAndSettle();
    expect(find.text('New budget'), findsOneWidget);
    expect(find.text('Monthly'), findsOneWidget);
    // The amount must be above zero.
    await tester.enterText(_fields.last, '0');
    await tester.pump();
    expect(find.text('The amount must be greater than zero.'), findsOneWidget);
    await tester.enterText(_fields.last, '130');
    await tester.pump();
    await _check(tester);
    expect(find.text('New budget'), findsNothing);
    expect(find.text('New category'), findsOneWidget);
    // Nothing is saved until the check of the category.
    expect(repo.categories(), isEmpty);
    expect(repo.budgets, isEmpty);
    await _scrollTo(tester, find.text('€130'));
    expect(find.text('Monthly'), findsOneWidget);
    expect(find.text('€130'), findsOneWidget);

    // A subcategory.
    await _scrollTo(tester, find.text('Add subcategory'));
    await tester.tap(find.text('Add subcategory'));
    await tester.pumpAndSettle();
    expect(find.text('New subcategory'), findsOneWidget);
    await tester.enterText(_fields.last, 'Vet');
    await tester.pump();
    await _check(tester);
    expect(find.text('Vet'), findsOneWidget);

    await _check(tester);
    expect(find.text('New category'), findsNothing);
    final pets = repo.categories().single;
    expect(pets.name, 'Pets');
    expect(repo.subcategoriesOf(pets.id).single.name, 'Vet');
    final budget = repo.budgetsForCategory(pets.id).single;
    expect(budget.period, BudgetPeriod.monthly);
    expect(budget.amount, 130);
    expect(budget.countForOverall, isTrue);
    expect(budget.limitAlert, isFalse);
    expect(find.text('Budget: €130, Monthly'), findsOneWidget);

    // Edit: the row opens the form, with its data.
    await tester.tap(find.text('Pets'));
    await tester.pumpAndSettle();
    expect(find.text('Edit category'), findsOneWidget);
    expect(find.text('Delete category'), findsOneWidget);
    await tester.enterText(_fields.at(0), 'Animals');
    await tester.pump();
    await _check(tester);
    expect(repo.categories().single.name, 'Animals');

    // Delete, with a confirmation; the budget goes with the category.
    await tester.tap(find.text('Animals'));
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.text('Delete category'));
    await tester.tap(find.text('Delete category'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this category?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(repo.categories(), isEmpty);
    expect(repo.budgets, isEmpty);
    expect(find.text('Create your first category'), findsOneWidget);
  });

  testWidgets('the X discards the draft, a duplicate name shows an error', (
    tester,
  ) async {
    final state = await _step2(tester);
    final repo = state.repository;
    await tester.tap(find.bySemanticsLabel('Add Housing'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add category'));
    await tester.pumpAndSettle();
    const taken = 'You already have a category of this type with this name';
    await tester.enterText(_fields.at(0), 'Pets');
    await tester.pumpAndSettle();
    expect(find.text(taken), findsNothing);
    // Capitals do not count.
    await tester.enterText(_fields.at(0), 'housing');
    await tester.pumpAndSettle();
    expect(find.text(taken), findsOneWidget);
    expect(
      tester
          .widget<SossoldiBottomSheetToolbar>(
            find.byType(SossoldiBottomSheetToolbar),
          )
          .confirmEnabled,
      isFalse,
    );
    await tester.tap(find.byIcon(PhosphorIconsRegular.x).last);
    await tester.pumpAndSettle();
    expect(repo.categories(), hasLength(1));
  });

  testWidgets('income has no budgets; changing to it asks first', (
    tester,
  ) async {
    final state = await _step2(tester);
    await tester.tap(find.text('Create category'));
    await tester.pumpAndSettle();
    await tester.enterText(_fields.at(0), 'Bonus');
    await tester.pump();
    await _scrollTo(tester, find.text('Add budget'));
    await tester.tap(find.text('Add budget'));
    await tester.pumpAndSettle();
    await tester.enterText(_fields.last, '50');
    await tester.pump();
    await _check(tester);
    await tester.ensureVisible(find.text('Expense'));
    await tester.tap(find.text('Expense'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Income').last);
    await tester.pumpAndSettle();
    expect(find.text('Change to income?'), findsOneWidget);
    // Cancelled: nothing changes.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Budget'), findsOneWidget);
    await tester.tap(find.text('Expense'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Income').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Change type'));
    await tester.pumpAndSettle();
    expect(find.text('Budget'), findsNothing);
    await _check(tester);
    final bonus = state.repository.categories().single;
    expect(bonus.type, CategoryType.income);
    expect(state.repository.budgetsForCategory(bonus.id), isEmpty);
  });

  testWidgets('a period another budget uses cannot be picked', (tester) async {
    await _step2(tester);
    await tester.tap(find.text('Create category'));
    await tester.pumpAndSettle();
    await tester.enterText(_fields.at(0), 'Fun');
    await tester.pump();
    await _scrollTo(tester, find.text('Add budget'));
    await tester.tap(find.text('Add budget'));
    await tester.pumpAndSettle();
    await tester.enterText(_fields.last, '50');
    await tester.pump();
    await _check(tester);
    await _scrollTo(tester, find.text('Add budget'));
    await tester.tap(find.text('Add budget'));
    await tester.pumpAndSettle();
    // Monthly is taken: the form starts on the first free period.
    expect(find.text('Weekly'), findsOneWidget);
    // Monthly is only left in the row of the form behind.
    expect(find.text('Monthly'), findsOneWidget);
  });

  testWidgets('back goes to step 1, next goes to step 3', (tester) async {
    final state = await _step2(tester);
    await tester.tap(find.bySemanticsLabel('Add Housing'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Step 1 of 3'), findsOneWidget);
    // What was done stays.
    expect(state.repository.categories(), hasLength(1));
    await tester.tap(find.text('Next step'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next step'));
    await tester.pumpAndSettle();
    expect(find.text('Step 3 of 3'), findsOneWidget);
  });

  for (final brightness in Brightness.values) {
    testWidgets('the screen and its forms render in $brightness', (
      tester,
    ) async {
      final state = await _step2(tester, brightness: brightness);
      state.repository.addSuggestedCategory(
        state.repository.suggestedCategoriesLeft().first,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Housing'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _scrollTo(tester, find.text('Add subcategory'));
      await tester.tap(find.text('Add subcategory'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('in Italian', (tester) async {
    await _step2(tester, device: 'it');
    expect(find.text('Passo 2 di 3'), findsOneWidget);
    expect(find.text('Le tue categorie'), findsOneWidget);
    expect(find.text('Crea la tua prima categoria'), findsOneWidget);
    expect(find.text('Suggerite'), findsOneWidget);
  });
}
