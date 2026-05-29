# Phase 3 — Reusable Widgets

> **Status**: 🔴 Belum dimulai  
> **Prasyarat**: Phase 2 selesai + review ditulis  
> **Prinsip**: Semua widget baru harus compile-clean sebelum lanjut ke Phase 4. Setiap widget diverifikasi via hot-reload setelah selesai.

---

## Tasks

### 3a — `lib/widget/text_field_wirdget.dart` *(filename typo dipertahankan)*

- [ ] Ganti style label → `bodyStyle.copyWith(fontSize: 11, letterSpacing: 0.22 * 11, color: CustomColor.muted)` (DM Mono kicker style) atau pakai `monoStyle`
- [ ] Ganti border radius field → 12 (dari theme, tidak hard-code)
- [ ] Color teks input → `CustomColor.ink`
- [ ] Placeholder/hint color → `CustomColor.muted`
- [ ] Signature StatelessWidget/constructor **tidak berubah**

### 3b — `lib/widget/custom_buttom_sheet.dart` *(filename typo dipertahankan)*

- [ ] Import `image_picker`, `dart:io`, `create_itinerary_result.dart`
- [ ] Tambah state var: `String? _thumbnailPath`
- [ ] Tambah method `_pickThumbnail()`:
  ```dart
  final picker = ImagePicker();
  final xfile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
  if (xfile != null) setState(() => _thumbnailPath = xfile.path);
  ```
- [ ] Tambah thumbnail picker slot di atas TextField:
  - Jika `_thumbnailPath == null`: dashed border container, ikon kamera, text "Tambah foto cover (opsional)"
  - Jika ada: `Image.file(File(_thumbnailPath!), fit: BoxFit.cover)` di AspectRatio(5/3)
  - GestureDetector onTap → `_pickThumbnail()`
- [ ] Ubah `Navigator.of(context).pop(titleController.text)` → `Navigator.of(context).pop(CreateItineraryResult(title: titleController.text, thumbnailPath: _thumbnailPath))`
- [ ] Update `showModalBottomSheet<CreateItineraryResult>` generic di **caller** (`itinerary_list.dart`) — note ini di-handle di P4b
- [ ] Restyle header: "Buat Itinerary Baru" pakai `bodyStyle.copyWith(fontWeight: semibold, fontSize: 16)`
- [ ] Restyle button "SELANJUTNYA" → text "Selanjutnya" (lowercase), pill style dari theme

### 3c — `lib/widget/itinerary_card.dart`

- [ ] Hapus seluruh widget tree lama, rewrite dari scratch
- [ ] Struktur baru:
  ```
  ClipRRect(radius: 16)
    Container(decoration: border ocean900/10, shadow card)
      Column
        _ThumbnailHeader(height: 96, thumbnailPath, title)  ← photo atau gradient
        Padding(16)
          Row: Expanded(title text) + _MoreButton(onDelete)
          mono date range + jumlah aktivitas
  ```
- [ ] `_ThumbnailHeader` widget:
  - Jika `thumbnailPath != null` dan file exists: `Image.file` + `Stack` overlay bottom kicker + hari pill
  - Jika null: `_GradientHeader(seed: itinerary.title.hashCode)`
- [ ] `_GradientHeader` — 5 preset gradient themes diindex `seed.abs() % 5`:
  ```
  0: terrace-green  (rgba 111,138,82 repeat + dark overlay)
  1: bromo-orange   (coral → ocean gradient)
  2: komodo-blue    (ocean → sand gradient)
  3: yogya-brown    (sand-700 repeat + dark overlay)
  4: jimbaran-sunset (coral-300 → ocean gradient)
  ```
- [ ] Kicker overlay: `days.isNotEmpty && days[0].activities.isNotEmpty ? days[0].activities[0].lokasi.toLowerCase() : ''` — empty string jika tidak ada
- [ ] Duration pill (kanan bawah header): `<nHari>D<nMalam>N` mono style, bg paper/95
- [ ] Title: `displayStyle.copyWith(fontSize: 20, height: 1.2)`
- [ ] Date: `monoStyle.copyWith(fontSize: 11, color: muted)` — pakai `AppHelper.formatDate()` existing
- [ ] Activity count: `monoStyle.copyWith(fontSize: 11, color: muted)` — `${totalActivities} aktivitas`
- [ ] Delete: `IconButton` di row title, icon `Icons.more_vert`, onPressed → `onDelete()` existing
- [ ] Tap seluruh card → `onTap()` existing (push AddDays)

### 3d — `lib/widget/activity_card.dart`

- [ ] Rewrite ke timeline format:
  ```
  Row
    _TimelineDot(isFirst: bool)  ← dot coral500 atau ocean300
    SizedBox(width: 12)
    Expanded
      _ActivityCardBody(activity)
  ```
- [ ] `_TimelineDot`: `Container` 12×12 rounded-full, color `coral500` jika first else `ocean300`, border 2px paper
- [ ] `_ActivityCardBody`:
  ```
  Container(bg: paper, borderRadius: 12, border ocean900/10, shadow soft)
    Padding(14)
      Row: monoStyle time chip + trailing edit/delete icons
      Text: bodyStyle medium, activityName (fontSize 15)
      Text: monoStyle, lokasi (fontSize 12, color muted)
      (optional) "Lihat di peta" pill → push map view jika isCustomLocation==false && lat/lng valid
  ```
