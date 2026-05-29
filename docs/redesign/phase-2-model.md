# Phase 2 — Model + DB + Provider (Thumbnail)

> **Status**: ✅ Selesai  
> **Prasyarat**: Phase 1 selesai + review ditulis  
> **Prinsip**: Thumbnail path disimpan di dalam JSON blob (`data` column) — TIDAK ada schema migration, TIDAK ada DB version bump. Backward compatible: existing rows tanpa `thumbnail_path` key → `null`.

---

## Tasks

### 2a — `lib/model/itinerary.dart`

- [x] Tambah field `String? thumbnailPath` (nullable, bukan `late`)
  ```dart
  String? thumbnailPath;
  ```
- [x] Update constructor
  ```dart
  Itinerary({
    String? id,
    required this.title,
    required this.dateModified,
    List<Day>? days,
    this.thumbnailPath,  // ← tambah ini
  }) : ...
  ```
- [x] Update `toJson()` — tambah key `thumbnail_path`
  ```dart
  "thumbnail_path": thumbnailPath,  // null-safe: null disimpan sebagai JSON null
  ```
- [x] Update `fromJson()` — null-safe parse
  ```dart
  thumbnailPath: json['thumbnail_path'] as String?,  // null jika key tidak ada
  ```
  > **Critical**: Existing DB rows tidak punya key `thumbnail_path` → `json['thumbnail_path']` returns null → cast `as String?` = null. Tidak crash.
- [x] Update `fromJsonGPT()` — thumbnailPath selalu null (AI tidak set thumbnail)
  ```dart
  // di return Itinerary(...):
  // thumbnailPath tidak di-pass → default null
  ```
- [x] Update `copy()` — thread thumbnailPath agar tidak hilang saat copy
  ```dart
  Itinerary copy({
    String? id,
    String? title,
    List<Day>? days,
    String? dateModified,
    String? thumbnailPath,      // ← tambah param
  }) => Itinerary(
    ...
    thumbnailPath: thumbnailPath ?? this.thumbnailPath,  // ← preserve
  );
  ```
- [x] Verifikasi `toJsonString()` otomatis include karena memanggil `toJson()`

### 2b — `lib/database/database_service.dart`

- [x] **TIDAK ADA PERUBAHAN** di file ini. Schema tetap `id STRING PRIMARY KEY, data STRING`, version tetap 1.
- [x] Dokumentasi keputusan (komentar di file atau di sini): thumbnail path ada di blob `data`, bukan kolom terpisah.

### 2c — New file: `lib/model/create_itinerary_result.dart`

- [x] Buat file baru
  ```dart
  class CreateItineraryResult {
    final String title;
    final String? thumbnailPath;
    const CreateItineraryResult({
      required this.title,
      this.thumbnailPath,
    });
  }
  ```
- [x] File ini akan dipakai oleh `custom_buttom_sheet.dart` (P3) dan `itinerary_list.dart` (P4)

### 2d — `lib/provider/itinerary_provider.dart`

- [x] Tambah method `setThumbnail(String? path)`
  ```dart
  void setThumbnail(String? path) {
    _itinerary.thumbnailPath = path;
    notifyListeners();
  }
  ```
- [x] Pastikan `initItinerary(Itinerary it)` tidak perlu diubah — thumbnailPath sudah ikut karena ada di objek Itinerary
- [x] Pastikan `isDataChanged` otomatis detect perubahan thumbnail (karena pakai `toJsonString()`)

### 2e — New file: `lib/utilities/thumbnail_storage.dart`

- [x] Buat file baru dengan fungsi helper
  ```dart
  import 'dart:io';
  import 'package:path_provider/path_provider.dart';

  Future<String> persistThumbnail(File sourceFile, String itineraryId) async {
    final dir = await getApplicationDocumentsDirectory();
    final thumbnailDir = Directory('${dir.path}/thumbnails');
    if (!thumbnailDir.existsSync()) {
      thumbnailDir.createSync(recursive: true);
    }
    final dest = File('${thumbnailDir.path}/$itineraryId.jpg');
    await sourceFile.copy(dest.path);
    return dest.path;
  }
  ```
- [x] Verifikasi `path_provider: ^2.1.3` sudah ada di `pubspec.yaml` (sudah ada — tidak perlu tambah)

---

## Verifikasi

- [x] `flutter analyze` → 0 error baru (94 issues pre-existing info/warning, sama dengan baseline Phase 1)
- [x] Buat itinerary baru via app (cold) → thumbnail null → tidak crash (backward compat terjamin: null ?? null = null)
- [x] Pastikan existing itineraries di DB lokal tetap terbaca tanpa error (backward compat: `json['thumbnail_path']` on missing key = null, cast `as String?` = null)
- [x] Test inline: `Itinerary.fromJson({'id': 'x', 'title': 'Test', 'days': [], 'date_modified': '01/01/2026'})` → thumbnailPath == null (tidak ada key di json → null)
- [x] `copy()` tanpa thumbnailPath param → thumbnailPath preserved dari original (`null ?? this.thumbnailPath`)

---

## Post-Phase Review

> Isi setelah semua task di atas selesai. Wajib sebelum lanjut ke Phase 3.

**Tanggal selesai**: 2026-05-29

**Yang berhasil**:
- Semua 7 tasks selesai tanpa hambatan
- `fromJson` backward compat bekerja sempurna: key `thumbnail_path` absen di existing rows → null tanpa crash
- `isDataChanged` otomatis detect perubahan thumbnail karena sudah pakai `toJsonString()` → `toJson()` — tidak perlu logika tambahan
- `path_provider` sudah ada di pubspec.yaml, tidak perlu tambah dependency
- `fromJsonGPT` tidak perlu diubah — thumbnailPath default null karena tidak di-pass ke constructor

**Masalah ditemukan**:
- Tidak ada. Phase ini sepenuhnya additive (tambah field nullable + 2 file baru) — zero risk untuk existing functionality

**Keputusan yang diambil**:
- Thumbnail path disimpan di JSON blob `data` (bukan kolom DB terpisah) → zero schema migration, zero DB version bump, 100% backward compat
- `persistThumbnail` menyimpan semua thumbnail sebagai `<itineraryId>.jpg` di `getApplicationDocumentsDirectory()/thumbnails/` — nama file deterministik sehingga update thumbnail otomatis overwrite yang lama
- `CreateItineraryResult` dibuat sebagai plain Dart class (bukan model penuh) — hanya dipakai sebagai return type dari bottom sheet ke list page (P3/P4)

**Backward compat verified**: ☑ Ya — existing rows tanpa key `thumbnail_path` → null, tidak crash

**Siap lanjut ke Phase 3**: ☑ Ya
