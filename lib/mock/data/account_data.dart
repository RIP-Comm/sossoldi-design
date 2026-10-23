// Bank names are fictional.

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../models/account.dart';

const checkingAccountId = 'acc_checking';
const savingsAccountId = 'acc_savings';
const brokerAccountId = 'acc_broker';

const mockAccounts = [
  Account(
    id: checkingAccountId,
    name: 'Everyday account',
    bankName: 'Aurora Bank',
    type: AccountType.checking,
    initialBalance: 3500,
    currency: 'EUR',
    colorIndex: 25,
    icon: PhosphorIconsRegular.bank,
  ),
  Account(
    id: savingsAccountId,
    name: 'Savings account',
    bankName: 'Fenice Savings',
    type: AccountType.savings,
    initialBalance: 12000,
    currency: 'EUR',
    colorIndex: 12,
    icon: PhosphorIconsRegular.piggyBank,
  ),
  Account(
    id: brokerAccountId,
    name: 'Investment account',
    bankName: 'Orbita Invest',
    type: AccountType.broker,
    initialBalance: 1500,
    currency: 'EUR',
    colorIndex: 28,
    icon: PhosphorIconsRegular.chartLineUp,
  ),
];
