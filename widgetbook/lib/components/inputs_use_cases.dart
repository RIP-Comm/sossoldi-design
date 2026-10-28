import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../foundations/foundation_page.dart';

const _icon = PhosphorIconsRegular.sticker;

class _Field extends StatelessWidget {
  const _Field(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) => SizedBox(width: 280, child: child);
}

class TextInputUseCase extends StatelessWidget {
  const TextInputUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Default (tap to focus = Active) / Filled / Error / Disabled',
          children: [
            _Field(
              SossoldiTextInput(
                controller: TextEditingController(text: '850'),
                label: 'With a suffix (e.g. the currency)',
                suffixText: '€',
                keyboardType: TextInputType.number,
              ),
            ),
            const _Field(
              SossoldiTextInput(
                label: 'Input label text',
                placeholder: 'Placeholder text',
                helperText: 'Informative message holder',
                icon: _icon,
                clearSemanticLabel: 'Clear',
              ),
            ),
            _Field(
              SossoldiTextInput(
                controller: TextEditingController(text: 'Filled text'),
                label: 'Input label text',
                helperText: 'Informative message holder',
                icon: _icon,
                clearSemanticLabel: 'Clear',
              ),
            ),
            _Field(
              SossoldiTextInput(
                controller: TextEditingController(text: 'Wrong value'),
                label: 'Input label text',
                errorText: 'Informative message holder',
                icon: _icon,
                clearSemanticLabel: 'Clear',
              ),
            ),
            const _Field(
              SossoldiTextInput(
                label: 'Input label text',
                placeholder: 'Placeholder text',
                helperText: 'Informative message holder',
                icon: _icon,
                enabled: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TextareaUseCase extends StatelessWidget {
  const TextareaUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return const FoundationPage(
      children: [
        FoundationSection(
          title: 'Default / Disabled',
          children: [
            SizedBox(
              width: 398,
              child: SossoldiTextarea(
                placeholder: 'Here is a sample placeholder',
              ),
            ),
            SizedBox(
              width: 398,
              child: SossoldiTextarea(
                placeholder: 'Here is a sample placeholder',
                enabled: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SelectUseCase extends StatefulWidget {
  const SelectUseCase({super.key});

  @override
  State<SelectUseCase> createState() => _SelectUseCaseState();
}

class _SelectUseCaseState extends State<SelectUseCase> {
  int? _value;

  static const _items = [
    SossoldiSelectItem(value: 1, label: 'Option 1'),
    SossoldiSelectItem(value: 2, label: 'Option 2'),
    SossoldiSelectItem(value: 3, label: 'Option 3'),
  ];

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Interactive (tap to open) / Selected / Disabled',
          children: [
            _Field(
              SossoldiSelect<int>(
                items: _items,
                value: _value,
                onChanged: (v) => setState(() => _value = v),
                label: 'Select label text',
                placeholder: 'Select one',
                helperText: 'Informative message holder',
                icon: _icon,
              ),
            ),
            _Field(
              SossoldiSelect<int>(
                items: _items,
                value: 2,
                onChanged: (_) {},
                label: 'Select label text',
                helperText: 'Informative message holder',
                icon: _icon,
              ),
            ),
            const _Field(
              SossoldiSelect<int>(
                items: _items,
                value: null,
                onChanged: null,
                label: 'Select label text',
                placeholder: 'Select one',
                helperText: 'Informative message holder',
                icon: _icon,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
