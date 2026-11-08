// The Accounts page: one row per account (icon and color, name, balance in the
// account's currency, chevron), the main one marked, ordered by the
// repository (balance in the main currency, highest first). Opened from
// Settings > Accounts and from the "Manage" of the Finance Overview. A tap
// opens the page of the account; the "+" of the header opens the form. No Figma node.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../settings/settings_page.dart';
import 'account_detail_screen.dart';
import 'account_form_sheet.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  /// The route to push from any screen.
  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const AccountsScreen());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // The repository notifies on every change (and the app state on the main
    // currency), so the order and the balances follow.
    final repo = context.repository;
    final masked = context.hideAmounts;
    final accounts = repo.accountsByBalance();
    return SettingsPage(
      title: l10n.settingsAccounts,
      trailing: SettingsAddButton(
        semanticLabel: l10n.accountsAddSemantic,
        onPressed: () => showAccountFormSheet(context),
      ),
      children: [
        if (accounts.isEmpty)
          SossoldiEmptyState(
            icon: PhosphorIconsRegular.bank,
            title: l10n.accountsEmptyTitle,
            message: l10n.accountsEmptyMessage,
          ),
        SossoldiList(
          children: [
            for (final a in accounts)
              SossoldiAccountItem(
                key: ValueKey(a.account.id),
                name: a.account.name,
                balance: a.balance,
                currencyCode: a.account.currency,
                masked: masked,
                hasChevron: true,
                tag: a.account.isMain
                    ? SossoldiTag(label: l10n.accountMainTag, hasStroke: true)
                    : null,
                leading: Icon(
                  a.account.icon,
                  size: 24,
                  color: a.account.color.main,
                ),
                onTap: () =>
                    Navigator.of(context)
                        .push(AccountDetailScreen.route(a.account.id)),
              ),
          ],
        ),
      ],
    );
  }
}
