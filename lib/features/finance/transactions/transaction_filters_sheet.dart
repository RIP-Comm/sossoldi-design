// Filters bottom sheet for the transaction list (proposed, the Figma node
// 13:4217 only has the filter button and the chips): date, type, category,
// amount and account. Changes are kept in a draft and applied with "Apply".

import 'package:flutter/material.dart';

import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/date_utils.dart';
import '../../../mock/mock_repository.dart';
import '../../../mock/models/transaction.dart';
import '../../../mock/models/transaction_filter.dart';
import '../filter_check_row.dart';

/// Opens the sheet and returns the chosen filters, or null if cancelled.
Future<TransactionFilter?> showTransactionFiltersSheet(
  BuildContext context, {
  required MockRepository repository,
  required TransactionFilter filter,
  required TransactionFilter defaults,
  bool showDate = true,
  bool showType = true,
  bool showCategory = true,
  bool showAccount = true,
}) {
  return showModalBottomSheet<TransactionFilter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: sossoldiSheetConstraints(context),
    builder: (_) => TransactionFiltersSheet(
      repository: repository,
      filter: filter,
      defaults: defaults,
      showDate: showDate,
      showType: showType,
      showCategory: showCategory,
      showAccount: showAccount,
    ),
  );
}

enum _DatePreset {
  thisMonth,
  lastMonth,
  last3Months,
  thisYear,
  allTime,
  custom,
}

class TransactionFiltersSheet extends StatefulWidget {
  const TransactionFiltersSheet({
    super.key,
    required this.repository,
    required this.filter,
    required this.defaults,
    this.showDate = true,
    this.showType = true,
    this.showCategory = true,
    this.showAccount = true,
  });

  final MockRepository repository;
  final TransactionFilter filter;

  /// What "Reset" goes back to.
  final TransactionFilter defaults;

  /// Sections to show. A page that fixes a filter (a budget fixes the date,
  /// the type and the category) hides its section; the fixed values stay in
  /// [filter] and in [defaults] and come back unchanged.
  final bool showDate;
  final bool showType;
  final bool showCategory;
  final bool showAccount;

  @override
  State<TransactionFiltersSheet> createState() =>
      _TransactionFiltersSheetState();
}

class _TransactionFiltersSheetState extends State<TransactionFiltersSheet> {
  late TransactionFilter _draft = widget.filter;
  late _DatePreset _preset = _presetOf(widget.filter);
  late DateTime? _customStart = widget.filter.from;
  late DateTime? _customEnd = widget.filter.to;
  late final TextEditingController _min = TextEditingController(
    text: _amountText(widget.filter.minAmount),
  );
  late final TextEditingController _max = TextEditingController(
    text: _amountText(widget.filter.maxAmount),
  );

  DateTime get _today => widget.repository.today;

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  // Dates

  (DateTime?, DateTime?) _rangeOf(_DatePreset preset) {
    final t = _today;
    return switch (preset) {
      _DatePreset.thisMonth => (
        DateTime(t.year, t.month),
        DateTime(t.year, t.month + 1, 0),
      ),
      _DatePreset.lastMonth => (
        DateTime(t.year, t.month - 1),
        DateTime(t.year, t.month, 0),
      ),
      _DatePreset.last3Months => (
        DateTime(t.year, t.month - 2),
        DateTime(t.year, t.month + 1, 0),
      ),
      _DatePreset.thisYear => (DateTime(t.year), DateTime(t.year, 12, 31)),
      _DatePreset.allTime => (null, null),
      _DatePreset.custom => (_customStart, _customEnd ?? _customStart),
    };
  }

  _DatePreset _presetOf(TransactionFilter f) {
    for (final preset in _DatePreset.values) {
      if (preset == _DatePreset.custom) continue;
      final (from, to) = _rangeOf(preset);
      if (_sameDay(from, f.from) && _sameDay(to, f.to)) return preset;
    }
    return _DatePreset.custom;
  }

  static bool _sameDay(DateTime? a, DateTime? b) =>
      a == null || b == null ? a == b : dateOnly(a) == dateOnly(b);

  void _selectPreset(_DatePreset preset) {
    setState(() {
      _preset = preset;
      final (from, to) = _rangeOf(preset);
      // A custom range needs both days; until then the dates stay as they were.
      if (preset != _DatePreset.custom) {
        _draft = _draft.withDateRange(from, to);
      } else if (from != null) {
        _draft = _draft.withDateRange(from, to);
      }
    });
  }

  void _pickRange(DateTime start, DateTime? end) {
    setState(() {
      _customStart = start;
      _customEnd = end;
      _draft = _draft.withDateRange(start, end ?? start);
    });
  }

  // Multi-selects

  Set<T> _toggle<T>(Set<T> set, T value) => {
    for (final v in set)
      if (v != value) v,
    if (!set.contains(value)) value,
  };

  // Amount

  static String _amountText(double? v) => v == null
      ? ''
      : v == v.roundToDouble()
      ? v.toStringAsFixed(0)
      : v.toString();

