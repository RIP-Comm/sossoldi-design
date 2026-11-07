import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/dashboard/model/dashboard_layout.dart';
import 'package:sossoldi/features/dashboard/model/default_dashboard_layout.dart';
import 'package:sossoldi/features/dashboard/registry/dashboard_widget_ids.dart';
import 'package:sossoldi_inspector/catalog/widgetbook_links.dart';
import 'package:sossoldi_inspector/main.dart';
import 'package:sossoldi_inspector/panel/component_section.dart';
import 'package:sossoldi_inspector/scenes.dart';
import 'package:sossoldi_inspector/toolbar/inspector_toolbar.dart';

/// The device id flutter_test gives a mouse.
const _mouseDevice = 1;

Future<void> _pumpInspector(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1440, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  // The default Dashboard has many widgets and Latest transactions is below
  // the first view: these tests need Monthly balance and the transactions in
  // sight, as in the old default layout.
  startDashboardLayout = const DashboardLayout([
    DashboardItem(
      id: 'item_1',
      widgetId: DashboardWidgetIds.monthlyBalance,
      size: DashboardWidgetSize.s,
    ),
    DashboardItem(
      id: 'item_2',
      widgetId: DashboardWidgetIds.upcomingRecurring,
      size: DashboardWidgetSize.s,
    ),
    DashboardItem(
      id: 'item_3',
      widgetId: DashboardWidgetIds.latestTransactions,
      size: DashboardWidgetSize.l,
    ),
    DashboardItem(
      id: 'item_4',
      widgetId: DashboardWidgetIds.budgetStatus,
      size: DashboardWidgetSize.m,
    ),
  ]);
  addTearDown(() => startDashboardLayout = defaultDashboardLayout);
  await tester.pumpWidget(const InspectorApp());
  await tester.pump(const Duration(seconds: 1));
}

/// A tool of the floating toolbar (the sidebar has icons of its own).
Finder _inToolbar(IconData icon) => find.descendant(
  of: find.byType(InspectorToolbar),
  matching: find.byIcon(icon),
);

