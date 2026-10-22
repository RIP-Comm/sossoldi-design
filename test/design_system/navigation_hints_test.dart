import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/design_system/design_system.dart';

Widget _app(Widget child, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? SossoldiTheme.light,
  home: Scaffold(
    body: Center(child: SizedBox(width: 400, child: child)),
  ),
);

SossoldiBreadcrumbItem _item(String label) =>
    SossoldiBreadcrumbItem(label: label, onTap: () {});

void main() {
  for (final (name, theme) in [
    ('light', SossoldiTheme.light),
    ('dark', SossoldiTheme.dark),
  ]) {
    testWidgets('navigation & hints render in $name', (tester) async {
      await tester.pumpWidget(
        _app(
          theme: theme,
          Column(
            children: [
              SossoldiBreadcrumb(
                moreSemanticLabel: 'More',
                items: [_item('A'), _item('B'), _item('C')],
              ),
              SossoldiPagination(
                page: 1,
                pageCount: 3,
                onChanged: (_) {},
                previousSemanticLabel: 'Prev',
                nextSemanticLabel: 'Next',
              ),
              for (final arrow in SossoldiTooltipArrow.values)
                SossoldiTooltip(message: 'Tip', arrow: arrow),
              const SossoldiPopover(content: Text('Body'), child: Text('Open')),
            ],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }

  test('pagination shows a window around the page plus the last page', () {
    List<int> pages(int page) => SossoldiPagination(
      page: page,
      pageCount: 26,
      onChanged: (_) {},
      previousSemanticLabel: '',
      nextSemanticLabel: '',
    ).visiblePages;
    expect(pages(3), [1, 2, 3, 4, 5, 26]);
    expect(pages(12), [10, 11, 12, 13, 14, 26]);
    expect(pages(26), [21, 22, 23, 24, 25, 26]);
  });

  testWidgets('breadcrumb collapses middle items into a dropdown', (
    tester,
  ) async {
    var tapped = '';
    SossoldiBreadcrumbItem item(String l) =>
        SossoldiBreadcrumbItem(label: l, onTap: () => tapped = l);
    await tester.pumpWidget(
      _app(
        SossoldiBreadcrumb(
          moreSemanticLabel: 'More',
          items: [
            item('Home'),
            item('A'),
            item('B'),
            item('C'),
            item('Sub'),
            item('Target'),
          ],
        ),
      ),
    );
    expect(find.text('A'), findsNothing);
    await tester.tap(find.bySemanticsLabel('More'));
    await tester.pump();
    await tester.tap(find.text('B'));
    await tester.pump();
    expect(tapped, 'B');
    expect(find.text('A'), findsNothing);
  });

  testWidgets('popover opens on tap and closes outside', (tester) async {
    await tester.pumpWidget(
      _app(const SossoldiPopover(content: Text('Body'), child: Text('Open'))),
    );
    await tester.tap(find.text('Open'));
    await tester.pump();
    expect(find.text('Body'), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pump();
    expect(find.text('Body'), findsNothing);
  });
}
