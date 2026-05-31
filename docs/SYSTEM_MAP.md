# SYSTEM MAP — Trip Planner App

> Navigasi utama proyek. Dihasilkan secara otomatis dari analisis source code.
> **Package:** `iterasi1` | **Versi:** 1.0.0+1

---

## 1. Project Summary

### Tujuan
Aplikasi mobile untuk merencanakan perjalanan wisata. Pengguna dapat membuat itinerary secara manual atau menggunakan bantuan AI (GPT-4o), mengelola aktivitas per hari, melampirkan foto dari galeri/kamera, dan mengekspor itinerary ke PDF.

### Tech Stack

| Komponen | Detail |
|---|---|
| Flutter SDK | ≥3.x (dikonfirmasi Flutter 3.35.2 stable) |
| Dart SDK | `>=2.19.2 <3.0.0` |
| State Management | **Provider** (`ChangeNotifier`) + **GetX** (hanya di modul foto) |
| Database Lokal | **SQLite** via `sqflite ^2.3.3+1` |
| Backend / AI | **OpenAI GPT-4o** (`https://api.openai.com/v1/chat/completions`) |
| Maps & Places | Google Maps Flutter + Google Places API |
| PDF | `pdf ^3.9.0` + `printing ^5.10.1` |
| Responsive | `flutter_screenutil ^5.9.0` (design size: 375×812) |
| Env Config | `flutter_dotenv ^5.2.1` (file `.env` di-bundle sebagai asset) |
| Font | **Inter** via `google_fonts` (body & heading) |
| Target Platform | Android (utama), iOS |

### Pola Arsitektur
**Layer-first** sederhana — tidak menggunakan Clean Architecture secara penuh. Struktur nyata:
```
lib/
  main.dart         ← entrypoint + DI setup
  model/            ← data class + serialisasi JSON
  database/         ← data source (SQLite)
  service/          ← API client (OpenAI)
  provider/         ← state management (ChangeNotifier)
  pages/            ← screens + sub-widgets per fitur
  widget/           ← shared/reusable widgets
  resource/         ← tema & design tokens
  utilities/        ← helper, formatter, env
```

---

## 2. Core Logic Flow

### Flow A — Membuat Itinerary Manual
```
ItineraryList [FAB tap]
  → CustomBottomSheet [input judul]
  → ItineraryProvider.initItinerary()
  → SelectDate [pilih rentang tanggal]
  → ItineraryProvider.initializeDays(dates)
  → AddDays [kelola tab hari + aktivitas]
    → AddActivities [form tambah/edit aktivitas]
      → Activity.new()
      → ItineraryProvider.insertNewActivity()
  → AddDays.persistCurrentItinerary()
    → DatabaseProvider.insertItinerary()
      → DatabaseService.insertItinerary() → SQLite
  → ItineraryList [refresh via DatabaseProvider.refreshData()]
```

### Flow B — Rekomendasi Itinerary via AI
```
SelectDate [tombol "Minta AI menyusun" — tanpa batas jumlah hari]
  → FormSuggestion [kota asal & tujuan + preferensi opsional:
       tipe trip (maks 2), gaya perjalanan/pace, pergi dengan siapa, catatan]
    → Google Places API [autocomplete TypeAhead]
  → ItineraryProvider.generateItineraryByAi(vibes, pace, companions, notes)
      AI hanya menyusun 3 HARI PERTAMA:
        isPartialTrip = jumlah hari > 3
        tripDates     = isPartialTrip ? 3 tanggal pertama : semua tanggal
        returnToOrigin = !isPartialTrip   (≤3 hari → pulang ke kota asal;
                         >3 hari → tetap di kota tujuan, tidak pulang)
    → ItineraryService.fetchItinerary(returnToOrigin) ×2 versi
      → OpenAI GPT-4o API [structured JSON output]
    → Itinerary.fromJsonGPT() → List<Itinerary>
  → SuggestionPage [tampilkan 2 rekomendasi via TabBar — hanya 3 hari AI]
  → ItineraryProvider.addDay() per hari AI
    + Day.from() untuk tanggal ke-4+ sebagai hari KOSONG (jika trip > 3 hari)
  → AddDays [3 hari terisi + hari 4+ kosong, lanjut edit manual]
```

