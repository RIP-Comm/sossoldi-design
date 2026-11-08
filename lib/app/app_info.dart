// What the app says about itself (Settings > Info, footer of App settings):
// version and the community links. The version is the one of the release, kept
// here so a screen never reads it from the platform.

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInfo {
  const AppInfo._();

  static const version = '2.0.0';

  static const github = 'https://github.com/RIP-Comm/sossoldi';
  static const linkedin = 'https://www.linkedin.com/company/sossoldi/posts/';
  static const youtube = 'https://www.youtube.com/@Sossoldi-app';
  static const discord = 'https://discord.com/invite/PcaUZnvPzS';
  static const contactEmail = 'help.sossoldi@gmail.com';

  /// The external form of Settings > Feedback: not available yet, the row does
  /// nothing while it is empty.
  static const feedbackForm = '';
}

/// Opens [url] outside the app (browser, mail). Does nothing for an empty
/// address and never throws: a missing handler (tests, simulators) is ignored.
Future<void> openExternalLink(String url) async {
  if (url.isEmpty) return;
  try {
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('Could not open $url: $e');
  }
}
