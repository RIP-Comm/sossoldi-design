# Backlog — Sossoldi V2 prototype

NON caricato in automatico (fuori da `.claude/rules/`). Leggerlo solo per stato, "cosa manca", priorità.
Stato: todo / needs design / blocked. Aggiornato: 2026-10-30 (Add sheet).

## Next up (max 5)
- [ ] Account principale: scelta dell'account da Settings > Accounts (la flag esiste) — todo — `mock/models/account.dart`
- [ ] Settings: Accounts e Categories & budgets (riusano i form di onboarding; qui arrivano anche i "Manage") — todo — `features/accounts`, `categories`, `budgets`
- [ ] Widget Dashboard core mancanti: Income & expenses, Budget status — todo (spec S/M/L in Figma "Widget - Components") — `dashboard/registry/dashboard_widget_registry.dart`
- [ ] Dettaglio, modifica ed eliminazione di una transazione (il tap oggi non fa nulla) — needs design — `transaction_row.dart`
- [ ] Settings > General (autenticazione) e sezioni restanti — needs design — `settings_screen.dart`

## To do

### Dashboard
- [ ] Widget opzionali: Upcoming recurring, Investments snapshot, Net worth, Insight of the moment — todo, spec in Figma "Widget - Components" — registry
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
- [ ] Mappatura finale dei token e elenco completo dei componenti (sezione "To be completed") — todo — `rules/design-system.md`
- [ ] Hidden Mode (maschera importi): interruttore globale c'è, verificare copertura — todo
- [ ] Ordine alfabetico di conti e categorie (nessun riordino manuale per ora) — todo

### Tecnico
- [ ] Elenco font DM Sans in sync tra `pubspec.yaml` e `widgetbook/pubspec.yaml` — controllo ricorrente
- [ ] Conti broker: le operazioni non spostano denaro tra conti (semplificazione nota) — todo/decidere

## Open questions
- Nessuna aperta. Decise: nessun insight → non si mostra nulla, non sono tappabili; conti e categorie in ordine alfabetico (si rivede in Settings)

## Done (più recente in alto)
- [x] 2026-10-30 — Snackbar e ombre del pulsante add, animazione e posizione dello snackbar
- [x] 2026-10-30 — Add sheet: un solo bottom sheet per transazioni e movimenti (conto principale, trasferimenti con cambio, ricorrenze, suggerimenti, Undo)
- [x] 2026-10-28 — Form asset dell'onboarding sceglie l'asset come il form movimento
- [x] 2026-10-28 — Pulsante Back sopra il titolo degli step; fix bordo asset scelto e ricerca web
- [x] 2026-10-28 — Test: il form conto conserva il testo e chiede numeri
- [x] 2026-10-28 — App costruita, onboarding (splash, welcome, step 1–3), fix dei form su iOS
- [x] 2026-10-23 — Database mock in memoria
- [x] 2026-10-22 — Progetto Flutter e design system (token, tema, componenti, widgetbook)
