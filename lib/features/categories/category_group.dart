// A titled list of categories ("Expenses", "Income"): the title in Body Large
// above a [SossoldiList]. Shared by the onboarding and Settings > Categories.

import 'package:flutter/material.dart';

import '../../design_system/design_system.dart';

class CategoryGroup extends StatelessWidget {
  const CategoryGroup({super.key, required this.title, required this.children});

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
