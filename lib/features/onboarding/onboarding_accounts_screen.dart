// Step 1 of the onboarding, from the Figma "Onboarding 0.1.0" (node 13:3368,
// no accounts) and "0.1.2" (13:3576, with one): the main currency and the
// accounts. Both states take the sizes of 0.1.2, which is the later one.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../accounts/account_form_sheet.dart';
import '../accounts/currency_labels.dart';
import 'onboarding_categories_screen.dart';

class OnboardingAccountsScreen extends StatelessWidget {
  const OnboardingAccountsScreen({super.key});

  /// The currency that comes preselected.
  static const defaultCurrency = 'EUR';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    final state = AppScope.of(context);
    final repo = state.repository;
    return Scaffold(
      backgroundColor: colors.surfaceMed,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: repo,
          builder: (context, _) {
            final accounts = repo.accounts;
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SossoldiSpacing.l,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: SossoldiSpacing.xxl,
                        children: [
                          Column(
                            spacing: SossoldiSpacing.xs,
                            children: [
                              Text(
                                l10n.onboardingStep(1, 3),
                                textAlign: TextAlign.center,
                                style: typography.titleMedium.copyWith(
                                  color: colors.textHigh,
                                ),
                              ),
                              Text(
                                l10n.onboardingStep1Subtitle,
                                textAlign: TextAlign.center,
                                style: typography.bodyXLarge.copyWith(
                                  color: colors.textMed,
                                ),
                              ),
                            ],
                          ),
                          SossoldiSelect<String>(
                            label: l10n.onboardingMainCurrency,
                            value: repo.mainCurrency,
                            onChanged: state.setMainCurrency,
                            items: [
                              for (final code in repo.supportedCurrencies)
                                SossoldiSelectItem(
                                  value: code,
                                  label: currencyLabel(
                                    context,
                                    code,
                                    isDefault: code == defaultCurrency,
                                  ),
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: SossoldiSpacing.s,
                            children: [
                              Text(
                                l10n.onboardingYourAccounts,
                                style: typography.titleMedium.copyWith(
                                  color: colors.textHigh,
                                ),
                              ),
                              if (accounts.isEmpty)
                                _EmptyAccounts(
                                  onCreate: () => showAccountFormSheet(context),
                                )
                              else
                                SossoldiList(
                                  children: [
                                    for (final a in accounts)
                                      SossoldiAccountItem(
                                        name: a.name,
                                        balance: repo.accountBalance(a.id),
                                        currencyCode: a.currency,
                                        masked: state.hideAmounts,
                                        leading: Icon(
                                          a.icon,
                                          size: 24,
                                          color: a.color.main,
                                        ),
                                        onTap: () => showAccountFormSheet(
                                          context,
                                          editing: a,
                                        ),
                                      ),
                                    SossoldiListAddButton(
                                      label: l10n.onboardingAddAccount,
                                      onPressed: () =>
                                          showAccountFormSheet(context),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (accounts.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: SossoldiSpacing.s,
                      ),
                      child: SossoldiButton(
                        label: l10n.onboardingNextStep,
                        type: SossoldiButtonType.ghost,
                        size: SossoldiButtonSize.large,
                        iconRight: PhosphorIconsRegular.caretRight,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const OnboardingCategoriesScreen(),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The card of an empty list of accounts: a line and the button that opens the
/// form.
class _EmptyAccounts extends StatelessWidget {
  const _EmptyAccounts({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(SossoldiSpacing.l),
      decoration: ShapeDecoration(
        color: colors.surfaceLow,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(SossoldiRadius.m),
        ),
      ),
      child: Column(
        spacing: SossoldiSpacing.l,
        children: [
          Text(
            l10n.onboardingFirstAccount,
            textAlign: TextAlign.center,
            style: context.typography.bodyLarge.copyWith(color: colors.textMed),
          ),
          SossoldiButton(
            label: l10n.onboardingCreateAccount,
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}
