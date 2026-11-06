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

## Colors and icons of accounts and categories
- `CategoryColors.all` is the palette (Figma "Palette - Categories"); a `CategoryColor` can also be built from any
  color (`CategoryColor.fromColor`: tint = same hue and saturation at HSL lightness 90%, which is what the palette
  tints are, to one level of 255; in dark mode the tint stays the color at 0.2 of opacity).
- `SossoldiColorPicker`: two sliders (hue, saturation). The space is HCT (`material_color_utilities`, already a
  dependency of Flutter): fixed tone 60, hue from orange to red (30° over 350°), saturation from 60% to 100% of
  the chroma the hue can have at that tone, never above 97 (the most saturated of the palette). Calibrated against
  the palette: the ends have 27 to 93 of chroma, the palette 29 to 97. A color that is not on the sliders (the palette
  ones have other tones) puts them at the closest position and stays exactly as it is until a slider is moved.
- `SossoldiIconPicker` / `showSossoldiIconPicker`: tabs (one icon per group, scrolling) and the grid of the
  selected group, for accounts and categories. `CategoryIcons.groups` has the groups of the Phosphor library
  (Finance, Commerce, Map as travel, Health, People, Nature with Weather, Games, Media, Office, Communication,
  Objects; an icon in several stays in the first) without Arrows, System, Editor, Development, Design and Brand,
  and without math symbols, digits and payment logos: about 990 icons. To drop or move one, edit
  `category_icons.dart`.

## Category row
`SossoldiCategoryItem` toggles its subcategories on a tap of the whole row (Figma Default / Open). With `onRowTap` the
row does something else (edit) and only the caret opens and closes the list (added for the onboarding, Figma 13:3685).

## Change indicator
`SossoldiChangeIndicator(amount, currencyCode, percent?)`: tag with arrow icon and percentage plus the amount in plain text; without
percentage the tag has the amount. Used by the Net worth and Investments widgets (widgetbook: Domain). Not in Figma.

## Components of the Add sheet
Not in Figma, built from tokens: `SossoldiAmountInput` (big number with a fixed prefix such as the "−" of an expense,
currency, numeric keyboard), `showSossoldiDatePicker` (one day, in a bottom sheet, on `SossoldiDateRangePicker`),
tabs that take a color when selected (`SossoldiTabData.text(..., activeRole:)`, for expense / income / transfer),
`SossoldiSnackbar` with a text action ("Undo") and `showSossoldiSnackbar(messenger:, bottomMargin:)`,
`SossoldiBottomSheetToolbar.icon(titleWidget:)` (title that opens a menu), `SossoldiPopover.close(context)`,
`SossoldiSwitchRow(description:)`, `SossoldiAccountItem(tag:)`, `SossoldiTextInput(focusNode:)`, `SossoldiSwitch(size: SossoldiSwitchSize.small)` (40 × 22, for the Inspector's light/dark switch only: no Widgetbook entry on purpose), `SossoldiTagType.info` (blue, to name a variable: the Inspector's design tokens), `SossoldiMenuItem(dense:)` (compact row for the
Inspector's menu), `SossoldiPopover(above:)` (opens above the trigger, for the Inspector's toolbar); the label of a
`SossoldiUnitNavigator` is cut with an ellipsis. Each has a widgetbook entry.

## Trend chart
`SossoldiTrendChart` (Dashboard widgets) has the touch indicator and the tooltip of the other charts (`SossoldiChartTooltip`)
when it gets `formatValue` (plus `pointTitles` per slot of the axis, `currentLabel`, `referenceLabel`, `masked`); without it
it only draws.

## To be completed
- Mapping of the real tokens (after importing the variables from Figma)
- Full component list (after the components page in the linked Figma file)
