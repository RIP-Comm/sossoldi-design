import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:sossoldi/design_system/tokens/category_colors.dart';
import 'package:sossoldi/mock/data/account_data.dart';
import 'package:sossoldi/mock/mock_repository.dart';
import 'package:sossoldi/mock/models/account.dart';
import 'package:sossoldi/mock/models/account_edit.dart';
import 'package:sossoldi/mock/models/movement_edit.dart';

final _now = DateTime(2026, 10, 22, 10);

AccountDraft _draft(
  String name, {
  double amount = 100,
  String currency = 'EUR',
  AccountType type = AccountType.checking,
}) => AccountDraft(
  name: name,
  initialBalance: amount,
  currency: currency,
  color: CategoryColors.all[3],
  icon: PhosphorIconsRegular.bank,
  type: type,
);

void main() {
  group('the repository of a new user', () {
    final demo = MockRepository(now: _now);
    late MockRepository repo;
    setUp(() => repo = MockRepository.newUser(now: _now));

    test('is empty: nothing of the user', () {
      expect(repo.accounts, isEmpty);
      expect(repo.categories(), isEmpty);
      expect(repo.transactions, isEmpty);
      expect(repo.holdings, isEmpty);
      expect(repo.totalBalance, 0);
      expect(repo.brokerAccounts, isEmpty);
      expect(repo.liquidity, 0);
      expect(repo.recurringOccurrences(_now.year, _now.month), isEmpty);
      expect(repo.movementList(const MovementFilter()).days, isEmpty);
    });

    test('has the identity of the demo user and EUR by default', () {
      expect(repo.user.email, demo.user.email);
      expect(repo.user.firstName, demo.user.firstName);
      expect(repo.mainCurrency, 'EUR');
      expect(
        MockRepository.newUser(now: _now, mainCurrency: 'BRL').mainCurrency,
        'BRL',
      );
    });

    test('keeps the catalog and the rates: they are not the user\'s', () {
      expect(repo.supportedCurrencies, demo.supportedCurrencies);
      expect(
        repo.supportedCurrencies,
        containsAll(['EUR', 'USD', 'GBP', 'CHF', 'BRL', 'AED', 'JPY', 'CAD']),
      );
      for (final c in repo.supportedCurrencies) {
        expect(repo.toEur(1, c), greaterThan(0));
      }
      expect(repo.assetCatalog, isNotEmpty);
    });

    test('the main currency can be changed', () {
      repo.setMainCurrency('JPY');
      expect(repo.mainCurrency, 'JPY');
    });

    test('the demo repository is not affected', () {
      repo.addAccount(_draft('Mine'));
      expect(demo.accounts.map((a) => a.name), isNot(contains('Mine')));
      expect(demo.accounts, hasLength(3));
    });
  });

  group('accounts', () {
    late MockRepository repo;
    setUp(() => repo = MockRepository.newUser(now: _now));

    test('add: the balance is the amount, any sign, zero included', () {
      final a = repo.addAccount(_draft('Wallet', amount: 1000.204)).account!;
      expect(repo.accounts, [a]);
      expect(a.name, 'Wallet');
      expect(repo.accountBalance(a.id), 1000.2);
      final zero = repo.addAccount(_draft('Empty', amount: 0)).account!;
      expect(repo.accountBalance(zero.id), 0);
      final card = repo.addAccount(_draft('Card', amount: -250.5)).account!;
      expect(repo.accountBalance(card.id), -250.5);
      expect(repo.totalBalance, 749.7);
    });

    test('add: the account keeps its own currency; totals are converted', () {
      final usd = repo
          .addAccount(_draft('Dollars', amount: 100, currency: 'USD'))
          .account!;
      expect(usd.currency, 'USD');
      expect(repo.accountBalance(usd.id), 100);
      expect(repo.totalBalance, closeTo(92.34, 0.001));
    });

    test('changing the main currency leaves the accounts as they are', () {
      final a = repo.addAccount(_draft('Euros', amount: 500)).account!;
      repo.setMainCurrency('USD');
      expect(repo.account(a.id).currency, 'EUR');
      expect(repo.accountBalance(a.id), 500);
    });

    test('add: ids are unique and listeners are told', () {
      var calls = 0;
      repo.addListener(() => calls++);
      final a = repo.addAccount(_draft('A')).account!;
      final b = repo.addAccount(_draft('B')).account!;
      expect(a.id, isNot(b.id));
      expect(calls, 2);
    });

    test('the name: required, unique ignoring capitals and spaces', () {
      expect(
        repo.addAccount(_draft('   ')).failure,
        AccountFailure.invalidName,
      );
      repo.addAccount(_draft('Savings'));
      expect(
        repo.addAccount(_draft('savings')).failure,
        AccountFailure.duplicateName,
      );
      expect(
        repo.addAccount(_draft('  SAVINGS ')).failure,
        AccountFailure.duplicateName,
      );
      expect(repo.accounts, hasLength(1));
      expect(repo.accountNameTaken('sAvInGs'), isTrue);
      expect(repo.accountNameTaken('Other'), isFalse);
    });

    test('the amount and the currency are checked', () {
      expect(
        repo.addAccount(_draft('A', amount: double.nan)).failure,
        AccountFailure.invalidAmount,
      );
      expect(
        repo.addAccount(_draft('A', amount: double.infinity)).failure,
        AccountFailure.invalidAmount,
      );
      expect(
        repo.addAccount(_draft('A', currency: 'XXX')).failure,
        AccountFailure.invalidCurrency,
      );
      expect(repo.accounts, isEmpty);
    });

    test('update: name, balance, currency, color and icon', () {
      final a = repo.addAccount(_draft('Old')).account!;
      final r = repo.updateAccount(
        a.id,
        AccountDraft(
          name: 'New',
          initialBalance: 5,
          currency: 'GBP',
          color: CategoryColor.fromColor(const Color(0xFF123456)),
          icon: PhosphorIconsRegular.wallet,
        ),
      );
      expect(r.ok, isTrue);
      final b = repo.account(a.id);
      expect(b.name, 'New');
      expect(b.currency, 'GBP');
      expect(b.icon, PhosphorIconsRegular.wallet);
      expect(b.color.main, const Color(0xFF123456));
      expect(repo.accountBalance(a.id), 5);
      expect(repo.accounts, hasLength(1));
    });

    test('update: keeping its own name is not a duplicate; another is', () {
      final a = repo.addAccount(_draft('One')).account!;
      repo.addAccount(_draft('Two'));
      expect(repo.updateAccount(a.id, _draft('ONE', amount: 9)).ok, isTrue);
      expect(
        repo.updateAccount(a.id, _draft('two')).failure,
        AccountFailure.duplicateName,
      );
      expect(repo.account(a.id).name, 'ONE');
    });

    test('update and delete of an account that is not there', () {
      expect(
        repo.updateAccount('nope', _draft('X')).failure,
        AccountFailure.notFound,
      );
      expect(repo.deleteAccount('nope').failure, AccountFailure.notFound);
    });

    test('delete removes it and tells the listeners', () {
      final a = repo.addAccount(_draft('A')).account!;
      final b = repo.addAccount(_draft('B')).account!;
      var calls = 0;
      repo.addListener(() => calls++);
      expect(repo.deleteAccount(a.id).ok, isTrue);
      expect(repo.accounts, [b]);
      expect(calls, 1);
      expect(repo.accountNameTaken('A'), isFalse);
      // The name can be used again.
      expect(repo.addAccount(_draft('A')).ok, isTrue);
    });

    test('a broker account is the one the movements go to', () {
      expect(repo.brokerAccounts, isEmpty);
      final broker = repo
          .addAccount(_draft('Broker', type: AccountType.broker))
          .account!;
      expect(repo.brokerAccounts, [broker]);
    });
  });

  group('accounts of the demo data', () {
    late MockRepository repo;
    setUp(() => repo = MockRepository(now: _now));

    test('one with transactions cannot be deleted, nor change currency', () {
      expect(repo.accountInUse(checkingAccountId), isTrue);
      expect(
        repo.deleteAccount(checkingAccountId).failure,
        AccountFailure.inUse,
      );
      final a = repo.account(checkingAccountId);
      final r = repo.updateAccount(
        a.id,
        AccountDraft(
          name: a.name,
          initialBalance: a.initialBalance,
          currency: 'USD',
          color: a.color,
          icon: a.icon,
        ),
      );
      expect(r.failure, AccountFailure.inUse);
      expect(repo.account(a.id).currency, 'EUR');
    });

    test('its name, balance, color and icon can change', () {
      final a = repo.account(checkingAccountId);
      final before = repo.accountBalance(a.id);
      final r = repo.updateAccount(
        a.id,
        AccountDraft(
          name: 'Renamed',
          initialBalance: a.initialBalance + 100,
          currency: a.currency,
          color: CategoryColors.all[0],
          icon: PhosphorIconsRegular.wallet,
        ),
      );
      expect(r.ok, isTrue);
      expect(repo.accountBalance(a.id), closeTo(before + 100, 0.001));
    });

    test(
      'the colors of the demo accounts and categories are the palette\'s',
      () {
        for (final a in repo.accounts) {
          expect(CategoryColors.all, contains(a.color));
        }
      },
    );
  });
}
