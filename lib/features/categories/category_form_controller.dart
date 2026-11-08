import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../design_system/tokens/category_colors.dart';
import '../../mock/mock_repository.dart';
import '../../mock/models/budget.dart';
import '../../mock/models/category.dart';
import '../../mock/models/category_edit.dart';

/// What is wrong in a field of the category form, to be written in the
/// user's language by the screen.
enum CategoryFieldError { nameRequired, nameTaken }

/// State of the category form (new or edit). Everything added in it, budgets
/// and subcategories included, stays in a draft: the repository is touched
/// only by [submit], and closing the form with the X discards the draft.
class CategoryFormController extends ChangeNotifier {
  CategoryFormController(
    this.repository, {
    this.editing,
    CategoryType initialType = CategoryType.expense,
  }) : _type = editing?.type ?? initialType,
       _color = editing?.color ?? CategoryColors.all.first,
       _icon = editing?.icon ?? PhosphorIconsRegular.tag {
    final c = editing;
    if (c != null) {
      name.text = c.name;
      _subcategories.addAll([
        for (final s in repository.subcategoriesOf(c.id))
          SubcategoryDraft(id: s.id, name: s.name),
      ]);
      _budgets.addAll([
        for (final b in repository.budgetsForCategory(c.id))
          BudgetDraft(
            id: b.id,
            period: b.period,
            amount: repository.toMain(b.amount, b.currency),
            limitAlert: b.limitAlert,
            countForOverall: b.countForOverall,
          ),
      ]);
    }
    name.addListener(_typed);
  }

  final MockRepository repository;

  /// The category being changed; null when creating one.
  final Category? editing;

  final name = TextEditingController();
  final _subcategories = <SubcategoryDraft>[];
  final _budgets = <BudgetDraft>[];

  CategoryType _type;
  CategoryColor _color;
  IconData _icon;
  bool _nameTouched = false;
  bool _submitted = false;
  CategoryFailure? _failure;

  bool get isEditing => editing != null;
  CategoryType get type => _type;
  CategoryColor get color => _color;
  IconData get icon => _icon;

  /// What the repository refused with, if it did.
  CategoryFailure? get failure => _failure;

  List<SubcategoryDraft> get subcategories => List.unmodifiable(_subcategories);

  /// The budgets of the draft, shortest period first. Always empty for an
  /// income category.
  List<BudgetDraft> get budgets => List.unmodifiable(
    List.of(_budgets)..sort((a, b) => a.period.index.compareTo(b.period.index)),
  );

  void _typed() {
    _nameTouched = _nameTouched || name.text.isNotEmpty;
    _failure = null;
    notifyListeners();
  }

  /// Changes the type. Income has no budgets: the ones of the draft are
  /// discarded (the screen asks before).
  void setType(CategoryType value) {
    if (value == _type) return;
    _type = value;
    if (value == CategoryType.income) _budgets.clear();
    _failure = null;
    notifyListeners();
  }

  void setColor(CategoryColor value) {
    if (value == _color) return;
    _color = value;
    notifyListeners();
  }

  void setIcon(IconData value) {
    if (value == _icon) return;
    _icon = value;
    notifyListeners();
  }

  // Subcategories

  /// Whether another subcategory of the draft has [subcategoryName]; [index]
  /// is the one being edited, if any.
  bool subcategoryNameTaken(String subcategoryName, {int? index}) {
    final wanted = subcategoryName.trim().toLowerCase();
    for (final (i, s) in _subcategories.indexed) {
      if (i != index && s.name.trim().toLowerCase() == wanted) return true;
    }
    return false;
  }

  void addSubcategory(String subcategoryName) {
    _subcategories.add(SubcategoryDraft(name: subcategoryName.trim()));
    notifyListeners();
  }

  void renameSubcategory(int index, String subcategoryName) {
    final old = _subcategories[index];
    _subcategories[index] = SubcategoryDraft(
      id: old.id,
      name: subcategoryName.trim(),
    );
    notifyListeners();
  }

  void removeSubcategory(int index) {
    _subcategories.removeAt(index);
    notifyListeners();
  }

  // Budgets

  /// The periods the draft already has a budget on; [index] (of [budgets])
  /// is the one being edited, whose own period stays free.
  Set<BudgetPeriod> takenPeriods({int? index}) {
    final sorted = budgets;
    return {
      for (final (i, b) in sorted.indexed)
        if (i != index) b.period,
    };
  }

  void addBudget(BudgetDraft budget) {
    _budgets.add(budget);
    notifyListeners();
  }

  /// Replaces the budget at [index] of [budgets].
  void updateBudget(int index, BudgetDraft budget) {
    final target = budgets[index];
    _budgets[_budgets.indexOf(target)] = budget;
    notifyListeners();
  }

  void removeBudget(int index) {
    _budgets.remove(budgets[index]);
    notifyListeners();
  }

  // Saving

  CategoryFieldError? get _nameError {
    if (name.text.trim().isEmpty) return CategoryFieldError.nameRequired;
    if (repository.categoryNameTaken(
      name.text,
      _type,
      excluding: editing?.id,
    )) {
      return CategoryFieldError.nameTaken;
    }
    return null;
  }

  /// The error of the name, once the user has typed in it or tried to save
  /// (a name already taken shows at once).
  CategoryFieldError? get nameError {
    final e = _nameError;
    if (e == CategoryFieldError.nameTaken) return e;
    return _nameTouched || _submitted ? e : null;
  }

  /// Whether the form can be saved: the check of the toolbar is on.
  bool get isValid => _nameError == null;

  CategorySave get save => CategorySave(
    category: CategoryDraft(
      type: _type,
      name: name.text,
      icon: _icon,
      color: _color,
    ),
    subcategories: List.of(_subcategories),
    budgets: _type == CategoryType.expense ? budgets : const [],
  );

  /// Saves the category with its subcategories and budgets. False when the
  /// form is not valid or the repository refused ([failure] says why).
  bool submit() {
    _submitted = true;
    if (!isValid) {
      notifyListeners();
      return false;
    }
    final result = isEditing
        ? repository.updateCategory(editing!.id, save)
        : repository.addCategory(save);
    _failure = result.failure;
    notifyListeners();
    return result.ok;
  }

  /// Deletes the category being edited. False when something refers to it.
  bool delete() {
    final result = repository.deleteCategory(editing!.id);
    _failure = result.failure;
    notifyListeners();
    return result.ok;
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }
}
