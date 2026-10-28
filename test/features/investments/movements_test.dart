import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/app/app.dart';
import 'package:sossoldi/app/app_scope.dart';
import 'package:sossoldi/app/app_state.dart';
import 'package:sossoldi/app/placeholder_screen.dart';
import 'package:sossoldi/design_system/design_system.dart';
import 'package:sossoldi/features/investments/investments_controller.dart';
import 'package:sossoldi/features/investments/investments_screen.dart';
import 'package:sossoldi/features/investments/movements/movement_detail_screen.dart';
import 'package:sossoldi/features/investments/movements/movement_form_controller.dart';
import 'package:sossoldi/features/investments/movements/movement_form_fields.dart';
import 'package:sossoldi/features/investments/positions/position_detail_screen.dart';
import 'package:sossoldi/l10n/l10n.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/holding.dart';
import 'package:sossoldi/mock/models/investment_movement.dart';
import 'package:sossoldi/mock/models/movement_edit.dart';
import 'package:sossoldi/mock/models/portfolio.dart';

import '../../load_test_fonts.dart';

final _now = DateTime(2026, 10, 22, 10);

MockRepository _empty() => MockRepository(
  now: _now,
  investments: (_, _) =>
      (holdings: <Holding>[], movements: <InvestmentMovement>[]),
);

class _H {
  _H(this.state, this.controller);
  final AppState state;
  final InvestmentsController controller;
  MockRepository get repo => state.repository;
}

Future<_H> _pump(
  WidgetTester tester, {
  Brightness brightness = Brightness.light,
  Locale locale = const Locale('en'),
  MockRepository? repository,
}) async {
  tester.view.physicalSize = const Size(390, 5200);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.localeTestValue = locale;
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(() {
    tester.view.reset();
    tester.platformDispatcher.clearAllTestValues();
  });
  final state = AppState(repository: repository ?? MockRepository(now: _now));
  final controller = InvestmentsController(state.repository)
    ..selectTab(InvestmentsTab.movements);
  addTearDown(controller.dispose);
  await tester.pumpWidget(
    AppScope(
      state: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
          theme: brightness == Brightness.dark
              ? SossoldiTheme.dark
              : SossoldiTheme.light,
          locale: state.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: InvestmentsScreen(controller: controller)),
        ),
      ),
    ),
  );
  await tester.pump();
  return _H(state, controller);
}

