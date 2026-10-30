import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../foundations/foundation_page.dart';

const _eur = 'EUR';

Widget _icon(BuildContext context) => Icon(
  PhosphorIconsRegular.sticker,
  size: 24,
  color: context.colors.textHigh,
);

class _Column extends StatelessWidget {
  const _Column(this.children);

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 358,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.xl,
      children: children,
    ),
  );
}

class AmountUseCase extends StatelessWidget {
  const AmountUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return const FoundationPage(
      children: [
        FoundationSection(
          title: 'Tones (switch locale in Addons to see formatting)',
          children: [
            SossoldiAmount(value: 1000.2, currencyCode: _eur),
            SossoldiAmount(
              value: 147.45,
              currencyCode: _eur,
              tone: SossoldiAmountTone.signed,
              showPlusSign: true,
            ),
            SossoldiAmount(
              value: -32.1,
              currencyCode: _eur,
              tone: SossoldiAmountTone.signed,
            ),
            SossoldiAmount(
              value: 500,
              currencyCode: _eur,
              tone: SossoldiAmountTone.transfer,
            ),
            SossoldiAmount(value: 250, currencyCode: 'USD'),
            SossoldiAmount(value: 1000.2, currencyCode: _eur, masked: true),
          ],
        ),
        FoundationSection(
          title: 'Change tag',
          children: [
            SossoldiChangeTag.money(value: 147.45, currencyCode: _eur),
            SossoldiChangeTag.money(value: -20, currencyCode: _eur),
            SossoldiChangeTag.percent(value: 0.0085),
            SossoldiChangeTag.percent(value: -0.031),
          ],
        ),
      ],
    );
  }
}

class AvatarUseCase extends StatelessWidget {
  const AvatarUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Initials md / sm / xs',
          children: [
            for (final size in SossoldiAvatarSize.values)
              SossoldiAvatar.initials(initials: 'DN', size: size),
          ],
        ),
        FoundationSection(
          title: 'Badges',
          children: [
            for (final badge in SossoldiAvatarBadge.values)
              SossoldiAvatar.initials(initials: 'DN', badge: badge),
            const SossoldiAvatar.initials(
              initials: 'DN',
              size: SossoldiAvatarSize.xs,
              badge: SossoldiAvatarBadge.topRight,
            ),
          ],
        ),
      ],
    );
  }
}

class RightChartUseCase extends StatelessWidget {
  const RightChartUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return const FoundationPage(
      children: [
        FoundationSection(
          title: 'Positive / Negative',
          children: [
            SizedBox(
              width: 120,
              child: SossoldiRightChart(
                points: [3, 4, 3.5, 6, 5, 7, 5.5, 8, 6.5],
                value: 1240.5,
                currencyCode: _eur,
                change: 0.0085,
              ),
            ),
            SizedBox(
              width: 120,
              child: SossoldiRightChart(
                points: [8, 7, 7.5, 6, 6.4, 5, 5.6, 4.5, 4],
                value: 980,
                currencyCode: _eur,
                change: -0.031,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TransactionItemUseCase extends StatelessWidget {
  const TransactionItemUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        _Column([
          SossoldiTransactionItem(
            type: SossoldiTransactionType.income,
            leading: _icon(context),
            description: 'Salary',
            account: 'Main account',
            amount: 2100,
            currencyCode: _eur,
            recurrenceLabel: '31 May',
          ),
          SossoldiTransactionItem(
            type: SossoldiTransactionType.expense,
            leading: _icon(context),
            description: 'Groceries',
            account: 'Main account',
            amount: 54.3,
            currencyCode: _eur,
          ),
          SossoldiTransactionItem(
            type: SossoldiTransactionType.transfer,
            leading: _icon(context),
            description: 'Savings',
            account: 'Main account',
            toAccount: 'Savings account',
            amount: 300,
            currencyCode: _eur,
            recurrenceLabel: '31 May',
          ),
          SossoldiListAddButton(
            label: 'Add recurrent transaction',
            onPressed: () {},
          ),
        ]),
      ],
    );
  }
}

class AccountItemUseCase extends StatelessWidget {
  const AccountItemUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        _Column([
          SossoldiAccountItem(
            leading: _icon(context),
            name: 'Main account',
            balance: 1000.2,
            currencyCode: _eur,
            tag: const SossoldiTag(label: 'Main'),
          ),
          Column(
            children: [
              SossoldiAccountItem(
                leading: _icon(context),
                name: 'Main account',
                balance: 1000.2,
                currencyCode: _eur,
                variation: 147.45,
                hasStroke: true,
              ),
              SossoldiAccountItem(
                leading: _icon(context),
                name: 'Credit card',
                balance: -320,
                currencyCode: _eur,
                variation: -80,
              ),
            ],
          ),
          SossoldiListAddButton(label: 'Add account', onPressed: () {}),
        ]),
      ],
    );
  }
}

class CategoryItemUseCase extends StatelessWidget {
  const CategoryItemUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    final subs = [
      SossoldiSubcategory(name: 'Rent', leading: _icon(context)),
      SossoldiSubcategory(name: 'Utilities', leading: _icon(context)),
    ];
    return FoundationPage(
      children: [
        _Column([
          SossoldiCategoryItem(
            leading: _icon(context),
            name: 'Housing',
            subtitle: 'Rent, Utilities',
            subcategories: subs,
          ),
          SossoldiCategoryItem(
            leading: _icon(context),
            name: 'Housing',
            subtitle: 'Rent, Utilities',
            subcategories: subs,
            initiallyExpanded: true,
          ),
          // Onboarding: the row opens the category, only the caret toggles.
          SossoldiCategoryItem(
            leading: _icon(context),
            name: 'Housing',
            subtitle: 'Budget: 130€, Monthly',
            subcategories: subs,
            onRowTap: () {},
            expandSemanticLabel: 'Show subcategories',
            collapseSemanticLabel: 'Hide subcategories',
          ),
          SossoldiCategoryItem.suggested(
            leading: _icon(context),
            name: 'Travel',
            subtitle: 'Suggested',
            onAdd: () {},
            addSemanticLabel: 'Add category',
          ),
          SossoldiListAddButton(label: 'Add category', onPressed: () {}),
        ]),
      ],
    );
  }
}

class AssetItemUseCase extends StatelessWidget {
  const AssetItemUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        _Column([
          const SossoldiAssetItem(
            name: 'Vanguard FTSE All-World',
            typeLabel: 'ETF',
            identifier: 'VWCE - IE00BK5BQT80',
            chart: SossoldiRightChart(
              points: [3, 4, 3.5, 6, 5, 7, 5.5, 8, 6.5],
              value: 7698.14,
              currencyCode: _eur,
              change: 0.0085,
            ),
          ),
          SossoldiAssetItem.detailed(
            name: 'Vanguard FTSE All-World',
            typeLabel: 'ETF',
            identifier: 'VWCE - IE00BK5BQT80',
            value: 7698.14,
            currencyCode: _eur,
            details: [
              ('Quantity:', SossoldiAmountFormat.number(context, 212)),
              (
                'PMC:',
                SossoldiAmountFormat.money(
                  context,
                  36.312,
                  currencyCode: _eur,
                  decimalDigits: 3,
                ),
              ),
            ],
          ),
          SossoldiListAddButton(label: 'Add asset', onPressed: () {}),
        ]),
      ],
    );
  }
}
