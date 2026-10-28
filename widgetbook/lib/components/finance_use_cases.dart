import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/finance/finance_controller.dart';
import 'package:sossoldi/features/finance/finance_screen.dart';

import '../foundations/foundation_page.dart';

class FilterButtonUseCase extends StatelessWidget {
  const FilterButtonUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Default / With active filters / Disabled',
          children: [
            SossoldiFilterButton(onPressed: () {}, semanticLabel: 'Filters'),
            SossoldiFilterButton(
              onPressed: () {},
              semanticLabel: 'Filters',
              active: true,
            ),
            const SossoldiFilterButton(
              onPressed: null,
              semanticLabel: 'Filters',
            ),
          ],
        ),
      ],
    );
  }
}

class DayHeaderUseCase extends StatelessWidget {
  const DayHeaderUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Income / Expense / No total / Long title',
          children: const [
            SizedBox(
              width: 358,
              child: SossoldiDayHeader(
                title: 'Saturday, June 27th',
                total: '+ 1.790,01€',
              ),
            ),
            SizedBox(
              width: 358,
              child: SossoldiDayHeader(
                title: 'Friday, June 26th',
                total: '- 20,32€',
                positive: false,
              ),
            ),
            SizedBox(
              width: 358,
              child: SossoldiDayHeader(title: 'Only transfers today'),
            ),
            SizedBox(
              width: 220,
              child: SossoldiDayHeader(
                title: 'Wednesday, September 24th, a very long title',
                total: '- 67,91€',
                positive: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class EmptyStateUseCase extends StatelessWidget {
  const EmptyStateUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'With filters (hint + action) / Plain',
          children: [
            SizedBox(
              width: 358,
              child: SossoldiEmptyState(
                icon: PhosphorIconsRegular.magnifyingGlass,
                title: 'No transactions found',
                message: 'Try changing the search or the filters.',
                actionLabel: 'Clear filters',
                onAction: () {},
              ),
            ),
            const SizedBox(
              width: 358,
              child: SossoldiEmptyState(
                icon: PhosphorIconsRegular.magnifyingGlass,
                title: 'No transactions found',
                message: 'There are no transactions in this period.',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

const _demoColors = [
  Color(0xFFB655F6),
  Color(0xFF16DCB1),
  Color(0xFFF36127),
  Color(0xFFD3DD16),
];
const _demoNames = ['Home', 'Groceries', 'Transport', 'Leisure'];
const _demoAmounts = [1568.19, 398.27, 348.48, 174.24];

class DonutChartUseCase extends StatelessWidget {
  const DonutChartUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Four categories with legend / One / Many / Empty',
          children: [
            SizedBox(
              width: 334,
              child: Column(
                spacing: 12,
                children: [
                  SossoldiDonutChart(
                    segments: [
                      for (final (i, v) in _demoAmounts.indexed)
                        SossoldiChartSegment(value: v, color: _demoColors[i]),
                    ],
                  ),
                  SossoldiChartLegend(
                    items: [
                      for (final (i, v) in _demoAmounts.indexed)
                        SossoldiLegendItem(
                          color: _demoColors[i],
                          label: _demoNames[i],
                          value: '${v.toStringAsFixed(2)} €',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SossoldiDonutChart(
              size: 120,
              segments: [
                SossoldiChartSegment(value: 1, color: Color(0xFFB655F6)),
              ],
            ),
            SossoldiDonutChart(
              size: 120,
              segments: [
                for (var i = 0; i < 12; i++)
                  SossoldiChartSegment(
                    value: 12.0 - i,
                    color: HSVColor.fromAHSV(1, i * 30.0, .7, .9).toColor(),
                  ),
              ],
            ),
            const SossoldiDonutChart(size: 120, segments: []),
          ],
        ),
      ],
    );
  }
}

class StackedAreaChartUseCase extends StatefulWidget {
  const StackedAreaChartUseCase({super.key});

  @override
  State<StackedAreaChartUseCase> createState() =>
      _StackedAreaChartUseCaseState();
}

class _StackedAreaChartUseCaseState extends State<StackedAreaChartUseCase> {
  bool _masked = false;

  @override
  Widget build(BuildContext context) {
    const weeks = ['30 May', '6 Jun', '13 Jun', '20 Jun', '27 Jun', '4 Jul'];
    const values = <List<double>>[
      [50, 52, 80, 95, 60, 30],
      [20, 40, 10, 35, 45, 55],
      [30, 140, 110, 90, 40, 45],
      [150, 90, 70, 110, 120, 60],
    ];
    Widget chart(List<List<double>> data, {bool masked = false}) => SizedBox(
      width: 334,
      child: SossoldiStackedAreaChart(
        masked: masked,
        totalLabel: 'Total',
        pointLabels: weeks.sublist(0, data.first.length),
        pointTitles: [
          for (final w in weeks.sublist(0, data.first.length)) 'Week of $w',
        ],
        formatValue: (v) => '${v.toStringAsFixed(2)} €',
        formatAxis: (v) => v.toStringAsFixed(0),
        series: [
          for (final (i, v) in data.indexed)
            SossoldiAreaSeries(
              name: _demoNames[i],
              color: _demoColors[i],
              values: v,
            ),
        ],
      ),
    );
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Touch or drag for the values (hide amounts to mask them)',
          children: [
            SossoldiSwitch(
              value: _masked,
              onChanged: (v) => setState(() => _masked = v),
              semanticLabel: 'Hide amounts',
            ),
            chart(values, masked: _masked),
          ],
        ),
        FoundationSection(
          title: 'Few points / One point',
          children: [
            chart([for (final v in values) v.sublist(0, 3)]),
            chart([for (final v in values) v.sublist(0, 1)]),
          ],
        ),
      ],
    );
  }
}

class BudgetItemUseCase extends StatelessWidget {
  const BudgetItemUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final brightness = Theme.of(context).brightness;
    const category = CategoryColor(Color(0xFFB655F6), Color(0xFFEACFFC));
    Widget item(
      String name,
      double usage,
      SossoldiBudgetTone tone,
      String remaining, {
      bool prominent = false,
      String? period,
      bool divider = false,
    }) {
      final overall = prominent;
      final fill = overall
          ? switch (tone) {
              SossoldiBudgetTone.ok => colors.primary.surface,
              SossoldiBudgetTone.warning => colors.warning.stroke,
              SossoldiBudgetTone.exceeded => colors.error.stroke,
            }
          : category.main;
      final track = overall
          ? switch (tone) {
              SossoldiBudgetTone.ok => colors.primary.surface.withValues(
                alpha: 0.2,
              ),
              SossoldiBudgetTone.warning => colors.warning.surface,
              SossoldiBudgetTone.exceeded => colors.error.surface,
            }
          : category.tintFor(brightness);
      return SossoldiBudgetItem(
        title: name,
        percent: '${(usage * 100).round()}%',
        remaining: remaining,
        tone: tone,
        prominent: prominent,
        periodLabel: period,
        showDivider: divider,
        bar: SossoldiBudgetBar(
          value: usage,
          color: fill,
          trackColor: track,
          // Only the overall bar of an exceeded budget has the outline.
          exceeded: overall && tone == SossoldiBudgetTone.exceeded,
        ),
      );
    }

    Widget card(List<Widget> children) =>
        SizedBox(width: 358, child: SossoldiList(children: children));
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Row: ok / warning (from 80%) / exceeded',
          children: [
            card([
              item(
                'Groceries',
                .5,
                SossoldiBudgetTone.ok,
                '120,00 € left',
                divider: true,
              ),
              item(
                'Transport',
                .86,
                SossoldiBudgetTone.warning,
                '28,00 € left',
                divider: true,
              ),
              item(
                'Leisure',
                1.34,
                SossoldiBudgetTone.exceeded,
                '51,00 € over',
              ),
            ]),
          ],
        ),
        FoundationSection(
          title: 'Overall: ok / warning / exceeded',
          children: [
            card([
              item(
                'Overall budget',
                .62,
                SossoldiBudgetTone.ok,
                '246,00 € left',
                prominent: true,
              ),
            ]),
            card([
              item(
                'Overall budget',
                .88,
                SossoldiBudgetTone.warning,
                '90,00 € left',
                prominent: true,
              ),
            ]),
            card([
              item(
                'Overall budget',
                1.12,
                SossoldiBudgetTone.exceeded,
                '75,00 € over',
                prominent: true,
              ),
            ]),
          ],
        ),
        FoundationSection(
          title: 'With period chip / Long name and amount / Hidden',
          children: [
            card([
              item(
                'Groceries',
                .5,
                SossoldiBudgetTone.ok,
                '120,00 € left',
                period: 'Monthly',
              ),
            ]),
            card([
              item(
                'A category with a really very long name indeed',
                1.5,
                SossoldiBudgetTone.exceeded,
                '1.234.567,00 € over',
              ),
            ]),
            card([item('Groceries', .5, SossoldiBudgetTone.ok, '•••• left')]),
          ],
        ),
      ],
    );
  }
}

class SegmentedBarUseCase extends StatelessWidget {
  const SegmentedBarUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    SossoldiBarSegment seg(int color, double share, {bool exceeded = false}) =>
        SossoldiBarSegment(
          share: share,
          color: CategoryColors.all[color].main,
          exceeded: exceeded,
        );
    Widget bar(List<SossoldiBarSegment> s) =>
        SizedBox(width: 334, child: SossoldiSegmentedBar(segments: s));
    return FoundationPage(
      children: [
        FoundationSection(
          title:
              'The bar is the total budget: the parts are what was spent (70%)',
          children: [
            bar([seg(2, .25), seg(14, .2), seg(5, .15), seg(20, .1)]),
          ],
        ),
        FoundationSection(
          title: 'A part over its own limit has the error outline',
          children: [
            bar([
              seg(2, .25),
              seg(14, .2, exceeded: true),
              seg(5, .15),
              seg(20, .1, exceeded: true),
            ]),
          ],
        ),
        FoundationSection(
          title: 'Total reached (full) / Barely started / Nothing spent',
          children: [
            bar([seg(2, .5), seg(14, .3), seg(5, .2)]),
            bar([seg(2, .03), seg(14, .02)]),
            bar(const []),
          ],
        ),
      ],
    );
  }
}

class DangerButtonUseCase extends StatelessWidget {
  const DangerButtonUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Danger: fill / outline / ghost / disabled',
          children: [
            for (final type in SossoldiButtonType.values)
              SossoldiButton(
                label: 'Delete budget',
                type: type,
                tone: SossoldiButtonTone.danger,
                size: SossoldiButtonSize.large,
                onPressed: () {},
              ),
            const SossoldiButton(
              label: 'Delete budget',
              tone: SossoldiButtonTone.danger,
              size: SossoldiButtonSize.large,
              onPressed: null,
            ),
          ],
        ),
      ],
    );
  }
}

