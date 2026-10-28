import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/tokens/category_colors.dart';
import 'package:sossoldi/mock/data/suggested_category_data.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/budget.dart';
import 'package:sossoldi/mock/models/category.dart';
import 'package:sossoldi/mock/models/category_edit.dart';

final _now = DateTime(2026, 10, 22, 10);

CategorySave _save(
  String name, {
  CategoryType type = CategoryType.expense,
  List<String> subs = const [],
  List<BudgetDraft> budgets = const [],
}) => CategorySave(
  category: CategoryDraft(
    type: type,
    name: name,
    icon: PhosphorIconsRegular.tag,
    color: CategoryColors.all.first,
  ),
  subcategories: [for (final s in subs) SubcategoryDraft(name: s)],
  budgets: budgets,
);

void main() {
  late MockRepository repo;
  setUp(() => repo = MockRepository.newUser(now: _now));

  group('names', () {
    test('a category name is unique per type, capitals and spaces aside', () {
      expect(repo.addCategory(_save('Housing')).ok, isTrue);
      final dup = repo.addCategory(_save('  housing '));
      expect(dup.failure, CategoryFailure.duplicateName);
      // Same name, other type: fine.
      expect(
        repo.addCategory(_save('Housing', type: CategoryType.income)).ok,
        isTrue,
      );
      expect(repo.categories(), hasLength(2));
    });

    test('an empty name is refused', () {
      expect(
        repo.addCategory(_save('  ')).failure,
        CategoryFailure.invalidName,
      );
    });

    test('editing a category keeps its own name valid', () {
      final id = repo.addCategory(_save('Housing')).category!.id;
      expect(repo.updateCategory(id, _save('HOUSING')).ok, isTrue);
      expect(repo.category(id).name, 'HOUSING');
    });

    test('a subcategory name is unique inside its category only', () {
      final a = repo.addCategory(_save('A', subs: ['Rent'])).category!;
      final b = repo.addCategory(_save('B', subs: ['Rent'])).category!;
      expect(repo.subcategoriesOf(a.id).single.name, 'Rent');
      expect(repo.subcategoriesOf(b.id).single.name, 'Rent');
      expect(
        repo.addSubcategory(a.id, ' rent').failure,
        CategoryFailure.duplicateName,
      );
      expect(repo.addSubcategory(a.id, 'Utilities').ok, isTrue);
      // A draft with two equal names is refused whole.
      final before = repo.categories().length;
      expect(
        repo.addCategory(_save('C', subs: ['X', 'x'])).failure,
        CategoryFailure.duplicateName,
      );
      expect(repo.categories(), hasLength(before));
    });

    test('subcategories are renamed and deleted', () {
      final a = repo.addCategory(_save('A', subs: ['Rent', 'Gas'])).category!;
      final rent = repo.subcategoriesOf(a.id).first;
      expect(
        repo.updateSubcategory(rent.id, 'gas').failure,
        CategoryFailure.duplicateName,
      );
      expect(repo.updateSubcategory(rent.id, 'Mortgage').ok, isTrue);
      expect(repo.subcategory(rent.id).name, 'Mortgage');
      expect(repo.deleteSubcategory(rent.id).ok, isTrue);
      expect(repo.subcategoriesOf(a.id), hasLength(1));
    });
  });

  group('budgets', () {
    BudgetDraft b(BudgetPeriod p, double amount, {bool overall = true}) =>
        BudgetDraft(period: p, amount: amount, countForOverall: overall);

    test('one budget per period for a category', () {
      final c = repo
          .addCategory(_save('A', budgets: [b(BudgetPeriod.monthly, 100)]))
          .category!;
      expect(
        repo.addBudget(c.id, b(BudgetPeriod.monthly, 50)).failure,
        CategoryFailure.duplicatePeriod,
      );
      expect(repo.addBudget(c.id, b(BudgetPeriod.weekly, 30)).ok, isTrue);
      expect(repo.budgetsForCategory(c.id).map((x) => x.period), [
        BudgetPeriod.weekly,
        BudgetPeriod.monthly,
      ]);
      // Two drafts on the same period: refused, nothing is saved.
      final before = repo.categories().length;
      expect(
        repo
            .addCategory(
              _save(
                'B',
                budgets: [b(BudgetPeriod.weekly, 1), b(BudgetPeriod.weekly, 2)],
              ),
            )
            .failure,
        CategoryFailure.duplicatePeriod,
      );
      expect(repo.categories(), hasLength(before));
      expect(repo.budgets, hasLength(2));
    });

    test('a budget needs an amount above zero', () {
      for (final amount in [0.0, -5.0, double.nan]) {
        expect(
          repo
              .addCategory(
                _save('A$amount', budgets: [b(BudgetPeriod.monthly, amount)]),
              )
              .failure,
          CategoryFailure.invalidAmount,
        );
      }
      expect(repo.categories(), isEmpty);
    });

    test('budgets only on expense categories', () {
      expect(
        repo
            .addCategory(
              _save(
                'Work',
                type: CategoryType.income,
                budgets: [b(BudgetPeriod.monthly, 100)],
              ),
            )
            .failure,
        CategoryFailure.budgetOnIncome,
      );
      final work = repo
          .addCategory(_save('Work', type: CategoryType.income))
          .category!;
      expect(
        repo.addBudget(work.id, b(BudgetPeriod.monthly, 100)).failure,
        CategoryFailure.budgetOnIncome,
      );
    });

    test('a budget is stored in the main currency with its flags', () {
      final c = repo
          .addCategory(
            _save(
              'A',
              budgets: [
                const BudgetDraft(
                  period: BudgetPeriod.yearly,
                  amount: 130.456,
                  limitAlert: true,
                  countForOverall: false,
                ),
              ],
            ),
          )
          .category!;
      final budget = repo.budgetsForCategory(c.id).single;
      expect(budget.currency, repo.mainCurrency);
      expect(budget.amount, 130.46);
      expect(budget.limitAlert, isTrue);
      expect(budget.countForOverall, isFalse);
    });

    test('a budget can be edited, and its period moved to a free one', () {
      final c = repo
          .addCategory(
            _save(
              'A',
              budgets: [
                b(BudgetPeriod.monthly, 100),
                b(BudgetPeriod.weekly, 20),
              ],
            ),
          )
          .category!;
      final monthly = repo.budgetsForCategory(c.id).last;
      expect(
        repo.updateBudget(monthly.id, b(BudgetPeriod.weekly, 100)).failure,
        CategoryFailure.duplicatePeriod,
      );
      expect(
        repo.updateBudget(monthly.id, b(BudgetPeriod.quarterly, 300)).ok,
        isTrue,
      );
      expect(repo.budget(monthly.id).period, BudgetPeriod.quarterly);
      expect(repo.budget(monthly.id).amount, 300);
    });

    test('saving a category replaces its budgets and subcategories', () {
      final c = repo
          .addCategory(
            _save(
              'A',
              subs: ['Rent', 'Gas'],
              budgets: [b(BudgetPeriod.monthly, 100)],
            ),
          )
          .category!;
      final rent = repo.subcategoriesOf(c.id).first;
      final result = repo.updateCategory(
        c.id,
        CategorySave(
          category: CategoryDraft(
            type: CategoryType.expense,
            name: 'A',
            icon: PhosphorIconsRegular.tag,
            color: CategoryColors.all.first,
          ),
          subcategories: [SubcategoryDraft(id: rent.id, name: 'Rent!')],
        ),
      );
      expect(result.ok, isTrue);
      expect(repo.subcategoriesOf(c.id).single.id, rent.id);
      expect(repo.subcategoriesOf(c.id).single.name, 'Rent!');
      expect(repo.budgetsForCategory(c.id), isEmpty);
    });

    test('deleting a category removes its subcategories and budgets', () {
      final c = repo
          .addCategory(
            _save('A', subs: ['Rent'], budgets: [b(BudgetPeriod.monthly, 100)]),
          )
          .category!;
      expect(repo.deleteCategory(c.id).ok, isTrue);
      expect(repo.categories(), isEmpty);
      expect(repo.subcategoriesOf(c.id), isEmpty);
      expect(repo.budgets, isEmpty);
      expect(repo.deleteCategory(c.id).failure, CategoryFailure.notFound);
    });
  });

  group('suggested', () {
    test('every suggestion is offered on a new user, expenses then income', () {
      final left = repo.suggestedCategoriesLeft();
      expect(left.map((s) => s.name), [
        'Housing',
        'Groceries',
        'Stuff',
        'Health',
        'Travel',
        'Transportation',
        'Work',
        'Extra',
      ]);
      expect(left.where((s) => s.type == CategoryType.expense), hasLength(6));
    });

    test('adding one creates the category with no subcategories', () {
      final housing = suggestedCategories.first;
      final c = repo.addSuggestedCategory(housing).category!;
      expect(c.name, 'Housing');
      expect(c.type, CategoryType.expense);
      expect(c.icon, housing.icon);
      expect(repo.subcategoriesOf(c.id), isEmpty);
      expect(
        repo.suggestedCategoriesLeft().map((s) => s.name),
        isNot(contains('Housing')),
      );
    });

    test(
      'a category made by hand hides the suggestion, deleting brings it back',
      () {
        final id = repo.addCategory(_save('groceries')).category!.id;
        expect(
          repo.suggestedCategoriesLeft().map((s) => s.name),
          isNot(contains('Groceries')),
        );
        // Same name but income: the expense suggestion stays.
        final income = repo
            .addCategory(_save('Travel', type: CategoryType.income))
            .category!;
        expect(
          repo.suggestedCategoriesLeft().map((s) => s.name),
          contains('Travel'),
        );
        repo.deleteCategory(id);
        repo.deleteCategory(income.id);
        expect(repo.suggestedCategoriesLeft(), hasLength(8));
      },
    );

    test('with all of them created nothing is left', () {
      for (final s in suggestedCategories) {
        expect(repo.addSuggestedCategory(s).ok, isTrue);
      }
      expect(repo.suggestedCategoriesLeft(), isEmpty);
      expect(repo.categories(), hasLength(8));
    });
  });

  group('demo data', () {
    late MockRepository demo;
    setUp(() => demo = MockRepository(now: _now));

    test('the budgets count for the overall budget and have no alert', () {
      expect(demo.budgets, isNotEmpty);
      expect(demo.budgets.every((b) => b.countForOverall), isTrue);
      expect(demo.budgets.every((b) => !b.limitAlert), isTrue);
    });

    test('a category with transactions cannot be deleted or change type', () {
      final c = demo.categories().first;
      expect(demo.categoryInUse(c.id), isTrue);
      expect(demo.deleteCategory(c.id).failure, CategoryFailure.inUse);
      final result = demo.updateCategory(
        c.id,
        CategorySave(
          category: CategoryDraft(
            type: CategoryType.income,
            name: c.name,
            icon: c.icon,
            color: c.color,
          ),
        ),
      );
      expect(result.failure, CategoryFailure.inUse);
      expect(demo.category(c.id).type, CategoryType.expense);
    });
  });

  group('overall budget', () {
    test('sums only the budgets that count; hidden when none does', () {
      final demo = MockRepository(now: _now);
      final period = BudgetPeriod.monthly;
      final all = demo.budgetOverview(period);
      expect(all.hasOverall, isTrue);
      expect(all.overallTotal, all.total);
      expect(all.overallSpent, all.spent);

      final monthly = demo.budgets.where((b) => b.period == period).toList();
      expect(monthly.length, greaterThan(1));
      final first = monthly.first;
      demo.updateBudget(
        first.id,
        BudgetDraft(
          period: first.period,
          amount: demo.toMain(first.amount, first.currency),
          countForOverall: false,
        ),
      );
      final some = demo.budgetOverview(period);
      final excluded = demo.budgetStatus(demo.budget(first.id));
      expect(some.overallCount, monthly.length - 1);
      expect(some.overallTotal, closeTo(all.total - excluded.amount, 0.01));
      expect(some.overallSpent, closeTo(all.spent - excluded.spent, 0.01));
      // The list and the totals of the period do not change.
      expect(some.items.length, all.items.length);
      expect(some.total, all.total);
      expect(some.segments.length, all.segments.length);

      for (final b in monthly.skip(1)) {
        demo.updateBudget(
          b.id,
          BudgetDraft(
            period: b.period,
            amount: demo.toMain(b.amount, b.currency),
            countForOverall: false,
          ),
        );
      }
      final none = demo.budgetOverview(period);
      expect(none.hasOverall, isFalse);
      expect(none.overallTotal, 0);
      expect(none.items, hasLength(monthly.length));
    });
  });
}
