# Phase 4 — Screens

> **Status**: 🔴 Belum dimulai  
> **Prasyarat**: Phase 3 selesai + review ditulis  
> **Prinsip**: Setiap screen selesai → hot reload → verifikasi visual → baru ke screen berikutnya. `add_days.dart` adalah yang paling berisiko — hanya sentuh `build()` tree.

---

## Deletions (lakukan pertama sebelum restyle)

- [ ] **DELETE** `lib/navigation/bottom_navbar.dart`
- [ ] **DELETE** `lib/navigation/side_navbar.dart`
- [ ] **DELETE** `lib/pages/add_activities/suggestion_itinerary.dart` (legacy R5)
- [ ] **DELETE** `lib/pages/user_review_page.dart`
- [ ] Verifikasi `lib/main.dart` tidak reference `BottomNavbar` di routes — kalau ada, hapus import & route entry
- [ ] Verifikasi `lib/core.dart` sudah tidak export files yang dihapus (cross-check dengan P5a)

---

## Tasks per Screen

### 4a — `lib/pages/splash_screen.dart`

- [ ] Background: `Scaffold(backgroundColor: CustomColor.ocean900)`
- [ ] Kompas SVG di tengah atas (CustomPaint atau Container dengan SVG sederhana):
  - Lingkaran luar tipis sand300/55%
  - Jarum utara coral500
  - Jarum timur/barat ocean300/75%
  - Dot tengah paper
- [ ] Wordmark "iterasi" — `displayStyle.copyWith(fontSize: 88, color: paper, height: 0.85)`
- [ ] Titik italic coral: `TextSpan` italic coral400 di akhir wordmark
- [ ] Tagline: `displayStyle.copyWith(fontStyle: FontStyle.italic, fontSize: 20, color: paper.withOpacity(0.85))`  
  → Text: "Perjalanan, dirancang dengan tangan."
- [ ] Kicker atas (opsional): `monoStyle.copyWith(fontSize: 10, letterSpacing: 0.24*10, color: coral300)` → "est. 2026 · jakarta"
- [ ] Footer bawah: `monoStyle.copyWith(fontSize: 10, color: paper.withOpacity(0.4))` → "v 2.0 · raja ampat build"
- [ ] Garis pantai dekoratif (opsional SVG/CustomPaint) di bagian bawah
- [ ] **Preserve**: `mounted` check sebelum navigate, 1.5s delay, `pushReplacementNamed(ItineraryList.route)`

### 4b — `lib/pages/itinerary_list.dart`

- [ ] Hapus `BottomNavbar` wrapper — Scaffold langsung di sini
- [ ] Hapus AppBar → ganti inline header di body
- [ ] Import `CreateItineraryResult` (dari P2c)
- [ ] Update `showModalBottomSheet<CreateItineraryResult>` generic (dari `<String>`)
- [ ] Update handler result: `if (result is CreateItineraryResult)` → pakai `result.title` dan `result.thumbnailPath`
- [ ] Header inline:
  ```
  Padding(px: 24, pt: statusBarHeight + 8, pb: 12)
    IterasiKicker("selamat pagi", color: coral700)
    Row
      Expanded
        IterasiDisplay("Trip ", children: [TextSpan("kamu", italic: true)])
      SizedBox(11, 44)  ← spacer (no profile button)
    IterasiDisplay(italic, fontSize: 16, color: ocean700): "X perjalanan tersimpan."
      → X = Future<int> dari dbProvider length (atau build dari FutureBuilder)
  ```
- [ ] Search field: pill style (border radius 999), paper bg, muted hint "Cari Bromo, Bali, Yogya…", search icon ocean600
- [ ] ListView: `ItineraryCard` × n, separator 12px, padding horizontal 16
- [ ] Empty state `_EmptyState` widget:
  - SVG sederhana (paper-plane + ticket) via CustomPaint atau Container dengan dekorasi
  - `IterasiDisplay("Mulai dari mana?", fontSize: 28)`
  - `IterasiBody("Pilih tanggal dulu...", color: ocean700, maxLines: 3)`
  - `ElevatedButton("Buat itinerary pertama")` → openBottomSheet
  - `TextButton("Lihat contoh perjalanan ⌐")` (opsional, bisa stub)
- [ ] FAB pill: `FloatingActionButton.extended(icon: Icons.add, label: Text("Trip baru"))` — atau manual Positioned pill button di Stack
- [ ] Delete confirmation → `IterasiConfirmDialog` (bukan AlertDialog lama)
- [ ] **Preserve**: `DatabaseProvider`, `ItineraryProvider` usage, `getItineraryTitle()`, filter search logic

