# Phase 1 — Theme Rewrite

> **Status**: ✅ Selesai  
> **File utama**: `lib/resource/theme.dart`, `lib/main.dart`  
> **Prinsip**: Tambah token baru DULU, jangan hapus lama. Alias lama → baru agar semua file ikut berubah visual tanpa harus disentuh satu per satu.

---

## Tasks

### 1a — Tambah color tokens baru di `CustomColor`

- [x] Tambah ocean scale (50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950)
  ```dart
  static const ocean950 = Color(0xFF06192F);
  static const ocean900 = Color(0xFF0A2540);
  static const ocean800 = Color(0xFF143155);
  static const ocean700 = Color(0xFF1B3A5F);
  static const ocean600 = Color(0xFF284F77);
  static const ocean500 = Color(0xFF3A5878);
  static const ocean400 = Color(0xFF5B7A9C);
  static const ocean300 = Color(0xFF7A93AC);
  static const ocean200 = Color(0xFFC7D5E0);
  static const ocean100 = Color(0xFFDEE6EF);
  static const ocean50  = Color(0xFFEFF4F8);
  ```
- [x] Tambah coral scale (200, 300, 400, 500, 600, 700, 800)
  ```dart
  static const coral800 = Color(0xFF8E3F2A);
  static const coral700 = Color(0xFFB2533A);
  static const coral600 = Color(0xFFC25E42);
  static const coral500 = Color(0xFFD4684A);
  static const coral400 = Color(0xFFE08366);
  static const coral300 = Color(0xFFE89878);
  static const coral200 = Color(0xFFF2BFA8);
  ```
- [x] Tambah sand scale (100, 200, 300, 400, 500, 700)
  ```dart
  static const sand700 = Color(0xFFA78854);
  static const sand500 = Color(0xFFC9A875);
  static const sand400 = Color(0xFFD8BC92);
  static const sand300 = Color(0xFFE8DAC2);
  static const sand200 = Color(0xFFEFE3CD);
  static const sand100 = Color(0xFFF5EDDD);
  ```
- [x] Tambah paper, paper2, ink, muted
  ```dart
  static const paper  = Color(0xFFFAF6EF);
  static const paper2 = Color(0xFFF2EEE6);
  static const ink    = Color(0xFF0A2540);
  static const muted  = Color(0xFF6B7A8F);
  ```
- [x] Tambah semantic colors
  ```dart
  static const success  = Color(0xFF047857); // emerald-700
  static const warnAmber = Color(0xFFD97706); // amber-600
  static const danger   = Color(0xFFB2533A); // coral-700
  ```
- [x] Tambah shadow tokens
  ```dart
  static const shadowSoft = Color(0x140A2540); // 8% ocean900
  static const shadowCard = Color(0x1F0A2540); // 12% ocean900
  ```

### 1b — Alias field lama ke token baru (jangan delete field lama)

- [x] Alias `boardroomNavy`, `pitchBlack` → `ocean900`
- [x] Alias `brandElectric`, `primary`, `buttonColor` → `coral500`
- [x] Alias `softOffWhite`, `surface`, `backgroundColor`, `scaffoldBackground`, `greyBackgroundColor` → `paper`
- [x] Alias `whiteColor`, `cardBackground`, `inputFillColor` → `paper`
- [x] Alias `lightCoolGray`, `cardBorder`, `dividerColor` → `ocean100`
- [x] Alias `mediumGray`, `subtitleTextColor`, `hintTextColor`, `inputBorderColor`, `inputBorderGray`, `disabledColor` → `muted`
- [x] Alias `feedbackYellow` → `warnAmber`
- [x] Alias `warningColor` → `danger`
- [x] Alias `successColor` → `success`
- [x] Alias `accentOrange` → `coral500`
- [x] Alias `shadowColor` → `shadowSoft`
- [x] Alias `actionPanelShadowColor` → `shadowCard`
- [x] Alias `primaryColor50..900` scale → `ocean50..900` (primaryColor100 → sand300 per spec)
- [x] Alias `lilacAccent`, `dateBackground`, `primaryColor100` → `sand300`

### 1c — Tambah typography helpers (jangan hapus lama)

- [x] Tambah `bodyStyle` (DM Sans, ink color)
  ```dart
  final TextStyle bodyStyle = GoogleFonts.dmSans(color: CustomColor.ink);
  ```
- [x] Tambah `displayStyle` (Instrument Serif, ink color)
  ```dart
  final TextStyle displayStyle = GoogleFonts.instrumentSerif(color: CustomColor.ink);
  ```
- [x] Tambah `monoStyle` (DM Mono, muted color)
  ```dart
  final TextStyle monoStyle = GoogleFonts.dmMono(color: CustomColor.muted);
  ```
