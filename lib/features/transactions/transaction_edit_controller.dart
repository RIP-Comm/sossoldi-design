import 'package:flutter/widgets.dart';

import '../../mock/date_utils.dart';
import '../../mock/mock_repository.dart';
import '../../mock/models/subcategory.dart';
import '../../mock/models/transaction.dart';
import '../../mock/models/transaction_edit.dart';
import '../accounts/account_form_controller.dart' show parseAmount;

/// State of the form that edits one transaction already made: it keeps what
/// was typed and turns it into a [TransactionDraft]. The type never changes.
/// The repository does the rest and may refuse.
class TransactionEditController extends ChangeNotifier {
  TransactionEditController(
    this.repository, {
    required this.locale,
    required this.transaction,
  }) : _accountId = transaction.accountId,
       _toAccountId = transaction.toAccountId,
       _categoryId = transaction.categoryId,
       _subcategoryId = transaction.subcategoryId,
       _date = dateOnly(transaction.date) {
    amount.text = _format(transaction.amount);
    description.text = transaction.description;
    amount.addListener(_typed);
    description.addListener(_typed);
  }

  final MockRepository repository;
  final String locale;
  final Transaction transaction;

  final amount = TextEditingController();
  final description = TextEditingController();

  String _accountId;
  String? _toAccountId;
  String? _categoryId;
  String? _subcategoryId;
  DateTime _date;
  bool _submitted = false;
  TransactionFailure? _failure;

  bool get isTransfer => transaction.type == TransactionType.transfer;
  String get accountId => _accountId;
  String? get toAccountId => _toAccountId;
  String? get categoryId => _categoryId;
  String? get subcategoryId => _subcategoryId;
  DateTime get date => _date;
  bool get submitted => _submitted;
  TransactionFailure? get failure => _failure;

  String get currency => repository.account(_accountId).currency;

  /// The subcategories of the category chosen.
  List<Subcategory> get subcategories =>
      _categoryId == null ? const [] : repository.subcategoriesOf(_categoryId!);

  static String _format(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString().replaceAll('.', ',');

  void _typed() {
    _failure = null;
    notifyListeners();
  }

  void setAccount(String id) {
    if (id == _accountId) return;
    _accountId = id;
    // A transfer cannot go to itself: the other side takes the old place.
    if (isTransfer && _toAccountId == id) _toAccountId = transaction.accountId;
    _typed();
  }

  void setToAccount(String id) {
    if (id == _toAccountId) return;
    _toAccountId = id;
    _typed();
  }

  void setCategory(String id) {
    if (id == _categoryId) return;
    _categoryId = id;
    _subcategoryId = null;
    _typed();
  }

  void setSubcategory(String? id) {
    if (id == _subcategoryId) return;
    _subcategoryId = id;
    _typed();
  }

  void setDate(DateTime value) {
    _date = dateOnly(value);
    _typed();
  }

  double? get parsedAmount {
    final v = parseAmount(amount.text, locale);
    return v != null && v > 0 ? v : null;
  }

  bool get amountMissing => parsedAmount == null;

  /// Whether the form can be saved: the check of the toolbar is on.
  bool get isValid =>
      parsedAmount != null &&
      (isTransfer
          ? _toAccountId != null && _toAccountId != _accountId
          : _categoryId != null);

  TransactionDraft get draft => TransactionDraft(
    type: transaction.type,
    amount: parsedAmount ?? 0,
    accountId: _accountId,
    date: _date,
    toAccountId: isTransfer ? _toAccountId : null,
    categoryId: isTransfer ? null : _categoryId,
    subcategoryId: isTransfer ? null : _subcategoryId,
    description: description.text,
  );

  /// Saves the changes. False when the form is not valid or the repository
  /// refused ([failure] says why).
  bool submit() {
    _submitted = true;
    if (!isValid) {
      notifyListeners();
      return false;
    }
    final result = repository.updateTransaction(transaction.id, draft);
    _failure = result.failure;
    notifyListeners();
    return result.ok;
  }

  /// Deletes the transaction.
  bool delete() => repository.deleteTransaction(transaction.id);

  @override
  void dispose() {
    amount.dispose();
    description.dispose();
    super.dispose();
  }
}
