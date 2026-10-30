import 'package:flutter/widgets.dart';

import '../../mock/date_utils.dart';
import '../../mock/mock_repository.dart';
import '../../mock/models/category.dart';
import '../../mock/models/recurring_transaction.dart';
import '../../mock/models/subcategory.dart';
import '../../mock/models/transaction.dart';
import '../../mock/models/transaction_edit.dart';
import '../accounts/account_form_controller.dart' show parseAmount;
import '../investments/movements/movement_form_controller.dart' show FieldError;
import 'add_sheet_draft.dart';

/// Which chip of the date row is on.
enum DateChoice { today, yesterday, other }

/// State of the transaction form of the Add sheet: it keeps what was typed,
/// proposes categories and descriptions from the past, checks everything and
/// turns it into a [TransactionDraft]. The repository does the rest.
class TransactionFormController extends ChangeNotifier {
  TransactionFormController(
    this.repository, {
    required this.locale,
    AddSheetDraft? draft,
  }) : _type = draft?.transactionType ?? TransactionType.expense,
       _date = draft?.date == null ? repository.today : dateOnly(draft!.date!),
       _accountId = draft?.accountId,
       _toAccountId = draft?.toAccountId,
       _categoryId = draft?.categoryId,
       _subcategoryId = draft?.subcategoryId,
       _recurring = draft?.recurring ?? false {
    if (draft?.amount != null) {
      final v = draft!.amount!;
      amount.text = v == v.roundToDouble() ? v.toStringAsFixed(0) : '$v';
    }
    description.text = draft?.description ?? '';
    _categoryPicked = _categoryId != null;
    amount.addListener(_amountTyped);
    toAmount.addListener(_toAmountTyped);
    description.addListener(_descriptionChanged);
    count.addListener(_typed);
    _syncToAccount();
  }

  final MockRepository repository;
  final String locale;

  final amount = TextEditingController();
  final toAmount = TextEditingController();
  final description = TextEditingController();
  final count = TextEditingController(text: '12');

  /// To put the focus back on the amount (after "Add and create another").
  final amountFocus = FocusNode();

  TransactionType _type;
  DateTime _date;
  String? _accountId;
  String? _toAccountId;
  String? _categoryId;
  String? _subcategoryId;

  /// The user chose the category (a proposal never replaces it).
  bool _categoryPicked = false;
  bool _toAmountEdited = false;
  bool _recurring;
  RecurrenceFrequency _frequency = RecurrenceFrequency.monthly;
  DateTime? _startDate;
  RecurrenceEnd _end = RecurrenceEnd.never;
  DateTime? _endDate;
  bool _submitted = false;
  TransactionFailure? _failure;

  TransactionType get type => _type;
  bool get isTransfer => _type == TransactionType.transfer;
  CategoryType get categoryType => _type == TransactionType.income
      ? CategoryType.income
      : CategoryType.expense;
  DateTime get date => _date;
  String? get categoryId => _categoryId;
  String? get subcategoryId => _subcategoryId;
  bool get recurring => _recurring;
  RecurrenceFrequency get frequency => _frequency;
  RecurrenceEnd get end => _end;
  bool get submitted => _submitted;
  TransactionFailure? get failure => _failure;

  /// The account (the main one until another is chosen).
  String? get accountId =>
      _accountId ??
      repository.mainAccount?.id ??
      repository.accounts.firstOrNull?.id;

  /// The destination of a transfer: the first account that is not the
  /// source, until one is chosen.
  String? get toAccountId => _toAccountId;

  String get currency => accountId == null
      ? repository.mainCurrency
      : repository.account(accountId!).currency;

  String? get toCurrency =>
      _toAccountId == null ? null : repository.account(_toAccountId!).currency;

  /// A transfer needs two accounts.
  bool get transferPossible => repository.accounts.length >= 2;

  /// Accounts with different currencies: "Amount received" shows.
  bool get crossCurrency =>
      isTransfer && toCurrency != null && toCurrency != currency;

  DateChoice get dateChoice {
    if (_date == repository.today) return DateChoice.today;
    if (_date == addDays(repository.today, -1)) return DateChoice.yesterday;
    return DateChoice.other;
  }

