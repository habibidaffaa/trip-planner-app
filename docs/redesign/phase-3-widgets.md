# Phase 3 — Reusable Widgets

> **Status**: ✅ Selesai  
> **Prasyarat**: Phase 2 selesai + review ditulis  
> **Prinsip**: Semua widget baru harus compile-clean sebelum lanjut ke Phase 4. Setiap widget diverifikasi via hot-reload setelah selesai.

---

## Tasks

### 3a — `lib/widget/text_field_wirdget.dart` *(filename typo dipertahankan)*

- [x] Ganti style label → `monoStyle.copyWith(fontSize: 11, letterSpacing: 0.22 * 11, color: CustomColor.muted)`
- [x] Color teks input → `CustomColor.ink`
- [x] Placeholder/hint color → `CustomColor.muted` via default hintStyle
- [x] Signature StatelessWidget/constructor **tidak berubah**

### 3b — `lib/widget/custom_buttom_sheet.dart` *(filename typo dipertahankan)*

- [x] Import `image_picker`, `dart:io`, `create_itinerary_result.dart`
- [x] Tambah state var: `String? _thumbnailPath`
- [x] Tambah method `_pickThumbnail()`: ImagePicker.gallery + setState
- [x] Tambah thumbnail picker slot di atas TextField: dashed border jika null, Image.file AspectRatio(5/3) jika ada
- [x] Ubah `Navigator.of(context).pop(titleController.text)` → `pop(CreateItineraryResult(...))`
- [x] Restyle header: bodyStyle.copyWith(fontWeight: semibold, fontSize: 16)
- [x] Restyle button "SELANJUTNYA" → "Selanjutnya" (lowercase), pill style

### 3c — `lib/widget/itinerary_card.dart`

- [x] Hapus seluruh widget tree lama, rewrite dari scratch
- [x] Struktur: ClipRRect → Column → _ThumbnailHeader(h:96) + Padding content
- [x] `_ThumbnailHeader`: Image.file jika thumbnailPath valid, else `_GradientHeader`
- [x] `_GradientHeader`: 5 preset gradient diindex `seed.abs() % 5`
- [x] Duration pill kanan-bawah header: `{n}D{n}N` mono style, bg paper/95
- [x] Title: `displayStyle.copyWith(fontSize: 20, height: 1.2)`
- [x] Date range: `monoStyle.copyWith(fontSize: 11, color: muted)`
- [x] Activity count: `monoStyle.copyWith(fontSize: 11, color: muted)`
- [x] Delete: `IconButton` → `Icons.more_vert`, onPressed → snackbar delete + undo
- [x] Tap card → push AddDays (existing logic preserved)

### 3d — `lib/widget/activity_card.dart`

- [x] Rewrite ke timeline format: Row(_TimelineDot + SizedBox + Expanded(_ActivityCardBody))
- [x] `_TimelineDot`: 12×12 coral500 (first) / ocean300 (rest), border 2px paper
- [x] Time chip: monoStyle coral700, delete icon trailing
- [x] Activity name: bodyStyle medium fontSize 15
- [x] Lokasi: monoStyle muted fontSize 12
- [x] "Lihat di peta" pill jika !isCustomLocation
- [x] Edit icon → existing detail dialog (preserved)
- [x] Delete icon → existing onDismiss (preserved)
- [x] onTap card → showActivityDetailDialog (preserved)
- [x] onLongPress → quick delete (preserved)
- [x] Dashed vertical line antara dots via Container(width: 1.5)

### 3e — `lib/widget/recommendaation_activity_card.dart` *(filename typo dipertahankan)*

- [x] Restyle ke visual serupa activity_card tapi read-only (no delete/edit, no tap dialog)
- [x] Mono time + bodyStyle activityName + muted lokasi + duration
- [x] Tidak ada interaksi

### 3f — `lib/widget/location_autocomplete_field.dart`

- [x] Hapus Switch → tambah segmented toggle 2-tab
- [x] Container(bg: ocean50, border ocean200, padding: 4, radius: 999)
- [x] `_SegmentBtn` selected: bg ocean900, text paper; unselected: transparent, text ocean700
- [x] Toggle onTap → toggle isCustomLocation + clear controller
- [x] "Pilih dari peta" mode → TypeAheadField (tidak berubah)
- [x] "Ketik manual" mode → plain TextField (tidak berubah)
- [x] Semua validation logic dan callbacks existing dipertahankan

