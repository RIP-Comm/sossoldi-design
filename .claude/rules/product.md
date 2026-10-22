# Product

## Problem and vision
Mr. RIP tracks his net worth in a spreadsheet. Sossoldi aims to replace that spreadsheet and
make net-worth tracking easy for everyone, even people who aren't comfortable with Excel or
Google Sheets. Long-term goal: evolve from a basic income/expense tracker into a complete
personal finance management tool.

## Who it's for
People who want to:
- track their net worth
- track their expenses to understand where their money goes
- keep track of their investments (from someone with a few ETFs to someone managing a
  diversified, complex portfolio)
- keep everything in one place

## Core values (binding for every design and code decision)
- **User ownership of data**: data belongs to the user and must always be exportable in open,
  editable formats. No data collection; if that ever changes, it must be communicated transparently.
- **Offline-first**: transactions, budgeting, planning and import/export must work without a
  connection. Online features are welcome but always optional.
- **Performance and usability**: speed and efficiency come first. Fast navigation, ease of use.
- **Seamless system integration**: the goal is to replace the systems users already rely on;
  import, sync and integrations ease the transition.
- **Open source and community respect**: MIT license, credit to the original authors.

## Public roadmap (no dates)
- Phase 1 — Income/expense tracking + budgeting (Beta)
- Phase 2 — Data management: better CSV template, partial import, import from other apps and
  banks, Hidden Mode (blur balances), opt-in cloud backup, default categories in onboarding, subcategories
- Phase 2 — Multi-currency and investments: multiple currencies per account, automatic exchange
  rates, net worth in a base currency; stocks, ETFs, bonds, crypto entered manually with P/L,
  allocation and performance
- Phase 3 — Annual budgets, net worth over time revamp, forecasting
- Phase 4 — Open Banking, Google Sheets integration, financial literacy tools
- Phase 5 — Shared accounts and collaboration

Note: V2 promotes Investments to a main tab and brings forward parts of Phases 2–3
(multi-currency, aggregated net worth, insights). This is intentional.

## Out of scope for this prototype
- Backend, real database, persistence
- Real integrations (Open Banking, brokers, price APIs, exchange rates): mock only
- Roadmap Phases 4–5 (Google Sheets, shared accounts)
