import 'package:flutter/foundation.dart';

import '../../../mock/mock_repository.dart';
import '../../../mock/models/recurring_occurrence.dart';
import '../../../mock/models/recurring_transaction.dart';

/// Why the amount typed in edit mode cannot be saved.
enum RecurringAmountError { required, notPositive }

/// State of the page of one recurring transaction: the old transactions
/// (time range) and the edit mode with the period, the amount and the
/// active switch being changed. Nothing is saved until Done; the numbers
/// come from the repository.
class RecurringDetailController extends ChangeNotifier {
  RecurringDetailController(this.repository, this.recurringId) {
    repository.addListener(notifyListeners);
  }

  final MockRepository repository;
  final String recurringId;

  RecurringHistoryRange _range = RecurringHistoryRange.last6Months;
  bool _editing = false;
  RecurrenceFrequency? _draftFrequency;
  String _draftAmount = '';
  bool _draftActive = true;
  RecurringAmountError? _error;

  @override
  void dispose() {
    repository.removeListener(notifyListeners);
    super.dispose();
  }

  /// Null once it was deleted.
  RecurringTransaction? get recurring {
    for (final r in repository.recurringTransactions()) {
      if (r.id == recurringId) return r;
    }
    return null;
  }

  // Old transactions

  RecurringHistoryRange get range => _range;

  List<RecurringYearGroup> get history =>
      repository.recurringHistory(recurringId, range: _range);

  void selectRange(RecurringHistoryRange range) {
    _range = range;
    notifyListeners();
  }

  // Edit mode

  bool get isEditing => _editing;

  /// What the fields show: the draft while editing, else what is saved.
  RecurrenceFrequency get frequency =>
      _editing ? _draftFrequency! : recurring!.frequency;

  bool get isActive =>
      _editing ? _draftActive : recurring!.status == RecurringStatus.active;

  /// Set once Done was tried with an amount that cannot be saved; cleared
  /// when the text changes.
  RecurringAmountError? get amountError => _error;

  /// Starts editing with [amountText] (the current amount) in the field.
  void startEditing(String amountText) {
    final r = recurring!;
    _editing = true;
    _draftFrequency = r.frequency;
    _draftAmount = amountText;
    _draftActive = r.status == RecurringStatus.active;
    _error = null;
    notifyListeners();
  }

  void setFrequency(RecurrenceFrequency f) {
    _draftFrequency = f;
    notifyListeners();
  }

  void setAmount(String text) {
    _draftAmount = text;
    _error = null;
    notifyListeners();
  }

  void setActive(bool active) {
    _draftActive = active;
    notifyListeners();
  }

  /// Leaves edit mode and forgets what was changed.
  void cancelEditing() {
    _editing = false;
    _error = null;
    notifyListeners();
  }

  /// The field lost focus: checks the typed amount and shows why it cannot be
  /// used, if so. The text stays as typed until Done.
  void checkAmount() {
    if (!_editing) return;
    final error = _validate(_draftAmount);
    if (error != _error) {
      _error = error;
      notifyListeners();
    }
  }

  static RecurringAmountError? _validate(String text) {
    final value = double.tryParse(text.trim().replaceAll(',', '.'));
    if (value == null || !value.isFinite) return RecurringAmountError.required;
    if (value <= 0) return RecurringAmountError.notPositive;
    return null;
  }

  /// Saves the changes (for the dates to come only) and leaves edit mode.
  /// With an amount that is empty, not a number, zero or negative nothing is
  /// saved, edit mode stays and [amountError] says why. Returns whether it
  /// was saved.
  bool save() {
    final error = _validate(_draftAmount);
    final value = double.tryParse(_draftAmount.trim().replaceAll(',', '.'));
    if (error != null) {
      _error = error;
      notifyListeners();
      return false;
    }
    repository.updateRecurring(
      recurringId,
      amount: value,
      frequency: _draftFrequency,
      status: _draftActive ? RecurringStatus.active : RecurringStatus.paused,
    );
    _editing = false;
    _error = null;
    notifyListeners();
    return true;
  }

  /// Removes the recurring transaction; the page has to close.
  void delete() {
    _editing = false;
    repository.deleteRecurring(recurringId);
  }
}
