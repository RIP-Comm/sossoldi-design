// Bottom sheet, from Figma component "Bottom Sheet" (node 3:3719).
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';

class SossoldiBottomSheet extends StatelessWidget {
  const SossoldiBottomSheet({
    super.key,
    required this.child,
    this.toolbar,
    this.showDragHandle = true,
  });

  /// Usually a SossoldiBottomSheetToolbar.
  final Widget? toolbar;
  final Widget child;
  final bool showDragHandle;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        SossoldiSpacing.l,
        0,
        SossoldiSpacing.l,
        SossoldiSpacing.l,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceMed,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SossoldiRadius.sheet),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: SossoldiSpacing.l,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: SossoldiSpacing.s,
              children: [
                if (showDragHandle)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: colors.shapeLow,
                          borderRadius: BorderRadius.circular(
                            SossoldiRadius.max,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: SossoldiSpacing.l),
                ?toolbar,
              ],
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

/// Shows [builder]'s content in a [SossoldiBottomSheet] over the page.
Future<T?> showSossoldiBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Widget? toolbar,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (context) =>
        SossoldiBottomSheet(toolbar: toolbar, child: builder(context)),
  );
}
