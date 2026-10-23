import 'package:flutter/foundation.dart';

/// A subcategory has its own name; icon and color come from the parent
/// Category ([categoryId]).
@immutable
class Subcategory {
  const Subcategory({
    required this.id,
    required this.categoryId,
    required this.name,
  });

  final String id;
  final String categoryId;
  final String name;
}