### Flow C — Manajemen Foto Aktivitas
```
AddDays [ikon foto pada ActivityCard]
  → PhotoManager.requestPermissionExtend()
  → ActivityPhotoPage
    → PhotoController (GetX) [loadImage + syncGalleryIncremental]
      → photo_manager [scan galeri by tanggal & jam aktivitas]
      → ItineraryProvider.addPhotoActivity() / removePhotoActivity()
    → ImagePicker [kamera / galeri manual]
  → Simpan path foto di Activity.images[]
```

### Flow D — Export PDF
```
AddDays [ikon print]
  → PdfPreviewPage
    → makePdf(itinerary) → Uint8List
      → pdf.Document() + Table per hari
    → printing.layoutPdf() [preview & share]
```

---

## 3. Clean Tree

```
trip-planner-app/
├── lib/
│   ├── main.dart
│   ├── core.dart
│   ├── core_package.dart
│   ├── database/
│   │   └── database_service.dart
│   ├── model/
│   │   ├── activity.dart
│   │   ├── alert_save_dialog_result.dart
│   │   ├── create_itinerary_result.dart
│   │   ├── day.dart
│   │   └── itinerary.dart
│   ├── pages/
│   │   ├── activity_photo_controller.dart
│   │   ├── activity_photo_page.dart
│   │   ├── activity_trash_photo_page.dart
│   │   ├── add_activities/
│   │   │   ├── add_activities.dart
│   │   │   ├── form_suggestion.dart
│   │   │   └── suggestion_page.dart
│   │   ├── add_days/
│   │   │   ├── add_days.dart
│   │   │   ├── app_bar_itinerary_title.dart
│   │   │   └── search_field.dart
│   │   ├── datepicker/
│   │   │   └── select_date.dart
│   │   ├── itinerary_list.dart
│   │   ├── pdf/
│   │   │   ├── make_pdf.dart
│   │   │   └── preview_pdf_page.dart
│   │   └── splash_screen.dart
│   ├── provider/
│   │   ├── database_provider.dart
│   │   └── itinerary_provider.dart
│   ├── resource/
│   │   └── theme.dart
│   ├── service/
│   │   └── itinerary_service.dart
│   ├── utilities/
│   │   ├── app_env.dart
│   │   ├── app_helper.dart
│   │   ├── date_time_formatter.dart
│   │   ├── thumbnail_storage.dart
│   │   └── utils.dart
│   └── widget/
│       ├── activity_card.dart
│       ├── custom_buttom_sheet.dart
│       ├── iterasi_chip.dart
│       ├── iterasi_text.dart
│       ├── itinerary_card.dart
│       ├── loading_overlay.dart
│       ├── location_autocomplete_field.dart
│       ├── maps_text_field.dart
│       ├── recommendaation_activity_card.dart
│       ├── text_dialog.dart
│       └── text_field_wirdget.dart
├── test/
│   └── widget_test.dart
├── assets/
│   ├── data.json              ← data rekomendasi statis (asal-tujuan)
│   ├── response.json          ← contoh response OpenAI (dev/debug)
│   ├── fonts/
│   │   ├── MrDeHaviland-Regular.ttf
│   │   ├── OratorStd.otf
│   │   ├── Poppins-Bold.ttf
│   │   ├── Poppins-Regular.ttf
│   │   └── good times rg.otf
│   └── images/
│       ├── AppLogo.png
│       ├── splashscreen.png
│       └── ... (aset gambar lainnya)
├── docs/
│   └── SYSTEM_MAP.md          ← file ini
├── DESIGN.md
├── .env                       ← GPT_KEY, GMAPS_API_KEY (tidak di-commit)
├── analysis_options.yaml
└── pubspec.yaml
```

---

## 4. Module Map

### Presentation Layer