  static double? _parse(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  TransactionFilter _withAmounts(TransactionFilter f) {
    var min = _parse(_min.text);
    var max = _parse(_max.text);
    if (min != null && max != null && min > max) (min, max) = (max, min);
    return f.withAmountRange(min, max);
  }

  void _reset() {
    setState(() {
      _draft = widget.defaults;
      _preset = _DatePreset.thisMonth;
      _customStart = null;
      _customEnd = null;
      _min.clear();
      _max.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final repo = widget.repository;

    String presetLabel(_DatePreset p) => switch (p) {
      _DatePreset.thisMonth => l10n.datePresetThisMonth,
      _DatePreset.lastMonth => l10n.datePresetLastMonth,
      _DatePreset.last3Months => l10n.datePresetLast3Months,
      _DatePreset.thisYear => l10n.datePresetThisYear,
      _DatePreset.allTime => l10n.datePresetAllTime,
      _DatePreset.custom => l10n.datePresetCustom,
    };

    String typeLabel(TransactionType t) => switch (t) {
      TransactionType.expense => l10n.typeExpense,
      TransactionType.income => l10n.typeIncome,
      TransactionType.transfer => l10n.typeTransfer,
    };

    Widget section(String title, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.s,
      children: [
        Text(
          title,
          style: context.typography.labelBoldLarge.copyWith(
            color: colors.textHigh,
          ),
        ),
        child,
      ],
    );

    final categories = repo.categories();
    final accounts = repo.accounts;

    return SossoldiBottomSheet(
      fillHeight: true,
      toolbar: SossoldiBottomSheetToolbar.text(
        title: l10n.filters,
        closeLabel: l10n.cancel,
        onClose: () => Navigator.of(context).pop(),
        confirmLabel: l10n.filtersApply,
        onConfirm: () => Navigator.of(context).pop(_withAmounts(_draft)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SossoldiSpacing.xl,
          children: [
            if (widget.showDate)
              section(
                l10n.filterDate,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: SossoldiSpacing.s,
                  children: [
                    Wrap(
                      spacing: SossoldiSpacing.s,
                      runSpacing: SossoldiSpacing.s,
                      children: [
                        for (final p in _DatePreset.values)
                          SossoldiUnitNavigator(
                            label: presetLabel(p),
                            selected: _preset == p,
                            onTap: () => _selectPreset(p),
                          ),
                      ],
                    ),
                    if (_preset == _DatePreset.custom)
                      Container(
                        padding: const EdgeInsets.all(SossoldiSpacing.s),
                        decoration: ShapeDecoration(
                          color: colors.surfaceHigh,
                          shape: RoundedSuperellipseBorder(
                            borderRadius: BorderRadius.circular(
                              SossoldiRadius.m,
                            ),
                          ),
                        ),
                        child: SossoldiDateRangePicker(
                          start: _customStart,
                          end: _customEnd,
                          lastDate: _today,
                          onChanged: _pickRange,
                          previousMonthSemanticLabel: l10n.previousMonth,
                          nextMonthSemanticLabel: l10n.nextMonth,
                        ),
                      ),
                  ],
                ),
              ),
            if (widget.showType)
              section(
                l10n.filterType,
                Wrap(
                  spacing: SossoldiSpacing.s,
                  runSpacing: SossoldiSpacing.s,
                  children: [
                    for (final t in TransactionType.values)
                      SossoldiUnitNavigator(
                        label: typeLabel(t),
                        selected: _draft.types.contains(t),
                        onTap: () => setState(
                          () => _draft = _draft.copyWith(
                            types: _toggle(_draft.types, t),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (widget.showCategory)
              section(
                l10n.filterCategory,
                SossoldiList(
                  children: [
                    for (final c in categories)
                      FilterCheckRow(
                        icon: Icon(c.icon, size: 24, color: c.color.main),
                        label: c.name,
                        checked: _draft.categoryIds.contains(c.id),
                        onToggle: () => setState(
                          () => _draft = _draft.copyWith(
                            categoryIds: _toggle(_draft.categoryIds, c.id),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            section(
              l10n.filterAmount,
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: SossoldiSpacing.xs,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: SossoldiSpacing.s,
                    children: [
                      Expanded(
                        child: SossoldiTextInput(
                          controller: _min,
                          placeholder: l10n.amountMin,
                          suffixText: SossoldiAmountFormat.currencySymbol(
                            context,
                            repo.mainCurrency,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      Expanded(
                        child: SossoldiTextInput(
                          controller: _max,
                          placeholder: l10n.amountMax,
                          suffixText: SossoldiAmountFormat.currencySymbol(
                            context,
                            repo.mainCurrency,
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.showAccount)
              section(
                l10n.filterAccount,
                SossoldiList(
                  children: [
                    for (final a in accounts)
                      FilterCheckRow(
                        icon: Icon(a.icon, size: 24, color: a.color.main),
                        label: a.name,
                        checked: _draft.accountIds.contains(a.id),
                        onToggle: () => setState(
                          () => _draft = _draft.copyWith(
                            accountIds: _toggle(_draft.accountIds, a.id),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.center,
              child: SossoldiButton(
                label: l10n.filtersReset,
                type: SossoldiButtonType.ghost,
                onPressed: _reset,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
