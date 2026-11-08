// Time picker: hour and minute chosen on two scrolling wheels in a bottom
// sheet, as in the iPhone reminders (not in Figma, built from tokens: round X
// and check in the toolbar like the other forms). 24-hour clock, both wheels
// loop. Reads well in light and dark mode.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_bottom_sheet.dart';
import 'sossoldi_bottom_sheet_toolbar.dart';

/// Opens the wheels and returns the time confirmed with the check, or null
/// when the sheet is closed with the X or dismissed.
Future<TimeOfDay?> showSossoldiTimePicker({
  required BuildContext context,
  required String title,
  required TimeOfDay initial,
  required String closeSemanticLabel,
  required String confirmSemanticLabel,
}) {
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    constraints: sossoldiSheetConstraints(context),
    builder: (_) => _TimePickerSheet(
      title: title,
      initial: initial,
      closeSemanticLabel: closeSemanticLabel,
      confirmSemanticLabel: confirmSemanticLabel,
    ),
  );
}

class _TimePickerSheet extends StatefulWidget {
  const _TimePickerSheet({
    required this.title,
    required this.initial,
    required this.closeSemanticLabel,
    required this.confirmSemanticLabel,
  });

  final String title;
  final TimeOfDay initial;
  final String closeSemanticLabel;
  final String confirmSemanticLabel;

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  late int _hour = widget.initial.hour;
  late int _minute = widget.initial.minute;

  @override
  Widget build(BuildContext context) {
    return SossoldiBottomSheet(
      toolbar: SossoldiBottomSheetToolbar.icon(
        title: widget.title,
        onClose: () => Navigator.of(context).pop(),
        closeSemanticLabel: widget.closeSemanticLabel,
        onConfirm: () =>
            Navigator.of(context).pop(TimeOfDay(hour: _hour, minute: _minute)),
        confirmSemanticLabel: widget.confirmSemanticLabel,
      ),
      child: SossoldiTimeWheels(
        hour: _hour,
        minute: _minute,
        onChanged: (h, m) => setState(() {
          _hour = h;
          _minute = m;
        }),
      ),
    );
  }
}

/// The two wheels (hours 0-23, minutes 0-59) on a card, with a band behind
/// the selected row.
class SossoldiTimeWheels extends StatefulWidget {
  const SossoldiTimeWheels({
    super.key,
    required this.hour,
    required this.minute,
    required this.onChanged,
  });

  final int hour;
  final int minute;
  final void Function(int hour, int minute) onChanged;

  static const double itemExtent = 44;
  static const double height = itemExtent * 5;

  @override
  State<SossoldiTimeWheels> createState() => _SossoldiTimeWheelsState();
}

class _SossoldiTimeWheelsState extends State<SossoldiTimeWheels> {
  late final FixedExtentScrollController _hours = FixedExtentScrollController(
    initialItem: widget.hour,
  );
  late final FixedExtentScrollController _minutes = FixedExtentScrollController(
    initialItem: widget.minute,
  );

  @override
  void dispose() {
    _hours.dispose();
    _minutes.dispose();
    super.dispose();
  }

  Widget _wheel(FixedExtentScrollController controller, int count, bool hours) {
    final colors = context.colors;
    final style = context.typography.titleLarge.copyWith(
      color: colors.textHigh,
    );
    return Expanded(
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: SossoldiTimeWheels.itemExtent,
        physics: const FixedExtentScrollPhysics(),
        overAndUnderCenterOpacity: 0.35,
        perspective: 0.003,
        onSelectedItemChanged: (i) {
          final value = i % count;
          if (hours) {
            widget.onChanged(value, widget.minute);
          } else {
            widget.onChanged(widget.hour, value);
          }
        },
        childDelegate: ListWheelChildLoopingListDelegate(
          children: [
            for (var i = 0; i < count; i++)
              Center(child: Text(i.toString().padLeft(2, '0'), style: style)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: SossoldiTimeWheels.height,
      padding: const EdgeInsets.symmetric(horizontal: SossoldiSpacing.l),
      decoration: ShapeDecoration(
        color: colors.surfaceHigh,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(SossoldiRadius.m),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The band behind the selected row.
          Container(
            height: SossoldiTimeWheels.itemExtent,
            decoration: ShapeDecoration(
              color: colors.surfaceMed,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(SossoldiRadius.s),
              ),
            ),
          ),
          Row(
            children: [
              _wheel(_hours, 24, true),
              Text(
                ':',
                style: context.typography.titleLarge.copyWith(
                  color: colors.textHigh,
                ),
              ),
              _wheel(_minutes, 60, false),
            ],
          ),
        ],
      ),
    );
  }
}
