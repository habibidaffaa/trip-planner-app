# Redesign Backlog — Quiet Luxury Coastal

> **Status keseluruhan**: 🔴 Belum dimulai  
> **Confidence target**: ≥97%  
> **Design source**: `trip-planner-design.html` (11 screens)

---

## Cara pakai dokumen ini

- Setiap phase punya file markdown terpisah.
- Baca file phase yang aktif **sebelum eksekusi**.
- Update checkbox `[ ]` → `[x]` segera setelah task selesai.
- Isi bagian **Post-Phase Review** setelah seluruh task di phase selesai.
- Jangan lanjut ke phase berikutnya sebelum review ditulis.

---

## Progress Overview

| Phase | File | Status | Selesai |
|---|---|---|---|
| P1 | [phase-1-theme.md](phase-1-theme.md) | ✅ Selesai | 8/8 |
| P2 | [phase-2-model.md](phase-2-model.md) | ✅ Selesai | 7/7 |
| P3 | [phase-3-widgets.md](phase-3-widgets.md) | ✅ Selesai | 13/13 |
| P4 | [phase-4-screens.md](phase-4-screens.md) | ✅ Selesai | 20/20 |
| P5 | [phase-5-cleanup.md](phase-5-cleanup.md) | 🔴 Belum | 0/8 |
| P6 | [phase-6-docs.md](phase-6-docs.md) | 🔴 Belum | 0/4 |
| P7 | [phase-7-verify.md](phase-7-verify.md) | 🔴 Belum | 0/12 |

**Total tasks**: 72

---

## Scope (dikonfirmasi)

### Masuk scope
- Visual restyle penuh 11 screens → palette ocean/coral/sand/paper + Instrument Serif/DM Sans/DM Mono
- Thumbnail opsional per itinerary (disimpan dalam JSON blob, no DB migration)
- Timeline view di Add Days
- Segmented location toggle (Peta / Ketik manual)
- Day chips row di Add Days

### Ditunda ke iterasi berikutnya
- Full-screen map picker
- Multi-select foto
- Filter status chips (Semua / Datang / Akan datang / Arsip)
- Drum-roll time picker
- Greeting personal (nama user / auth system)

### Dihapus permanen
- `BottomNavbar` — app jadi single-tab home (ItineraryList langsung)
- `SideNavbar` — tidak pernah terintegrasi
- `SuggestionItinerary` — legacy, diganti SuggestionPage
- `UserReviewPage` — tidak ada route aktif
- `ItineraryTile` — dead code (zero import)

---

## Token Mapping Reference (FREEZE)

> Jangan ubah mapping ini mid-implementation. Kalau ada konflik, tulis di section Notes phase yang relevan.

| Old field (`CustomColor.*`) | New field | Hex |
|---|---|---|
| `boardroomNavy`, `primaryColor900`, `pitchBlack` | `ocean900` | `#0A2540` |
| `brandElectric`, `primary`, `buttonColor`, `primaryColor500` | `coral500` | `#D4684A` |
| `lilacAccent`, `dateBackground`, `primaryColor100` | `sand300` | `#E8DAC2` |
| `softOffWhite`, `surface`, `backgroundColor`, `scaffoldBackground`, `greyBackgroundColor` | `paper` | `#FAF6EF` |
| `whiteColor`, `cardBackground`, `inputFillColor` | `paper` / `paperPure` | `#FAF6EF` / `#FFFFFF` |
| `lightCoolGray`, `cardBorder`, `dividerColor` | `ocean900.withOpacity(0.10)` | derived |
| `mediumGray`, `subtitleTextColor`, `hintTextColor`, `inputBorderColor`, `inputBorderGray`, `disabledColor` | `muted` | `#6B7A8F` |
| `feedbackYellow` | `warnAmber` | `#D97706` |
| `warningColor` | `danger` | `#B2533A` |
| `successColor` | `success` | `#047857` |
| `accentOrange` | `coral500` | `#D4684A` |
| `shadowColor` | `shadowSoft` | `rgba(10,37,64,0.08)` |
| `actionPanelShadowColor` | `shadowCard` | `rgba(10,37,64,0.12)` |
| `primaryColor50..900` scale | `ocean50..950` scale | per HTML |
| `transparentColor` | `Colors.transparent` | — |

### Typography mapping

| Old | New | Font | Usage |
|---|---|---|---|
| `primaryTextStyle` | alias → `bodyStyle` | DM Sans | Body, UI copy |
| `headingTextStyle` | alias → `displayStyle` | Instrument Serif | Display, headings |
| — | `monoStyle` (new) | DM Mono | Times, codes, kickers |
| `light/regular/medium/semibold/bold` | **dipertahankan** | `FontWeight.w300..w700` | Banyak file pakai |

---

## Files at Risk (yang punya CustomColor atau theme refs)

> 21 file teridentifikasi. Semua sudah diassign ke phase. Jangan ada yang lolos.

```
lib/resource/theme.dart                           → P1
lib/main.dart                                     → P1
lib/navigation/bottom_navbar.dart                 → P4 (DELETE)
lib/navigation/side_navbar.dart                   → P4 (DELETE)
lib/pages/activity_photo_controller.dart          → P5
lib/pages/activity_photo_page.dart                → P4
lib/pages/activity_trash_photo_page.dart          → P4
lib/pages/add_activities/add_activities.dart      → P4
lib/pages/add_activities/form_suggestion.dart     → P4
lib/pages/add_activities/suggestion_itinerary.dart → P4 (DELETE)
lib/pages/add_activities/suggestion_page.dart     → P4
lib/pages/add_days/add_days.dart                  → P4
lib/pages/add_days/app_bar_itinerary_title.dart   → P4
lib/pages/add_days/search_field.dart              → P4
lib/pages/datepicker/select_date.dart             → P4
lib/pages/itinerary_list.dart                     → P4
lib/pages/pdf/make_pdf.dart                       → P5
lib/pages/splash_screen.dart                      → P4
lib/pages/user_review_page.dart                   → P4 (DELETE)
lib/widget/activity_card.dart                     → P3
lib/widget/custom_buttom_sheet.dart               → P3
lib/widget/itinerary_card.dart                    → P3
lib/widget/itinerary_tile.dart                    → P3 (DELETE)
lib/widget/location_autocomplete_field.dart       → P3
lib/widget/recommendaation_activity_card.dart     → P3
lib/widget/text_dialog.dart                       → P3
lib/widget/text_field_wirdget.dart                → P3
```

> **Catatan typos load-bearing** (jangan rename):
> - `text_field_wirdget.dart`
> - `custom_buttom_sheet.dart`
> - `recommendaation_activity_card.dart`
> - Field `longtitude` di Activity model
