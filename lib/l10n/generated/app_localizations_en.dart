// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navFinance => 'Finance';

  @override
  String get navInvestments => 'Investments';

  @override
  String get addTransaction => 'Add transaction';

  @override
  String get settings => 'Settings';

  @override
  String get back => 'Back';

  @override
  String get showAmounts => 'Show amounts';

  @override
  String get hideAmounts => 'Hide amounts';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get widgetMonthlyBalanceName => 'Monthly balance';

  @override
  String get widgetLatestTransactionsName => 'Latest transactions';

  @override
  String get widgetIncome => 'Income';

  @override
  String get widgetExpense => 'Expense';

  @override
  String get widgetComparedToLastMonth =>
      'Compared to last month on the same day';

  @override
  String get chartThisMonth => 'This month';

  @override
  String get chartLastMonth => 'Last month';

  @override
  String get editHome => 'Edit Home';

  @override
  String get addWidget => 'Add widget';

  @override
  String get doneEditing => 'Done';

  @override
  String get cancel => 'Cancel';

  @override
  String get removeWidget => 'Remove widget';

  @override
  String get resizeWidget => 'Resize widget';

  @override
  String get widgetSizeSmall => 'Small';

  @override
  String get widgetSizeMedium => 'Medium';

  @override
  String get widgetSizeLarge => 'Large';

  @override
  String get dashboardEmptyTitle => 'Your Home is empty';

  @override
  String get dashboardEmptyEditHint => 'Tap + to add a widget';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get financeTitle => 'Finance';

  @override
  String get financeTabOverview => 'Overview';

  @override
  String get financeTabTransactions => 'Transactions';

  @override
  String get financeTabBudget => 'Budget';

  @override
  String get financeTabRecurring => 'Recurring';

  @override
  String get transactionsViewList => 'List';

  @override
  String get transactionsViewCharts => 'Charts';

  @override
  String get searchTransactions => 'Search transactions';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get filters => 'Filters';

  @override
  String get filtersApply => 'Apply';

  @override
  String get filtersReset => 'Reset';

  @override
  String get filterDate => 'Date';

  @override
  String get filterType => 'Type';

  @override
  String get filterCategory => 'Category';

  @override
  String get filterAmount => 'Amount';

  @override
  String get filterAccount => 'Account';

  @override
  String get typeExpense => 'Expense';

  @override
  String get typeIncome => 'Income';

  @override
  String get typeTransfer => 'Transfer';

  @override
  String get removeFilter => 'Remove filter';

  @override
  String get datePresetThisMonth => 'This month';

  @override
  String get datePresetLastMonth => 'Last month';

  @override
  String get datePresetLast3Months => 'Last 3 months';

  @override
  String get datePresetThisYear => 'This year';

  @override
  String get datePresetAllTime => 'All time';

  @override
  String get datePresetCustom => 'Custom range';

  @override
  String get amountMin => 'Min';

  @override
  String get amountMax => 'Max';

  @override
  String get emptyTransactionsTitle => 'No transactions found';

  @override
  String get emptyTransactionsFiltered =>
      'Try changing the search or the filters.';

  @override
  String get emptyTransactionsPlain =>
      'There are no transactions in this period.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get paginationPrevious => 'Previous page';

  @override
  String get paginationNext => 'Next page';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String amountsIn(String currency) {
    return 'Amounts in $currency';
  }

  @override
  String get chartsSelectTimeRange => 'Select time range';

  @override
  String get rangeCurrentMonth => 'Current month';

  @override
  String get rangeLastMonth => 'Last month';

  @override
  String get rangeLast3Months => 'Last 3 months';

  @override
  String get rangeLast6Months => 'Last 6 months';

  @override
  String get rangeYearToDate => 'Year to date';

  @override
  String get rangeLast12Months => 'Last 12 months';

  @override
  String get kindExpenses => 'Expenses';

  @override
  String get kindIncome => 'Income';

  @override
  String get chartTotal => 'Total';

  @override
  String get chartCategoriesBreakdown => 'Categories breakdown';

  @override
  String get chartBreakdownOverTime => 'Breakdown over time';

  @override
  String get chartSnapshot => 'Snapshot';

  @override
  String get granularityWeekly => 'Weekly';

  @override
  String get granularityMonthly => 'Monthly';

  @override
  String get emptyChartsTitle => 'No transactions in this period';

  @override
  String get emptyChartsFiltered => 'Try another time range or fewer filters.';

  @override
  String get chartDonutSemantics => 'Breakdown by category';

  @override
  String get chartAreaSemantics => 'Breakdown over time by category';

  @override
  String changeVsPrevious(String value) {
    return '$value PoP';
  }

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Device language';

  @override
  String get currency => 'Currency';

  @override
  String get periodWeekly => 'Weekly';

  @override
  String get periodMonthly => 'Monthly';

  @override
  String get periodQuarterly => 'Quarterly';

  @override
  String get periodSemiannual => 'Semiannual';

  @override
  String get periodYearly => 'Yearly';

  @override
  String get budgetOverall => 'Overall budget';

  @override
  String get budgetCategoriesBreakdown => 'Categories breakdown';

  @override
  String get budgetsBarSemantics => 'Budgets of the period';

  @override
  String get budgetEmptyTitle => 'No budgets for this period';

  @override
  String get budgetEmptyHint =>
      'You will be able to add budgets from Settings.';

  @override
  String get budgetEdit => 'Edit';

  @override
  String get budgetSectionBudget => 'Budget';

  @override
  String get budgetSectionExpenses => 'Expenses';

  @override
  String get budgetSearchExpenses => 'Search expenses';

  @override
  String get budgetAmount => 'Budget amount';

  @override
  String get budgetAmountRequired => 'Enter an amount.';

  @override
  String get budgetAmountPositive => 'The amount must be greater than zero.';

  @override
  String get budgetDelete => 'Delete budget';

  @override
  String get budgetDeleteTitle => 'Delete this budget?';

  @override
  String get budgetDeleteConfirm => 'Delete';

  @override
  String get emptyBudgetExpensesTitle => 'No expenses in this period';

  @override
  String budgetLeft(String amount) {
    return '$amount left';
  }

  @override
  String budgetOver(String amount) {
    return '$amount over';
  }

  @override
  String budgetDeleteMessage(String period, String category) {
    return 'The $period budget of $category will be removed. Your expenses are not affected.';
  }

  @override
  String get recurringPreviousMonth => 'Previous month';

  @override
  String get recurringNextMonth => 'Next month';

  @override
  String get recurringPickMonth => 'Choose the month';

  @override
  String get recurringPickMonthTitle => 'Select month';

  @override
  String get recurringPreviousYear => 'Previous year';

  @override
  String get recurringNextYear => 'Next year';

  @override
  String get recurringAdd => 'Add recurrent transaction';

  @override
  String get recurringEmptyMonthTitle => 'No recurring transactions this month';

  @override
  String get recurringEmptyDayTitle => 'Nothing on this day';

  @override
  String get recurringEdit => 'Edit';

  @override
  String get recurringSectionDetails => 'Details';

  @override
  String get recurringPeriod => 'Recurrence period';

  @override
  String get recurringAmount => 'Amount';

  @override
  String get recurringActive => 'Active';

  @override
  String get recurringSectionOld => 'Old transactions';

  @override
  String get recurringRangeLabel => 'Select time range';

  @override
  String get recurringRangeLast3 => 'Last 3 months';

  @override
  String get recurringRangeLast6 => 'Last 6 months';

  @override
  String get recurringRangeLast12 => 'Last 12 months';

  @override
  String get recurringRangeAll => 'All';

  @override
  String get recurringFrequencyWeekly => 'Weekly';

  @override
  String get recurringFrequencyBiweekly => 'Every 2 weeks';

  @override
  String get recurringFrequencyMonthly => 'Monthly';

  @override
  String get recurringFrequencyBimonthly => 'Every 2 months';

  @override
  String get recurringFrequencyQuarterly => 'Quarterly';

  @override
  String get recurringFrequencySemiannual => 'Semiannual';

  @override
  String get recurringFrequencyYearly => 'Yearly';

  @override
  String get recurringHistoryEmpty => 'No transactions in this period';

  @override
  String get recurringDelete => 'Delete recurrence';

  @override
  String get recurringDeleteTitle => 'Delete this recurring transaction?';

  @override
  String get recurringDeleteConfirm => 'Delete';

  @override
  String recurringDeleteMessage(String name) {
    return '$name will not repeat any more. The transactions already recorded are kept.';
  }

  @override
  String get close => 'Close';

  @override
  String get overviewAccounts => 'Your accounts';

  @override
  String get overviewManage => 'Manage';

  @override
  String get overviewBudgetsTitle => 'Budgets';

  @override
  String get overviewUpcoming => 'Upcoming recurrences';

  @override
  String get overviewNoUpcoming =>
      'No recurring transactions until the end of the month';

  @override
  String get overviewCashFlow => 'Cash flow';

  @override
  String get overviewBudgetStatus => 'Budget status';

  @override
  String get overviewNoBudgets => 'No budgets for this month';

  @override
  String get legendIncome => 'Income';

  @override
  String get legendExpense => 'Expense';

  @override
  String get legendBalance => 'Balance';

  @override
  String get cashFlowSemantics =>
      'Cash flow of the month: income, expenses and balance day by day';

  @override
  String get digestBudgetExceededTitle => 'Budget exceeded';

  @override
  String digestBudgetExceeded(String category, String amount) {
    return 'You went over the $category budget by $amount';
  }

  @override
  String get digestBudgetAtRiskTitle => 'Budget at risk';

  @override
  String digestBudgetAtRisk(String category, String percent, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return 'The $category budget is at $percent with $_temp0 left';
  }

  @override
  String get digestBelowTitle => 'Good month so far';

  @override
  String digestBelow(String amount) {
    return 'You are spending $amount less than the average of the last 3 months';
  }

  @override
  String get digestAboveTitle => 'Spending above average';

  @override
  String digestAbove(String amount) {
    return 'You are spending $amount more than the average of the last 3 months';
  }

  @override
  String get digestRecurrencesTitle => 'Payments coming up';

  @override
  String digestRecurrencesOne(String name, String amount, int days) {
    return '$name ($amount) is due in the next $days days';
  }

  @override
  String digestRecurrencesMany(int count, int days, String amount) {
    return '$count recurring payments in the next $days days, $amount in total';
  }

  @override
  String get digestGrowthTitle => 'Spending is growing';

  @override
  String digestGrowth(String category, String percent) {
    return 'Spending on $category is up $percent on the same days of last month';
  }

  @override
  String get digestAllGoodTitle => 'All good';

  @override
  String get digestAllGood => 'Everything is in order this month';

  @override
  String get investmentsTitle => 'Investments';

  @override
  String get investmentsTabOverview => 'Overview';

  @override
  String get investmentsTabPositions => 'Positions';

  @override
  String get investmentsTabMovements => 'Movements';

  @override
  String get investmentsUpdatedNow => 'Updated just now';

  @override
  String investmentsUpdatedMinutes(int count) {
    return 'Updated $count min ago';
  }

  @override
  String investmentsUpdatedHours(int count) {
    return 'Updated $count h ago';
  }

  @override
  String investmentsUpdatedDays(int count) {
    return 'Updated $count d ago';
  }

  @override
  String get investmentsPortfolioValue => 'Portfolio value';

  @override
  String get investmentsLiquidity => 'Available liquidity';

  @override
  String get investmentsMarketValue => 'Market value';

  @override
  String get investmentsAllocations => 'Asset allocations';

  @override
  String get periodDay => '1D';

  @override
  String get periodFiveDays => '5D';

  @override
  String get periodMonth => '1M';

  @override
  String get periodSixMonths => '6M';

  @override
  String get periodYearToDate => 'YTD';

  @override
  String get periodYear => '1Y';

  @override
  String get periodFiveYears => '5Y';

  @override
  String get legendMarketValue => 'Market value';

  @override
  String get legendInvested => 'Invested';

  @override
  String get legendDifference => 'Difference';

  @override
  String get marketValueSemantics =>
      'Market value of the portfolio and capital invested over time';

  @override
  String get allocationAssetClass => 'Asset class';

  @override
  String get allocationSingleAsset => 'Single asset';

  @override
  String get allocationEtf => 'ETFs';

  @override
  String get allocationStocks => 'Stocks';

  @override
  String get allocationBonds => 'Bonds';

  @override
  String get allocationOther => 'Other';

  @override
  String get allocationLiquidity => 'Liquidity';

  @override
  String get allocationSemantics => 'Allocation of the portfolio';

  @override
  String get investmentsEmptyTitle => 'No investments yet';

  @override
  String get investmentsEmptyHint => 'Your positions will show up here.';

  @override
  String get investmentsDigestAllGoodTitle => 'All good';

  @override
  String get investmentsDigestAllGood =>
      'Nothing to report on your investments';

  @override
  String get investmentsDigestConcentrationTitle => 'Concentration';

  @override
  String investmentsDigestConcentration(String percent, String name) {
    return '**$percent** of your portfolio is in a single asset, $name. Consider diversifying';
  }

  @override
  String get investmentsDigestDropTitle => 'Portfolio down';

  @override
  String investmentsDigestDrop(String amount, String percent) {
    return 'Your portfolio lost **$amount** (**$percent**) over the last month';
  }

  @override
  String get investmentsDigestGrowthTitle => 'Portfolio growing';

  @override
  String investmentsDigestGrowth(String amount) {
    return 'Your invested wealth grew by **$amount** over the last month';
  }

  @override
  String get investmentsDigestDividendTitle => 'Dividend coming';

  @override
  String investmentsDigestDividendOne(String name, String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$name pays **$amount** in dividends within $_temp0';
  }

  @override
  String investmentsDigestDividendMany(int count, String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$count dividends worth **$amount** in total are expected within $_temp0';
  }

  @override
  String get positionsTitle => 'Positions';

  @override
  String get positionsSearch => 'Search positions';

  @override
  String get positionsFilterType => 'Asset type';

  @override
  String get positionsEmptyTitle => 'No positions found';

  @override
  String get positionsEmptyHint => 'Try another search or other filters.';

  @override
  String get positionsNoneTitle => 'No positions yet';

  @override
  String get kindEtf => 'ETF';

  @override
  String get kindStock => 'Stock';

  @override
  String get kindBond => 'Bond';

  @override
  String get kindManual => 'Manual asset';

  @override
  String get manualPension => 'Pension fund';

  @override
  String get manualCollectible => 'Collectible';

  @override
  String get manualArt => 'Art';

  @override
  String get manualRealEstate => 'Real estate';

  @override
  String get manualOther => 'Other';

  @override
  String get breakdownTitle => 'Portfolio breakdown';

  @override
  String get breakdownRegion => 'Region';

  @override
  String get breakdownSector => 'Sector';

  @override
  String get positionYour => 'Your position';

  @override
  String get positionMarketValue => 'Market value';

  @override
  String get positionQuantity => 'Quantity';

  @override
  String get positionAverageCost => 'Average cost';

  @override
  String get positionInvested => 'Invested capital';

  @override
  String get positionPnl => 'Profit / loss';

  @override
  String get positionWeight => 'Weight';

  @override
  String get positionAssetInfo => 'Asset info';

  @override
  String get infoType => 'Type';

  @override
  String get infoSector => 'Sector';

  @override
  String get infoRegion => 'Region';

  @override
  String get infoCurrency => 'Currency';

  @override
  String get infoExchange => 'Exchange';

  @override
  String get positionOperations => 'Operations';

  @override
  String get operationsEmpty => 'No operations yet';

  @override
  String get operationBuy => 'Buy';

  @override
  String get operationSell => 'Sell';

  @override
  String get operationDividend => 'Dividend';

  @override
  String operationDetails(String quantity, String price) {
    return '$quantity × $price';
  }

  @override
  String get positionBuy => 'Buy';

  @override
  String get positionSell => 'Sell';

  @override
  String get positionAddDividend => 'Add dividend';

  @override
  String get positionPrice => 'Price';

  @override
  String get positionPriceChartSemantics =>
      'Price of the asset over time and average cost';

  @override
  String positionPriceInCurrency(String price) {
    return '$price per unit';
  }

  @override
  String get infoDistribution => 'Distribution';

  @override
  String get distAccumulating => 'Accumulating';

  @override
  String get distDistributing => 'Distributing';

  @override
  String get infoTer => 'TER';

  @override
  String get infoDividendYield => 'Dividend yield';

  @override
  String get infoCoupon => 'Coupon';

  @override
  String get infoMaturity => 'Maturity';

  @override
  String get infoDuration => 'Duration';

  @override
  String infoYears(String value) {
    return '$value years';
  }

  @override
  String get positionMoreActions => 'More actions';

  @override
  String get positionUpdateValue => 'Update value';

  @override
  String get movementsSearch => 'Search movements';

  @override
  String get movementsUpNext => 'Up next';

  @override
  String get movementsEmptyTitle => 'No movements found';

  @override
  String get movementsEmptyHint => 'Try another search or other filters.';

  @override
  String get movementsNoneTitle => 'No movements yet';

  @override
  String get movementTypeBuy => 'Buy';

  @override
  String get movementTypeSell => 'Sell';

  @override
  String get movementTypeDividend => 'Dividend';

  @override
  String get movementTypeCost => 'Cost';

  @override
  String get movementPrice => 'Price';

  @override
  String movementDetails(String quantity, String price) {
    return '$quantity · Price $price';
  }

  @override
  String get movementPeriodCurrentMonth => 'Current month';

  @override
  String get movementPeriodLast3Months => 'Last 3 months';

  @override
  String get movementPeriodCurrentYear => 'Current year';

  @override
  String get movementPeriodLast12Months => 'Last 12 months';

  @override
  String get movementPeriodAll => 'All';

  @override
  String get movementFilterPeriod => 'Period';

  @override
  String get movementFilterType => 'Movement type';

  @override
  String get movementFilterAssetType => 'Asset type';

  @override
  String get movementFilterAsset => 'Asset';

  @override
  String get movementFilterAnyAsset => 'All assets';

  @override
  String get movementNew => 'New movement';

  @override
  String get movementAdd => 'Add';

  @override
  String get movementFieldAsset => 'Asset';

  @override
  String get movementFieldAssetOptional => 'Asset (optional)';

  @override
  String get movementNoAsset => 'None';

  @override
  String get movementSearchAsset => 'Search an asset';

  @override
  String get movementChangeAsset => 'Change';

  @override
  String get movementAssetCatalog => 'Catalog';

  @override
  String get movementAssetManual => 'Manual asset';

  @override
  String get movementManualName => 'Name';

  @override
  String get movementManualType => 'Kind of asset';

  @override
  String get movementFieldAccount => 'Broker account';

  @override
  String get movementFieldDate => 'Date';

  @override
  String get movementFieldQuantity => 'Quantity';

  @override
  String get movementFieldUnitPrice => 'Unit price';

  @override
  String get movementFieldFee => 'Commission (optional)';

  @override
  String get movementFieldAmount => 'Amount';

  @override
  String get movementFieldNetAmount => 'Net amount';

  @override
  String get movementFieldDescription => 'Description';

  @override
  String get movementFieldDescriptionOptional => 'Description (optional)';

  @override
  String movementHeld(String quantity) {
    return 'You hold $quantity';
  }

  @override
  String get movementErrRequired => 'Required.';

  @override
  String get movementErrNumber => 'Enter a valid number.';

  @override
  String get movementErrPositive => 'It must be greater than zero.';

  @override
  String get movementErrFuture => 'The date cannot be in the future.';

  @override
  String get movementErrChooseAsset => 'Choose an asset.';

  @override
  String movementErrNegative(String date) {
    return 'On $date you would hold less than zero of this asset. Nothing was changed.';
  }

  @override
  String get movementErrInvalid => 'The movement is not valid.';

  @override
  String movementLiquidityWarning(String amount) {
    return 'This is more than your available liquidity: it will go to $amount.';
  }

  @override
  String get movementDetailEdit => 'Edit';

  @override
  String get movementDetailTotal => 'Total';

  @override
  String get movementDetailAsset => 'Asset';

  @override
  String get movementDetailType => 'Type';

  @override
  String get movementDetailAccount => 'Broker account';

  @override
  String get movementDetailDate => 'Date';

  @override
  String get movementDetailQuantity => 'Quantity';

  @override
  String get movementDetailPrice => 'Unit price';

  @override
  String get movementDetailFee => 'Commission';

  @override
  String get movementDelete => 'Delete movement';

  @override
  String get movementDeleteTitle => 'Delete this movement?';

  @override
  String get movementDeleteMessage =>
      'The position and the liquidity will be worked out again without it.';

  @override
  String get movementDeleteConfirm => 'Delete';

  @override
  String get movementDividendExpected => 'Expected';

  @override
  String get appName => 'SOSSOLDI';

  @override
  String get onboardingSplashWelcome => 'Welcome to';

  @override
  String get onboardingSplashTagline =>
      'The personal finance app of the Mr. RIP community';

  @override
  String get onboardingWelcomeTitle => 'Set up the app';

  @override
  String get onboardingWelcomeSubtitle =>
      'A few steps and you\'ll be ready to keep track of your personal finances (almost) like Mr. Rip';

  @override
  String get onboardingChooseLanguage => 'Choose language';

  @override
  String get onboardingDefault => 'default';

  @override
  String get onboardingStartSetup => 'Start the setup';

  @override
  String get onboardingOr => 'Or';

  @override
  String get onboardingImport => 'Import data from another app';

  @override
  String get onboardingImportTitle => 'Import data';

  @override
  String onboardingStep(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get onboardingStep1Subtitle =>
      'Select your currency and setup the accounts';

  @override
  String get onboardingMainCurrency => 'Select main currency';

  @override
  String get onboardingYourAccounts => 'Your accounts';

  @override
  String get onboardingFirstAccount => 'Create your first account';

  @override
  String get onboardingCreateAccount => 'Create account';

  @override
  String get onboardingAddAccount => 'Add account';

  @override
  String get onboardingNextStep => 'Next step';

  @override
  String get accountNew => 'New account';

  @override
  String get accountEdit => 'Edit account';

  @override
  String get accountMainInfo => 'Main info';

  @override
  String get accountName => 'Name';

  @override
  String get accountNamePlaceholder => 'Your account name';

  @override
  String get accountAmount => 'Amount';

  @override
  String get accountIconAndColor => 'Icon and color';

  @override
  String get accountTapToSelect => 'Tap to select';

  @override
  String get accountChooseIcon => 'Choose an icon';

  @override
  String get accountColorHue => 'Hue';

  @override
  String get accountColorSaturation => 'Saturation';

  @override
  String get accountSave => 'Save';

  @override
  String get accountDelete => 'Delete account';

  @override
  String get accountDeleteTitle => 'Delete this account?';

  @override
  String get accountDeleteConfirm => 'Delete';

  @override
  String get accountErrName => 'Enter a name';

  @override
  String get accountErrNameTaken =>
      'You already have an account with this name';

  @override
  String get accountErrAmount => 'Enter an amount';

  @override
  String get accountErrAmountInvalid => 'Enter a valid number';

  @override
  String get accountErrInUse =>
      'This account has transactions, so it cannot be deleted or change currency';

  @override
  String get settingsAppSettings => 'App settings';

  @override
  String get settingsPrototypeSettings => 'Prototype settings';

  @override
  String get settingsAuthentication => 'Authentication';

  @override
  String get settingsAccounts => 'Accounts';

  @override
  String get settingsCategories => 'Categories';

  @override
  String get settingsBudgets => 'Budgets';

  @override
  String get settingsImportExport => 'Import / Export';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsFeedback => 'Feedback';

  @override
  String get settingsInfo => 'Info';

  @override
  String get settingsRestartOnboarding => 'Restart onboarding';

  @override
  String get settingsLoadDemo => 'Load demo data';

  @override
  String get currencyNameEUR => 'Euro';

  @override
  String get currencyNameUSD => 'US dollar';

  @override
  String get currencyNameGBP => 'British pound';

  @override
  String get currencyNameCHF => 'Swiss franc';

  @override
  String get currencyNameBRL => 'Brazilian real';

  @override
  String get currencyNameAED => 'UAE dirham';

  @override
  String get currencyNameJPY => 'Japanese yen';

  @override
  String get currencyNameCAD => 'Canadian dollar';

  @override
  String accountDeleteMessage(String name) {
    return '$name will be removed from your accounts.';
  }

  @override
  String get iconGroupFinance => 'Finance';

  @override
  String get iconGroupCommerce => 'Shopping';

  @override
  String get iconGroupTravel => 'Travel and places';

  @override
  String get iconGroupHealth => 'Health';

  @override
  String get iconGroupPeople => 'People';

  @override
  String get iconGroupNature => 'Nature and weather';

  @override
  String get iconGroupGames => 'Games';

  @override
  String get iconGroupMedia => 'Media';

  @override
  String get iconGroupOffice => 'Office';

  @override
  String get iconGroupCommunication => 'Communication';

  @override
  String get iconGroupObjects => 'Objects';

  @override
  String get onboardingStep2Subtitle =>
      'Now it’s time to create your categories and the related budgets';

  @override
  String get onboardingYourCategories => 'Your categories';

  @override
  String get onboardingFirstCategory => 'Create your first category';

  @override
  String get onboardingCreateCategory => 'Create category';

  @override
  String get onboardingAddCategory => 'Add category';

  @override
  String get onboardingSuggested => 'Suggested';

  @override
  String get onboardingSuggestedExpenses => 'Expenses';

  @override
  String get onboardingSuggestedIncome => 'Income';

  @override
  String onboardingAddSuggested(String name) {
    return 'Add $name';
  }

  @override
  String categoryBudgetSubtitle(String budgets) {
    return 'Budget: $budgets';
  }

  @override
  String categoryBudgetEntry(String amount, String period) {
    return '$amount, $period';
  }

  @override
  String get categoryShowSubcategories => 'Show subcategories';

  @override
  String get categoryHideSubcategories => 'Hide subcategories';

  @override
  String get categoryNew => 'New category';

  @override
  String get categoryEdit => 'Edit category';

  @override
  String get categoryType => 'Type';

  @override
  String get categoryTypeExpense => 'Expense';

  @override
  String get categoryTypeIncome => 'Income';

  @override
  String get categoryNamePlaceholder => 'Your category name';

  @override
  String get categoryBudget => 'Budget';

  @override
  String get categoryAddBudget => 'Add budget';

  @override
  String get categorySubcategories => 'Subcategories';

  @override
  String get categorySubcategoriesHint =>
      'Subcategories allow you to manage your transactions more precisely';

  @override
  String get categoryAddSubcategory => 'Add subcategory';

  @override
  String get categoryDelete => 'Delete category';

  @override
  String get categoryDeleteTitle => 'Delete this category?';

  @override
  String categoryDeleteMessage(String name) {
    return '$name, its subcategories and its budgets will be removed.';
  }

  @override
  String get categoryDeleteConfirm => 'Delete';

  @override
  String get categoryErrName => 'Enter a name';

  @override
  String get categoryErrNameTaken =>
      'You already have a category of this type with this name';

  @override
  String get categoryErrInUse =>
      'This category has transactions, so it cannot be deleted or change type';

  @override
  String get categoryTypeChangeTitle => 'Change to income?';

  @override
  String get categoryTypeChangeMessage =>
      'Income categories have no budgets: the budgets of this category will be discarded.';

  @override
  String get categoryTypeChangeConfirm => 'Change type';

  @override
  String get subcategoryNew => 'New subcategory';

  @override
  String get subcategoryEdit => 'Edit subcategory';

  @override
  String get subcategoryNamePlaceholder => 'Your subcategory name';

  @override
  String get subcategoryDelete => 'Delete subcategory';

  @override
  String get subcategoryErrNameTaken =>
      'This category already has a subcategory with this name';

  @override
  String get budgetFormNew => 'New budget';

  @override
  String get budgetFormEdit => 'Edit budget';

  @override
  String get budgetSelectType => 'Select type';

  @override
  String get budgetSetAmount => 'Set amount';

  @override
  String get budgetAmountPlaceholder => 'e.g. 100';

  @override
  String get budgetLimitAlert => 'Limit reach alert';

  @override
  String get budgetCountForOverall => 'Count for overall budget';

  @override
  String get onboardingStep3Subtitle =>
      'And your investments and keep track of them in the app';

  @override
  String get onboardingYourAssets => 'Your assets';

  @override
  String get onboardingNoAssets => 'No asset yet';

  @override
  String get onboardingAddAsset => 'Add asset';

  @override
  String get onboardingSkipStep => 'Skip this step';

  @override
  String get onboardingStartTracking => 'Start tracking';

  @override
  String get assetQuantityLabel => 'Quantity:';

  @override
  String get assetPmcLabel => 'PMC:';

  @override
  String get assetNew => 'New asset';

  @override
  String get assetEdit => 'Edit asset';

  @override
  String get assetMainDetails => 'Main details';

  @override
  String get assetSearch => 'Search by name, ticker or ISIN';

  @override
  String get assetManualNamePlaceholder => 'Your asset name';

  @override
  String get assetAmount => 'Amount';

  @override
  String get assetAmountPlaceholder => 'e.g. 12';

  @override
  String get assetAveragePrice => 'Average purchase price';

  @override
  String get assetPricePlaceholder => 'e.g. 10,50';

  @override
  String get assetCountsForNetWorth => 'Counts for Net Worth';

  @override
  String get assetDelete => 'Delete asset';

  @override
  String get assetDeleteTitle => 'Delete this asset?';

  @override
  String assetDeleteMessage(String name) {
    return '$name and its opening movement will be removed.';
  }

  @override
  String get assetDeleteConfirm => 'Delete';

  @override
  String get assetErrChoose => 'Choose an asset';

  @override
  String get assetErrDuplicate => 'This asset is already in your list';

  @override
  String get assetErrNameRequired => 'Enter a name';

  @override
  String get assetErrNameTaken =>
      'You already have a manual asset with this name';

  @override
  String get assetErrAmount => 'Enter an amount';

  @override
  String get assetErrAmountPositive => 'The amount must be greater than zero';

  @override
  String get assetErrAmountDecimals => 'At most 8 decimals';

  @override
  String get assetErrAmountInvalid => 'Enter a valid number';

  @override
  String get assetErrPrice => 'Enter a price';

  @override
  String get assetErrPricePositive => 'The price must be greater than zero';

  @override
  String get assetErrDeleteRefused =>
      'This asset cannot be deleted: other movements depend on it';

  @override
  String get dashboardNoTransactions => 'No transactions yet';

  @override
  String get overviewCashFlowEmpty => 'No income or expenses this month yet';

  @override
  String get accountMain => 'Main account';

  @override
  String get accountMainHint => 'To change it, set another account as main';

  @override
  String get accountPageEdit => 'Edit';

  @override
  String get accountsEmptyTitle => 'No accounts yet';

  @override
  String get accountsEmptyMessage => 'Add one to start tracking.';

  @override
  String get accountNoTransactions => 'No transactions in this account yet.';

  @override
  String get accountMainTag => 'Main';

  @override
  String get addNewTransaction => 'New transaction';

  @override
  String get addNewMovement => 'New movement';

  @override
  String get addModeTransaction => 'Transaction';

  @override
  String get addModeMovement => 'Investment movement';

  @override
  String get addModeSemantic => 'Change what to add';

  @override
  String get addTransactionButton => 'Add transaction';

  @override
  String get addMovementButton => 'Add movement';

  @override
  String get addTransactionDone => 'Transaction added';

  @override
  String get addMovementDone => 'Movement added';

  @override
  String get addUndo => 'Undo';

  @override
  String get txAmount => 'Amount';

  @override
  String get txCategory => 'Category';

  @override
  String get txSubcategory => 'Subcategory (optional)';

  @override
  String get txSubcategories => 'Subcategories';

  @override
  String get txMore => 'More…';

  @override
  String get txErrCategory => 'Choose a category';

  @override
  String get txNoExpenseCategories => 'You have no expense categories yet.';

  @override
  String get txNoIncomeCategories => 'You have no income categories yet.';

  @override
  String get txNoAccounts => 'You need an account before adding a transaction.';

  @override
  String get txAccount => 'Account';

  @override
  String get txFrom => 'From';

  @override
  String get txTo => 'To';

  @override
  String get txSwapAccounts => 'Swap accounts';

  @override
  String get txAmountReceived => 'Amount received';

  @override
  String get txTransferNeedsTwo =>
      'To make a transfer you need at least two accounts.';

  @override
  String get txDate => 'Date';

  @override
  String get txToday => 'Today';

  @override
  String get txYesterday => 'Yesterday';

  @override
  String get txOtherDate => 'Custom';

  @override
  String get txDescription => 'Description (optional)';

  @override
  String get txRecurring => 'Recurring';

  @override
  String get txFrequency => 'Frequency';

  @override
  String get txStartDate => 'Start date';

  @override
  String get txEnd => 'End';

  @override
  String get txEndNever => 'Never';

  @override
  String get txEndOnDate => 'On date';

  @override
  String get txEndAfter => 'After';

  @override
  String get txEndDate => 'End date';

  @override
  String get txEndCount => 'Number of times';

  @override
  String get txChooseDate => 'Choose a date';

  @override
  String get txErrChooseDate => 'Choose the end date';

  @override
  String get txErrEndBeforeStart => 'The end is before the start';

  @override
  String get widgetUpcomingRecurringName => 'Upcoming recurring';

  @override
  String get dashboardNoUpcomingRecurring => 'No recurring transactions';

  @override
  String get widgetBudgetStatusName => 'Budget status';

  @override
  String get widgetBudgetTitle => 'Budget';

  @override
  String get budgetTypeAll => 'All';

  @override
  String get budgetTypeSemantic => 'Budget type';

  @override
  String get widgetNoBudgets => 'No budgets yet';

  @override
  String widgetNoBudgetsOfPeriod(String period) {
    return 'No $period budgets';
  }

  @override
  String get kindTransfers => 'Transfers';

  @override
  String get dashboardTransactionTypeSemantic => 'Transaction type';

  @override
  String dashboardNoTransactionsOfType(String type) {
    return 'No $type transactions';
  }

  @override
  String dashboardNoRecurringOfType(String type) {
    return 'No $type recurring transactions';
  }

  @override
  String get widgetNetWorthName => 'Net worth';

  @override
  String get widgetNetWorthNoHistory => 'Not enough history yet';

  @override
  String get netWorthPeriodSemantic => 'Period';

  @override
  String get netWorthPeriod3M => '3M';

  @override
  String get netWorthPeriod6M => '6M';

  @override
  String get netWorthPeriod1Y => '1Y';

  @override
  String get netWorthPeriod3Y => '3Y';

  @override
  String get netWorthPeriod5Y => '5Y';

  @override
  String get netWorthPeriodAll => 'All';

  @override
  String get widgetInvestmentsName => 'Investments';

  @override
  String get widgetInvestmentsPeriodSemantic => 'Period';

  @override
  String get netWorthPeriodYtd => 'YTD';

  @override
  String get widgetAllocationName => 'Allocation';

  @override
  String get widgetInsightName => 'Insight of the moment';

  @override
  String insightBudgetExceededTitle(String category) {
    return '$category over budget';
  }

  @override
  String insightBudgetAtRiskTitle(String category) {
    return '$category budget at risk';
  }

  @override
  String get insightRecurringDueToday => 'Payment due today';

  @override
  String get insightRecurringDueTomorrow => 'Payment due tomorrow';

  @override
  String insightUnusualTitle(String category) {
    return 'Unusual $category expense';
  }

  @override
  String insightUnusualDetail(String ratio) {
    return '$ratio× the usual';
  }

  @override
  String get insightPortfolioDropTitle => 'Portfolio down today';

  @override
  String get insightPortfolioGainTitle => 'Portfolio up today';

  @override
  String get insightNetWorthHighTitle => 'Highest net worth in a month';

  @override
  String get insightNoTransactionTodayTitle => 'Nothing recorded today';

  @override
  String get insightNoTransactionTodayDetail => 'Add today\'s transactions';

  @override
  String get insightNoRecentTitle => 'No recent transactions';

  @override
  String insightNoRecentDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days since the last one',
      one: '1 day since the last one',
    );
    return '$_temp0';
  }

  @override
  String get insightFirstTransactionTitle => 'Add your first transaction';

  @override
  String get insightFirstTransactionDetail => 'Start tracking your finances';

  @override
  String get insightAllGoodTitle => 'All good for today';

  @override
  String get insightAllGoodDetail => 'Nothing needs your attention';

  @override
  String get showcaseBudgetExceeded => 'Budget exceeded';

  @override
  String get showcaseRecurringDue => 'Recurring payment due';

  @override
  String get showcaseBudgetAtRisk => 'Budget at risk';

  @override
  String get showcaseUnusualExpense => 'Unusual expense';

  @override
  String get showcasePortfolioDrop => 'Portfolio drop';

  @override
  String get showcaseReminder => 'Reminder';

  @override
  String get showcasePositive => 'Good news';

  @override
  String get showcaseAllGood => 'No insight';

  @override
  String get transactionTypeAll => 'All';

  @override
  String get settingsWidgetShowcase => 'Widget showcase';

  @override
  String get showcaseIntro => 'Every widget, case and size, on demo data';

  @override
  String get showcaseWithData => 'With data';

  @override
  String get showcaseNewUser => 'New user, no data';

  @override
  String get categoriesGroupIncome => 'Income';

  @override
  String get categoriesGroupExpenses => 'Expenses';

  @override
  String get categoriesAddSemantic => 'Add category';

  @override
  String get categoriesEmptyTitle => 'No categories yet';

  @override
  String get categoriesEmptyMessage => 'Add one with the + button.';

  @override
  String categorySubcategoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count subcategories',
      one: '1 subcategory',
      zero: 'No subcategories',
    );
    return '$_temp0';
  }

  @override
  String get categoryPageEdit => 'Edit';

  @override
  String get categoryDetailSubcategories => 'Subcategories';

  @override
  String get categoryDetailTransactions => 'Transactions';

  @override
  String get categoryNoTransactions => 'No transactions in this category yet.';

  @override
  String get subcategoryNoTransactions =>
      'No transactions in this subcategory yet.';

  @override
  String get categoryDetailRecurring => 'Recurring';

  @override
  String get accountsAddSemantic => 'Add account';

  @override
  String get transactionDetailEdit => 'Edit';

  @override
  String get transactionEdit => 'Edit transaction';

  @override
  String get transactionSave => 'Save transaction';

  @override
  String get transactionDelete => 'Delete transaction';

  @override
  String get transactionDeleteTitle => 'Delete this transaction?';

  @override
  String get transactionDeleteMessage =>
      'It will be removed and balances, charts and budgets will be updated.';

  @override
  String get transactionDeleteConfirm => 'Delete';

  @override
  String get transactionUpdated => 'Transaction updated';

  @override
  String get transactionAskOnlyThis => 'Only this transaction';

  @override
  String get transactionAskRecurrence => 'The recurrence (next ones)';

  @override
  String get transactionSubcategoryNone => 'None';

  @override
  String get transactionShowRecurrence => 'Show recurrence';

  @override
  String get recurringPausedLabel => 'Paused';

  @override
  String get infoAppVersion => 'App version';

  @override
  String get infoCollaborators => 'Collaborators';

  @override
  String get infoCollaboratorsSubtitle => 'See the team behind this app';

  @override
  String get infoContribute => 'Want to contribute?';

  @override
  String get infoContributeSubtitle =>
      'Open an issue, submit a PR or just say hi on GitHub';

  @override
  String get infoPrivacyPolicy => 'Privacy policy';

  @override
  String get collaboratorsIntroTitle => 'Meet the team';

  @override
  String get collaboratorsIntro =>
      'Sossoldi is built and maintained by a passionate open source community. Every feature, fix and idea comes from people like you.';

  @override
  String get linkGithub => 'GitHub';

  @override
  String get linkLinkedin => 'LinkedIn';

  @override
  String get linkYoutube => 'YouTube';

  @override
  String get linkDiscord => 'Discord';

  @override
  String get linkWebsite => 'Website';

  @override
  String get communityFooter => 'Open source, built by the community';

  @override
  String get privacyIntro =>
      'Sossoldi is built as an open source app. This service is provided by us at no cost and it is intended for use as is. We are not interested in collecting any personal information. We believe such information is yours and yours alone. We do not store or transmit your personal details, nor do we include any advertising or analytics software that talks to third parties.';

  @override
  String get privacyCollectTitle => 'What information do we collect?';

  @override
  String get privacyCollectBody =>
      'Sossoldi does not collect any personal information or connect to the internet. Any information that you add in the app exists solely on your device and nowhere else.';

  @override
  String get privacyChangesTitle => 'Changes to this privacy policy';

  @override
  String get privacyChangesBody =>
      'We may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes.';

  @override
  String get privacyEffective => 'This policy is effective as of 2024-01-01';

  @override
  String get privacyContactTitle => 'Contact us';

  @override
  String get privacyContactBody =>
      'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at';

  @override
  String get notificationsReminderTitle => 'Add transaction reminder';

  @override
  String get notificationsReminderSubtitle =>
      'A nudge to log your transactions';

  @override
  String get notificationsRecurringTitle => 'Recurring transaction added';

  @override
  String get notificationsRecurringSubtitle =>
      'When a recurrence is booked in your transactions';

  @override
  String get notificationsFrequency => 'Frequency';

  @override
  String get notificationsDay => 'Day';

  @override
  String get notificationsTime => 'Time';

  @override
  String get reminderDaily => 'Daily';

  @override
  String get reminderWeekly => 'Weekly';

  @override
  String get reminderBiweekly => 'Every 2 weeks';

  @override
  String get reminderMonthly => 'Monthly';

  @override
  String get timePickerConfirm => 'Confirm';
}
