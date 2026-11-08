import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// Bottom bar tab: Dashboard
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom bar tab: Finance
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get navFinance;

  /// Bottom bar tab: Investments
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get navInvestments;

  /// Title of the add transaction screen and label of the + button
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransaction;

  /// Title of the settings screen and label of the gear button
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Label of the button that reveals hidden amounts
  ///
  /// In en, this message translates to:
  /// **'Show amounts'**
  String get showAmounts;

  /// Label of the button that hides every amount in the app
  ///
  /// In en, this message translates to:
  /// **'Hide amounts'**
  String get hideAmounts;

  /// Body of placeholder screens
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// Dashboard widget: income minus expenses of the current month
  ///
  /// In en, this message translates to:
  /// **'Monthly balance'**
  String get widgetMonthlyBalanceName;

  /// Dashboard widget: the most recent transactions
  ///
  /// In en, this message translates to:
  /// **'Latest transactions'**
  String get widgetLatestTransactionsName;

  /// Label above the month's income in the Monthly balance widget
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get widgetIncome;

  /// Label above the month's expenses in the Monthly balance widget
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get widgetExpense;

  /// Caption next to the change tag in the Monthly balance widget
  ///
  /// In en, this message translates to:
  /// **'Compared to last month on the same day'**
  String get widgetComparedToLastMonth;

  /// Chart legend: current month line
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get chartThisMonth;

  /// Chart legend: previous month dashed line
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get chartLastMonth;

  /// Title of the Dashboard top bar in edit mode
  ///
  /// In en, this message translates to:
  /// **'Edit Home'**
  String get editHome;

  /// Title of the add-widget sheet, its confirm button and the + button label
  ///
  /// In en, this message translates to:
  /// **'Add widget'**
  String get addWidget;

  /// Label of the check button that leaves edit mode
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get doneEditing;

  /// Cancel action of a sheet
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label of the - badge on a widget in edit mode
  ///
  /// In en, this message translates to:
  /// **'Remove widget'**
  String get removeWidget;

  /// Label of the resize handle on a widget in edit mode
  ///
  /// In en, this message translates to:
  /// **'Resize widget'**
  String get resizeWidget;

  /// Widget size name
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get widgetSizeSmall;

  /// Widget size name
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get widgetSizeMedium;

  /// Widget size name
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get widgetSizeLarge;

  /// Empty Dashboard message
  ///
  /// In en, this message translates to:
  /// **'Your Home is empty'**
  String get dashboardEmptyTitle;

  /// Hint shown in edit mode when the Dashboard has no widgets
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a widget'**
  String get dashboardEmptyEditHint;

  /// Settings row: dark theme switch
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// Title of the Finance page
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get financeTitle;

  /// Finance tab
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get financeTabOverview;

  /// Finance tab
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get financeTabTransactions;

  /// Finance tab
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get financeTabBudget;

  /// Finance tab
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get financeTabRecurring;

  /// Transactions view switch
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get transactionsViewList;

  /// Transactions view switch
  ///
  /// In en, this message translates to:
  /// **'Charts'**
  String get transactionsViewCharts;

  /// Placeholder of the transactions search field
  ///
  /// In en, this message translates to:
  /// **'Search transactions'**
  String get searchTransactions;

  /// Label of the clear button of a search field
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// Filter button label and title of the filters sheet
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Apply the filters
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get filtersApply;

  /// Reset the filters to their defaults
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filtersReset;

  /// Filter name
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get filterDate;

  /// Filter name
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get filterType;

  /// Filter name
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filterCategory;

  /// Filter name
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get filterAmount;

  /// Filter name
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get filterAccount;

  /// Transaction type
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get typeExpense;

  /// Transaction type
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get typeIncome;

  /// Transaction type
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get typeTransfer;

  /// Label of the X on an active filter chip
  ///
  /// In en, this message translates to:
  /// **'Remove filter'**
  String get removeFilter;

  /// Date filter shortcut
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get datePresetThisMonth;

  /// Date filter shortcut
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get datePresetLastMonth;

  /// Date filter shortcut
  ///
  /// In en, this message translates to:
  /// **'Last 3 months'**
  String get datePresetLast3Months;

  /// Date filter shortcut
  ///
  /// In en, this message translates to:
  /// **'This year'**
  String get datePresetThisYear;

  /// Date filter shortcut
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get datePresetAllTime;

  /// Date filter shortcut
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get datePresetCustom;

  /// Placeholder of the minimum amount field
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get amountMin;

  /// Placeholder of the maximum amount field
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get amountMax;

  /// Empty state of the transaction list
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get emptyTransactionsTitle;

  /// Hint when the search or filters hide everything
  ///
  /// In en, this message translates to:
  /// **'Try changing the search or the filters.'**
  String get emptyTransactionsFiltered;

  /// Hint when there are no filters
  ///
  /// In en, this message translates to:
  /// **'There are no transactions in this period.'**
  String get emptyTransactionsPlain;

  /// Button of the empty state
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// Pagination button label
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get paginationPrevious;

  /// Pagination button label
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get paginationNext;

  /// Calendar button label
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// Calendar button label
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// Hint under the amount filter
  ///
  /// In en, this message translates to:
  /// **'Amounts in {currency}'**
  String amountsIn(String currency);

  /// Label of the time range select in the charts
  ///
  /// In en, this message translates to:
  /// **'Select time range'**
  String get chartsSelectTimeRange;

  /// Time range
  ///
  /// In en, this message translates to:
  /// **'Current month'**
  String get rangeCurrentMonth;

  /// Time range
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get rangeLastMonth;

  /// Time range
  ///
  /// In en, this message translates to:
  /// **'Last 3 months'**
  String get rangeLast3Months;

  /// Time range
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get rangeLast6Months;

  /// Time range
  ///
  /// In en, this message translates to:
  /// **'Year to date'**
  String get rangeYearToDate;

  /// Time range
  ///
  /// In en, this message translates to:
  /// **'Last 12 months'**
  String get rangeLast12Months;

  /// Charts segmented control
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get kindExpenses;

  /// Charts segmented control
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get kindIncome;

  /// Label of the period total
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get chartTotal;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Categories breakdown'**
  String get chartCategoriesBreakdown;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Breakdown over time'**
  String get chartBreakdownOverTime;

  /// Label of the granularity select
  ///
  /// In en, this message translates to:
  /// **'Snapshot'**
  String get chartSnapshot;

  /// Granularity option
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get granularityWeekly;

  /// Granularity option
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get granularityMonthly;

  /// Empty state of the charts
  ///
  /// In en, this message translates to:
  /// **'No transactions in this period'**
  String get emptyChartsTitle;

  /// Hint of the empty state of the charts
  ///
  /// In en, this message translates to:
  /// **'Try another time range or fewer filters.'**
  String get emptyChartsFiltered;

  /// Screen reader label of the donut
  ///
  /// In en, this message translates to:
  /// **'Breakdown by category'**
  String get chartDonutSemantics;

  /// Screen reader label of the area chart
  ///
  /// In en, this message translates to:
  /// **'Breakdown over time by category'**
  String get chartAreaSemantics;

  /// Change against the previous period of the same length (PoP = period over period)
  ///
  /// In en, this message translates to:
  /// **'{value} PoP'**
  String changeVsPrevious(String value);

  /// Settings: language select
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Settings: follow the device language
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get languageSystem;

  /// Settings: main currency select
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Budget period
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get periodWeekly;

  /// Budget period
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get periodMonthly;

  /// Budget period
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get periodQuarterly;

  /// Budget period
  ///
  /// In en, this message translates to:
  /// **'Semiannual'**
  String get periodSemiannual;

  /// Budget period
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get periodYearly;

  /// Title of the overall budget card
  ///
  /// In en, this message translates to:
  /// **'Overall budget'**
  String get budgetOverall;

  /// Title of the budgets list
  ///
  /// In en, this message translates to:
  /// **'Categories breakdown'**
  String get budgetCategoriesBreakdown;

  /// Screen reader label of the segmented bar
  ///
  /// In en, this message translates to:
  /// **'Budgets of the period'**
  String get budgetsBarSemantics;

  /// Empty state of the Budget tab
  ///
  /// In en, this message translates to:
  /// **'No budgets for this period'**
  String get budgetEmptyTitle;

  /// Hint of the empty Budget tab
  ///
  /// In en, this message translates to:
  /// **'You will be able to add budgets from Settings.'**
  String get budgetEmptyHint;

  /// Edit button of the budget page
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get budgetEdit;

  /// Section title of the budget page
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budgetSectionBudget;

  /// Section title of the expenses counted in a budget
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get budgetSectionExpenses;

  /// Placeholder of the search field of a budget's expenses
  ///
  /// In en, this message translates to:
  /// **'Search expenses'**
  String get budgetSearchExpenses;

  /// Label of the amount field in edit mode
  ///
  /// In en, this message translates to:
  /// **'Budget amount'**
  String get budgetAmount;

  /// Error: the amount is empty or not a number
  ///
  /// In en, this message translates to:
  /// **'Enter an amount.'**
  String get budgetAmountRequired;

  /// Error: the amount is zero or negative
  ///
  /// In en, this message translates to:
  /// **'The amount must be greater than zero.'**
  String get budgetAmountPositive;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete budget'**
  String get budgetDelete;

  /// Title of the delete confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete this budget?'**
  String get budgetDeleteTitle;

  /// Confirm button of the delete confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get budgetDeleteConfirm;

  /// Empty state of the expenses of a budget
  ///
  /// In en, this message translates to:
  /// **'No expenses in this period'**
  String get emptyBudgetExpensesTitle;

  /// What is left of a budget
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String budgetLeft(String amount);

  /// How much a budget was exceeded by
  ///
  /// In en, this message translates to:
  /// **'{amount} over'**
  String budgetOver(String amount);

  /// Body of the delete confirmation
  ///
  /// In en, this message translates to:
  /// **'The {period} budget of {category} will be removed. Your expenses are not affected.'**
  String budgetDeleteMessage(String period, String category);

  /// Label of the arrow that goes to the previous month
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get recurringPreviousMonth;

  /// Label of the arrow that goes to the next month
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get recurringNextMonth;

  /// Label of the button that opens the month picker
  ///
  /// In en, this message translates to:
  /// **'Choose the month'**
  String get recurringPickMonth;

  /// Title of the month picker
  ///
  /// In en, this message translates to:
  /// **'Select month'**
  String get recurringPickMonthTitle;

  /// Month picker: previous year
  ///
  /// In en, this message translates to:
  /// **'Previous year'**
  String get recurringPreviousYear;

  /// Month picker: next year
  ///
  /// In en, this message translates to:
  /// **'Next year'**
  String get recurringNextYear;

  /// Button at the end of the recurring list and title of its placeholder screen
  ///
  /// In en, this message translates to:
  /// **'Add recurrent transaction'**
  String get recurringAdd;

  /// Empty state of the Recurring list for a whole month
  ///
  /// In en, this message translates to:
  /// **'No recurring transactions this month'**
  String get recurringEmptyMonthTitle;

  /// Empty state of the Recurring list for a selected day
  ///
  /// In en, this message translates to:
  /// **'Nothing on this day'**
  String get recurringEmptyDayTitle;

  /// Edit button of the recurring transaction page
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get recurringEdit;

  /// Section of the recurring transaction page
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get recurringSectionDetails;

  /// Field: how often a recurring transaction repeats
  ///
  /// In en, this message translates to:
  /// **'Recurrence period'**
  String get recurringPeriod;

  /// Field: amount of a recurring transaction
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get recurringAmount;

  /// Switch: the recurring transaction is active (off = paused)
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get recurringActive;

  /// Section with the transactions a recurring one generated
  ///
  /// In en, this message translates to:
  /// **'Old transactions'**
  String get recurringSectionOld;

  /// Label of the time range select
  ///
  /// In en, this message translates to:
  /// **'Select time range'**
  String get recurringRangeLabel;

  /// Time range option
  ///
  /// In en, this message translates to:
  /// **'Last 3 months'**
  String get recurringRangeLast3;

  /// Time range option
  ///
  /// In en, this message translates to:
  /// **'Last 6 months'**
  String get recurringRangeLast6;

  /// Time range option
  ///
  /// In en, this message translates to:
  /// **'Last 12 months'**
  String get recurringRangeLast12;

  /// Time range option: no limit
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get recurringRangeAll;

  /// Recurrence period
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get recurringFrequencyWeekly;

  /// Recurrence period
  ///
  /// In en, this message translates to:
  /// **'Every 2 weeks'**
  String get recurringFrequencyBiweekly;

  /// Recurrence period
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get recurringFrequencyMonthly;

  /// Recurrence period
  ///
  /// In en, this message translates to:
  /// **'Every 2 months'**
  String get recurringFrequencyBimonthly;

  /// Recurrence period
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get recurringFrequencyQuarterly;

  /// Recurrence period
  ///
  /// In en, this message translates to:
  /// **'Semiannual'**
  String get recurringFrequencySemiannual;

  /// Recurrence period
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get recurringFrequencyYearly;

  /// Empty state of the old transactions
  ///
  /// In en, this message translates to:
  /// **'No transactions in this period'**
  String get recurringHistoryEmpty;

  /// Red button at the bottom of the page in edit mode
  ///
  /// In en, this message translates to:
  /// **'Delete recurrence'**
  String get recurringDelete;

  /// Title of the delete confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete this recurring transaction?'**
  String get recurringDeleteTitle;

  /// Confirm button of the delete confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get recurringDeleteConfirm;

  /// Body of the delete confirmation
  ///
  /// In en, this message translates to:
  /// **'{name} will not repeat any more. The transactions already recorded are kept.'**
  String recurringDeleteMessage(String name);

  /// Accessibility label of a close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Overview section title
  ///
  /// In en, this message translates to:
  /// **'Your accounts'**
  String get overviewAccounts;

  /// Button next to the accounts and budget sections
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get overviewManage;

  /// Title of the placeholder screen behind Manage (budgets)
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get overviewBudgetsTitle;

  /// Overview section title
  ///
  /// In en, this message translates to:
  /// **'Upcoming recurrences'**
  String get overviewUpcoming;

  /// Overview: empty upcoming recurrences
  ///
  /// In en, this message translates to:
  /// **'No recurring transactions until the end of the month'**
  String get overviewNoUpcoming;

  /// Overview section title
  ///
  /// In en, this message translates to:
  /// **'Cash flow'**
  String get overviewCashFlow;

  /// Overview section title
  ///
  /// In en, this message translates to:
  /// **'Budget status'**
  String get overviewBudgetStatus;

  /// Overview: empty budget list
  ///
  /// In en, this message translates to:
  /// **'No budgets for this month'**
  String get overviewNoBudgets;

  /// Cash flow legend
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get legendIncome;

  /// Cash flow legend
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get legendExpense;

  /// Cash flow legend
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get legendBalance;

  /// Screen reader label of the cash flow chart
  ///
  /// In en, this message translates to:
  /// **'Cash flow of the month: income, expenses and balance day by day'**
  String get cashFlowSemantics;

  /// Digest message title
  ///
  /// In en, this message translates to:
  /// **'Budget exceeded'**
  String get digestBudgetExceededTitle;

  /// Digest: a budget was exceeded
  ///
  /// In en, this message translates to:
  /// **'You went over the {category} budget by {amount}'**
  String digestBudgetExceeded(String category, String amount);

  /// Digest message title
  ///
  /// In en, this message translates to:
  /// **'Budget at risk'**
  String get digestBudgetAtRiskTitle;

  /// Digest: a budget is close to its limit
  ///
  /// In en, this message translates to:
  /// **'The {category} budget is at {percent} with {days, plural, =1{1 day} other{{days} days}} left'**
  String digestBudgetAtRisk(String category, String percent, int days);

  /// Digest message title
  ///
  /// In en, this message translates to:
  /// **'Good month so far'**
  String get digestBelowTitle;

  /// Digest: spending under the average
  ///
  /// In en, this message translates to:
  /// **'You are spending {amount} less than the average of the last 3 months'**
  String digestBelow(String amount);

  /// Digest message title
  ///
  /// In en, this message translates to:
  /// **'Spending above average'**
  String get digestAboveTitle;

  /// Digest: spending over the average
  ///
  /// In en, this message translates to:
  /// **'You are spending {amount} more than the average of the last 3 months'**
  String digestAbove(String amount);

  /// Digest message title
  ///
  /// In en, this message translates to:
  /// **'Payments coming up'**
  String get digestRecurrencesTitle;

  /// Digest: one large recurring payment is coming
  ///
  /// In en, this message translates to:
  /// **'{name} ({amount}) is due in the next {days} days'**
  String digestRecurrencesOne(String name, String amount, int days);

  /// Digest: several large recurring payments are coming
  ///
  /// In en, this message translates to:
  /// **'{count} recurring payments in the next {days} days, {amount} in total'**
  String digestRecurrencesMany(int count, int days, String amount);

  /// Digest message title
  ///
  /// In en, this message translates to:
  /// **'Spending is growing'**
  String get digestGrowthTitle;

  /// Digest: a category grew
  ///
  /// In en, this message translates to:
  /// **'Spending on {category} is up {percent} on the same days of last month'**
  String digestGrowth(String category, String percent);

  /// Digest message title
  ///
  /// In en, this message translates to:
  /// **'All good'**
  String get digestAllGoodTitle;

  /// Digest: nothing to report
  ///
  /// In en, this message translates to:
  /// **'Everything is in order this month'**
  String get digestAllGood;

  /// Title of the Investments page
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get investmentsTitle;

  /// Investments tab
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get investmentsTabOverview;

  /// Investments tab
  ///
  /// In en, this message translates to:
  /// **'Positions'**
  String get investmentsTabPositions;

  /// Investments tab
  ///
  /// In en, this message translates to:
  /// **'Movements'**
  String get investmentsTabMovements;

  /// Caption under the title: prices updated less than a minute ago
  ///
  /// In en, this message translates to:
  /// **'Updated just now'**
  String get investmentsUpdatedNow;

  /// Caption: prices updated minutes ago
  ///
  /// In en, this message translates to:
  /// **'Updated {count} min ago'**
  String investmentsUpdatedMinutes(int count);

  /// Caption: prices updated hours ago
  ///
  /// In en, this message translates to:
  /// **'Updated {count} h ago'**
  String investmentsUpdatedHours(int count);

  /// Caption: prices updated days ago
  ///
  /// In en, this message translates to:
  /// **'Updated {count} d ago'**
  String investmentsUpdatedDays(int count);

  /// Label of the portfolio value card
  ///
  /// In en, this message translates to:
  /// **'Portfolio value'**
  String get investmentsPortfolioValue;

  /// Label of the cash in the portfolio card
  ///
  /// In en, this message translates to:
  /// **'Available liquidity'**
  String get investmentsLiquidity;

  /// Section title of the chart
  ///
  /// In en, this message translates to:
  /// **'Market value'**
  String get investmentsMarketValue;

  /// Section title of the donut
  ///
  /// In en, this message translates to:
  /// **'Asset allocations'**
  String get investmentsAllocations;

  /// Chart period: one day
  ///
  /// In en, this message translates to:
  /// **'1D'**
  String get periodDay;

  /// Chart period: five days
  ///
  /// In en, this message translates to:
  /// **'5D'**
  String get periodFiveDays;

  /// Chart period: one month
  ///
  /// In en, this message translates to:
  /// **'1M'**
  String get periodMonth;

  /// Chart period: six months
  ///
  /// In en, this message translates to:
  /// **'6M'**
  String get periodSixMonths;

  /// Chart period: year to date
  ///
  /// In en, this message translates to:
  /// **'YTD'**
  String get periodYearToDate;

  /// Chart period: one year
  ///
  /// In en, this message translates to:
  /// **'1Y'**
  String get periodYear;

  /// Chart period: five years
  ///
  /// In en, this message translates to:
  /// **'5Y'**
  String get periodFiveYears;

  /// Chart legend and tooltip: value of the positions
  ///
  /// In en, this message translates to:
  /// **'Market value'**
  String get legendMarketValue;

  /// Chart legend and tooltip: capital invested
  ///
  /// In en, this message translates to:
  /// **'Invested'**
  String get legendInvested;

  /// Chart tooltip: value minus invested
  ///
  /// In en, this message translates to:
  /// **'Difference'**
  String get legendDifference;

  /// Screen reader label of the market value chart
  ///
  /// In en, this message translates to:
  /// **'Market value of the portfolio and capital invested over time'**
  String get marketValueSemantics;

  /// Allocation switch
  ///
  /// In en, this message translates to:
  /// **'Asset class'**
  String get allocationAssetClass;

  /// Allocation switch
  ///
  /// In en, this message translates to:
  /// **'Single asset'**
  String get allocationSingleAsset;

  /// Allocation: asset class
  ///
  /// In en, this message translates to:
  /// **'ETFs'**
  String get allocationEtf;

  /// Allocation: asset class
  ///
  /// In en, this message translates to:
  /// **'Stocks'**
  String get allocationStocks;

  /// Allocation: asset class
  ///
  /// In en, this message translates to:
  /// **'Bonds'**
  String get allocationBonds;

  /// Allocation: other assets (manual ones, or the smallest ones)
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get allocationOther;

  /// Allocation: cash
  ///
  /// In en, this message translates to:
  /// **'Liquidity'**
  String get allocationLiquidity;

  /// Screen reader label of the donut
  ///
  /// In en, this message translates to:
  /// **'Allocation of the portfolio'**
  String get allocationSemantics;

  /// Empty state of the Investments Overview
  ///
  /// In en, this message translates to:
  /// **'No investments yet'**
  String get investmentsEmptyTitle;

  /// Empty state hint
  ///
  /// In en, this message translates to:
  /// **'Your positions will show up here.'**
  String get investmentsEmptyHint;

  /// Digest message title
  ///
  /// In en, this message translates to:
  /// **'All good'**
  String get investmentsDigestAllGoodTitle;

  /// Digest: nothing to report
  ///
  /// In en, this message translates to:
  /// **'Nothing to report on your investments'**
  String get investmentsDigestAllGood;

  /// Digest message title
  ///
  /// In en, this message translates to:
  /// **'Concentration'**
  String get investmentsDigestConcentrationTitle;

  /// Digest: one asset is most of the portfolio
  ///
  /// In en, this message translates to:
  /// **'**{percent}** of your portfolio is in a single asset, {name}. Consider diversifying'**
  String investmentsDigestConcentration(String percent, String name);

  /// Digest message title
  ///
  /// In en, this message translates to:
  /// **'Portfolio down'**
  String get investmentsDigestDropTitle;

  /// Digest: the positions lost value in the month
  ///
  /// In en, this message translates to:
  /// **'Your portfolio lost **{amount}** (**{percent}**) over the last month'**
  String investmentsDigestDrop(String amount, String percent);

  /// Digest message title
  ///
  /// In en, this message translates to:
  /// **'Portfolio growing'**
  String get investmentsDigestGrowthTitle;

  /// Digest: the positions gained value in the month
  ///
  /// In en, this message translates to:
  /// **'Your invested wealth grew by **{amount}** over the last month'**
  String investmentsDigestGrowth(String amount);

  /// Digest message title
  ///
  /// In en, this message translates to:
  /// **'Dividend coming'**
  String get investmentsDigestDividendTitle;

  /// Digest: one dividend is expected soon
  ///
  /// In en, this message translates to:
  /// **'{name} pays **{amount}** in dividends within {days, plural, =1{1 day} other{{days} days}}'**
  String investmentsDigestDividendOne(String name, String amount, int days);

  /// Digest: several dividends are expected soon
  ///
  /// In en, this message translates to:
  /// **'{count} dividends worth **{amount}** in total are expected within {days, plural, =1{1 day} other{{days} days}}'**
  String investmentsDigestDividendMany(int count, String amount, int days);

  /// Section title of the positions list
  ///
  /// In en, this message translates to:
  /// **'Positions'**
  String get positionsTitle;

  /// Placeholder of the positions search
  ///
  /// In en, this message translates to:
  /// **'Search positions'**
  String get positionsSearch;

  /// Filter group in the positions filters
  ///
  /// In en, this message translates to:
  /// **'Asset type'**
  String get positionsFilterType;

  /// Empty state of the positions list
  ///
  /// In en, this message translates to:
  /// **'No positions found'**
  String get positionsEmptyTitle;

  /// Empty state hint when search or filters are on
  ///
  /// In en, this message translates to:
  /// **'Try another search or other filters.'**
  String get positionsEmptyHint;

  /// Empty state when the portfolio has no positions
  ///
  /// In en, this message translates to:
  /// **'No positions yet'**
  String get positionsNoneTitle;

  /// Position kind
  ///
  /// In en, this message translates to:
  /// **'ETF'**
  String get kindEtf;

  /// Position kind
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get kindStock;

  /// Position kind
  ///
  /// In en, this message translates to:
  /// **'Bond'**
  String get kindBond;

  /// Position kind: entered by hand
  ///
  /// In en, this message translates to:
  /// **'Manual asset'**
  String get kindManual;

  /// Kind of manual asset
  ///
  /// In en, this message translates to:
  /// **'Pension fund'**
  String get manualPension;

  /// Kind of manual asset
  ///
  /// In en, this message translates to:
  /// **'Collectible'**
  String get manualCollectible;

  /// Kind of manual asset
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get manualArt;

  /// Kind of manual asset
  ///
  /// In en, this message translates to:
  /// **'Real estate'**
  String get manualRealEstate;

  /// Kind of manual asset
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get manualOther;

  /// Section title
  ///
  /// In en, this message translates to:
  /// **'Portfolio breakdown'**
  String get breakdownTitle;

  /// Breakdown switch
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get breakdownRegion;

  /// Breakdown switch
  ///
  /// In en, this message translates to:
  /// **'Sector'**
  String get breakdownSector;

  /// Section of the position page
  ///
  /// In en, this message translates to:
  /// **'Your position'**
  String get positionYour;

  /// Row of the position page
  ///
  /// In en, this message translates to:
  /// **'Market value'**
  String get positionMarketValue;

  /// Row of the position page
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get positionQuantity;

  /// Row of the position page and chart legend
  ///
  /// In en, this message translates to:
  /// **'Average cost'**
  String get positionAverageCost;

  /// Row of the position page
  ///
  /// In en, this message translates to:
  /// **'Invested capital'**
  String get positionInvested;

  /// Row of the position page
  ///
  /// In en, this message translates to:
  /// **'Profit / loss'**
  String get positionPnl;

  /// Row of the position page: share of the portfolio
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get positionWeight;

  /// Section of the position page
  ///
  /// In en, this message translates to:
  /// **'Asset info'**
  String get positionAssetInfo;

  /// Asset info row
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get infoType;

  /// Asset info row
  ///
  /// In en, this message translates to:
  /// **'Sector'**
  String get infoSector;

  /// Asset info row
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get infoRegion;

  /// Asset info row
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get infoCurrency;

  /// Asset info row
  ///
  /// In en, this message translates to:
  /// **'Exchange'**
  String get infoExchange;

  /// Section of the position page
  ///
  /// In en, this message translates to:
  /// **'Operations'**
  String get positionOperations;

  /// Empty state of the operations
  ///
  /// In en, this message translates to:
  /// **'No operations yet'**
  String get operationsEmpty;

  /// Operation type
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get operationBuy;

  /// Operation type
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get operationSell;

  /// Operation type
  ///
  /// In en, this message translates to:
  /// **'Dividend'**
  String get operationDividend;

  /// Under the amount of an operation: units and price
  ///
  /// In en, this message translates to:
  /// **'{quantity} × {price}'**
  String operationDetails(String quantity, String price);

  /// Button of the position page
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get positionBuy;

  /// Button of the position page
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get positionSell;

  /// Button of the position page
  ///
  /// In en, this message translates to:
  /// **'Add dividend'**
  String get positionAddDividend;

  /// Chart legend and tooltip
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get positionPrice;

  /// Screen reader label of the price chart
  ///
  /// In en, this message translates to:
  /// **'Price of the asset over time and average cost'**
  String get positionPriceChartSemantics;

  /// Price in the currency of the asset
  ///
  /// In en, this message translates to:
  /// **'{price} per unit'**
  String positionPriceInCurrency(String price);

  /// Asset info row of an ETF
  ///
  /// In en, this message translates to:
  /// **'Distribution'**
  String get infoDistribution;

  /// ETF distribution
  ///
  /// In en, this message translates to:
  /// **'Accumulating'**
  String get distAccumulating;

  /// ETF distribution
  ///
  /// In en, this message translates to:
  /// **'Distributing'**
  String get distDistributing;

  /// Asset info row of an ETF: yearly cost
  ///
  /// In en, this message translates to:
  /// **'TER'**
  String get infoTer;

  /// Asset info row of a stock
  ///
  /// In en, this message translates to:
  /// **'Dividend yield'**
  String get infoDividendYield;

  /// Asset info row of a bond
  ///
  /// In en, this message translates to:
  /// **'Coupon'**
  String get infoCoupon;

  /// Asset info row of a bond
  ///
  /// In en, this message translates to:
  /// **'Maturity'**
  String get infoMaturity;

  /// Asset info row of a bond
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get infoDuration;

  /// A duration in years
  ///
  /// In en, this message translates to:
  /// **'{value} years'**
  String infoYears(String value);

  /// Label of the three dots button of the position page
  ///
  /// In en, this message translates to:
  /// **'More actions'**
  String get positionMoreActions;

  /// Action of a manual asset: enter its current value
  ///
  /// In en, this message translates to:
  /// **'Update value'**
  String get positionUpdateValue;

  /// Placeholder of the movements search
  ///
  /// In en, this message translates to:
  /// **'Search movements'**
  String get movementsSearch;

  /// Section of the expected dividends
  ///
  /// In en, this message translates to:
  /// **'Up next'**
  String get movementsUpNext;

  /// Empty state of the movements list
  ///
  /// In en, this message translates to:
  /// **'No movements found'**
  String get movementsEmptyTitle;

  /// Empty state hint
  ///
  /// In en, this message translates to:
  /// **'Try another search or other filters.'**
  String get movementsEmptyHint;

  /// Empty state: the portfolio has no movements
  ///
  /// In en, this message translates to:
  /// **'No movements yet'**
  String get movementsNoneTitle;

  /// Movement type
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get movementTypeBuy;

  /// Movement type
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get movementTypeSell;

  /// Movement type
  ///
  /// In en, this message translates to:
  /// **'Dividend'**
  String get movementTypeDividend;

  /// Movement type
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get movementTypeCost;

  /// Detail line of a buy or sell: price per unit
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get movementPrice;

  /// Detail line of a buy or sell
  ///
  /// In en, this message translates to:
  /// **'{quantity} · Price {price}'**
  String movementDetails(String quantity, String price);

  /// Period filter
  ///
  /// In en, this message translates to:
  /// **'Current month'**
  String get movementPeriodCurrentMonth;

  /// Period filter
  ///
  /// In en, this message translates to:
  /// **'Last 3 months'**
  String get movementPeriodLast3Months;

  /// Period filter
  ///
  /// In en, this message translates to:
  /// **'Current year'**
  String get movementPeriodCurrentYear;

  /// Period filter
  ///
  /// In en, this message translates to:
  /// **'Last 12 months'**
  String get movementPeriodLast12Months;

  /// Period filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get movementPeriodAll;

  /// Filter group
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get movementFilterPeriod;

  /// Filter group
  ///
  /// In en, this message translates to:
  /// **'Movement type'**
  String get movementFilterType;

  /// Filter group
  ///
  /// In en, this message translates to:
  /// **'Asset type'**
  String get movementFilterAssetType;

  /// Filter group
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get movementFilterAsset;

  /// Filter: no single asset
  ///
  /// In en, this message translates to:
  /// **'All assets'**
  String get movementFilterAnyAsset;

  /// Title of the form to add a movement
  ///
  /// In en, this message translates to:
  /// **'New movement'**
  String get movementNew;

  /// Button that saves a new movement
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get movementAdd;

  /// Form field
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get movementFieldAsset;

  /// Form field of a cost
  ///
  /// In en, this message translates to:
  /// **'Asset (optional)'**
  String get movementFieldAssetOptional;

  /// Form: no asset for a cost
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get movementNoAsset;

  /// Placeholder of the asset search in the form
  ///
  /// In en, this message translates to:
  /// **'Search an asset'**
  String get movementSearchAsset;

  /// Button to pick another asset in the form
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get movementChangeAsset;

  /// Form switch: asset from the catalog
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get movementAssetCatalog;

  /// Form switch: asset entered by hand
  ///
  /// In en, this message translates to:
  /// **'Manual asset'**
  String get movementAssetManual;

  /// Form field of a manual asset
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get movementManualName;

  /// Form field of a manual asset
  ///
  /// In en, this message translates to:
  /// **'Kind of asset'**
  String get movementManualType;

  /// Form field
  ///
  /// In en, this message translates to:
  /// **'Broker account'**
  String get movementFieldAccount;

  /// Form field
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get movementFieldDate;

  /// Form field
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get movementFieldQuantity;

  /// Form field
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get movementFieldUnitPrice;

  /// Form field
  ///
  /// In en, this message translates to:
  /// **'Commission (optional)'**
  String get movementFieldFee;

  /// Form field of a dividend or a cost
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get movementFieldAmount;

  /// Form field of a dividend
  ///
  /// In en, this message translates to:
  /// **'Net amount'**
  String get movementFieldNetAmount;

  /// Form field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get movementFieldDescription;

  /// Form field
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get movementFieldDescriptionOptional;

  /// Under the quantity of a sell
  ///
  /// In en, this message translates to:
  /// **'You hold {quantity}'**
  String movementHeld(String quantity);

  /// Form error
  ///
  /// In en, this message translates to:
  /// **'Required.'**
  String get movementErrRequired;

  /// Form error
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number.'**
  String get movementErrNumber;

  /// Form error
  ///
  /// In en, this message translates to:
  /// **'It must be greater than zero.'**
  String get movementErrPositive;

  /// Form error
  ///
  /// In en, this message translates to:
  /// **'The date cannot be in the future.'**
  String get movementErrFuture;

  /// Form error
  ///
  /// In en, this message translates to:
  /// **'Choose an asset.'**
  String get movementErrChooseAsset;

  /// Message when a movement would make the quantity negative
  ///
  /// In en, this message translates to:
  /// **'On {date} you would hold less than zero of this asset. Nothing was changed.'**
  String movementErrNegative(String date);

  /// Generic form error
  ///
  /// In en, this message translates to:
  /// **'The movement is not valid.'**
  String get movementErrInvalid;

  /// Warning in the form of a buy
  ///
  /// In en, this message translates to:
  /// **'This is more than your available liquidity: it will go to {amount}.'**
  String movementLiquidityWarning(String amount);

  /// Edit button of the movement page
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get movementDetailEdit;

  /// Row of the movement page
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get movementDetailTotal;

  /// Row of the movement page
  ///
  /// In en, this message translates to:
  /// **'Asset'**
  String get movementDetailAsset;

  /// Row of the movement page
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get movementDetailType;

  /// Row of the movement page
  ///
  /// In en, this message translates to:
  /// **'Broker account'**
  String get movementDetailAccount;

  /// Row of the movement page
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get movementDetailDate;

  /// Row of the movement page
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get movementDetailQuantity;

  /// Row of the movement page
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get movementDetailPrice;

  /// Row of the movement page
  ///
  /// In en, this message translates to:
  /// **'Commission'**
  String get movementDetailFee;

  /// Red button of the movement page in edit mode
  ///
  /// In en, this message translates to:
  /// **'Delete movement'**
  String get movementDelete;

  /// Title of the delete confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete this movement?'**
  String get movementDeleteTitle;

  /// Body of the delete confirmation
  ///
  /// In en, this message translates to:
  /// **'The position and the liquidity will be worked out again without it.'**
  String get movementDeleteMessage;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get movementDeleteConfirm;

  /// Tag of a dividend that is still to come
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get movementDividendExpected;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SOSSOLDI'**
  String get appName;

  /// No description provided for @onboardingSplashWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to'**
  String get onboardingSplashWelcome;

  /// No description provided for @onboardingSplashTagline.
  ///
  /// In en, this message translates to:
  /// **'The personal finance app of the Mr. RIP community'**
  String get onboardingSplashTagline;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Set up the app'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A few steps and you\'ll be ready to keep track of your personal finances (almost) like Mr. Rip'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @onboardingChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get onboardingChooseLanguage;

  /// No description provided for @onboardingDefault.
  ///
  /// In en, this message translates to:
  /// **'default'**
  String get onboardingDefault;

  /// No description provided for @onboardingStartSetup.
  ///
  /// In en, this message translates to:
  /// **'Start the setup'**
  String get onboardingStartSetup;

  /// No description provided for @onboardingOr.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get onboardingOr;

  /// No description provided for @onboardingImport.
  ///
  /// In en, this message translates to:
  /// **'Import data from another app'**
  String get onboardingImport;

  /// No description provided for @onboardingImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get onboardingImportTitle;

  /// No description provided for @onboardingStep.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String onboardingStep(int current, int total);

  /// No description provided for @onboardingStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your currency and setup the accounts'**
  String get onboardingStep1Subtitle;

  /// No description provided for @onboardingMainCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select main currency'**
  String get onboardingMainCurrency;

  /// No description provided for @onboardingYourAccounts.
  ///
  /// In en, this message translates to:
  /// **'Your accounts'**
  String get onboardingYourAccounts;

  /// No description provided for @onboardingFirstAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your first account'**
  String get onboardingFirstAccount;

  /// No description provided for @onboardingCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get onboardingCreateAccount;

  /// No description provided for @onboardingAddAccount.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get onboardingAddAccount;

  /// No description provided for @onboardingNextStep.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get onboardingNextStep;

  /// No description provided for @accountNew.
  ///
  /// In en, this message translates to:
  /// **'New account'**
  String get accountNew;

  /// No description provided for @accountEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get accountEdit;

  /// No description provided for @accountMainInfo.
  ///
  /// In en, this message translates to:
  /// **'Main info'**
  String get accountMainInfo;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get accountName;

  /// No description provided for @accountNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your account name'**
  String get accountNamePlaceholder;

  /// No description provided for @accountAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get accountAmount;

  /// No description provided for @accountIconAndColor.
  ///
  /// In en, this message translates to:
  /// **'Icon and color'**
  String get accountIconAndColor;

  /// No description provided for @accountTapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get accountTapToSelect;

  /// No description provided for @accountChooseIcon.
  ///
  /// In en, this message translates to:
  /// **'Choose an icon'**
  String get accountChooseIcon;

  /// No description provided for @accountColorHue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get accountColorHue;

  /// No description provided for @accountColorSaturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get accountColorSaturation;

  /// No description provided for @accountSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get accountSave;

  /// No description provided for @accountDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDelete;

  /// No description provided for @accountDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this account?'**
  String get accountDeleteTitle;

  /// No description provided for @accountDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get accountDeleteConfirm;

  /// No description provided for @accountErrName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get accountErrName;

  /// No description provided for @accountErrNameTaken.
  ///
  /// In en, this message translates to:
  /// **'You already have an account with this name'**
  String get accountErrNameTaken;

  /// No description provided for @accountErrAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get accountErrAmount;

  /// No description provided for @accountErrAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get accountErrAmountInvalid;

  /// No description provided for @accountErrInUse.
  ///
  /// In en, this message translates to:
  /// **'This account has transactions, so it cannot be deleted or change currency'**
  String get accountErrInUse;

  /// Settings hub row and title of the app settings page
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get settingsAppSettings;

  /// Settings hub row and title of the prototype settings page
  ///
  /// In en, this message translates to:
  /// **'Prototype settings'**
  String get settingsPrototypeSettings;

  /// App settings row and title of its page
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get settingsAuthentication;

  /// App settings row and title of its page
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get settingsAccounts;

  /// App settings row and title of its page
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get settingsCategories;

  /// App settings row and title of its page
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get settingsBudgets;

  /// App settings row and title of its page
  ///
  /// In en, this message translates to:
  /// **'Import / Export'**
  String get settingsImportExport;

  /// App settings row and title of its page
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// App settings row and title of its page
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get settingsFeedback;

  /// App settings row and title of its page
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get settingsInfo;

  /// No description provided for @settingsRestartOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Restart onboarding'**
  String get settingsRestartOnboarding;

  /// No description provided for @settingsLoadDemo.
  ///
  /// In en, this message translates to:
  /// **'Load demo data'**
  String get settingsLoadDemo;

  /// No description provided for @currencyNameEUR.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currencyNameEUR;

  /// No description provided for @currencyNameUSD.
  ///
  /// In en, this message translates to:
  /// **'US dollar'**
  String get currencyNameUSD;

  /// No description provided for @currencyNameGBP.
  ///
  /// In en, this message translates to:
  /// **'British pound'**
  String get currencyNameGBP;

  /// No description provided for @currencyNameCHF.
  ///
  /// In en, this message translates to:
  /// **'Swiss franc'**
  String get currencyNameCHF;

  /// No description provided for @currencyNameBRL.
  ///
  /// In en, this message translates to:
  /// **'Brazilian real'**
  String get currencyNameBRL;

  /// No description provided for @currencyNameAED.
  ///
  /// In en, this message translates to:
  /// **'UAE dirham'**
  String get currencyNameAED;

  /// No description provided for @currencyNameJPY.
  ///
  /// In en, this message translates to:
  /// **'Japanese yen'**
  String get currencyNameJPY;

  /// No description provided for @currencyNameCAD.
  ///
  /// In en, this message translates to:
  /// **'Canadian dollar'**
  String get currencyNameCAD;

  /// No description provided for @accountDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} will be removed from your accounts.'**
  String accountDeleteMessage(String name);

  /// No description provided for @iconGroupFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get iconGroupFinance;

  /// No description provided for @iconGroupCommerce.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get iconGroupCommerce;

  /// No description provided for @iconGroupTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel and places'**
  String get iconGroupTravel;

  /// No description provided for @iconGroupHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get iconGroupHealth;

  /// No description provided for @iconGroupPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get iconGroupPeople;

  /// No description provided for @iconGroupNature.
  ///
  /// In en, this message translates to:
  /// **'Nature and weather'**
  String get iconGroupNature;

  /// No description provided for @iconGroupGames.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get iconGroupGames;

  /// No description provided for @iconGroupMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get iconGroupMedia;

  /// No description provided for @iconGroupOffice.
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get iconGroupOffice;

  /// No description provided for @iconGroupCommunication.
  ///
  /// In en, this message translates to:
  /// **'Communication'**
  String get iconGroupCommunication;

  /// No description provided for @iconGroupObjects.
  ///
  /// In en, this message translates to:
  /// **'Objects'**
  String get iconGroupObjects;

  /// Subtitle of step 2 of the onboarding
  ///
  /// In en, this message translates to:
  /// **'Now it’s time to create your categories and the related budgets'**
  String get onboardingStep2Subtitle;

  /// No description provided for @onboardingYourCategories.
  ///
  /// In en, this message translates to:
  /// **'Your categories'**
  String get onboardingYourCategories;

  /// No description provided for @onboardingFirstCategory.
  ///
  /// In en, this message translates to:
  /// **'Create your first category'**
  String get onboardingFirstCategory;

  /// No description provided for @onboardingCreateCategory.
  ///
  /// In en, this message translates to:
  /// **'Create category'**
  String get onboardingCreateCategory;

  /// No description provided for @onboardingAddCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get onboardingAddCategory;

  /// No description provided for @onboardingSuggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested'**
  String get onboardingSuggested;

  /// No description provided for @onboardingSuggestedExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get onboardingSuggestedExpenses;

  /// No description provided for @onboardingSuggestedIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get onboardingSuggestedIncome;

  /// Label for screen readers of the + of a suggested category
  ///
  /// In en, this message translates to:
  /// **'Add {name}'**
  String onboardingAddSuggested(String name);

  /// Second line of a category with budgets, e.g. 'Budget: 130€, Monthly'
  ///
  /// In en, this message translates to:
  /// **'Budget: {budgets}'**
  String categoryBudgetSubtitle(String budgets);

  /// One budget in that line
  ///
  /// In en, this message translates to:
  /// **'{amount}, {period}'**
  String categoryBudgetEntry(String amount, String period);

  /// No description provided for @categoryShowSubcategories.
  ///
  /// In en, this message translates to:
  /// **'Show subcategories'**
  String get categoryShowSubcategories;

  /// No description provided for @categoryHideSubcategories.
  ///
  /// In en, this message translates to:
  /// **'Hide subcategories'**
  String get categoryHideSubcategories;

  /// No description provided for @categoryNew.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get categoryNew;

  /// No description provided for @categoryEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get categoryEdit;

  /// No description provided for @categoryType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get categoryType;

  /// No description provided for @categoryTypeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get categoryTypeExpense;

  /// No description provided for @categoryTypeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get categoryTypeIncome;

  /// No description provided for @categoryNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your category name'**
  String get categoryNamePlaceholder;

  /// No description provided for @categoryBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get categoryBudget;

  /// No description provided for @categoryAddBudget.
  ///
  /// In en, this message translates to:
  /// **'Add budget'**
  String get categoryAddBudget;

  /// No description provided for @categorySubcategories.
  ///
  /// In en, this message translates to:
  /// **'Subcategories'**
  String get categorySubcategories;

  /// No description provided for @categorySubcategoriesHint.
  ///
  /// In en, this message translates to:
  /// **'Subcategories allow you to manage your transactions more precisely'**
  String get categorySubcategoriesHint;

  /// No description provided for @categoryAddSubcategory.
  ///
  /// In en, this message translates to:
  /// **'Add subcategory'**
  String get categoryAddSubcategory;

  /// No description provided for @categoryDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get categoryDelete;

  /// No description provided for @categoryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this category?'**
  String get categoryDeleteTitle;

  /// No description provided for @categoryDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'{name}, its subcategories and its budgets will be removed.'**
  String categoryDeleteMessage(String name);

  /// No description provided for @categoryDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get categoryDeleteConfirm;

  /// No description provided for @categoryErrName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get categoryErrName;

  /// No description provided for @categoryErrNameTaken.
  ///
  /// In en, this message translates to:
  /// **'You already have a category of this type with this name'**
  String get categoryErrNameTaken;

  /// No description provided for @categoryErrInUse.
  ///
  /// In en, this message translates to:
  /// **'This category has transactions, so it cannot be deleted or change type'**
  String get categoryErrInUse;

  /// No description provided for @categoryTypeChangeTitle.
  ///
  /// In en, this message translates to:
  /// **'Change to income?'**
  String get categoryTypeChangeTitle;

  /// No description provided for @categoryTypeChangeMessage.
  ///
  /// In en, this message translates to:
  /// **'Income categories have no budgets: the budgets of this category will be discarded.'**
  String get categoryTypeChangeMessage;

  /// No description provided for @categoryTypeChangeConfirm.
  ///
  /// In en, this message translates to:
  /// **'Change type'**
  String get categoryTypeChangeConfirm;

  /// No description provided for @subcategoryNew.
  ///
  /// In en, this message translates to:
  /// **'New subcategory'**
  String get subcategoryNew;

  /// No description provided for @subcategoryEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit subcategory'**
  String get subcategoryEdit;

  /// No description provided for @subcategoryNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your subcategory name'**
  String get subcategoryNamePlaceholder;

  /// No description provided for @subcategoryDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete subcategory'**
  String get subcategoryDelete;

  /// No description provided for @subcategoryErrNameTaken.
  ///
  /// In en, this message translates to:
  /// **'This category already has a subcategory with this name'**
  String get subcategoryErrNameTaken;

  /// No description provided for @budgetFormNew.
  ///
  /// In en, this message translates to:
  /// **'New budget'**
  String get budgetFormNew;

  /// No description provided for @budgetFormEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit budget'**
  String get budgetFormEdit;

  /// No description provided for @budgetSelectType.
  ///
  /// In en, this message translates to:
  /// **'Select type'**
  String get budgetSelectType;

  /// No description provided for @budgetSetAmount.
  ///
  /// In en, this message translates to:
  /// **'Set amount'**
  String get budgetSetAmount;

  /// No description provided for @budgetAmountPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. 100'**
  String get budgetAmountPlaceholder;

  /// No description provided for @budgetLimitAlert.
  ///
  /// In en, this message translates to:
  /// **'Limit reach alert'**
  String get budgetLimitAlert;

  /// No description provided for @budgetCountForOverall.
  ///
  /// In en, this message translates to:
  /// **'Count for overall budget'**
  String get budgetCountForOverall;

  /// No description provided for @onboardingStep3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'And your investments and keep track of them in the app'**
  String get onboardingStep3Subtitle;

  /// No description provided for @onboardingYourAssets.
  ///
  /// In en, this message translates to:
  /// **'Your assets'**
  String get onboardingYourAssets;

  /// No description provided for @onboardingNoAssets.
  ///
  /// In en, this message translates to:
  /// **'No asset yet'**
  String get onboardingNoAssets;

  /// No description provided for @onboardingAddAsset.
  ///
  /// In en, this message translates to:
  /// **'Add asset'**
  String get onboardingAddAsset;

  /// No description provided for @onboardingSkipStep.
  ///
  /// In en, this message translates to:
  /// **'Skip this step'**
  String get onboardingSkipStep;

  /// No description provided for @onboardingStartTracking.
  ///
  /// In en, this message translates to:
  /// **'Start tracking'**
  String get onboardingStartTracking;

  /// No description provided for @assetQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity:'**
  String get assetQuantityLabel;

  /// No description provided for @assetPmcLabel.
  ///
  /// In en, this message translates to:
  /// **'PMC:'**
  String get assetPmcLabel;

  /// No description provided for @assetNew.
  ///
  /// In en, this message translates to:
  /// **'New asset'**
  String get assetNew;

  /// No description provided for @assetEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit asset'**
  String get assetEdit;

  /// No description provided for @assetMainDetails.
  ///
  /// In en, this message translates to:
  /// **'Main details'**
  String get assetMainDetails;

  /// No description provided for @assetSearch.
  ///
  /// In en, this message translates to:
  /// **'Search by name, ticker or ISIN'**
  String get assetSearch;

  /// No description provided for @assetManualNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Your asset name'**
  String get assetManualNamePlaceholder;

  /// No description provided for @assetAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get assetAmount;

  /// No description provided for @assetAmountPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. 12'**
  String get assetAmountPlaceholder;

  /// No description provided for @assetAveragePrice.
  ///
  /// In en, this message translates to:
  /// **'Average purchase price'**
  String get assetAveragePrice;

  /// No description provided for @assetPricePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. 10,50'**
  String get assetPricePlaceholder;

  /// No description provided for @assetCountsForNetWorth.
  ///
  /// In en, this message translates to:
  /// **'Counts for Net Worth'**
  String get assetCountsForNetWorth;

  /// No description provided for @assetDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete asset'**
  String get assetDelete;

  /// No description provided for @assetDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this asset?'**
  String get assetDeleteTitle;

  /// No description provided for @assetDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} and its opening movement will be removed.'**
  String assetDeleteMessage(String name);

  /// No description provided for @assetDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get assetDeleteConfirm;

  /// No description provided for @assetErrChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose an asset'**
  String get assetErrChoose;

  /// No description provided for @assetErrDuplicate.
  ///
  /// In en, this message translates to:
  /// **'This asset is already in your list'**
  String get assetErrDuplicate;

  /// No description provided for @assetErrNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get assetErrNameRequired;

  /// No description provided for @assetErrNameTaken.
  ///
  /// In en, this message translates to:
  /// **'You already have a manual asset with this name'**
  String get assetErrNameTaken;

  /// No description provided for @assetErrAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get assetErrAmount;

  /// No description provided for @assetErrAmountPositive.
  ///
  /// In en, this message translates to:
  /// **'The amount must be greater than zero'**
  String get assetErrAmountPositive;

  /// No description provided for @assetErrAmountDecimals.
  ///
  /// In en, this message translates to:
  /// **'At most 8 decimals'**
  String get assetErrAmountDecimals;

  /// No description provided for @assetErrAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid number'**
  String get assetErrAmountInvalid;

  /// No description provided for @assetErrPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter a price'**
  String get assetErrPrice;

  /// No description provided for @assetErrPricePositive.
  ///
  /// In en, this message translates to:
  /// **'The price must be greater than zero'**
  String get assetErrPricePositive;

  /// No description provided for @assetErrDeleteRefused.
  ///
  /// In en, this message translates to:
  /// **'This asset cannot be deleted: other movements depend on it'**
  String get assetErrDeleteRefused;

  /// Latest transactions widget with no transactions
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get dashboardNoTransactions;

  /// Cash flow card of the Finance overview with no income or expenses
  ///
  /// In en, this message translates to:
  /// **'No income or expenses this month yet'**
  String get overviewCashFlowEmpty;

  /// Switch in the account form to make it the main account
  ///
  /// In en, this message translates to:
  /// **'Main account'**
  String get accountMain;

  /// Line under the disabled main account switch
  ///
  /// In en, this message translates to:
  /// **'To change it, set another account as main'**
  String get accountMainHint;

  /// Edit of the account page: opens the account form
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get accountPageEdit;

  /// Accounts page without accounts
  ///
  /// In en, this message translates to:
  /// **'No accounts yet'**
  String get accountsEmptyTitle;

  /// Accounts page without accounts
  ///
  /// In en, this message translates to:
  /// **'Add one to start tracking.'**
  String get accountsEmptyMessage;

  /// Account page, list of transactions with no transaction
  ///
  /// In en, this message translates to:
  /// **'No transactions in this account yet.'**
  String get accountNoTransactions;

  /// Tag on the main account in the list of accounts
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get accountMainTag;

  /// Title of the Add sheet in transaction mode
  ///
  /// In en, this message translates to:
  /// **'New transaction'**
  String get addNewTransaction;

  /// Title of the Add sheet in investment movement mode
  ///
  /// In en, this message translates to:
  /// **'New movement'**
  String get addNewMovement;

  /// Option of the menu of the Add sheet title
  ///
  /// In en, this message translates to:
  /// **'Transaction'**
  String get addModeTransaction;

  /// Option of the menu of the Add sheet title
  ///
  /// In en, this message translates to:
  /// **'Investment movement'**
  String get addModeMovement;

  /// Screen reader label of the title menu of the Add sheet
  ///
  /// In en, this message translates to:
  /// **'Change what to add'**
  String get addModeSemantic;

  /// Primary button of the Add sheet, transaction mode
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get addTransactionButton;

  /// Primary button of the Add sheet, movement mode
  ///
  /// In en, this message translates to:
  /// **'Add movement'**
  String get addMovementButton;

  /// Snackbar after adding a transaction
  ///
  /// In en, this message translates to:
  /// **'Transaction added'**
  String get addTransactionDone;

  /// Snackbar after adding a movement
  ///
  /// In en, this message translates to:
  /// **'Movement added'**
  String get addMovementDone;

  /// Action of the snackbar after adding
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get addUndo;

  /// Screen reader label of the big amount field
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get txAmount;

  /// Label of the category row in the transaction form
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get txCategory;

  /// Label of the subcategory chips
  ///
  /// In en, this message translates to:
  /// **'Subcategory (optional)'**
  String get txSubcategory;

  /// Screen reader label of the caret of a category with subcategories
  ///
  /// In en, this message translates to:
  /// **'Subcategories'**
  String get txSubcategories;

  /// Chip that opens the full list of categories
  ///
  /// In en, this message translates to:
  /// **'More…'**
  String get txMore;

  /// Error when no category is chosen
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get txErrCategory;

  /// Shown in the transaction form with no expense categories
  ///
  /// In en, this message translates to:
  /// **'You have no expense categories yet.'**
  String get txNoExpenseCategories;

  /// Shown in the transaction form with no income categories
  ///
  /// In en, this message translates to:
  /// **'You have no income categories yet.'**
  String get txNoIncomeCategories;

  /// Shown in the transaction form with no accounts
  ///
  /// In en, this message translates to:
  /// **'You need an account before adding a transaction.'**
  String get txNoAccounts;

  /// Label of the account select
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get txAccount;

  /// Label of the source account of a transfer
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get txFrom;

  /// Label of the destination account of a transfer
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get txTo;

  /// Screen reader label of the button that swaps From and To
  ///
  /// In en, this message translates to:
  /// **'Swap accounts'**
  String get txSwapAccounts;

  /// Transfer between currencies: what arrives
  ///
  /// In en, this message translates to:
  /// **'Amount received'**
  String get txAmountReceived;

  /// Shown when there is only one account
  ///
  /// In en, this message translates to:
  /// **'To make a transfer you need at least two accounts.'**
  String get txTransferNeedsTwo;

  /// Label of the date chips
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get txDate;

  /// Date chip
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get txToday;

  /// Date chip
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get txYesterday;

  /// Date chip that opens the calendar
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get txOtherDate;

  /// Label of the description field
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get txDescription;

  /// Switch of the recurrence
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get txRecurring;

  /// Label of the frequency select
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get txFrequency;

  /// Label of the start date of a recurrence
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get txStartDate;

  /// Label of the end of a recurrence
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get txEnd;

  /// End of a recurrence
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get txEndNever;

  /// End of a recurrence
  ///
  /// In en, this message translates to:
  /// **'On date'**
  String get txEndOnDate;

  /// End of a recurrence
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get txEndAfter;

  /// Label of the end date
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get txEndDate;

  /// Label of the count of a recurrence
  ///
  /// In en, this message translates to:
  /// **'Number of times'**
  String get txEndCount;

  /// Placeholder of the end date
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get txChooseDate;

  /// Error when the end date is missing
  ///
  /// In en, this message translates to:
  /// **'Choose the end date'**
  String get txErrChooseDate;

  /// Error when the end date is before the start
  ///
  /// In en, this message translates to:
  /// **'The end is before the start'**
  String get txErrEndBeforeStart;

  /// Dashboard widget: the next occurrences of the recurring transactions
  ///
  /// In en, this message translates to:
  /// **'Upcoming recurring'**
  String get widgetUpcomingRecurringName;

  /// Upcoming recurring widget with no active recurring transactions
  ///
  /// In en, this message translates to:
  /// **'No recurring transactions'**
  String get dashboardNoUpcomingRecurring;

  /// Dashboard widget: the budgets of the current periods
  ///
  /// In en, this message translates to:
  /// **'Budget status'**
  String get widgetBudgetStatusName;

  /// Header of the Budget status widget (M and L)
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get widgetBudgetTitle;

  /// Budget type selector of the Budget status widget: every type
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get budgetTypeAll;

  /// Accessibility label of the budget type selector
  ///
  /// In en, this message translates to:
  /// **'Budget type'**
  String get budgetTypeSemantic;

  /// Budget status widget with no budgets
  ///
  /// In en, this message translates to:
  /// **'No budgets yet'**
  String get widgetNoBudgets;

  /// Budget status widget with none of the chosen type; period in lowercase, e.g. monthly
  ///
  /// In en, this message translates to:
  /// **'No {period} budgets'**
  String widgetNoBudgetsOfPeriod(String period);

  /// Type chip of the Dashboard widgets
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get kindTransfers;

  /// Accessibility label of the type chip of Latest transactions and Upcoming recurring
  ///
  /// In en, this message translates to:
  /// **'Transaction type'**
  String get dashboardTransactionTypeSemantic;

  /// Latest transactions with none of the chosen type; type in lowercase, e.g. expense
  ///
  /// In en, this message translates to:
  /// **'No {type} transactions'**
  String dashboardNoTransactionsOfType(String type);

  /// Upcoming recurring with none of the chosen type; type in lowercase, e.g. income
  ///
  /// In en, this message translates to:
  /// **'No {type} recurring transactions'**
  String dashboardNoRecurringOfType(String type);

  /// Dashboard widget: accounts plus investments
  ///
  /// In en, this message translates to:
  /// **'Net worth'**
  String get widgetNetWorthName;

  /// Net worth widget chart with fewer than two points
  ///
  /// In en, this message translates to:
  /// **'Not enough history yet'**
  String get widgetNetWorthNoHistory;

  /// Accessibility label of the period chip of the Net worth widget
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get netWorthPeriodSemantic;

  /// Net worth period: 3 months
  ///
  /// In en, this message translates to:
  /// **'3M'**
  String get netWorthPeriod3M;

  /// Net worth period: 6 months
  ///
  /// In en, this message translates to:
  /// **'6M'**
  String get netWorthPeriod6M;

  /// Net worth period: 1 year
  ///
  /// In en, this message translates to:
  /// **'1Y'**
  String get netWorthPeriod1Y;

  /// Net worth period: 3 years
  ///
  /// In en, this message translates to:
  /// **'3Y'**
  String get netWorthPeriod3Y;

  /// Net worth period: 5 years
  ///
  /// In en, this message translates to:
  /// **'5Y'**
  String get netWorthPeriod5Y;

  /// Net worth period: from the start of the history
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get netWorthPeriodAll;

  /// Dashboard widget: value and performance of the portfolio
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get widgetInvestmentsName;

  /// Accessibility label of the period chip of the Investments widget
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get widgetInvestmentsPeriodSemantic;

  /// Net worth period: year to date
  ///
  /// In en, this message translates to:
  /// **'YTD'**
  String get netWorthPeriodYtd;

  /// Dashboard widget: asset allocation of the portfolio
  ///
  /// In en, this message translates to:
  /// **'Allocation'**
  String get widgetAllocationName;

  /// Dashboard widget: the one most relevant insight right now
  ///
  /// In en, this message translates to:
  /// **'Insight of the moment'**
  String get widgetInsightName;

  /// Insight title: a budget was exceeded
  ///
  /// In en, this message translates to:
  /// **'{category} over budget'**
  String insightBudgetExceededTitle(String category);

  /// Insight title: a budget is close to its limit
  ///
  /// In en, this message translates to:
  /// **'{category} budget at risk'**
  String insightBudgetAtRiskTitle(String category);

  /// Insight title: a recurring expense is due today
  ///
  /// In en, this message translates to:
  /// **'Payment due today'**
  String get insightRecurringDueToday;

  /// Insight title: a recurring expense is due tomorrow
  ///
  /// In en, this message translates to:
  /// **'Payment due tomorrow'**
  String get insightRecurringDueTomorrow;

  /// Insight title: an expense far above the usual of its category
  ///
  /// In en, this message translates to:
  /// **'Unusual {category} expense'**
  String insightUnusualTitle(String category);

  /// Insight detail: how many times the usual expense of the category
  ///
  /// In en, this message translates to:
  /// **'{ratio}× the usual'**
  String insightUnusualDetail(String ratio);

  /// Insight title: the portfolio lost value today
  ///
  /// In en, this message translates to:
  /// **'Portfolio down today'**
  String get insightPortfolioDropTitle;

  /// Insight title: the portfolio gained value today
  ///
  /// In en, this message translates to:
  /// **'Portfolio up today'**
  String get insightPortfolioGainTitle;

  /// Insight title: net worth above the previous days
  ///
  /// In en, this message translates to:
  /// **'Highest net worth in a month'**
  String get insightNetWorthHighTitle;

  /// Insight title: evening reminder, no transaction today
  ///
  /// In en, this message translates to:
  /// **'Nothing recorded today'**
  String get insightNoTransactionTodayTitle;

  /// Insight detail: evening reminder
  ///
  /// In en, this message translates to:
  /// **'Add today\'s transactions'**
  String get insightNoTransactionTodayDetail;

  /// Insight title: the last transaction is some days old
  ///
  /// In en, this message translates to:
  /// **'No recent transactions'**
  String get insightNoRecentTitle;

  /// Insight detail: days since the last transaction
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day since the last one} other{{count} days since the last one}}'**
  String insightNoRecentDetail(int count);

  /// Insight title: new user without transactions
  ///
  /// In en, this message translates to:
  /// **'Add your first transaction'**
  String get insightFirstTransactionTitle;

  /// Insight detail: new user
  ///
  /// In en, this message translates to:
  /// **'Start tracking your finances'**
  String get insightFirstTransactionDetail;

  /// Insight title: neutral state, nothing to report
  ///
  /// In en, this message translates to:
  /// **'All good for today'**
  String get insightAllGoodTitle;

  /// Insight detail: neutral state
  ///
  /// In en, this message translates to:
  /// **'Nothing needs your attention'**
  String get insightAllGoodDetail;

  /// Showcase group
  ///
  /// In en, this message translates to:
  /// **'Budget exceeded'**
  String get showcaseBudgetExceeded;

  /// Showcase group
  ///
  /// In en, this message translates to:
  /// **'Recurring payment due'**
  String get showcaseRecurringDue;

  /// Showcase group
  ///
  /// In en, this message translates to:
  /// **'Budget at risk'**
  String get showcaseBudgetAtRisk;

  /// Showcase group
  ///
  /// In en, this message translates to:
  /// **'Unusual expense'**
  String get showcaseUnusualExpense;

  /// Showcase group
  ///
  /// In en, this message translates to:
  /// **'Portfolio drop'**
  String get showcasePortfolioDrop;

  /// Showcase group
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get showcaseReminder;

  /// Showcase group
  ///
  /// In en, this message translates to:
  /// **'Good news'**
  String get showcasePositive;

  /// Showcase group
  ///
  /// In en, this message translates to:
  /// **'No insight'**
  String get showcaseAllGood;

  /// Type selector of the transaction widgets (Latest transactions, Upcoming recurring): every type, feminine in Italian ("tutte" the transactions)
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get transactionTypeAll;

  /// Settings > Prototype row: opens the page with every Dashboard widget
  ///
  /// In en, this message translates to:
  /// **'Widget showcase'**
  String get settingsWidgetShowcase;

  /// Subtitle of the widget showcase page
  ///
  /// In en, this message translates to:
  /// **'Every widget, case and size, on demo data'**
  String get showcaseIntro;

  /// Showcase case: widget on the demo data
  ///
  /// In en, this message translates to:
  /// **'With data'**
  String get showcaseWithData;

  /// Showcase case: widget of a new user with no data
  ///
  /// In en, this message translates to:
  /// **'New user, no data'**
  String get showcaseNewUser;

  /// Settings > Categories: title of the income categories
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get categoriesGroupIncome;

  /// Settings > Categories: title of the expense categories
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get categoriesGroupExpenses;

  /// Settings > Categories: screen reader label of the + button that asks for the type
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get categoriesAddSemantic;

  /// Settings > Categories without categories
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get categoriesEmptyTitle;

  /// Settings > Categories without categories
  ///
  /// In en, this message translates to:
  /// **'Add one with the + button.'**
  String get categoriesEmptyMessage;

  /// Second line of a category row: how many subcategories it has
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No subcategories} =1{1 subcategory} other{{count} subcategories}}'**
  String categorySubcategoriesCount(int count);

  /// Edit of the category page: opens the category form
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get categoryPageEdit;

  /// Category page: title of the list of subcategories
  ///
  /// In en, this message translates to:
  /// **'Subcategories'**
  String get categoryDetailSubcategories;

  /// Category page: title of the list of transactions
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get categoryDetailTransactions;

  /// Category page, list of transactions with no transaction
  ///
  /// In en, this message translates to:
  /// **'No transactions in this category yet.'**
  String get categoryNoTransactions;

  /// Subcategory page, list of transactions with no transaction
  ///
  /// In en, this message translates to:
  /// **'No transactions in this subcategory yet.'**
  String get subcategoryNoTransactions;

  /// Category page: title of the list of recurring transactions
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get categoryDetailRecurring;

  /// Accounts page: screen reader label of the + button
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get accountsAddSemantic;

  /// Transaction page: Edit button in the top bar
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get transactionDetailEdit;

  /// Transaction form: title in edit mode
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get transactionEdit;

  /// Transaction form: screen reader label of the check
  ///
  /// In en, this message translates to:
  /// **'Save transaction'**
  String get transactionSave;

  /// Transaction form: red delete button
  ///
  /// In en, this message translates to:
  /// **'Delete transaction'**
  String get transactionDelete;

  /// Delete confirmation: title
  ///
  /// In en, this message translates to:
  /// **'Delete this transaction?'**
  String get transactionDeleteTitle;

  /// Delete confirmation: message
  ///
  /// In en, this message translates to:
  /// **'It will be removed and balances, charts and budgets will be updated.'**
  String get transactionDeleteMessage;

  /// Delete confirmation: button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get transactionDeleteConfirm;

  /// Snackbar after saving an edit
  ///
  /// In en, this message translates to:
  /// **'Transaction updated'**
  String get transactionUpdated;

  /// Choice dialog: edits the single transaction
  ///
  /// In en, this message translates to:
  /// **'Only this transaction'**
  String get transactionAskOnlyThis;

  /// Choice dialog: opens the recurrence, which changes only the dates to come
  ///
  /// In en, this message translates to:
  /// **'The recurrence (next ones)'**
  String get transactionAskRecurrence;

  /// Transaction form: no subcategory option
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get transactionSubcategoryNone;

  /// Transaction page: text button under the frequency chip that opens the recurrence
  ///
  /// In en, this message translates to:
  /// **'Show recurrence'**
  String get transactionShowRecurrence;

  /// Recurring page: chip when the recurring transaction is paused
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get recurringPausedLabel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
