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
  Figma components, each with a widgetbook entry); screens not started yet

## Project context
Project context lives in `.claude/rules/` and loads automatically every session:
- `product.md` — what Sossoldi is, who it's for, core values, roadmap, out of scope
- `research.md` — Alpha 1.0 user feedback and the design decisions derived from it
- `information-architecture.md` — V2 navigation, main screens and the question each screen answers, open points
- `design-system.md` — rules for tokens, components and light/dark theming

## Stack and technical conventions
- Flutter. Targets: iOS and Android; use Flutter web or macOS for fast previews during development.
- Data: local mock data only. No database and no network calls in the prototype.
- Folder structure:
  - `lib/design_system/` → `tokens/`, `theme/`, `components/`
  - `lib/features/` → `onboarding/`, `dashboard/`, `finance/`, `investments/`, `add_transaction/`, `settings/`
  - `lib/mock/` → fake data (accounts, transactions, budgets, recurring items, positions)
  - `lib/l10n/` → localized strings
  - `widgetbook/` → design system component gallery
- Naming: files in snake_case, classes in PascalCase, one public widget per file.
- Commands (Flutter SDK in `~/development/flutter`; if `flutter` is not on PATH, use
  `~/development/flutter/bin/flutter`):
  - Run the app: `flutter run -d chrome` (or `-d macos`)
  - Static checks: `flutter analyze`
  - Tests: `flutter test`
  - Format: `dart format lib test widgetbook/lib`
  - Widgetbook (separate app in `widgetbook/`, depends on this package by path):
    `cd widgetbook && flutter run -d chrome`
- Fonts: DM Sans is bundled in `assets/fonts/dm_sans/` (OFL). Text styles reference it with
  `package: 'sossoldi'` so they also work from widgetbook.
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