class DateRangePickerUseCase extends StatefulWidget {
  const DateRangePickerUseCase({super.key});

  @override
  State<DateRangePickerUseCase> createState() => _DateRangePickerUseCaseState();
}

class _DateRangePickerUseCaseState extends State<DateRangePickerUseCase> {
  DateTime? _start;
  DateTime? _end;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Tap two days: start, then end (future days are disabled)',
          children: [
            Container(
              width: 358,
              padding: const EdgeInsets.all(SossoldiSpacing.s),
              decoration: ShapeDecoration(
                color: context.colors.surfaceHigh,
                shape: RoundedSuperellipseBorder(
                  borderRadius: BorderRadius.circular(SossoldiRadius.m),
                ),
              ),
              child: SossoldiDateRangePicker(
                start: _start,
                end: _end,
                lastDate: today,
                onChanged: (s, e) => setState(() {
                  _start = s;
                  _end = e;
                }),
                previousMonthSemanticLabel: 'Previous month',
                nextMonthSemanticLabel: 'Next month',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CashFlowChartUseCase extends StatelessWidget {
  const CashFlowChartUseCase({super.key});

  static List<double> _cumulative(List<double> daily) {
    var sum = 0.0;
    return [for (final v in daily) sum += v];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final income = _cumulative([
      for (var i = 0; i < 22; i++) i == 17 ? 2150 : 0,
    ]);
    final expenses = _cumulative([
      for (var i = 0; i < 22; i++) 40.0 + (i % 5) * 25,
    ]);
    final balance = [
      for (var i = 0; i < income.length; i++) income[i] - expenses[i],
    ];
    Widget chart({
      required List<double> inc,
      required List<double> exp,
      required List<double> bal,
      bool masked = false,
    }) => Container(
      width: 358,
      padding: const EdgeInsets.all(SossoldiSpacing.m),
      decoration: ShapeDecoration(
        color: colors.surfaceHigh,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(SossoldiRadius.m),
        ),
      ),
      child: Column(
        spacing: SossoldiSpacing.m,
        children: [
          SossoldiCashFlowChart(
            income: inc,
            expenses: exp,
            balance: bal,
            length: 31,
            xLabels: [for (var d = 1; d <= 31; d++) 'Oct $d'],
            formatAxis: (v) => '${v > 0 ? '+' : ''}${v.round()}',
            pointTitles: [for (var d = 1; d <= 31; d++) 'Oct $d'],
            formatValue: (v) => '${v.toStringAsFixed(2)} €',
            incomeLabel: 'Income',
            expenseLabel: 'Expense',
            balanceLabel: 'Balance',
            masked: masked,
          ),
          SossoldiChartLegend(
            items: [
              SossoldiLegendItem(
                color: colors.income.onSurface,
                label: 'Income',
              ),
              SossoldiLegendItem(
                color: colors.expense.onSurface,
                label: 'Expense',
              ),
              SossoldiLegendItem(color: colors.shapeMed, label: 'Balance'),
            ],
          ),
        ],
      ),
    );
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Month so far / first day / hidden amounts',
          children: [
            chart(inc: income, exp: expenses, bal: balance),
            chart(inc: const [0], exp: const [12], bal: const [-12]),
            chart(inc: income, exp: expenses, bal: balance, masked: true),
          ],
        ),
      ],
    );
  }
}

