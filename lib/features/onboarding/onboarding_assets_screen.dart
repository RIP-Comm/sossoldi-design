// Step 3 of the onboarding, from the Figma "Onboarding 0.3.0" (node 13:3649,
// no assets) and "0.3.3" (13:3669, with one): the assets the user already
// holds, each an opening buy. The step can be skipped; "Start tracking" and
// "Skip this step" end the onboarding on the data of the new user. The value of
// a row is quantity x average cost (not the market value), in the main
// currency.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../../mock/mock_repository.dart';
import '../../mock/models/holding.dart';
import '../assets/asset_form_sheet.dart';
import '../investments/investments_texts.dart' show positionKindLabel;

class OnboardingAssetsScreen extends StatelessWidget {
  const OnboardingAssetsScreen({super.key});

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
            final assets = repo.openingAssets;
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
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: SossoldiIconButton(
                                      icon: PhosphorIconsRegular.arrowLeft,
                                      semanticLabel: l10n.back,
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ),
                                  Text(
                                    l10n.onboardingStep(3, 3),
                                    textAlign: TextAlign.center,
                                    style: typography.titleMedium.copyWith(
                                      color: colors.textHigh,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                l10n.onboardingStep3Subtitle,
                                textAlign: TextAlign.center,
                                style: typography.bodyLarge.copyWith(
                                  color: colors.textMed,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: SossoldiSpacing.s,
                            children: [
                              Text(
                                l10n.onboardingYourAssets,
                                style: typography.titleLarge.copyWith(
                                  color: colors.textHigh,
                                ),
                              ),
                              if (assets.isEmpty)
                                _EmptyAssets(
                                  onAdd: () => showAssetFormSheet(context),
                                )
                              else
                                SossoldiList(
                                  children: [
                                    for (final h in assets)
                                      _AssetRow(
                                        key: ValueKey(h.id),
                                        repo: repo,
                                        holding: h,
                                        masked: state.hideAmounts,
                                      ),
                                    SossoldiListAddButton(
                                      label: l10n.onboardingAddAsset,
                                      onPressed: () =>
                                          showAssetFormSheet(context),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: SossoldiSpacing.s,
                    ),
                    child: assets.isEmpty
                        ? SossoldiButton(
                            label: l10n.onboardingSkipStep,
                            type: SossoldiButtonType.ghost,
                            size: SossoldiButtonSize.large,
                            iconRight: PhosphorIconsRegular.caretRight,
                            onPressed: state.finishOnboarding,
                          )
                        : SossoldiButton(
                            label: l10n.onboardingStartTracking,
                            size: SossoldiButtonSize.large,
                            iconRight: PhosphorIconsRegular.caretRight,
                            onPressed: state.finishOnboarding,
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

class _EmptyAssets extends StatelessWidget {
  const _EmptyAssets({required this.onAdd});

  final VoidCallback onAdd;

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
            l10n.onboardingNoAssets,
            textAlign: TextAlign.center,
            style: context.typography.bodyLarge.copyWith(color: colors.textMed),
          ),
          SossoldiButton(label: l10n.onboardingAddAsset, onPressed: onAdd),
        ],
      ),
    );
  }
}

class _AssetRow extends StatelessWidget {
  const _AssetRow({
    super.key,
    required this.repo,
    required this.holding,
    required this.masked,
  });

  final MockRepository repo;
  final Holding holding;
  final bool masked;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final h = holding;
    final asset = h.isManual ? null : repo.asset(h.assetId!);
    return SossoldiAssetItem.detailed(
      name: repo.holdingName(h.id),
      typeLabel: positionKindLabel(context, repo.kindOfHolding(h.id)),
      identifier: asset == null ? '' : '${asset.ticker} – ${asset.isin}',
      // What the user says it cost, not the market value.
      value: repo.holdingCost(h.id),
      currencyCode: repo.mainCurrency,
      details: [
        (
          l10n.assetQuantityLabel,
          SossoldiAmountFormat.quantity(context, h.quantity),
        ),
        (
          l10n.assetPmcLabel,
          SossoldiAmountFormat.money(
            context,
            h.averageCost,
            currencyCode: h.currency,
            decimalDigits: h.averageCost < 1 ? 4 : 3,
          ),
        ),
      ],
      onTap: () => showAssetFormSheet(context, editing: h),
    );
  }
}
