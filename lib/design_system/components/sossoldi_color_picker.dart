// Color picker of accounts and categories, from the two sliders of the Figma
// "Icon and color" selector (node 13:1833): the first moves the hue along a
// rainbow track, the second the saturation, on a track that changes with the
// hue. The colors come from [CategoryColorSpace] (HCT, fixed tone), so every
// hue looks as light as the others and the ends stay in the family of the
// palette of [CategoryColors]. No color picker package.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';
import '../tokens/category_color_space.dart';
import '../tokens/primitive_colors.dart';
import '../tokens/shadows.dart';

class SossoldiColorPicker extends StatefulWidget {
  const SossoldiColorPicker({
    super.key,
    required this.color,
    required this.onChanged,
    this.hueSemanticLabel,
    this.saturationSemanticLabel,
  });

  /// The color shown. The sliders sit at the closest position; the color is
  /// not changed until one of them is moved.
  final Color color;

  /// A slider was moved: the new color.
  final ValueChanged<Color> onChanged;
  final String? hueSemanticLabel;
  final String? saturationSemanticLabel;

  @override
  State<SossoldiColorPicker> createState() => _SossoldiColorPickerState();
}

class _SossoldiColorPickerState extends State<SossoldiColorPicker> {
  late double _hue;
  late double _saturation;

  /// The last color this picker gave, to tell a change of [color] it caused
  /// from one that comes from outside.
  Color? _emitted;

  @override
  void initState() {
    super.initState();
    _place(widget.color);
  }

  @override
  void didUpdateWidget(SossoldiColorPicker old) {
    super.didUpdateWidget(old);
    if (widget.color != old.color && widget.color != _emitted) {
      _place(widget.color);
    }
  }

  void _place(Color color) {
    final positions = CategoryColorSpace.positionsOf(color);
    _hue = positions.hue;
    _saturation = positions.saturation;
  }

  void _emit() {
    final color = CategoryColorSpace.colorAt(_hue, _saturation);
    _emitted = color;
    widget.onChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 24,
      children: [
        _GradientSlider(
          value: _hue,
          colors: [
            for (var i = 0; i <= 10; i++) CategoryColorSpace.colorAt(i / 10, 1),
          ],
          semanticLabel: widget.hueSemanticLabel,
          onChanged: (v) {
            setState(() => _hue = v);
            _emit();
          },
        ),
        _GradientSlider(
          value: _saturation,
          colors: [
            for (var i = 0; i <= 10; i++)
              CategoryColorSpace.colorAt(_hue, i / 10),
          ],
          // The track follows the hue.
          semanticLabel: widget.saturationSemanticLabel,
          onChanged: (v) {
            setState(() => _saturation = v);
            _emit();
          },
        ),
      ],
    );
  }
}

/// A pill track filled with a gradient and a white knob. [value] and what it
/// reports are positions from 0 to 1.
class _GradientSlider extends StatelessWidget {
  const _GradientSlider({
    required this.value,
    required this.colors,
    required this.onChanged,
    this.semanticLabel,
  });

  final double value;
  final List<Color> colors;
  final ValueChanged<double> onChanged;
  final String? semanticLabel;

  static const double _trackHeight = 24;
  static const double _knob = 32;

  /// Arrow keys and screen readers move the knob by this much.
  static const double _step = 0.05;

  @override
  Widget build(BuildContext context) {
    final themeColors = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final travel = width - _knob;

        void moveTo(double dx) =>
            onChanged(((dx - _knob / 2) / travel).clamp(0.0, 1.0));

        return Semantics(
          slider: true,
          label: semanticLabel,
          value: '${(value * 100).round()}%',
          increasedValue: '${((value + _step).clamp(0.0, 1.0) * 100).round()}%',
          decreasedValue: '${((value - _step).clamp(0.0, 1.0) * 100).round()}%',
          onIncrease: () => onChanged((value + _step).clamp(0.0, 1.0)),
          onDecrease: () => onChanged((value - _step).clamp(0.0, 1.0)),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (d) => moveTo(d.localPosition.dx),
            onHorizontalDragStart: (d) => moveTo(d.localPosition.dx),
            onHorizontalDragUpdate: (d) => moveTo(d.localPosition.dx),
            child: SizedBox(
              height: _knob,
              child: Stack(
                alignment: Alignment.centerLeft,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: _trackHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(_trackHeight),
                      border: Border.all(color: themeColors.strokeDefault),
                      gradient: LinearGradient(colors: colors),
                    ),
                  ),
                  Positioned(
                    left: value.clamp(0.0, 1.0) * travel,
                    // The knob is white in both modes, as in Figma.
                    child: Container(
                      width: _knob,
                      height: _knob,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: SossoldiPrimitives.grey100,
                        border: Border.all(color: SossoldiPrimitives.grey10),
                        boxShadow: SossoldiShadows.s,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
