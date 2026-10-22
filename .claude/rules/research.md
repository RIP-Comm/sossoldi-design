# Alpha 1.0 feedback and V2 decisions

| User feedback | V2 decision / implication |
|---|---|
| Multi-currency and currency management | The user picks a main currency; transactions in other currencies are converted into it. Support for adding new currencies (e.g. BRL, AED), different currencies per account, an "all currencies" option. The main currency is chosen in the first onboarding step. |
| Italian language support | Localization from the start: EN and IT, then PT. Language preselected from the device, editable (onboarding and Settings). |
| Recurring payments, income and transfers | Recurrences extended to income and transfers between accounts, with more frequency options. Dedicated "Recurring" section in Finance. ⚠️ Area with known bugs in the Alpha: handle with care. |
| Date picker unreadable in dark mode | Every component is checked in dark mode; the date picker is rebuilt on theme tokens. |
| Reordering categories and accounts | Tap & hold to reorder; alphabetical or custom order. |
| Charts on total liquidity over time, richer dashboard filterable by period and account | Customizable widget-based Dashboard with a global time filter; Net Worth and Balance widgets with trend charts and comparison to the previous period. |
| Faster transaction entry | Automatic category assignment (e.g. from the description); quick entry via voice (Siri/Google) or Shortcuts-style automations. |

## Principles that emerge
- Clarity of direction: users don't just want numbers, they want to know if they're doing well or badly → insights and comparisons with the previous period.
- Every screen answers a user question (see `information-architecture.md`).
- Transparency about online data: always show when data was last updated (e.g. "updated 2 min ago").
