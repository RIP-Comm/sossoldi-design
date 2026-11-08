# Backlog — Sossoldi V2 prototype

Leggerlo solo per stato, "cosa manca", priorità.
Stato: todo / needs design / blocked. Aggiornato: 2026-11-07 (Dashboard completata).

## To do

### Finance
- [x] "Manage" conti (Overview) → pagina Accounts — fatto — `finance/overview/overview_tab_view.dart`
- [ ] "Manage" budget (Overview) → Settings > Budgets — todo, oggi PlaceholderScreen — `overview_tab_view.dart:307`

### Investments
- [ ] Position page, menu "…" > "Update value" (asset manuale): PlaceholderScreen — needs design — `positions/position_detail_screen.dart:46,86`

### Add transaction
- [ ] Dettaglio, modifica ed eliminazione di una transazione — needs design — `transaction_row.dart`

### Settings
- [x] Settings a due livelli (hub, App settings, Prototype settings) con i placeholder autonomi — fatto — `features/settings/`
- [ ] Authentication: pagina vera (oggi placeholder) — needs design — `authentication_settings_screen.dart`
- [x] Accounts: elenco (ordinato per saldo convertito, tag "Principale", chevron) e pagina di dettaglio del conto (andamento del saldo, transazioni, Edit) — fatto — `features/accounts/accounts_screen.dart`, `account_detail_screen.dart`
- [ ] Accounts: scelta dell'account principale dall'elenco o dal dettaglio (oggi solo dallo switch del form) — todo
- [ ] Accounts: riordino dei conti (tap & hold, alfabetico, personalizzato) — needs design
- [ ] Accounts: transazione in valuta diversa dal conto, campo valuta nel form del conto (commentato) — needs design
- [ ] Categories: pagina di gestione (apribile da altre schermate) — todo — `categories_settings_screen.dart`, `features/categories`
- [ ] Budgets: pagina di gestione, incluso "Add budget" (il form esiste; apribile dal "Manage" di Finance) — todo — `budgets_settings_screen.dart`, `features/budgets/budget_form_sheet.dart`
- [ ] Import / Export: placeholder — needs design — `import_export_settings_screen.dart`
- [ ] Notifications: placeholder — needs design — `notifications_settings_screen.dart`
- [ ] Feedback: placeholder — needs design — `feedback_settings_screen.dart`
- [ ] Info: placeholder — needs design — `info_settings_screen.dart`
- [ ] Voci Investments e connessioni banca/broker — blocked (punto aperto, stato API da verificare)

### Onboarding
- [ ] Import da un'altra app (pre-crea conti, categorie, valute) — needs design — `onboarding_welcome_screen.dart:133`
- [ ] Campo valuta del conto commentato (valuta unica per ora) — blocked (multi-valuta) — `account_form_sheet.dart:219`
- [ ] "Limit reach alert" dei budget: solo salvato, nessuna notifica — blocked (Notifications) — `mock/models/budget.dart`
- [ ] "Counts for Net Worth" degli asset: solo salvato, nessun totale lo usa — blocked (Net worth) — `Holding.countsForNetWorth`

### Design system
- [ ] Blur progressivo: oggi 16 fasce di `BackdropFilter` (`app/top_blur.dart`); un vero shader continuo è un'idea da provare (con ripiego dove non è supportato) e le prestazioni su telefono non sono misurate — todo
- [ ] Mappatura finale dei token e elenco completo dei componenti (sezione "To be completed") — todo — `rules/design-system.md`
- [ ] Hidden Mode (maschera importi): interruttore globale c'è, verificare copertura — todo
- [ ] Ordine alfabetico di conti e categorie (nessun riordino manuale per ora) — todo

### Tecnico
- [ ] Elenco font DM Sans in sync tra `pubspec.yaml`, `widgetbook/pubspec.yaml` e `inspector/pubspec.yaml` — controllo ricorrente

### Inspector (`inspector/`)
- [x] Rifinire la UI dell'Inspector insieme (pannello destro: gerarchie, cosa mostrare per primo) — in corso
- [ ] Tooltip sugli strumenti della toolbar (SossoldiTooltipTarget si apre anche al tap: va bene solo al passaggio del mouse) — todo
- [ ] Più scene: pagine di dettaglio (budget, ricorrenza, posizione, movimento), Step 1–3 dell'onboarding, form, Dashboard in edit mode, stati vuoti — todo
- [x] Distanze tra fratelli di un Row/Column (gap) disegnate sul telefono, misure con Alt come in Figma — todo
- [ ] Copia dei valori (snippet Flutter / CSS) e link alla scena (URL per scena, tema, lingua) — todo
- [ ] Widgetbook pubblicato accanto all'Inspector (cartella `widgetbook/` del sito, o un altro indirizzo con `WIDGETBOOK_URL`): ora il link "Open in Widgetbook" funziona solo in locale (porta 8082) — da decidere
- [ ] Widgetbook non compila: `widgetbook/lib/components/app_shell_use_cases.dart:357` usa `LatestTransactionsCard` senza i nuovi parametri `selector` e `title` — todo (lavoro Dashboard)
- [x] Hosting: collegare il branch `site` a un hosting statico (Cloudflare Pages o altro) e al dominio di Sossoldi; sottodominio o sottocartella (`INSPECTOR_BASE_HREF`) — blocked (collega)
- [ ] Sito vetrina di Sossoldi con una pagina per gli sviluppatori che porta all'Inspector (link o iframe) — da decidere
- [ ] Rigenerare `lib/catalog/widget_names.g.dart` quando si aggiungono componenti o schermate (`dart run tool/generate_widget_names.dart`) — controllo ricorrente
- [ ] Conti broker: le operazioni non spostano denaro tra conti (semplificazione nota) — todo/decidere

