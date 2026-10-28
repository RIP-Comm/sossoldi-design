import 'package:flutter/material.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../foundations/foundation_page.dart';

class CheckboxUseCase extends StatefulWidget {
  const CheckboxUseCase({super.key});

  @override
  State<CheckboxUseCase> createState() => _CheckboxUseCaseState();
}

class _CheckboxUseCaseState extends State<CheckboxUseCase> {
  bool? _interactive = false;

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'States (Stroke, Fill, Mixed, Disabled)',
          children: [
            SossoldiCheckbox(value: false, onChanged: (_) {}, label: 'Label'),
            SossoldiCheckbox(value: true, onChanged: (_) {}, label: 'Label'),
            SossoldiCheckbox(value: null, onChanged: (_) {}, label: 'Label'),
            const SossoldiCheckbox(value: true, onChanged: null, label: 'Off'),
            const SossoldiCheckbox(value: false, onChanged: null),
          ],
        ),
        FoundationSection(
          title: 'Interactive',
          children: [
            SossoldiCheckbox(
              value: _interactive,
              onChanged: (v) => setState(() => _interactive = v),
              label: 'Tap me',
            ),
          ],
        ),
      ],
    );
  }
}

class RadioUseCase extends StatefulWidget {
  const RadioUseCase({super.key});

  @override
  State<RadioUseCase> createState() => _RadioUseCaseState();
}

class _RadioUseCaseState extends State<RadioUseCase> {
  int _value = 1;

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Interactive group',
          children: [
            for (final v in [1, 2, 3])
              SossoldiRadio<int>(
                value: v,
                groupValue: _value,
                onChanged: (v) => setState(() => _value = v),
                label: 'Option $v',
              ),
          ],
        ),
        const FoundationSection(
          title: 'Disabled',
          children: [
            SossoldiRadio<int>(
              value: 1,
              groupValue: 1,
              onChanged: null,
              label: 'Label',
            ),
            SossoldiRadio<int>(
              value: 2,
              groupValue: 1,
              onChanged: null,
              label: 'Label',
            ),
          ],
        ),
      ],
    );
  }
}

class SwitchUseCase extends StatefulWidget {
  const SwitchUseCase({super.key});

  @override
  State<SwitchUseCase> createState() => _SwitchUseCaseState();
}

class _SwitchUseCaseState extends State<SwitchUseCase> {
  bool _value = true;

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Off / On / Disabled off / Disabled on',
          children: [
            SossoldiSwitch(value: false, onChanged: (_) {}),
            SossoldiSwitch(value: true, onChanged: (_) {}),
            const SossoldiSwitch(value: false, onChanged: null),
            const SossoldiSwitch(value: true, onChanged: null),
          ],
        ),
        FoundationSection(
          title: 'Interactive',
          children: [
            SossoldiSwitch(
              value: _value,
              onChanged: (v) => setState(() => _value = v),
            ),
          ],
        ),
        FoundationSection(
          title: 'Row with label (forms of a budget and of an asset)',
          children: [
            SossoldiSwitchRow(
              label: 'Counts for Net Worth',
              value: _value,
              onChanged: (v) => setState(() => _value = v),
            ),
            const SossoldiSwitchRow(
              label: 'Disabled',
              value: false,
              onChanged: null,
            ),
          ],
        ),
      ],
    );
  }
}
