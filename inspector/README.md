# Sossoldi Inspector

The V2 prototype in a phone frame, with a dev-mode panel: the reference for the
developers who rebuild the front end (Figma is no longer kept up to date).

- **Left**: the main screens, opened directly (no need to navigate the app).
- **Middle**: the real app, at the size of the chosen phone (logical pixels).
  *Inspect* picks boxes (*Element*: the deepest one; *Component*: the whole
  design system component); hover another box to measure the distance.
  *Interact* uses the app as on the phone. The wheel scrolls in both modes.
- **Right**:
  - the layers of the selection as a tree (the screens and components around
    it, the selected one last), each with the icon of its kind: a design system
    component is purple, as in Figma. The whole row selects the layer and its
    name is underlined on hover;
  - for a design system component, its details: name, the file in the code and
    its page in Widgetbook, opened in a new window;
  - size and position, padding, auto layout (Row/Column, gap, alignment), fill,
    border, radius, shadow, text style and color. The value is shown as it is
    and the design system variable it matches in a blue chip.
- **Toolbar** (floating, under the phone, as in Figma): on the left device,
  language, data, dark mode, reload, zoom (fit or 50–150%) and what a click
  picks (Element / Component, only in Inspect); on the right the modes,
  Inspect and Interact.
- The switch next to the title (sidebar) is the light/dark theme of the
  Inspector itself: light by default, whatever the device uses. The theme of the
  app in the phone is in the toolbar.
- The right panel is resized by dragging its left edge (320–520 px).

```bash
cd inspector
flutter run -d chrome
```

## Publishing

Every push on `main` of [RIP-Comm/sossoldi-design](https://github.com/RIP-Comm/sossoldi-design)
runs `.github/workflows/inspector.yml`: it tests the Inspector, builds it
(`flutter build web`) and puts the ready site in the **`site`** branch (static
files only, the last build). Any static host serves that branch as it is, with
no build command and the branch root as output: Cloudflare Pages, GitHub Pages
("Deploy from a branch"), Netlify. A failing test leaves the site as it was.

The site expects to be at the root of a domain or subdomain. For a subfolder
(e.g. `/inspector/`) set the repository variable `INSPECTOR_BASE_HREF`. The
Flutter version is pinned in the workflow: update it together with the local
one.

After adding a design system component or a screen widget, regenerate the
names the panel shows (a release build minifies class names) and the file of
each widget:

```bash
dart run tool/generate_widget_names.dart
```

It also checks `lib/catalog/widgetbook_links.dart`, which says where each
component is in Widgetbook: it fails when an entry does not exist in
`widgetbook/lib/main.dart` and lists the components with no entry (no link in the
panel). Add the new component there.

**Widgetbook link.** In a debug run it points to the local Widgetbook
(`http://localhost:8082/`, the `widgetbook` launch configuration). In a build it
points to the `widgetbook/` folder next to the Inspector, or to the address
given with `--dart-define=WIDGETBOOK_URL=https://...`. Widgetbook must be
published there for the link to work.

Measures are in logical pixels (Flutter dp / iOS pt). Assets and fonts come from
the app through the links in `assets/`.
