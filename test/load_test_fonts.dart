import 'package:flutter/services.dart';

/// Loads DM Sans, so widget tests lay text out with the real metrics
/// instead of the test font (Ahem), whose glyphs are far wider.
Future<void> loadTestFonts() async {
  final loader = FontLoader('DMSans');
  for (final file in const ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    loader.addFont(rootBundle.load('assets/fonts/dm_sans/DMSans-$file.ttf'));
  }
  await loader.load();
}
