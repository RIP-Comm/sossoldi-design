import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';
import '../../mock/models/category.dart';

/// What the list of categories returns: the category and, when one of its
/// subcategories was tapped, that too.
typedef CategoryPick = ({String categoryId, String? subcategoryId});

/// The whole list of categories of a type, with their subcategories, in a
/// bottom sheet. Tapping a category (or a subcategory) picks it and closes.
Future<CategoryPick?> showCategoryPickerSheet(
  BuildContext context, {
  required CategoryType type,
}) {
  final repo = AppScope.read(context).repository;
  final l10n = context.l10n;
  return showSossoldiBottomSheet<CategoryPick>(
    context: context,
    toolbar: Builder(
      builder: (sheet) => SossoldiBottomSheetToolbar.icon(
        title: l10n.txCategory,
        onClose: () => Navigator.of(sheet).pop(),
        closeSemanticLabel: l10n.close,
      ),
    ),
    builder: (sheet) {
      final categories = repo.categoriesByUsage(type);
      return SingleChildScrollView(
        child: SossoldiList(
          children: [
            for (final c in categories)
              SossoldiCategoryItem(
                name: c.name,
                leading: Icon(c.icon, size: 24, color: c.color.main),
                subtitle: null,
                onTap: () =>
                    Navigator.of(sheet)
                        .pop((categoryId: c.id, subcategoryId: null)),
                onRowTap: () =>
                    Navigator.of(sheet)
                        .pop((categoryId: c.id, subcategoryId: null)),
                expandSemanticLabel: l10n.txSubcategories,
                collapseSemanticLabel: l10n.txSubcategories,
                subcategories: [
                  for (final s in repo.subcategoriesOf(c.id))
                    SossoldiSubcategory(
                      name: s.name,
                      leading: Icon(c.icon, size: 24, color: c.color.main),
                      onTap: () =>
                          Navigator.of(sheet)
                              .pop((categoryId: c.id, subcategoryId: s.id)),
                    ),
                ],
              ),
          ],
        ),
      );
    },
  );
}
