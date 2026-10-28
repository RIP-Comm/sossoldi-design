import 'package:flutter/widgets.dart';

import '../../app/placeholder_screen.dart';
import '../../l10n/l10n.dart';

/// Add transaction, not designed yet. Opened on top of the shell.
class AddTransactionPlaceholderScreen extends StatelessWidget {
  const AddTransactionPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderScreen(title: context.l10n.addTransaction, showBack: true);
}