  /// The start of the recurrence: the date chosen until set on its own.
  DateTime get startDate => _startDate ?? _date;
  DateTime? get endDate => _endDate;

  // Actions

  /// True while the code (not the user) changes the texts.
  bool _quiet = false;

  void _typed() {
    if (_quiet) return;
    _failure = null;
    notifyListeners();
  }

  void _amountTyped() {
    if (_quiet) return;
    _refreshToAmount();
    _typed();
  }

  /// Runs [change] without the listeners of the texts reacting.
  void _silently(VoidCallback change) {
    _quiet = true;
    change();
    _quiet = false;
  }

  void setType(TransactionType t) {
    if (t == _type) return;
    _type = t;
    _failure = null;
    if (t != TransactionType.transfer) {
      // The category belongs to the type.
      final category = _categoryId == null
          ? null
          : repository.category(_categoryId!);
      if (category != null && category.type != categoryType) {
        _categoryId = null;
        _subcategoryId = null;
        _categoryPicked = false;
      }
      _applySuggestion();
    }
    _syncToAccount();
    notifyListeners();
  }

  void setAccount(String id) {
    _accountId = id;
    _syncToAccount();
    _refreshToAmount();
    notifyListeners();
  }

  void setToAccount(String id) {
    _toAccountId = id;
    _toAmountEdited = false;
    _refreshToAmount();
    notifyListeners();
  }

  void swapAccounts() {
    final from = accountId;
    final to = _toAccountId;
    if (from == null || to == null) return;
    _accountId = to;
    _toAccountId = from;
    _toAmountEdited = false;
    _refreshToAmount();
    notifyListeners();
  }

  /// Keeps the destination valid: not the source, and an account if there
  /// is another one.
  void _syncToAccount() {
    final from = accountId;
    final others = [
      for (final a in repository.accounts)
        if (a.id != from) a.id,
    ];
    if (_toAccountId == null || _toAccountId == from) {
      _toAccountId = others.firstOrNull;
      _toAmountEdited = false;
    }
  }

  void setDate(DateTime d) {
    _date = dateOnly(d);
    _failure = null;
    notifyListeners();
  }

  void setCategory(String id, {String? subcategoryId}) {
    _categoryId = id;
    _subcategoryId = subcategoryId;
    _categoryPicked = true;
    _failure = null;
    notifyListeners();
  }

  void setSubcategory(String? id) {
    _subcategoryId = id == _subcategoryId ? null : id;
    notifyListeners();
  }

  void setRecurring(bool on) {
    _recurring = on;
    _failure = null;
    notifyListeners();
  }

  void setFrequency(RecurrenceFrequency f) {
    _frequency = f;
    notifyListeners();
  }

  void setStartDate(DateTime d) {
    _startDate = dateOnly(d);
    notifyListeners();
  }

  void setEnd(RecurrenceEnd e) {
    _end = e;
    _failure = null;
    notifyListeners();
  }

  void setEndDate(DateTime d) {
    _endDate = dateOnly(d);
    _failure = null;
    notifyListeners();
  }

  // Proposals from the past

  CategorySuggestion? _suggestion;

  /// The category proposed by the description, if the past has one.
  CategorySuggestion? get suggestion => _suggestion;

  void _descriptionChanged() {
    if (_quiet) return;
    if (!isTransfer) _applySuggestion();
    _typed();
  }

  void _applySuggestion() {
    final found = repository.suggestCategory(description.text, categoryType);
    final changed =
        found?.categoryId != _suggestion?.categoryId ||
        found?.subcategoryId != _suggestion?.subcategoryId;
    _suggestion = found;
    if (!_categoryPicked) {
      // Preselected while the user has not chosen; gone when it stops fitting.
      if (found != null) {
        _categoryId = found.categoryId;
        _subcategoryId = found.subcategoryId;
      } else if (changed) {
        _categoryId = null;
        _subcategoryId = null;
      }
    }
  }

  /// The chips of the category row: at most five. The category proposed
  /// first, then the one chosen (if the chips did not have it), then the
  /// most used of the type.
  List<Category> get categoryChips {
    final ranked = repository.categoriesByUsage(categoryType);
    final byId = {for (final c in ranked) c.id: c};
    final ids = <String>[
      if (_suggestion != null && byId.containsKey(_suggestion!.categoryId))
        _suggestion!.categoryId,
      if (_categoryId != null && byId.containsKey(_categoryId)) _categoryId!,
      for (final c in ranked) c.id,
    ];
    return [for (final id in ids.toSet().take(5)) byId[id]!];
  }

