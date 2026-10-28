// Step 2 of the onboarding, from the Figma "Onboarding 0.2.0" (node 13:3596,
// no categories) and "0.2.7" (13:3685, with one): the categories, with their
// budgets and subcategories, and the suggested ones. The state with a row
// opened (its subcategories) is not drawn: it takes the style of the
// subcategories in the form. Differences from Figma: a row with budgets but no
// subcategories also has the caret, and opens the budgets.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../../mock/mock_repository.dart';
import '../../mock/models/category.dart';
import '../../mock/models/suggested_category.dart';
import '../categories/category_form_sheet.dart';
import '../categories/category_texts.dart';
import 'onboarding_assets_screen.dart';
import 'onboarding_back_button.dart';

class OnboardingCategoriesScreen extends StatelessWidget {
  const OnboardingCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    final repo = AppScope.of(context).repository;
    return Scaffold(
      backgroundColor: colors.surfaceMed,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: repo,
          builder: (context, _) {
            final categories = repo.categories();
            final suggested = repo.suggestedCategoriesLeft();
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
                              const OnboardingBackButton(),
                              Text(
                                l10n.onboardingStep(2, 3),
                                textAlign: TextAlign.center,
                                style: typography.titleMedium.copyWith(
                                  color: colors.textHigh,
                                ),
                              ),
                              Text(
                                l10n.onboardingStep2Subtitle,
                                textAlign: TextAlign.center,
                                style: typography.bodyLarge.copyWith(
                                  color: colors.textMed,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: SossoldiSpacing.l,
                            children: [
                              _YourCategories(
                                repo: repo,
                                categories: categories,
                              ),
                              if (suggested.isNotEmpty)
                                _Suggested(repo: repo, suggested: suggested),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (categories.isNotEmpty)
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
                            builder: (_) => const OnboardingAssetsScreen(),
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

/// "Your categories": the empty card, or the list in order of creation.
class _YourCategories extends StatelessWidget {
  const _YourCategories({required this.repo, required this.categories});

  final MockRepository repo;
  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.s,
      children: [
        Text(
          l10n.onboardingYourCategories,
          style: typography.titleLarge.copyWith(color: colors.textHigh),
        ),
        if (categories.isEmpty)
          Container(
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
                  l10n.onboardingFirstCategory,
                  textAlign: TextAlign.center,
                  style: typography.bodyLarge.copyWith(color: colors.textMed),
                ),
                SossoldiButton(
                  label: l10n.onboardingCreateCategory,
                  onPressed: () => showCategoryFormSheet(context),
                ),
              ],
            ),
          )
        else ...[
          for (final (title, type) in [
            (l10n.onboardingSuggestedExpenses, CategoryType.expense),
            (l10n.onboardingSuggestedIncome, CategoryType.income),
          ])
            if (categories.any((c) => c.type == type))
              _Group(
                title: title,
                children: [
                  for (final c in categories.where((c) => c.type == type))
                    _CategoryRow(key: ValueKey(c.id), repo: repo, category: c),
                ],
              ),
          SossoldiList(
            children: [
              SossoldiListAddButton(
                label: l10n.onboardingAddCategory,
                onPressed: () => showCategoryFormSheet(context),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// A titled list: "Expenses" or "Income", in "Your categories" and in
/// "Suggested".
class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.xs,
      children: [
        Text(
          title,
          style: context.typography.bodyLarge.copyWith(
            color: context.colors.textMed,
          ),
        ),
        SossoldiList(children: children),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({super.key, required this.repo, required this.category});

  final MockRepository repo;
  final Category category;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final budgets = repo.budgetsForCategory(category.id);
    final currency = repo.mainCurrency;
    Widget icon() => Icon(category.icon, size: 24, color: category.color.main);
    final subcategories = repo.subcategoriesOf(category.id);
    // What the caret opens: the subcategories, or the budgets when there are
    // no subcategories.
    final children = subcategories.isNotEmpty
        ? [
            for (final s in subcategories)
              SossoldiSubcategory(name: s.name, leading: icon()),
          ]
        : [
            for (final b in budgets)
              SossoldiSubcategory(
                name: budgetEntryText(
                  context,
                  period: b.period,
                  amount: b.amount,
                  currency: currency,
                ),
                leading: Icon(
                  PhosphorIconsRegular.target,
                  size: 24,
                  color: colors.textMed,
                ),
              ),
          ];
    return SossoldiCategoryItem(
      name: category.name,
      leading: icon(),
      subtitle: budgets.isEmpty
          ? null
          : budgetsSubtitle(context, budgets, currency),
      subcategories: children,
      onTap: () => showCategoryFormSheet(context, editing: category),
      onRowTap: () => showCategoryFormSheet(context, editing: category),
      expandSemanticLabel: l10n.categoryShowSubcategories,
      collapseSemanticLabel: l10n.categoryHideSubcategories,
    );
  }
}

/// "Suggested": the categories not created yet, expenses then income; the "+"
/// creates the category with its subcategories at once.
class _Suggested extends StatelessWidget {
  const _Suggested({required this.repo, required this.suggested});

  final MockRepository repo;
  final List<SuggestedCategory> suggested;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final typography = context.typography;
    Widget group(String title, CategoryType type) {
      final items = suggested.where((s) => s.type == type).toList();
      if (items.isEmpty) return const SizedBox.shrink();
      return _Group(
        title: title,
        children: [
          for (final s in items)
            SossoldiCategoryItem.suggested(
              key: ValueKey('suggested_${s.type.name}_${s.name}'),
              name: s.name,
              leading: Icon(s.icon, size: 24, color: s.color.main),
              onAdd: () => repo.addSuggestedCategory(s),
              addSemanticLabel: l10n.onboardingAddSuggested(s.name),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: SossoldiSpacing.m,
      children: [
        Text(
          l10n.onboardingSuggested,
          style: typography.titleLarge.copyWith(color: colors.textHigh),
        ),
        group(l10n.onboardingSuggestedExpenses, CategoryType.expense),
        group(l10n.onboardingSuggestedIncome, CategoryType.income),
      ],
    );
  }
}