| Path | Class | Method Publik Utama | Peran |
|---|---|---|---|
| `lib/pages/splash_screen.dart` | `SplashScreen` | — | Splash 1,5 detik lalu redirect ke `ItineraryList` |
| `lib/pages/itinerary_list.dart` | `ItineraryList` | `getItineraryTitle()` | Halaman utama: daftar itinerary + search + FAB buat baru |
| `lib/pages/add_days/add_days.dart` | `AddDays` | `saveAndExit()`, `handleBackBehaviour()`, `persistCurrentItinerary()` | Editor itinerary: tab hari, list aktivitas, simpan/batal |
| `lib/pages/add_activities/add_activities.dart` | `AddActivities` | `_submitActivity()` | Form tambah/edit satu aktivitas dengan validasi |
| `lib/pages/datepicker/select_date.dart` | `SelectDate` | `onSimpanDate()` | Pilih rentang tanggal; arahkan ke AI atau manual |
| `lib/pages/add_activities/form_suggestion.dart` | `FormSuggestion` | — | Form input kota asal-tujuan untuk trigger AI |
| `lib/pages/add_activities/suggestion_page.dart` | `SuggestionPage` | `_buildItineraryContent()` | Tampilkan 2 rekomendasi AI dalam TabBar, pilih satu |
| `lib/pages/activity_photo_page.dart` | `ActivityPhotoPage` | `_saveCameraImage()`, `_saveGalleryImage()` | Galeri foto per aktivitas: ambil kamera/galeri, multi-select share/hapus, masonry view |
| `lib/pages/activity_trash_photo_page.dart` | `ActivityTrashPhotoPage` | — | Tampilkan foto yang ditandai dihapus, bisa dipulihkan |
| `lib/pages/pdf/preview_pdf_page.dart` | `PdfPreviewPage` | — | Preview dan share PDF itinerary |

### State Management Layer

| Path | Class | Method Publik Utama | Peran |
|---|---|---|---|
| `lib/provider/database_provider.dart` | `DatabaseProvider` | `refreshData()`, `deleteItinerary()`, `insertItinerary()` | Jembatan UI ↔ SQLite untuk daftar itinerary |
| `lib/provider/itinerary_provider.dart` | `ItineraryProvider` | `initItinerary()`, `addDay()`, `initializeDays()`, `updateActivity()`, `insertNewActivity()`, `removeActivity()`, `addPhotoActivity()`, `generateItineraryByAi()` | State sesi editing satu itinerary aktif + logika AI |
| `lib/pages/activity_photo_controller.dart` | `PhotoController` | `loadImage()`, `syncGalleryIncremental()`, `deletePhoto()`, `returnPhoto()` | GetX controller untuk state foto per aktivitas |

### Data Layer

| Path | Class | Method Publik Utama | Peran |
|---|---|---|---|
| `lib/database/database_service.dart` | `DatabaseService` | `insertItinerary()`, `fetchItineraries()`, `deleteItinerary()` | Singleton SQLite service — CRUD itinerary |
| `lib/service/itinerary_service.dart` | `ItineraryService` | `fetchItinerary()` | HTTP client ke OpenAI GPT-4o, parse JSON → `Itinerary` |

### Domain / Model Layer

| Path | Class | Method / Field Penting | Peran |
|---|---|---|---|
| `lib/model/itinerary.dart` | `Itinerary` | `fromJson()`, `fromJsonGPT()`, `toJsonString()`, `copy()` | Root model: id, title, dateModified, List\<Day\> |
| `lib/model/day.dart` | `Day` | `fromJson()`, `fromJsonGPT()`, `getDatetime()`, `copy()` | Model satu hari: tanggal (DD/MM/YYYY), List\<Activity\> |
| `lib/model/activity.dart` | `Activity` | `fromJson()`, `fromJsonGPT()`, `copy()`, `startDateTime`, `endDateTime` | Model aktivitas: nama, lokasi, waktu, foto, koordinat |
| `lib/model/alert_save_dialog_result.dart` | `AlertSaveDialogResult` | enum: `cancel`, `saveWithoutQuit`, `saveAndQuit` | Enum hasil dialog konfirmasi simpan |
| `lib/model/create_itinerary_result.dart` | `CreateItineraryResult` | `title`, `thumbnailPath` | Hasil bottom sheet "buat itinerary baru": judul + path thumbnail |

### Core / Utilities

