import 'package:flutter/widgets.dart';

import '../../design_system/tokens/category_colors.dart';

enum CategoryType { expense, income }

/// Top-level category. Icon and color are defined here only: subcategories
/// read them from their parent.
@immutable
class Category {
  const Category({
    required this.id,
    required this.type,
    required this.name,
    required this.icon,
    required this.colorIndex,
  });

  final String id;
  final CategoryType type;
  final String name;
  final IconData icon;

  /// Index into [CategoryColors.all].
  final int colorIndex;

  CategoryColor get color => CategoryColors.all[colorIndex];
}
