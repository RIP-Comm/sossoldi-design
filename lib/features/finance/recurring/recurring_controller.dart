import 'package:flutter/foundation.dart';

import '../../../mock/mock_repository.dart';
import '../../../mock/models/recurring_occurrence.dart';
import '../../../mock/models/transaction.dart';

/// State of the Recurring tab for the session: the month shown and the
/// selected day. The dates come from [MockRepository.recurringOccurrences];
/// nothing is computed here. Kept by the Finance controller, so it survives
/// tab changes.
class RecurringController extends ChangeNotifier {
  RecurringController(this.repository)
    : _month = DateTime(repository.today.year, repository.today.month) {
    repository.addListener(_repositoryChanged);
  }

  final MockRepository repository;

  /// The months that can be reached, around today.
  static const int yearsBack = 5;
  static const int yearsAhead = 5;

  DateTime _month;
  DateTime? _selectedDay;
  List<RecurringOccurrence>? _occurrences;
  Map<int, Set<TransactionType>>? _dayTypes;

  @override
  void dispose() {
    repository.removeListener(_repositoryChanged);
    super.dispose();
  }

  /// A recurring transaction was edited or deleted, or the currency changed.
  void _repositoryChanged() {
    _occurrences = null;
    _dayTypes = null;
    notifyListeners();
  }

  /// First day of the month shown (today's month at first).
  DateTime get month => _month;

  /// The selected day, or null: the whole month is listed.
  DateTime? get selectedDay => _selectedDay;

  int get firstYear => repository.today.year - yearsBack;
  int get lastYear => repository.today.year + yearsAhead;

  bool get canGoPrevious => _month.year > firstYear || _month.month > 1;
  bool get canGoNext => _month.year < lastYear || _month.month < 12;

  /// Every date of the month, by date.
  List<RecurringOccurrence> get monthOccurrences => _occurrences ??= repository
      .recurringOccurrences(_month.year, _month.month);

  /// The kinds of recurring transaction on each day of the month.
  Map<int, Set<TransactionType>> get dayTypes =>
      _dayTypes ??= repository.recurringDayTypes(_month.year, _month.month);

  /// What the list shows: the selected day's dates, or the whole month's.
  List<RecurringOccurrence> get visibleOccurrences {
    final day = _selectedDay;
    if (day == null) return monthOccurrences;
    return [
      for (final o in monthOccurrences)
        if (o.date == day) o,
    ];
  }

  /// Goes to [month] (any day of it); the selection is cleared.
  void selectMonth(DateTime month) {
    final first = DateTime(month.year, month.month);
    final clamped = first.isBefore(DateTime(firstYear))
        ? DateTime(firstYear)
        : first.isAfter(DateTime(lastYear, 12))
        ? DateTime(lastYear, 12)
        : first;
    if (clamped == _month && _selectedDay == null) return;
    _month = clamped;
    _selectedDay = null;
    _occurrences = null;
    _dayTypes = null;
    notifyListeners();
  }

  void previousMonth() => selectMonth(DateTime(_month.year, _month.month - 1));

  void nextMonth() => selectMonth(DateTime(_month.year, _month.month + 1));

  /// Selects [day]; the same day again goes back to the whole month.
  void toggleDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    _selectedDay = _selectedDay == d ? null : d;
    notifyListeners();
  }
}
