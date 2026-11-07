import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/app_scope.dart';
import '../../../app/app_shell_scope.dart';
import '../../../insights/insight.dart';
import '../../../insights/insight_constants.dart';
import '../../../insights/insight_engine.dart';
import '../../../mock/date_utils.dart';
import '../../../mock/mock_repository.dart';
import '../../../mock/models/transaction_filter.dart';
import '../../add_transaction/add_sheet.dart';
import '../../finance/budget/budget_detail_screen.dart';
import '../../finance/recurring/recurring_detail_screen.dart';
import '../model/dashboard_layout.dart';
import '../registry/dashboard_widget_definition.dart';
import 'insight_card.dart';
import 'insight_texts.dart';

/// Insight of the moment: the one insight the [InsightEngine] finds most
/// relevant. It is worked out again only when the repository's data change,
/// when the app comes back to the foreground and at the moments the answer
/// can change by itself (the evening reminder hour, midnight): not on every
/// rebuild. A tap (and the button of M) opens what the insight is about.
class InsightWidget extends StatefulWidget {
  const InsightWidget({
    super.key,
    required this.size,
    this.instance = const DashboardWidgetInstance(),
  });

  final DashboardWidgetSize size;
  final DashboardWidgetInstance instance;

  /// What the "add widget" list shows: a fixed example.
  static const example = Insight(
    type: InsightType.portfolioDrop,
    tone: InsightTone.negative,
    action: InsightAction.viewInvestments,
    level: 5,
    amount: -120,
    percent: -0.024,
    value: 4880,
  );

  @override
  State<InsightWidget> createState() => _InsightWidgetState();
}

class _InsightWidgetState extends State<InsightWidget>
    with WidgetsBindingObserver {
  MockRepository? _repository;
  Insight _insight = const Insight.allGood();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repository = context.repository;
    if (!identical(repository, _repository)) {
      _repository?.removeListener(_recompute);
      _repository = repository..addListener(_recompute);
      _insight = _evaluate();
      _schedule();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _recompute();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _repository?.removeListener(_recompute);
    _timer?.cancel();
    super.dispose();
  }

  Insight _evaluate() {
    final repository = _repository!;
    return InsightEngine(repository).evaluate(repository.currentTime);
  }

  void _recompute() {
    if (!mounted) return;
    final next = _evaluate();
    _schedule();
    if (next != _insight) setState(() => _insight = next);
  }

  /// Wakes up at the next moment the answer can change on its own.
  void _schedule() {
    _timer?.cancel();
    final repository = _repository!;
    final now = repository.currentTime;
    final wait = InsightEngine(repository)
        .nextTimeBoundary(now)
        .difference(now);
    _timer = Timer(
      wait < const Duration(seconds: 1) ? const Duration(seconds: 1) : wait,
      _recompute,
    );
  }

  VoidCallback? _tapFor(Insight insight) {
    final scope = AppShellScope.maybeOf(context);
    final repository = context.repository;
    return switch (insight.action) {
      InsightAction.none => null,
      InsightAction.viewBudget => () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BudgetDetailScreen(budgetId: insight.budgetId!),
        ),
      ),
      InsightAction.viewRecurring => () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              RecurringDetailScreen(recurringId: insight.recurringId!),
        ),
      ),
      InsightAction.viewTransactions =>
        scope?.openTransactions == null
            ? null
            : () {
                final today = dateOnly(repository.currentTime);
                scope!.openTransactions!(
                  TransactionFilter(
                    from: addDays(today, -InsightConstants.unusualWindowDays),
                    to: today,
                    categoryIds: {insight.categoryId!},
                  ),
                );
              },
      InsightAction.viewInvestments => scope?.openInvestmentsOverview,
      InsightAction.addTransaction => () => showAddSheet(context),
    };
  }

  @override
  Widget build(BuildContext context) {
    final insight = widget.instance.preview ? InsightWidget.example : _insight;
    final texts = InsightTexts.of(
      context,
      insight,
      masked: context.hideAmounts,
    );
    return InsightCard(
      tone: insight.tone,
      icon: texts.icon,
      title: texts.title,
      bottom: texts.bottom,
      attachedDetail: texts.attachedDetail,
      onTap: widget.instance.editing || widget.instance.preview
          ? null
          : _tapFor(insight),
    );
  }
}
