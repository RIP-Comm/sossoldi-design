// Primitive color scale, generated from the Figma export Primitive_colors.tokens.json.
// Do not use these directly in widgets: go through the semantic SossoldiColors.
// Orange/20, Orange/70 and Red/5 are corrected values provided by design
// (the Figma export still has the old ones).

import 'package:flutter/painting.dart';

abstract final class SossoldiPrimitives {
  // Primary
  static const primary5 = Color(0xFF010D19);
  static const primary10 = Color(0xFF011A32);
  static const primary20 = Color(0xFF023364);
  static const primary30 = Color(0xFF034D96);
  static const primary40 = Color(0xFF0466C8);
  static const primary50 = Color(0xFF0580FA);
  static const primary60 = Color(0xFF3799FB);
  static const primary70 = Color(0xFF69B2FC);
  static const primary80 = Color(0xFF9BCCFD);
  static const primary90 = Color(0xFFCDE5FE);
  static const primary93 = Color(0xFFE1EDFA); // try: light selected tint
  static const primary95 = Color(0xFFE6F2FE);
  static const primary97 = Color(0xFFF0F7FF);
  static const primary99 = Color(0xFFFAFCFF);

  // Grey
  static const grey5 = Color(0xFF0B0D0F);
  static const grey10 = Color(0xFF161A1D);
  static const grey20 = Color(0xFF2C333A);
  static const grey22 = Color(0xFF282F34); // try: dark surfaceHighPlus1
  static const grey30 = Color(0xFF424D57);
  static const grey40 = Color(0xFF586674);
  static const grey50 = Color(0xFF6E8091);
  static const grey60 = Color(0xFF8B99A7);
  static const grey70 = Color(0xFFA8B2BD);
  static const grey80 = Color(0xFFC5CCD3);
  static const grey88 = Color(0xFFDFE3E7); // try: light surfaceLow
  static const grey90 = Color(0xFFE2E5E9);
  static const grey93 = Color(0xFFEBEDF0);
  static const grey95 = Color(0xFFF0F2F4);
  static const grey97 = Color(0xFFF6F7F8);
  static const grey100 = Color(0xFFFFFFFF);

  // Red
  static const red5 = Color(0xFF170303);
  static const red10 = Color(0xFF2E0505);
  static const red20 = Color(0xFF5C0A0A);
  static const red30 = Color(0xFF8A0F0F);
  static const red40 = Color(0xFFB81414);
  static const red50 = Color(0xFFE51919);
  static const red60 = Color(0xFFEB4747);
  static const red70 = Color(0xFFF07575);
  static const red80 = Color(0xFFF5A3A3);
  static const red90 = Color(0xFFFAD1D1);
  static const red95 = Color(0xFFFCE8E8);
  static const red99 = Color(0xFFFEFAFA);

  // Green
  static const green5 = Color(0xFF041606);
  static const green10 = Color(0xFF082B0C);
  static const green20 = Color(0xFF0F5719);
  static const green30 = Color(0xFF178225);
  static const green40 = Color(0xFF1FAD32);
  static const green50 = Color(0xFF26D93E);
  static const green60 = Color(0xFF52E065);
  static const green70 = Color(0xFF7DE88B);
  static const green80 = Color(0xFFA8F0B2);
  static const green90 = Color(0xFFD4F7D8);
  static const green95 = Color(0xFFE9FBEC);
  static const green99 = Color(0xFFFBFEFB);

  // Orange
  static const orange5 = Color(0xFF180902);
  static const orange10 = Color(0xFF2F1204);
  static const orange20 = Color(0xFF5E2508);
  static const orange30 = Color(0xFF8E370B);
  static const orange40 = Color(0xFFBD490F);
  static const orange50 = Color(0xFFEC5B13);
  static const orange60 = Color(0xFFF07C42);
  static const orange70 = Color(0xFFF49D71);
  static const orange80 = Color(0xFFF7BEA1);
  static const orange90 = Color(0xFFFBDED0);
  static const orange95 = Color(0xFFFDEFE7);
  static const orange99 = Color(0xFFFFFCFA);

  // Muted semantic tones for dark mode (derived, not in the Figma export):
  // the saturated primitives above glow on dark surfaces.
  static const mutedBlueText = Color(0xFF9CC3E8);
  static const mutedBlue = Color(0xFF6A9FD0);
  static const mutedBlueSurface = Color(0xFF16222D);
  static const mutedGreenText = Color(0xFF93C9A0);
  static const mutedGreen = Color(0xFF63AA75);
  static const mutedGreenSurface = Color(0xFF15261B);
  static const mutedOrangeText = Color(0xFFE2AA88);
  static const mutedOrange = Color(0xFFD08A5E);
  static const mutedOrangeSurface = Color(0xFF2A1E16);
  static const mutedRedText = Color(0xFFE09C9C);
  static const mutedRed = Color(0xFFCF6F6F);
  static const mutedRedSurface = Color(0xFF2A1717);
}
