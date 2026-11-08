import 'package:flutter/material.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/l10n/l10n.dart';
import 'package:widgetbook/widgetbook.dart';

import 'components/account_use_cases.dart';
import 'components/app_shell_use_cases.dart';
import 'components/buttons_use_cases.dart';
import 'components/chips_use_cases.dart';
import 'components/domain_use_cases.dart';
import 'components/finance_use_cases.dart';
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
          localizationsDelegates: AppLocalizations.localizationsDelegates,
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
            _component('Amount input', const AmountInputUseCase()),
            _component('Textarea', const TextareaUseCase()),
            _component('Select', const SelectUseCase()),
            _component('Color picker', const ColorPickerUseCase()),
            _component('Icon picker', const IconPickerUseCase()),
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
            _component('Alert carousel', const AlertCarouselUseCase()),
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
          name: 'App shell & dashboard',
          children: [
            _component('Header button', const HeaderButtonUseCase()),
            _component('Navbar', const NavbarUseCase()),
            _component('Widget card', const WidgetCardUseCase()),
            _component('Trend chart', const TrendChartUseCase()),
            _component('Edit controls', const EditControlsUseCase()),
            _component(
              'Monthly balance (S, M, L)',
              const MonthlyBalanceUseCase(),
            ),
            _component(
              'Latest transactions (S, M, L)',
              const LatestTransactionsUseCase(),
            ),
            _component('Dashboard edit demo', const DashboardEditDemoUseCase()),
          ],
        ),
        WidgetbookFolder(
          name: 'Finance',
          children: [
            _component('Filter button', const FilterButtonUseCase()),
            _component('Day header', const DayHeaderUseCase()),
            _component('Receipt', const ReceiptUseCase()),
            _component('Empty state', const EmptyStateUseCase()),
            _component('Donut chart + legend', const DonutChartUseCase()),
            _component('Stacked area chart', const StackedAreaChartUseCase()),
            _component('Budget item + bar', const BudgetItemUseCase()),
            _component('Segmented bar', const SegmentedBarUseCase()),
            _component('Danger button', const DangerButtonUseCase()),
            _component('Date range picker', const DateRangePickerUseCase()),
            _component('Date picker', const DatePickerUseCase()),
            _component('Time picker', const TimePickerUseCase()),
            _component('Calendar + month selector', const CalendarUseCase()),
            _component('Cash flow chart', const CashFlowChartUseCase()),
            _component('Budget card', const BudgetCardUseCase()),
            _component('Portfolio card', const PortfolioCardUseCase()),
            _component('Breakdown item', const BreakdownItemUseCase()),
            _component('Operation item', const OperationItemUseCase()),
            _component('Movement item', const MovementItemUseCase()),
            _component('Value chart', const ValueChartUseCase()),
            _component('Finance page demo', const FinanceDemoUseCase()),
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
