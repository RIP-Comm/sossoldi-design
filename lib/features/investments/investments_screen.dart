// Investments page, from Figma "Investments - Overview" (node 13:4855):
// the title with "Updated X ago", the three tabs, and the selected one.
// Pull-to-refresh on the whole page, whatever the tab, updates the prices.
// Only Overview is built; Positions and Movements are placeholders.

import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/top_blur.dart';
import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import 'investments_controller.dart';
import 'investments_texts.dart';
import 'overview/investments_overview_tab.dart';
import 'movements/movements_tab.dart';
import 'positions/positions_tab.dart';

class InvestmentsScreen extends StatefulWidget {
  const InvestmentsScreen({super.key, required this.controller});

  final InvestmentsController controller;

  @override
  State<InvestmentsScreen> createState() => _InvestmentsScreenState();
}

class _InvestmentsScreenState extends State<InvestmentsScreen> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // "Updated 4 min ago" moves on with the clock.
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final repo = context.repository;
    // The shell adds the height of the bottom bar to the bottom padding.
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final controller = widget.controller;
    final top = MediaQuery.paddingOf(context).top;
    return TopBlur(
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => RefreshIndicator(
          // The loader sits over the page: the content does not move.
          color: colors.primary.surface,
          backgroundColor: colors.surfaceHigh,
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              SossoldiSpacing.l,
              top + 15,
              SossoldiSpacing.l,
              bottomInset + SossoldiSpacing.l,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: SossoldiSpacing.l,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.investmentsTitle,
                      style: context.typography.headlineMedium.copyWith(
                        color: colors.textHigh,
                      ),
                    ),
                    Text(
                      investmentsUpdatedText(
                        context,
                        repo.pricesUpdatedAt,
                        repo.currentTime,
                      ),
                      style: context.typography.captionSmall.copyWith(
                        color: colors.textMed,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: SossoldiSpacing.m,
                  children: [
                    SossoldiTabNavigation(
                      tabs: [
                        SossoldiTabData.text(l10n.investmentsTabOverview),
                        SossoldiTabData.text(l10n.investmentsTabPositions),
                        SossoldiTabData.text(l10n.investmentsTabMovements),
                      ],
                      selectedIndex: controller.tab.index,
                      onChanged: (i) =>
                          controller.selectTab(InvestmentsTab.values[i]),
                    ),
                    if (controller.tab == InvestmentsTab.overview)
                      InvestmentsOverviewTab(controller: controller)
                    else if (controller.tab == InvestmentsTab.positions)
                      PositionsTab(controller: controller)
                    else
                      MovementsTab(controller: controller),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
