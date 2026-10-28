import 'package:flutter/widgets.dart';

import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';

/// The portfolio value card of the Overview and of Positions, read from the
/// repository.
class PortfolioValueCard extends StatelessWidget {
  const PortfolioValueCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = context.repository.portfolioSummary();
    return SossoldiPortfolioCard(
      label: l10n.investmentsPortfolioValue,
      value: s.totalValue,
      gain: s.gain,
      gainPercent: s.gainPercent,
      currencyCode: s.currency,
      liquidityLabel: l10n.investmentsLiquidity,
      liquidity: s.liquidity,
      masked: context.hideAmounts,
    );
  }
}
