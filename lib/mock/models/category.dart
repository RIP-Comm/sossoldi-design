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
    required this.color,
  });

  final String id;
  final CategoryType type;
  final String name;
  final IconData icon;

  /// A color of [CategoryColors.all] or a free one from the color picker.
  final CategoryColor color;

  Category copyWith({
    CategoryType? type,
    String? name,
    IconData? icon,
    CategoryColor? color,
  }) => Category(
    id: id,
    type: type ?? this.type,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
  );
}