| Path | Class | Peran |
|---|---|---|
| `lib/resource/theme.dart` | `CustomColor`, `AppTheme` | Design token (warna, radius, shadow) + `ThemeData` global |
| `lib/utilities/app_env.dart` | `AppEnv` | Load `.env` via flutter_dotenv, expose `gptKey`, `gmapsApiKey` |
| `lib/utilities/app_helper.dart` | `AppHelper` | Format tanggal ke "DD MMM YYYY", hitung durasi menit |
| `lib/utilities/date_time_formatter.dart` | `DateTimeFormatter` | Konversi `DateTime` → string format "DD-MM-YYYY" |
| `lib/utilities/thumbnail_storage.dart` | `persistThumbnail()` (top-level) | Salin file thumbnail ke `<appDocs>/thumbnails/<itineraryId>.jpg`, kembalikan path |

---

## 5. State Management Map

### Pattern
**Provider** (`ChangeNotifier`) — digunakan untuk state utama aplikasi.
**GetX** — digunakan **hanya** di `ActivityPhotoPage` / `PhotoController` untuk reaktivitas foto.

### State Classes

```
MultiProvider (root)
├── ChangeNotifierProvider<DatabaseProvider>
│   State: _itineraryDatas (Future<List<Itinerary>>)
│   Notifies: ItineraryList (via context.watch)
│   Triggers: DatabaseService.fetchItineraries()
│
└── ChangeNotifierProvider<ItineraryProvider>
    State: _itinerary (Itinerary aktif), initialItinerary (snapshot awal)
    Notifies: AddDays, SelectDate, AddActivities (via Provider.of / context.read)
    isDataChanged: bool — dirty check via toJsonString() comparison

GetX (scoped ke ActivityPhotoPage)
└── Get.put(PhotoController)
    State: image (RxList<File>), isLoading (RxBool)
    Consumed: ActivityPhotoPage via Obx()
```

### Dependency Graph
```
ItineraryList
  → watches: DatabaseProvider (_itineraryDatas)
  → reads:   ItineraryProvider (initItinerary)

SelectDate
  → reads:   ItineraryProvider (initializeDays)

AddDays
  → listens: ItineraryProvider (itinerary state)
  → listens: DatabaseProvider (untuk refresh setelah save)

FormSuggestion
  → reads: ItineraryProvider (generateItineraryByAi)

SuggestionPage
  → reads: ItineraryProvider (addDay)

ActivityPhotoPage
  → reads:   ItineraryProvider (addPhotoActivity, removePhotoActivity)
  → owns:    PhotoController (GetX)
```

---

## 6. Navigation & Routing

### Router Library
**Navigator 1.0 imperatif** (`Navigator.push`, `Navigator.pop`, `Navigator.pushReplacementNamed`, `Navigator.popUntil`). Tidak menggunakan GoRouter atau AutoRoute.

### Named Routes (di `MaterialApp.routes`)

| Route Key | Screen | Keterangan |
|---|---|---|
| `/` (home) | `SplashScreen` | Default home |
| `ItineraryList.route` = `"/ItineraryListRoute"` | `ItineraryList` | Halaman utama setelah splash |

### Push Routes (MaterialPageRoute — tidak bernama)

| Dari | Ke | Kondisi |
|---|---|---|
| `SplashScreen` (1,5 dtk) | `ItineraryList` | `pushReplacementNamed` |
| `ItineraryList` (FAB) | `SelectDate(isNewItinerary: true)` | Setelah input judul di bottom sheet |
| `SelectDate` (tanggal terpilih) | `FormSuggestion` | Tombol "Minta AI menyusun" — tanpa batas jumlah hari; AI hanya menyusun 3 hari pertama |
| `SelectDate` (semua) | `AddDays` | Tombol "Susun sendiri" |
| `FormSuggestion` | `SuggestionPage` | Setelah AI response berhasil |
| `SuggestionPage` (pilih) | `AddDays` | Setelah user pilih rekomendasi |
| `AddDays` | `AddActivities` | Tombol "Tambah Aktivitas" |
| `AddDays` | `SelectDate(isNewItinerary: false)` | Tombol + tanggal di day tab |
| `AddDays` | `PdfPreviewPage` | Ikon print |
| `AddDays` | `ActivityPhotoPage` | Ikon foto di `ActivityCard` |
| `ActivityPhotoPage` | `ActivityTrashPhotoPage` | Ikon delete di app bar |
| `AddDays` (save) | `ItineraryList` | `popUntil(ModalRoute.withName(...))` |

