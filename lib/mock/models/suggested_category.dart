import 'package:flutter/widgets.dart';

import '../../design_system/tokens/category_colors.dart';
import 'category.dart';

/// A category the onboarding suggests (it is created with no subcategories).
@immutable
class SuggestedCategory {
  const SuggestedCategory({
    required this.type,
    required this.name,
    required this.icon,
    required this.color,
  });

  final CategoryType type;
  final String name;
  final IconData icon;
  final CategoryColor color;
}
