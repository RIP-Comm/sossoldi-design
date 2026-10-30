# Backlog — Sossoldi V2 prototype

NON caricato in automatico (fuori da `.claude/rules/`). Leggerlo solo per stato, "cosa manca", priorità.
Stato: todo / needs design / blocked. Aggiornato: 2026-10-30.

## Next up (max 5)
- [ ] Add transaction: disegno in Figma, poi "+" come unico ingresso con selettore di tipo — needs design — `app_shell.dart:_actionFor`, IA "Add transaction"
- [ ] Settings: Accounts e Categories & budgets (riusano i form di onboarding; qui arrivano anche i "Manage") — todo — `features/accounts`, `categories`, `budgets`
- [ ] Dettaglio/modifica/eliminazione transazione (oggi il tap non fa nulla) — needs design — `transaction_row.dart`
- [ ] Widget Dashboard core mancanti: Income & expenses, Budget status — todo (spec S/M/L in Figma "Widget - Components") — `dashboard/registry/dashboard_widget_registry.dart`
- [ ] "Add recurrent transaction +" in Finance > Recurring — needs design — `recurring_tab_view.dart:116`

## To do

### Dashboard
- [ ] Widget opzionali: Upcoming recurring, Investments snapshot, Net worth, Insight of the moment — todo, spec in Figma "Widget - Components" — registry
- [ ] Widget Savings goals — needs design; nessun modello dati per gli obiettivi in `lib/mock/models/` (verificato) — blocked
- [ ] Layout della Dashboard solo in memoria (nessuna persistenza) — todo — `dashboard_controller.dart`

### Finance
- [ ] "Manage" conti (Overview) → Settings > Accounts — todo, oggi PlaceholderScreen — `finance/overview/overview_tab_view.dart:120`
- [ ] "Manage" budget (Overview) → Settings > Budgets — todo, oggi PlaceholderScreen — `overview_tab_view.dart:307`
- [ ] "Add recurrent transaction +" — needs design — `recurring_tab_view.dart:116`
- [ ] Barra segmentata del totale in Budget nascosta (codice commentato) — todo/decidere — `budget/budget_tab_view.dart:124`
- [ ] Commento di testata obsoleto ("Only Transactions > List is built") — todo — `finance_screen.dart:3`

### Investments
- [ ] Position page, menu "…" > "Update value" (asset manuale): PlaceholderScreen — needs design — `positions/position_detail_screen.dart:46,86`
- [ ] Commento obsoleto ("Only Overview is built") — todo — `investments_screen.dart:4`
- [ ] Commento obsoleto sui bottoni Buy/Sell/Dividend "placeholder" (ora aprono il form) — todo — `position_detail_screen.dart:6`
- [ ] Aggiornamento manuale del prezzo di un asset manuale — needs design — `mock-data.md`
- [ ] Prezzi simulati: nessun feed reale (fuori scope prototipo) — blocked

### Add transaction
- [ ] Schermata completa (importo, categoria, conto, data, ricorrenza, budget rimanente, categoria automatica) — needs design — `add_transaction/add_transaction_placeholder_screen.dart`
- [ ] "+" fuori da Investments apre il segnaposto; in Investments il form movimento — todo — `app_shell.dart:52-57`
- [ ] Selettore di tipo (spesa / entrata / trasferimento / investimento) — needs design — IA Open points

### Settings
- [ ] General: tema (c'è), lingua (c'è), valuta (c'è), autenticazione — todo / needs design — `settings_screen.dart`
- [ ] Accounts (lista, ordine, crea/modifica/elimina) — todo — `features/accounts`
- [ ] Categories & budgets, incluso "Add budget" (il form esiste) — todo — `features/budgets/budget_form_sheet.dart`
- [ ] Investments, Import/Export, Notifications, Feedback, App info — needs design
- [ ] Connessioni banca/broker — blocked (stato API da verificare)

### Onboarding
- [ ] Import da un'altra app (pre-crea conti, categorie, valute) — needs design — `onboarding_welcome_screen.dart:133`
- [ ] Commento di testata obsoleto (parla di step 2 e 3 come segnaposto) — todo — `onboarding_flow.dart:2`
- [ ] Campo valuta del conto commentato (valuta unica per ora) — blocked (multi-valuta) — `account_form_sheet.dart:219`
- [ ] "Limit reach alert" dei budget: solo salvato, nessuna notifica — blocked (Notifications) — `mock/models/budget.dart`
- [ ] "Counts for Net Worth" degli asset: solo salvato, nessun totale lo usa — blocked (Net worth) — `Holding.countsForNetWorth`

### Design system
- [ ] Mappatura finale dei token e elenco completo dei componenti (sezione "To be completed") — todo — `rules/design-system.md`
- [ ] Hidden Mode (maschera importi): interruttore globale c'è, verificare copertura — todo
- [ ] Riordino di conti e categorie (tap & hold) — needs design — `rules/research.md`

### Tecnico
- [ ] Lingua portoghese (EN e IT esistono) — todo — `lib/l10n/`
- [ ] Nessuna persistenza (tutto in memoria) — fuori scope prototipo
- [ ] Elenco font DM Sans in sync tra `pubspec.yaml` e `widgetbook/pubspec.yaml` — controllo ricorrente
- [ ] Verificare i codici ISIN dei bond (BTP Valore, BTP Italia) — todo — `mock-data.md`
- [ ] Conti broker: le operazioni non spostano denaro tra conti (semplificazione nota) — todo/decidere

## Needs design (bloccate da Figma)
- [ ] Add transaction e selettore di tipo
- [ ] Dettaglio / modifica / eliminazione transazione
- [ ] Add recurrent transaction
- [ ] Import da un'altra app
- [ ] Settings (tutte le sezioni oltre a tema, lingua, valuta)
- [ ] Savings goals e Insight of the moment
- [ ] Aggiornamento valore di un asset manuale
- [ ] Stati vuoti senza disegno (testo neutro con i componenti esistenti): Dashboard "Latest transactions" ("No transactions yet"), Finance Overview cash flow ("No income or expenses this month yet"), altre schermate con nuovo utente (Budget, Recurring, Investments con portafoglio vuoto)

## Open questions
- Insights: cosa mostrare se non ce ne sono? Sono tappabili? (assunzione: no)
- Asset in onboarding: quali campi oltre a quantità, valore e PMC?
- Stato delle API banca e broker: da verificare
- "+" globale: selettore di cosa aggiungere al posto dell'azione per sezione
- Ordine alfabetico o personalizzato per conti e categorie

## Done (più recente in alto)
- [x] 2026-10-28 — Form asset dell'onboarding sceglie l'asset come il form movimento
- [x] 2026-10-28 — Pulsante Back sopra il titolo degli step; fix bordo asset scelto e ricerca web
- [x] 2026-10-28 — Test: il form conto conserva il testo e chiede numeri
- [x] 2026-10-28 — App costruita, onboarding (splash, welcome, step 1–3), fix dei form su iOS
- [x] 2026-10-23 — Database mock in memoria
- [x] 2026-10-22 — Progetto Flutter e design system (token, tema, componenti, widgetbook)
