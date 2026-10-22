// Accordion, from Figma component "Accordion" (node 11:6518): a header that
// shows or hides its content.
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_tappable.dart';

enum SossoldiAccordionSize { sm, md }

class SossoldiAccordion extends StatefulWidget {
  const SossoldiAccordion({
    super.key,
    required this.title,
    required this.child,
    this.icon,
    this.size = SossoldiAccordionSize.sm,
    this.initiallyExpanded = false,
  });

  final String title;
  final Widget child;
  final IconData? icon;
  final SossoldiAccordionSize size;
  final bool initiallyExpanded;

  @override
  State<SossoldiAccordion> createState() => _SossoldiAccordionState();
}

class _SossoldiAccordionState extends State<SossoldiAccordion> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isMd = widget.size == SossoldiAccordionSize.md;
    final titleStyle = isMd ? typography.labelMedium : typography.labelSmall;

    final header = SossoldiTappable(
      onTap: () => setState(() => _expanded = !_expanded),
      semanticLabel: widget.title,
      child: Padding(
        padding: const EdgeInsets.all(SossoldiSpacing.s),
        child: Row(
          spacing: SossoldiSpacing.s,
          children: [
            if (widget.icon != null)
              Icon(widget.icon, size: isMd ? 20 : 16, color: colors.textHigh),
            Expanded(
              child: Text(
                widget.title,
                style: titleStyle.copyWith(color: colors.textHigh),
              ),
            ),
            Icon(
              _expanded
                  ? PhosphorIconsRegular.caretUp
                  : PhosphorIconsRegular.caretDown,
              size: 16,
              color: colors.textHigh,
            ),
          ],
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(SossoldiRadius.s),
      child: ColoredBox(
        color: colors.surfaceMed,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(expanded: _expanded, child: header),
              if (_expanded) ...[
                Divider(height: 1, thickness: 1, color: colors.strokeMinus1),
                widget.child,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
