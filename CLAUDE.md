# CLAUDE.md — Trip Planner App (`iterasi1`)

Flutter mobile app for planning travel itineraries (manual or AI-assisted via GPT-4o), with SQLite persistence, photo galleries, and PDF export.

**Project facts live in [docs/SYSTEM_MAP.md](docs/SYSTEM_MAP.md).** This file describes *how Claude works on this codebase* — not what the codebase contains. Do not duplicate the map here.

---

## Core Rules

### 1. Think Before Coding
State assumptions. Present multiple interpretations. Push back if simpler exists.

### 2. Simplicity First
No features beyond asked. No abstractions for single-use. Small files by responsibility.

### 3. Surgical Changes
Don't improve adjacent code. Match existing style. Out-of-scope = user approval.
Remove only what YOUR changes made unused.

### 4. Goal-Driven Execution
Define success criteria. Loop until verified. Multi-step → plan with per-step verification.

### 5. Documentation Is Part of the Change
Header Doc on every file (Purpose, Caller, Dependencies, Main Functions, Side Effects).
Core changes → update SYSTEM_MAP.md same session.

### 6. Database & Query Standards
Minimum I/O, no N+1. Justify DB-heavy changes before finalizing.

### 7. Variable & Code Naming
No single-letter vars. No generic placeholders. Booleans as predicates.

---

## Navigation Rules

- **Session start:** read `docs/SYSTEM_MAP.md` once before any edit. It is your map of layers, flows (A–D), modules, routes, and risks (R1–R6, G1–G5). Cross-check it before assuming structure.
- **Trace by flow, not by grep:** for feature work, follow the chain `page → provider → service/database → model` exactly as documented in SYSTEM_MAP §2 (Core Logic Flow). Don't `grep`/`find` for things the map already locates.
- **Use the map index, skip `rg` for known structure:** if SYSTEM_MAP §4 (Module Map) names the file, open it directly. Reserve search for things genuinely not in the map.
- **Large files = block reads:** `itinerary_provider.dart`, `add_days.dart`, `activity_photo_page.dart`, `theme.dart` are long. Read by `offset` + `limit` around the symbol you need; never re-read end-to-end.
- **Pre-edit note:** before editing any file, state in one line *which flow* (A/B/C/D) and *which layer* (Presentation / State / Data / Model / Utility) you are touching, and which downstream files in SYSTEM_MAP §5 (State Management Map) will receive `notifyListeners()`.
- **Mind the legacy:** `suggestion_itinerary.dart` is legacy (see §4) — do not edit unless explicitly asked. Active flow uses `suggestion_page.dart`.

---

## Framework Conventions

Derived from the actual codebase. Match these — do not introduce new patterns without approval.

### State Management — Provider (default) + GetX (photos only)
- Default: `ChangeNotifier` + `Provider.of(context, listen: …)` / `context.watch` / `context.read`.
- `notifyListeners()` is mandatory after every state mutation in providers.
- GetX is **scoped to** `ActivityPhotoPage` / `PhotoController` only. Do not extend GetX to other screens. See risk **R1** in SYSTEM_MAP §10.

```dart
// BAD — adding GetX to a non-photo screen
final controller = Get.put(MyController());

// GOOD — use the existing Provider pattern
final provider = context.read<ItineraryProvider>();
provider.insertNewActivity(dayIndex, activity);
```

### Dependency Injection
- Manual via `MultiProvider` in `lib/main.dart`. No `get_it`, no `injectable`.
- Add a new provider by appending a `ChangeNotifierProvider` to the `providers` list — keep root-level only.

### Folder Structure (layer-first, flat)
`lib/{model,database,service,provider,pages,widget,navigation,resource,utilities}/`. Do not create nested feature folders; do not introduce `domain/`, `repository/`, or Clean Architecture layers — the project is intentionally flat.

### Code Generation
**None.** No `build_runner`, no `freezed`, no `json_serializable`. JSON parsing is hand-written via `fromJson()` (internal) and `fromJsonGPT()` (OpenAI response) on each model — keep both forms when adding fields.

### Data Layering
- All SQLite I/O goes through the `DatabaseService` singleton.
- All OpenAI calls go through `ItineraryService`.
- UI never touches `sqflite` or `http` directly. State logic that today lives inside `ItineraryProvider` (risk **R2**) should not be expanded — push new parsing into `ItineraryService` instead.

### Naming
- Files: `snake_case.dart`. Classes: `PascalCase`. Members: `camelCase`.
- Booleans: predicate form (`isDataChanged`, `isNewItinerary`, `isCustomLocation`).
- Existing typos (`text_field_wirdget.dart`, `custom_buttom_sheet.dart`, `recommendaation_activity_card.dart`, `longtitude`) are load-bearing — do not rename without explicit approval (Rule 3).

### Logging
Use `dart:developer` `log(...)`. Do not introduce new `print()` calls (risk **R6**).

### Theming & Sizing
- All colors come from `CustomColor` in `lib/resource/theme.dart`. No hard-coded hex in widgets.
- All sizing uses `flutter_screenutil` (`.w`, `.h`, `.sp`) against a 375×812 design size.
- Font: **Inter** via `google_fonts`. Legacy registered fonts (`Orator`, `GoodTimes`, `Haviland`, `poppins_*`) remain in `pubspec.yaml` but should not be used in new code.

---

## Commands

```bash
# Install / refresh dependencies
flutter pub get

# Run on connected device / emulator (debug)
flutter run

# Build release APK (Android — primary target)
flutter build apk --release

# Build iOS
flutter build ios --release

# Static analysis (lints from flutter_lints + analysis_options.yaml)
flutter analyze

# Tests (only widget_test.dart present today)
flutter test

# Regenerate launcher icons (note path mismatch — see SYSTEM_MAP G3)
flutter pub run flutter_launcher_icons
```

There is **no codegen step**, no `build_runner watch`, no separate lint command.

---

## Environment

- Single environment — **no flavors** (no dev/staging/prod split).
- `.env` lives at the repo root and is bundled as a Flutter asset (`pubspec.yaml` → `assets: - .env`). It **must exist** before any build, even if empty (G2 in SYSTEM_MAP), otherwise the build fails with `No file or variants found for asset: .env`.
- Loaded via `AppEnv.load()` (`lib/utilities/app_env.dart`) inside `main()` before `runApp`.

Required variables:

| Key | Used by | Source |
|---|---|---|
| `GPT_KEY` | `ItineraryService` (OpenAI GPT-4o) | OpenAI dashboard |
| `GMAPS_API_KEY` | `FormSuggestion` autocomplete, `google_maps_flutter` | Google Cloud Console (Maps + Places enabled) |

Locale is hard-coded to `id_ID` (Indonesian) with `en_US` fallback; orientation is locked to portrait in `main.dart`.

---

## Closing

These guidelines are working if:

- A change in flow A/B/C/D can be traced top-to-bottom in SYSTEM_MAP §2 within one read.
- New state lives in an existing `ChangeNotifier`; GetX has not spread beyond the photo module.
- No file imports `sqflite` or `http` outside the `database/` and `service/` folders.
- `.env`, `pubspec.yaml` assets, and `AppEnv` keys stay consistent — no broken builds from missing env or assets.
- SYSTEM_MAP.md reflects reality after the change — module table, flows, and risks updated in the same session.
- No new `print()` calls, no hard-coded colors/fonts, no Clean-Architecture folders introduced.