### 4c — `lib/pages/datepicker/select_date.dart`

- [ ] Header: back button (outline circle) + `monoStyle` "step 1 of 3" kicker center + spacer right
- [ ] Hero text: `IterasiKicker("tanggal perjalanan", color: coral700)` + `IterasiDisplay("Kapan kamu ", italic-span "berangkat", fontSize: 34)`
- [ ] Subtitle: `IterasiBody("Pilih hari pertama dan hari pulang.", color: ocean700)`
- [ ] Calendar container: `Container(bg: paper, border: ocean900/10, borderRadius: 16, shadow: soft)`
- [ ] `SfDateRangePicker` theming via direct props:
  ```dart
  selectionColor: CustomColor.ocean900,
  startRangeSelectionColor: CustomColor.ocean900,
  endRangeSelectionColor: CustomColor.ocean900,
  rangeSelectionColor: CustomColor.sand300.withOpacity(0.4),
  todayHighlightColor: CustomColor.coral500,
  headerStyle: DateRangePickerHeaderStyle(textStyle: displayStyle.copyWith(fontSize: 20)),
  monthCellStyle: DateRangePickerMonthCellStyle(
    textStyle: bodyStyle.copyWith(fontSize: 13),
    todayTextStyle: bodyStyle.copyWith(color: coral500),
  ),
  ```
- [ ] Range readout bawah kalender: kicker "berangkat" / "pulang" + `displayStyle` date + arrow coral → `monoStyle` "X hari · Y malam"
- [ ] Path picker row:
  - `Susun sendiri` → outline button (border ocean900/25)
  - `Minta AI menyusun` → filled ocean900 + subtle coral glow di background
  - Warning chip di bawah: amber icon + `bodyStyle` "Pilih AI? Trip-mu akan dipotong ke 3 hari pertama (X–Y Mar)." — muncul hanya jika range > 3 hari
- [ ] Bottom CTA pill: "Lanjut · susun sendiri" → existing `onSimpanDate()` logic preserved
- [ ] **Preserve**: `onSimpanDate()`, `isNewItinerary` param, date range validation, push ke FormSuggestion atau AddDays

### 4d — `lib/pages/add_activities/form_suggestion.dart`

- [ ] AppBar → ganti ke custom header: back button + "step 2 of 3" kicker center + spacer
- [ ] Header copy: `IterasiKicker` date range coral + `IterasiDisplay("Ceritakan ", italic-span "tripmu.")` + `IterasiBody("Iterasi akan menyusun dua rancangan untuk kamu pilih.")`
- [ ] Field labels: `IterasiKicker(uppercase mono muted)`
- [ ] Departure field: paper bg, border ocean900/15, radius 12, location pin icon coral600
- [ ] Destination field: same style
- [ ] **NO vibe chips** (ditunda)
- [ ] CTA pill: "Generate dua itinerary" + AI/star icon → existing submit handler
- [ ] Loading state: ganti ke `LoadingOverlay` dengan `isDark: true` (ocean-deep bg)
  - Copy loading: `IterasiDisplay("Iterasi sedang menggambar dua versi tripmu.", color: paper)`
  - Subtitle italic: "Biasanya 15–25 detik."
  - Animating compass SVG (opsional)
  - Progress steps list (opsional, bisa skip jika kompleks)
- [ ] **Preserve**: `generateItineraryByAi()` call, `isFormValid`, Places autocomplete TypeAheadField

### 4e — `lib/pages/add_activities/suggestion_page.dart`

- [ ] Header: back button + "2 rancangan · geser →" kicker + spacer
- [ ] Title: `IterasiDisplay("Bali, dua versi.")` + kicker coral "v 1 / 2"
- [ ] **Keep TabBar** (bukan horizontal carousel):
  - `TabBar` indicator: underline coral500 height 2
  - Labels: `bodyStyle.copyWith(fontSize: 12)`
  - BG: paper
- [ ] Per tab content:
  - Gradient header (pakai salah satu `_GradientHeader` preset, misal photo-terrace untuk tab 1)
  - Kicker di header "v 1 · slow" + pill "3 hari · X stops"
  - Subtitle italic displayStyle di atas gambar
  - Day list: `ExpansionTile` styled (kicker day label coral, displayStyle day title, collapse/expand icon muted)
  - Activity rows: `recommendaation_activity_card` (dari P3e)
