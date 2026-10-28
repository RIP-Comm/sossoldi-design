import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/dashboard/dashboard_controller.dart';
import 'package:sossoldi/features/dashboard/dashboard_screen.dart';
import 'package:sossoldi/features/dashboard/model/dashboard_layout.dart';
import 'package:sossoldi/l10n/l10n.dart';
import 'package:sossoldi/mock/mock_repository.dart';

import '../../load_test_fonts.dart';

final _now = DateTime(2026, 10, 22, 10);

AppState _state() => AppState(repository: MockRepository(now: _now));

void _setUpView(WidgetTester tester, {Size size = const Size(390, 844)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.localeTestValue = const Locale('en');
  tester.platformDispatcher.localesTestValue = [const Locale('en')];
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearAllTestValues();
  });
}

/// The Dashboard alone, with a controller the test can inspect.
Future<DashboardController> _pumpDashboard(
  WidgetTester tester, {
  DashboardLayout? layout,
}) async {
  _setUpView(tester);
  final controller = DashboardController(layout: layout);
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    AppScope(
      state: _state(),
      child: MaterialApp(
        theme: SossoldiTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DashboardScreen(controller: controller, onOpenSettings: () {}),
        ),
      ),
    ),
  );
  await tester.pump();
  return controller;
}

/// The header button with this accessibility label.
Finder _headerButton(String label) => find.byWidgetPredicate(
  (w) => w is SossoldiHeaderButton && w.semanticLabel == label,
);