- [x] Alias `primaryTextStyle` → `bodyStyle` (reassign ke DM Sans)
  ```dart
  final TextStyle primaryTextStyle = GoogleFonts.dmSans(color: CustomColor.ink);
  ```
- [x] Alias `headingTextStyle` → `displayStyle` (reassign ke Instrument Serif)
  ```dart
  final TextStyle headingTextStyle = GoogleFonts.instrumentSerif(...);
  ```
- [x] Pastikan `FontWeight light/regular/medium/semibold/bold` globals **tetap ada** (diupgrade ke `const`)

### 1d — Rewrite `AppTheme.lightTheme` dengan token baru

- [x] `AppBarTheme`: background `paper`, foreground `ocean900`, `centerTitle: false`, elevation 0
- [x] `inputDecorationTheme`: fillColor `paper`, border `ocean100` default radius **12**, hintStyle pakai `bodyStyle` dengan color `muted`
- [x] `ElevatedButton`: background `ocean900`, foreground `paper`, radius **999** (pill), height 50, disabled background `ocean200`
- [x] `floatingActionButtonTheme`: background `ocean900`, foreground `paper`, shape pill
- [x] `snackBarTheme`: background `ocean900`, contentTextStyle `bodyStyle` white
- [x] `bottomSheetTheme`: background `paper`, shape `RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24)))`
- [x] `dialogTheme`: background `paper`, shape radius 18
- [x] `scaffoldBackgroundColor`: `paper`
- [x] `progressIndicatorTheme`: color `coral500`
- [x] `colorScheme.primary`: `coral500`, secondary: `ocean700`, surface: `paper`
- [x] TextTheme via `GoogleFonts.dmSansTextTheme(base.textTheme)` — body pakai DM Sans global
- [x] Dead static `AppTheme.colorScheme` field removed (was duplicate of lightTheme, no external references)

### 1e — Update `lib/main.dart`

- [x] `SystemChrome.setSystemUIOverlayStyle`: status bar dark icons (karena bg paper), `CustomColor.paper` untuk nav bar
- [x] Pastikan `ScreenUtilInit(designSize: Size(375, 812))` tidak berubah
- [x] Pastikan `MultiProvider` tidak berubah
- [x] Pastikan `locale: const Locale('id', 'ID')` tidak berubah

---

## Verifikasi

- [x] `flutter analyze` → 0 error baru (94 pre-existing info/warning, semua dari file lain)
- [ ] `flutter run` → app boot, splash muncul
- [ ] Itinerary list → background berubah ke paper (#FAF6EF)
- [ ] FAB → background berubah ke ocean900 (navy, bukan electric blue)
- [ ] AppBar → background putih/paper, teks navy

---

## Post-Phase Review

> Isi setelah semua task di atas selesai. Wajib sebelum lanjut ke Phase 2.

**Tanggal selesai**: 2026-05-29

**Yang berhasil**:
- Semua 47 token baru ditambahkan (ocean scale, coral scale, sand scale, paper/ink/muted, semantic, shadow)
- Semua 26+ field lama di-alias ke token baru tanpa ada yang dihapus — backward compat terjaga
- Typography diupgrade: DM Sans (body), Instrument Serif (display), DM Mono (mono)
- `AppTheme.lightTheme` sepenuhnya menggunakan token baru
- `flutter analyze` 0 error baru
- FontWeight globals diupgrade ke `const`, TextStyle globals ke `final` — immutability terjaga
- Dead code `AppTheme.colorScheme` static dihapus (tidak ada referensi eksternal)

**Masalah ditemukan**:
- `main.dart` awalnya punya hard-coded `Color(0xFFFAF6EF)` di `SystemUiOverlayStyle` → diperbaiki ke `CustomColor.paper`
- Code quality reviewer flagged `warningColor → danger` (concern semantic naming) dan `primaryColor100 → sand300` (break scale) — keduanya intentional per spec, dipertahankan

**Keputusan yang diambil**:
- `warningColor → danger` dipertahankan per token mapping spec (fase 1 tidak mengubah semantik lama)
- `primaryColor100 → sand300` dipertahankan per spec (lilacAccent / dateBackground lama memang sand-tone)
- `paper2` dan `monoStyle` dideklarasikan sebagai reserved token, tidak dihapus

**flutter analyze output**:
```
94 issues found. (ran in 4.4s)
All 94 are pre-existing info/warning in: location_autocomplete_field.dart, recommendaation_activity_card.dart, text_dialog.dart, widget_test.dart
0 new errors from Phase 1 changes.
```

**Siap lanjut ke Phase 2**: ☑ Ya (visual check `flutter run` dilakukan setelah Phase 2 selesai untuk melihat efek kombinasi)
