import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/design_system.dart';

import '../foundations/foundation_page.dart';

class BreadcrumbUseCase extends StatelessWidget {
  const BreadcrumbUseCase({super.key});

  static SossoldiBreadcrumbItem _item(String label, {IconData? icon}) =>
      SossoldiBreadcrumbItem(label: label, icon: icon, onTap: () {});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Default / slash separator / icon as item',
          children: [
            SossoldiBreadcrumb(
              moreSemanticLabel: 'Show more',
              items: [
                _item('Home page'),
                _item('Sub page'),
                _item('Target page'),
              ],
            ),
            SossoldiBreadcrumb(
              moreSemanticLabel: 'Show more',
              separator: SossoldiBreadcrumbSeparator.slash,
              items: [
                _item('Home page'),
                _item('Sub page'),
                _item('Target page'),
              ],
            ),
            SossoldiBreadcrumb(
              moreSemanticLabel: 'Show more',
              separator: SossoldiBreadcrumbSeparator.chevron,
              items: [
                _item('Home', icon: PhosphorIconsRegular.house),
                _item('Sub page'),
                _item('Target page'),
              ],
            ),
          ],
        ),
        FoundationSection(
          title: 'More than 4 items (tap "..." to open)',
          children: [
            SossoldiBreadcrumb(
              moreSemanticLabel: 'Show more',
              items: [
                _item('Home page'),
                _item('Page A'),
                _item('Page B'),
                _item('Page C'),
                _item('Sub sub page'),
                _item('Target page'),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class PaginationUseCase extends StatefulWidget {
  const PaginationUseCase({super.key});

  @override
  State<PaginationUseCase> createState() => _PaginationUseCaseState();
}

class _PaginationUseCaseState extends State<PaginationUseCase> {
  int _page = 3;

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: '26 pages (interactive)',
          children: [
            SizedBox(
              width: 320,
              child: SossoldiPagination(
                page: _page,
                pageCount: 26,
                onChanged: (p) => setState(() => _page = p),
                previousSemanticLabel: 'Previous page',
                nextSemanticLabel: 'Next page',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class TooltipUseCase extends StatelessWidget {
  const TooltipUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Arrow positions',
          children: [
            for (final arrow in SossoldiTooltipArrow.values)
              SossoldiTooltip(message: 'Tooltip (${arrow.name})', arrow: arrow),
          ],
        ),
        FoundationSection(
          title: 'Live (tap, hover or long press the icon)',
          children: [
            SossoldiTooltipTarget(
              message: 'Net worth = accounts + investments',
              child: Icon(
                PhosphorIconsRegular.info,
                size: 24,
                color: context.colors.textHigh,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class PopoverUseCase extends StatelessWidget {
  const PopoverUseCase({super.key});

  @override
  Widget build(BuildContext context) {
    return FoundationPage(
      children: [
        FoundationSection(
          title: 'Tap the button to open',
          children: [
            SossoldiPopover(
              content: SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    'CONTENT',
                    style: context.typography.labelUppercaseLarge.copyWith(
                      color: context.colors.primary.text,
                    ),
                  ),
                ),
              ),
              child: IgnorePointer(
                child: SossoldiButton(
                  label: 'Open popover',
                  type: SossoldiButtonType.outline,
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
        FoundationSection(
          title: 'Above the trigger (above: true)',
          children: [
            const SizedBox(height: 140),
            SossoldiPopover(
              above: true,
              content: SizedBox(
                height: 120,
                child: Center(
                  child: Text(
                    'CONTENT',
                    style: context.typography.labelUppercaseLarge.copyWith(
                      color: context.colors.primary.text,
                    ),
                  ),
                ),
              ),
              child: IgnorePointer(
                child: SossoldiButton(
                  label: 'Open above',
                  type: SossoldiButtonType.outline,
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
