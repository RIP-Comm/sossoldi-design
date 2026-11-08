# V2 information architecture

High-level structure only. Detailed content of each screen is defined screen by screen,
from Figma, as work progresses.

## Navigation
- V1: Dashboard / Transactions / Planning / Charts + Add transaction
- V2: **Dashboard / Finance / Investments** + **Add transaction** (primary action)
- Settings live outside the tab bar.
- Time filters are **per page/section**, not global: each section shows different information
  and has its own time control (see Finance below).

## Onboarding
Shown full screen on the empty data of a new user (the demo data stay the default of the prototype; see
Settings below). The import from another app is still a placeholder.
1. Splash — logo, "Welcome to SOSSOLDI", the line of the Mr. RIP community. The logo fades in (ease out) from a
   bigger size to its own, the text follows 200 ms later the same way; after 1.5 s everything fades out and, 100 ms
   later, the welcome fades in.
2. Welcome — title, the open vault, a select to choose the language (English, Italiano; the language of the
   device when the app has it, else English, marked "(default)"). Changing it changes the language of the whole
   app at once. "Start the setup", or "Or" + "Import data from another app" (import pre-creates accounts,
   categories and currencies; not designed yet: a placeholder).
3. **Step 1 of 3 — main currency and accounts.** Select of the main currency (EUR, USD, GBP, CHF, BRL, AED, JPY, CAD;
   EUR is the default and says so). "Your accounts": with none, a card "Create your first account" with a button;
   with some, the list (icon and color, name, balance in the account's currency), "Add account +" and, at the
   bottom, "Next step >" (only with at least one account). Changing the main currency leaves the accounts as they
   are. Tap on an account: the same form, to edit it.
   - Account form (bottom sheet): X, "New account" ("Edit account"), check (on only when the data is valid).
     Name (required, unique ignoring capitals), Amount (the starting balance: zero and negative are fine, comma
     or point; in the main currency: the currency is one for the whole app, so the account has no currency field,
     which is commented out in the code for now), Icon and color. Icon and color: a round
     preview, "Tap to select" opens a bottom sheet with a tab for each group of icons (finance, shopping, travel,
     health, people, nature, games, media, office, communication, objects: the groups of the Phosphor library) and
     the grid of the selected group, about 990 icons in all (to be reused by the categories); two sliders
     give the color: hue, and saturation (its track follows the hue). Colors are HCT with a fixed tone, so they all
     look as light as the others; the ends stay in the family of the palette of the categories. In edit mode a red
     "Delete account" (with a confirmation) closes the form (not in Figma, added).
4. **Step 2 of 3 — categories, subcategories and budgets.** Heading "Step 2 of 3" with a "< Back" button on its own row above the title, always at the left (goes
   to Step 1, added) and a subtitle. "Your categories":
   with none, a card "Create your first category" with "Create category"; with some, two lists "Expenses" and "Income" (as in "Suggested", a group is shown only when it has
   categories), each in order of creation (icon and color, name, second line "Budget: 130€, Monthly" when it has budgets, several separated by " · "),
   "Add category +" below the lists and, at the bottom, "Next step >" (only with at least one category). Tap on a row: the form,
   to edit it. The caret (when the category has subcategories, or budgets) opens and closes the list inline: the
   subcategories (the budgets when there are no subcategories); the open state is not drawn, it takes the style of the
   subcategories in the form.
   - "Suggested": "Expenses" (Housing, Groceries, Stuff, Health, Travel, Transportation) and "Income" (Work, Extra), each
     a row with icon, name and "+" (group labels in Body Large). The "+" creates the category at once **with no
     subcategories** (the user adds them from the form) and it moves to "Your categories". A suggestion is hidden while a category of the same name and type exists (even one
     made by hand) and comes back when it is deleted; with nothing left the section goes away. Constant in code
     (`mock/data/suggested_category_data.dart`).
   - Category form (bottom sheet): X, "New category" ("Edit category"), check (on only with a valid name). Type
     (Expense / Income, default Expense), Name (required, unique per type ignoring capitals), Icon and color (same
     component as the account form), Budget (expense only: one row per budget "Monthly · 130€" and "Add budget +"),
     Subcategories (the rows with the icon and color of the parent and "Add subcategory +"; with none, a card with
     an explanatory line and "Add subcategory"). Budgets and subcategories added in the form stay in a draft and are
     saved only with the check; X discards it. Changing the type from Expense to Income with budgets asks for
     confirmation and then discards them. In edit mode a red "Delete category" (with a confirmation) closes the
     form, and takes its subcategories and budgets with it (not in Figma, same pattern as Delete budget). A category
     with transactions or recurrences (demo data only) cannot be deleted nor change type.
   - Differences from Figma: the budget row shows period and amount, not "50% 120€ left" (nothing is spent in the
     onboarding).
   - Subcategory form (bottom sheet): X, "New subcategory" ("Edit subcategory"), Name, check (on with a valid name,
     unique inside the category). Tap on a subcategory of the list: the same form with a red "Delete subcategory".
   - Budget form (bottom sheet, a component of its own, `features/budgets/budget_form_sheet.dart`, to be used by
     Settings > Budgets too): "Select type" (Weekly, Monthly, Quarterly, Semiannual, Yearly; default Monthly or the
     first free one; the periods another budget of the category uses are disabled), "Set amount" (above zero, in the
     main currency), "Limit reach alert" (off by default, only stored), "Count for overall budget" (**on by default,
     differs from Figma**). "New budget" ("Edit budget") with a red "Delete budget" in edit mode.
   Back goes to Step 1 keeping the data; "Next step" opens a placeholder of Step 3.
5. **Step 3 of 3 — the assets the user already holds** (can be skipped). Heading "Step 3 of 3" with the "< Back" button on its own row above it
   (to Step 2, keeping the data) and a subtitle. "Your assets": with none, a card "No asset yet" with "Add asset" and,
   at the bottom, the link "Skip this step >"; with some, a list (asset row of the design system: avatar with the
   initial, type tag, name, "ticker – ISIN", **value = quantity × PMC converted to the main currency, not the market
   value**, "Quantity", "PMC" in the currency of the asset), "Add asset +" and, at the bottom, the primary button
   "Start tracking >". Tap on a row: the form, to edit it.
   - Asset form (bottom sheet): X, "New asset" ("Edit asset"), check (on only with valid data). The asset, chosen as in the form of
     a movement (**differs from Figma, which has a Type select**): "Catalog" (default; a search with the placeholder
     "Search by name, ticker or ISIN"; the pick shows name, ticker – ISIN and "Change") or "Manual asset" (name and kind of
     asset). None of the fields of a movement (date, commission, account) is here. Amount
     (quantity above zero, up to 8 decimals), Average purchase price (above zero, in the currency of the asset, the main
     currency for a manual asset), "Counts for Net Worth" (**on by default, differs from Figma**; only stored: no screen
     or total uses it yet). An asset already added (a manual one with the same name) is an inline error. In edit mode
     the type and the asset cannot change and a red "Delete asset" (with a confirmation; not in Figma) deletes the
     opening buy and the position goes with it.
   - An asset of the onboarding is an **opening buy**: a Buy dated today with quantity and price = PMC, no commission and
     no broker account, so it never touches the liquidity. It shows in Investments > Movements like any buy and is edited
     from its page (which has no account row, and no commission field in edit mode).
   - "Start tracking" and "Skip this step" end the onboarding: the app opens on **Home with the data of the new user**
     (the onboarding is gone from the stack: the system back does not return to it). Settings > "Load demo data" is
     the way back to the full data.
The system back gesture goes to the previous screen and keeps what was typed; Steps 2 and 3 also have a back arrow. From
the first screen of the flow it leaves the onboarding and loads the demo data.

### New user with little data
Every screen must hold with accounts that have only a starting balance, no transactions, a few categories with budgets
at 0%, and one or no assets. Where nothing is drawn in Figma, a neutral text with the existing empty-state components is
used (listed in the handoff of the Step 3 work): Dashboard "Latest transactions" ("No transactions yet"), Finance
Overview cash flow ("No income or expenses this month yet"). With no broker account the movement form offers any account.

## Dashboard
Quick overview of the user's finances. Customizable widget grid: 2 columns, widget sizes
S (1×1), M (2×1), L (2×2). Core widgets: Total balance, Income & expenses, Budget status,
Latest transactions. Optional widgets: Upcoming recurring, Investments (snapshot), Allocation, Net worth,
Insight of the moment (Savings goals will not be built; Income & expenses is covered by Monthly balance). Net worth = accounts + investments.
Available now (S/M/L; Insight of the moment S only): Monthly balance, Latest transactions, **Budget status** (core) and **Upcoming recurring** (optional, not in the initial
layout, in the add-widget list). Upcoming recurring: the next occurrences of the active recurring transactions from
today on (today included, paused ones left out, all types), soonest first; S 1, M 2, L as many as fit (5-6); the row is
the Latest transactions one with the date of the occurrence as a chip (same format as the Finance Overview list); no
tap and no title, like Latest transactions; empty state "No recurring transactions".

**Insight of the moment** (optional, add-widget list, S only, first widget of the initial layout; no Figma node: the card style of the other
widgets): one insight, the most relevant right now, chosen by `InsightEngine` (`lib/insights/`, pure Dart, injectable `now`, every
threshold in `insight_constants.dart`; reusable, not linked elsewhere). The first level with a candidate wins, inside a level the most
serious (ties keep a stable order). Days are counted back from today, inclusive.
1. Budget exceeded (>100%) within the last 7 days (the day comes from the transactions): highest % first. Tone negative. Tap → budget page.
2. Recurring expense due today or tomorrow (active, expenses only; same occurrences as the Upcoming widget, so one already booked today counts):
   nearest, then largest amount. Attention. Tap → recurring page.
3. Budget at risk (≥ 80%, not exceeded): highest %; shows the days left in the period. Attention. Tap → budget page.
4. Unusual expense: in the last 3 days, ≥ 3× the average expense of its category over the 90 days before that window and ≥ 50 € (main
   currency); needs ≥ 5 such expenses; transactions of a recurrence never count; highest ratio first. Attention. Tap → Finance >
   Transactions > List filtered on the category and the last 3 days.
5. Portfolio down 2% or more today (the Investments snapshot's daily change) first, then budgets exceeded more than 7 days ago (highest %).
   Negative. Tap → Investments > Overview / budget page.
6. Reminder (neutral, tap → Add sheet): no transaction ever ("Add your first transaction"); else the last one more than 2 days old; else, from
   18:00 local, none dated today. All transaction types count.
7. Good news (positive): portfolio up 2% or more today (tap → Investments > Overview); net worth above every end-of-day value of the previous
   30 days (needs 30 days of history; no tap).
8. Nothing: "All good for today" (neutral, check icon, no tap).
Size S only: icon in the tone color, title (2 lines), and the detail anchored to the bottom, built from the components the other widgets use for the
same thing: budgets (exceeded or at risk) the Budget status figures (error chip with the %, or bold % in the tone color, then "34 € over" /
"60 € left") and the budget bar; recurring the payment name with its amount (negative, red); unusual expense the amount (one step above the
title, red) with "4× the usual" under it in neutral text; portfolio drop or gain the portfolio value in title large over the change indicator (percentage tag + amount, as in
Investments); net worth at a high ("Highest net worth in a month") the net worth amount in title large with the change indicator over the 30 days (as in Net
worth); reminders a neutral line; "All good" has its line right under the title (up to 2 lines). What does not fit is scaled down. Tap on the
card, disabled in edit mode (no M size, no button). Budget numbers are `budgetStatus` (same % and state as the Budget tab). Amounts follow Hidden Mode, percentages stay.
The insight is worked out again only when the repository changes, when the app returns to the foreground and at the next boundary (18:00,
midnight), never on a rebuild. The add-widget preview shows a fixed example (portfolio down).

**Budget status**: the budgets valid today (each on its own current period, same numbers as the Budget tab) by
relevance, the same rule as the Finance Overview: exceeded first (highest % first), then at risk (≥ 80%) by % descending,
then the rest by % descending; on a tie the shortest period first. S: the first budget, no header; M: header + 3 rows
(compact: period chip beside the name, thin bar); L: header + up to 6. Row: category name, period chip, "50% · 120€ left"
or "112% · 34€ over", bar. Header (M, L): "Budget" and, at the right, a chip with a menu to choose the budget type (All, Weekly,
Monthly, Quarterly, Semiannual, Yearly; default All); the filter applies to every size, is stored with the placement in
the layout (survives reordering and resizing, memory only) and the chip is disabled in edit mode. Tap → the budget page.
Empty: "No budgets yet" / "No {period} budgets". Initial layout (a use case with every widget, in different sizes, from top): Insight of the moment (S) and Monthly
balance (S), Budget status (M), Net worth (M), Upcoming recurring (S) and Allocation (S), Latest transactions (L), Investments (L).

**Net worth** (optional, in the add-widget list): accounts + investments, main currency.
The charts of Monthly balance and Net worth (M and L, not S) show, on tap or drag, an indicator and the tooltip of the other charts (the day; Monthly
balance: this month and last month at that day; Net worth: the value that day). The
liquidity of the broker accounts is in the account balances, so only the positions at market value are added to them
(no double count; `MockRepository.netWorth`). S: title with the label "YTD" (no chip), value, the year-to-date change under it and the trend chart; M and L:
the headline with the period chip at the top right, then the value (3M, 6M, YTD, 1Y, 3Y, 5Y, All; default YTD, against the close of 31 December; a menu as in Budget status, the periods
the history does not cover are shown but disabled) with the change at its right (money and percent; the percentage is hidden when
the starting value is not above 0; nothing without history) and the chart (taller in L, one series, no comparison, no
legend). The period is stored with the placement, disabled in edit mode. Transfers never change it. Empty: value 0 and "Not enough
history yet" in place of the chart.

**Change rendering** (Net worth M/L and Investments, `SossoldiChangeIndicator`): a tag with an up/down arrow and the percentage
(green/red, neutral at exactly 0) and, beside it, the amount in plain text with its sign; when the percentage cannot be worked out
(base zero) the tag shows the amount and the plain text goes away. Hidden Mode masks both figures (arrow and color stay).

**Investments** (optional, add-widget list; no Figma node, follows Net worth): value = positions + liquidity
(as the Investments Overview). Changes are **market performance**, net of buys and sells: change of (market value - invested)
between two moments, percentage over the starting value plus what was invested meanwhile (the Overview's own P&L is instead
against the average cost). **Year to date is the default everywhere.** S: title with the label "YTD" (no chip), value, the
year-to-date change under it and the trend chart edge to edge (no axes, legend or tooltip). M: the period chip at the top right (same
periods as the Overview chart, default YTD, in memory with the placement, disabled in edit mode), the change of the period at the
right of the value and the trend chart of the period edge to edge (tooltip, no axes or legend). L: the same chip and change, and the
Overview's market value chart (axes, tooltip) with its legend under it. Tap on the figures → Investments >
Overview (not on the chart). No positions: "No investments yet". With fewer than two days of history the changes are not shown.

**Allocation** (optional, add-widget list; no Figma node): the Investments Overview's allocation (same data, colors,
donut; the liquidity is its own slice, as there), by asset class or by single asset. Rows after the first N are summed in "Other" (neutral
color; a lone leftover slice keeps its name); whole percentages that add up to 100 (under 1% is written "<1%"). Every legend row: dot, name,
percentage and amount side by side at the right (amounts hidden with Hidden Mode; percentages stay; S without decimals). S: the title with a
small donut at its right (sized so the title is always shown whole), 4 rows + Other in the small type. M: donut at the left, legend at the right (5
rows + Other), one type step up. L: selector "Asset class" / "Single asset" centered under the title, the donut takes the room left and pushes the legend down, legend one step up with more space between rows (4 px in M). No percentage in
the middle of the donut. Single asset: the first six assets + Other. The view is stored with the placement (memory
only; S and M follow it, default Asset class), independent of the Investments page; the selector is disabled in edit mode. Tap → Investments >
Overview. No investments: "No investments yet" with an empty donut.

**Padding of every Dashboard widget, every size**: 12 px on all four sides (top, bottom, left, right). Only charts without axes
(trend charts) go edge to edge. The transaction rows of Latest transactions and Upcoming recurring count their own row padding in the 12
(so M of both transaction widgets fits 2 rows).

**Headline of the M and L widgets** (Budget status, Latest transactions, Upcoming recurring): the title in Label Large bold
at the left and, at the right, a chip with a menu for the type (Budget status: All, Weekly…; the two transaction widgets: "All" / "Tutte" (feminine in Italian, it refers to the transactions),
Expenses, Income, Transfers). The choice is stored with the placement (as for Budget status), applies to every size
(S has no headline), and the chip is disabled in edit mode. Rows of the transaction widgets: M and L the same, as in the list (52 px, the space left shared between them, 12 px under the headline's own padding): M fits 2 rows in both.

## Finance
Where the user goes to understand in detail where their money goes. Four sections, each
answering a question. No global time filter: each section has its own.

General rules for Finance:
- Transfers are excluded from income and expense totals, charts and cash flow.
- All totals are shown in the main currency (converted); per-account values in the account's currency.

### Overview — "What's the overall situation?"
- Fixed period: the **current month**. Data up to today (on the 2nd, only 2 days of data),
  but upcoming recurrences shown until the end of the month.
- Digest at the top: a swipeable row of 1 to 3 messages by priority (exceeded budgets, budgets at risk,
  spending vs the average of the last 3 months on the same days, large recurrences in the next 7 days,
  a category that grew more than 50%); a neutral message when none applies. Not tappable.
- Accounts summary: balance and change since the 1st of the month (in the account currency),
  with "Manage" → the Accounts page (same as Settings > Accounts; back returns to the Overview). A tap on a row opens the page of that account (a normal page, like the other details of Finance; back returns to the Overview); the rows have no chevron.
- Upcoming recurrences (amount and date) until the end of the month.
- Cash flow chart for the current month (income, expenses, balance line).
- Budget status: horizontal scrolling list of the budgets valid in the current month
  (including e.g. yearly budgets that cover it), with "Manage" → Settings > Budgets.

### Transactions — "Where did my money go?"
- Two views: **List** and **Charts**.
- List: search bar; filters for date, type, category, amount, account. Default date filter:
  current month. 20 transactions per page, with pagination.
- Charts: time range selector + filters (account, category). Expenses / Income tabs, each
  with total + change vs the previous period of the same length, pie chart breakdown, and a
  cumulative breakdown over time.
- Granularity of the over-time chart is separate from the time range: weekly by default,
  monthly when the range is 6 months or longer.

### Budget — "Am I staying within my limits?"
- Budget period selector (weekly, monthly, quarterly, semiannual, yearly); default: **monthly**.
- Shows the overall budget for the selected period (total bar) + breakdown by category.
- A category can have **multiple budgets** (e.g. one weekly and one monthly), **never two on the same period**.
  Only expense categories have budgets; subcategories have none.
- Each budget has a flag "Count for overall budget" (default on): the **Overall budget** card sums only the budgets of
  the period that have it on, and is hidden when none has. The list of the period and the segmented bar do not change.
  "Limit reach alert" is only stored (no notifications in the prototype).
- No "all periods" view: a period is always selected.
- Budget detail (tap on a budget): only that budget (progress) + the transactions counted in
  its current period. No other budgets of the category, no "add budget" here (budgets are
  added from Settings > Budgets). "Edit" enables edit mode: change the amount, or delete the
  budget with a red button at the bottom center (only in edit mode).

### Recurring — "What fixed commitments do I have?"
- Month selector (month + year) in place of the title; default: current month.
- Calendar with dots on days with recurrences: red = expense, green = income, blue = transfer;
  a day can have multiple dots. No day is selected by default: the list shows the whole month by
  date. Tapping a day selects it and lists only its recurrences (empty state for empty days);
  tapping it again goes back to the month. Paused recurrences have no future dates in the calendar
  (the ones that already happened stay).
- Recurrence detail: type, frequency, amount, active/paused, past transactions. Read-only
  until "Edit". Edits apply to future occurrences only.

## Investments
Where the user goes to understand the state and performance of their portfolio.
Three sections + a detail page. Header: title + caption "Updated X ago" (last price update);
pull-to-refresh on the whole page updates prices. No benchmark comparison.

General rules for Investments:
- Portfolio value = market value of all positions + available liquidity (cash in broker accounts).
- P&L shown next to the portfolio value and on each position = total unrealized P&L vs
  average cost (PMC), not the daily change.

### Overview
- Digest carousel (same component as Finance Overview), with investment-specific messages, at most 3 by
  priority: a single asset above 40% of the portfolio (info), portfolio down more than 5% in the last
  month (warning), portfolio up in the last month (success; both net of what was invested in the month),
  dividend expected in the next 7 days (info); a neutral message when none applies.
- Portfolio value card (value, P&L € and %, available liquidity).
- Market value chart with periods 1D, 5D, 1M, 6M, YTD, 1Y, 5Y: market value line + "invested"
  line (net contributions at cost), legend in the same style as Finance charts, tooltip on tap.
- Asset allocation donut: by asset class (ETF, stocks, bonds, other) or by single asset (top 5 + "other");
  liquidity is its own slice.
- Empty portfolio: the card with the liquidity and an empty state in place of chart and allocation.
- Pull-to-refresh and "Updated X ago" work on every tab.

### Positions
- Portfolio value card (repeated on purpose).
- "Positions" section with its own search + filters (position type / asset type): they apply
  only to the positions list, not to the rest of the page.
- Position row: type tag, name, ticker – ISIN, sparkline, market value, total P&L %.
- Portfolio breakdown: by region / by sector.
- Tap on a position → position detail page: Back + name (no Edit: it comes from the movements), type tag,
  "ticker – ISIN – exchange", price and today's change, price chart (1D to 5Y, tooltip, dashed line at the
  average cost), "Your position" (value, quantity, average cost, invested, P&L, weight), "Asset info",
  "Operations" (buys, sells, paid dividends by day, newest first), Buy / Sell / Add dividend (placeholders for now).
  A manual asset has no chart and no asset info.
- Positions list: the heaviest first (weight over positions + liquidity). Breakdown: "Other" (no region or
  sector: bonds, manual assets) always last; liquidity excluded; not affected by search or filters.

### Movements
- Search (asset name, ticker, ISIN, description) + filters: period (default current year; current month,
  last 3 months, current year, last 12 months, all), type of movement (buy, sell, dividend, cost), type of
  asset, one asset.
- "Up next": expected dividends (future date), apart at the top, hidden when there are none; it follows the
  search and the filters but not the period.
- Below, one list of the movements already happened, grouped by day, the newest first (day header without
  total). Row: chip with icon and type (Buy, Sell, Dividend, Cost), asset name, "ticker – ISIN" (a cost
  without an asset: its description), amount; buy and sell have units and unit price ("Price") under the
  amount, dividend and cost the description. Colors: buy and sell neutral (green or red would read as gain or
  loss), dividend green, cost red.
- No floating "Add movement" button: the blue "+" of the bar, when in Investments (any tab), opens the Add sheet in
  movement mode with a buy selected. In the other sections it opens a new transaction (the action of the "+" is
  set per section in the shell).
- Form (the "Investment movement" mode of the Add sheet, see Add transaction; the same fields edit a movement in its
  page): type Buy / Sell / Dividend / Cost. Buy: asset (catalog search or
  a manual asset with name and kind), broker account, date, quantity, unit price, optional commission. A new
  asset creates the position; one held updates quantity and average cost (weighted, commission included in
  the cost); it lowers the liquidity (over the available liquidity is allowed, with a warning). Sell: only
  assets held, quantity not above what is held on that date, price, commission; the average cost does not
  change; at zero the position closes; it raises the liquidity. Dividend: asset held, date (a future one goes
  in "Up next"), net amount. Cost: optional asset, date, amount, description (required).
- Movement page (tap on a row): Back, type + asset, Edit. Read-only rows (type, asset, broker account, date,
  quantity, price, commission, total; the asset opens its position when it still exists). Edit makes the
  numbers editable (not the type or the asset); Done saves; in edit mode a red "Delete movement" with a
  confirmation. After a change or a delete the quantity and the average cost are worked out again from the
  whole history of the asset and the liquidity follows; it is refused, with a message, if at some date the
  quantity would go below zero (e.g. deleting a buy a later sell depends on). An asset left with no
  movements disappears; one sold out stays only in the movements.
- Buy, Sell and Add dividend of the position page open the same form with the asset chosen.

## Add transaction
Primary action, reachable from everywhere: the blue "+" of the bar opens **one bottom sheet** (the Add sheet,
`features/add_transaction/add_sheet.dart`) with two modes, **Transaction** and **Investment movement**. Not in Figma:
the movement form was the visual reference.
- Header: X at the left (same round X as the onboarding forms), centered title with a caret ("New transaction ▾" /
  "New movement ▾"). Tap on the title: a small menu with "Transaction" and "Investment movement"; it changes mode
  without closing the sheet (each mode keeps its own fields while the sheet is open).
- No footer buttons: the round check at the top right (as in the onboarding forms) saves and closes, and stays grey
  until every required field is filled. After saving: snackbar "Transaction added" / "Movement added" with "Undo"
  (above the bar of the app, with a deeper shadow than the bar). Undo takes back what was just done (the
  transaction, the recurrence and its first transaction, or the movement). There is no "Add and create another".
- The sheet opens with an optional `AddSheetDraft` that fills fields in advance (hook for Siri / Shortcuts, not
  integrated yet).
- Entry points (the action of the "+" is set per section in the shell and read at the tap): Home and every Finance
  tab → Transaction, Expense; Finance > Recurring → Transaction with the Recurring switch already on (the link "Add
  recurrent transaction +" does the same); every Investments tab → Movement, Buy; position page → movement with the
  asset chosen (Buy, Sell, Add dividend).
- **Transaction mode.** Tabs Expense / Income / Transfer, the selected one takes the color of the type (red, green,
  blue). Big amount at the top with the system numeric keyboard and focus on open; for an expense the "−" is a fixed
  prefix. The amount is saved positive, the sign comes from the type; the currency is the one of the account.
  - Expense and Income: Description first (optional, up to 3 past descriptions to complete it, a tap fills it and the
    category proposed); then Category (one row of up to 5 chips that scrolls sideways, the icon of each chip keeps the
    color of its category, selected or not; the most used of the type in the last 90 days, for a new user in
    order of creation, plus "More…" with the whole list and the subcategories; a description that matches a past one
    proposes its category, put first and preselected, without a match nothing is preselected; the category is
    required, a row needs it to have a title), then the chips of its subcategories (optional); Account (select, the
    main account by default); Date (chips Today, Yesterday, Custom → calendar; no future date); switch Recurring.
  - Recurring: Frequency (all the ones of the model), Start date (default the date chosen, may be in the future), End
    (Never / On date / After N times). Saving creates the recurrence and, when it starts today or before, its first
    transaction; when it starts later, only the planned recurrence.
  - Transfer: From (main account by default) and To (first other account) with a button that swaps them; they cannot
    be the same. With different currencies "Amount received" appears, filled with the mock rate and editable (it is
    saved with the transfer: each account moves in its own currency). No category. Date, Description and Recurring as
    above. With a single account: a message, a transfer is not possible.
  - No reference to budgets in the form. Without categories of the type, a message says so.
- **Movement mode:** the movement form of Investments, in the same shell (dates with the same chips as the
  transaction). Details in Investments > Movements.
- Not built: edit and delete of an existing transaction, transaction detail.
- Main account: every user with accounts has exactly one (the first account created; setting another takes the flag
  from the previous one; deleting the main one makes the first left main). The account form has the switch "Main
  account" (on and disabled on the main one, "To change it, set another account as main") and the list of accounts
  of onboarding Step 1 shows the tag "Main".

## Settings
Two levels. The entry point (the gear of the Dashboard) opens the hub (`features/settings/settings_screen.dart`): two rows with
title and chevron, **App settings** and **Prototype settings**. Back from the hub returns to the screen it was opened from.
- **App settings** (`app_settings_screen.dart`), three blocks separated by space, no group titles:
  1. Dark mode (switch), Language, Main currency (selects) and Authentication.
  2. Accounts, Categories, Budgets, Import / Export.
  3. Notifications, Feedback, Info.
  Every row that opens a page has a chevron. Built: theme, language, currency. The other destinations are placeholders.
- **Prototype settings** (`prototype_settings_screen.dart`): "Restart onboarding" and "Load demo data" (actions, no chevron;
  both close the whole Settings stack and rebuild the app on the other data) and "Widget showcase" (opens a page; every Dashboard
  widget in every size and case, one cluster per widget, on demo data and on the empty data of a new user; Insight in its kinds;
  `widget_showcase_screen.dart`).
- **Every management page is a screen of its own**: Authentication, Accounts, Categories, Budgets, Import / Export, Notifications,
  Feedback and Info are each a class in `features/settings/` with a static `route()`, so any screen can open them with a push
  (back returns to where it started, e.g. the "Manage" of Finance) and the real page replaces the placeholder without touching the hub.
- Not added (open point): Investments settings, bank/broker connections.

### Accounts (Settings > Accounts)
Two screens of their own in `features/accounts/`, opened with `AccountsScreen.route()` / `AccountDetailScreen.route(id)` (Settings, and the
"Manage" of the Finance Overview). No Figma node: built from the Account row, the Net worth widget and the Finance list.
- **List** (`accounts_screen.dart`): one `SossoldiAccountItem` per account (icon and color, name, balance in the account's own currency, chevron,
  no change), the main account with the "Main" tag (with a stroke, so it reads as a tag) next to its name (asked here, a deliberate exception to "no tags"). Order from
  `accountsByBalance()`: balance converted to the main currency, highest first (negatives last), same balance by name. "Add account +" under
  the list opens the account form (new). With no account: empty state "No accounts yet" and the same link. Tap on a row: the page of the account.
- **Page of an account** (`account_detail_screen.dart`, opened with `AccountDetailScreen.route(id)` from the list and from the Finance Overview): bar with Back, the account name and "Edit" (the existing account form in edit mode, with
  Delete and its confirmation; an account in use cannot be deleted). After a delete the page closes and the list is shown; after an edit the page
  updates; an account deleted from elsewhere while the page is open closes it quietly.
  - Balance card (`account_balance_card.dart`, same look as Net worth M/L): at the top left the current balance in the account's currency with the
    change of the period next to it (`SossoldiChangeIndicator`, percentage hidden when the start is not above 0, nothing without history); at the top
    right the period chip (3M, 6M, YTD, 1Y, 3Y, 5Y, All; the periods the account's history does not reach are shown but disabled). It opens on YTD when the history covers it, otherwise on the closest period it does cover (6M, then 3M) if that takes in all but about a month of the history, otherwise on All: never on a period that cannot be picked (`accountDefaultPeriod`);
    under it the trend chart with the tooltip (day and balance of that day). Without history "Not enough history yet". The period lives in
    memory in the page (`AccountDetailController`).
  - Transactions of the account (`account_transactions_section.dart`): the Finance list (search, filters for date, type, category and amount, rows by day,
    20 per page, pagination), with state of its own; the account is fixed (no filter, no chip), **no date filter by default**. A transfer between
    currencies shows what moved that account (the amount going out, `toAmount` in the destination's currency coming in).
  - Hidden Mode masks the balances (and the chart); percentages stay.

## Open points (don't decide without asking)
- Asset setup in onboarding: which fields beyond quantity, value and average cost?
- Status of bank API and broker connections: to be verified
