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
    this.fillHeight = false,
  });

  /// Usually a SossoldiBottomSheetToolbar.
  final Widget? toolbar;
  final Widget child;
  final bool showDragHandle;

  /// Takes all the height it is given (e.g. a full-height sheet) and lets
  /// [child] expand into it, instead of wrapping its content.
  final bool fillHeight;

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
      decoration: ShapeDecoration(
        color: colors.surfaceMed,
        shape: const RoundedSuperellipseBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SossoldiRadius.sheet),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
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
            if (fillHeight) Expanded(child: child) else Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

/// The tallest a sheet can be: it starts 15px below the status bar (Figma).
/// The status bar height is read from the view, not from [context]: a page
/// inside a SafeArea has already consumed it from its MediaQuery, and the
/// sheet would then reach under the status bar.
BoxConstraints sossoldiSheetConstraints(BuildContext context) {
  final view = View.of(context);
  final top = view.padding.top / view.devicePixelRatio;
  final height = view.physicalSize.height / view.devicePixelRatio;
  return BoxConstraints(maxHeight: height - top - 15);
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
    constraints: sossoldiSheetConstraints(context),
    builder: (context) =>
        SossoldiBottomSheet(toolbar: toolbar, child: builder(context)),
  );
}
