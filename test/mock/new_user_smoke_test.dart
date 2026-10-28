import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/tokens/category_colors.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/account_edit.dart';
import 'package:sossoldi/mock/models/budget.dart';
import 'package:sossoldi/mock/models/category.dart';
import 'package:sossoldi/mock/models/category_edit.dart';
import 'package:sossoldi/mock/models/investment_movement.dart';
import 'package:sossoldi/mock/models/movement_edit.dart';
import 'package:sossoldi/mock/models/portfolio.dart';
import 'package:sossoldi/mock/models/transaction_filter.dart';
import 'package:sossoldi/mock/models/transaction_time_range.dart';

final _now = DateTime(2026, 10, 22, 10);

/// Every read the screens make, on a repository: none may throw or return a
/// number that is not finite.
void _runEveryRead(MockRepository repo) {
  bool finite(num v) => v.isFinite;
  expect(finite(repo.totalBalance), isTrue);
  expect(finite(repo.netWorth), isTrue);
  expect(finite(repo.portfolioValue), isTrue);
  expect(finite(repo.liquidity), isTrue);
  repo.accountsWithChange();
  final trend = repo.balanceTrend();
  expect(finite(trend.income), isTrue);
  expect(finite(trend.vsPreviousSameDay), isTrue);
  repo.latestTransactions(8);
  repo.financeDigest();
  repo.upcomingRecurrencesThisMonth();
  final flow = repo.cashFlow();
  expect(
    [...flow.income, ...flow.expenses, ...flow.balance].every(finite),
    isTrue,
  );
  for (final s in repo.monthBudgets()) {
    expect(finite(s.usage), isTrue);
  }
  for (final p in BudgetPeriod.values) {
    final o = repo.budgetOverview(p);
    expect(finite(o.usage), isTrue);
    expect(finite(o.overallUsage), isTrue);
    for (final b in o.items) {
      expect(finite(b.usage), isTrue);
    }
  }
  repo.searchTransactions(const TransactionFilter());
  for (final range in TransactionTimeRange.values) {
    for (final kind in TransactionKind.values) {
      final b = repo.transactionBreakdown(
        range: range,
        kind: kind,
        accountIds: const {},
        categoryIds: const {},
        granularity: TransactionGranularity.weekly,
      );
      expect(finite(b.total), isTrue);
    }
  }
  for (var m = 1; m <= 12; m++) {
    repo.recurringOccurrences(2026, m);
    repo.recurringDayTypes(2026, m);
  }
  final summary = repo.portfolioSummary();
  expect(finite(summary.gainPercent), isTrue);
  expect(finite(summary.totalValue), isTrue);
  for (final p in ValuePeriod.values) {
    final s = repo.marketValueSeries(p);
    for (final pt in s.points) {
      expect(finite(pt.value) && finite(pt.invested), isTrue);
    }
  }
  for (final m in AllocationMode.values) {
    for (final slice in repo.assetAllocation(m)) {
      expect(finite(slice.share), isTrue);
    }
  }
  repo.investmentDigest();
  for (final p in repo.searchPositions()) {
    expect(finite(p.gainPercent), isTrue);
    expect(finite(p.weight), isTrue);
    final d = repo.positionDetail(p.holdingId);
    expect(finite(d.price ?? 0), isTrue);
    for (final period in ValuePeriod.values) {
      repo.priceSeries(p.holdingId, period);
    }
  }
  for (final by in BreakdownBy.values) {
    for (final row in repo.portfolioBreakdown(by)) {
      expect(finite(row.share), isTrue);
    }
  }
  final list = repo.movementList(const MovementFilter());
  for (final day in list.days) {
    for (final e in day.entries) {
      expect(finite(e.total), isTrue);
    }
  }
  for (final p in MovementPeriod.values) {
    repo.movementList(MovementFilter(period: p));
  }
  repo.movementAssets();
  repo.brokerAccounts;
}

void main() {
  test('a new user with nothing: every read works', () {
    _runEveryRead(MockRepository.newUser(now: _now));
  });

  test('a new user with accounts only', () {
    final repo = MockRepository.newUser(now: _now);
    repo.addAccount(
      AccountDraft(
        name: 'Checking',
        initialBalance: 0,
        currency: 'EUR',
        color: CategoryColors.all.first,
        icon: PhosphorIconsRegular.bank,
      ),
    );
    _runEveryRead(repo);
  });

  test('a new user with categories, budgets and assets', () {
    final repo = MockRepository.newUser(now: _now);
    repo.addAccount(
      AccountDraft(
        name: 'Checking',
        initialBalance: 1200,
        currency: 'EUR',
        color: CategoryColors.all.first,
        icon: PhosphorIconsRegular.bank,
      ),
    );
    repo.addCategory(
      CategorySave(
        category: CategoryDraft(
          type: CategoryType.expense,
          name: 'Housing',
          icon: PhosphorIconsRegular.house,
          color: const CategoryColor(Color(0xFF000000), Color(0xFFFFFFFF)),
        ),
        budgets: [
          for (final p in BudgetPeriod.values)
            BudgetDraft(
              period: p,
              amount: 100,
              countForOverall: p.index.isEven,
            ),
        ],
      ),
    );
    final etf = repo.assetCatalog.first;
    repo.addOpeningAsset(assetId: etf.id, quantity: 0.00000001, averageCost: 1);
    repo.addOpeningAsset(manualName: 'Painting', quantity: 1, averageCost: 5);
    // An asset in another currency than the main one.
    final usd = repo.assetCatalog.firstWhere((a) => a.currency != 'EUR');
    repo.addOpeningAsset(assetId: usd.id, quantity: 123456.78, averageCost: 12);
    _runEveryRead(repo);
  });

  test(
    'the form of a movement works for a new user with an ordinary account',
    () {
      final repo = MockRepository.newUser(now: _now);
      repo.addAccount(
        AccountDraft(
          name: 'Checking',
          initialBalance: 1000,
          currency: 'EUR',
          color: CategoryColors.all.first,
          icon: PhosphorIconsRegular.bank,
        ),
      );
      // No broker account: any account can be picked.
      expect(repo.brokerAccounts.single.name, 'Checking');
      final etf = repo.assetCatalog.first;
      final draft = MovementDraft(
        type: MovementType.buy,
        date: repo.today,
        assetId: etf.id,
        quantity: 2,
        price: 100,
        fee: 1,
      );
      expect(repo.liquidityAfter(draft), isNotNull);
      expect(repo.addMovement(draft).ok, isTrue);
      expect(repo.holdings.single.quantity, 2);
      _runEveryRead(repo);
    },
  );
}
