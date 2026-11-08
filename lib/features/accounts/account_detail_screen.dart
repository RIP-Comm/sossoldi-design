// Page of one account: the balance over a period (chart) and its
// transactions. A screen of its own, opened with [route]. No Figma node:
// built from the Net worth widget and the Finance transaction list.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../../mock/models/net_worth.dart';
import '../dashboard/widgets/dashboard_type_selector.dart';
import '../dashboard/widgets/net_worth_widget.dart';
import 'account_balance_card.dart';
import 'account_detail_controller.dart';
import 'account_form_sheet.dart';
import 'account_transactions_section.dart';

class AccountDetailScreen extends StatefulWidget {
  const AccountDetailScreen({super.key, required this.accountId});

  final String accountId;

  /// The route to push from any screen.
  static Route<void> route(String accountId) => MaterialPageRoute<void>(
    builder: (_) => AccountDetailScreen(accountId: accountId),
  );

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  AccountDetailController? _controller;
  final _scroll = ScrollController();
  bool _closing = false;

  AccountDetailController get controller => _controller!;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= AccountDetailController(
      context.repository,
      widget.accountId,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scroll.dispose();
    super.dispose();
  }

  /// The account is gone (deleted from its form, or from elsewhere): close the
  /// page. Removes this route and not the top one, as the form may still be
  /// closing above it.
  void _close() {
    if (_closing) return;
    _closing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final route = ModalRoute.of(context);
      if (route != null) Navigator.of(context).removeRoute(route);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final account = controller.account;
        if (account == null) {
          _close();
          return Scaffold(backgroundColor: colors.surfaceMed);
        }
        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SossoldiSpacing.l,
          children: [
            _Balance(controller: controller),
            AccountTransactionsSection(
              controller: controller,
              onPageSelected: (p) {
                controller.goToPage(p);
                if (_scroll.hasClients) _scroll.jumpTo(0);
              },
            ),
          ],
        );
        return Scaffold(
          backgroundColor: colors.surfaceMed,
          body: SafeArea(
            child: Column(
              children: [
                // The same bar as a sheet's: Back, title, action.
                SossoldiBottomSheetToolbar.text(
                  title: account.name,
                  closeLabel: l10n.back,
                  closeIcon: PhosphorIconsRegular.caretLeft,
                  onClose: () => Navigator.of(context).pop(),
                  confirmLabel: l10n.accountPageEdit,
                  onConfirm: () =>
                      showAccountFormSheet(context, editing: account),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.all(SossoldiSpacing.l),
                    child: content,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Balance extends StatelessWidget {
  const _Balance({required this.controller});

  final AccountDetailController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final series = controller.series;
    final period = controller.period;
    final unavailable = controller.unavailablePeriods;
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    return AccountBalanceCard(
      balance: series.current,
      currency: series.currency,
      values: [for (final p in series.points) p.value],
      pointTitles: [for (final p in series.points) date.format(p.time)],
      formatValue: (v) =>
          SossoldiAmountFormat.money(context, v, currencyCode: series.currency),
      change: series.change,
      changePercent: series.changePercent,
      masked: context.hideAmounts,
      noDataText: l10n.widgetNetWorthNoHistory,
      selector: DashboardTypeSelector(
        label: NetWorthWidget.periodLabel(l10n, period),
        options: [
          for (final p in NetWorthPeriod.values)
            (key: p.name, label: NetWorthWidget.periodLabel(l10n, p)),
        ],
        selected: period.name,
        disabledKeys: {for (final p in unavailable) p.name},
        semanticLabel: l10n.netWorthPeriodSemantic,
        onSelected: (key) {
          for (final p in NetWorthPeriod.values) {
            if (p.name == key) controller.selectPeriod(p);
          }
        },
      ),
    );
  }
}