## Open questions
- Nessuna aperta.

## Done (più recente in alto)
- [x] 2026-11-08 — Settings > Accounts: pagina elenco dei conti (saldo decrescente convertito, negativi in fondo, tag Principale, "Add account +") e pagina del conto (saldo e variazione nel periodo, chip del periodo come in Net worth, grafico con tooltip, transazioni con ricerca e filtri propri, Edit col form esistente); `MockRepository.accountsByBalance`, `accountSeries`, `accountHistoryStart`, `accountPeriodAvailable`; il "Manage" della Finance Overview apre la stessa pagina; `SossoldiAccountItem(hasChevron:)`; il filtro conto del foglio filtri si nasconde (`showAccount`)
- [x] 2026-11-08 — Settings a due livelli: hub con "App settings" e "Prototype settings"; App settings in tre blocchi (tema, lingua, valuta principale, Authentication / Accounts, Categories, Budgets, Import / Export / Notifications, Feedback, Info); Authentication, Accounts, Categories, Budgets, Import / Export, Notifications, Feedback e Info sono schermate autonome con `route()` (placeholder); Restart onboarding, Widget showcase e Load demo data in Prototype settings
- [x] 2026-11-07 — Dashboard chiusa: Income & expenses coperto da Monthly balance, Savings goals scartato
- [x] 2026-11-07 — Righe di Ultime transazioni e Prossime ricorrenze in M come in L (stessa spaziatura, 2 righe); pagina "Showcase dei widget" in Settings > Prototipo con tutti i widget, taglie e casi (cluster per widget, dati demo e nuovo utente); corretti overflow in Budget status (chip del periodo) e Allocazione S (legenda stretta)
- [x] 2026-11-07 — Widget Dashboard: padding di 12 px su tutti i lati in tutte le taglie (solo i grafici senza assi vanno a filo); chip "Tutte" (non "Tutti") in Ultime transazioni e Prossime ricorrenze; Upcoming recurring M ora mostra 2 righe
- [x] 2026-11-07 — Dashboard iniziale: set completo di widget in taglie diverse (Insight S e Monthly balance S, Budget status M, Net worth M, Upcoming recurring S e Allocation S, Latest transactions L, Investments L); Insight portafoglio e patrimonio con il valore in title large
- [x] 2026-11-07 — Insight: solo taglia S, dettaglio ancorato in basso con i componenti degli altri widget (figure e barra del budget, importo, change indicator); rimosse M e bottone; pagina showcase in Settings > Prototipo
- [x] 2026-11-07 — Widget Dashboard "Insight of the moment" (solo S dopo la revisione del 2026-11-07, opzionale, non nel layout iniziale): un solo insight scelto da `InsightEngine` (`lib/insights/`, Dart puro, `now` iniettabile, soglie in `insight_constants.dart`) con 8 livelli di priorità (budget sforato negli ultimi 7 giorni, ricorrente oggi/domani, budget a rischio, spesa anomala, calo portafoglio e sforamenti vecchi, promemoria, notizia positiva, "All good"); tono → colore semantico, tap e bottone (M) aprono budget, ricorrente, lista transazioni (filtrata sulla categoria), Investments > Overview o l'Add sheet; ricalcolo su cambio dati, ritorno in primo piano e alle 18:00/mezzanotte; nuovi metodi `budgetExceededOn`, `categoryExpenseStats`, `lastTransactionDate`, `netWorthHighBefore`; `AppShellScope.openTransactions`
- [x] 2026-11-06 — Widget Dashboard "Asset allocation" (S/M/L, opzionale): composizione dell'Overview (stessi dati e colori: `allocationColor`), `allocationBreakdown` con "Other" e percentuali intere che sommano 100; S 4 righe + Other, M 5 + Other, L con selettore Asset class / Single asset (primi 6 asset + Other) e importi mascherabili; la vista è nell'istanza del widget; tap → Investments > Overview
- [x] 2026-11-06 — Investments e Net worth: default year to date ovunque (nuovo periodo YTD in Net worth); S con etichetta YTD senza chip e variazione YTD (anche Net worth S), M e L con chip in alto a destra
- [x] 2026-11-06 — Investments e Net worth: variazione a destra del valore; Investments S/M con grafico a tutta larghezza senza assi né legenda (S 1M con la variazione del mese, M YTD), L con chip in alto a destra, solo variazione del periodo e legenda sotto il grafico
- [x] 2026-11-06 — Widget Dashboard "Investments snapshot" (S/M/L, opzionale): valore (posizioni + liquidità), variazione giornaliera e YTD come performance di mercato al netto dei versamenti (`investmentsSnapshot`), L con chip periodo (default 1M) e grafico dell'Overview con assi e senza legenda, tap → Investments > Overview (`AppShellScope`); nuova resa della variazione (`SossoldiChangeIndicator`: chip con freccia e %, importo in testo) usata anche da Net worth M/L
- [x] 2026-11-05 — Net worth: chip del periodo in alto a destra; grafici di Monthly balance e Net worth con indicatore e tooltip al tap/trascinamento (`SossoldiTrendChart`, stesso tooltip dei grafici di Finance e Investments)
- [x] 2026-11-05 — Widget Dashboard "Net worth" (S/M/L, opzionale): conti + posizioni (liquidità non doppia), periodi 3M/6M/1Y/3Y/5Y/All con chip e menu (non coperti disattivati), variazione € e %, grafico a una serie; `netWorthSeries`, `netWorthAt`, `netWorthPeriodAvailable`
- [x] 2026-11-05 — Dashboard: riga di intestazione (titolo Label Large bold + chip del tipo) anche in Latest transactions e Upcoming recurring (M, L; filtro Tutti/Uscite/Entrate/Trasferimenti salvato nell'istanza); righe compatte da 44 px; titolo di Budget status ridotto
- [x] 2026-11-05 — Widget Dashboard "Budget status" (S/M/L, core): budget per rilevanza (`budgetsByRelevance`, filtro periodo e limite), chip selettore del tipo (All/Weekly/…) salvata nell'istanza (`DashboardItem.settings`), disattivata in modifica, tap → pagina del budget; layout iniziale: Budget status (M) al posto del secondo Monthly balance; `SossoldiBudgetBar.thickness`, `SossoldiPopover.alignEnd`
- [x] 2026-11-03 — Navbar: bordo `strokeMinus1` in light e dark, padding interno 4 px; blur progressivo sotto la barra di stato e la barra in alto (Home, Finance, Investments: `ProgressiveBlur`, `TopBlur`); Dashboard di default con quattro widget (S, S, L, M)
- [x] 2026-11-03 — Dashboard: nella variante S nessuno spazio tra descrizione e conto; trascinamento di un M sopra un altro M non sposta più le S sopra
- [x] 2026-11-03 — `SossoldiSelect`: la tendina resta nello schermo, si apre verso l'alto se serve, scorre dentro ed è attaccata al campo
- [x] 2026-11-06 — Inspector: switch tema piccolo (`SossoldiSwitch(size:)`), sottotitolo "V2 prototype", albero dei livelli cliccabile sempre (un livello e il componente che avvolge condividono il box) e con cursore a manina, pulsante Widgetbook testo piccolo
- [x] 2026-11-06 — Inspector: albero dei livelli con icone per tipo (componenti viola), sezione dettagli componente (nome, file, link Widgetbook), variabili del design system in chip blu (`SossoldiTagType.info`), tema dell'Inspector con switch nella sidebar (default chiaro)
- [x] 2026-11-04 — GitHub Action che a ogni push su `main` testa e compila l'Inspector nel branch `site` (file statici per qualsiasi hosting)
- [x] 2026-11-03 — Inspector: toolbar flottante stile Figma (menu device, lingua, dati, selezione, zoom; dark mode e modalità), pannello destro ridimensionabile, menu con titoli in evidenza, niente ombra dentro il telefono; `SossoldiMenuItem(dense:)` e `SossoldiPopover(above:)`
- [x] 2026-11-03 — Inspector (bozza): app web in `inspector/` con menu delle schermate, telefono, pannello dev mode (misure, padding, auto layout, colori, testo, token)
- [x] 2026-11-02 — Widget Dashboard "Upcoming recurring" (S/M/L, opzionale, oggi incluso, stato vuoto)
- [x] 2026-10-30 — Snackbar e ombre del pulsante add, animazione e posizione dello snackbar
- [x] 2026-10-30 — Add sheet: un solo bottom sheet per transazioni e movimenti (conto principale, trasferimenti con cambio, ricorrenze, suggerimenti, Undo)
- [x] 2026-10-28 — Form asset dell'onboarding sceglie l'asset come il form movimento
- [x] 2026-10-28 — Pulsante Back sopra il titolo degli step; fix bordo asset scelto e ricerca web
- [x] 2026-10-28 — Test: il form conto conserva il testo e chiede numeri
- [x] 2026-10-28 — App costruita, onboarding (splash, welcome, step 1–3), fix dei form su iOS
- [x] 2026-10-23 — Database mock in memoria
- [x] 2026-10-22 — Progetto Flutter e design system (token, tema, componenti, widgetbook)
