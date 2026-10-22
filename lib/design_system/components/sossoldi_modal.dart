// Modal, from Figma component "Modal" (node 3:3733): an elevated
// container for dialogs; the content is supplied by the caller.
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/shadows.dart';
import '../tokens/spacing.dart';

class SossoldiModal extends StatelessWidget {
  const SossoldiModal({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SossoldiSpacing.s),
      decoration: BoxDecoration(
        color: context.colors.surfaceHigh,
        borderRadius: BorderRadius.circular(SossoldiRadius.m),
        boxShadow: SossoldiShadows.lg,
      ),
      child: child,
    );
  }
}

/// Shows [builder]'s content in a centered [SossoldiModal].
Future<T?> showSossoldiModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => Center(
      child: Padding(
        padding: const EdgeInsets.all(SossoldiSpacing.l),
        child: Material(
          type: MaterialType.transparency,
          child: SossoldiModal(child: builder(context)),
        ),
      ),
    ),
  );
}
