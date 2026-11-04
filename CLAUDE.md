# Sossoldi V2 — Flutter prototype

## What it is
Sossoldi is a free, open-source (MIT) app built with Flutter to track net worth, expenses,
bank accounts and investments. It was born to replace Mr. RIP's net-worth spreadsheet and
make net-worth tracking accessible to people who don't use Excel or Google Sheets.
It is mobile-first.

This project is the **high-fidelity prototype of V2**: a redesign of the information
architecture and UI based on feedback from the Alpha 1.0 users. Its purpose is to validate
the design and iterate quickly; later it may be shared with the community and brought into
the official repository.

## Current status
- Alpha 1.0 user feedback: collected and synthesized
- V2 information architecture: defined
- Screens: almost all designed in Figma
- Design system: derived from Moon Design (components detached and customized), being imported
- Code: design system done (tokens, light/dark theme, typography, category colors and all
  Figma components, each with a widgetbook entry); mock database done; app shell (tabs, bottom bar) and Dashboard
  done in view and edit mode (long press, wiggle, drag to reorder, remove, resize, add-widget sheet) with three
  widgets (Monthly balance, Latest transactions and Upcoming recurring, sizes S/M/L; layout in memory only);
  Finance page with its four tabs and Transactions > List (search, filters, grouped by day, pagination)
  and > Charts (totals, donut, breakdown over time, hand-drawn with CustomPainter, no chart library);
  and Budget (overall, segmented bar, list, budget page with edit and delete, all in memory);
  and Recurring (month selector, calendar with dots, list by month or day, recurring page with
  edit, pause and delete, all in memory) and Overview (digest, accounts with their change, upcoming
  recurrences, cash flow, budget status; Finance opens on it);
  Investments page (header with "Updated X ago", pull-to-refresh, tabs) with its Overview (digest,
  portfolio value card, market value chart by period, asset allocation) and Positions (search and
  filters, list with mini charts, breakdown by region or sector, position page with price chart, position,
  asset info and operations) and Movements (search and filters, expected dividends apart, one list by day,
  form to add a movement, page of a movement with edit and delete; the "+" of the bar opens the form in
  Investments); Onboarding: splash, welcome with the choice of language (changes the whole app), Step 1
  (main currency and accounts) with the account form (icon tabs and grid, hue and saturation sliders), Step 2
  (categories, subcategories and budgets, with the suggested categories, the category, subcategory and budget forms,
  drafts saved with the check) and Step 3 (assets as opening buys: asset row, asset form, skip or "Start tracking", which opens the app on Home with the new user's data) on a new-user empty repository; the import is a placeholder; a new user with little data and no transactions is handled by every screen (a neutral empty state where Figma has none);
  the budgets have the flags "count for overall budget" (the Overall budget of the Budget tab sums only those) and
  "limit reach alert" (stored only); Settings has the dark-mode switch, language, currency and,
  as "prototype", "Restart onboarding" and "Load demo data";
  Add transaction: one bottom sheet (the "+") with the Transaction mode (expense, income, transfer also between
  currencies, recurring, category and description suggestions, Undo) and the
  Investment movement mode (the existing form); main account (`isMain`) with its switch in the account form

## Project context
Project context lives in `.claude/rules/` and loads automatically every session:
- `product.md` — what Sossoldi is, who it's for, core values, roadmap, out of scope
- `research.md` — Alpha 1.0 user feedback and the design decisions derived from it
- `information-architecture.md` — V2 navigation, main screens and the question each screen answers, open points
- `design-system.md` — rules for tokens, components and light/dark theming
- `mock-data.md` — how the mock database is built and generated; update it when the mock data changes

Backlog: docs/backlog.md — NON è caricato in automatico; leggilo solo quando ti si chiede stato, cosa manca o priorità

## Stack and technical conventions
- Flutter. Targets: iOS and Android; use Flutter web or macOS for fast previews during development.
- Data: local mock data only. No database and no network calls in the prototype.
  The mock database lives in `lib/mock/` (in memory, generated relative to today with fixed
  seeds). Screens read data **only** through `MockRepository` (`lib/mock/mock_repository.dart`),
  never from `lib/mock/data/` directly. Details in `.claude/rules/mock-data.md`.
- Folder structure:
  - `lib/app/` → app-wide pieces: `app.dart` (MaterialApp, theme, l10n), `app_shell.dart`
    (tabs + bottom bar), `app_state.dart` / `app_scope.dart` (repository and the global
    "hide amounts" switch and the theme mode: `context.repository`, `context.hideAmounts`),
    `placeholder_screen.dart`
  - `lib/design_system/` → `tokens/`, `theme/`, `components/`
  - `lib/features/` → `onboarding/` (`onboarding_flow.dart` with its own Navigator: splash, welcome, step 1, step 2
    `onboarding_categories_screen.dart`, step 3 `onboarding_assets_screen.dart`), `accounts/` (the form of an account and its
    controller, shared by the onboarding and, later, Settings), `categories/` (the forms of a category and of a
    subcategory with their controller, shared with Settings later), `budgets/` (the form of a budget, a component
    of its own for Settings > Budgets too), `assets/` (the form of an asset of the onboarding and its controller), `dashboard/`, `finance/`, `investments/`, `add_transaction/` (the Add sheet `add_sheet.dart`, the transaction form and its controller, the draft that pre-fills it, date fields and the category list), `settings/`
    (Dashboard: `model/` layout and geometry (pure Dart), `dashboard_controller.dart` (layout +
    edit mode, in memory), `dashboard_grid.dart` (animated grid, wiggle, edit controls),
    `add_widget/` (bottom sheet: list, then S/M/L preview), `registry/` available widgets,
    `widgets/` one card + one data-wiring file per widget; to add a widget, register it in
    `registry/dashboard_widget_registry.dart`; Investments: `investments_controller.dart` (tab, period, allocation; pull-to-refresh), `investments_screen.dart`,
    `overview/` the Overview tab, `positions/` the Positions tab and the position page, `movements/` the Movements tab, the form and the page of a
    movement; Finance: `finance_controller.dart` (tab, view, search,
    filters and page, kept by the shell so they survive tab changes), `finance_screen.dart`,
    `transactions/` the list, active filter chips and the filters sheet, `charts/` the Charts view with its
    own controller and filters sheet, `budget/` the Budget tab and the page of one budget, `overview/` the Overview tab, `recurring/` the Recurring tab (calendar, list)
    and the page of one recurring transaction)
  - `lib/mock/` → mock database: `models/`, `data/`, `mock_repository.dart`
  - `lib/l10n/` → localized strings: edit `app_en.arb` / `app_it.arb`, then run `flutter gen-l10n`
    (output in `lib/l10n/generated/`); use `context.l10n.<key>`
  - `widgetbook/` → design system component gallery
  - `inspector/` → Sossoldi Inspector (Flutter web, depends on this package by path): the app in a phone frame
    with a menu of screens and a dev-mode panel (size, padding, auto layout, colors, text, with their tokens),
    the reference for the developers instead of Figma. The app has two hooks for it: `AppEntry`
    (`lib/app/app_entry.dart`, where the shell opens) and `SossoldiApp.builder`. Screens of the menu in
    `inspector/lib/scenes.dart`; after adding a component or a screen widget run
    `dart run tool/generate_widget_names.dart` in `inspector/`. Run: `cd inspector && flutter run -d chrome`.
    Published on GitHub Pages by `.github/workflows/inspector.yml` at every push on `main`
    (repo RIP-Comm/sossoldi-design); the workflow pins the Flutter version (3.47.8): keep it in step
- Naming: files in snake_case, classes in PascalCase, one public widget per file.
- Commands (Flutter SDK in `~/development/flutter`; if `flutter` is not on PATH, use
  `~/development/flutter/bin/flutter`):
  - Run the app: `flutter run -d chrome` (or `-d macos`)
  - Static checks: `flutter analyze`
  - Tests: `flutter test`
  - Format: `dart format lib test widgetbook/lib`
  - Widgetbook (separate app in `widgetbook/`, depends on this package by path):
    `cd widgetbook && flutter run -d chrome`
- Fonts: DM Sans is bundled in `assets/fonts/dm_sans/` (OFL), family `DMSans`. The widgetbook app declares the
  same files through the link `widgetbook/assets/fonts/dm_sans` in its own pubspec, the Inspector through
  `inspector/assets/fonts/dm_sans` (and `inspector/assets/images`): keep the font lists in sync.
- Images: `assets/images/` (the vault in SVG, the five pieces of the logo in `logo/`), drawn with `flutter_svg`.
- Icons: Phosphor (`phosphoricons_flutter`; `phosphor_flutter` is abandoned and does not compile on Dart 3.x).

## Working rules
1. Figma is the visual source of truth. Before implementing a screen or component, read the
   corresponding Figma node via MCP. If you don't have the link, ask for it: never invent the layout.
2. Screens use only tokens and components from `lib/design_system/`. No hardcoded colors,
   sizes, fonts or spacing. If a component is missing, create it in the design system
   (with its widgetbook entry) and say so.
3. Every screen and component must work in both light and dark mode, with readable text in both.
4. No hardcoded user-facing strings: everything goes through localization.
   English and Italian from the start, Portuguese planned.
5. Amounts always show their currency and use the design system's amount component
   (locale formatting, color for positive/negative).
6. Don't add screens, flows or features that aren't in the specs or in Figma without asking first.
7. For the open points listed in `information-architecture.md`, don't decide on your own:
   propose 1–2 options and ask.
8. Offline-first: core features never depend on online services. Online features
   (asset prices, exchange rates, brokers) are simulated with mock data in the prototype.
9. If you reuse code from the `moon_design` package (MIT), keep the attribution in the file header.
10. Don't wait for approval of a plan: when the request is clear and consistent with Figma and
    these rules, go ahead and implement it. Stop and ask only when something is ambiguous,
    contradicts Figma or the rules, or needs a decision that isn't covered (rules 6 and 7 still apply).
11. Quando completi o scopri un lavoro, aggiorna docs/backlog.md (spunta le voci, aggiungi le nuove, aggiorna il log Done)
    List any minor assumption you made in the final summary.
