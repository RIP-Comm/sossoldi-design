# V2 information architecture

High-level structure only. Detailed content of each screen is defined screen by screen,
from Figma, as work progresses.

## Navigation
- V1: Dashboard / Transactions / Planning / Charts + Add transaction
- V2: **Dashboard / Finance / Investments** + **Add transaction** (primary action)
- Settings live outside the tab bar.
- Dashboard, Finance and Investments each have a **global time filter** that drives all data on the page.

## Onboarding
1. Splash — logo, value proposition, language (preselected from device). Choice: start setup or import from another app (import pre-creates accounts, categories and currencies).
2. Main currency + accounts setup
3. Categories setup (with a suggested base set)
4. Investment assets setup

## Dashboard
Quick overview of the user's finances. Customizable widget grid: 2 columns, widget sizes
S (1×1), M (2×1), L (2×2). Core widgets: Total balance, Income & expenses, Budget status,
Latest transactions. Optional widgets: Upcoming recurring, Investments snapshot, Net worth,
Savings goals, Insight of the moment. Net worth = accounts + investments.

## Finance
Where the user goes to understand in detail where their money goes. Four sections, each
answering a question:
- **Overview** — "What's the overall situation?"
- **Transactions** — "Where did my money go?"
- **Budget** — "Am I staying within my limits?"
- **Recurring** — "What fixed commitments do I have?"

## Investments
Where the user goes to understand the state and performance of their portfolio.
Three sections + a detail page:
- **Overview**
- **Positions**
- **Movements** — "What did I earn and spend?"
- **Position detail** (tap on a position)
Global pull-to-refresh for prices, with last-update time always visible.

## Add transaction
Primary action, reachable from everywhere. Shows the remaining budget of the selected
category, supports automatic category assignment and recurring income/expenses/transfers.

## Settings
General (theme, language, currency, authentication), Accounts, Categories & budgets,
Investments, Import/Export, Notifications, Feedback, App info, bank/broker connections.

## Open points (don't decide without asking)
- Insights: what is shown when no insight is available? Are they tappable? (Current assumption: no)
- Non-monthly budgets: filter or toggle to show budgets spanning beyond the selected period?
- Asset setup in onboarding: which fields beyond quantity, value and average cost?
- Status of bank API and broker connections: to be verified
- Benchmark comparison in Investments: to be confirmed
