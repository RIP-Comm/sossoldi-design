# Sossoldi Inspector

The V2 prototype in a phone frame, with a dev-mode panel: the reference for the
developers who rebuild the front end (Figma is no longer kept up to date).

- **Left**: the main screens, opened directly (no need to navigate the app).
- **Middle**: the real app, at the size of the chosen phone (logical pixels).
  *Inspect* picks boxes (*Element*: the deepest one; *Component*: the whole
  design system component); hover another box to measure the distance.
  *Interact* uses the app as on the phone. The wheel scrolls in both modes.
- **Right**: size and position, padding, auto layout (Row/Column, gap,
  alignment), fill, border, radius, shadow, text style and color, each with the
  design system token it comes from; the components around the selection.
- **Toolbar** (floating, under the phone, as in Figma): on the left device,
  language, data, dark mode, reload, zoom (fit or 50–150%) and what a click
  picks (Element / Component, only in Inspect); on the right the modes,
  Inspect and Interact.
- The right panel is resized by dragging its left edge (320–520 px).

```bash
cd inspector
flutter run -d chrome
# a static site to publish:
flutter build web
```

After adding a design system component or a screen widget, regenerate the
names the panel shows (a release build minifies class names):

```bash
dart run tool/generate_widget_names.dart
```

Measures are in logical pixels (Flutter dp / iOS pt). Assets and fonts come from
the app through the links in `assets/`.
