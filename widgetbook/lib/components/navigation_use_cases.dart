import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../foundations/foundation_page.dart';

const _icon = PhosphorIconsRegular.sticker;

class TabUseCase extends StatelessWidget {
  const TabUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Default (inactive / active) and Icon',
          children: [
            for (final active in [false, true]) ...[
              SizedBox(
                width: 110,
                child: SossoldiTab(
                  label: 'Label',
                  icon: _icon,
                  counter: '99',
                  active: active,
                  onTap: () {},
                ),
              ),
              SossoldiTab.icon(
                icon: _icon,
                active: active,
                onTap: () {},
                semanticLabel: 'Tab',
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class TabNavigationUseCase extends StatefulWidget {
  const TabNavigationUseCase({super.key});

  @override
  State<TabNavigationUseCase> createState() => _TabNavigationUseCaseState();
}

class _TabNavigationUseCaseState extends State<TabNavigationUseCase> {
  int _text = 0;
  int _typed = 0;
  int _icon = 0;

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Text',
          children: [
            SizedBox(
              width: 320,
              child: SossoldiTabNavigation(
                tabs: const [
                  SossoldiTabData.text('Label'),
                  SossoldiTabData.text('Label'),
                  SossoldiTabData.text('Label'),
                  SossoldiTabData.text('Label'),
                ],
                selectedIndex: _text,
                onChanged: (i) => setState(() => _text = i),
              ),
            ),
          ],
        ),
        FoundationSection(
          title: 'Colored when selected (type of a transaction)',
          children: [
            SizedBox(
              width: 320,
              child: SossoldiTabNavigation(
                tabs: [
                  SossoldiTabData.text(
                    'Expense',
                    activeRole: context.colors.expense,
                  ),
                  SossoldiTabData.text(
                    'Income',
                    activeRole: context.colors.income,
                  ),
                  SossoldiTabData.text(
                    'Transfer',
                    activeRole: context.colors.info,
                  ),
                ],
                selectedIndex: _typed,
                onChanged: (i) => setState(() => _typed = i),
              ),
            ),
          ],
        ),
        FoundationSection(
          title: 'Icon',
          children: [
            SossoldiTabNavigation(
              tabs: [
                for (var i = 0; i < 4; i++)
                  SossoldiTabData.icon(
                    PhosphorIconsRegular.sticker,
                    semanticLabel: 'Tab $i',
                  ),
              ],
              selectedIndex: _icon,
              onChanged: (i) => setState(() => _icon = i),
            ),
          ],
        ),
      ],
    );
  }
}

class UnitNavigatorUseCase extends StatefulWidget {
  const UnitNavigatorUseCase({super.key});

  @override
  State<UnitNavigatorUseCase> createState() => _UnitNavigatorUseCaseState();
}

class _UnitNavigatorUseCaseState extends State<UnitNavigatorUseCase> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Default / Selected (tap to toggle)',
          children: [
            SossoldiUnitNavigator(
              label: 'Unit navigator',
              icon: _icon,
              selected: _selected,
              onTap: () => setState(() => _selected = !_selected),
            ),
            SossoldiUnitNavigator(
              label: 'Unit navigator',
              icon: _icon,
              selected: true,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}