### Guard / Deep Link
- Tidak ada auth guard.
- Tidak ada deep link yang dikonfigurasi.
- Orientasi dikunci portrait (`SystemChrome.setPreferredOrientations`).

---

## 7. Data & Config

### Environment Variables (`.env`)
```
GPT_KEY=<OpenAI API Key>
GMAPS_API_KEY=<Google Maps API Key>
```
Dimuat via `AppEnv.load()` di `main()`. File `.env` di-bundle sebagai Flutter asset (tercantum di `pubspec.yaml`).

### Database Lokal — SQLite
| Detail | Nilai |
|---|---|
| Library | `sqflite ^2.3.3+1` |
| DB Name | `itinerary_db` |
| Table | `itineraries` |
| Schema | `id STRING PRIMARY KEY, data STRING` |
| Strategi | Seluruh `Itinerary` di-serialize ke JSON string dan disimpan di kolom `data` |
| Pattern | Singleton (`DatabaseService._internalConstructor`) |

### Model Serialisasi

```
Itinerary {id, title, dateModified, days[]}
  └── Day {date: "DD/MM/YYYY", activities[]}
        └── Activity {
              id, activityName, lokasi,
              startActivityTime, endActivityTime,
              keterangan, latitude, longtitude,
              isCustomLocation,
              images[], removedImages[], hiddenPhotoHashes[],
              lastGalleryScanEpochMs
            }
```

Dua format JSON tersedia per model:
- `fromJson()` — format internal (dari SQLite)
- `fromJsonGPT()` — format response OpenAI

### DI Setup
Tidak menggunakan get_it atau injectable. DI dilakukan manual via `MultiProvider` di `MyApp.build()`:
```dart
MultiProvider(providers: [
  ChangeNotifierProvider(create: (_) => DatabaseProvider()),
  ChangeNotifierProvider(create: (_) => ItineraryProvider()),
])
```

### Assets Data
| File | Isi |
|---|---|
| `assets/data.json` | Rekomendasi itinerary statis: key = `"ASAL-TUJUAN"`, value = itinerary per jumlah hari |
| `assets/response.json` | Contoh response OpenAI (digunakan untuk debug lokal, ada komentar switch di `ItineraryService`) |

---

## 8. External Integrations

### OpenAI GPT-4o
- **Endpoint:** `https://api.openai.com/v1/chat/completions`
- **Model:** `gpt-4o-2024-08-06`
- **Mode:** Structured Output (`json_schema` dengan `strict: true`)
- **Output Schema:** `{ itinerary: [{ date, activities: [{ title, location, start_time, end_time, description, latitude, longitude }] }] }`
- **Auth:** Bearer token dari `AppEnv.gptKey`
- **Aturan pulang (`returnToOrigin`):** parameter `fetchItinerary(returnToOrigin)` menyisipkan aturan prompt — `true` → hari terakhir wajib pulang ke kota asal; `false` → hari terakhir tetap di kota tujuan (untuk trip >3 hari yang hanya digenerate 3 hari pertama).
- **Input preferensi opsional:** `fetchItinerary` menerima `vibes` (tipe trip, maks 2), `pace` (gaya perjalanan: Santai/Balanced/Padat, dengan panduan kepadatan jadwal), `companions` (pergi dengan siapa), dan `notes`. Tiap input hanya disisipkan ke prompt jika diisi.
- **File:** `lib/service/itinerary_service.dart`

### Google Maps / Places API
- **Autocomplete:** `https://maps.googleapis.com/maps/api/place/autocomplete/json` — digunakan di `FormSuggestion` via `flutter_typeahead`
- **Maps View:** `google_maps_flutter ^2.10.1` — tersedia di widget `maps_text_field.dart` dan `location_autocomplete_field.dart`
- **Auth:** Key dari `AppEnv.gmapsApiKey`

### Native Platform Channel
- **Channel:** `trip_planner/media_scanner`
- **Method:** `scanFile({path})` — memanggil Android MediaScanner setelah foto disimpan ke `/storage/emulated/0/Pictures/Trip Planner/`
- **File:** `lib/pages/activity_photo_page.dart:42`

