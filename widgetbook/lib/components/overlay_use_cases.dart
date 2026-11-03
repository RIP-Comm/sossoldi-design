import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../foundations/foundation_page.dart';

const _icon = PhosphorIconsRegular.sticker;

class _Box extends StatelessWidget {
  const _Box(this.child, {this.width = 376});

  final Widget child;
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(width: width, child: child);
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 120,
    child: Center(
      child: Text(
        'CONTENT',
        style: context.typography.labelUppercaseLarge.copyWith(
          color: context.colors.primary.text,
        ),
      ),
    ),
  );
}

class BottomSheetUseCase extends StatelessWidget {
  const BottomSheetUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Toolbar: icon / text',
          children: [
            _Box(
              SossoldiBottomSheetToolbar.icon(
                title: 'Title',
                onClose: () {},
                closeSemanticLabel: 'Close',
                onConfirm: () {},
                confirmSemanticLabel: 'Confirm',
              ),
            ),
            _Box(
              SossoldiBottomSheetToolbar.icon(
                title: 'Check disabled',
                onClose: () {},
                closeSemanticLabel: 'Close',
                onConfirm: () {},
                confirmSemanticLabel: 'Confirm',
                confirmEnabled: false,
              ),
            ),
            _Box(
              SossoldiBottomSheetToolbar.text(
                title: 'Title',
                onClose: () {},
                closeLabel: 'Cancel',
                onConfirm: () {},
                confirmLabel: 'Done',
              ),
            ),
          ],
        ),
        FoundationSection(
          title: 'Bottom sheet',
          children: [
            _Box(
              SossoldiBottomSheet(
                toolbar: SossoldiBottomSheetToolbar.icon(
                  title: 'Title',
                  onClose: () {},
                  closeSemanticLabel: 'Close',
                  onConfirm: () {},
                  confirmSemanticLabel: 'Confirm',
                ),
                child: const _Placeholder(),
              ),
            ),
            SossoldiButton(
              label: 'Open bottom sheet',
              onPressed: () => showSossoldiBottomSheet<void>(
                context: context,
                toolbar: Builder(
                  builder: (context) => SossoldiBottomSheetToolbar.text(
                    title: 'Title',
                    onClose: () => Navigator.pop(context),
                    closeLabel: 'Cancel',
                    onConfirm: () => Navigator.pop(context),
                    confirmLabel: 'Done',
                  ),
                ),
                builder: (_) => const _Placeholder(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ModalUseCase extends StatelessWidget {
  const ModalUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Modal',
          children: [
            const _Box(SossoldiModal(child: _Placeholder())),
            SossoldiButton(
              label: 'Open modal',
              onPressed: () => showSossoldiModal<void>(
                context: context,
                builder: (context) => SizedBox(
                  width: 360,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const _Placeholder(),
                      SossoldiButton(
                        label: 'Close',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SnackbarUseCase extends StatelessWidget {
  const SnackbarUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => FoundationPage(
          children: [
            FoundationSection(
              title: 'Types',
              children: [
                for (final type in SossoldiSnackbarType.values)
                  _Box(
                    SossoldiSnackbar(
                      title: type.name,
                      description: 'Your registration completed successfully',
                      type: type,
                      onClose: () {},
                      closeSemanticLabel: 'Close',
                    ),
                    width: 320,
                  ),
              ],
            ),
            FoundationSection(
              title: 'With an action (after adding a transaction)',
              children: [
                _Box(
                  SossoldiSnackbar(
                    title: 'Transaction added',
                    type: SossoldiSnackbarType.success,
                    actionLabel: 'Undo',
                    onAction: () {},
                  ),
                  width: 320,
                ),
              ],
            ),
            FoundationSection(
              title: 'Live',
              children: [
                SossoldiButton(
                  label: 'Show snackbar',
                  onPressed: () => showSossoldiSnackbar(
                    context,
                    title: 'Saved',
                    description: 'Transaction added',
                    type: SossoldiSnackbarType.success,
                    closeSemanticLabel: 'Close',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AlertUseCase extends StatelessWidget {
  const AlertUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'With title / without title',
          children: [
            _Box(
              SossoldiAlert(
                title: 'Alert title',
                message: 'Pull request #9999 merged after a successful build',
                icon: _icon,
                onClose: () {},
                closeSemanticLabel: 'Close',
              ),
              width: 432,
            ),
            _Box(
              SossoldiAlert(
                message: 'Pull request #9999 merged after a successful build',
                icon: _icon,
                onClose: () {},
                closeSemanticLabel: 'Close',
              ),
              width: 432,
            ),
          ],
        ),
        FoundationSection(
          title: 'Tones: neutral / info / success / warning / error',
          children: [
            for (final tone in SossoldiAlertTone.values)
              _Box(
                SossoldiAlert(
                  tone: tone,
                  title: 'Alert title',
                  message: 'Spending is under the average of the last 3 months',
                  icon: _icon,
                ),
                width: 358,
              ),
          ],
        ),
      ],
    );
  }
}

class AlertCarouselUseCase extends StatelessWidget {
  const AlertCarouselUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Swipe: alerts with a gap, bold numbers (**text**), indicator',
          children: [
            SizedBox(
              width: 358,
              child: SossoldiAlertCarousel(
                alerts: [
                  for (final tone in [
                    SossoldiAlertTone.info,
                    SossoldiAlertTone.success,
                    SossoldiAlertTone.warning,
                  ])
                    SossoldiAlert(
                      tone: tone,
                      title: 'Alert title',
                      message: 'Your portfolio is up **1.240,00 €** over the last month',
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class LoaderProgressUseCase extends StatefulWidget {
  const LoaderProgressUseCase({super.key});

  @override
  State<LoaderProgressUseCase> createState() => _LoaderProgressUseCaseState();
}

class _LoaderProgressUseCaseState extends State<LoaderProgressUseCase> {
  double _value = 0.5;

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        const FoundationSection(
          title: 'Loader xs / md',
          children: [
            SossoldiLoader(),
            SossoldiLoader(size: SossoldiLoaderSize.md),
          ],
        ),
        FoundationSection(
          title: 'Progress circular sm / md',
          children: [
            SossoldiProgressCircular(value: _value),
            SossoldiProgressCircular(
              value: _value,
              size: SossoldiProgressCircularSize.md,
            ),
          ],
        ),
        FoundationSection(
          title: 'Progress linear (tap the buttons to change)',
          children: [
            _Box(SossoldiProgressLinear(value: _value), width: 214),
            SossoldiButton(
              label: '-10%',
              type: SossoldiButtonType.outline,
              onPressed: () =>
                  setState(() => _value = (_value - 0.1).clamp(0, 1)),
            ),
            SossoldiButton(
              label: '+10%',
              type: SossoldiButtonType.outline,
              onPressed: () =>
                  setState(() => _value = (_value + 0.1).clamp(0, 1)),
            ),
          ],
        ),
      ],
    );
  }
}

class AccordionUseCase extends StatelessWidget {
  const AccordionUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        for (final size in SossoldiAccordionSize.values)
          FoundationSection(
            title: 'Size ${size.name} (tap to toggle)',
            children: [
              for (final expanded in [false, true])
                _Box(
                  SossoldiAccordion(
                    title: 'Accordion title',
                    icon: _icon,
                    size: size,
                    initiallyExpanded: expanded,
                    child: const _Placeholder(),
                  ),
                  width: 418,
                ),
            ],
          ),
      ],
    );
  }
}

class MenuListDropdownUseCase extends StatelessWidget {
  const MenuListDropdownUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    final leading = Icon(_icon, size: 24, color: context.colors.textHigh);
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Menu item',
          children: [
            _Box(
              SossoldiMenuItem(
                label: 'Your value',
                subtitle: 'The future of gaming is here, we are ...',
                leading: leading,
                tag: 'Your label',
                hasSubitems: true,
                onTap: () {},
              ),
            ),
          ],
        ),
        FoundationSection(
          title: 'Dense (navigation lists): default / selected',
          children: [
            _Box(
              SossoldiList(
                children: [
                  SossoldiMenuItem(
                    label: 'Overview',
                    dense: true,
                    onTap: () {},
                  ),
                  SossoldiMenuItem(
                    label: 'Transactions',
                    dense: true,
                    selected: true,
                    onTap: () {},
                  ),
                ],
              ),
              width: 240,
            ),
          ],
        ),
        FoundationSection(
          title: 'List',
          children: [
            _Box(
              SossoldiList(
                children: [
                  for (var i = 1; i <= 3; i++)
                    SossoldiMenuItem(
                      label: 'Item $i',
                      leading: leading,
                      hasSubitems: true,
                      onTap: () {},
                    ),
                ],
              ),
              width: 323,
            ),
          ],
        ),
        FoundationSection(
          title: 'Dropdown: single / custom',
          children: [
            _Box(
              SossoldiDropdown(
                options: [
                  for (var i = 1; i <= 3; i++)
                    SossoldiMenuItem(label: 'Option $i', onTap: () {}),
                ],
              ),
              width: 304,
            ),
            const _Box(
              SossoldiDropdown.custom(child: _Placeholder()),
              width: 304,
            ),
          ],
        ),
      ],
    );
  }
}

class SearchUseCase extends StatefulWidget {
  const SearchUseCase({super.key});

  @override
  State<SearchUseCase> createState() => _SearchUseCaseState();
}

class _SearchUseCaseState extends State<SearchUseCase> {
  static const _all = ['Groceries', 'Gym', 'Gifts', 'Rent', 'Restaurants'];
  List<String> _results = const [];

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Icon',
          children: [
            SossoldiSearchButton(onPressed: () {}, semanticLabel: 'Search'),
          ],
        ),
        FoundationSection(
          title: 'Field (type "g" or "r" to see results)',
          children: [
            _Box(
              SossoldiSearchField(
                placeholder: 'Type here to search',
                clearSemanticLabel: 'Clear',
                results: _results,
                onChanged: (q) => setState(
                  () => _results = q.isEmpty
                      ? const []
                      : _all
                            .where(
                              (r) =>
                                  r.toLowerCase().startsWith(q.toLowerCase()),
                            )
                            .toList(),
                ),
              ),
              width: 480,
            ),
          ],
        ),
      ],
    );
  }
}

class AuthCodeUseCase extends StatelessWidget {
  const AuthCodeUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return const FoundationPage(
      children: [
        FoundationSection(
          title: '4 fields / 6 fields (tap and type digits)',
          children: [
            SossoldiAuthCode(semanticLabel: 'PIN'),
            SossoldiAuthCode(length: 6, semanticLabel: 'PIN'),
          ],
        ),
      ],
    );
  }
}
