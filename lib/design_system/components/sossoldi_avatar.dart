// Avatar, from Figma component "Avatar" (node 3:3663).
// Derived from Moon Design (moon_design, MIT, Yolo Group), customized in Figma.

import 'package:flutter/material.dart';

import '../theme/sossoldi_theme.dart';

/// md: 40px, sm: 32px, xs: 24px.
enum SossoldiAvatarSize { md, sm, xs }

enum SossoldiAvatarBadge { topLeft, topRight, bottomLeft, bottomRight }

class SossoldiAvatar extends StatelessWidget {
  /// Initials on a neutral background (Figma Type=Initials).
  const SossoldiAvatar.initials({
    super.key,
    required String this.initials,
    this.size = SossoldiAvatarSize.md,
    this.badge,
  }) : image = null;

  /// Picture (Figma Type=Image).
  const SossoldiAvatar.image({
    super.key,
    required ImageProvider this.image,
    this.size = SossoldiAvatarSize.md,
    this.badge,
  }) : initials = null;

  final String? initials;
  final ImageProvider? image;
  final SossoldiAvatarSize size;

  /// Optional status dot in one corner.
  final SossoldiAvatarBadge? badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final (double box, TextStyle style, double dot) = switch (size) {
      SossoldiAvatarSize.md => (40, typography.labelUppercaseBoldLarge, 8),
      SossoldiAvatarSize.sm => (32, typography.labelUppercaseBoldMedium, 8),
      SossoldiAvatarSize.xs => (24, typography.labelUppercaseBoldSmall, 4),
    };

    final circle = Container(
      width: box,
      height: box,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: image == null ? colors.surfaceMed : null,
        image: image == null
            ? null
            : DecorationImage(image: image!, fit: BoxFit.cover),
      ),
      child: initials == null
          ? null
          : Text(
              initials!.toUpperCase(),
              style: style.copyWith(color: colors.textHigh),
            ),
    );

    if (badge == null) return circle;
    final top =
        badge == SossoldiAvatarBadge.topLeft ||
        badge == SossoldiAvatarBadge.topRight;
    final left =
        badge == SossoldiAvatarBadge.topLeft ||
        badge == SossoldiAvatarBadge.bottomLeft;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        circle,
        Positioned(
          top: top ? 0 : null,
          bottom: top ? null : 0,
          left: left ? 0 : null,
          right: left ? null : 0,
          child: Container(
            width: dot,
            height: dot,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.success.onSurface,
              border: Border.all(color: colors.surfaceMed, width: dot / 4),
            ),
          ),
        ),
      ],
    );
  }
}