// In edit mode the widgets wiggle forever, so pumpAndSettle would never end.
Future<void> _settle(WidgetTester tester) async {
  // One frame to build a new route or step, then time for its animation.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

const _s = DashboardWidgetSize.s;
const _m = DashboardWidgetSize.m;
const _l = DashboardWidgetSize.l;

DashboardLayout _layout(List<DashboardWidgetSize> sizes) => DashboardLayout([
  for (final (i, size) in sizes.indexed)
    DashboardItem(
      id: 'item_${i + 1}',
      widgetId: i.isEven ? 'monthly_balance' : 'latest_transactions',
      size: size,
    ),
]);

void main() {
  setUpAll(loadTestFonts);

  group('entering and leaving edit mode', () {
    testWidgets('long press enters, check leaves; bar changes', (tester) async {
      final c = await _pumpDashboard(tester);
      expect(_headerButton('Hide amounts'), findsOneWidget);
      expect(find.text('Edit Home'), findsNothing);

      await tester.longPress(find.text('Monthly balance'));
      await _settle(tester);
      expect(c.isEditing, isTrue);
      expect(find.text('Edit Home'), findsOneWidget);
      expect(_headerButton('Add widget'), findsOneWidget);
      expect(_headerButton('Hide amounts'), findsNothing);
      expect(find.byType(SossoldiRemoveBadge), findsOneWidget);
      expect(find.byType(SossoldiResizeHandle), findsOneWidget);

      await tester.tap(_headerButton('Done'));
      await _settle(tester);
      expect(c.isEditing, isFalse);
      expect(find.byType(SossoldiRemoveBadge), findsNothing);
      expect(_headerButton('Hide amounts'), findsOneWidget);
    });

    testWidgets('widgets wiggle in edit mode and stop after', (tester) async {
      final c = await _pumpDashboard(tester);
      // Several Transforms wrap a widget (appear, lift, wiggle): the wiggle
      // is the one that rotates.
      double angle() {
        final transforms = tester.widgetList<Transform>(
          find.ancestor(
            of: find.byType(SossoldiWidgetCard),
            matching: find.byType(Transform),
          ),
        );
        return transforms
            .map((t) => t.transform.getRotation().storage[1])
            .reduce((a, b) => a.abs() > b.abs() ? a : b);
      }

      c.enterEditMode();
      await tester.pump(const Duration(milliseconds: 100));
      final first = angle();
      await tester.pump(const Duration(milliseconds: 70));
      final second = angle();
      expect(first, isNot(second));
      // Light: never more than about a degree and a half.
      expect(first.abs(), lessThan(0.03));
      expect(second.abs(), lessThan(0.03));

      c.exitEditMode();
      await _settle(tester);
      expect(angle(), 0);
      await tester.pump(const Duration(milliseconds: 70));
      expect(angle(), 0);
    });

    testWidgets('widgets do not react to taps while editing', (tester) async {
      final c = await _pumpDashboard(tester);
      c.enterEditMode();
      await _settle(tester);
      expect(
        tester
            .widgetList<IgnorePointer>(
              find.descendant(
                of: find.byType(DashboardScreen),
                matching: find.byType(IgnorePointer),
              ),
            )
            .any((w) => w.ignoring),
        isTrue,
      );
    });
  });

  group('removing', () {
    testWidgets('the - badge removes only its widget', (tester) async {
      final c = await _pumpDashboard(tester, layout: _layout([_s, _s, _m]));
      c.enterEditMode();
      await _settle(tester);
      expect(find.byType(SossoldiRemoveBadge), findsNWidgets(3));

      await tester.tap(find.byType(SossoldiRemoveBadge).first);
      await _settle(tester);
      expect(c.layout.items.map((i) => i.id), ['item_2', 'item_3']);
      expect(find.byType(SossoldiRemoveBadge), findsNWidgets(2));
    });

    testWidgets('empty dashboard: hint in edit mode, button in view', (
      tester,
    ) async {
      final c = await _pumpDashboard(tester, layout: _layout([_s]));
      c.enterEditMode();
      await _settle(tester);
      await tester.tap(find.byType(SossoldiRemoveBadge));
      await _settle(tester);
      expect(c.layout.isEmpty, isTrue);
      expect(find.text('Tap + to add a widget'), findsOneWidget);

      c.exitEditMode();
      await _settle(tester);
      expect(find.text('Your Home is empty'), findsOneWidget);
      expect(find.widgetWithText(SossoldiButton, 'Add widget'), findsOneWidget);
    });
  });

  group('reordering', () {
    // Press and hold the widget showing [title], then drag it by [by].
    Future<void> dragWidget(
      WidgetTester tester,
      Finder on,
      Offset by, {
      bool release = true,
    }) async {
      final gesture = await tester.startGesture(tester.getCenter(on));
      await tester.pump(const Duration(milliseconds: 700));
      for (var i = 1; i <= 10; i++) {
        await gesture.moveBy(by / 10);
        await tester.pump(const Duration(milliseconds: 16));
      }
      if (release) {
        await gesture.up();
        await _settle(tester);
      }
    }

    List<String> ids(DashboardController c) => [
      for (final i in c.layout.items) i.id,
    ];

    testWidgets('dragging a widget below the next one swaps them', (
      tester,
    ) async {
      final c = await _pumpDashboard(tester, layout: _layout([_m, _m]));
      c.enterEditMode();
      await _settle(tester);
      await dragWidget(
        tester,
        find.text('Monthly balance'),
        const Offset(0, 200),
      );
      expect(ids(c), ['item_2', 'item_1']);
    });

    testWidgets('a small drag keeps the order', (tester) async {
      final c = await _pumpDashboard(tester, layout: _layout([_m, _m]));
      c.enterEditMode();
      await _settle(tester);
      await dragWidget(
        tester,
        find.text('Monthly balance'),
        const Offset(0, 30),
      );
      expect(ids(c), ['item_1', 'item_2']);
    });

    testWidgets(
      'while held the widget has no controls; order changes on drop',
      (tester) async {
        final c = await _pumpDashboard(tester, layout: _layout([_m, _m]));
        c.enterEditMode();
        await _settle(tester);
        final gesture = await tester.startGesture(
          tester.getCenter(find.text('Monthly balance')),
        );
        await tester.pump(const Duration(milliseconds: 700));
        await gesture.moveBy(const Offset(0, 200));
        await tester.pump(const Duration(milliseconds: 100));
        // Only the other widget keeps its badge while one is held.
        expect(find.byType(SossoldiRemoveBadge), findsOneWidget);
        expect(ids(c), ['item_1', 'item_2']);
        await gesture.up();
        await _settle(tester);
        expect(find.byType(SossoldiRemoveBadge), findsNWidgets(2));
        expect(ids(c), ['item_2', 'item_1']);
      },
    );

    testWidgets('an S dragged next to a lone S pairs up with it', (
      tester,
    ) async {
      final c = await _pumpDashboard(tester, layout: _layout([_s, _m, _s]));
      c.enterEditMode();
      await _settle(tester);
      // The last S sits alone on the third row; drag it up and to the right,
      // next to the first S. The M cannot be beside an S, so it moves down.
      final lastS = find.byType(SossoldiWidgetCard).last;
      await dragWidget(tester, lastS, const Offset(186, -380));
      expect(ids(c), ['item_1', 'item_3', 'item_2']);
      final first = tester.getTopLeft(find.byType(SossoldiWidgetCard).first);
      final second = tester.getTopLeft(find.byType(SossoldiWidgetCard).at(1));
      // Same row (the wiggle moves them a pixel or so).
      expect((first.dy - second.dy).abs(), lessThan(3));
    });

    testWidgets('a long press in view mode still only enters edit mode', (
      tester,
    ) async {
      final c = await _pumpDashboard(tester, layout: _layout([_m, _m]));
      await tester.longPress(find.text('Monthly balance'));
      await _settle(tester);
      expect(c.isEditing, isTrue);
      expect(ids(c), ['item_1', 'item_2']);
    });
  });

  group('resizing', () {
    Future<void> dragHandle(WidgetTester tester, Offset by) async {
      final handle = tester.getCenter(find.byType(SossoldiResizeHandle).first);
      final gesture = await tester.startGesture(handle);
      for (var i = 1; i <= 10; i++) {
        await gesture.moveBy(by / 10);
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.up();
      await _settle(tester);
    }

    testWidgets('dragging the handle right grows S to M, then down to L', (
      tester,
    ) async {
      final c = await _pumpDashboard(tester, layout: _layout([_s]));
      c.enterEditMode();
      await _settle(tester);

      await dragHandle(tester, const Offset(180, 0));
      expect(c.layout.items.single.size, _m);

      await dragHandle(tester, const Offset(0, 190));
      expect(c.layout.items.single.size, _l);
    });

    testWidgets('and back down again', (tester) async {
      final c = await _pumpDashboard(tester, layout: _layout([_l]));
      c.enterEditMode();
      await _settle(tester);
      await dragHandle(tester, const Offset(-250, -250));
      expect(c.layout.items.single.size, _s);
    });

    testWidgets('a small drag keeps the size', (tester) async {
      final c = await _pumpDashboard(tester, layout: _layout([_s]));
      c.enterEditMode();
      await _settle(tester);
      await dragHandle(tester, const Offset(20, 10));
      expect(c.layout.items.single.size, _s);
    });

    testWidgets('screen readers can step through sizes', (tester) async {
      final handle = tester.ensureSemantics();
      final c = await _pumpDashboard(tester, layout: _layout([_s]));
      c.enterEditMode();
      await _settle(tester);
      tester.semantics.increase(find.semantics.byLabel('Resize widget'));
      await _settle(tester);
      expect(c.layout.items.single.size, _m);
      tester.semantics.decrease(find.semantics.byLabel('Resize widget'));
      await _settle(tester);
      expect(c.layout.items.single.size, _s);
      handle.dispose();
    });
  });

  group('adding', () {
    testWidgets('the sheet lists the registry widgets', (tester) async {
      final c = await _pumpDashboard(tester);
      c.enterEditMode();
      await _settle(tester);
      await tester.tap(_headerButton('Add widget'));
      await _settle(tester);
      await _settle(tester);
      expect(find.text('Cancel'), findsOneWidget);
      expect(
        find.widgetWithText(SossoldiMenuItem, 'Monthly balance'),
        findsOne,
      );
      expect(
        find.widgetWithText(SossoldiMenuItem, 'Latest transactions'),
        findsOne,
      );
      await tester.tap(find.text('Cancel'));
      await _settle(tester);
      expect(c.layout.items, hasLength(1));
    });

    testWidgets('pick, swipe to M, add: lands in M and the sheet closes', (
      tester,
    ) async {
      final c = await _pumpDashboard(tester);
      c.enterEditMode();
      await _settle(tester);
      await tester.tap(_headerButton('Add widget'));
      await _settle(tester);
      await tester.tap(find.text('Latest transactions'));
      await _settle(tester);

      // Preview starts on S; the title is now the widget name.
      expect(find.byType(SossoldiPageIndicator), findsOneWidget);
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await _settle(tester);
      await tester.tap(find.widgetWithText(SossoldiButton, 'Add widget'));
      await _settle(tester);

      expect(find.byType(SossoldiButton), findsNothing);
      expect(c.layout.items, hasLength(2));
      expect(c.layout.items.last.widgetId, 'latest_transactions');
      expect(c.layout.items.last.size, _m);
    });

    testWidgets(
      'Back returns to the list; the same widget can be added twice',
      (tester) async {
        final c = await _pumpDashboard(tester);
        c.enterEditMode();
        await _settle(tester);
        for (var i = 0; i < 2; i++) {
          await tester.tap(_headerButton('Add widget'));
          await _settle(tester);
          await tester.tap(find.text('Monthly balance').last);
          await _settle(tester);
          if (i == 0) {
            await tester.tap(find.text('Back'));
            await _settle(tester);
            expect(find.text('Cancel'), findsOneWidget);
            await tester.tap(find.text('Monthly balance').last);
            await _settle(tester);
          }
          await tester.tap(find.widgetWithText(SossoldiButton, 'Add widget'));
          await _settle(tester);
        }
        final monthly = c.layout.items.where(
          (i) => i.widgetId == 'monthly_balance',
        );
        expect(monthly, hasLength(3));
        expect(c.layout.items.map((i) => i.id).toSet(), hasLength(3));
      },
    );

    testWidgets('the empty state button enters edit mode and opens the sheet', (
      tester,
    ) async {
      final c = await _pumpDashboard(tester, layout: const DashboardLayout([]));
      await tester.tap(find.widgetWithText(SossoldiButton, 'Add widget'));
      await _settle(tester);
      expect(c.isEditing, isTrue);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });

  group('in the app', () {
    testWidgets('the navigation bar leaves while editing and comes back', (
      tester,
    ) async {
      _setUpView(tester);
      await tester.pumpWidget(SossoldiApp(state: _state()));
      await tester.pump();
      bool barIgnored() => tester
          .widget<IgnorePointer>(
            find
                .ancestor(
                  of: find.byType(SossoldiNavbar),
                  matching: find.byType(IgnorePointer),
                )
                .first,
          )
          .ignoring;
      expect(barIgnored(), isFalse);

      await tester.longPress(find.text('Monthly balance'));
      await _settle(tester);
      expect(barIgnored(), isTrue);
      await tester.tap(_headerButton('Done'));
      await _settle(tester);
      expect(barIgnored(), isFalse);
    });

    testWidgets('the Settings switch turns dark mode on and off', (
      tester,
    ) async {
      _setUpView(tester);
      await tester.pumpWidget(SossoldiApp(state: _state()));
      await tester.pump();
      Brightness brightness() =>
          Theme.of(tester.element(find.byType(Scaffold).first)).brightness;
      expect(brightness(), Brightness.light);

      await tester.tap(find.bySemanticsLabel('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(SossoldiSwitch));
      await tester.pumpAndSettle();
      expect(brightness(), Brightness.dark);

      await tester.tap(find.byType(SossoldiSwitch));
      await tester.pumpAndSettle();
      expect(brightness(), Brightness.light);
    });

    testWidgets('edit mode works in dark mode and in Italian', (tester) async {
      _setUpView(tester);
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      tester.platformDispatcher.localeTestValue = const Locale('it');
      tester.platformDispatcher.localesTestValue = [const Locale('it')];
      await tester.pumpWidget(SossoldiApp(state: _state()));
      await tester.pump();
      await tester.longPress(find.text('Saldo mensile'));
      await _settle(tester);
      expect(find.text('Modifica Home'), findsOneWidget);
      await tester.tap(_headerButton('Aggiungi widget'));
      await _settle(tester);
      expect(find.text('Ultime transazioni'), findsOneWidget);
      expect(find.text('Annulla'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
