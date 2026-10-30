// Bank names are fictional.

import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../design_system/tokens/category_colors.dart';
import '../models/account.dart';

const checkingAccountId = 'acc_checking';
const savingsAccountId = 'acc_savings';
const brokerAccountId = 'acc_broker';

final mockAccounts = [
  Account(
    id: checkingAccountId,
    name: 'Everyday account',
    bankName: 'Aurora Bank',
    type: AccountType.checking,
    initialBalance: 3500,
    currency: 'EUR',
    color: CategoryColors.all[25],
    icon: PhosphorIconsRegular.bank,
    isMain: true,
  ),
  Account(
    id: savingsAccountId,
    name: 'Savings account',
    bankName: 'Fenice Savings',
    type: AccountType.savings,
    initialBalance: 12000,
    currency: 'EUR',
    color: CategoryColors.all[12],
    icon: PhosphorIconsRegular.piggyBank,
  ),
  Account(
    id: brokerAccountId,
    name: 'Investment account',
    bankName: 'Orbita Invest',
    type: AccountType.broker,
    initialBalance: 1500,
    currency: 'EUR',
    color: CategoryColors.all[28],
    icon: PhosphorIconsRegular.chartLineUp,
  ),
];
