// Select, from Figma component "Select" (node 3:3823).
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.
// Figma states map to: Default (no value), Selected (has value),
// Disabled (onChanged null); Open shows the options list below the field.

import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/spacing.dart';
import 'sossoldi_dropdown.dart';
import 'sossoldi_field_frame.dart';
import 'sossoldi_menu_item.dart';
import 'sossoldi_tappable.dart';

class SossoldiSelectItem<T> {
  const SossoldiSelectItem({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  final T value;
  final String label;

  /// A disabled option is shown dimmed and cannot be picked.
  final bool enabled;
}

class SossoldiSelect<T> extends StatefulWidget {
  const SossoldiSelect({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.label,
    this.placeholder,
    this.helperText,
    this.icon,
  });

  final List<SossoldiSelectItem<T>> items;
  final T? value;

  /// Null disables the select.
  final ValueChanged<T>? onChanged;
  final String? label;
  final String? placeholder;
  final String? helperText;
  final IconData? icon;

  @override
  State<SossoldiSelect<T>> createState() => _SossoldiSelectState<T>();
}

class _SossoldiSelectState<T> extends State<SossoldiSelect<T>> {
  final _overlay = OverlayPortalController();
  final _link = LayerLink();
  final _fieldKey = GlobalKey();
  final _tapRegionGroup = Object();

  bool get _enabled => widget.onChanged != null;

  void _toggle() {
    setState(_overlay.toggle);
  }

  void _close() {
    if (_overlay.isShowing) setState(_overlay.hide);
  }

  void _select(T value) {
    widget.onChanged?.call(value);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final selected = widget.items
        .where((item) => item.value == widget.value)
        .firstOrNull;
    final open = _overlay.isShowing;
    final contentColor = _enabled ? colors.textHigh : colors.textLow;

    final field = SossoldiTappable(
      onTap: _enabled ? _toggle : null,
      semanticLabel: widget.label,
      child: Container(
        padding: const EdgeInsets.all(SossoldiSpacing.m),
        decoration: SossoldiFieldFrame.decoration(
          context,
          SossoldiFieldFrame.borderColor(
            context,
            enabled: _enabled,
            focused: false,
            hasValue: selected != null,
            isError: false,
          ),
        ),
        child: Row(
          spacing: SossoldiSpacing.s,
          children: [
            if (widget.icon != null)
              Icon(widget.icon, size: 20, color: contentColor),
            Expanded(
              child: Text(
                selected?.label ?? widget.placeholder ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: typography.labelLarge.copyWith(
                  color: !_enabled
                      ? colors.textLow
                      : selected != null
                      ? colors.textHigh
                      : colors.textMed,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(
                open
                    ? PhosphorIconsRegular.caretUp
                    : PhosphorIconsRegular.caretDown,
                size: 16,
                color: _enabled ? colors.textHigh : colors.disabledSurface,
              ),
            ),
          ],
        ),
      ),
    );

    return TapRegion(
      groupId: _tapRegionGroup,
      onTapOutside: (_) => _close(),
      child: SossoldiFieldFrame(
        label: widget.label,
        helperText: widget.helperText,
        child: CompositedTransformTarget(
          key: _fieldKey,
          link: _link,
          child: OverlayPortal(
            controller: _overlay,
            overlayChildBuilder: (context) => _buildOptions(context),
            child: field,
          ),
        ),
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    // Options list is as wide as the field.
    final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    return CompositedTransformFollower(
      link: _link,
      targetAnchor: Alignment.bottomLeft,
      offset: const Offset(0, SossoldiSpacing.s),
      child: Align(
        alignment: Alignment.topLeft,
        child: TapRegion(
          groupId: _tapRegionGroup,
          child: SizedBox(
            width: box?.size.width,
            child: SossoldiDropdown(
              options: [
                for (final item in widget.items)
                  SossoldiMenuItem(
                    label: item.label,
                    selected: item.value == widget.value,
                    enabled: item.enabled,
                    onTap: () => _select(item.value),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