class PortfolioCardUseCase extends StatelessWidget {
  const PortfolioCardUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    Widget card({
      double gain = 1680,
      double percent = 0.2423,
      bool masked = false,
    }) => SizedBox(
      width: 358,
      child: SossoldiPortfolioCard(
        label: 'Portfolio value',
        value: 32734.88,
        gain: gain,
        gainPercent: percent,
        currencyCode: 'EUR',
        liquidityLabel: 'Available liquidity',
        liquidity: 1500.2,
        masked: masked,
      ),
    );
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Gain / loss / hidden amounts',
          children: [
            card(),
            card(gain: -1680, percent: -0.0488),
            card(masked: true),
          ],
        ),
      ],
    );
  }
}

class ValueChartUseCase extends StatelessWidget {
  const ValueChartUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final values = [
      for (var i = 0; i < 60; i++) 30000 + i * 120 + (i % 7) * 250.0,
    ];
    final invested = [for (var i = 0; i < 60; i++) i < 30 ? 29000.0 : 31500.0];
    Widget chart({List<double>? v, List<double>? inv, bool masked = false}) =>
        Container(
          width: 358,
          padding: const EdgeInsets.all(SossoldiSpacing.m),
          decoration: ShapeDecoration(
            color: colors.surfaceHigh,
            shape: RoundedSuperellipseBorder(
              borderRadius: BorderRadius.circular(SossoldiRadius.m),
            ),
          ),
          child: Column(
            spacing: SossoldiSpacing.m,
            children: [
              SossoldiValueChart(
                values: v ?? values,
                invested: inv ?? invested,
                pointLabels: [
                  for (var d = 1; d <= (v ?? values).length; d++) 'D$d',
                ],
                pointTitles: [
                  for (var d = 1; d <= (v ?? values).length; d++) 'Day $d',
                ],
                formatAxis: (x) => '${(x / 1000).toStringAsFixed(0)}K',
                formatValue: (x) => '${x.toStringAsFixed(2)} €',
                valueLabel: 'Market value',
                investedLabel: 'Invested',
                masked: masked,
              ),
              SossoldiChartLegend(
                items: [
                  SossoldiLegendItem(
                    color: colors.income.onSurface,
                    label: 'Market value',
                  ),
                  SossoldiLegendItem(color: colors.shapeMed, label: 'Invested'),
                ],
              ),
            ],
          ),
        );
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Tap or drag for the card: above invested / below / hidden / one point',
          children: [
            chart(),
            chart(
              v: [for (var i = 0; i < 60; i++) 28000 - i * 40.0],
              inv: List.filled(60, 29000),
            ),
            chart(masked: true),
            chart(v: const [30000], inv: const [29000]),
          ],
        ),
      ],
    );
  }
}

