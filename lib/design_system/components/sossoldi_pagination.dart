// Pagination, from Figma component "Pagination" (node 3:3736): previous /
// next buttons and a window of page numbers plus the last page.
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/radius.dart';
import '../tokens/spacing.dart';
import 'sossoldi_icon_button.dart';
import 'sossoldi_tappable.dart';

class SossoldiPagination extends StatelessWidget {
  const SossoldiPagination({
    super.key,
    required this.page,
    required this.pageCount,
    required this.onChanged,
    required this.previousSemanticLabel,
    required this.nextSemanticLabel,
    this.window = 5,
  }) : assert(pageCount > 0 && page >= 1 && page <= pageCount);

  /// Current page, 1-based.
  final int page;
  final int pageCount;
  final ValueChanged<int> onChanged;
  final String previousSemanticLabel;
  final String nextSemanticLabel;

  /// How many consecutive pages are shown around the current one.
  final int window;

  /// Pages to show: a window around [page], plus the last page.
  List<int> get visiblePages {
    if (pageCount <= window + 1) {
      return [for (var p = 1; p <= pageCount; p++) p];
    }
    var start = (page - window ~/ 2).clamp(1, pageCount - window);
    final pages = [for (var p = start; p < start + window; p++) p];
    if (pages.last != pageCount) pages.add(pageCount);
    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: SossoldiSpacing.xs,
      children: [
        SossoldiIconButton(
          icon: PhosphorIconsRegular.caretLeft,
          variant: SossoldiIconButtonVariant.primary,
          semanticLabel: previousSemanticLabel,
          onPressed: page > 1 ? () => onChanged(page - 1) : null,
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: SossoldiSpacing.xs,
            children: [
              for (final p in visiblePages)
                _PageButton(
                  page: p,
                  current: p == page,
                  onTap: () => onChanged(p),
                ),
            ],
          ),
        ),
        SossoldiIconButton(
          icon: PhosphorIconsRegular.caretRight,
          variant: SossoldiIconButtonVariant.primary,
          semanticLabel: nextSemanticLabel,
          onPressed: page < pageCount ? () => onChanged(page + 1) : null,
        ),
      ],
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.page,
    required this.current,
    required this.onTap,
  });

  final int page;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    return SossoldiTappable(
      onTap: current ? null : onTap,
      selected: current,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: current ? colors.primary.surface : null,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(
              current ? SossoldiRadius.s : SossoldiRadius.xs,
            ),
          ),
        ),
        child: Text(
          '$page',
          style: current
              ? typography.bodyBoldMedium.copyWith(
                  color: colors.primary.onSurface,
                )
              : typography.bodyMedium.copyWith(color: colors.textHigh),
        ),
      ),
    );
  }
}
