# Backlog — Sossoldi V2 prototype

NON caricato in automatico (fuori da `.claude/rules/`). Leggerlo solo per stato, "cosa manca", priorità.
Stato: todo / needs design / blocked. Aggiornato: 2026-11-03 (navbar, blur, tendine).

## Next up (max 5)
- [ ] Account principale: scelta dell'account da Settings > Accounts (la flag esiste) — todo — `mock/models/account.dart`
- [ ] Settings: Accounts e Categories & budgets (riusano i form di onboarding; qui arrivano anche i "Manage") — todo — `features/accounts`, `categories`, `budgets`
- [ ] Widget Dashboard core mancanti: Income & expenses, Budget status — todo (spec S/M/L in Figma "Widget - Components") — `dashboard/registry/dashboard_widget_registry.dart`
- [ ] Dettaglio, modifica ed eliminazione di una transazione (il tap oggi non fa nulla) — needs design — `transaction_row.dart`
- [ ] Settings > General (autenticazione) e sezioni restanti — needs design — `settings_screen.dart`

## To do

### Dashboard
- [ ] Widget opzionali: Investments snapshot, Net worth, Insight of the moment — todo, spec in Figma "Widget - Components" — registry
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
- [ ] Push su RIP-Comm/sossoldi-design: il token del Mac non ha il permesso `workflow` — blocked
- [ ] Hosting: collegare il branch `site` a un hosting statico (Cloudflare Pages o altro) e al dominio di Sossoldi; sottodominio o sottocartella (`INSPECTOR_BASE_HREF`) — blocked (collega)
- [ ] Sito vetrina di Sossoldi con una pagina per gli sviluppatori che porta all'Inspector (link o iframe) — da decidere
- [ ] Rigenerare `lib/catalog/widget_names.g.dart` quando si aggiungono componenti o schermate (`dart run tool/generate_widget_names.dart`) — controllo ricorrente
- [ ] Conti broker: le operazioni non spostano denaro tra conti (semplificazione nota) — todo/decidere

## Open questions
- Nessuna aperta. Decise: nessun insight → non si mostra nulla, non sono tappabili; conti e categorie in ordine alfabetico (si rivede in Settings)

## Done (più recente in alto)
- [x] 2026-11-03 — Navbar: bordo `strokeMinus1` in light e dark, padding interno 4 px; blur progressivo sotto la barra di stato e la barra in alto (Home, Finance, Investments: `ProgressiveBlur`, `TopBlur`); Dashboard di default con quattro widget (S, S, L, M)
- [x] 2026-11-03 — Dashboard: nella variante S nessuno spazio tra descrizione e conto; trascinamento di un M sopra un altro M non sposta più le S sopra
- [x] 2026-11-03 — `SossoldiSelect`: la tendina resta nello schermo, si apre verso l'alto se serve, scorre dentro ed è attaccata al campo
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
