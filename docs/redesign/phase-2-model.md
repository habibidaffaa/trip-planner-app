# Phase 2 — Model + DB + Provider (Thumbnail)

> **Status**: 🔴 Belum dimulai  
> **Prasyarat**: Phase 1 selesai + review ditulis  
> **Prinsip**: Thumbnail path disimpan di dalam JSON blob (`data` column) — TIDAK ada schema migration, TIDAK ada DB version bump. Backward compatible: existing rows tanpa `thumbnail_path` key → `null`.

---

## Tasks

### 2a — `lib/model/itinerary.dart`

- [ ] Tambah field `String? thumbnailPath` (nullable, bukan `late`)
  ```dart
  String? thumbnailPath;
  ```
- [ ] Update constructor
  ```dart
  Itinerary({
    String? id,
    required this.title,
    required this.dateModified,
    List<Day>? days,
    this.thumbnailPath,  // ← tambah ini
  }) : ...
  ```
- [ ] Update `toJson()` — tambah key `thumbnail_path`
  ```dart
  "thumbnail_path": thumbnailPath,  // null-safe: null disimpan sebagai JSON null
  ```
- [ ] Update `fromJson()` — null-safe parse
  ```dart
  thumbnailPath: json['thumbnail_path'] as String?,  // null jika key tidak ada
  ```
  > **Critical**: Existing DB rows tidak punya key `thumbnail_path` → `json['thumbnail_path']` returns null → cast `as String?` = null. Tidak crash.
- [ ] Update `fromJsonGPT()` — thumbnailPath selalu null (AI tidak set thumbnail)
  ```dart
  // di return Itinerary(...):
  // thumbnailPath tidak di-pass → default null
  ```
- [ ] Update `copy()` — thread thumbnailPath agar tidak hilang saat copy
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
- [ ] Verifikasi `toJsonString()` otomatis include karena memanggil `toJson()`

### 2b — `lib/database/database_service.dart`

- [ ] **TIDAK ADA PERUBAHAN** di file ini. Schema tetap `id STRING PRIMARY KEY, data STRING`, version tetap 1.
- [ ] Dokumentasi keputusan (komentar di file atau di sini): thumbnail path ada di blob `data`, bukan kolom terpisah.

### 2c — New file: `lib/model/create_itinerary_result.dart`

- [ ] Buat file baru
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
- [ ] File ini akan dipakai oleh `custom_buttom_sheet.dart` (P3) dan `itinerary_list.dart` (P4)

### 2d — `lib/provider/itinerary_provider.dart`

- [ ] Tambah method `setThumbnail(String? path)`
  ```dart
  void setThumbnail(String? path) {
    _itinerary.thumbnailPath = path;
    notifyListeners();
  }
  ```
- [ ] Pastikan `initItinerary(Itinerary it)` tidak perlu diubah — thumbnailPath sudah ikut karena ada di objek Itinerary
- [ ] Pastikan `isDataChanged` otomatis detect perubahan thumbnail (karena pakai `toJsonString()`)

### 2e — New file: `lib/utilities/thumbnail_storage.dart`

- [ ] Buat file baru dengan fungsi helper
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
- [ ] Verifikasi `path_provider: ^2.1.3` sudah ada di `pubspec.yaml` (sudah ada — tidak perlu tambah)

---

## Verifikasi

- [ ] `flutter analyze` → 0 error baru
- [ ] Buat itinerary baru via app (cold) → thumbnail null → tidak crash
- [ ] Pastikan existing itineraries di DB lokal tetap terbaca tanpa error (backward compat)
- [ ] Test inline: `Itinerary.fromJson({'id': 'x', 'title': 'Test', 'days': [], 'date_modified': '01/01/2026'})` → thumbnailPath == null (tidak ada key di json → null)
- [ ] `copy()` tanpa thumbnailPath param → thumbnailPath preserved dari original

---

## Post-Phase Review

> Isi setelah semua task di atas selesai. Wajib sebelum lanjut ke Phase 3.

**Tanggal selesai**: _

**Yang berhasil**:
- 

**Masalah ditemukan**:
- 

**Keputusan yang diambil**:
- 

**Backward compat verified**: ☐ Ya / ☐ Tidak (detail: _)

**Siap lanjut ke Phase 3**: ☐ Ya / ☐ Tidak (alasan: _)
