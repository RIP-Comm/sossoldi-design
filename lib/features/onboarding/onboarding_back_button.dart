import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../design_system/design_system.dart';
import '../../l10n/l10n.dart';

/// "< Back", on its own row above the title of a step, always at the left.
class OnboardingBackButton extends StatelessWidget {
  const OnboardingBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SossoldiButton(
        label: context.l10n.back,
        type: SossoldiButtonType.ghost,
        size: SossoldiButtonSize.large,
        iconLeft: PhosphorIconsRegular.arrowLeft,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}
