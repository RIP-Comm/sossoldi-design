import 'package:flutter_test/flutter_test.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/transaction_filter.dart';
import 'package:sossoldi/mock/models/transaction_time_range.dart';

void main() {
  final now = DateTime(2026, 10, 22, 10);
  late MockRepository eur;
  late MockRepository usd;

  setUp(() {
    eur = MockRepository(now: now);
    usd = MockRepository(now: now)..setMainCurrency('USD');
  });

  // EUR per USD, as the repository converts it.
  double rate() => eur.toEur(1, 'USD');

  test('EUR is the default and the supported ones have a rate', () {
    expect(eur.mainCurrency, 'EUR');
    expect(eur.supportedCurrencies, [
      'EUR',
      'USD',
      'GBP',
      'CHF',
      'BRL',
      'AED',
      'JPY',
      'CAD',
    ]);
  });

  test('toMain converts through EUR in every direction', () {
    expect(usd.toMain(100, 'USD'), 100);
    expect(usd.toMain(100, 'EUR'), closeTo(100 / rate(), 1e-9));
    expect(
      usd.toMain(100, 'GBP'),
      closeTo(eur.toEur(100, 'GBP') / rate(), 1e-9),
    );
    expect(eur.toMain(100, 'USD'), closeTo(100 * rate(), 1e-9));
    expect(eur.toMain(100, 'EUR'), 100);
    for (final c in eur.supportedCurrencies) {
      final back = (MockRepository(now: now)..setMainCurrency(c));
      expect(back.toMain(1, c), 1);
    }
  });

  test('an unknown currency is ignored', () {
    usd.setMainCurrency('XXX');
    expect(usd.mainCurrency, 'USD');
  });

  test('listeners hear about a change, once, and not about the same value', () {
    var calls = 0;
    eur.addListener(() => calls++);
    eur.setMainCurrency('GBP');
    eur.setMainCurrency('GBP');
    expect(calls, 1);
    expect(eur.mainCurrency, 'GBP');
  });

  test('balances, totals and the trend follow the main currency', () {
    expect(usd.totalBalance, closeTo(eur.totalBalance / rate(), 0.05));
    final a = eur.balanceTrend();
    final b = usd.balanceTrend();
    expect(a.currency, 'EUR');
    expect(b.currency, 'USD');
    expect(b.net, closeTo(a.net / rate(), 0.05));
    expect(b.income, closeTo(a.income / rate(), 0.05));
  });

  test('the list totals per day are converted', () {
    final f = TransactionFilter.forMonthOf(now);
    final a = eur.searchTransactions(f);
    final b = usd.searchTransactions(f);
    expect(b.total, a.total);
    for (final e in a.netByDay.entries) {
      expect(b.netByDay[e.key]!, closeTo(e.value / rate(), 0.02));
    }
  });

  test('the amount filter compares in the main currency', () {
    const f = TransactionFilter();
    // 50..200 EUR is a different set of transactions than 50..200 USD.
    final inEur = eur.searchTransactions(f.withAmountRange(50, 200)).total;
    final inUsd = usd.searchTransactions(f.withAmountRange(50, 200)).total;
    expect(inEur, isNot(inUsd));
    final scaled = eur
        .searchTransactions(f.withAmountRange(50 * rate(), 200 * rate()))
        .total;
    expect(inUsd, scaled);
  });

  test('breakdown: total, categories and buckets stay consistent', () {
    for (final range in TransactionTimeRange.values) {
      final a = eur.transactionBreakdown(
        range: range,
        kind: TransactionKind.expense,
      );
      final b = usd.transactionBreakdown(
        range: range,
        kind: TransactionKind.expense,
      );
      // Each transaction is rounded to the cent, so a little drift is normal.
      expect(b.total, closeTo(a.total / rate(), 2), reason: '$range');
      expect(
        b.categories.fold(0.0, (s, c) => s + c.amount),
        closeTo(b.total, 0.05),
      );
      expect(
        b.buckets.fold(0.0, (s, x) => s + x.total),
        closeTo(b.total, 0.05),
      );
    }
  });

  test('holdings are valued in the main currency', () {
    final h = eur.holdings.first;
    expect(
      usd.holdingValue(h.id),
      closeTo(eur.holdingValue(h.id) / rate(), 0.05),
    );
  });
}
