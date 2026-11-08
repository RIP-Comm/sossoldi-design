// Settings > Categories: the income categories, then the expense ones, each in
// a titled list as in the onboarding (Step 2). A "+" at the right of the
// header asks for the type (Income or Expense) and opens the category form;
// a row (icon, name, how many subcategories, chevron) opens the page of the
// category. No Figma node: built from the onboarding's category row.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../../mock/models/category.dart';
import '../settings/settings_page.dart';
import 'category_detail_screen.dart';
import 'category_form_sheet.dart';
import 'category_group.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  /// The route to push from any screen.
  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const CategoriesScreen());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // The repository notifies on every change, so the lists follow.
    final repo = context.repository;
    final categories = repo.categories();
    return SettingsPage(
      title: l10n.settingsCategories,
      trailing: _AddButton(),
      children: [
        if (categories.isEmpty)
          SossoldiEmptyState(
            icon: PhosphorIconsRegular.tag,
            title: l10n.categoriesEmptyTitle,
            message: l10n.categoriesEmptyMessage,
          ),
        // Income first, then expenses, each apart.
        for (final (title, type) in [
          (l10n.categoriesGroupIncome, CategoryType.income),
          (l10n.categoriesGroupExpenses, CategoryType.expense),
        ])
          if (categories.any((c) => c.type == type))
            CategoryGroup(
              title: title,
              children: [
                for (final c in categories.where((c) => c.type == type))
                  SossoldiCategoryItem(
                    key: ValueKey(c.id),
                    name: c.name,
                    leading: Icon(c.icon, size: 24, color: c.color.main),
                    subtitle: l10n.categorySubcategoriesCount(
                      repo.subcategoriesOf(c.id).length,
                    ),
                    hasChevron: true,
                    onTap: () =>
                        Navigator.of(context)
                            .push(CategoryDetailScreen.route(c.id)),
                  ),
              ],
            ),
      ],
    );
  }
}

/// The blue "+" of the header: a menu asks for the type, then the form of a
/// new category opens.
class _AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    Widget option(String label, CategoryType type) => Builder(
      builder: (popover) => SossoldiMenuItem(
        label: label,
        onTap: () {
          SossoldiPopover.close(popover);
          showCategoryFormSheet(context, initialType: type);
        },
      ),
    );
    return SossoldiPopover(
      width: 200,
      alignEnd: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          option(l10n.categoryTypeIncome, CategoryType.income),
          option(l10n.categoryTypeExpense, CategoryType.expense),
        ],
      ),
      // The popover takes the tap; the button only draws.
      child: Semantics(
        label: l10n.categoriesAddSemantic,
        button: true,
        excludeSemantics: true,
        child: const IgnorePointer(
          child: SossoldiHeaderButton(
            icon: PhosphorIconsRegular.plus,
            filled: true,
            onPressed: null,
            semanticLabel: '',
          ),
        ),
      ),
    );
  }
}
