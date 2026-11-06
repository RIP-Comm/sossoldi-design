# Backlog — Sossoldi V2 prototype

NON caricato in automatico (fuori da `.claude/rules/`). Leggerlo solo per stato, "cosa manca", priorità.
Stato: todo / needs design / blocked. Aggiornato: 2026-11-03 (navbar, blur, tendine).

## Next up (max 5)
- [ ] Account principale: scelta dell'account da Settings > Accounts (la flag esiste) — todo — `mock/models/account.dart`
- [ ] Settings: Accounts e Categories & budgets (riusano i form di onboarding; qui arrivano anche i "Manage") — todo — `features/accounts`, `categories`, `budgets`
- [ ] Widget Dashboard core mancanti: Income & expenses (Budget status fatto) — todo (spec S/M/L in Figma "Widget - Components") — `dashboard/registry/dashboard_widget_registry.dart`
- [ ] Dettaglio, modifica ed eliminazione di una transazione (il tap oggi non fa nulla) — needs design — `transaction_row.dart`
- [ ] Settings > General (autenticazione) e sezioni restanti — needs design — `settings_screen.dart`

## To do

### Dashboard
- [ ] Widget opzionali: Insight of the moment — todo, spec in Figma "Widget - Components" — registry (Net worth e Investments snapshot fatti)
- [ ] Widget Savings goals — needs design; nessun modello dati per gli obiettivi in `lib/mock/models/` (verificato) — blocked

### Finance
- [ ] "Manage" conti (Overview) → Settings > Accounts — todo, oggi PlaceholderScreen — `finance/overview/overview_tab_view.dart:120`
- [ ] "Manage" budget (Overview) → Settings > Budgets — todo, oggi PlaceholderScreen — `overview_tab_view.dart:307`

### Investments
- [ ] Position page, menu "…" > "Update value" (asset manuale): PlaceholderScreen — needs design — `positions/position_detail_screen.dart:46,86`

### Add transaction
- [x] Add sheet unico (spesa, entrata, trasferimento con cambio, ricorrenza, movimento investimento), suggerimenti, Undo — fatto — `features/add_transaction/add_sheet.dart`
- [ ] Dettaglio, modifica ed eliminazione di una transazione — needs design — `transaction_row.dart`

### Settings
- [ ] General: tema (c'è), lingua (c'è), valuta (c'è), autenticazione — todo / needs design — `settings_screen.dart`
- [ ] Accounts (lista, ordine, crea/modifica/elimina) — todo — `features/accounts`
- [ ] Categories & budgets, incluso "Add budget" (il form esiste) — todo — `features/budgets/budget_form_sheet.dart`
- [ ] Investments, Import/Export, Notifications, Feedback, App info — needs design
- [ ] Connessioni banca/broker — blocked (stato API da verificare)

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
- [ ] Rifinire la UI dell'Inspector insieme (pannello destro: gerarchie, cosa mostrare per primo) — in corso
- [ ] Tooltip sugli strumenti della toolbar (SossoldiTooltipTarget si apre anche al tap: va bene solo al passaggio del mouse) — todo
- [ ] Più scene: pagine di dettaglio (budget, ricorrenza, posizione, movimento), Step 1–3 dell'onboarding, form, Dashboard in edit mode, stati vuoti — todo
- [ ] Distanze tra fratelli di un Row/Column (gap) disegnate sul telefono, misure con Alt come in Figma — todo
- [ ] Copia dei valori (snippet Flutter / CSS) e link alla scena (URL per scena, tema, lingua) — todo
- [ ] Widgetbook pubblicato accanto all'Inspector (cartella `widgetbook/` del sito, o un altro indirizzo con `WIDGETBOOK_URL`): ora il link "Open in Widgetbook" funziona solo in locale (porta 8082) — da decidere
- [ ] Widgetbook non compila: `widgetbook/lib/components/app_shell_use_cases.dart:357` usa `LatestTransactionsCard` senza i nuovi parametri `selector` e `title` — todo (lavoro Dashboard)
- [ ] Hosting: collegare il branch `site` a un hosting statico (Cloudflare Pages o altro) e al dominio di Sossoldi; sottodominio o sottocartella (`INSPECTOR_BASE_HREF`) — blocked (collega)
- [ ] Sito vetrina di Sossoldi con una pagina per gli sviluppatori che porta all'Inspector (link o iframe) — da decidere
- [ ] Rigenerare `lib/catalog/widget_names.g.dart` quando si aggiungono componenti o schermate (`dart run tool/generate_widget_names.dart`) — controllo ricorrente
- [ ] Conti broker: le operazioni non spostano denaro tra conti (semplificazione nota) — todo/decidere

## Open questions
- Nessuna aperta. Decise: nessun insight → non si mostra nulla, non sono tappabili; conti e categorie in ordine alfabetico (si rivede in Settings)

## Done (più recente in alto)
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