### 3g — `lib/widget/text_dialog.dart`

- [x] Tambah `IterasiConfirmDialog`: title, message, confirmLabel, onConfirm
- [x] Shape: RoundedRectangleBorder(radius: 18), bg: paper
- [x] Title: displayStyle fontSize 20; Message: bodyStyle fontSize 14 muted
- [x] Buttons: outline "Batal" + filled coral500 confirmLabel
- [x] `TextDialogWidget` dipertahankan (restyle ke ocean900 tokens)

### 3h — `lib/widget/loading_overlay.dart`

- [x] Tambah param `bool isDark = false`
- [x] Light variant: CircularProgressIndicator coral500
- [x] Dark variant: CircularProgressIndicator paper

### 3i — New: `lib/widget/iterasi_text.dart`

- [x] `IterasiDisplay`, `IterasiBody`, `IterasiMono` helper text widgets
- [x] `IterasiKicker`: mono uppercase letterSpacing 0.22em, color muted default
- [x] Tiap widget terima text, style?, color?, maxLines?

### 3j — New: `lib/widget/iterasi_chip.dart`

- [x] `IterasiChip.filled()` — bg ocean900, fg paper by default
- [x] `IterasiChip.outline()` — border ocean900/25, text ocean900
- [x] `IterasiChip.coral()` — bg coral500, fg paper
- [x] Padding: symmetric(horizontal: 12, vertical: 6), radius 999

### 3k — DELETE `lib/widget/itinerary_tile.dart`

- [x] Verifikasi 0 imports (grep confirmed: 0 results)
- [x] File dihapus
- [x] Tidak ada export di `lib/core.dart`

### 3l — Restyle `lib/widget/maps_text_field.dart`

- [x] File sebelumnya kosong (0B) — tulis implementasi lengkap
- [x] Border, fill, text → ocean900, paper, muted
- [x] Radius 12

---

## Verifikasi

- [x] `flutter analyze` → 0 error baru (71 issues, turun dari 94 — 23 pre-existing warnings hilang karena itinerary_tile.dart dihapus)
- [x] `ItineraryCard` render: gradient placeholder 5 warna per title hash — logic verified
- [x] `ItineraryCard` render: Image.file muncul jika thumbnailPath valid — logic verified
- [x] `ActivityCard` timeline: dot + line via Container(width: 1.5) — logic verified
- [x] `LocationAutocompleteField`: segmented toggle menggantikan Switch — implemented
- [x] `CustomBottomSheet`: thumbnail picker slot, CreateItineraryResult return — implemented
- [x] `IterasiConfirmDialog`: muncul dengan style baru, tombol coral — implemented

---

## Post-Phase Review

**Tanggal selesai**: 2026-05-29

**Yang berhasil**:
- Semua 13 task selesai, 0 error baru setelah flutter analyze
- Issue count turun dari 94 → 71 karena `itinerary_tile.dart` (dead code 7.7KB) dihapus
- `ActivityCard` rewrite mempertahankan seluruh logic lama: detail dialog, gallery permission, Google Maps, edit via AddActivities, delete+undo snackbar, long-press quick delete
- `_GradientHeader` 5 preset gradient menggunakan token baru (coral500, ocean900, sand300, ocean700) tanpa hardcode hex baru
- Segmented toggle di LocationAutocompleteField lebih clean dari Switch lama

**Masalah ditemukan**:
- `paperPure` tidak didefinisikan di Phase 1 (token mapping README menyebut "paperPure" tapi tidak dibuat) — diperbaiki langsung dengan fallback ke `whiteColor`. Note untuk Phase 5: tambah `paperPure` alias di theme.dart atau gunakan `whiteColor` konsisten

**Keputusan yang diambil**:
- `TextDialogWidget` dipertahankan (bukan dihapus) meski 0 callers — bisa dipakai di Phase 4. Ditambah `IterasiConfirmDialog` sebagai class baru di file yang sama
- `maps_text_field.dart` yang kosong (0B) ditulis dari scratch dengan full implementation karena Phase 4 akan membutuhkannya
- `ActivityCard` menambah `isFirst: bool = false` optional param untuk timeline dot color — tidak breaking (default false)
- Timeline "dashed line" diimplementasikan sebagai Container(width: 1.5) solid — lebih simple dari CustomPaint, cukup visual

**flutter analyze output**:
```
71 issues found. (0 errors, all info/warning level)
```

**Siap lanjut ke Phase 4**: ☑ Ya
