---
name: sync-map
description: Update SYSTEM_MAP.md after code changes so it stays the source of truth. Use after finishing a feature/fix/refactor, or when the user says "sync map". Only updates sections actually affected.
---

# /sync-map — Targeted SYSTEM_MAP.md update

## Purpose
Keep `docs/SYSTEM_MAP.md` aligned with the real code after a change lands. This skill makes **surgical** edits to the sections the change touched — it never regenerates the map from scratch. The map must already exist; if `docs/SYSTEM_MAP.md` is missing, stop and tell the user (this skill does not bootstrap a new map).

## When to run
Run after a change that alters the project's *structure or contract* — the things the map documents. For this Flutter app (`lib/` source dir, entrypoint `lib/main.dart`):

- A file is created or deleted under `lib/` (page, widget, provider, service, model, utility).
- A public class, or a public method/getter listed in the **Module Map** tables, is added, renamed, or removed.
- A core flow changes — the `page → provider → service/database → model` chain of Flow A (manual itinerary), B (AI recommendation), C (photo management), or D (PDF export).
- The SQLite schema, `DatabaseService` CRUD surface, or model serialisation (`fromJson` / `fromJsonGPT` fields) changes.
- A new external integration is added (OpenAI, Google Maps/Places, a new platform channel, or a native plugin in `pubspec.yaml`).
- A new screen/route is wired (named route in `MaterialApp.routes` or a `Navigator.push` edge).
- A new provider is registered in the root `MultiProvider`, or GetX state changes in the photo module.
- A new feature module appears, or an architectural risk (R1–R6 / G1–G5) is introduced or resolved.

If the change is none of the above — internal refactor with no public-name change, styling tweak, copy edit, comment, test-only edit — **no update needed.** Say so and stop.

## Workflow

### Step 1 — Gather the diff
Run `git status` and `git diff --stat` (and `git diff` on the changed files when needed). Build the concrete list of files added / deleted / modified. Only sections tied to those files are in scope.

### Step 2 — Classify changes to map sections
Match each change to the exact SYSTEM_MAP.md heading it affects. Heading names below are copy-pasted from the current map — edit under these, do not invent new ones.

| Change type | SYSTEM_MAP.md section (exact heading) |
|---|---|
| New/changed dependency, Dart/Flutter SDK, or state-mgmt approach | `## 1. Project Summary` → **Tech Stack** |
| New top-level `lib/` folder or shift in layering | `## 1. Project Summary` → **Pola Arsitektur** |
| A documented flow chain (page → provider → service/db → model) changes | `## 2. Core Logic Flow` → relevant **Flow A/B/C/D** |
| File created or deleted under `lib/` or `assets/` | `## 3. Clean Tree` |
| Public page/widget/navbar class added/renamed/removed | `## 4. Module Map` → **Presentation Layer** |
| Provider or GetX controller public method added/renamed/removed | `## 4. Module Map` → **State Management Layer** |
| `DatabaseService` / `ItineraryService` public method changed | `## 4. Module Map` → **Data Layer** |
| Model class, field, or `fromJson`/`fromJsonGPT` surface changed | `## 4. Module Map` → **Domain / Model Layer** |
| Theme token, env helper, or formatter utility changed | `## 4. Module Map` → **Core / Utilities** |
| New provider registered, or notify/consume relationship changed | `## 5. State Management Map` → **Pattern** / **State Classes** / **Dependency Graph** |
| Named route added/changed (`MaterialApp.routes`) | `## 6. Navigation & Routing` → **Named Routes (di `MaterialApp.routes`)** |
| New `Navigator.push` edge or route condition | `## 6. Navigation & Routing` → **Push Routes (MaterialPageRoute — tidak bernama)** |
| New/changed `.env` key | `## 7. Data & Config` → **Environment Variables (`.env`)** |
| SQLite DB name / table / schema / strategy changed | `## 7. Data & Config` → **Database Lokal — SQLite** |
| Model serialisation shape changed | `## 7. Data & Config` → **Model Serialisasi** |
| Provider added/removed in `MultiProvider` | `## 7. Data & Config` → **DI Setup** |
| Asset data file (`data.json`, `response.json`, etc.) added/changed | `## 7. Data & Config` → **Assets Data** |
| OpenAI, Maps/Places, platform channel, or native plugin changed | `## 8. External Integrations` |
| Flavor, build config, launcher icon, or build caveat changed | `## 9. Build & Flavors` |
| Architectural risk introduced/resolved or asset risk changed | `## 10. Risks / Blind Spots` → **Risiko Arsitektur** (R#) / **Risks Generated Code / Assets** (G#) |

### Step 3 — Verify before writing
Open the actual changed files and confirm public names, file paths, method signatures, and flow edges from the code — **not from memory or the diff summary alone**. A wrong path or stale method name in the map is worse than no entry.

### Step 4 — Apply minimal edits
Edit only the rows/lines/blocks identified in Step 2. Match the existing language (the map body is in **Indonesian** — keep it Indonesian), heading levels, table column layout, and bullet/code-block style. Add, rename, or remove a single table row rather than rewriting a table. Leave every untouched section byte-for-byte unchanged. Do not touch the footer line unless a change makes it wrong.

### Step 5 — Report
State plainly:
- **Updated sections:** [list exact headings + what changed]
- **Skipped sections:** [list sections that were in scope but needed no change, and why]

## Anti-patterns (never do)
- Rewriting the whole map, or "tidying up" sections the change didn't touch.
- Adding sections, headings, or columns that aren't in the existing template.
- Replacing a table or bullet list with prose where bullets/tables already work.
- Guessing a public class/method name or file path without opening the file.
- Re-touching unchanged sections (don't reflow, reword, or re-order them).
- Leaving a stale entry behind for deleted code (remove the row when the code is gone).
- Pasting code snippets into the map — it's a compass, not a mirror of the source.
- Switching the map's language to English (body stays Indonesian).

## Relationship
- **SYSTEM_MAP.md** = dynamic project facts (layers, flows, modules, routes, risks) — this is what `/sync-map` maintains.
- **CLAUDE.md** = stable behavioral rules for how to work on this codebase — not touched by this skill.
This skill only ever edits `docs/SYSTEM_MAP.md`.