- [ ] Time chip: `monoStyle.copyWith(fontSize: 12, color: coral700)` — `activity.startActivityTime`
- [ ] Edit icon → existing `onEdit()` callback
- [ ] Delete icon → existing `onDelete()` callback atau dialog
- [ ] Tap card → existing detail dialog (preserve logic)
- [ ] Long-press → existing quick delete
- [ ] Dashed vertical line antara dots: implementasi via `CustomPaint` di parent listview atau `DashedLinePainter` helper

### 3e — `lib/widget/recommendaation_activity_card.dart` *(filename typo dipertahankan)*

- [ ] Restyle ke visual serupa `activity_card.dart` timeline, tapi **tanpa** delete/edit icons (read-only di SuggestionPage)
- [ ] Mono time + body text activity name + muted lokasi
- [ ] Tidak ada interaksi (no tap dialog, no long-press)

### 3f — `lib/widget/location_autocomplete_field.dart`

- [ ] Tambah segmented toggle 2-tab di atas field:
  ```
  Container(bg: ocean50, border ocean200, padding: 4, radius: 999)
    Row
      _SegmentBtn("Pilih dari peta", selected: !isCustomLocation)
      _SegmentBtn("Ketik manual", selected: isCustomLocation)
  ```
- [ ] `_SegmentBtn` selected state: bg ocean900, text paper; unselected: bg transparent, text ocean700
- [ ] Toggle onTap → toggle `isCustomLocation` state yang sudah ada
- [ ] "Pilih dari peta" mode → existing TypeAhead dengan Google Places API (tidak berubah)
- [ ] "Ketik manual" mode → plain TextField, style paper border radius 12
- [ ] Preserve semua validation logic dan callbacks existing

### 3g — `lib/widget/text_dialog.dart`

- [ ] Rewrite sebagai `IterasiConfirmDialog` (destructive confirmation)
  ```dart
  class IterasiConfirmDialog extends StatelessWidget {
    final String title;
    final String message;
    final String confirmLabel;
    final VoidCallback onConfirm;
    ...
  }
  ```
- [ ] Shape: `RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))`
- [ ] Background: `paper`
- [ ] Title: `displayStyle.copyWith(fontSize: 20)`
- [ ] Message: `bodyStyle.copyWith(fontSize: 14, color: muted)`
- [ ] Buttons row: outline "Batal" + filled coral500 `confirmLabel`
- [ ] Backward compatible: existing callers pakai `TextDialog` atau `showDialog(IterasiConfirmDialog(...))` — pastikan interface match

### 3h — `lib/widget/loading_overlay.dart`

- [ ] Default variant: paper bg (untuk loading umum)
- [ ] Ocean-deep variant: background `ocean900` gradient, text paper (untuk AI loading di FormSuggestion)
- [ ] Tambah param `bool isDark = false`
- [ ] Progress dots 3 buah animating `coral300` (atau existing CircularProgressIndicator bila lebih mudah)

### 3i — New: `lib/widget/iterasi_text.dart`

- [ ] Buat helper text widgets:
  ```dart
  class IterasiDisplay extends StatelessWidget { /* displayStyle */ }
  class IterasiBody extends StatelessWidget { /* bodyStyle */ }
  class IterasiMono extends StatelessWidget { /* monoStyle */ }
  class IterasiKicker extends StatelessWidget { /* monoStyle uppercase tracking */ }
  ```
- [ ] Tiap widget terima `String text`, `TextStyle? style`, `Color? color`, `int? maxLines`
- [ ] `IterasiKicker`: mono, fontSize 10-11, letterSpacing 0.22em, uppercase, color muted by default

### 3j — New: `lib/widget/iterasi_chip.dart`

- [ ] `IterasiChip.filled({required String label, Color? bg, Color? fg})` — bg default ocean900, fg paper
- [ ] `IterasiChip.outline({required String label})` — border ocean900/25, text ocean900
- [ ] `IterasiChip.coral({required String label})` — bg coral500, fg paper
- [ ] Padding: `EdgeInsets.symmetric(horizontal: 12, vertical: 6)`
- [ ] Radius: 999 (pill)
- [ ] Font: `bodyStyle.copyWith(fontSize: 12, fontWeight: medium)`

### 3k — DELETE `lib/widget/itinerary_tile.dart`

- [ ] Verifikasi tidak ada yang import `itinerary_tile.dart` (grep confirm: 0 imports)
- [ ] Hapus file
- [ ] Hapus export di `lib/core.dart` jika ada

### 3l — Restyle `lib/widget/maps_text_field.dart`

- [ ] Ganti warna border, fill, text → token baru (ocean900, paper, muted)
- [ ] Radius → 12

---

## Verifikasi

- [ ] `flutter analyze` → 0 error baru setelah semua widget selesai
- [ ] `ItineraryCard` render: gradient placeholder muncul (5 warna berbeda per title hash)
- [ ] `ItineraryCard` render: Image.file muncul jika thumbnailPath valid
- [ ] `ActivityCard` timeline: dot + line visible
- [ ] `LocationAutocompleteField`: toggle Peta/Ketik manual berfungsi
- [ ] `CustomBottomSheet`: thumbnail picker slot muncul, pilih gambar → preview muncul
- [ ] `IterasiConfirmDialog`: muncul dengan style baru, tombol konfirm berwarna coral

---

## Post-Phase Review

> Isi setelah semua task di atas selesai. Wajib sebelum lanjut ke Phase 4.

**Tanggal selesai**: _

**Yang berhasil**:
- 

**Masalah ditemukan**:
- 

**Keputusan yang diambil**:
- 

**flutter analyze output**:
```
(paste output di sini)
```

**Siap lanjut ke Phase 4**: ☐ Ya / ☐ Tidak (alasan: _)
