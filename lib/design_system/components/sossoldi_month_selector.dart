// Month selector of the Recurring tab: previous and next month around the
// month and year, which open the month picker. Not in Figma (it replaces
// the title "Recurrencies for this month"): built from the icon button and
// the title style used elsewhere.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_bottom_sheet.dart';
import 'sossoldi_bottom_sheet_toolbar.dart';
import 'sossoldi_icon_button.dart';
import 'sossoldi_tappable.dart';
import 'sossoldi_unit_navigator.dart';

class SossoldiMonthSelector extends StatelessWidget {
  const SossoldiMonthSelector({
    super.key,
    required this.month,
    required this.onPrevious,
    required this.onNext,
    required this.onTap,
    required this.previousSemanticLabel,
    required this.nextSemanticLabel,
    required this.pickSemanticLabel,
  });

  /// Any day of the month shown.
  final DateTime month;

  /// Null disables the arrow.
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  /// Opens the picker.
  final VoidCallback onTap;
  final String previousSemanticLabel;
  final String nextSemanticLabel;
  final String pickSemanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = toBeginningOfSentenceCase(
      MaterialLocalizations.of(context).formatMonthYear(month),
      Localizations.localeOf(context).toString(),
    );
    return Row(
      children: [
        SossoldiIconButton(
          icon: PhosphorIconsRegular.caretLeft,
          semanticLabel: previousSemanticLabel,
          onPressed: onPrevious,
        ),
        Expanded(
          child: SossoldiTappable(
            onTap: onTap,
            semanticLabel: pickSemanticLabel,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: SossoldiSpacing.xs,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.titleMedium.copyWith(
                      color: colors.textHigh,
                    ),
                  ),
                ),
                Icon(
                  PhosphorIconsRegular.caretDown,
                  size: 16,
                  color: colors.textMed,
                ),
              ],
            ),
          ),
        ),
        SossoldiIconButton(
          icon: PhosphorIconsRegular.caretRight,
          semanticLabel: nextSemanticLabel,
          onPressed: onNext,
        ),
      ],
    );
  }
}

/// The month picker: a year stepper and the twelve months. Returns the
/// first day of the month picked (null when closed). Years go from
/// [firstYear] to [lastYear].
Future<DateTime?> showSossoldiMonthPicker({
  required BuildContext context,
  required DateTime selected,
  required int firstYear,
  required int lastYear,
  required String title,
  required String closeSemanticLabel,
  required String previousYearSemanticLabel,
  required String nextYearSemanticLabel,
}) {
  return showSossoldiBottomSheet<DateTime>(
    context: context,
    toolbar: Builder(
      builder: (context) => SossoldiBottomSheetToolbar.icon(
        title: title,
        onClose: () => Navigator.of(context).pop(),
        closeSemanticLabel: closeSemanticLabel,
      ),
    ),
    builder: (context) => _MonthPicker(
      selected: selected,
      firstYear: firstYear,
      lastYear: lastYear,
      previousYearSemanticLabel: previousYearSemanticLabel,
      nextYearSemanticLabel: nextYearSemanticLabel,
    ),
  );
}

class _MonthPicker extends StatefulWidget {
  const _MonthPicker({
    required this.selected,
    required this.firstYear,
    required this.lastYear,
    required this.previousYearSemanticLabel,
    required this.nextYearSemanticLabel,
  });

  final DateTime selected;
  final int firstYear;
  final int lastYear;
  final String previousYearSemanticLabel;
  final String nextYearSemanticLabel;

  @override
  State<_MonthPicker> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<_MonthPicker> {
  late int _year = widget.selected.year.clamp(
    widget.firstYear,
    widget.lastYear,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final locale = Localizations.localeOf(context).toString();
    final names = MaterialLocalizations.of(context);
    String monthName(int m) {
      // Short month names are not in MaterialLocalizations: cut the long one.
      final full = names.formatMonthYear(DateTime(2024, m)).split(' ').first;
      final cut = full.length > 3 ? full.substring(0, 3) : full;
      return toBeginningOfSentenceCase(cut, locale) ?? cut;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.m,
      children: [
        Row(
          children: [
            SossoldiIconButton(
              icon: PhosphorIconsRegular.caretLeft,
              semanticLabel: widget.previousYearSemanticLabel,
              onPressed: _year > widget.firstYear
                  ? () => setState(() => _year--)
                  : null,
            ),
            Expanded(
              child: Text(
                '$_year',
                textAlign: TextAlign.center,
                style: context.typography.titleMedium.copyWith(
                  color: colors.textHigh,
                ),
              ),
            ),
            SossoldiIconButton(
              icon: PhosphorIconsRegular.caretRight,
              semanticLabel: widget.nextYearSemanticLabel,
              onPressed: _year < widget.lastYear
                  ? () => setState(() => _year++)
                  : null,
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(SossoldiSpacing.m),
          decoration: ShapeDecoration(
            color: colors.surfaceHigh,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(SossoldiRadius.m),
            ),
          ),
          child: Column(
            spacing: SossoldiSpacing.s,
            children: [
              for (var row = 0; row < 4; row++)
                Row(
                  spacing: SossoldiSpacing.s,
                  children: [
                    for (var col = 0; col < 3; col++)
                      Expanded(
                        child: _MonthCell(
                          label: monthName(row * 3 + col + 1),
                          selected:
                              _year == widget.selected.year &&
                              row * 3 + col + 1 == widget.selected.month,
                          onTap: () =>
                              Navigator.of(context)
                                  .pop(DateTime(_year, row * 3 + col + 1)),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthCell extends StatelessWidget {
  const _MonthCell({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) =>
      SossoldiUnitNavigator(label: label, selected: selected, onTap: onTap);
}
