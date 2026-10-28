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
Latest transactions. Optional widgets: Upcoming recurring, Investments snapshot, Net worth,
Savings goals, Insight of the moment. Net worth = accounts + investments.

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
  with "Manage" → Settings > Accounts.
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
- No floating "Add movement" button: the blue "+" of the bar, when in Investments (any tab), opens the form
  with a buy selected. In the other sections it still opens the Add transaction placeholder (the action of
  the "+" is set per section in the shell).
- Form (bottom sheet; also used to edit): type Buy / Sell / Dividend / Cost. Buy: asset (catalog search or
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
Primary action, reachable from everywhere. Shows the remaining budget of the selected
category, supports automatic category assignment and recurring income/expenses/transfers.

## Settings
General (theme, language, currency, authentication), Accounts, Categories & budgets,
Investments, Import/Export, Notifications, Feedback, App info, bank/broker connections.
Built so far: theme, language, currency and, labelled "Prototype", "Restart onboarding" (full screen, on an
empty repository) and "Load demo data" (back to the app on the full demo data).

## Open points (don't decide without asking)
- Insights: what is shown when no insight is available? Are they tappable? (Current assumption: no)
- Asset setup in onboarding: which fields beyond quantity, value and average cost?
- Status of bank API and broker connections: to be verified
- Global "+": a selector of what to add (expense, income, transfer, investment movement) in place of the per-section action; to be decided when designing Add transaction.