### Plugin Native Penting
| Plugin | Fungsi |
|---|---|
| `photo_manager ^3.1.1` | Scan galeri perangkat berdasarkan rentang waktu aktivitas |
| `image_picker ^1.1.0` | Ambil foto dari kamera / galeri manual |
| `permission_handler ^11.3.1` | Minta izin `manageExternalStorage`, galeri |
| `native_exif ^0.6.0` | Baca metadata EXIF foto (tersedia, belum digunakan aktif) |
| `printing ^5.10.1` | Preview dan share PDF |
| `share_plus ^7.2.2` | Bagikan foto (multi-select di `ActivityPhotoPage`) & berkas dari `add_days.dart` via share sheet OS |

---

## 9. Build & Flavors

### Flavors / Environment
**Tidak ada flavor** (dev/staging/prod). Konfigurasi dilakukan satu environment lewat `.env`.

### Konfigurasi Build
```yaml
# pubspec.yaml
version: 1.0.0+1
environment:
  sdk: ">=2.19.2 <3.0.0"
```

### Launcher Icons
```yaml
flutter_icons:
  android: true
  ios: true
  image_path: "assets/logo/AppLogo.png"   # ⚠️ path ini tidak sama dengan assets/images/AppLogo.png
```

### Catatan Build
- Debug build pernah gagal karena `.env` tidak ditemukan — file harus ada (bisa kosong) sebelum build.
- Dependency yang pernah konflik: `syncfusion_flutter_datepicker` + `intl ^0.20.0` — sudah diselesaikan dengan upgrade ke `syncfusion_flutter_datepicker: ^33.2.8`.
- Orientasi dikunci portrait via `SystemChrome` di `main()`.

---

## 10. Risks / Blind Spots

### Risiko Arsitektur

| # | Risiko | Lokasi | Dampak |
|---|---|---|---|
| R1 | **Mixed state management** — Provider + GetX dalam satu app. `PhotoController` (GetX) mengakses `ItineraryProvider` (Provider) via `Get.context!`, membuat coupling lintas sistem | `activity_photo_controller.dart:19` | Crash jika context hilang; susah di-test |
| R2 | **Logika parsing AI di dalam Provider** — `parseJsonToItinerary()`, `splitItineraryToDays()`, `generateItineraryByAi()` ada di `ItineraryProvider`, bukan di service/repository | `itinerary_provider.dart:233–396` | Provider terlalu besar (god object) |
| R3 | **Mutation state langsung** — `insertNewActivity()` memodifikasi `List<Activity>` yang dikirim langsung, bukan via `copyWith` | `itinerary_provider.dart:109` | Perubahan bisa terjadi tanpa `notifyListeners()` jika lupa |
| R4 | **`ItineraryProvider.isDataChanged`** menggunakan `toJsonString()` comparison — O(n) setiap build cycle | `itinerary_provider.dart:19` | Potensi jank di itinerary besar |
| R5 | *(resolved)* Versi legacy `suggestion_itinerary.dart` sudah dihapus; tinggal `suggestion_page.dart` sebagai satu-satunya halaman rekomendasi | — | — |
| R6 | **`print()` di production code** — beberapa lokasi masih pakai `print()` bukan `dart:developer log()` | `database_service.dart`, `itinerary_provider.dart` | Noise di log, tidak bisa difilter |

### Risks Generated Code / Assets
| # | Item | Catatan |
|---|---|---|
| G1 | `assets/data.json` — data rekomendasi statis | Bergantung pada format key `"ASAL-TUJUAN"` yang harus diketahui manual; tidak ada validasi skema |
| G2 | `.env` harus ada saat build | File kosong sudah dibuat; jika terhapus, build gagal dengan error "No file or variants found for asset: .env" |
| G3 | `flutter_launcher_icons` mereferensikan `assets/logo/AppLogo.png` | Path berbeda dari `assets/images/AppLogo.png` — ikon launcher mungkin tidak ter-generate dengan benar |
| G4 | `native_exif` diimport di `pubspec.yaml` | Tidak digunakan aktif di kode sumber yang ditemukan — kandidat untuk dihapus |
| G5 | `csv` package diimport | File `kontol.csv`, `pepekk.csv`, `puqi.csv` ada di `assets/` — kemungkinan file eksperimen/tes, harus dibersihkan sebelum release |

---

*Dibuat: 2026-05-28 | Tools: trace-by-flow dari `lib/main.dart`*