/// The fields of a form on their own, to type in.
Future<MovementFormController> _pumpForm(
  WidgetTester tester,
  MockRepository repo, {
  MovementType type = MovementType.buy,
  String? holdingId,
  InvestmentMovement? editing,
  Brightness brightness = Brightness.light,
}) async {
  tester.view.physicalSize = const Size(390, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final c = MovementFormController(
    repo,
    type: type,
    holdingId: holdingId,
    editing: editing,
  );
  addTearDown(c.dispose);
  await tester.pumpWidget(
    AppScope(
      state: AppState(repository: repo),
      child: MaterialApp(
        theme: brightness == Brightness.dark
            ? SossoldiTheme.dark
            : SossoldiTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: MovementFormFields(controller: c),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return c;
}

Finder _field(String label) => find.descendant(
  of: find.widgetWithText(SossoldiTextInput, label),
  matching: find.byType(TextField),
);

Future<void> _type(WidgetTester tester, String label, String text) async {
  await tester.enterText(_field(label), text);
  await tester.pump();
}

void main() {
  setUpAll(loadTestFonts);

  group('the Movements tab', () {
    testWidgets('search and filters, up next, rows grouped by day', (
      tester,
    ) async {
      final h = await _pump(tester);
      expect(find.byType(SossoldiSearchField), findsOneWidget);
      expect(find.byType(SossoldiFilterButton), findsOneWidget);
      expect(find.text('Up next'), findsOneWidget);
      expect(
        find.text('Add movement'),
        findsNothing,
        reason: 'no floating button',
      );
      final list = h.repo.movementList(h.controller.movementFilter);
      final items = tester
          .widgetList<SossoldiMovementItem>(find.byType(SossoldiMovementItem))
          .toList();
      final expected =
          list.upNext.length +
          list.days.fold(0, (s, d) => s + d.entries.length);
      expect(items.length, expected);
      expect(find.byType(SossoldiDayHeader), findsNWidgets(list.days.length));
      // The day headers have no total chip.
      expect(
        find.descendant(
          of: find.byType(SossoldiDayHeader),
          matching: find.byType(SossoldiChip),
        ),
        findsNothing,
      );
    });

    testWidgets('the tones: buy and sell neutral, dividend green, cost red', (
      tester,
    ) async {
      final h = await _pump(tester, repository: _empty());
      h.repo.addMovement(
        MovementDraft(
          type: MovementType.buy,
          assetId: 'ast_vwce',
          date: DateTime(2026, 3, 2),
          quantity: 2,
          price: 100,
        ),
      );
      final id = h.repo.holdings.single.id;
      h.repo.addMovement(
        MovementDraft(
          type: MovementType.sell,
          holdingId: id,
          date: DateTime(2026, 4, 2),
          quantity: 1,
          price: 110,
        ),
      );
      h.repo.addMovement(
        MovementDraft(
          type: MovementType.dividend,
          holdingId: id,
          date: DateTime(2026, 5, 2),
          amount: 3,
        ),
      );
      h.repo.addMovement(
        MovementDraft(
          type: MovementType.cost,
          date: DateTime(2026, 6, 2),
          amount: 12,
          description: 'Custody',
        ),
      );
      await tester.pump();
      final byType = {
        for (final i in tester.widgetList<SossoldiMovementItem>(
          find.byType(SossoldiMovementItem),
        ))
          i.typeLabel: i,
      };
      expect(byType['Buy']!.tone, SossoldiMovementTone.neutral);
      expect(byType['Sell']!.tone, SossoldiMovementTone.neutral);
      expect(byType['Dividend']!.tone, SossoldiMovementTone.income);
      expect(byType['Cost']!.tone, SossoldiMovementTone.expense);
      expect(byType['Cost']!.amount, -12);
      expect(byType['Cost']!.title, 'Custody');
      expect(byType['Cost']!.subtitle, isNull);
      expect(byType['Buy']!.details, '2 · Price €100.00');
      expect(byType['Buy']!.subtitle, 'VWCE – IE00BK5BQT80');
      expect(byType['Buy']!.amount, 200);
    });

    testWidgets('the search narrows the list; no result, then clear', (
      tester,
    ) async {
      final h = await _pump(tester);
      await tester.enterText(find.byType(TextField).first, 'zzzzz');
      await tester.pump();
      expect(find.byType(SossoldiMovementItem), findsNothing);
      expect(find.text('No movements found'), findsOneWidget);
      await tester.tap(find.text('Clear filters'));
      await tester.pump();
      expect(find.byType(SossoldiMovementItem), findsWidgets);
      expect(h.controller.movementFilter.isRefined, isFalse);
    });

    testWidgets('the filters sheet: period, type, kind and asset', (
      tester,
    ) async {
      final h = await _pump(tester);
      expect(
        tester
            .widget<SossoldiFilterButton>(find.byType(SossoldiFilterButton))
            .active,
        isFalse,
      );
      await tester.tap(find.byType(SossoldiFilterButton));
      await tester.pumpAndSettle();
      for (final t in [
        'Current month',
        'Last 3 months',
        'Current year',
        'Last 12 months',
        'All',
      ]) {
        expect(
          find.descendant(
            of: find.byType(SossoldiBottomSheet),
            matching: find.text(t),
          ),
          findsOneWidget,
        );
      }
      Finder inSheet(String t) => find.descendant(
        of: find.byType(SossoldiBottomSheet),
        matching: find.text(t),
      );
      await tester.tap(inSheet('All'));
      await tester.tap(inSheet('Sell'));
      await tester.tap(inSheet('Stock'));
      await tester.pump();
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      final f = h.controller.movementFilter;
      expect(f.period, MovementPeriod.all);
      expect(f.types, {MovementType.sell});
      expect(f.kinds, {PositionKind.stock});
      expect(
        tester
            .widget<SossoldiFilterButton>(find.byType(SossoldiFilterButton))
            .active,
        isTrue,
      );
      for (final i in tester.widgetList<SossoldiMovementItem>(
        find.byType(SossoldiMovementItem),
      )) {
        expect(i.typeLabel, 'Sell');
      }
    });

    testWidgets('hidden amounts; Italian; dark', (tester) async {
      final h = await _pump(
        tester,
        locale: const Locale('it'),
        brightness: Brightness.dark,
      );
      expect(find.text('Cerca movimenti'), findsOneWidget);
      expect(find.text('In arrivo'), findsOneWidget);
      expect(find.text('Dividendo'), findsWidgets);
      h.state.toggleHideAmounts();
      await tester.pump();
      expect(find.text('••••'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('no movements at all: an empty state', (tester) async {
      await _pump(tester, repository: _empty());
      expect(find.text('No movements yet'), findsOneWidget);
      expect(find.byType(SossoldiMovementItem), findsNothing);
    });
  });

  group('the form', () {
    testWidgets('a buy: the fields, the currency, no errors until a save', (
      tester,
    ) async {
      final c = await _pumpForm(tester, _empty());
      for (final t in ['Buy', 'Sell', 'Dividend', 'Cost']) {
        expect(find.text(t), findsOneWidget);
      }
      for (final l in [
        'Quantity',
        'Unit price',
        'Commission (optional)',
        'Date',
      ]) {
        expect(find.text(l), findsOneWidget);
      }
      expect(find.text('€'), findsNWidgets(2));
      expect(find.text('Required.'), findsNothing);
      expect(c.submit(), isFalse);
      await tester.pump();
      expect(find.text('Required.'), findsWidgets);
      expect(find.text('Choose an asset.'), findsOneWidget);
    });

    testWidgets('typed numbers are checked; a comma works', (tester) async {
      final repo = _empty();
      final c = await _pumpForm(tester, repo);
      c.selectCatalogAsset('ast_vwce');
      await _type(tester, 'Quantity', 'abc');
      await _type(tester, 'Unit price', '-3');
      await _type(tester, 'Commission (optional)', '-1');
      c.submit();
      await tester.pump();
      expect(find.text('Enter a valid number.'), findsOneWidget);
      expect(find.text('It must be greater than zero.'), findsNWidgets(2));
      await _type(tester, 'Quantity', '2,5');
      await _type(tester, 'Unit price', '100.5');
      await _type(tester, 'Commission (optional)', '');
      expect(c.submit(), isTrue);
      expect(repo.holdings.single.quantity, 2.5);
    });

    testWidgets('a buy over the liquidity: allowed, with a warning', (
      tester,
    ) async {
      final repo = _empty();
      final c = await _pumpForm(tester, repo);
      c.selectCatalogAsset('ast_vwce');
      await _type(tester, 'Quantity', '1000');
      await _type(tester, 'Unit price', '100');
      expect(
        find.textContaining('more than your available liquidity'),
        findsOneWidget,
      );
      expect(c.submit(), isTrue);
      expect(repo.liquidity, lessThan(0));
    });

    testWidgets('a sell: what is held, and refusing more than that', (
      tester,
    ) async {
      final repo = _empty();
      repo.addMovement(
        MovementDraft(
          type: MovementType.buy,
          assetId: 'ast_vwce',
          date: DateTime(2026, 3, 2),
          quantity: 10,
          price: 100,
        ),
      );
      final id = repo.holdings.single.id;
      final c = await _pumpForm(
        tester,
        repo,
        type: MovementType.sell,
        holdingId: id,
      );
      expect(find.text('You hold 10'), findsOneWidget);
      await _type(tester, 'Quantity', '11');
      await _type(tester, 'Unit price', '120');
      expect(c.submit(), isFalse);
      await tester.pump();
      expect(
        find.textContaining('you would hold less than zero'),
        findsOneWidget,
      );
      expect(repo.holdings.single.quantity, 10);
      await _type(tester, 'Quantity', '4');
      expect(c.submit(), isTrue);
      expect(repo.holdings.single.quantity, 6);
    });

    testWidgets('a dividend can be in the future; the others cannot', (
      tester,
    ) async {
      final repo = _empty();
      repo.addMovement(
        MovementDraft(
          type: MovementType.buy,
          assetId: 'ast_vwce',
          date: DateTime(2026, 3, 2),
          quantity: 1,
          price: 100,
        ),
      );
      final id = repo.holdings.single.id;
      final c = await _pumpForm(
        tester,
        repo,
        type: MovementType.dividend,
        holdingId: id,
      );
      expect(find.text('Net amount'), findsOneWidget);
      c.setDate(DateTime(2026, 12, 1));
      await _type(tester, 'Net amount', '5');
      expect(c.submit(), isTrue);
      expect(repo.expectedDividends.single.amount, 5);
      final cost = MovementFormController(repo, type: MovementType.cost);
      addTearDown(cost.dispose);
      cost.setDate(DateTime(2026, 12, 1));
      cost.amount.text = '5';
      cost.description.text = 'x';
      expect(cost.submit(), isFalse);
      expect(cost.dateError, FieldError.future);
    });

    testWidgets('a cost: asset optional, description required', (tester) async {
      final repo = _empty();
      final c = await _pumpForm(tester, repo, type: MovementType.cost);
      expect(find.text('Asset (optional)'), findsOneWidget);
      await _type(tester, 'Amount', '12');
      expect(c.submit(), isFalse);
      await tester.pump();
      expect(find.text('Required.'), findsOneWidget);
      await _type(tester, 'Description', 'Stamp duty');
      expect(c.submit(), isTrue);
      expect(repo.movements().single.description, 'Stamp duty');
    });

    testWidgets('a manual asset: name and kind', (tester) async {
      final repo = _empty();
      final c = await _pumpForm(tester, repo);
      await tester.tap(find.text('Manual asset'));
      await tester.pump();
      expect(find.text('Kind of asset'), findsOneWidget);
      await _type(tester, 'Name', 'Old watch');
      await _type(tester, 'Quantity', '1');
      await _type(tester, 'Unit price', '900');
      expect(c.submit(), isTrue);
      expect(repo.holdings.single.manualName, 'Old watch');
    });

    testWidgets('changing the type keeps the asset where it makes sense', (
      tester,
    ) async {
      final repo = _empty();
      repo.addMovement(
        MovementDraft(
          type: MovementType.buy,
          assetId: 'ast_vwce',
          date: DateTime(2026, 3, 2),
          quantity: 1,
          price: 100,
        ),
      );
      final id = repo.holdings.single.id;
      final c = await _pumpForm(
        tester,
        repo,
        type: MovementType.sell,
        holdingId: id,
      );
      c.selectType(MovementType.buy);
      expect(c.assetId, 'ast_vwce');
      c.selectType(MovementType.dividend);
      expect(c.holdingId, id);
    });

    testWidgets('dark mode and a dollar asset', (tester) async {
      final repo = _empty();
      repo.addMovement(
        MovementDraft(
          type: MovementType.buy,
          assetId: 'ast_aapl',
          date: DateTime(2026, 3, 2),
          quantity: 1,
          price: 100,
        ),
      );
      await _pumpForm(
        tester,
        repo,
        type: MovementType.sell,
        holdingId: repo.holdings.single.id,
        brightness: Brightness.dark,
      );
      expect(find.text(r'$'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  });

  group('the page of a movement', () {
    Future<_H> open(
      WidgetTester tester,
      String holdingId,
      MovementType type, {
      MockRepository? repo,
    }) async {
      final h = await _pump(tester, repository: repo);
      h.controller.setMovementFilter(
        MovementFilter(
          period: MovementPeriod.all,
          holdingId: holdingId,
          types: {type},
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(SossoldiMovementItem).first);
      await tester.pumpAndSettle();
      return h;
    }

    testWidgets('read-only: type, asset, account, date, numbers, total', (
      tester,
    ) async {
      final h = await open(tester, 'hld_vwce', MovementType.buy);
      expect(find.byType(MovementDetailScreen), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete movement'), findsNothing);
      final m = h.repo
          .movementList(
            MovementFilter(
              period: MovementPeriod.all,
              holdingId: 'hld_vwce',
              types: {MovementType.buy},
            ),
          )
          .days
          .first
          .entries
          .first
          .movement;
      for (final l in [
        'Type',
        'Asset',
        'Broker account',
        'Date',
        'Quantity',
        'Unit price',
        'Commission',
        'Total',
      ]) {
        expect(find.text(l), findsOneWidget, reason: l);
      }
      expect(find.text('Vanguard FTSE All-World UCITS ETF Acc'), findsWidgets);
      expect(h.repo.movement(m.id).type, MovementType.buy);
    });

    testWidgets('the asset opens its position', (tester) async {
      await open(tester, 'hld_vwce', MovementType.buy);
      await tester.tap(find.text('Vanguard FTSE All-World UCITS ETF Acc').last);
      await tester.pumpAndSettle();
      expect(find.byType(PositionDetailScreen), findsOneWidget);
    });

    testWidgets('Edit: fields, a new price is saved with Done', (tester) async {
      final h = await open(tester, 'hld_vwce', MovementType.buy);
      final id = h.repo
          .movementList(
            MovementFilter(
              period: MovementPeriod.all,
              holdingId: 'hld_vwce',
              types: {MovementType.buy},
            ),
          )
          .days
          .first
          .entries
          .first
          .movement
          .id;
      final before = h.repo.movement(id);
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete movement'), findsOneWidget);
      // The type and the asset do not change: no type tabs, no asset picker.
      expect(find.byType(SossoldiTabNavigation), findsNothing);
      expect(find.byType(SossoldiSearchField), findsNothing);
      await _type(tester, 'Unit price', '200');
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(h.repo.movement(id).price, 200);
      expect(h.repo.movement(id).amount, closeTo(before.quantity! * 200, 0.01));
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('Edit: an invalid value stays in edit mode with the error', (
      tester,
    ) async {
      final h = await open(tester, 'hld_vwce', MovementType.buy);
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await _type(tester, 'Quantity', '0');
      await tester.tap(find.text('Done'));
      await tester.pump();
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('It must be greater than zero.'), findsOneWidget);
      expect(h.repo.holding('hld_vwce').quantity, isNot(0));
    });

    testWidgets('Cancel forgets what was typed', (tester) async {
      final h = await open(tester, 'hld_vwce', MovementType.buy);
      final q = h.repo.holding('hld_vwce').quantity;
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await _type(tester, 'Quantity', '999');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(h.repo.holding('hld_vwce').quantity, q);
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('Delete asks first; Cancel keeps it', (tester) async {
      final repo = _empty();
      final h = await _pump(tester, repository: repo);
      final id = repo
          .addMovement(
            MovementDraft(
              type: MovementType.buy,
              assetId: 'ast_vwce',
              date: DateTime(2026, 3, 2),
              quantity: 2,
              price: 100,
            ),
          )
          .movementId!;
      await tester.pump();
      await tester.tap(find.byType(SossoldiMovementItem).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Delete movement'));
      await tester.tap(find.text('Delete movement'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this movement?'), findsOneWidget);
      await tester.tap(find.text('Cancel').last);
      await tester.pumpAndSettle();
      expect(h.repo.movements().any((m) => m.id == id), isTrue);
    });

    testWidgets('Delete: back to the list, the position goes', (tester) async {
      final repo = _empty();
      final h = await _pump(tester, repository: repo);
      repo.addMovement(
        MovementDraft(
          type: MovementType.buy,
          assetId: 'ast_vwce',
          date: DateTime(2026, 3, 2),
          quantity: 2,
          price: 100,
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(SossoldiMovementItem).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Delete movement'));
      await tester.tap(find.text('Delete movement'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();
      expect(find.byType(MovementDetailScreen), findsNothing);
      expect(h.repo.holdings, isEmpty);
      expect(find.byType(SossoldiMovementItem), findsNothing);
    });

    testWidgets('Delete refused when a sell needs the buy: a clear message', (
      tester,
    ) async {
      final repo = _empty();
      final h = await _pump(tester, repository: repo);
      repo.addMovement(
        MovementDraft(
          type: MovementType.buy,
          assetId: 'ast_vwce',
          date: DateTime(2026, 3, 2),
          quantity: 2,
          price: 100,
        ),
      );
      repo.addMovement(
        MovementDraft(
          type: MovementType.sell,
          holdingId: repo.holdings.single.id,
          date: DateTime(2026, 4, 2),
          quantity: 2,
          price: 110,
        ),
      );
      h.controller.setMovementFilter(
        const MovementFilter(period: MovementPeriod.all),
      );
      await tester.pump();
      // The buy is the older one: the last row.
      await tester.tap(find.byType(SossoldiMovementItem).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Delete movement'));
      await tester.tap(find.text('Delete movement'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this movement?'), findsNothing);
      expect(
        find.textContaining('you would hold less than zero'),
        findsOneWidget,
      );
      expect(repo.movements().length, 2);
    });

    testWidgets('a dividend and a cost; hidden amounts', (tester) async {
      final repo = _empty();
      final h = await _pump(tester, repository: repo);
      repo.addMovement(
        MovementDraft(
          type: MovementType.cost,
          date: DateTime(2026, 6, 2),
          amount: 12,
          description: 'Custody',
        ),
      );
      await tester.pump();
      await tester.tap(find.byType(SossoldiMovementItem).first);
      await tester.pumpAndSettle();
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Custody'), findsWidgets);
      expect(find.text('-€12.00'), findsOneWidget);
      h.state.toggleHideAmounts();
      await tester.pump();
      expect(find.text('-€12.00'), findsNothing);
    });

    testWidgets('Italian, dark', (tester) async {
      final h = await _pump(
        tester,
        locale: const Locale('it'),
        brightness: Brightness.dark,
      );
      await tester.tap(find.byType(SossoldiMovementItem).first);
      await tester.pumpAndSettle();
      expect(find.text('Modifica'), findsOneWidget);
      await tester.tap(find.text('Modifica'));
      await tester.pumpAndSettle();
      expect(find.text('Elimina movimento'), findsOneWidget);
      expect(h.repo, isNotNull);
      expect(tester.takeException(), isNull);
    });
  });

  group('the position page opens the form', () {
    Future<_H> pumpPositions(WidgetTester tester) async {
      final h = await _pump(tester);
      h.controller.selectTab(InvestmentsTab.positions);
      await tester.pump();
      return h;
    }

    testWidgets('Buy and Sell: the form with the asset chosen', (tester) async {
      await pumpPositions(tester);
      await tester.tap(
        find.widgetWithText(SossoldiAssetItem, 'APPLE INC.').first,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(SossoldiButton, 'Buy'));
      await tester.tap(find.widgetWithText(SossoldiButton, 'Buy'));
      await tester.pumpAndSettle();
      expect(find.text('New movement'), findsOneWidget);
      expect(find.text('Apple Inc.'), findsWidgets);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(SossoldiButton, 'Sell'));
      await tester.pumpAndSettle();
      expect(find.text('New movement'), findsOneWidget);
      expect(find.textContaining('You hold'), findsOneWidget);
    });

    testWidgets('Add dividend is in the three dots, with the asset chosen', (
      tester,
    ) async {
      await pumpPositions(tester);
      await tester.tap(
        find.widgetWithText(SossoldiAssetItem, 'APPLE INC.').first,
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.bySemanticsLabel('More actions'));
      await tester.tap(find.bySemanticsLabel('More actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add dividend'));
      await tester.pumpAndSettle();
      expect(find.text('New movement'), findsOneWidget);
      expect(find.text('Net amount'), findsOneWidget);
    });

    testWidgets('selling everything closes the position and leaves its page', (
      tester,
    ) async {
      final repo = _empty();
      repo.addMovement(
        MovementDraft(
          type: MovementType.buy,
          assetId: 'ast_vwce',
          date: DateTime(2026, 3, 2),
          quantity: 4,
          price: 100,
        ),
      );
      final h = await _pump(tester, repository: repo);
      h.controller.selectTab(InvestmentsTab.positions);
      await tester.pump();
      await tester.tap(find.byType(SossoldiAssetItem).first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(SossoldiButton, 'Sell'));
      await tester.pumpAndSettle();
      await tester.enterText(_field('Quantity'), '4');
      await tester.enterText(_field('Unit price'), '110');
      await tester.pump();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(repo.holdings, isEmpty);
      expect(find.byType(PositionDetailScreen), findsNothing);
    });
  });

  group('the "+" of the bar', () {
    Future<void> pumpApp(WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.localeTestValue = const Locale('en');
      tester.platformDispatcher.localesTestValue = [const Locale('en')];
      addTearDown(() {
        tester.view.reset();
        tester.platformDispatcher.clearAllTestValues();
      });
      await tester.pumpWidget(
        SossoldiApp(
          state: AppState(repository: MockRepository(now: _now)),
        ),
      );
      await tester.pump();
    }

    testWidgets('in Investments it opens the form of a buy', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Investments'));
      await tester.pump();
      for (final tab in ['Overview', 'Positions', 'Movements']) {
        await tester.tap(find.text(tab).first);
        await tester.pump();
        await tester.tap(find.bySemanticsLabel('Add transaction'));
        await tester.pumpAndSettle();
        expect(find.text('New movement'), findsOneWidget, reason: tab);
        expect(find.byType(PlaceholderScreen), findsNothing);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      }
      // A buy is what is selected.
      await tester.tap(find.bySemanticsLabel('Add transaction'));
      await tester.pumpAndSettle();
      expect(find.text('Quantity'), findsOneWidget);
      expect(find.text('Unit price'), findsOneWidget);
    });

    testWidgets('elsewhere it is still the placeholder', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.bySemanticsLabel('Add transaction'));
      await tester.pumpAndSettle();
      expect(find.byType(PlaceholderScreen), findsOneWidget);
      expect(find.text('New movement'), findsNothing);
    });
  });
}
