// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navFinance => 'Finanze';

  @override
  String get navInvestments => 'Investimenti';

  @override
  String get addTransaction => 'Aggiungi transazione';

  @override
  String get settings => 'Impostazioni';

  @override
  String get back => 'Indietro';

  @override
  String get showAmounts => 'Mostra importi';

  @override
  String get hideAmounts => 'Nascondi importi';

  @override
  String get comingSoon => 'In arrivo';

  @override
  String get widgetMonthlyBalanceName => 'Saldo mensile';

  @override
  String get widgetLatestTransactionsName => 'Ultime transazioni';

  @override
  String get widgetIncome => 'Entrate';

  @override
  String get widgetExpense => 'Uscite';

  @override
  String get widgetComparedToLastMonth =>
      'Rispetto allo stesso giorno del mese scorso';

  @override
  String get chartThisMonth => 'Questo mese';

  @override
  String get chartLastMonth => 'Mese scorso';

  @override
  String get editHome => 'Modifica Home';

  @override
  String get addWidget => 'Aggiungi widget';

  @override
  String get doneEditing => 'Fine';

  @override
  String get cancel => 'Annulla';

  @override
  String get removeWidget => 'Rimuovi widget';

  @override
  String get resizeWidget => 'Ridimensiona widget';

  @override
  String get widgetSizeSmall => 'Piccolo';

  @override
  String get widgetSizeMedium => 'Medio';

  @override
  String get widgetSizeLarge => 'Grande';

  @override
  String get dashboardEmptyTitle => 'La tua Home è vuota';

  @override
  String get dashboardEmptyEditHint => 'Tocca + per aggiungere un widget';

  @override
  String get darkMode => 'Modalità scura';

  @override
  String get financeTitle => 'Finanze';

  @override
  String get financeTabOverview => 'Panoramica';

  @override
  String get financeTabTransactions => 'Transazioni';

  @override
  String get financeTabBudget => 'Budget';

  @override
  String get financeTabRecurring => 'Ricorrenze';

  @override
  String get transactionsViewList => 'Lista';

  @override
  String get transactionsViewCharts => 'Grafici';

  @override
  String get searchTransactions => 'Cerca transazioni';

  @override
  String get clearSearch => 'Cancella ricerca';

  @override
  String get filters => 'Filtri';

  @override
  String get filtersApply => 'Applica';

  @override
  String get filtersReset => 'Reimposta';

  @override
  String get filterDate => 'Data';

  @override
  String get filterType => 'Tipo';

  @override
  String get filterCategory => 'Categoria';

  @override
  String get filterAmount => 'Importo';

  @override
  String get filterAccount => 'Conto';

  @override
  String get typeExpense => 'Uscita';

  @override
  String get typeIncome => 'Entrata';

  @override
  String get typeTransfer => 'Trasferimento';

  @override
  String get removeFilter => 'Rimuovi filtro';

  @override
  String get datePresetThisMonth => 'Questo mese';

  @override
  String get datePresetLastMonth => 'Mese scorso';

  @override
  String get datePresetLast3Months => 'Ultimi 3 mesi';

  @override
  String get datePresetThisYear => 'Quest\'anno';

  @override
  String get datePresetAllTime => 'Tutto il periodo';

  @override
  String get datePresetCustom => 'Intervallo personalizzato';

  @override
  String get amountMin => 'Min';

  @override
  String get amountMax => 'Max';

  @override
  String get emptyTransactionsTitle => 'Nessuna transazione trovata';

  @override
  String get emptyTransactionsFiltered =>
      'Prova a cambiare la ricerca o i filtri.';

  @override
  String get emptyTransactionsPlain =>
      'Non ci sono transazioni in questo periodo.';

  @override
  String get clearFilters => 'Rimuovi filtri';

  @override
  String get paginationPrevious => 'Pagina precedente';

  @override
  String get paginationNext => 'Pagina successiva';

  @override
  String get previousMonth => 'Mese precedente';

  @override
  String get nextMonth => 'Mese successivo';

  @override
  String amountsIn(String currency) {
    return 'Importi in $currency';
  }

  @override
  String get chartsSelectTimeRange => 'Seleziona il periodo';

  @override
  String get rangeCurrentMonth => 'Mese in corso';

  @override
  String get rangeLastMonth => 'Mese scorso';

  @override
  String get rangeLast3Months => 'Ultimi 3 mesi';

  @override
  String get rangeLast6Months => 'Ultimi 6 mesi';

  @override
  String get rangeYearToDate => 'Da inizio anno';

  @override
  String get rangeLast12Months => 'Ultimi 12 mesi';

  @override
  String get kindExpenses => 'Uscite';

  @override
  String get kindIncome => 'Entrate';

  @override
  String get chartTotal => 'Totale';

  @override
  String get chartCategoriesBreakdown => 'Ripartizione per categoria';

  @override
  String get chartBreakdownOverTime => 'Andamento nel tempo';

  @override
  String get chartSnapshot => 'Intervallo';

  @override
  String get granularityWeekly => 'Settimanale';

  @override
  String get granularityMonthly => 'Mensile';

  @override
  String get emptyChartsTitle => 'Nessuna transazione in questo periodo';

  @override
  String get emptyChartsFiltered => 'Prova un altro periodo o meno filtri.';

  @override
  String get chartDonutSemantics => 'Ripartizione per categoria';

  @override
  String get chartAreaSemantics => 'Andamento nel tempo per categoria';

  @override
  String changeVsPrevious(String value) {
    return '$value vs periodo prec.';
  }

  @override
  String get language => 'Lingua';

  @override
  String get languageSystem => 'Lingua del dispositivo';

  @override
  String get currency => 'Valuta';

  @override
  String get periodWeekly => 'Settimanale';

  @override
  String get periodMonthly => 'Mensile';

  @override
  String get periodQuarterly => 'Trimestrale';

  @override
  String get periodSemiannual => 'Semestrale';

  @override
  String get periodYearly => 'Annuale';

  @override
  String get budgetOverall => 'Budget totale';

  @override
  String get budgetCategoriesBreakdown => 'Ripartizione per categoria';

  @override
  String get budgetsBarSemantics => 'Budget del periodo';

  @override
  String get budgetEmptyTitle => 'Nessun budget per questo periodo';

  @override
  String get budgetEmptyHint =>
      'Potrai aggiungere i budget dalle Impostazioni.';

  @override
  String get budgetEdit => 'Modifica';

  @override
  String get budgetSectionBudget => 'Budget';

  @override
  String get budgetSectionExpenses => 'Spese';

  @override
  String get budgetSearchExpenses => 'Cerca spese';

  @override
  String get budgetAmount => 'Importo del budget';

  @override
  String get budgetAmountRequired => 'Inserisci un importo.';

  @override
  String get budgetAmountPositive => 'L\'importo deve essere maggiore di zero.';

  @override
  String get budgetDelete => 'Elimina budget';

  @override
  String get budgetDeleteTitle => 'Eliminare questo budget?';

  @override
  String get budgetDeleteConfirm => 'Elimina';

  @override
  String get emptyBudgetExpensesTitle => 'Nessuna spesa in questo periodo';

  @override
  String budgetLeft(String amount) {
    return '$amount rimasti';
  }

  @override
  String budgetOver(String amount) {
    return '$amount oltre';
  }

  @override
  String budgetDeleteMessage(String period, String category) {
    return 'Il budget $period di $category verrà rimosso. Le tue spese non cambiano.';
  }

  @override
  String get recurringPreviousMonth => 'Mese precedente';

  @override
  String get recurringNextMonth => 'Mese successivo';

  @override
  String get recurringPickMonth => 'Scegli il mese';

  @override
  String get recurringPickMonthTitle => 'Seleziona il mese';

  @override
  String get recurringPreviousYear => 'Anno precedente';

  @override
  String get recurringNextYear => 'Anno successivo';

  @override
  String get recurringAdd => 'Aggiungi transazione ricorrente';

  @override
  String get recurringEmptyMonthTitle => 'Nessuna ricorrenza in questo mese';

  @override
  String get recurringEmptyDayTitle => 'Nessuna ricorrenza in questo giorno';

  @override
  String get recurringEdit => 'Modifica';

  @override
  String get recurringSectionDetails => 'Dettagli';

  @override
  String get recurringPeriod => 'Periodo di ricorrenza';

  @override
  String get recurringAmount => 'Importo';

  @override
  String get recurringActive => 'Attiva';

  @override
  String get recurringSectionOld => 'Transazioni passate';

  @override
  String get recurringRangeLabel => 'Seleziona l\'intervallo';

  @override
  String get recurringRangeLast3 => 'Ultimi 3 mesi';

  @override
  String get recurringRangeLast6 => 'Ultimi 6 mesi';

  @override
  String get recurringRangeLast12 => 'Ultimi 12 mesi';

  @override
  String get recurringRangeAll => 'Tutte';

  @override
  String get recurringFrequencyWeekly => 'Settimanale';

  @override
  String get recurringFrequencyBiweekly => 'Ogni 2 settimane';

  @override
  String get recurringFrequencyMonthly => 'Mensile';

  @override
  String get recurringFrequencyBimonthly => 'Ogni 2 mesi';

  @override
  String get recurringFrequencyQuarterly => 'Trimestrale';

  @override
  String get recurringFrequencySemiannual => 'Semestrale';

  @override
  String get recurringFrequencyYearly => 'Annuale';

  @override
  String get recurringHistoryEmpty => 'Nessuna transazione in questo periodo';

  @override
  String get recurringDelete => 'Elimina ricorrenza';

  @override
  String get recurringDeleteTitle => 'Eliminare questa ricorrenza?';

  @override
  String get recurringDeleteConfirm => 'Elimina';

  @override
  String recurringDeleteMessage(String name) {
    return '$name non si ripeterà più. Le transazioni già registrate restano.';
  }

  @override
  String get close => 'Chiudi';

  @override
  String get overviewAccounts => 'I tuoi conti';

  @override
  String get overviewManage => 'Gestisci';

  @override
  String get overviewBudgetsTitle => 'Budget';

  @override
  String get overviewUpcoming => 'Prossime ricorrenze';

  @override
  String get overviewNoUpcoming => 'Nessuna ricorrenza fino a fine mese';

  @override
  String get overviewCashFlow => 'Flusso di cassa';

  @override
  String get overviewBudgetStatus => 'Stato dei budget';

  @override
  String get overviewNoBudgets => 'Nessun budget per questo mese';

  @override
  String get legendIncome => 'Entrate';

  @override
  String get legendExpense => 'Uscite';

  @override
  String get legendBalance => 'Saldo';

  @override
  String get cashFlowSemantics =>
      'Flusso di cassa del mese: entrate, uscite e saldo giorno per giorno';

  @override
  String get digestBudgetExceededTitle => 'Budget sforato';

  @override
  String digestBudgetExceeded(String category, String amount) {
    return 'Hai sforato il budget $category di $amount';
  }

  @override
  String get digestBudgetAtRiskTitle => 'Budget a rischio';

  @override
  String digestBudgetAtRisk(String category, String percent, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni',
      one: '1 giorno',
    );
    return 'Il budget $category è al $percent e mancano $_temp0';
  }

  @override
  String get digestBelowTitle => 'Mese in positivo';

  @override
  String digestBelow(String amount) {
    return 'Stai spendendo $amount in meno rispetto alla media degli ultimi 3 mesi';
  }

  @override
  String get digestAboveTitle => 'Spesa sopra la media';

  @override
  String digestAbove(String amount) {
    return 'Stai spendendo $amount in più rispetto alla media degli ultimi 3 mesi';
  }

  @override
  String get digestRecurrencesTitle => 'Pagamenti in arrivo';

  @override
  String digestRecurrencesOne(String name, String amount, int days) {
    return '$name ($amount) scade nei prossimi $days giorni';
  }

  @override
  String digestRecurrencesMany(int count, int days, String amount) {
    return '$count pagamenti ricorrenti nei prossimi $days giorni, $amount in totale';
  }

  @override
  String get digestGrowthTitle => 'Spesa in crescita';

  @override
  String digestGrowth(String category, String percent) {
    return 'La spesa per $category è salita del $percent rispetto agli stessi giorni del mese scorso';
  }

  @override
  String get digestAllGoodTitle => 'Tutto bene';

  @override
  String get digestAllGood => 'Tutto nella norma questo mese';

  @override
  String get investmentsTitle => 'Investimenti';

  @override
  String get investmentsTabOverview => 'Panoramica';

  @override
  String get investmentsTabPositions => 'Posizioni';

  @override
  String get investmentsTabMovements => 'Movimenti';

  @override
  String get investmentsUpdatedNow => 'Aggiornato adesso';

  @override
  String investmentsUpdatedMinutes(int count) {
    return 'Aggiornato $count min fa';
  }

  @override
  String investmentsUpdatedHours(int count) {
    return 'Aggiornato $count h fa';
  }

  @override
  String investmentsUpdatedDays(int count) {
    return 'Aggiornato $count g fa';
  }

  @override
  String get investmentsPortfolioValue => 'Valore del portafoglio';

  @override
  String get investmentsLiquidity => 'Liquidità disponibile';

  @override
  String get investmentsMarketValue => 'Valore di mercato';

  @override
  String get investmentsAllocations => 'Allocazione degli asset';

  @override
  String get periodDay => '1G';

  @override
  String get periodFiveDays => '5G';

  @override
  String get periodMonth => '1M';

  @override
  String get periodSixMonths => '6M';

  @override
  String get periodYearToDate => 'YTD';

  @override
  String get periodYear => '1A';

  @override
  String get periodFiveYears => '5A';

  @override
  String get legendMarketValue => 'Valore di mercato';

  @override
  String get legendInvested => 'Investito';

  @override
  String get legendDifference => 'Differenza';

  @override
  String get marketValueSemantics =>
      'Valore di mercato del portafoglio e capitale investito nel tempo';

  @override
  String get allocationAssetClass => 'Classe di asset';

  @override
  String get allocationSingleAsset => 'Singolo asset';

  @override
  String get allocationEtf => 'ETF';

  @override
  String get allocationStocks => 'Azioni';

  @override
  String get allocationBonds => 'Obbligazioni';

  @override
  String get allocationOther => 'Altro';

  @override
  String get allocationLiquidity => 'Liquidità';

  @override
  String get allocationSemantics => 'Allocazione del portafoglio';

  @override
  String get investmentsEmptyTitle => 'Ancora nessun investimento';

  @override
  String get investmentsEmptyHint => 'Le tue posizioni compariranno qui.';

  @override
  String get investmentsDigestAllGoodTitle => 'Tutto bene';

  @override
  String get investmentsDigestAllGood =>
      'Niente da segnalare sui tuoi investimenti';

  @override
  String get investmentsDigestConcentrationTitle => 'Concentrazione';

  @override
  String investmentsDigestConcentration(String percent, String name) {
    return 'Il **$percent** del tuo portafoglio è su un solo asset, $name. Considera di diversificare';
  }

  @override
  String get investmentsDigestDropTitle => 'Portafoglio in calo';

  @override
  String investmentsDigestDrop(String amount, String percent) {
    return 'Il tuo portafoglio è sceso di **$amount** (**$percent**) nell\'ultimo mese';
  }

  @override
  String get investmentsDigestGrowthTitle => 'Portafoglio in crescita';

  @override
  String investmentsDigestGrowth(String amount) {
    return 'Il tuo patrimonio investito è cresciuto di **$amount** nell\'ultimo mese';
  }

  @override
  String get investmentsDigestDividendTitle => 'Dividendo in arrivo';

  @override
  String investmentsDigestDividendOne(String name, String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni',
      one: '1 giorno',
    );
    return '$name stacca **$amount** di dividendi entro $_temp0';
  }

  @override
  String investmentsDigestDividendMany(int count, String amount, int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days giorni',
      one: '1 giorno',
    );
    return '$count dividendi per **$amount** in totale sono attesi entro $_temp0';
  }

  @override
  String get positionsTitle => 'Posizioni';

  @override
  String get positionsSearch => 'Cerca posizioni';

  @override
  String get positionsFilterType => 'Tipo di asset';

  @override
  String get positionsEmptyTitle => 'Nessuna posizione trovata';

  @override
  String get positionsEmptyHint => 'Prova un\'altra ricerca o altri filtri.';

  @override
  String get positionsNoneTitle => 'Ancora nessuna posizione';

  @override
  String get kindEtf => 'ETF';

  @override
  String get kindStock => 'Azione';

  @override
  String get kindBond => 'Obbligazione';

  @override
  String get kindManual => 'Asset manuale';

  @override
  String get manualPension => 'Fondo pensione';

  @override
  String get manualCollectible => 'Da collezione';

  @override
  String get manualArt => 'Arte';

  @override
  String get manualRealEstate => 'Immobile';

  @override
  String get manualOther => 'Altro';

  @override
  String get breakdownTitle => 'Ripartizione del portafoglio';

  @override
  String get breakdownRegion => 'Regione';

  @override
  String get breakdownSector => 'Settore';

  @override
  String get positionYour => 'La tua posizione';

  @override
  String get positionMarketValue => 'Valore di mercato';

  @override
  String get positionQuantity => 'Quantità';

  @override
  String get positionAverageCost => 'Costo medio';

  @override
  String get positionInvested => 'Capitale investito';

  @override
  String get positionPnl => 'Profitto / perdita';

  @override
  String get positionWeight => 'Peso';

  @override
  String get positionAssetInfo => 'Info sull\'asset';

  @override
  String get infoType => 'Tipo';

  @override
  String get infoSector => 'Settore';

  @override
  String get infoRegion => 'Regione';

  @override
  String get infoCurrency => 'Valuta';

  @override
  String get infoExchange => 'Borsa';

  @override
  String get positionOperations => 'Operazioni';

  @override
  String get operationsEmpty => 'Ancora nessuna operazione';

  @override
  String get operationBuy => 'Acquisto';

  @override
  String get operationSell => 'Vendita';

  @override
  String get operationDividend => 'Dividendo';

  @override
  String operationDetails(String quantity, String price) {
    return '$quantity × $price';
  }

  @override
  String get positionBuy => 'Acquista';

  @override
  String get positionSell => 'Vendi';

  @override
  String get positionAddDividend => 'Aggiungi dividendo';

  @override
  String get positionPrice => 'Prezzo';

  @override
  String get positionPriceChartSemantics =>
      'Prezzo dell\'asset nel tempo e costo medio';

  @override
  String positionPriceInCurrency(String price) {
    return '$price per unità';
  }

  @override
  String get infoDistribution => 'Distribuzione';

  @override
  String get distAccumulating => 'Accumulazione';

  @override
  String get distDistributing => 'Distribuzione dei dividendi';

  @override
  String get infoTer => 'TER';

  @override
  String get infoDividendYield => 'Rendimento da dividendo';

  @override
  String get infoCoupon => 'Cedola';

  @override
  String get infoMaturity => 'Scadenza';

  @override
  String get infoDuration => 'Duration';

  @override
  String infoYears(String value) {
    return '$value anni';
  }

  @override
  String get positionMoreActions => 'Altre azioni';

  @override
  String get positionUpdateValue => 'Aggiorna il valore';

  @override
  String get movementsSearch => 'Cerca movimenti';

  @override
  String get movementsUpNext => 'In arrivo';

  @override
  String get movementsEmptyTitle => 'Nessun movimento trovato';

  @override
  String get movementsEmptyHint => 'Prova un\'altra ricerca o altri filtri.';

  @override
  String get movementsNoneTitle => 'Ancora nessun movimento';

  @override
  String get movementTypeBuy => 'Acquisto';

  @override
  String get movementTypeSell => 'Vendita';

  @override
  String get movementTypeDividend => 'Dividendo';

  @override
  String get movementTypeCost => 'Costo';

  @override
  String get movementPrice => 'Prezzo';

  @override
  String movementDetails(String quantity, String price) {
    return '$quantity · Prezzo $price';
  }

  @override
  String get movementPeriodCurrentMonth => 'Mese corrente';

  @override
  String get movementPeriodLast3Months => 'Ultimi 3 mesi';

  @override
  String get movementPeriodCurrentYear => 'Anno corrente';

  @override
  String get movementPeriodLast12Months => 'Ultimi 12 mesi';

  @override
  String get movementPeriodAll => 'Tutti';

  @override
  String get movementFilterPeriod => 'Periodo';

  @override
  String get movementFilterType => 'Tipo di movimento';

  @override
  String get movementFilterAssetType => 'Tipo di asset';

  @override
  String get movementFilterAsset => 'Asset';

  @override
  String get movementFilterAnyAsset => 'Tutti gli asset';

  @override
  String get movementNew => 'Nuovo movimento';

  @override
  String get movementAdd => 'Aggiungi';

  @override
  String get movementFieldAsset => 'Asset';

  @override
  String get movementFieldAssetOptional => 'Asset (facoltativo)';

  @override
  String get movementNoAsset => 'Nessuno';

  @override
  String get movementSearchAsset => 'Cerca un asset';

  @override
  String get movementChangeAsset => 'Cambia';

  @override
  String get movementAssetCatalog => 'Catalogo';

  @override
  String get movementAssetManual => 'Asset manuale';

  @override
  String get movementManualName => 'Nome';

  @override
  String get movementManualType => 'Tipo di asset';

  @override
  String get movementFieldAccount => 'Conto broker';

  @override
  String get movementFieldDate => 'Data';

  @override
  String get movementFieldQuantity => 'Quantità';

  @override
  String get movementFieldUnitPrice => 'Prezzo unitario';

  @override
  String get movementFieldFee => 'Commissioni (facoltative)';

  @override
  String get movementFieldAmount => 'Importo';

  @override
  String get movementFieldNetAmount => 'Importo netto';

  @override
  String get movementFieldDescription => 'Descrizione';

  @override
  String get movementFieldDescriptionOptional => 'Descrizione (facoltativa)';

  @override
  String movementHeld(String quantity) {
    return 'Ne possiedi $quantity';
  }

  @override
  String get movementErrRequired => 'Obbligatorio.';

  @override
  String get movementErrNumber => 'Inserisci un numero valido.';

  @override
  String get movementErrPositive => 'Deve essere maggiore di zero.';

  @override
  String get movementErrFuture => 'La data non può essere nel futuro.';

  @override
  String get movementErrChooseAsset => 'Scegli un asset.';

  @override
  String movementErrNegative(String date) {
    return 'Il $date possederesti meno di zero di questo asset. Non è stato modificato nulla.';
  }

  @override
  String get movementErrInvalid => 'Il movimento non è valido.';

  @override
  String movementLiquidityWarning(String amount) {
    return 'Supera la liquidità disponibile: andrà a $amount.';
  }

  @override
  String get movementDetailEdit => 'Modifica';

  @override
  String get movementDetailTotal => 'Totale';

  @override
  String get movementDetailAsset => 'Asset';

  @override
  String get movementDetailType => 'Tipo';

  @override
  String get movementDetailAccount => 'Conto broker';

  @override
  String get movementDetailDate => 'Data';

  @override
  String get movementDetailQuantity => 'Quantità';

  @override
  String get movementDetailPrice => 'Prezzo unitario';

  @override
  String get movementDetailFee => 'Commissioni';

  @override
  String get movementDelete => 'Elimina movimento';

  @override
  String get movementDeleteTitle => 'Eliminare questo movimento?';

  @override
  String get movementDeleteMessage =>
      'La posizione e la liquidità verranno ricalcolate senza di esso.';

  @override
  String get movementDeleteConfirm => 'Elimina';

  @override
  String get movementDividendExpected => 'Atteso';

  @override
  String get appName => 'SOSSOLDI';

  @override
  String get onboardingSplashWelcome => 'Benvenuto in';

  @override
  String get onboardingSplashTagline =>
      'L\'app di finanza personale della community di Mr. RIP';

  @override
  String get onboardingWelcomeTitle => 'Configura l\'app';

  @override
  String get onboardingWelcomeSubtitle =>
      'Pochi passaggi e sarai pronto a tenere traccia delle tue finanze personali (quasi) come Mr. Rip';

  @override
  String get onboardingChooseLanguage => 'Scegli la lingua';

  @override
  String get onboardingDefault => 'predefinita';

  @override
  String get onboardingStartSetup => 'Inizia la configurazione';

  @override
  String get onboardingOr => 'Oppure';

  @override
  String get onboardingImport => 'Importa i dati da un\'altra app';

  @override
  String get onboardingImportTitle => 'Importa i dati';

  @override
  String onboardingStep(int current, int total) {
    return 'Passo $current di $total';
  }

  @override
  String get onboardingStep1Subtitle => 'Scegli la valuta e configura i conti';

  @override
  String get onboardingMainCurrency => 'Seleziona la valuta principale';

  @override
  String get onboardingYourAccounts => 'I tuoi conti';

  @override
  String get onboardingFirstAccount => 'Crea il tuo primo conto';

  @override
  String get onboardingCreateAccount => 'Crea conto';

  @override
  String get onboardingAddAccount => 'Aggiungi conto';

  @override
  String get onboardingNextStep => 'Passo successivo';

  @override
  String get accountNew => 'Nuovo conto';

  @override
  String get accountEdit => 'Modifica conto';

  @override
  String get accountMainInfo => 'Informazioni principali';

  @override
  String get accountName => 'Nome';

  @override
  String get accountNamePlaceholder => 'Nome del conto';

  @override
  String get accountAmount => 'Importo';

  @override
  String get accountIconAndColor => 'Icona e colore';

  @override
  String get accountTapToSelect => 'Tocca per scegliere';

  @override
  String get accountChooseIcon => 'Scegli un\'icona';

  @override
  String get accountColorHue => 'Tonalità';

  @override
  String get accountColorSaturation => 'Saturazione';

  @override
  String get accountSave => 'Salva';

  @override
  String get accountDelete => 'Elimina conto';

  @override
  String get accountDeleteTitle => 'Eliminare questo conto?';

  @override
  String get accountDeleteConfirm => 'Elimina';

  @override
  String get accountErrName => 'Inserisci un nome';

  @override
  String get accountErrNameTaken => 'Hai già un conto con questo nome';

  @override
  String get accountErrAmount => 'Inserisci un importo';

  @override
  String get accountErrAmountInvalid => 'Inserisci un numero valido';

  @override
  String get accountErrInUse =>
      'Questo conto ha delle transazioni: non si può eliminare né cambiare valuta';

  @override
  String get settingsAppSettings => 'Impostazioni app';

  @override
  String get settingsPrototypeSettings => 'Impostazioni prototipo';

  @override
  String get settingsAuthentication => 'Autenticazione';

  @override
  String get settingsAccounts => 'Conti';

  @override
  String get settingsCategories => 'Categorie';

  @override
  String get settingsBudgets => 'Budget';

  @override
  String get settingsImportExport => 'Importa / Esporta';

  @override
  String get settingsNotifications => 'Notifiche';

  @override
  String get settingsFeedback => 'Feedback';

  @override
  String get settingsInfo => 'Info';

  @override
  String get settingsRestartOnboarding => 'Riavvia l\'onboarding';

  @override
  String get settingsLoadDemo => 'Carica i dati demo';

  @override
  String get currencyNameEUR => 'Euro';

  @override
  String get currencyNameUSD => 'Dollaro statunitense';

  @override
  String get currencyNameGBP => 'Sterlina britannica';

  @override
  String get currencyNameCHF => 'Franco svizzero';

  @override
  String get currencyNameBRL => 'Real brasiliano';

  @override
  String get currencyNameAED => 'Dirham degli Emirati';

  @override
  String get currencyNameJPY => 'Yen giapponese';

  @override
  String get currencyNameCAD => 'Dollaro canadese';

  @override
  String accountDeleteMessage(String name) {
    return '$name verrà rimosso dai tuoi conti.';
  }

  @override
  String get iconGroupFinance => 'Finanza';

  @override
  String get iconGroupCommerce => 'Shopping';

  @override
  String get iconGroupTravel => 'Viaggi e luoghi';

  @override
  String get iconGroupHealth => 'Salute';

  @override
  String get iconGroupPeople => 'Persone';

  @override
  String get iconGroupNature => 'Natura e meteo';

  @override
  String get iconGroupGames => 'Giochi';

  @override
  String get iconGroupMedia => 'Media';

  @override
  String get iconGroupOffice => 'Ufficio';

  @override
  String get iconGroupCommunication => 'Comunicazione';

  @override
  String get iconGroupObjects => 'Oggetti';

  @override
  String get onboardingStep2Subtitle =>
      'È il momento di creare le tue categorie e i relativi budget';

  @override
  String get onboardingYourCategories => 'Le tue categorie';

  @override
  String get onboardingFirstCategory => 'Crea la tua prima categoria';

  @override
  String get onboardingCreateCategory => 'Crea categoria';

  @override
  String get onboardingAddCategory => 'Aggiungi categoria';

  @override
  String get onboardingSuggested => 'Suggerite';

  @override
  String get onboardingSuggestedExpenses => 'Spese';

  @override
  String get onboardingSuggestedIncome => 'Entrate';

  @override
  String onboardingAddSuggested(String name) {
    return 'Aggiungi $name';
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
  String get categoryShowSubcategories => 'Mostra le sottocategorie';

  @override
  String get categoryHideSubcategories => 'Nascondi le sottocategorie';

  @override
  String get categoryNew => 'Nuova categoria';

  @override
  String get categoryEdit => 'Modifica categoria';

  @override
  String get categoryType => 'Tipo';

  @override
  String get categoryTypeExpense => 'Spesa';

  @override
  String get categoryTypeIncome => 'Entrata';

  @override
  String get categoryNamePlaceholder => 'Il nome della categoria';

  @override
  String get categoryBudget => 'Budget';

  @override
  String get categoryAddBudget => 'Aggiungi budget';

  @override
  String get categorySubcategories => 'Sottocategorie';

  @override
  String get categorySubcategoriesHint =>
      'Le sottocategorie ti permettono di gestire le transazioni in modo più preciso';

  @override
  String get categoryAddSubcategory => 'Aggiungi sottocategoria';

  @override
  String get categoryDelete => 'Elimina categoria';

  @override
  String get categoryDeleteTitle => 'Eliminare questa categoria?';

  @override
  String categoryDeleteMessage(String name) {
    return '$name, le sue sottocategorie e i suoi budget verranno rimossi.';
  }

  @override
  String get categoryDeleteConfirm => 'Elimina';

  @override
  String get categoryErrName => 'Inserisci un nome';

  @override
  String get categoryErrNameTaken =>
      'Hai già una categoria di questo tipo con questo nome';

  @override
  String get categoryErrInUse =>
      'Questa categoria ha delle transazioni: non si può eliminare né cambiarne il tipo';

  @override
  String get categoryTypeChangeTitle => 'Passare a entrata?';

  @override
  String get categoryTypeChangeMessage =>
      'Le categorie di entrata non hanno budget: quelli di questa categoria verranno scartati.';

  @override
  String get categoryTypeChangeConfirm => 'Cambia tipo';

  @override
  String get subcategoryNew => 'Nuova sottocategoria';

  @override
  String get subcategoryEdit => 'Modifica sottocategoria';

  @override
  String get subcategoryNamePlaceholder => 'Il nome della sottocategoria';

  @override
  String get subcategoryDelete => 'Elimina sottocategoria';

  @override
  String get subcategoryErrNameTaken =>
      'Questa categoria ha già una sottocategoria con questo nome';

  @override
  String get budgetFormNew => 'Nuovo budget';

  @override
  String get budgetFormEdit => 'Modifica budget';

  @override
  String get budgetSelectType => 'Seleziona il tipo';

  @override
  String get budgetSetAmount => 'Imposta l\'importo';

  @override
  String get budgetAmountPlaceholder => 'es. 100';

  @override
  String get budgetLimitAlert => 'Avviso al raggiungimento del limite';

  @override
  String get budgetCountForOverall => 'Conta nel budget complessivo';

  @override
  String get onboardingStep3Subtitle =>
      'E i tuoi investimenti, per tenerne traccia nell\'app';

  @override
  String get onboardingYourAssets => 'I tuoi asset';

  @override
  String get onboardingNoAssets => 'Ancora nessun asset';

  @override
  String get onboardingAddAsset => 'Aggiungi asset';

  @override
  String get onboardingSkipStep => 'Salta questo passo';

  @override
  String get onboardingStartTracking => 'Inizia a tracciare';

  @override
  String get assetQuantityLabel => 'Quantità:';

  @override
  String get assetPmcLabel => 'PMC:';

  @override
  String get assetNew => 'Nuovo asset';

  @override
  String get assetEdit => 'Modifica asset';

  @override
  String get assetMainDetails => 'Dettagli principali';

  @override
  String get assetSearch => 'Cerca per nome, ticker o ISIN';

  @override
  String get assetManualNamePlaceholder => 'Il nome dell\'asset';

  @override
  String get assetAmount => 'Quantità';

  @override
  String get assetAmountPlaceholder => 'es. 12';

  @override
  String get assetAveragePrice => 'Prezzo medio di acquisto';

  @override
  String get assetPricePlaceholder => 'es. 10,50';

  @override
  String get assetCountsForNetWorth => 'Conta nel patrimonio netto';

  @override
  String get assetDelete => 'Elimina asset';

  @override
  String get assetDeleteTitle => 'Eliminare questo asset?';

  @override
  String assetDeleteMessage(String name) {
    return '$name e il suo movimento di apertura verranno rimossi.';
  }

  @override
  String get assetDeleteConfirm => 'Elimina';

  @override
  String get assetErrChoose => 'Scegli un asset';

  @override
  String get assetErrDuplicate => 'Questo asset è già nella tua lista';

  @override
  String get assetErrNameRequired => 'Inserisci un nome';

  @override
  String get assetErrNameTaken => 'Hai già un asset manuale con questo nome';

  @override
  String get assetErrAmount => 'Inserisci una quantità';

  @override
  String get assetErrAmountPositive =>
      'La quantità deve essere maggiore di zero';

  @override
  String get assetErrAmountDecimals => 'Al massimo 8 decimali';

  @override
  String get assetErrAmountInvalid => 'Inserisci un numero valido';

  @override
  String get assetErrPrice => 'Inserisci un prezzo';

  @override
  String get assetErrPricePositive => 'Il prezzo deve essere maggiore di zero';

  @override
  String get assetErrDeleteRefused =>
      'Questo asset non si può eliminare: altri movimenti ne dipendono';

  @override
  String get dashboardNoTransactions => 'Ancora nessuna transazione';

  @override
  String get overviewCashFlowEmpty =>
      'Ancora nessuna entrata o spesa questo mese';

  @override
  String get accountMain => 'Conto principale';

  @override
  String get accountMainHint =>
      'Per cambiarlo, imposta un altro conto come principale';

  @override
  String get accountPageEdit => 'Modifica';

  @override
  String get accountsEmptyTitle => 'Nessun conto';

  @override
  String get accountsEmptyMessage => 'Aggiungine uno per iniziare.';

  @override
  String get accountNoTransactions =>
      'Ancora nessuna transazione in questo conto.';

  @override
  String get accountMainTag => 'Principale';

  @override
  String get addNewTransaction => 'Nuova transazione';

  @override
  String get addNewMovement => 'Nuovo movimento';

  @override
  String get addModeTransaction => 'Transazione';

  @override
  String get addModeMovement => 'Movimento di investimento';

  @override
  String get addModeSemantic => 'Cambia cosa aggiungere';

  @override
  String get addTransactionButton => 'Aggiungi transazione';

  @override
  String get addMovementButton => 'Aggiungi movimento';

  @override
  String get addTransactionDone => 'Transazione aggiunta';

  @override
  String get addMovementDone => 'Movimento aggiunto';

  @override
  String get addUndo => 'Annulla';

  @override
  String get txAmount => 'Importo';

  @override
  String get txCategory => 'Categoria';

  @override
  String get txSubcategory => 'Sottocategoria (facoltativa)';

  @override
  String get txSubcategories => 'Sottocategorie';

  @override
  String get txMore => 'Altre…';

  @override
  String get txErrCategory => 'Scegli una categoria';

  @override
  String get txNoExpenseCategories => 'Non hai ancora categorie di spesa.';

  @override
  String get txNoIncomeCategories => 'Non hai ancora categorie di entrata.';

  @override
  String get txNoAccounts => 'Serve un conto per aggiungere una transazione.';

  @override
  String get txAccount => 'Conto';

  @override
  String get txFrom => 'Da';

  @override
  String get txTo => 'A';

  @override
  String get txSwapAccounts => 'Inverti i conti';

  @override
  String get txAmountReceived => 'Importo ricevuto';

  @override
  String get txTransferNeedsTwo =>
      'Per fare un trasferimento servono almeno due conti.';

  @override
  String get txDate => 'Data';

  @override
  String get txToday => 'Oggi';

  @override
  String get txYesterday => 'Ieri';

  @override
  String get txOtherDate => 'Personalizzata';

  @override
  String get txDescription => 'Descrizione (facoltativa)';

  @override
  String get txRecurring => 'Ricorrente';

  @override
  String get txFrequency => 'Frequenza';

  @override
  String get txStartDate => 'Data di inizio';

  @override
  String get txEnd => 'Fine';

  @override
  String get txEndNever => 'Mai';

  @override
  String get txEndOnDate => 'Alla data';

  @override
  String get txEndAfter => 'Dopo';

  @override
  String get txEndDate => 'Data di fine';

  @override
  String get txEndCount => 'Numero di volte';

  @override
  String get txChooseDate => 'Scegli una data';

  @override
  String get txErrChooseDate => 'Scegli la data di fine';

  @override
  String get txErrEndBeforeStart => 'La fine è prima dell\'inizio';

  @override
  String get widgetUpcomingRecurringName => 'Prossime ricorrenze';

  @override
  String get dashboardNoUpcomingRecurring => 'Nessuna ricorrenza';

  @override
  String get widgetBudgetStatusName => 'Stato dei budget';

  @override
  String get widgetBudgetTitle => 'Budget';

  @override
  String get budgetTypeAll => 'Tutti';

  @override
  String get budgetTypeSemantic => 'Tipo di budget';

  @override
  String get widgetNoBudgets => 'Nessun budget';

  @override
  String widgetNoBudgetsOfPeriod(String period) {
    return 'Nessun budget $period';
  }

  @override
  String get kindTransfers => 'Trasferimenti';

  @override
  String get dashboardTransactionTypeSemantic => 'Tipo di transazione';

  @override
  String dashboardNoTransactionsOfType(String type) {
    return 'Nessuna transazione di tipo $type';
  }

  @override
  String dashboardNoRecurringOfType(String type) {
    return 'Nessuna ricorrenza di tipo $type';
  }

  @override
  String get widgetNetWorthName => 'Patrimonio netto';

  @override
  String get widgetNetWorthNoHistory => 'Storico non ancora sufficiente';

  @override
  String get netWorthPeriodSemantic => 'Periodo';

  @override
  String get netWorthPeriod3M => '3M';

  @override
  String get netWorthPeriod6M => '6M';

  @override
  String get netWorthPeriod1Y => '1A';

  @override
  String get netWorthPeriod3Y => '3A';

  @override
  String get netWorthPeriod5Y => '5A';

  @override
  String get netWorthPeriodAll => 'Tutto';

  @override
  String get widgetInvestmentsName => 'Investimenti';

  @override
  String get widgetInvestmentsPeriodSemantic => 'Periodo';

  @override
  String get netWorthPeriodYtd => 'YTD';

  @override
  String get widgetAllocationName => 'Allocazione';

  @override
  String get widgetInsightName => 'Insight del momento';

  @override
  String insightBudgetExceededTitle(String category) {
    return '$category oltre il budget';
  }

  @override
  String insightBudgetAtRiskTitle(String category) {
    return 'Budget $category a rischio';
  }

  @override
  String get insightRecurringDueToday => 'Pagamento in scadenza oggi';

  @override
  String get insightRecurringDueTomorrow => 'Pagamento in scadenza domani';

  @override
  String insightUnusualTitle(String category) {
    return 'Spesa insolita in $category';
  }

  @override
  String insightUnusualDetail(String ratio) {
    return '$ratio× il solito';
  }

  @override
  String get insightPortfolioDropTitle => 'Portafoglio in calo oggi';

  @override
  String get insightPortfolioGainTitle => 'Portafoglio in rialzo oggi';

  @override
  String get insightNetWorthHighTitle => 'Patrimonio più alto da un mese';

  @override
  String get insightNoTransactionTodayTitle => 'Niente registrato oggi';

  @override
  String get insightNoTransactionTodayDetail =>
      'Aggiungi le transazioni di oggi';

  @override
  String get insightNoRecentTitle => 'Nessuna transazione recente';

  @override
  String insightNoRecentDetail(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni dall\'ultima',
      one: '1 giorno dall\'ultima',
    );
    return '$_temp0';
  }

  @override
  String get insightFirstTransactionTitle =>
      'Aggiungi la tua prima transazione';

  @override
  String get insightFirstTransactionDetail =>
      'Inizia a tracciare le tue finanze';

  @override
  String get insightAllGoodTitle => 'Tutto a posto per oggi';

  @override
  String get insightAllGoodDetail => 'Niente richiede la tua attenzione';

  @override
  String get showcaseBudgetExceeded => 'Budget sforato';

  @override
  String get showcaseRecurringDue => 'Ricorrente in scadenza';

  @override
  String get showcaseBudgetAtRisk => 'Budget a rischio';

  @override
  String get showcaseUnusualExpense => 'Spesa anomala';

  @override
  String get showcasePortfolioDrop => 'Calo del portafoglio';

  @override
  String get showcaseReminder => 'Promemoria';

  @override
  String get showcasePositive => 'Notizia positiva';

  @override
  String get showcaseAllGood => 'Nessun insight';

  @override
  String get transactionTypeAll => 'Tutte';

  @override
  String get settingsWidgetShowcase => 'Showcase dei widget';

  @override
  String get showcaseIntro => 'Ogni widget, caso e taglia, con dati demo';

  @override
  String get showcaseWithData => 'Con dati';

  @override
  String get showcaseNewUser => 'Nuovo utente, senza dati';

  @override
  String get categoriesGroupIncome => 'Entrate';

  @override
  String get categoriesGroupExpenses => 'Spese';

  @override
  String get categoriesAddSemantic => 'Aggiungi categoria';

  @override
  String get categoriesEmptyTitle => 'Nessuna categoria';

  @override
  String get categoriesEmptyMessage => 'Aggiungine una con il pulsante +.';

  @override
  String categorySubcategoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sottocategorie',
      one: '1 sottocategoria',
      zero: 'Nessuna sottocategoria',
    );
    return '$_temp0';
  }

  @override
  String get categoryPageEdit => 'Modifica';

  @override
  String get categoryDetailSubcategories => 'Sottocategorie';

  @override
  String get categoryDetailTransactions => 'Transazioni';

  @override
  String get categoryNoTransactions =>
      'Ancora nessuna transazione in questa categoria.';

  @override
  String get subcategoryNoTransactions =>
      'Ancora nessuna transazione in questa sottocategoria.';

  @override
  String get categoryDetailRecurring => 'Ricorrenti';

  @override
  String get accountsAddSemantic => 'Aggiungi conto';

  @override
  String get transactionDetailEdit => 'Modifica';

  @override
  String get transactionEdit => 'Modifica transazione';

  @override
  String get transactionSave => 'Salva transazione';

  @override
  String get transactionDelete => 'Elimina transazione';

  @override
  String get transactionDeleteTitle => 'Eliminare questa transazione?';

  @override
  String get transactionDeleteMessage =>
      'Verrà rimossa e saldi, grafici e budget verranno aggiornati.';

  @override
  String get transactionDeleteConfirm => 'Elimina';

  @override
  String get transactionUpdated => 'Transazione aggiornata';

  @override
  String get transactionAskOnlyThis => 'Solo questa transazione';

  @override
  String get transactionAskRecurrence => 'La ricorrenza (dalle prossime)';

  @override
  String get transactionSubcategoryNone => 'Nessuna';

  @override
  String get transactionShowRecurrence => 'Mostra ricorrenza';

  @override
  String get recurringPausedLabel => 'In pausa';

  @override
  String get infoAppVersion => 'Versione dell\'app';

  @override
  String get infoCollaborators => 'Collaboratori';

  @override
  String get infoCollaboratorsSubtitle => 'Vedi il team dietro a questa app';

  @override
  String get infoContribute => 'Vuoi contribuire?';

  @override
  String get infoContributeSubtitle =>
      'Apri una issue, invia una PR o passa a salutarci su GitHub';

  @override
  String get infoPrivacyPolicy => 'Privacy policy';

  @override
  String get collaboratorsIntroTitle => 'Conosci il team';

  @override
  String get collaboratorsIntro =>
      'Sossoldi è creata e mantenuta da una community open source appassionata. Ogni funzione, correzione e idea nasce da persone come te.';

  @override
  String get linkGithub => 'GitHub';

  @override
  String get linkLinkedin => 'LinkedIn';

  @override
  String get linkYoutube => 'YouTube';

  @override
  String get linkDiscord => 'Discord';

  @override
  String get linkWebsite => 'Sito web';

  @override
  String get communityFooter => 'Open source, creata dalla community';

  @override
  String get privacyIntro =>
      'Sossoldi è un\'app open source. Questo servizio è offerto da noi gratuitamente e va usato così com\'è. Non siamo interessati a raccogliere informazioni personali: crediamo che appartengano solo a te. Non conserviamo né trasmettiamo i tuoi dati personali e non includiamo pubblicità né software di analisi che comunichi con terze parti.';

  @override
  String get privacyCollectTitle => 'Quali informazioni raccogliamo?';

  @override
  String get privacyCollectBody =>
      'Sossoldi non raccoglie informazioni personali e non si collega a internet. Tutto ciò che aggiungi nell\'app resta solo sul tuo dispositivo e da nessun\'altra parte.';

  @override
  String get privacyChangesTitle => 'Modifiche a questa privacy policy';

  @override
  String get privacyChangesBody =>
      'Potremmo aggiornare la nostra Privacy Policy di tanto in tanto. Ti consigliamo quindi di rivedere questa pagina periodicamente per eventuali modifiche.';

  @override
  String get privacyEffective => 'Questa policy è in vigore dal 2024-01-01';

  @override
  String get privacyContactTitle => 'Contattaci';

  @override
  String get privacyContactBody =>
      'Se hai domande o suggerimenti sulla nostra Privacy Policy, non esitare a contattarci a';

  @override
  String get notificationsReminderTitle => 'Promemoria transazioni';

  @override
  String get notificationsReminderSubtitle =>
      'Un promemoria per registrare le transazioni';

  @override
  String get notificationsRecurringTitle => 'Transazione ricorrente aggiunta';

  @override
  String get notificationsRecurringSubtitle =>
      'Quando una ricorrenza viene registrata nelle transazioni';

  @override
  String get notificationsFrequency => 'Frequenza';

  @override
  String get notificationsDay => 'Giorno';

  @override
  String get notificationsTime => 'Ora';

  @override
  String get reminderDaily => 'Giornaliero';

  @override
  String get reminderWeekly => 'Settimanale';

  @override
  String get reminderBiweekly => 'Ogni 2 settimane';

  @override
  String get reminderMonthly => 'Mensile';

  @override
  String get timePickerConfirm => 'Conferma';
}
