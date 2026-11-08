import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/app/app.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/categories/categories_screen.dart';
import 'package:sossoldi/features/categories/category_detail_screen.dart';
import 'package:sossoldi/features/dashboard/model/default_dashboard_layout.dart';
import 'package:sossoldi/features/finance/recurring/recurring_detail_screen.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/category.dart';
import 'package:sossoldi/mock/models/category_edit.dart';

import '../../load_test_fonts.dart';

final _now = DateTime(2026, 10, 22, 10);

/// Opens Settings > Categories on [state]'s repository.
Future<void> _open(
  WidgetTester tester,
  AppState state, {
  String locale = 'en',
  bool dark = false,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.localeTestValue = Locale(locale);
  tester.platformDispatcher.localesTestValue = [Locale(locale)];
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearAllTestValues();
  });
  if (dark) state.setDarkMode(true);
  await tester.pumpWidget(SossoldiApp(state: state));
  await tester.pump();
  await tester.tap(
    find.byWidgetPredicate(
      (w) =>
          w is SossoldiHeaderButton &&
          (w.semanticLabel == 'Settings' || w.semanticLabel == 'Impostazioni'),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(
    find.text(locale == 'en' ? 'App settings' : 'Impostazioni app'),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text(locale == 'en' ? 'Categories' : 'Categorie'));
  await tester.pumpAndSettle();
}

AppState _demo() => AppState(repository: MockRepository(now: _now));

/// A demo category with subcategories and transactions.
Category _withSubs(MockRepository repo) => repo.categories().firstWhere(
  (c) =>
      repo.subcategoriesOf(c.id).isNotEmpty &&
      repo
          .searchTransactions(repo.categoryTransactionFilter(c.id))
          .items
          .isNotEmpty,
);

Finder _plusButton() => find.byWidgetPredicate(
  (w) => w is SossoldiHeaderButton && w.icon == PhosphorIconsRegular.plus,
);

void main() {
  setUp(() => startDashboardLayout = singleWidgetDashboardLayout);
  tearDown(() => startDashboardLayout = defaultDashboardLayout);
  setUpAll(loadTestFonts);

  testWidgets('the list: income then expenses, count and chevron per row', (
    tester,
  ) async {
    final state = _demo();
    await _open(tester, state);
    final repo = state.repository;
    expect(find.byType(CategoriesScreen), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Income')).dy,
      lessThan(tester.getTopLeft(find.text('Expenses')).dy),
    );
    expect(
      find.byType(SossoldiCategoryItem),
      findsNWidgets(repo.categories().length),
    );
    expect(
      find.byIcon(PhosphorIconsRegular.caretRight),
      findsNWidgets(repo.categories().length),
    );
    final c = _withSubs(repo);
    final n = repo.subcategoriesOf(c.id).length;
    expect(
      find.text(n == 1 ? '1 subcategory' : '$n subcategories'),
      findsWidgets,
    );
    // The add button is in the header only.
    expect(find.text('Add category'), findsNothing);
    expect(_plusButton(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the + asks for the type and opens the form with it', (
    tester,
  ) async {
    await _open(tester, _demo());
    await tester.tap(find.byType(SossoldiPopover));
    await tester.pumpAndSettle();
    expect(find.text('Income'), findsNWidgets(2)); // group title and option
    expect(find.text('Expense'), findsOneWidget);
    // Income: the form has no budgets.
    await tester.tap(find.widgetWithText(SossoldiMenuItem, 'Income'));
    await tester.pumpAndSettle();
    expect(find.text('New category'), findsOneWidget);
    expect(find.text('Add budget'), findsNothing);
    await tester.tap(find.byIcon(PhosphorIconsRegular.x).first);
    await tester.pumpAndSettle();
    // Expense: budgets are offered.
    await tester.tap(find.byType(SossoldiPopover));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(SossoldiMenuItem, 'Expense'));
    await tester.pumpAndSettle();
    expect(find.text('New category'), findsOneWidget);
    expect(find.text('Add budget'), findsOneWidget);
  });

  testWidgets('a row opens the page: subcategories, transactions, Edit', (
    tester,
  ) async {
    final state = _demo();
    await _open(tester, state);
    final repo = state.repository;
    final c = _withSubs(repo);
    await tester.tap(find.byKey(ValueKey(c.id)));
    await tester.pumpAndSettle();
    expect(find.byType(CategoryDetailScreen), findsOneWidget);
    expect(find.text('Subcategories'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.byType(SossoldiSearchField), findsOneWidget);
    expect(find.byType(SossoldiFilterButton), findsOneWidget);
    // Edit opens the same form, in edit mode.
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit category'), findsOneWidget);
    await tester.tap(find.byIcon(PhosphorIconsRegular.x).first);
    await tester.pumpAndSettle();
    // Back returns to the list.
    await tester.tap(find.byIcon(PhosphorIconsRegular.caretLeft).first);
    await tester.pumpAndSettle();
    expect(find.byType(CategoriesScreen), findsOneWidget);
  });

  testWidgets('recurring transactions of the category open their page', (
    tester,
  ) async {
    final state = _demo();
    await _open(tester, state);
    final repo = state.repository;
    final c = repo.categories().firstWhere(
      (c) => repo.recurringOfCategory(c.id).isNotEmpty,
    );
    final r = repo.recurringOfCategory(c.id).first;
    await tester.tap(find.byKey(ValueKey(c.id)));
    await tester.pumpAndSettle();
    expect(find.text('Recurring'), findsOneWidget);
    await tester.ensureVisible(find.byKey(ValueKey(r.id)));
    await tester.tap(find.byKey(ValueKey(r.id)));
    await tester.pumpAndSettle();
    expect(find.byType(RecurringDetailScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a subcategory opens its own page, without Edit', (tester) async {
    final state = _demo();
    await _open(tester, state);
    final repo = state.repository;
    final c = _withSubs(repo);
    final s = repo.subcategoriesOf(c.id).first;
    await tester.tap(find.byKey(ValueKey(c.id)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(ValueKey(s.id)));
    await tester.tap(find.byKey(ValueKey(s.id)));
    await tester.pumpAndSettle();
    expect(
      find.byType(CategoryDetailScreen, skipOffstage: false),
      findsNWidgets(2),
    );
    expect(find.text('Edit'), findsNothing);
    expect(find.text('Subcategories'), findsNothing);
    expect(find.text('Transactions'), findsWidgets);
    expect(find.byType(SossoldiSearchField), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the filters follow the page: search and the empty case', (
    tester,
  ) async {
    final state = _demo();
    await _open(tester, state);
    final repo = state.repository;
    final c = _withSubs(repo);
    await tester.tap(find.byKey(ValueKey(c.id)));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'zzzzqqq');
    await tester.pumpAndSettle();
    expect(find.text('No transactions found'), findsOneWidget);
    expect(find.text('Clear filters'), findsOneWidget);
    await tester.ensureVisible(find.text('Clear filters'));
    await tester.tap(find.text('Clear filters'));
    await tester.pumpAndSettle();
    expect(find.text('No transactions found'), findsNothing);
  });

  testWidgets('a page closes when its category is deleted', (tester) async {
    final state = AppState(repository: MockRepository.newUser(now: _now));
    final repo = state.repository;
    final id = repo
        .addCategory(
          CategorySave(
            category: CategoryDraft(
              type: CategoryType.expense,
              name: 'Temp',
              icon: PhosphorIconsRegular.tag,
              color: CategoryColors.all.first,
            ),
          ),
        )
        .category!
        .id;
    await _open(tester, state);
    await tester.tap(find.byKey(ValueKey(id)));
    await tester.pumpAndSettle();
    expect(find.byType(CategoryDetailScreen), findsOneWidget);
    expect(find.text('No transactions in this category yet.'), findsOneWidget);
    repo.deleteCategory(id);
    await tester.pumpAndSettle();
    expect(find.byType(CategoryDetailScreen), findsNothing);
    expect(find.byType(CategoriesScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a new user: the empty state, no error', (tester) async {
    final state = AppState(repository: MockRepository.newUser(now: _now));
    await _open(tester, state);
    expect(find.text('No categories yet'), findsOneWidget);
    expect(find.byType(SossoldiCategoryItem), findsNothing);
    expect(_plusButton(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Italian and dark mode', (tester) async {
    final state = _demo();
    await _open(tester, state, locale: 'it', dark: true);
    expect(find.text('Entrate'), findsOneWidget);
    expect(find.text('Spese'), findsOneWidget);
    expect(find.textContaining('sottocategori'), findsWidgets);
    final c = _withSubs(state.repository);
    await tester.tap(find.byKey(ValueKey(c.id)));
    await tester.pumpAndSettle();
    expect(find.text('Sottocategorie'), findsOneWidget);
    expect(find.text('Transazioni'), findsOneWidget);
    expect(find.text('Modifica'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('categoryTransactionFilter: category and subcategory', () {
    final repo = MockRepository(now: _now);
    final c = _withSubs(repo);
    final all = repo.searchTransactions(repo.categoryTransactionFilter(c.id));
    expect(all.items, isNotEmpty);
    expect(all.items.every((t) => t.categoryId == c.id), isTrue);
    for (final s in repo.subcategoriesOf(c.id)) {
      final sub = repo.searchTransactions(
        repo.categoryTransactionFilter(c.id, subcategoryId: s.id),
      );
      expect(sub.total, lessThanOrEqualTo(all.total));
      expect(sub.items.every((t) => t.subcategoryId == s.id), isTrue);
    }
  });
}
