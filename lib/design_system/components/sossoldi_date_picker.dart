// Date picker: one day chosen in a bottom sheet with the calendar of the
// design system (SossoldiDateRangePicker, taking the first tap as the day).
// Built on theme tokens, so it reads well in light and dark mode.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_bottom_sheet.dart';
import 'sossoldi_bottom_sheet_toolbar.dart';
import 'sossoldi_date_range_picker.dart';

/// Opens the calendar and returns the day picked, or null if it was closed.
/// Days after [lastDate] (and before [firstDate], when given) cannot be
/// picked.
Future<DateTime?> showSossoldiDatePicker({
  required BuildContext context,
  required String title,
  required DateTime lastDate,
  required String closeSemanticLabel,
  required String previousMonthSemanticLabel,
  required String nextMonthSemanticLabel,
  DateTime? firstDate,
  DateTime? selected,
}) {
  return showSossoldiBottomSheet<DateTime>(
    context: context,
    toolbar: Builder(
      builder: (sheet) => SossoldiBottomSheetToolbar.icon(
        title: title,
        onClose: () => Navigator.of(sheet).pop(),
        closeSemanticLabel: closeSemanticLabel,
      ),
    ),
    builder: (sheet) => Container(
      padding: const EdgeInsets.all(SossoldiSpacing.s),
      decoration: ShapeDecoration(
        color: sheet.colors.surfaceHigh,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(SossoldiRadius.m),
        ),
      ),
      child: SossoldiDateRangePicker(
        start: selected,
        end: null,
        firstDate: firstDate,
        lastDate: lastDate,
        onChanged: (start, _) => Navigator.of(sheet).pop(start),
        previousMonthSemanticLabel: previousMonthSemanticLabel,
        nextMonthSemanticLabel: nextMonthSemanticLabel,
      ),
    ),
  );
}