  /// The subcategories of the category chosen.
  List<Subcategory> get subcategories =>
      _categoryId == null ? const [] : repository.subcategoriesOf(_categoryId!);

  /// Up to three past descriptions to complete the one being typed.
  List<String> get descriptionSuggestions =>
      isTransfer ? const [] : repository.pastDescriptions(description.text);

  /// A past description tapped: it fills the field and the category it was
  /// used with.
  void useDescription(String text) {
    _silently(() {
      description.text = text;
      description.selection = TextSelection.collapsed(offset: text.length);
    });
    _categoryPicked = false;
    _applySuggestion();
    notifyListeners();
  }

  // The amount received of a transfer between currencies

  void _toAmountTyped() {
    if (_quiet) return;
    _toAmountEdited = true;
    _typed();
  }

  void _refreshToAmount() {
    if (!crossCurrency || _toAmountEdited) return;
    final v = parsedAmount;
    _silently(
      () => toAmount.text = v == null || v <= 0
          ? ''
          : _format(repository.convert(v, currency, toCurrency!)),
    );
  }

  static String _format(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  double? get parsedAmount => parseAmount(amount.text, locale);
  double? get parsedToAmount => parseAmount(toAmount.text, locale);

  // Validation

  FieldError? get amountError {
    if (amount.text.trim().isEmpty) return FieldError.required;
    final v = parsedAmount;
    if (v == null) return FieldError.notANumber;
    return v > 0 ? null : FieldError.notPositive;
  }

  FieldError? get toAmountError {
    if (!crossCurrency) return null;
    if (toAmount.text.trim().isEmpty) return FieldError.required;
    final v = parsedToAmount;
    if (v == null) return FieldError.notANumber;
    return v > 0 ? null : FieldError.notPositive;
  }

  /// The category is required for an expense and an income.
  bool get categoryMissing => !isTransfer && _categoryId == null;

  bool get toAccountMissing => isTransfer && _toAccountId == null;

  FieldError? get countError {
    if (!_recurring || _end != RecurrenceEnd.afterCount) return null;
    final n = int.tryParse(count.text.trim());
    return n == null || n < 1 ? FieldError.notPositive : null;
  }

  bool get endDateMissing =>
      _recurring && _end == RecurrenceEnd.onDate && _endDate == null;

  bool get endBeforeStart =>
      _recurring &&
      _end == RecurrenceEnd.onDate &&
      _endDate != null &&
      _endDate!.isBefore(startDate);

  bool get isValid =>
      accountId != null &&
      amountError == null &&
      toAmountError == null &&
      !categoryMissing &&
      !toAccountMissing &&
      countError == null &&
      !endDateMissing &&
      !endBeforeStart;

  /// The error to show for [e]: none until a save was tried.
  FieldError? shown(FieldError? e) => _submitted ? e : null;

  /// Saves. Returns what was created, or null: then the errors show.
  AddedTransaction? submit() {
    _submitted = true;
    _failure = null;
    if (!isValid) {
      notifyListeners();
      return null;
    }
    final result = repository.addTransaction(
      TransactionDraft(
        type: _type,
        amount: parsedAmount!,
        accountId: accountId!,
        date: _date,
        toAccountId: isTransfer ? _toAccountId : null,
        toAmount: crossCurrency ? parsedToAmount : null,
        categoryId: isTransfer ? null : _categoryId,
        subcategoryId: isTransfer ? null : _subcategoryId,
        description: description.text,
        recurrence: _recurring
            ? RecurrenceDraft(
                frequency: _frequency,
                startDate: startDate,
                end: _end,
                endDate: _endDate,
                count: int.tryParse(count.text.trim()),
              )
            : null,
      ),
    );
    if (!result.ok) {
      _failure = result.failure;
      notifyListeners();
      return null;
    }
    return result.added;
  }

  @override
  void dispose() {
    for (final c in [amount, toAmount, description, count]) {
      c.dispose();
    }
    amountFocus.dispose();
    super.dispose();
  }
}
