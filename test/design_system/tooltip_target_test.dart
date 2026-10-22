import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/design_system/design_system.dart';

Widget _app(Widget child) => MaterialApp(
  theme: SossoldiTheme.light,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('tooltip target shows the message on long press', (tester) async {
    await tester.pumpWidget(
      _app(
        const SossoldiTooltipTarget(
          message: 'Hello',
          child: SizedBox(width: 24, height: 24),
        ),
      ),
    );
    expect(find.text('Hello'), findsNothing);
    await tester.longPress(find.byType(SizedBox).last);
    await tester.pump();
    expect(find.text('Hello'), findsOneWidget);
    // Hides by itself after a while.
    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Hello'), findsNothing);
  });

  testWidgets('tooltip target opens on tap and stays on screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: SossoldiTheme.light,
        home: const Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 200, left: 8),
              child: SossoldiTooltipTarget(
                message: 'Hello',
                child: SizedBox(width: 24, height: 24),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.byType(SizedBox).last);
    await tester.pump();
    expect(find.text('Hello'), findsOneWidget);
    // Near the left edge the bubble aligns left instead of overflowing.
    expect(
      tester.getTopLeft(find.byType(SossoldiTooltip)).dx,
      greaterThanOrEqualTo(0),
    );
    expect(
      tester.widget<SossoldiTooltip>(find.byType(SossoldiTooltip)).arrow,
      SossoldiTooltipArrow.bottomLeft,
    );
    // A tap outside closes it.
    await tester.tapAt(const Offset(600, 500));
    await tester.pump();
    expect(find.text('Hello'), findsNothing);
  });

  testWidgets('a mouse click right after hovering keeps it open', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        const SossoldiTooltipTarget(
          message: 'Hello',
          child: SizedBox(width: 24, height: 24),
        ),
      ),
    );
    final target = tester.getCenter(find.byType(SizedBox).last);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(target);
    await tester.pump();
    await mouse.down(target);
    await mouse.up();
    await tester.pump();
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('tooltip target shows the message on hover', (tester) async {
    await tester.pumpWidget(
      _app(
        const SossoldiTooltipTarget(
          message: 'Hello',
          child: SizedBox(width: 24, height: 24),
        ),
      ),
    );
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(SizedBox).last));
    await tester.pump();
    expect(find.text('Hello'), findsOneWidget);
    await mouse.moveTo(Offset.zero);
    await tester.pump();
    expect(find.text('Hello'), findsNothing);
  });
}
