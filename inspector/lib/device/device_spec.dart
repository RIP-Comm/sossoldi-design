import 'package:flutter/widgets.dart';

/// A phone the app is shown on: screen size in logical pixels and the safe
/// area the system takes (status bar or Dynamic Island, home indicator).
@immutable
class DeviceSpec {
  const DeviceSpec({
    required this.name,
    required this.size,
    required this.safeTop,
    required this.safeBottom,
    required this.cornerRadius,
    this.island = false,
  });

  final String name;
  final Size size;
  final double safeTop;
  final double safeBottom;
  final double cornerRadius;

  /// Draws the Dynamic Island.
  final bool island;

  EdgeInsets get padding => EdgeInsets.only(top: safeTop, bottom: safeBottom);

  static const all = [
    DeviceSpec(
      name: 'iPhone 17 Pro',
      size: Size(402, 874),
      safeTop: 62,
      safeBottom: 34,
      cornerRadius: 62,
      island: true,
    ),
    DeviceSpec(
      name: 'iPhone 17 Pro Max',
      size: Size(440, 956),
      safeTop: 62,
      safeBottom: 34,
      cornerRadius: 62,
      island: true,
    ),
    DeviceSpec(
      name: 'iPhone SE',
      size: Size(375, 667),
      safeTop: 20,
      safeBottom: 0,
      cornerRadius: 0,
    ),
    DeviceSpec(
      name: 'Android (Pixel 9)',
      size: Size(412, 923),
      safeTop: 52,
      safeBottom: 24,
      cornerRadius: 48,
    ),
  ];
}