/// Picks the whole design system component under "Pharmacy".
Future<void> _selectTransactionItem(WidgetTester tester) async {
  await tester.tap(_inToolbar(PhosphorIconsRegular.selection));
  await tester.pump();
  await tester.tap(find.text('Component'));
  await tester.pump();
  await tester.tapAt(tester.getCenter(find.text('Pharmacy').first));
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('every scene opens in light and dark', (tester) async {
    await _pumpInspector(tester);
    for (final dark in [false, true]) {
      if (dark) {
        await tester.tap(_inToolbar(PhosphorIconsRegular.moon));
        await tester.pump(const Duration(seconds: 1));
      }
      for (final scene in sceneGroups.expand((g) => g.scenes)) {
        await tester.tap(find.text(scene.title).first);
        // Sheets and pages open after the first frame, then animate.
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 500));
        }
        expect(tester.takeException(), isNull, reason: scene.id);
      }
    }
  });

  testWidgets('a click on the phone shows the measures of the text', (
    tester,
  ) async {
    await _pumpInspector(tester);
    // The title of the Monthly balance widget (the amounts change with the
    // date the mock data are built on).
    await tester.tapAt(tester.getCenter(find.text('Monthly balance').first));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('LAYOUT'), findsOneWidget);
    expect(find.text('TEXT'), findsOneWidget);
    // Its style and color are variables of the design system, in blue chips
    // next to the value.
    expect(find.text('Custom'), findsNothing);
    final chip = find.widgetWithText(SossoldiTag, 'textMed');
    expect(chip, findsOneWidget);
    expect(tester.widget<SossoldiTag>(chip).type, SossoldiTagType.info);
    expect(find.text('#586674'), findsOneWidget);
    // A component has no component section when the text is not one.
    expect(find.text('COMPONENT'), findsNothing);
  });

  testWidgets('Component picks the whole design system component', (
    tester,
  ) async {
    await _pumpInspector(tester);
    await _selectTransactionItem(tester);
    expect(find.text('Component'), findsOneWidget); // the tag
    expect(find.text('PADDING'), findsOneWidget);
    expect(find.text('AUTO LAYOUT'), findsOneWidget);
    // The gap is a number and its variable a chip.
    expect(find.widgetWithText(SossoldiTag, 's'), findsWidgets);
  });

  testWidgets('a component has its details, with Widgetbook in a new window', (
    tester,
  ) async {
    final opened = <Uri>[];
    final previous = openInNewWindow;
    openInNewWindow = (uri) async => opened.add(uri);
    addTearDown(() => openInNewWindow = previous);

    await _pumpInspector(tester);
    await _selectTransactionItem(tester);
    expect(find.text('COMPONENT'), findsOneWidget);
    expect(
      find.text('lib/design_system/components/sossoldi_transaction_item.dart'),
      findsOneWidget,
    );
    // Over the button the pointer is a hand.
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(tester.getCenter(find.text('Open in Widgetbook')));
    await tester.pump();
    expect(
      tester.binding.mouseTracker.debugDeviceActiveCursor(_mouseDevice),
      SystemMouseCursors.click,
    );
    await tester.tap(find.text('Open in Widgetbook'));
    await tester.pump();
    expect(opened, hasLength(1));
    expect(
      opened.single.queryParameters['path'],
      'domain/transaction-item/all-variants',
    );
  });

  testWidgets('layers: kind icons, the whole row selects, hover underlines', (
    tester,
  ) async {
    await _pumpInspector(tester);
    await _selectTransactionItem(tester);

    // The selected component has the purple component icon, in the title and
    // in the tree.
    final icons = find.byIcon(PhosphorIconsRegular.diamondsFour);
    expect(icons, findsWidgets);
    final purple = tester.widget<Icon>(icons.first).color;
    expect(purple, isNot(context(tester).colors.textMed));

    // An ancestor of the tree, a screen of the app.
    final ancestor = find.text('DashboardScreen');
    expect(ancestor, findsOneWidget);

    // Hover underlines the name.
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);
    expect(
      tester.widget<Text>(ancestor).style!.decoration,
      TextDecoration.none,
    );
    await mouse.moveTo(tester.getCenter(ancestor));
    await tester.pump();
    expect(
      tester.widget<Text>(ancestor).style!.decoration,
      TextDecoration.underline,
    );

    // The icon of the row selects too, not only the name.
    final iconSpot = tester.getTopLeft(ancestor) + const Offset(-14, 8);
    await tester.tapAt(iconSpot);
    await tester.pump(const Duration(milliseconds: 100));
    // Now it is the selected layer: in the title and in the tree.
    expect(find.text('DashboardScreen'), findsNWidgets(2));
  });

  testWidgets('the name of a layer selects it, with the hand cursor', (
    tester,
  ) async {
    await _pumpInspector(tester);
    await _selectTransactionItem(tester);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    addTearDown(mouse.removePointer);

    // Over the name the pointer is a hand, not the cursor of selectable text.
    final card = find.text('SossoldiWidgetCard');
    await mouse.moveTo(tester.getCenter(card));
    await tester.pump();
    expect(
      tester.binding.mouseTracker.debugDeviceActiveCursor(_mouseDevice),
      SystemMouseCursors.click,
    );

    // A click on the name selects the layer, every time, even when the mouse
    // moves a little while it is pressed. Selecting a layer ends the tree
    // there: the layers below it are gone.
    Future<void> click(String name) async {
      final at = tester.getCenter(find.text(name));
      await mouse.moveTo(at);
      await mouse.down(at);
      await mouse.moveBy(const Offset(2, 1));
      await mouse.up();
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('SossoldiTransactionItem'), findsWidgets);
    await click('SossoldiWidgetCard');
    expect(find.text('SossoldiTransactionItem'), findsNothing);
    await click('LatestTransactionsCard');
    expect(find.text('SossoldiWidgetCard'), findsNothing);
    await click('DashboardScreen');
    expect(find.text('LatestTransactionsCard'), findsNothing);
  });

  testWidgets('the pick tool hides in Interact and comes back', (tester) async {
    await _pumpInspector(tester);
    expect(find.byIcon(PhosphorIconsRegular.selection), findsOneWidget);
    await tester.tap(find.byIcon(PhosphorIconsRegular.handPointing));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byIcon(PhosphorIconsRegular.selection), findsNothing);
    await tester.tap(find.byIcon(PhosphorIconsRegular.cursor));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byIcon(PhosphorIconsRegular.selection), findsOneWidget);
  });

  testWidgets('zoom and a wide panel keep working', (tester) async {
    await _pumpInspector(tester);
    await tester.tap(find.text('Fit'));
    await tester.pump();
    await tester.tap(find.text('150%'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('150%'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Inspector is light until its own switch says dark', (
    tester,
  ) async {
    // A dark device does not make the Inspector dark.
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    await _pumpInspector(tester);

    Brightness inspector() =>
        Theme.of(tester.element(find.text('Sossoldi Inspector'))).brightness;
    expect(inspector(), Brightness.light);

    // The switch of the sidebar changes the Inspector, not the app.
    await tester.tap(find.byType(SossoldiSwitch));
    // The first pump builds the new theme, the second plays its animation.
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(inspector(), Brightness.dark);
    expect(
      Theme.of(tester.element(find.text('Monthly balance').first)).brightness,
      Brightness.light,
    );
  });

  test('every Widgetbook link points to a page name Widgetbook can have', () {
    final uri = widgetbookUri('SossoldiButton')!;
    expect(uri.queryParameters['path'], 'components/button/all-variants');
    // The name with spaces, "&" and "," is a single node of the path.
    expect(
      widgetbookUri('SossoldiMenuItem')!.queryParameters['path'],
      'overlays-&-feedback/menu-item,-list,-dropdown/all-variants',
    );
    // No page, no link.
    expect(widgetbookUri('SossoldiTappable'), isNull);
  });
}

BuildContext context(WidgetTester tester) =>
    tester.element(find.byType(InspectorPage));
