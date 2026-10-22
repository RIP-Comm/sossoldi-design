import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:widgetbook/widgetbook.dart';

import 'components/buttons_use_cases.dart';
import 'components/chips_use_cases.dart';
import 'components/domain_use_cases.dart';
import 'components/inputs_use_cases.dart';
import 'components/navigation_use_cases.dart';
import 'components/overlay_use_cases.dart';
import 'components/selection_controls_use_cases.dart';
import 'components/web_use_cases.dart';
import 'foundations/category_colors_use_case.dart';
import 'foundations/primitive_colors_use_case.dart';
import 'foundations/semantic_colors_use_case.dart';
import 'foundations/spacing_radius_use_case.dart';
import 'foundations/typography_use_case.dart';

void main() {
  runApp(const SossoldiWidgetbook());
}

class SossoldiWidgetbook extends StatelessWidget {
  const SossoldiWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(name: 'Light', data: SossoldiTheme.light),
            WidgetbookTheme(name: 'Dark', data: SossoldiTheme.dark),
          ],
        ),
        LocalizationAddon(
          locales: const [Locale('en'), Locale('it')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
        ),
      ],
      directories: [
        WidgetbookFolder(
          name: 'Foundations',
          children: [
            WidgetbookComponent(
              name: 'Colors',
              useCases: [
                WidgetbookUseCase(
                  name: 'Semantic',
                  builder: (_) => const SemanticColorsUseCase(),
                ),
                WidgetbookUseCase(
                  name: 'Primitives',
                  builder: (_) => const PrimitiveColorsUseCase(),
                ),
                WidgetbookUseCase(
                  name: 'Categories',
                  builder: (_) => const CategoryColorsUseCase(),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'Typography',
              useCases: [
                WidgetbookUseCase(
                  name: 'Text styles',
                  builder: (_) => const TypographyUseCase(),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'Spacing & radius',
              useCases: [
                WidgetbookUseCase(
                  name: 'Scale',
                  builder: (_) => const SpacingRadiusUseCase(),
                ),
              ],
            ),
          ],
        ),
        WidgetbookFolder(
          name: 'Components',
          children: [
            _component('Button', const ButtonUseCase()),
            _component('Icon button', const IconButtonUseCase()),
            _component('Checkbox', const CheckboxUseCase()),
            _component('Radio button', const RadioUseCase()),
            _component('Switch', const SwitchUseCase()),
            _component('Chip', const ChipUseCase()),
            _component('Chip-Filter', const FilterChipUseCase()),
            _component('Tag', const TagUseCase()),
            _component('Text input', const TextInputUseCase()),
            _component('Textarea', const TextareaUseCase()),
            _component('Select', const SelectUseCase()),
            _component('Tabs', const TabUseCase()),
            _component('Tab navigation', const TabNavigationUseCase()),
            _component('Unit navigator', const UnitNavigatorUseCase()),
          ],
        ),
        WidgetbookFolder(
          name: 'Domain',
          children: [
            _component('Amount & change tag', const AmountUseCase()),
            _component('Avatar', const AvatarUseCase()),
            _component('Right chart', const RightChartUseCase()),
            _component('Transaction item', const TransactionItemUseCase()),
            _component('Account', const AccountItemUseCase()),
            _component('Category', const CategoryItemUseCase()),
            _component('Asset', const AssetItemUseCase()),
          ],
        ),
        WidgetbookFolder(
          name: 'Overlays & feedback',
          children: [
            _component('Bottom sheet', const BottomSheetUseCase()),
            _component('Modal', const ModalUseCase()),
            _component('Snackbar', const SnackbarUseCase()),
            _component('Alert', const AlertUseCase()),
            _component('Loader & progress', const LoaderProgressUseCase()),
            _component('Accordion', const AccordionUseCase()),
            _component(
              'Menu item, List, Dropdown',
              const MenuListDropdownUseCase(),
            ),
            _component('Search', const SearchUseCase()),
            _component('Auth code', const AuthCodeUseCase()),
          ],
        ),
        WidgetbookFolder(
          name: 'Navigation & hints',
          children: [
            _component('Breadcrumb', const BreadcrumbUseCase()),
            _component('Pagination', const PaginationUseCase()),
            _component('Tooltip', const TooltipUseCase()),
            _component('Popover', const PopoverUseCase()),
          ],
        ),
      ],
    );
  }
}

WidgetbookComponent _component(String name, Widget useCase) {
  return WidgetbookComponent(
    name: name,
    useCases: [
      WidgetbookUseCase(name: 'All variants', builder: (_) => useCase),
    ],
  );
}
