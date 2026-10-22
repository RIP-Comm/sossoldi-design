# Design system

## Origin
Derived from Moon Design (Flutter package `moon_design`, MIT license, Yolo Group).
In Figma the components were detached from the library and customized: the reference is
Sossoldi's Figma, not the original Moon library.

## Decisions
- Tokens and components are **owned by the project** in `lib/design_system/`.
  Do not use `moon_design` as a dependency (package not updated since January 2025);
  its code may be used as a reference for complex components (date picker, bottom sheet,
  segmented control), keeping the attribution.
- Tokens come from the Figma variables (JSON export or read via MCP) and are the source of
  truth: colors (light and dark modes), typography, spacing, radius, shadows.
- The theme is exposed via `ThemeExtension`; widgets read values from the theme, never from scattered constants.
- Every component has a widgetbook entry with all variants and states, in light and dark.

## Domain-specific components to plan for
- Amount with currency (positive/negative, locale formatting, can be masked for future Hidden Mode)
- Dashboard widget card in sizes S / M / L
- Transaction list item
- Budget progress bar with ok / warning / exceeded states
- Period selector and segmented tabs for sections
- Change indicator (€ / %, arrow, color)
- "Updated X ago" label

## To be completed
- Mapping of the real tokens (after importing the variables from Figma)
- Full component list (after the components page in the linked Figma file)
