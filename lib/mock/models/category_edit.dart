import 'package:flutter/widgets.dart';

import '../../design_system/tokens/category_colors.dart';
import 'budget.dart';
import 'category.dart';

/// What the form of a category collects: the category itself. Its budgets
/// and subcategories travel with it in a [CategorySave].
@immutable
class CategoryDraft {
  const CategoryDraft({
    required this.type,
    required this.name,
    required this.icon,
    required this.color,
  });

  final CategoryType type;
  final String name;
  final IconData icon;
  final CategoryColor color;
}

/// A subcategory in a draft: [id] is null for a new one.
@immutable
class SubcategoryDraft {
  const SubcategoryDraft({this.id, required this.name});

  final String? id;
  final String name;
}

/// A budget in a draft: [id] is null for a new one. [amount] is in the main
/// currency (as the user types it); the budget is stored in it.
@immutable
class BudgetDraft {
  const BudgetDraft({
    this.id,
    required this.period,
    required this.amount,
    this.limitAlert = false,
    this.countForOverall = true,
  });

  final String? id;
  final BudgetPeriod period;
  final double amount;
  final bool limitAlert;
  final bool countForOverall;
}

/// A category with everything that goes with it, saved or refused as a whole
/// (the form of the category keeps its budgets and subcategories in a draft
/// until the check is pressed). The subcategories and budgets listed are the
/// ones that remain: an existing one that is missing is deleted.
@immutable
class CategorySave {
  const CategorySave({
    required this.category,
    this.subcategories = const [],
    this.budgets = const [],
  });

  final CategoryDraft category;
  final List<SubcategoryDraft> subcategories;
  final List<BudgetDraft> budgets;
}

/// Why a change of the categories, subcategories or budgets was not applied.
enum CategoryFailure {
  /// The name is empty.
  invalidName,

  /// Another category of the same type has the name (capitals do not count),
  /// or another subcategory of the same category.
  duplicateName,

  /// The amount of a budget is not a positive number.
  invalidAmount,

  /// The category already has a budget on that period.
  duplicatePeriod,

  /// A budget on an income category.
  budgetOnIncome,

  /// Transactions or recurrences refer to the category (or one of its
  /// subcategories): it cannot be deleted, nor change type.
  inUse,

  /// The category, subcategory or budget does not exist.
  notFound,
}

@immutable
class CategoryResult {
  const CategoryResult.ok(this.category) : failure = null;
  const CategoryResult.failed(this.failure) : category = null;

  /// The category created or changed.
  final Category? category;
  final CategoryFailure? failure;

  bool get ok => failure == null;
}