- [ ] "Pilih versi ini" CTA: coral500 pill di bottom setiap tab
- [ ] **Preserve**: `_buildItineraryContent(index)`, `addDay()` logic, navigation ke AddDays

### 4f — `lib/pages/add_days/add_days.dart` *(MAJOR — HATI-HATI)*

> **WAJIB BACA**: Method yang TIDAK BOLEH DISENTUH (hanya UI-nya boleh restyle):
> `_submitItineraryTitle`, `_commitPendingTitleIfAny`, `_safeDeleteFile`, `_extractAutoPhotoHash`,
> `_finalizeRemovedPhotos`, `requestGalleryPermission`, `saveAndExit`, `handleBackBehaviour`,
> `persistCurrentItinerary`, photo_manager scan loops, state vars `_pendingTitle`/`isEditing`/`selectedDayIndex`

- [ ] Hapus `AppBar` → ganti ke custom header widget di dalam `Column`
  ```
  SafeArea
    Padding(horizontal: 16, vertical: 8)
      Row
        _CircleBackButton()    ← outline circle, navigate pop
        Expanded(Column center)
          IterasiMono(dateRange, fontSize: 11, color: muted)
          IterasiDisplay(title, fontSize: 17) ← onTap → toggle isEditing
        _SavePill()            ← "Simpan" pill ocean900, onTap: saveAndExit (jika !isEditing) atau commitTitle
  ```
- [ ] Edit title mode (isEditing==true): ganti title area ke `SearchField` restyled (paper bg, ocean900 text, monoStyle separator)
- [ ] Day chips row (replace ExpansionTile tabs):
  ```
  SingleChildScrollView(scrollDirection: horizontal)
    Row: [_DayChip("D1 Kam"), _DayChip("D2 Jum"), ...]
  ```
  - Active chip: bg ocean900, text paper, mono prefix "D1" + regular day abbr
  - Inactive chip: outline border ocean900/15, text ocean900/ocean700
  - onTap → `setState(() => selectedDayIndex = i)`
- [ ] Big day header section:
  ```
  Padding(horizontal: 16, vertical: 12)
    IterasiKicker("hari N · <weekday> <date>", color: coral700)
    IterasiDisplay("<title or 'Hari N'>", fontSize: 28, italic)
    IterasiMono("X aktivitas · HH.MM — HH.MM", color: muted)
  ```
- [ ] Activity timeline ListView:
  ```
  ListView.builder(
    itemCount: days[selectedDayIndex].activities.length,
    builder: (ctx, i) => ActivityCard(activity: activities[i], isFirst: i==0, ...)
  )
  ```
  - Dashed vertical line: parent `Stack` atau `CustomPainter` di `ListView` background
- [ ] Edit thumbnail entry: kecil, di header atau title area:
  ```
  IconButton(icon: camera_icon, onPressed: _editThumbnail)
  ```
  - `_editThumbnail()`: image_picker → `persistThumbnail()` → `itineraryProvider.setThumbnail(path)`
- [ ] Bottom action bar (replace FAB):
  ```
  Container(bg: paper/95, borderTop: ocean900/10, px: 16, py: 12)
    Row
      Expanded("Tambah aktivitas", filled ocean900, icon: add)
      SizedBox(8)
      Container("Bagikan PDF", outlined, icon: share)
  ```
  - "Tambah aktivitas" → existing push AddActivities
  - "Bagikan PDF" → existing push PdfPreviewPage
- [ ] **Remove** `BottomNavbar` dari scope file ini (sudah dihapus di deletion step)
- [ ] **Preserve** semua provider reads/writes, WillPopScope, LoaderOverlay

### 4g — `lib/pages/add_days/app_bar_itinerary_title.dart` & `search_field.dart`

- [ ] `app_bar_itinerary_title.dart`: simplify ke `IterasiDisplay(title: title, fontSize: 17)` atau inline ke 4f header
- [ ] `search_field.dart`: restyle ke `TextField` dengan paper bg, ocean900 text, monoStyle. Preserve `onSubmit` / `onValueChange` callbacks & `initialText` param

### 4h — `lib/pages/add_activities/add_activities.dart`

- [ ] Header: text "Batal" (monoBold, muted, left) + center section (kicker + display "Aktivitas baru") + pill "Simpan" (ocean900, right)
- [ ] Time picker section: **keep existing 2-button picker**, restyle:
  - Label kicker "jam mulai · format 24h"
  - Container paper bg, border ocean900/12, radius 16
  - Mono time text coral700 (existing value)
  - Dot separator coral600
  - Quick-tap chips di bawah: "06.00", "08.00", "12.00", "19.30" — outline pills
