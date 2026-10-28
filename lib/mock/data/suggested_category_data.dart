import 'package:flutter/painting.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../design_system/tokens/category_colors.dart';
import '../models/category.dart';
import '../models/suggested_category.dart';

/// The categories suggested in the onboarding (Figma "Onboarding 0.2.0", icons
/// and colors read from the nodes), in the order they are shown.
final suggestedCategories = [
  SuggestedCategory(
    type: CategoryType.expense,
    name: 'Housing',
    icon: PhosphorIconsRegular.houseLine,
    // Not one of the palette: the yellow of the Figma icon.
    color: CategoryColor.fromColor(const Color(0xFFE9B814)),
  ),
  SuggestedCategory(
    type: CategoryType.expense,
    name: 'Groceries',
    icon: PhosphorIconsRegular.shoppingCartSimple,
    color: CategoryColors.all[12],
  ),
  SuggestedCategory(
    type: CategoryType.expense,
    name: 'Stuff',
    icon: PhosphorIconsRegular.intersectThree,
    color: CategoryColors.all[21],
  ),
  SuggestedCategory(
    type: CategoryType.expense,
    name: 'Health',
    icon: PhosphorIconsRegular.hospital,
    color: CategoryColors.all[37],
  ),
  SuggestedCategory(
    type: CategoryType.expense,
    name: 'Travel',
    icon: PhosphorIconsRegular.airplaneTilt,
    color: CategoryColors.all[20],
  ),
  SuggestedCategory(
    type: CategoryType.expense,
    name: 'Transportation',
    icon: PhosphorIconsRegular.bus,
    color: CategoryColors.all[3],
  ),
  SuggestedCategory(
    type: CategoryType.income,
    name: 'Work',
    icon: PhosphorIconsRegular.suitcaseSimple,
    color: CategoryColors.all[13],
  ),
  SuggestedCategory(
    type: CategoryType.income,
    name: 'Extra',
    icon: PhosphorIconsRegular.handCoins,
    color: CategoryColors.all[33],
  ),
];