class BreakdownItemUseCase extends StatelessWidget {
  const BreakdownItemUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    Widget row(String name, double share, int color, {bool masked = false}) =>
        SossoldiBreakdownItem(
          name: name,
          share: share,
          value: 13242 * share * 2,
          currencyCode: 'EUR',
          color: CategoryColors.all[color].main,
          trackColor: CategoryColors.all[color].tintFor(brightness),
          percentText: '${(share * 100).round()}%',
          masked: masked,
        );
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Breakdown rows: shares / hidden amount',
          children: [
            SizedBox(
              width: 358,
              child: SossoldiList(
                children: [
                  row('North America', .5, 3),
                  row('Europe', .25, 26),
                  row('Emerging markets', .08, 20),
                  row('Other', .02, 9, masked: true),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class OperationItemUseCase extends StatelessWidget {
  const OperationItemUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Buy / sell / dividend / hidden',
          children: [
            SizedBox(
              width: 358,
              child: SossoldiList(
                children: const [
                  SossoldiOperationItem(
                    typeLabel: 'Buy',
                    title: 'VWCE',
                    amount: 329.4,
                    currencyCode: 'EUR',
                    details: '3 × 109,80 €',
                  ),
                  SossoldiOperationItem(
                    typeLabel: 'Sell',
                    title: 'NVDA',
                    amount: 1020,
                    currencyCode: 'USD',
                    details: '8 × 127,50 \$',
                  ),
                  SossoldiOperationItem(
                    typeLabel: 'Dividend',
                    title: 'AAPL',
                    amount: 26,
                    currencyCode: 'USD',
                    positive: true,
                  ),
                  SossoldiOperationItem(
                    typeLabel: 'Buy',
                    title: 'A very long name of an asset that does not fit',
                    amount: 1234.5,
                    currencyCode: 'EUR',
                    details: '12 × 102,87 €',
                    masked: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class MovementItemUseCase extends StatelessWidget {
  const MovementItemUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Buy / sell (neutral), dividend (green), cost (red), hidden',
          children: [
            SizedBox(
              width: 358,
              child: SossoldiList(
                children: const [
                  SossoldiMovementItem(
                    typeLabel: 'Buy',
                    typeIcon: PhosphorIconsRegular.arrowDownLeft,
                    title: 'Vanguard FTSE All-World UCITS ETF Acc',
                    subtitle: 'VWCE – IE00BK5BQT80',
                    details: '4 · Price 129,85 €',
                    amount: 522.35,
                    currencyCode: 'EUR',
                  ),
                  SossoldiMovementItem(
                    typeLabel: 'Sell',
                    typeIcon: PhosphorIconsRegular.arrowUpRight,
                    title: 'Apple Inc.',
                    subtitle: 'AAPL – US0378331005',
                    details: '2 · Price 212,40 \$',
                    amount: 424.8,
                    currencyCode: 'USD',
                  ),
                  SossoldiMovementItem(
                    typeLabel: 'Dividend',
                    typeIcon: PhosphorIconsRegular.coins,
                    tone: SossoldiMovementTone.income,
                    title: 'Eni S.p.A.',
                    subtitle: 'ENI – IT0003132476',
                    details: '5 dic 2026',
                    amount: 55,
                    currencyCode: 'EUR',
                  ),
                  SossoldiMovementItem(
                    typeLabel: 'Cost',
                    typeIcon: PhosphorIconsRegular.receipt,
                    tone: SossoldiMovementTone.expense,
                    title: 'Broker custody fee',
                    amount: -12,
                    currencyCode: 'EUR',
                  ),
                  SossoldiMovementItem(
                    typeLabel: 'Buy',
                    typeIcon: PhosphorIconsRegular.arrowDownLeft,
                    title: 'A very long asset name that goes on and on',
                    subtitle: 'LONGTICKER – IE00BK5BQT80',
                    details: '1.234 · Price 1.234,56 €',
                    amount: 1523456.78,
                    currencyCode: 'EUR',
                    masked: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class BudgetCardUseCase extends StatelessWidget {
  const BudgetCardUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    Widget card(SossoldiBudgetTone tone, String percent, String remaining) =>
        SizedBox(
          width: 160,
          child: SossoldiBudgetItem(
            card: true,
            title: 'Category name',
            percent: percent,
            remaining: remaining,
            tone: tone,
            bar: SossoldiBudgetBar(
              value: tone == SossoldiBudgetTone.ok ? .5 : 1,
              color: CategoryColors.all[3].main,
              trackColor: CategoryColors.all[3].tintFor(
                Theme.of(context).brightness,
              ),
            ),
          ),
        );
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Card (160px): ok / warning / exceeded',
          children: [
            card(SossoldiBudgetTone.ok, '50%', '120,00 € left'),
            card(SossoldiBudgetTone.warning, '85%', '20,00 € left'),
            card(SossoldiBudgetTone.exceeded, '126%', '34,62 € over'),
          ],
        ),
      ],
    );
  }
}

class CalendarUseCase extends StatefulWidget {
  const CalendarUseCase({super.key});

  @override
  State<CalendarUseCase> createState() => _CalendarUseCaseState();
}

class _CalendarUseCaseState extends State<CalendarUseCase> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selected;

  static const _dots = <int, Set<SossoldiCalendarDot>>{
    1: {SossoldiCalendarDot.expense},
    2: {SossoldiCalendarDot.expense, SossoldiCalendarDot.transfer},
    15: {SossoldiCalendarDot.transfer},
    20: {
      SossoldiCalendarDot.expense,
      SossoldiCalendarDot.income,
      SossoldiCalendarDot.transfer,
    },
    27: {SossoldiCalendarDot.income},
  };

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Month selector + calendar (tap a day; tap it again)',
          children: [
            SizedBox(
              width: 358,
              child: Column(
                spacing: SossoldiSpacing.m,
                children: [
                  SossoldiMonthSelector(
                    month: _month,
                    onPrevious: () => setState(() {
                      _month = DateTime(_month.year, _month.month - 1);
                      _selected = null;
                    }),
                    onNext: () => setState(() {
                      _month = DateTime(_month.year, _month.month + 1);
                      _selected = null;
                    }),
                    onTap: () async {
                      final picked = await showSossoldiMonthPicker(
                        context: context,
                        selected: _month,
                        firstYear: today.year - 5,
                        lastYear: today.year + 5,
                        title: 'Select month',
                        closeSemanticLabel: 'Close',
                        previousYearSemanticLabel: 'Previous year',
                        nextYearSemanticLabel: 'Next year',
                      );
                      if (picked != null) {
                        setState(() {
                          _month = picked;
                          _selected = null;
                        });
                      }
                    },
                    previousSemanticLabel: 'Previous month',
                    nextSemanticLabel: 'Next month',
                    pickSemanticLabel: 'Choose the month',
                  ),
                  SossoldiCalendar(
                    month: _month,
                    today: today,
                    selectedDay: _selected,
                    dots: _dots,
                    onDayTap: (d) =>
                        setState(() => _selected = _selected == d ? null : d),
                  ),
                ],
              ),
            ),
          ],
        ),
        FoundationSection(
          title: 'Without interaction: dots of every kind, no selection',
          children: [
            SizedBox(
              width: 358,
              child: SossoldiCalendar(
                month: DateTime(2026, 2),
                today: DateTime(2026, 2, 12),
                dots: _dots,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The whole Finance page with its own state: search, filter, paginate.
class FinanceDemoUseCase extends StatefulWidget {
  const FinanceDemoUseCase({super.key});

  @override
  State<FinanceDemoUseCase> createState() => _FinanceDemoUseCaseState();
}

class _FinanceDemoUseCaseState extends State<FinanceDemoUseCase> {
  final AppState _state = AppState();
  late final FinanceController _controller = FinanceController(
    _state.repository,
  );

  @override
  void dispose() {
    _controller.dispose();
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 390,
        child: ColoredBox(
          color: context.colors.surfaceMed,
          child: AppScope(
            state: _state,
            child: FinanceScreen(controller: _controller),
          ),
        ),
      ),
    );
  }
}
