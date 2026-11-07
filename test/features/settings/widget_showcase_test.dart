import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/dashboard/widgets/insight_card.dart';
import 'package:sossoldi/features/settings/widget_showcase_screen.dart';
import 'package:sossoldi/l10n/l10n.dart';
import 'package:sossoldi/mock/mock_repository.dart';

void main() {
  for (final b in Brightness.values) {
    for (final locale in ['en', 'it']) {
      testWidgets(
        'the showcase draws every widget, case and size (${b.name}, $locale)',
        (tester) async {
          tester.view.physicalSize = const Size(390, 60000);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          await tester.pumpWidget(
            AppScope(
              state: AppState(repository: MockRepository.newUser()),
              child: MaterialApp(
                theme: b == Brightness.dark
                    ? SossoldiTheme.dark
                    : SossoldiTheme.light,
                locale: Locale(locale),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const WidgetShowcaseScreen(),
              ),
            ),
          );
          await tester.pump();
          // 12 insights (size S), and every widget of the registry.
          expect(find.byType(InsightCard), findsNWidgets(12));
          expect(
            find.byType(SossoldiWidgetCard).evaluate().length,
            greaterThan(60),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
