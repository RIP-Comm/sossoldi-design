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
- Account and category colors are a `CategoryColor` (design system): one of `CategoryColors.all` in the
  demo data, or a free one from the color picker (`CategoryColor.fromColor`: the tint derived like the
  palette's, HSL lightness 90%). Never hand-written `Color`s in the data. Icons come from Phosphor
  (`phosphoricons_flutter`).
- Subcategories have only a name and a parent id: icon and color are read from the parent.
- Amounts are `double` rounded to cents (fine for a prototype). The data is in EUR and EUR is the
  default main currency; `MockRepository.setMainCurrency` (EUR, USD, GBP, CHF) changes it and the
  repository notifies its listeners. Every total, balance and aggregate is in the main currency:
  `toMain` converts through EUR with the fixed rates (`toEur` is the base conversion). Single
  transactions keep their own currency.
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
- **Budgets** (`budget_data.dart`): at least one per expense category, and a category can have
  several on different periods (never two on the same: Groceries weekly + monthly, Leisure
  monthly + weekly); none on subcategories, none on the semiannual period (so that its empty
  state shows). Ids `bud_<category>_<period>`. Periods mixed via `budgetPlans`. Each plan has a `targetUsage`; the amount is calibrated as
  current-period spending / targetUsage, so on any day there are budgets ok (< 80%),
  warning (80-100%) and at least 2 exceeded (> 100%). Side effect: amounts change from
  day to day. If a budgeted category has no spending in its current period, the
  transaction generator adds one dated today.
- **Asset catalog** (`asset_catalog_data.dart`): 25 real ETFs, stocks and bonds (ISIN,
  ticker, exchange, currency, sector/region for ETFs and stocks). Five years of daily prices
  on trading days. The last year is a random walk (seed per asset) bent so it ends exactly at a
  chosen yearly return (that return decides whether holdings end in gain or loss); the four years
  before it are a separate walk (own seed) that ends on the price a year ago (bonds +4% over the
  period, the rest +40%), so the last year never changes. `buildIntradayPrices`: a price every
  15 minutes from 09:00 to 17:30 (35 points, the same hours for every exchange: a simplification)
  for the last 5 trading days, from the open (small gap on the previous close) to the official
  close, which is the last point of the day.
- **Holdings and movements** (`holding_data.dart`): a plan per position (trades with days
  ago, dividends with days ago; negative = expected future dividend). Buy/sell prices are
  taken from the price history; each trade has a 2.95 EUR fee. Purchases cover about four years (a
  quarterly plan on VWCE from ~3 years ago, older buys on the others; the pension fund bought ~4
  years ago), so the 5Y chart has something to show. Holding quantity = buys −
  sells, average cost (PMC) = weighted average of buy prices. Manual assets (pension fund,
  watch, painting) have one buy at the purchase value and a hand-entered current value.
- **Exchange rates** (`exchange_rate_data.dart`): fixed USD, GBP, CHF, BRL, AED, JPY and CAD to EUR,
  "updated" two hours before now. They are the currencies of the selectors (`supportedCurrencies`: EUR first).

## Derived reads added for screens
- `mainCurrency` — the user's main currency (EUR).
- `netResult(start, end)` — income minus expenses in EUR, transfers excluded.
- `cumulativeNetByDay(start, end)` — cumulative net at the end of each calendar day.
- `balanceTrend({on})` → `BalanceTrend` (`models/balance_trend.dart`): net of the month of
  `on` (default today) day by day up to `on`, plus the whole previous month for comparison,
  the month's `income` and `expenses`, and `vsPreviousSameDay` (net so far minus the previous
  month's net on the same day). Feeds the Dashboard "Monthly balance" widget (S, M, L).
- `latestTransactions(count)` — the newest transactions, transfers included. Feeds the
  Dashboard "Latest transactions" widget.
- `searchTransactions(TransactionFilter, {page, pageSize = 20})` → `TransactionPage`
  (`models/transaction_filter.dart`, `models/transaction_page.dart`): search, filter and paginate
  the Finance > Transactions list. The filter combines (AND) text (description, category,
  subcategory, account and transfer destination names), date range (days, inclusive; both
  null = any date), types, categories (a category filter leaves out transfers), accounts
  (both sides of a transfer) and an amount range compared **in the main currency**.
  Newest first; the page is clamped; `total`/`pageCount` cover all pages; `netByDay` has, for
  each day on the page, income minus expenses in EUR of **all** the filtered transactions of
  that day (transfers excluded, so transfer-only days have no entry). No filter logic in the UI.
  The mock has no transaction in a currency other than EUR; the conversion path is
  `toEur`, shared with the other reads.
- `transactionBreakdown(range, kind, accountIds, categoryIds, granularity)` →
  `TransactionBreakdown` (`models/transaction_breakdown.dart`, ranges in
  `models/transaction_time_range.dart`): everything of Finance > Transactions > Charts. Ranges are
  Current month (1st to today), Last month (the whole previous month), Last 3/6/12 months (the
  current month so far plus the 2/5/11 full ones before) and Year to date; the previous period has
  the same number of days and ends the day before the range starts. Returns the total and the
  previous total, the amount per top-level category (largest first, only those with money) and
  the buckets per week (Monday to Sunday) or month, cut to the range, empty ones included. Only
  expenses or only income, transfers excluded, EUR, summed in cents so total = sum of
  categories = sum of buckets exactly. Granularity: weekly always, monthly from 2 calendar
  months, default monthly from 6; an unsuitable one falls back to the default.
  `changeVsPrevious` is null when the previous period has no money.
- Budgets: `budgetsForCategory`, `budgetStatus(budget, {on, amountInMain})`, `budgetOverview(period)`
  (`models/budget_status.dart`, `models/budget_overview.dart`). Each budget is computed on its own
  current period (week Monday to Sunday, month, quarter, semester, year), only expenses of the
  category (subcategory expenses already carry the parent), converted to the main currency;
  state ok < 80%, warning from 80% to 100%, exceeded over 100% (`overBy`, `remaining` negative).
  The overview of a period has the total, the spent (overspending included), the usage/state,
  the items largest first and the parts of the segmented bar. The whole bar is the total budget:
  each part is what one budget spent (`share` = spent / total, or spent / total spent when the
  total is exceeded, so the bar is full), only for budgets that spent something; `exceeded`
  marks a budget over its own limit. The parts add up to the overall usage (max 1) and
  `emptyShare` is the neutral rest. `budgetTransactionFilter(id)` selects the expenses counted in a
  budget (read them with `searchTransactions`). `updateBudgetAmount` (amount in the main
  currency, stored in the budget's currency, positive only, else ArgumentError) and
  `deleteBudget` change the data in memory and notify.
- Recurring: `recurringOccurrences(year, month)` → `RecurringOccurrence`s (`models/recurring_occurrence.dart`),
  `recurringDayTypes(year, month)` (day → kinds, the calendar dots), `recurringHistory(id, {range})` →
  `RecurringYearGroup`s (old transactions by year, newest first, total of the year in the main currency:
  expenses negative; ranges last 3/6/12 months or all). Past dates are the real transactions linked by
  `recurringId`; the rest are projected from `nextDate` with the frequency and `anchorDay` (the day of the
  month monthly-based frequencies keep: a recurrence on the 31st falls on the last day of shorter months and
  on the 31st again after). A paused recurrence has no projected dates, only past ones. `updateRecurring`
  (amount in the recurrence's currency, positive only, else ArgumentError; frequency; status) counts only for
  the dates to come, a new frequency starts from `nextDate`, resuming makes `nextDate` after today.
  `deleteRecurring` keeps the past transactions, unlinked (`recurringId` null). Both notify. Weekly and
  biweekly steps are calendar days (`addDays`), not 24-hour periods: safe across a daylight saving change.
  `MockRepository(recurring: ...)` replaces the generated recurrences (tests of edge cases only).
- Finance Overview (all in `MockRepository`, models in `models/finance_overview.dart`):
  - `financeDigest()` → at most 3 `DigestMessage`s (data only, the screen writes the text), by priority:
    `digestExceededBudgets()` (error; one per budget over its limit in its current period, biggest
    overshoot first), `digestBudgetsAtRisk()` (warning; 80% to the limit, more than 3 days left),
    `digestSpendingVsAverage()` (spending so far vs the average of the same days of the last 3 months;
    10% or more under: success, over: warning; null on days 1-3 and when there is nothing to compare),
    `digestLargeRecurrences({threshold = 100, days = 7})` (info; expenses only, one message), and
    `digestCategoryGrowth({minimum = 30})` (warning; > +50% on the same days of last month, biggest
    increase; not on days 1-3). With no message: one `allGood`. Each rule is a method of its own.
  - `upcomingRecurrences({limit = 5, until, includeToday = false})`: the planned dates (after today) of the active
    recurrences, soonest first, month after month through `until` (default a year); with `includeToday` also the
    occurrence dated today, happened or not (active ones only). `upcomingRecurrencesThisMonth` is the same up to the end
    of the month (Overview); the Dashboard "Upcoming recurring" widget uses `includeToday: true`.
  - `accountsWithChange()` → `AccountChange` (balance today and today minus the balance before the 1st, in
    the account's currency; `accountBalanceAt(id, before)` is the shared calculation).
  - `upcomingRecurrencesThisMonth({limit = 5})`: the planned dates after today, same as the Recurring tab.
  - `cashFlow()` → `CashFlow`: cumulative income, expenses (positive) and balance per elapsed day of the
    month, main currency, transfers excluded, summed in cents (agrees with `balanceTrend`).
  - `monthBudgets()` = `budgetsByRelevance()`: every budget in its current period, exceeded first, then at risk (≥ 80%), then
    the rest, each by usage descending, ties shortest period first (same statuses as the Budget tab).
    `budgetsByRelevance({period, limit})` also feeds the Dashboard "Budget status" widget.
  - `MockRepository(accounts:, transactions:, budgets:, recurring:)` replace the generated data (tests only).
- Net worth (`models/net_worth.dart`): `netWorth` = `totalBalance` (every account, broker accounts included) + `portfolioValue`
  (positions at market value, liquidity excluded: no double count). `netWorthAt(day)` = account balances at the end of the
  day + `_portfolioAt` at the last trading day (today or later: `netWorth`). `netWorthHistoryStart` = earliest transaction or
  purchase (in the demo about 4 years, from the first purchase); before the first transaction the accounts stand at their
  starting balance. `netWorthPeriodStart/Available(NetWorthPeriod)` (3M, 6M, YTD, 1Y, 3Y, 5Y, All; YTD starts at the close of 31 December, daily points up to about 6 months, then weekly) and `netWorthSeries(period)` →
  `NetWorthSeries` (current, points sampled daily up to 6M, weekly for 1Y/3Y, every two weeks for 5Y; the last point is today and equals
  `current`; with fewer than two points `start`/`change` are null; `changePercent` null when the start is not above 0).
  A period starting before the history starts at it. Feeds the Dashboard "Net worth" widget.
- `investmentsSnapshot(ValuePeriod)` → `InvestmentsSnapshot` (`models/investments_snapshot.dart`): `totalValue` (= `portfolioSummary`),
  `daily` (last close against the previous one), `yearToDate` (against the last close of the previous year, or the first purchase),
  `periodChange` (first to last point of `series`; = daily for 1D, = YTD for YTD) and `series` (= `marketValueSeries`). An
  `InvestmentChange` is performance net of contributions: delta of (value - invested), percent over start value + invested in
  between, null when that base is not above 0. Null changes with fewer than two days of history. Feeds the Dashboard "Investments" widget.
- `allocationBreakdown(AllocationMode, {maxRows})` → `AllocationRow`s (slice + whole percent, the percents add up to 100 by largest
  remainder): `assetAllocation` with six single assets, the slices after `maxRows` summed in one "other" row (a lone leftover stays as it is).
  Feeds the Dashboard "Allocation" widget; `assetAllocation(mode, {topAssets = 5})` is unchanged for the Overview.
- Investments Overview (`models/portfolio.dart`):
  - `portfolioSummary()` → `PortfolioSummary`: market value of the positions, liquidity (broker account
    balance), cost (quantity x PMC), `totalValue` = positions + liquidity, `gain` = positions - cost
    (liquidity excluded), `gainPercent`.
  - `marketValueSeries(ValuePeriod)` → `ValueSeries` of `ValuePoint(time, value, invested)`: market value
    of the positions (liquidity excluded) and invested capital (buys at cost, sells at the running average
    cost, fees left out). 1D and 5D use the intraday prices (35 points a day; 1D is the last trading day,
    so on a weekend Friday), the others one point per trading day (1M, 6M, YTD, 1Y, 5Y). It starts at the
    first purchase when the period is longer than the history. The last point is the current market value
    of the positions, so card = last point + liquidity. Manual assets count at their purchase value until
    their valuation date, then at the value entered (a manual price update is still to be designed).
  - `assetAllocation(AllocationMode)`: by asset class (ETF, stocks, bonds, other = manual assets) or by
    single asset (top 5 + "other"); the liquidity is its own last slice; shares are of positions + liquidity.
  - Digest, one method per rule: `digestConcentration` (a single asset > 40% of positions + liquidity),
    `digestMonthDrop` (positions lost > 5% in the last month, net of what was invested in it),
    `digestMonthGrowth` (they gained), `digestExpectedDividend` (within 7 days, grouped); `investmentDigest()`
    gives at most 3 by priority, or one `allGood`.
  - `refreshPrices()`: every price moves at most 0.4% (bonds 0.05%), deterministic per refresh count; the
    last daily and intraday points follow; `pricesUpdatedAt` is set to `currentTime`. At first it is 4
    minutes before `now`. `currentTime`: the real clock, or `now` when the repository was given one.
  - Positions (`models/portfolio.dart`): `searchPositions({query, kinds})` → `Position`s, heaviest first
    (name, ticker, ISIN search; kinds etf/stock/bond/manual; the weight is over positions + liquidity and does
    not depend on the filter); `Position.monthPrices` (last month, main currency, empty for manual assets) and
    `gain`/`gainPercent` against quantity x PMC. `portfolioBreakdown(BreakdownBy)`: region or sector from the
    catalog, "other" (name null) last, shares over the positions only. `positionDetail(holdingId)` →
    `PositionDetail` (price in the asset and main currency, change against the previous close, quantity,
    average cost, asset info, `OperationDay`s with buys, sells and paid dividends, fees and expected dividends
    left out). `priceSeries(holdingId, ValuePeriod)`: the price in the main currency with the average cost as
    "invested" (a flat line), same points as the portfolio chart; empty for manual assets.
  - Movements (`models/investment_movement.dart`, `models/movement_edit.dart`): `MovementType` is buy, sell,
    dividend, cost. A buy or sell has `quantity`, `price`, `fee` (commission, in the asset currency; no separate
    "fee" movements any more), `amount` = units x price without the commission; a dividend or cost has the net
    `amount` and a `description`; a cost may have no `holdingId`. `accountId` is the broker account whose liquidity
    it moves (`cashEffect`: buy -(amount+fee), sell amount-fee, dividend +amount, cost -amount, in the movement
    currency, converted to the account's; only up to today). The opening balance of each account (`_opening`) is
    set so that today's liquidity is what it was before the movements moved it.
  - `replayHolding(movements)`: plays buys and sells in date order (same day: insertion order); the cost of the
    units held includes the buy commissions, a sell takes units out at the running average cost (the average
    cost does not change), more sold than held at some date is `failedOn`. The generator and the repository use
    it, so the average cost (PMC) always agrees with the movements. The invested series follows the same rules.
  - `movementList(MovementFilter)` → `MovementList(upNext, days)`: filters search (name, ticker, ISIN,
    description), period (current month, last 3 months, current year = default, last 12 months, all), types,
    asset kinds, one position. "Up next" = dividends after today, soonest first, not cut by the period. Days
    newest first. `movementEntry`, `movementAssets()` (positions with movements, sold out ones included),
    `movementPeriodStart`, `brokerAccounts`.
  - `addMovement(MovementDraft, {dryRun})`, `updateMovement(id, changes:, {dryRun})`, `deleteMovement(id,
    {dryRun})` → `MovementResult` (ok, or a `MovementFailure`: invalid, negativeQuantity with the date,
    notFound). A buy of an asset not held creates the position (catalog id `hld_<asset>`, or a manual one valued at
    what it cost); selling out keeps a closed `Holding` for its movements (`holding(id)` finds it, `holdings`
    does not); a position with no movements is removed. Everything changes only if the whole history is valid,
    then the caches are cleared and listeners notified, so Overview, Positions and the position page follow.
    `liquidityAfter(draft, {replacing})` is the liquidity the form warns about.
  - Tests only: `MockRepository(investments:, clock:)`, `debugSetLastPrice`.
- **New user** (`MockRepository.newUser({now, mainCurrency = 'EUR'})`): the same identity (name, email) as the demo
  user and nothing of his: no account, category, budget, transaction, recurrence, position or movement. The asset
  catalog and the exchange rates stay (they are not the user's). The demo repository is the default; `AppState`
  holds which one is active (`startOnboarding()` makes a new-user one, `loadDemoData()` a fresh demo one, each
  bumps `repositoryGeneration` so the app is built again, with nothing left of the other).
- Categories, subcategories and budgets (`models/category_edit.dart`; same for the demo and the new-user repository, all
  change the data in memory and notify). `addCategory(CategorySave)` / `updateCategory(id, CategorySave)` save a
  category with its subcategories and budgets **all or nothing** (the lists in the save are the ones that remain: an
  existing subcategory or budget left out is deleted; items with an `id` are updated, the others created).
  `deleteCategory`, `addSubcategory`, `updateSubcategory`, `deleteSubcategory`, `addBudget`, `updateBudget` (and the
  older `updateBudgetAmount`, `deleteBudget`) are the single operations. Results are `CategoryResult` (`ok` + the
  category, or a `CategoryFailure`: invalidName, duplicateName, invalidAmount, duplicatePeriod, budgetOnIncome, inUse,
  notFound). Rules: category name unique per type and subcategory name unique inside its category (capitals and the
  spaces around do not count: `categoryNameTaken`, `subcategoryNameTaken`); one budget per period per category
  (`budgetPeriodTaken`); budgets only on expense categories and with an amount above zero, stored in the main
  currency; subcategories read icon and color from the parent. A category with transactions or recurrences
  (`categoryInUse`) cannot be deleted nor change type, nor lose a subcategory used by them (`subcategoryInUse`);
  deleting a category takes its subcategories and budgets. Ids `cat_new_<n>`, `sub_new_<n>`, `bud_new_<n>`.
- `Budget` has `limitAlert` (default false, only stored) and `countForOverall` (default true; in the demo data every
  budget has countForOverall true and limitAlert false). `BudgetOverview.overallTotal` / `overallSpent` / `overallCount` (and `hasOverall`,
  `overallUsage`, `overallState`, `overallRemaining`, `overallOverBy`) are the "Overall budget" of the Budget tab:
  only the budgets with `countForOverall`; `total`, `spent`, `items` and `segments` cover all the budgets of the
  period.
- Suggested categories (`models/suggested_category.dart`, `data/suggested_category_data.dart`): the eight of the
  onboarding with icon and color (from Figma); they are created with no subcategories. `suggestedCategoriesLeft()` (the ones
  whose name and type are not taken) and `addSuggestedCategory(s)`.
- **Opening movement and assets of the onboarding**: `InvestmentMovement.isOpening` is a buy dated today, quantity and
  price = the average cost, `fee` 0 and `accountId` null (so `_movesCash` and the liquidity ignore it). The position, its
  quantity and PMC come from the history as always (`replayHolding` takes the cost of an opening buy as quantity x
  price, not from the amount rounded to cents, so a tiny quantity keeps the PMC typed). `MovementDraft.isOpening` and
  `countsForNetWorth`. Repository: `addOpeningAsset({assetId | manualName, quantity, averageCost, countsForNetWorth})`
  (fails with `MovementFailure.duplicate` for an asset already held, a manual name already taken: `assetHeld`,
  `manualAssetNameTaken`), `updateOpeningAsset`, `deleteOpeningAsset` (refused with `negativeQuantity` when a later
  sell depends on it), `openingAssets`, `openingMovementOf`, `holdingName`, `kindOfHolding`. The price is in the
  currency of the asset, in the main currency for a manual asset (valued at what it cost, and the value follows an
  edit). `Holding.countsForNetWorth` (default true, all true in the demo data) is only stored: no read uses it.
- `brokerAccounts` returns the broker accounts or, when there are none (a new user with ordinary accounts), every account,
  so the movement form always has an account to pick; the liquidity (`liquidity`) still counts only `broker` accounts.
- Accounts (`models/account_edit.dart`): `addAccount(AccountDraft)`, `updateAccount(id, draft)`,
  `deleteAccount(id)` → `AccountResult` (`ok` + the account, or an `AccountFailure`: invalidName, duplicateName
  (ignoring capitals and the spaces around), invalidAmount, invalidCurrency, inUse, notFound). The starting
  balance may be zero or negative; ids `acc_new_<n>`; each change notifies. `accountNameTaken(name, {excluding})`
  is the check the form shows inline; `accountInUse(id)`: transactions, recurrences or movements refer to it,
  and then it cannot be deleted nor change currency. Accounts and categories are copied from the data
  at the start, so changes never reach the demo lists.
- Screens get the repository from `context.repository` (`lib/app/app_scope.dart`); the
  global "hide amounts" switch is `context.hideAmounts`.

- Main account and adding transactions (`models/account.dart`, `models/transaction_edit.dart`):
  - `Account.isMain`; the repository keeps exactly one when there are accounts (`mainAccount`, `setMainAccount(id)`):
    the first account created is main, `AccountDraft.isMain` makes another one main (the previous loses the flag),
    editing cannot turn the flag off on the main account, deleting the main one gives it to the first account left.
    The demo's first account is main. Repositories built with a list of accounts are normalized the same way.
  - `addTransaction(TransactionDraft)` → `TransactionResult` (`ok` + `AddedTransaction`, or a `TransactionFailure`:
    invalidAmount, accountNotFound, sameAccount, invalidCategory, futureDate, invalidEnd, notFound). Expense, income
    or transfer; amount positive in the account's currency; the transaction is inserted in date order; one
    notification, so balances, lists, charts, budgets and digests follow. `Transaction.toAmount`: a transfer
    between currencies carries what arrives in the destination's currency (balances use it); the draft may give it,
    otherwise `convert(amount, from, to)` (mock rates, rounded to cents) fills it.
  - With a `RecurrenceDraft` (frequency, start date, end never / on date / after N times) it also creates the
    `RecurringTransaction` (`rec_new_<n>`, title = description, else category name, else "A → B"; `endDate` is new
    on `RecurringTransaction`, "after N" is turned into the date of the Nth occurrence; the projected dates stop at
    it): the first transaction (linked by `recurringId`) when the start is today or before, then `nextDate` is the
    first date after today; a start in the future creates only the planned recurrence. Ids `tx_new_<n>`.
  - `undoAdded(AddedTransaction)` takes back the transaction and the recurrence; `deleteTransaction(id)`.
  - Suggestions: `categoriesByUsage(type)` (uses in the last 90 days, ties and a new user by creation order),
    `suggestCategory(description, type)` → `CategorySuggestion` (the most frequent category of the past transactions
    of that type with the same description, capitals and extra spaces aside; the most recent on a tie; with the
    subcategory used most there), `pastDescriptions(query, limit = 3)` (expenses and income, most used first).
  - `newUser` and `MockRepository(recurring:, transactions:)` copy their lists, so they are growable.

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
`test/mock/opening_assets_test.dart` covers the opening buy (position, quantity and PMC, no effect on liquidity or balances, movement list and edit, weighted PMC with later buys, duplicates, delete and the refused delete, currencies). `test/mock/new_user_smoke_test.dart` runs every read the screens make on a new user (nothing, accounts only, with categories, budgets and assets, with a movement on an ordinary account) and checks that no number is not finite. `test/features/new_user_walk_test.dart` opens every tab and sub-tab on a new user in light and dark. `test/mock/categories_test.dart` covers the uniqueness of names, one budget per period, income without budgets, the all-or-nothing save, the suggested categories (created with no subcategories, hiding/return) and the overall budget with and without the flag. `test/mock/add_transaction_test.dart` covers the main account, adding each type, transfers with and without a change of currency, recurrences (today, past, future, ends), Undo and the suggestions. `test/mock/new_user_test.dart` covers the empty repository, the rates and the operations on the accounts
(unique name, any balance, currencies, update, delete, in use). `test/mock/movements_test.dart` covers buys (weighted average with commissions, new and manual assets, dollars,
over the liquidity), sells (partial, total, refused), dividends and costs, change and delete with the replay and the
refusals, and the list, search and filters. `test/mock/positions_test.dart` covers the list, search, filters, breakdown, position detail and price series.
`test/mock/investments_overview_test.dart` covers the P&L, the invested series, the series of every period,
the allocation, each digest rule and the refresh. `test/mock/finance_overview_test.dart` covers each digest rule, the account changes, the cash flow and the
budget order. `test/mock/recurring_test.dart` covers the occurrences (monthly, weekly, quarterly, yearly, the 31st, leap
year, daylight saving, paused), edit, delete and history. `test/mock/mock_repository_test.dart` runs on several "now" dates (real today, first of
month, a Monday, new year, end of year) and checks: every referenced id exists, unique ids,
transfers have a destination and no category, every category has subcategories and every
subcategory a parent, one budget per expense category, all budget states present, holding
quantities and PMC match the movements, gains and losses in the portfolio, recurring next
dates in the future, 30-50 transactions per full month, catalog size and price history,
same data for the same `now`. Run it after any change to the mock data.
