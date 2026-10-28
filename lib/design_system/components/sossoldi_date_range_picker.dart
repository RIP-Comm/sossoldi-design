// Date range picker: a month calendar where the first tap sets the start
// and the second the end. Not in Figma (proposed), built from the app's
// tokens and components: month header like the pagination, selection with
// the primary color, in-between days with a light primary tint.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_icon_button.dart';
import 'sossoldi_tappable.dart';

class SossoldiDateRangePicker extends StatefulWidget {
  const SossoldiDateRangePicker({
    super.key,
    required this.start,
    required this.end,
    required this.onChanged,
    required this.lastDate,
    required this.previousMonthSemanticLabel,
    required this.nextMonthSemanticLabel,
    this.firstDate,
  });

  /// Selected range, days only. [end] is null while the second day has not
  /// been picked yet; both null: nothing selected.
  final DateTime? start;
  final DateTime? end;

  /// Called with the new range; [end] null after the first tap.
  final void Function(DateTime start, DateTime? end) onChanged;

  /// Days outside [firstDate]..[lastDate] cannot be picked.
  final DateTime? firstDate;
  final DateTime lastDate;
  final String previousMonthSemanticLabel;
  final String nextMonthSemanticLabel;

  @override
  State<SossoldiDateRangePicker> createState() =>
      _SossoldiDateRangePickerState();
}

class _SossoldiDateRangePickerState extends State<SossoldiDateRangePicker> {
  static const double _cell = 40;

  late DateTime _month = _monthOf(
    widget.end ?? widget.start ?? widget.lastDate,
  );

  static DateTime _monthOf(DateTime d) => DateTime(d.year, d.month);
  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _enabled(DateTime day) =>
      !day.isAfter(_day(widget.lastDate)) &&
      (widget.firstDate == null || !day.isBefore(_day(widget.firstDate!)));

  bool get _canGoNext => DateTime(
    _month.year,
    _month.month + 1,
  ).isBefore(DateTime(widget.lastDate.year, widget.lastDate.month + 1));

  bool get _canGoPrevious =>
      widget.firstDate == null || _month.isAfter(_monthOf(widget.firstDate!));

  void _tap(DateTime day) {
    final start = widget.start == null ? null : _day(widget.start!);
    if (start == null || widget.end != null) {
      widget.onChanged(day, null);
    } else if (day.isBefore(start)) {
      widget.onChanged(day, start);
    } else {
      widget.onChanged(start, day);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final l10n = MaterialLocalizations.of(context);
    final first = l10n.firstDayOfWeekIndex; // 0 = Sunday
    final leading =
        (DateTime(_month.year, _month.month).weekday % 7 - first + 7) % 7;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final start = widget.start == null ? null : _day(widget.start!);
    final end = widget.end == null ? null : _day(widget.end!);
    final today = _day(DateTime.now());

    Widget dayCell(int index) {
      final dayNumber = index - leading + 1;
      if (dayNumber < 1 || dayNumber > daysInMonth) {
        return const SizedBox(height: _cell);
      }
      final day = DateTime(_month.year, _month.month, dayNumber);
      final isStart = start != null && day == start;
      final isEnd = end != null && day == end;
      final inRange =
          start != null &&
          end != null &&
          day.isAfter(start) &&
          day.isBefore(end);
      final enabled = _enabled(day);
      final selected = isStart || isEnd;
      return SizedBox(
        height: _cell,
        child: SossoldiTappable(
          onTap: enabled ? () => _tap(day) : null,
          semanticLabel: l10n.formatFullDate(day),
          selected: selected,
          child: Stack(
            children: [
              // The range band, flat on the inner sides.
              if (inRange || (selected && start != end && end != null))
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: isStart ? _cell / 2 : 0,
                      right: isEnd ? _cell / 2 : 0,
                    ),
                    child: ColoredBox(
                      color: colors.primary.surface.withValues(alpha: 0.14),
                    ),
                  ),
                ),
              Center(
                child: Container(
                  width: _cell - 4,
                  height: _cell - 4,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: selected ? colors.primary.surface : null,
                    shape: RoundedSuperellipseBorder(
                      borderRadius: BorderRadius.circular(SossoldiRadius.s),
                      side: !selected && day == today
                          ? BorderSide(color: colors.primary.stroke)
                          : BorderSide.none,
                    ),
                  ),
                  child: Text(
                    '$dayNumber',
                    style: typography.labelLarge.copyWith(
                      color: selected
                          ? colors.primary.onSurface
                          : enabled
                          ? colors.textHigh
                          : colors.textLow,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final rows = ((leading + daysInMonth) / 7).ceil();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SossoldiIconButton(
              icon: PhosphorIconsRegular.caretLeft,
              semanticLabel: widget.previousMonthSemanticLabel,
              onPressed: _canGoPrevious
                  ? () => setState(
                      () => _month = DateTime(_month.year, _month.month - 1),
                    )
                  : null,
            ),
            Expanded(
              child: Text(
                toBeginningOfSentenceCase(l10n.formatMonthYear(_month)) ?? '',
                textAlign: TextAlign.center,
                style: typography.titleMedium.copyWith(color: colors.textHigh),
              ),
            ),
            SossoldiIconButton(
              icon: PhosphorIconsRegular.caretRight,
              semanticLabel: widget.nextMonthSemanticLabel,
              onPressed: _canGoNext
                  ? () => setState(
                      () => _month = DateTime(_month.year, _month.month + 1),
                    )
                  : null,
            ),
          ],
        ),
        const SizedBox(height: SossoldiSpacing.s),
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(
                child: Center(
                  child: Text(
                    l10n.narrowWeekdays[(first + i) % 7],
                    style: typography.labelMedium.copyWith(
                      color: colors.textMed,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: SossoldiSpacing.xs),
        for (var r = 0; r < rows; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++) Expanded(child: dayCell(r * 7 + c)),
            ],
          ),
      ],
    );
  }
}
