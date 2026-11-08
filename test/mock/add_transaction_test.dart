import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/tokens/category_colors.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/account_edit.dart';
import 'package:sossoldi/mock/models/category.dart';
import 'package:sossoldi/mock/models/category_edit.dart';
import 'package:sossoldi/mock/models/recurring_transaction.dart';
import 'package:sossoldi/mock/models/transaction.dart';
import 'package:sossoldi/mock/models/transaction_edit.dart';

final _now = DateTime(2026, 10, 22, 10);
final _today = DateTime(2026, 10, 22);

AccountDraft _account(
  String name, {
  String currency = 'EUR',
  bool main = false,
}) => AccountDraft(
  name: name,
  initialBalance: 100,
  currency: currency,
  color: CategoryColors.all[3],
  icon: PhosphorIconsRegular.bank,
  isMain: main,
);

CategorySave _cat(String name) => CategorySave(
  category: CategoryDraft(
    type: CategoryType.expense,
    name: name,
    icon: PhosphorIconsRegular.tag,
    color: CategoryColors.all.first,
  ),
);

void main() {
  group('main account', () {
    late MockRepository repo;
    setUp(() => repo = MockRepository.newUser(now: _now));

    test('the demo has exactly one, the first', () {
      final demo = MockRepository(now: _now);
      expect(demo.accounts.where((a) => a.isMain), hasLength(1));
      expect(demo.mainAccount, demo.accounts.first);
    });

    test('the first account created is main', () {
      final a = repo.addAccount(_account('One')).account!;
      final b = repo.addAccount(_account('Two')).account!;
      expect(a.isMain, isTrue);
      expect(b.isMain, isFalse);
      expect(repo.mainAccount!.id, a.id);
    });

    test('setting another takes the flag from the previous one', () {
      final a = repo.addAccount(_account('One')).account!;
      final b = repo.addAccount(_account('Two', main: true)).account!;
      expect(repo.account(a.id).isMain, isFalse);
      expect(repo.account(b.id).isMain, isTrue);
      repo.setMainAccount(a.id);
      expect(repo.accounts.where((x) => x.isMain).single.id, a.id);
    });

    test('editing the main account cannot turn the flag off', () {
      final a = repo.addAccount(_account('One')).account!;
      repo.updateAccount(a.id, _account('One', main: false));
      expect(repo.account(a.id).isMain, isTrue);
    });

    test('deleting the main account makes the first left main', () {
      final a = repo.addAccount(_account('One')).account!;
      final b = repo.addAccount(_account('Two')).account!;
      repo.addAccount(_account('Three'));
      repo.deleteAccount(a.id);
      expect(repo.mainAccount!.id, b.id);
      expect(repo.accounts.where((x) => x.isMain), hasLength(1));
    });
  });

  group('adding a transaction', () {
    late MockRepository repo;
    late String eur;
    late String eur2;
    late String usd;
    late String groceries;
    setUp(() {
      repo = MockRepository(now: _now);
      eur = repo.accounts[0].id;
      eur2 = repo.accounts[1].id;
      usd = repo.addAccount(_account('Dollars', currency: 'USD')).account!.id;
      groceries = repo.categories(type: CategoryType.expense).first.id;
    });

    TransactionDraft expense({double amount = 10, DateTime? date}) =>
        TransactionDraft(
          type: TransactionType.expense,
          amount: amount,
          accountId: eur,
          date: date ?? _today,
          categoryId: groceries,
          description: 'Test shop',
        );

    test('an expense lowers the balance, shows in lists and notifies', () {
      final before = repo.accountBalance(eur);
      final month = repo.totalExpenses(DateTime(2026, 10), DateTime(2026, 11));
      var notified = 0;
      repo.addListener(() => notified++);
      final r = repo.addTransaction(expense(amount: 12.5));
      expect(r.ok, isTrue);
      expect(notified, 1);
      expect(repo.accountBalance(eur), before - 12.5);
      expect(
        repo.totalExpenses(DateTime(2026, 10), DateTime(2026, 11)),
        month + 12.5,
      );
      expect(repo.transactions.first.id, r.added!.transactionId);
    });

    test('an income raises the balance', () {
      final before = repo.accountBalance(eur);
      final income = repo.categories(type: CategoryType.income).first.id;
      repo.addTransaction(
        TransactionDraft(
          type: TransactionType.income,
          amount: 50,
          accountId: eur,
          date: _today,
          categoryId: income,
        ),
      );
      expect(repo.accountBalance(eur), before + 50);
    });

    test('keeps the list in date order for a past date', () {
      repo.addTransaction(
        expense(date: _today.subtract(const Duration(days: 40))),
      );
      final dates = repo.transactions.map((t) => t.date).toList();
      for (var i = 1; i < dates.length; i++) {
        expect(dates[i - 1].isBefore(dates[i]), isFalse);
      }
    });

    test('refuses wrong data and changes nothing', () {
      var notified = 0;
      repo.addListener(() => notified++);
      final count = repo.transactions.length;
      expect(
        repo.addTransaction(expense(amount: 0)).failure,
        TransactionFailure.invalidAmount,
      );
      expect(
        repo
            .addTransaction(expense(date: _today.add(const Duration(days: 1))))
            .failure,
        TransactionFailure.futureDate,
      );
      expect(
        repo
            .addTransaction(
              TransactionDraft(
                type: TransactionType.expense,
                amount: 1,
                accountId: eur,
                date: _today,
              ),
            )
            .failure,
        TransactionFailure.invalidCategory,
      );
      final income = repo.categories(type: CategoryType.income).first.id;
      expect(
        repo
            .addTransaction(
              TransactionDraft(
                type: TransactionType.expense,
                amount: 1,
                accountId: eur,
                date: _today,
                categoryId: income,
              ),
            )
            .failure,
        TransactionFailure.invalidCategory,
      );
      expect(
        repo
            .addTransaction(
              TransactionDraft(
                type: TransactionType.transfer,
                amount: 1,
                accountId: eur,
                toAccountId: eur,
                date: _today,
              ),
            )
            .failure,
        TransactionFailure.sameAccount,
      );
      expect(notified, 0);
      expect(repo.transactions, hasLength(count));
    });

    test('a transfer moves money between accounts, same currency', () {
      final a = repo.accountBalance(eur);
      final b = repo.accountBalance(eur2);
      final total = repo.totalBalance;
      repo.addTransaction(
        TransactionDraft(
          type: TransactionType.transfer,
          amount: 40,
          accountId: eur,
          toAccountId: eur2,
          date: _today,
        ),
      );
      expect(repo.accountBalance(eur), a - 40);
      expect(repo.accountBalance(eur2), b + 40);
      expect(repo.totalBalance, total);
    });

    test(
      'a transfer between currencies proposes and keeps the amount received',
      () {
        final proposed = repo.convert(100, 'EUR', 'USD');
        expect(proposed, isNot(100));
        final r = repo.addTransaction(
          TransactionDraft(
            type: TransactionType.transfer,
            amount: 100,
            accountId: eur,
            toAccountId: usd,
            date: _today,
          ),
        );
        expect(repo.transaction(r.added!.transactionId!).toAmount, proposed);
        expect(repo.accountBalance(usd), 100 + proposed);
        // The user edited the amount received.
        repo.addTransaction(
          TransactionDraft(
            type: TransactionType.transfer,
            amount: 100,
            accountId: eur,
            toAccountId: usd,
            toAmount: 120,
            date: _today,
          ),
        );
        expect(repo.accountBalance(usd), 100 + proposed + 120);
      },
    );

    test('convert goes through the rates both ways', () {
      expect(repo.convert(10, 'EUR', 'EUR'), 10);
      final usdAmount = repo.convert(100, 'EUR', 'USD');
      expect(
        (repo.convert(usdAmount, 'USD', 'EUR') - 100).abs(),
        lessThan(0.05),
      );
    });

    test('undo takes back the transaction', () {
      final before = repo.accountBalance(eur);
      final count = repo.transactions.length;
      final r = repo.addTransaction(expense());
      repo.undoAdded(r.added!);
      expect(repo.accountBalance(eur), before);
      expect(repo.transactions, hasLength(count));
    });

    group('recurring', () {
      TransactionDraft recurring(
        DateTime start, {
        RecurrenceEnd end = RecurrenceEnd.never,
        DateTime? endDate,
        int? count,
      }) => TransactionDraft(
        type: TransactionType.expense,
        amount: 9.99,
        accountId: eur,
        date: _today,
        categoryId: groceries,
        description: 'Streaming',
        recurrence: RecurrenceDraft(
          frequency: RecurrenceFrequency.monthly,
          startDate: start,
          end: end,
          endDate: endDate,
          count: count,
        ),
      );

      test(
        'starting today creates the recurrence and the first transaction',
        () {
          final r = repo.addTransaction(recurring(_today));
          final rec = repo.recurring(r.added!.recurringId!);
          expect(r.added!.transactionId, isNotNull);
          expect(repo.transaction(r.added!.transactionId!).recurringId, rec.id);
          expect(rec.nextDate, DateTime(2026, 11, 22));
          expect(rec.status, RecurringStatus.active);
        },
      );

      test('starting in the future creates only the planned recurrence', () {
        final balance = repo.accountBalance(eur);
        final r = repo.addTransaction(recurring(DateTime(2026, 11, 5)));
        expect(r.added!.transactionId, isNull);
        expect(repo.accountBalance(eur), balance);
        expect(
          repo.recurring(r.added!.recurringId!).nextDate,
          DateTime(2026, 11, 5),
        );
        final planned = repo
            .recurringOccurrences(2026, 11)
            .where((o) => o.recurringId == r.added!.recurringId);
        expect(planned.single.date, DateTime(2026, 11, 5));
      });

      test('starting in the past creates the first and plans the next', () {
        final r = repo.addTransaction(recurring(DateTime(2026, 10, 3)));
        expect(
          repo.transaction(r.added!.transactionId!).date,
          DateTime(2026, 10, 3),
        );
        expect(
          repo.recurring(r.added!.recurringId!).nextDate,
          DateTime(2026, 11, 3),
        );
      });

      test('ends after N times and on a date', () {
        final a = repo.addTransaction(
          recurring(
            DateTime(2026, 11, 5),
            end: RecurrenceEnd.afterCount,
            count: 2,
          ),
        );
        final id = a.added!.recurringId!;
        expect(repo.recurring(id).endDate, DateTime(2026, 12, 5));
        bool has(int y, int m) =>
            repo.recurringOccurrences(y, m).any((o) => o.recurringId == id);
        expect(has(2026, 11), isTrue);
        expect(has(2026, 12), isTrue);
        expect(has(2027, 1), isFalse);

        final b = repo.addTransaction(
          recurring(
            DateTime(2026, 11, 5),
            end: RecurrenceEnd.onDate,
            endDate: DateTime(2026, 11, 30),
          ),
        );
        final idB = b.added!.recurringId!;
        expect(
          repo.recurringOccurrences(2026, 12).any((o) => o.recurringId == idB),
          isFalse,
        );
      });

      test('an end before the start is refused', () {
        expect(
          repo
              .addTransaction(
                recurring(
                  DateTime(2026, 11, 5),
                  end: RecurrenceEnd.onDate,
                  endDate: DateTime(2026, 11, 1),
                ),
              )
              .failure,
          TransactionFailure.invalidEnd,
        );
      });

      test('undo removes the transaction and the recurrence', () {
        final recs = repo.recurringTransactions().length;
        final txs = repo.transactions.length;
        final r = repo.addTransaction(recurring(_today));
        repo.undoAdded(r.added!);
        expect(repo.recurringTransactions(), hasLength(recs));
        expect(repo.transactions, hasLength(txs));
      });
    });
  });

  group('updating a transaction', () {
    late MockRepository repo;
    late String eur;
    late String eur2;
    setUp(() {
      repo = MockRepository(now: _now);
      eur = repo.accounts[0].id;
      eur2 = repo.accounts[1].id;
    });

    TransactionDraft draft(Transaction t, {double? amount, String? account}) =>
        TransactionDraft(
          type: t.type,
          amount: amount ?? t.amount,
          accountId: account ?? t.accountId,
          date: t.date,
          toAccountId: t.toAccountId,
          categoryId: t.categoryId,
          subcategoryId: t.subcategoryId,
          description: t.description,
        );

    test(
      'a new amount moves the balance, back in time too, one notification',
      () {
        final t = repo.transactions.lastWhere(
          (t) => t.type == TransactionType.expense && t.accountId == eur,
        );
        final before = repo.accountBalance(eur);
        var notified = 0;
        repo.addListener(() => notified++);
        final r = repo.updateTransaction(t.id, draft(t, amount: t.amount + 10));
        expect(r.ok, isTrue);
        expect(notified, 1);
        expect(repo.accountBalance(eur), closeTo(before - 10, 0.001));
        expect(repo.transaction(t.id).amount, closeTo(t.amount + 10, 0.001));
      },
    );

    test('changing the account moves the money between accounts', () {
      final t = repo.transactions.lastWhere(
        (t) => t.type == TransactionType.expense && t.accountId == eur,
      );
      final a = repo.accountBalance(eur);
      final b = repo.accountBalance(eur2);
      repo.updateTransaction(t.id, draft(t, account: eur2));
      expect(repo.accountBalance(eur), closeTo(a + t.amount, 0.001));
      expect(repo.accountBalance(eur2), closeTo(b - t.amount, 0.001));
    });

    test('a new date keeps the list in order; the recurrence link stays', () {
      final t = repo.transactions.firstWhere((t) => t.recurringId != null);
      final moved = TransactionDraft(
        type: t.type,
        amount: t.amount,
        accountId: t.accountId,
        date: _today,
        categoryId: t.categoryId,
        description: t.description,
      );
      expect(repo.updateTransaction(t.id, moved).ok, isTrue);
      expect(repo.transaction(t.id).date, _today);
      expect(repo.transaction(t.id).recurringId, t.recurringId);
      final dates = repo.transactions.map((t) => t.date).toList();
      // Newest first.
      expect([...dates]..sort((a, b) => b.compareTo(a)), dates);
    });

    test('a refusal changes nothing: future date, no amount, unknown id', () {
      final t = repo.transactions.first;
      final before = repo.accountBalance(t.accountId);
      TransactionDraft with_({double? amount, DateTime? date}) =>
          TransactionDraft(
            type: t.type,
            amount: amount ?? t.amount,
            accountId: t.accountId,
            date: date ?? t.date,
            toAccountId: t.toAccountId,
            categoryId: t.categoryId,
            description: t.description,
          );
      expect(
        repo
            .updateTransaction(t.id, with_(date: DateTime(2026, 12, 1)))
            .failure,
        TransactionFailure.futureDate,
      );
      expect(
        repo.updateTransaction(t.id, with_(amount: 0)).failure,
        TransactionFailure.invalidAmount,
      );
      expect(
        repo.updateTransaction('nope', with_()).failure,
        TransactionFailure.notFound,
      );
      expect(repo.accountBalance(t.accountId), before);
    });

    test('a transfer cannot go to the same account', () {
      final t = repo.transactions.firstWhere(
        (t) => t.type == TransactionType.transfer,
      );
      final r = repo.updateTransaction(
        t.id,
        TransactionDraft(
          type: t.type,
          amount: t.amount,
          accountId: t.accountId,
          date: t.date,
          toAccountId: t.accountId,
        ),
      );
      expect(r.failure, TransactionFailure.sameAccount);
    });

    test('deleting a past transaction updates the balance', () {
      final t = repo.transactions.firstWhere(
        (t) => t.type == TransactionType.expense,
      );
      final before = repo.accountBalance(t.accountId);
      expect(repo.deleteTransaction(t.id), isTrue);
      expect(
        repo.accountBalance(t.accountId),
        closeTo(before + t.amount, 0.001),
      );
    });
  });

  group('suggestions', () {
    test('categories by use in the last 90 days, ties by creation order', () {
      final repo = MockRepository(now: _now);
      final order = repo.categories(type: CategoryType.expense);
      final ranked = repo.categoriesByUsage(CategoryType.expense);
      expect(ranked.map((c) => c.id).toSet(), order.map((c) => c.id).toSet());
      // Using the last one more than any other puts it first.
      final last = order.last;
      final acc = repo.accounts.first.id;
      for (var i = 0; i < 80; i++) {
        repo.addTransaction(
          TransactionDraft(
            type: TransactionType.expense,
            amount: 1,
            accountId: acc,
            date: _today,
            categoryId: last.id,
          ),
        );
      }
      expect(repo.categoriesByUsage(CategoryType.expense).first.id, last.id);
    });

    test('a new user gets the creation order', () {
      final repo = MockRepository.newUser(now: _now);
      repo.addAccount(_account('A'));
      for (final n in ['Zeta', 'Alpha', 'Mid']) {
        repo.addCategory(_cat(n));
      }
      expect(repo.categoriesByUsage(CategoryType.expense).map((c) => c.name), [
        'Zeta',
        'Alpha',
        'Mid',
      ]);
    });

    test('proposes the most frequent category of a description', () {
      final repo = MockRepository.newUser(now: _now);
      final acc = repo.addAccount(_account('A')).account!.id;
      final c1 = repo.addCategory(_cat('One')).category!.id;
      final c2 = repo.addCategory(_cat('Two')).category!.id;
      void add(String d, String c) => repo.addTransaction(
        TransactionDraft(
          type: TransactionType.expense,
          amount: 5,
          accountId: acc,
          date: _today,
          categoryId: c,
          description: d,
        ),
      );
      add('Corner Bar', c1);
      add('corner bar ', c2);
      add('Corner  Bar', c2);
      expect(
        repo.suggestCategory('  CORNER bar', CategoryType.expense)!.categoryId,
        c2,
      );
      expect(repo.suggestCategory('Nothing', CategoryType.expense), isNull);
      expect(repo.suggestCategory('', CategoryType.expense), isNull);
      expect(repo.suggestCategory('Corner Bar', CategoryType.income), isNull);
      // Past descriptions for autocomplete: at most 3, not the typed one.
      add('Corner Cafe', c1);
      add('Cornerstone', c1);
      add('Corn shop', c1);
      expect(repo.pastDescriptions('corn'), hasLength(3));
      expect(repo.pastDescriptions('corner bar'), isEmpty);
      expect(repo.pastDescriptions('corner b'), ['Corner Bar']);
    });
  });
}
