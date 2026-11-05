import 'package:flutter/widgets.dart';

import '../../../design_system/design_system.dart';

/// One budget as the Budget status widget draws it. Texts come ready (the
/// numbers were computed by the repository).
@immutable
class BudgetStatusRow {
  const BudgetStatusRow({
    required this.title,
    required this.periodLabel,
    required this.percent,
    required this.remaining,
    required this.tone,
    required this.usage,
    required this.color,
    required this.trackColor,
    this.onTap,
  });

  /// Name of the category.
  final String title;

  /// "Monthly".
  final String periodLabel;

  /// "50%".
  final String percent;

  /// "120 € left" or "34 € over".
  final String remaining;
  final SossoldiBudgetTone tone;
  final double usage;
  final Color color;
  final Color trackColor;
  final VoidCallback? onTap;
}
