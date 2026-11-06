// The details of a design system component: its name, the file to find it in
// the code and its page in Widgetbook, opened in a new window.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:url_launcher/url_launcher.dart';

import '../catalog/widget_names.g.dart';
import '../catalog/widgetbook_links.dart';
import 'panel_rows.dart';

/// Opens [uri] in a new browser window. Replaced in tests.
Future<void> Function(Uri uri) openInNewWindow = (uri) =>
    launchUrl(uri, webOnlyWindowName: '_blank');

class ComponentSection extends StatelessWidget {
  const ComponentSection({super.key, required this.name});

  /// The class of the component, e.g. `SossoldiTransactionItem`.
  final String name;

  @override
  Widget build(BuildContext context) {
    final widgetbook = widgetbookUri(name);
    return PanelSection(
      title: 'Component',
      children: [
        PanelRow(label: 'Name', value: name),
        PanelRow(label: 'Code', value: widgetFiles[name] ?? '-'),
        if (widgetbook != null)
          // Not selectable text: over it the pointer is a hand, not the
          // cursor of the selectable text around.
          SelectionContainer.disabled(
            child: Align(
              alignment: Alignment.centerLeft,
              child: SossoldiButton(
                label: 'Open in Widgetbook',
                size: SossoldiButtonSize.small,
                type: SossoldiButtonType.ghost,
                iconRight: PhosphorIconsRegular.arrowSquareOut,
                onPressed: () => openInNewWindow(widgetbook),
              ),
            ),
          ),
      ],
    );
  }
}
