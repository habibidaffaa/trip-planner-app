# Phase 5 — Cleanup, Barrel & Manifest

> **Status**: 🔴 Belum dimulai  
> **Prasyarat**: Phase 4 selesai + review ditulis + semua 12 scenario verified  
> **Prinsip**: Bersihkan sisa-sisa. Tidak ada fitur baru di phase ini — hanya removal, token rename sisa, dan config fixes.

---

## Tasks

### 5a — `lib/core.dart` barrel cleanup

- [ ] Hapus export `lib/navigation/bottom_navbar.dart`
- [ ] Hapus export `lib/navigation/side_navbar.dart`
- [ ] Hapus export `lib/pages/add_activities/suggestion_itinerary.dart`
- [ ] Hapus export `lib/pages/user_review_page.dart`
- [ ] Hapus export `lib/widget/itinerary_tile.dart`
- [ ] Jalankan `flutter analyze` → verifikasi tidak ada "Target of URI doesn't exist" error
- [ ] Verifikasi tidak ada file lain yang import `core.dart` (grep confirm — expected: 0 consumers)

### 5b — `lib/pages/pdf/make_pdf.dart` — token rename

- [ ] Grep semua `CustomColor.<old>` di file ini
- [ ] Replace per token mapping table (README.md):
  - `boardroomNavy` / `pitchBlack` → `ocean900`
  - `brandElectric` → `coral500`
  - `softOffWhite` → `paper`
  - `whiteColor` → `paper`
  - `subtitleTextColor` / `mediumGray` → `muted`
  - dsb per table
- [ ] Verifikasi PDF masih generate tanpa crash (test via "Bagikan PDF" di AddDays)

### 5c — `lib/pages/activity_photo_controller.dart` — token rename

- [ ] Grep semua `CustomColor.<old>` / `primaryTextStyle` / `headingTextStyle` di file ini
- [ ] Replace per token mapping table
- [ ] Verifikasi photo page masih berfungsi (GetX controller tidak crash)

### 5d — `lib/resource/theme.dart` — opsional: hapus deprecated aliases

- [ ] Cek apakah ada file yang masih pakai `CustomColor.boardroomNavy` directly (bukan via alias):
  ```bash
  grep -rn "\.boardroomNavy\|\.brandElectric\|\.softOffWhite\|\.pitchBlack\|\.lilacAccent\|\.lightCoolGray\|\.mediumGray\|primaryColor[0-9]" lib/ --include="*.dart"
  ```
- [ ] Jika grep kosong → boleh hapus deprecated aliases
- [ ] Jika masih ada → biarkan aliases tetap ada (safer), tandai TODO di file tersebut
- [ ] Pertimbangkan biarkan `primaryTextStyle` / `headingTextStyle` sebagai permanent aliases ke `bodyStyle` / `displayStyle` (karena banyak file pakai — tidak worth breaking)

### 5e — `android/app/src/main/AndroidManifest.xml`

- [ ] Tambah permission untuk Android 13+ image picker:
  ```xml
  <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
  ```
- [ ] Posisikan di antara `uses-permission` entries yang ada (sebelum `<application>` tag)
- [ ] Verifikasi existing permissions masih ada:
  - `READ_EXTERNAL_STORAGE`
  - `WRITE_EXTERNAL_STORAGE`
  - `MANAGE_EXTERNAL_STORAGE`
  - `CAMERA`
  - `INTERNET`

### 5f — `pubspec.yaml` — hapus orphan line

- [ ] Hapus `image_picker: ^1.1.0` line yang ada DI ATAS dependencies block (orphan/malformed)
- [ ] Pastikan `image_picker: ^1.1.0` YANG DI DALAM `dependencies:` block **tetap ada**
- [ ] Jalankan `flutter pub get` → verify no error

### 5g — `test/widget_test.dart` — DELETE

- [ ] Verifikasi ini adalah broken starter template (tes counter yang tidak relevan)
- [ ] Hapus file
- [ ] (Opsional) Buat pengganti minimal: `test/smoke_test.dart` yang hanya verifikasi widget utama bisa di-instantiate — tapi ini opsional, tidak blocking

### 5h — Final `flutter analyze`

- [ ] Jalankan `flutter analyze`
- [ ] Target: **0 errors**
- [ ] Warning/info dari file yang tidak disentuh di redesign ini → acceptable (catat di review)
- [ ] Catat output lengkap di Post-Phase Review

---

## Verifikasi

- [ ] `flutter analyze` → 0 errors
- [ ] `flutter pub get` → no error
- [ ] `flutter run` → app masih berfungsi normal
- [ ] PDF generate dan share masih works
- [ ] Thumbnail image_picker tidak crash di Android 13 emulator

---

## Post-Phase Review

> Isi setelah semua task di atas selesai. Wajib sebelum lanjut ke Phase 6.

**Tanggal selesai**: _

**Yang berhasil**:
- 

**Masalah ditemukan**:
- 

**Deprecated aliases dihapus / dipertahankan**:
- 

**flutter analyze output final**:
```
(paste output di sini)
```

**Siap lanjut ke Phase 6**: ☐ Ya / ☐ Tidak (alasan: _)
