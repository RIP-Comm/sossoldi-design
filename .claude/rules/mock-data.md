# Mock database

The prototype has no real database: all data lives in memory, in Dart, in `lib/mock/`.
Keep this file up to date whenever the mock data changes.

## Where things are
- `lib/mock/mock_repository.dart` — `MockRepository`, the **only** entry point. Screens read
  data through its methods and never import `lib/mock/data/` directly, so it can later be
  replaced by a real database with the same API.
- `lib/mock/models/` — immutable model classes, one file per entity.
- `lib/mock/data/` — static data and generators, one file per entity
  (exception: holdings and investment movements share `holding_data.dart`, because quantity
  and average cost are derived from the movements).
- `lib/mock/date_utils.dart` — date helpers (month arithmetic, next occurrence, trading days).
- `test/mock/mock_repository_test.dart` — consistency checks (see below).

## Rules
- Code and names in English. Data content (categories, descriptions) is in English too.
- Entities reference each other by `String` id, never by nested objects.
- Account and category colors are an index into `CategoryColors.all` (design system),
  never hand-written `Color`s. Icons come from Phosphor (`phosphoricons_flutter`).
- Subcategories have only a name and a parent id: icon and color are read from the parent.
- Amounts are `double` rounded to cents (fine for a prototype). Main currency is EUR;
  `MockRepository.toEur` converts with the fixed exchange rates.
- Bank names are fictional. Assets are real instruments, but **prices are simulated**.

## How the data is generated
- Everything is relative to "now": `MockRepository({DateTime? now})` defaults to
  `DateTime.now()`, so the prototype always looks current. Pass a fixed `now` in tests.
- Generators use `Random` with fixed seeds: the same `now` always gives the same data.
  Changing the order of random calls in a generator changes the generated data.
- **Transactions** (`transaction_data.dart`): ~6 months (`historyDays = 182`). Past
  occurrences of every recurring transaction (paused ones stop 60 days ago) plus variable
  spending/income from a table of specs (category, descriptions, amount range, count per
  month, probability). 30-50 per full month. Ids `tx_0001…` in date order.
- **Recurring** (`recurring_data.dart`): next dates computed from today (day of month,
  weekday or offset). Transactions they generate carry `recurringId`.
- **Budgets** (`budget_data.dart`): one per expense category, periods mixed via
  `budgetPlans`. Each plan has a `targetUsage`; the amount is calibrated as
  current-period spending / targetUsage, so on any day there are budgets ok (< 80%),
  warning (80-100%) and at least 2 exceeded (> 100%). Side effect: amounts change from
  day to day. If a budgeted category has no spending in its current period, the
  transaction generator adds one dated today.
- **Asset catalog** (`asset_catalog_data.dart`): 25 real ETFs, stocks and bonds (ISIN,
  ticker, exchange, currency, sector/region for ETFs and stocks). One year of daily prices
  on trading days: a random walk (seed per asset) bent so it ends exactly at a chosen
  yearly return. That return decides whether holdings end in gain or loss.
- **Holdings and movements** (`holding_data.dart`): a plan per position (trades with days
  ago, dividends with days ago; negative = expected future dividend). Buy/sell prices are
  taken from the price history; each trade has a 2.95 EUR fee. Holding quantity = buys −
  sells, average cost (PMC) = weighted average of buy prices. Manual assets (pension fund,
  watch, painting) have one buy at the purchase value and a hand-entered current value.
- **Exchange rates** (`exchange_rate_data.dart`): fixed USD/GBP/CHF to EUR, "updated"
  two hours before now.

## Contents (on 2026-10-22)
1 user · 3 accounts (checking, savings, broker) · 12 categories (8 expense, 4 income) with
32 subcategories · 8 budgets · ~240 transactions · 13 recurring (1 paused) · 25 catalog
assets · 9 holdings (6 catalog, 3 manual) · ~37 movements incl. 2 expected dividends ·
3 exchange rates.

## Known simplifications
- The broker account balance is its cash (transfers in); trades live only in the
  investment movements and do not move money between accounts.
- Bond ISINs (BTP Valore Giugno 2027, BTP Italia Novembre 2028) should be double-checked.

## Consistency test
`test/mock/mock_repository_test.dart` runs on several "now" dates (real today, first of
month, a Monday, new year, end of year) and checks: every referenced id exists, unique ids,
transfers have a destination and no category, every category has subcategories and every
subcategory a parent, one budget per expense category, all budget states present, holding
quantities and PMC match the movements, gains and losses in the portfolio, recurring next
dates in the future, 30-50 transactions per full month, catalog size and price history,
same data for the same `now`. Run it after any change to the mock data.