- [ ] Nama field: `TextFieldWidget` (P3a restyled) + char counter mono kanan "28/60"
- [ ] Lokasi: `LocationAutocompleteField` (P3f dengan segmented toggle)
- [ ] Deskripsi field: paper bg, border ocean900/15, radius 12, bodyStyle
- [ ] Catatan field: sand100 bg, border sand300, clock icon sand700, bodyStyle text — label "catatan (opsional)"
- [ ] **Preserve**: `_submitActivity()`, `_buildTimePicker()`, validasi, navigator pop

### 4i — `lib/pages/activity_photo_page.dart`

- [ ] Custom header (bukan AppBar): back button outline + kicker "jurnal aktivitas" center + `IconButton(share-arrow)`
- [ ] Hero section: `IterasiKicker("HH.MM · hari N", coral700)` + `IterasiDisplay(activityName, italic)` + `IterasiMono("lokasi · X foto")`
- [ ] Grid 3-col: `GridView.count(crossAxisCount: 3, mainAxisSpacing: 6, crossAxisSpacing: 6)` — rounded corners 8
- [ ] Thumbnail video badge: kecil overlay icon play di tengah + "0:14" mono kanan bawah
- [ ] Catatan section: `Container(bg: paper, border: ocean900/10, radius: 12)` + kicker "catatan kamu" coral + `IterasiDisplay(italic, fontSize: 18)`
- [ ] Bottom action bar:
  - Circle button (camera icon, outline, 48×48)
  - `Expanded` pill "Tambah dari galeri" ocean900
  - Circle button coral500 trash icon
- [ ] **NO multi-select** mode (ditunda)
- [ ] **Preserve**: semua PhotoController (GetX) logic, long-press delete, `_saveCameraImage`, `_saveGalleryImage`, media_scanner channel

### 4j — `lib/pages/activity_trash_photo_page.dart`

- [ ] Restyle AppBar → custom header (back + title "Foto terhapus" + restore action)
- [ ] Grid restyle (sama seperti 4i)
- [ ] **Preserve**: restore logic

### 4k — `lib/pages/pdf/preview_pdf_page.dart`

- [ ] Restyle AppBar saja:
  - Back button outline circle
  - Kicker "pratinjau pdf"
  - Right: kicker "A4" + kicker halaman count
- [ ] Bottom bar: 2 buttons — "Cetak" (outline) + "Bagikan" (filled ocean900, share icon)
- [ ] **Preserve**: `PdfPreview` widget, printing integration, semua handler

---

## Verifikasi per Screen (12 scenario)

- [ ] 1. Splash muncul 1.5s → redirect ke list
- [ ] 2. List kosong → empty state SVG + CTA muncul
- [ ] 3. Bottom sheet → thumbnail picker slot → pilih gambar → preview → input title → "Selanjutnya" → push SelectDate
- [ ] 4. SelectDate → pilih range → "Susun sendiri" → push AddDays (kosong)
- [ ] 5. AddDays → header editable title (tap) → day chips selectable → "Tambah aktivitas" → push AddActivities
- [ ] 6. AddActivities → isi semua field → segmented toggle peta/ketik works → Simpan → kembali ke AddDays → activity muncul di timeline
- [ ] 7. AddDays Simpan → pop ke list → card muncul (thumbnail / gradient fallback)
- [ ] 8. Tap card → push AddDays edit mode → existing data loaded
- [ ] 9. Delete card → IterasiConfirmDialog → confirm → card dihapus
- [ ] 10. AI flow: SelectDate 3 hari → "Minta AI" → FormSuggestion → loading → SuggestionPage TabBar → "Pilih versi ini" → AddDays dengan AI activities
- [ ] 11. Photo flow: AddDays activity card → photo icon → permission OK → PhotoPage grid muncul → tambah/hapus foto works
- [ ] 12. PDF flow: AddDays "Bagikan PDF" → PdfPreviewPage → OS share sheet muncul

---

## Post-Phase Review

> Isi setelah semua task di atas selesai. Wajib sebelum lanjut ke Phase 5.

**Tanggal selesai**: _

**Yang berhasil**:
- 

**Masalah ditemukan**:
- 

**Screen yang butuh polish**:
- 

**flutter analyze output setelah Phase 4**:
```
(paste output di sini)
```

**Semua 12 scenario verified**: ☐ Ya / ☐ Tidak (yang gagal: _)

**Siap lanjut ke Phase 5**: ☐ Ya / ☐ Tidak (alasan: _)
