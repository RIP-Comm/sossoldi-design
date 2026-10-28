// Recurring tab, from Figma "2.3.0 - Finance - Recurrencies" (node 13:4773):
// the month calendar and the list of the recurring transactions under it,
// ending with "Add recurrent transaction". Not in Figma: the month selector
// in place of the title, and tapping a day to list only that day.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../app/app_scope.dart';
import '../../../app/placeholder_screen.dart';
import '../../../design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../../mock/models/transaction.dart';
import 'recurring_controller.dart';
import 'recurring_detail_screen.dart';
import 'recurring_item.dart';

class RecurringTabView extends StatelessWidget {
  const RecurringTabView({super.key, required this.controller});

  final RecurringController controller;

  Future<void> _pickMonth(BuildContext context) async {
    final l10n = context.l10n;
    final picked = await showSossoldiMonthPicker(
      context: context,
      selected: controller.month,
      firstYear: controller.firstYear,
      lastYear: controller.lastYear,
      title: l10n.recurringPickMonthTitle,
      closeSemanticLabel: l10n.close,
      previousYearSemanticLabel: l10n.recurringPreviousYear,
      nextYearSemanticLabel: l10n.recurringNextYear,
    );
    if (picked != null) controller.selectMonth(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final repo = context.repository;
    final occurrences = controller.visibleOccurrences;
    final month = controller.month;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.l,
      children: [
        SossoldiMonthSelector(
          month: month,
          onPrevious: controller.canGoPrevious
              ? controller.previousMonth
              : null,
          onNext: controller.canGoNext ? controller.nextMonth : null,
          onTap: () => _pickMonth(context),
          previousSemanticLabel: l10n.recurringPreviousMonth,
          nextSemanticLabel: l10n.recurringNextMonth,
          pickSemanticLabel: l10n.recurringPickMonth,
        ),
        SossoldiCalendar(
          month: month,
          today: repo.today,
          selectedDay: controller.selectedDay,
          dots: {
            for (final e in controller.dayTypes.entries)
              e.key: {
                for (final t in e.value)
                  switch (t) {
                    TransactionType.expense => SossoldiCalendarDot.expense,
                    TransactionType.income => SossoldiCalendarDot.income,
                    TransactionType.transfer => SossoldiCalendarDot.transfer,
                  },
              },
          },
          onDayTap: controller.toggleDay,
        ),
        if (occurrences.isEmpty)
          Container(
            decoration: ShapeDecoration(
              color: context.colors.surfaceHigh,
              shape: RoundedSuperellipseBorder(
                borderRadius: BorderRadius.circular(SossoldiRadius.m),
              ),
            ),
            child: SossoldiEmptyState(
              icon: PhosphorIconsRegular.calendarBlank,
              title: controller.selectedDay == null
                  ? l10n.recurringEmptyMonthTitle
                  : l10n.recurringEmptyDayTitle,
            ),
          ),
        SossoldiList(
          children: [
            for (final (i, o) in occurrences.indexed)
              RecurringItem(
                key: ValueKey('${o.recurringId}-${o.date}-$i'),
                type: o.type,
                description: repo.recurring(o.recurringId).description,
                accountId: repo.recurring(o.recurringId).accountId,
                toAccountId: repo.recurring(o.recurringId).toAccountId,
                categoryId: repo.recurring(o.recurringId).categoryId,
                amount: o.amount,
                currency: o.currency,
                date: o.date,
                planned: o.isPlanned,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        RecurringDetailScreen(recurringId: o.recurringId),
                  ),
                ),
              ),
            SossoldiListAddButton(
              label: l10n.recurringAdd,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PlaceholderScreen(
                    title: l10n.recurringAdd,
                    showBack: true,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
