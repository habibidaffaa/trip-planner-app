# Phase 6 — Documentation Update

> **Status**: 🔴 Belum dimulai  
> **Prasyarat**: Phase 5 selesai + review ditulis  
> **Prinsip**: Docs harus mencerminkan realita kode setelah redesign. Baca file terlebih dulu sebelum edit — jangan assume.

---

## Tasks

### 6a — `docs/SYSTEM_MAP.md`

- [ ] **§1 Tech Stack** — update baris Font:
  - Lama: `Inter via google_fonts`
  - Baru: `Instrument Serif (display) / DM Sans (body) / DM Mono (utility) via google_fonts`

- [ ] **§3 Clean Tree** — hapus dari tree:
  ```
  lib/navigation/bottom_navbar.dart    ← hapus baris
  lib/navigation/side_navbar.dart      ← hapus baris
  lib/pages/add_activities/suggestion_itinerary.dart  ← hapus baris
  lib/pages/user_review_page.dart      ← hapus baris
  lib/widget/itinerary_tile.dart       ← hapus baris
  ```
  Tambah file baru:
  ```
  lib/model/create_itinerary_result.dart  ← tambah
  lib/utilities/thumbnail_storage.dart    ← tambah
  lib/widget/iterasi_text.dart            ← tambah
  lib/widget/iterasi_chip.dart            ← tambah
  ```

- [ ] **§4 Module Map** — hapus row:
  - `BottomNavbar` dari Presentation Layer table
  - `SideNavbar` dari Presentation Layer table
  - `SuggestionItinerary` dari Presentation Layer table
  - `UserReviewPage` dari Presentation Layer table
  - `ItineraryTile` dari widget table
  
  Tambah row baru ke widget table:
  - `lib/widget/iterasi_text.dart` | `IterasiDisplay, IterasiBody, IterasiMono, IterasiKicker` | Typography helpers
  - `lib/widget/iterasi_chip.dart` | `IterasiChip` | Filled/outline pill chips
  
  Update row ItineraryList:
  - Tambah catatan: "Tidak lagi dibungkus BottomNavbar — langsung jadi home screen"

- [ ] **§5 State Management Map** — update ItineraryProvider state class:
  ```
  State: _itinerary (Itinerary aktif), initialItinerary (snapshot awal)
  ```
  Tambah method baru: `setThumbnail(String? path)`

- [ ] **§6 Navigation** — update Named Routes:
  - `"/"` sekarang → `SplashScreen` (tidak berubah)
  - `ItineraryList.route` → `ItineraryList` **langsung** (tidak via BottomNavbar)
  - Hapus catatan tentang BottomNavbar shell
  - Update Routing section: tidak ada tab navigation lagi

- [ ] **§7 Data & Config** — update Model Serialisasi:
  ```
  Itinerary {id, title, dateModified, thumbnailPath?, days[]}
  ```
  Tambah note: `thumbnailPath` disimpan di JSON blob `data` column sebagai key `thumbnail_path`. Null untuk rows existing.

- [ ] **§10 Risks** — update:
  - Hapus **R5** (suggestion_itinerary.dart legacy — sudah dihapus di Phase 4)
  - Tambah **R7**:
    ```
    | R7 | Thumbnail orphan files | lib/utilities/thumbnail_storage.dart + deleteItinerary flow |
    | Thumbnail .jpg di `<docDir>/thumbnails/` tidak ikut terhapus saat deleteItinerary() dipanggil |
    | Disk leak minor — accepted untuk v1, cleanup di iterasi berikutnya |
    ```

### 6b — `CLAUDE.md`

- [ ] **Theming & Sizing section** — update:
  - Font baris: ganti `Inter via google_fonts` → `DM Sans (body), Instrument Serif (display), DM Mono (utility) via google_fonts`
  - CustomColor baris: tambah nama token baru: `ocean50..950`, `coral200..800`, `sand100..700`, `paper`, `muted`, `ink`
  - Radius baris: ganti dari "fieldRadius(0px), largeRadius(16px), pillRadius(100px)" → "12 (field/card), 18 (modal/dialog), 999 (pill/button)"
  - Contoh kode: update `CustomColor.brandElectric` → `CustomColor.coral500` dan `CustomColor.boardroomNavy` → `CustomColor.ocean900`

- [ ] **Navigation Rules section** — tambah:
  - "App adalah single-tab — tidak ada BottomNavbar. ItineraryList adalah home langsung via `pushReplacementNamed(ItineraryList.route)` dari SplashScreen."

- [ ] **Framework Conventions → Folder Structure** — update:
  - Hapus `navigation/` dari deskripsi (folder masih ada tapi kosong atau hapus)
  - Tambah `lib/model/create_itinerary_result.dart`

- [ ] **Closing criteria** — tambah/update:
  - "thumbnailPath disimpan dalam JSON blob, tidak ada kolom DB tambahan"
  - "BottomNavbar tidak ada — tidak perlu re-introduce tab navigation"

### 6c — Hapus `DESIGN.md` (opsional)

- [ ] Cek isi `DESIGN.md` — jika sudah tidak relevan atau superseded oleh `trip-planner-design.html`, bisa didelete atau archive
- [ ] Keputusan: ☐ Hapus / ☐ Pertahankan / ☐ Archive

---

## Verifikasi

- [ ] `docs/SYSTEM_MAP.md` dibaca ulang — tidak ada referensi ke file yang sudah dihapus
- [ ] `CLAUDE.md` dibaca ulang — token names dan font names sudah benar
- [ ] Tree di SYSTEM_MAP mencerminkan `ls lib/` aktual

---

## Post-Phase Review

> Isi setelah semua task di atas selesai. Wajib sebelum Phase 7 (final verification).

**Tanggal selesai**: _

**Yang diupdate**:
- 

**Inkonsistensi yang ditemukan**:
- 

**DESIGN.md decision**:
- 

**Siap lanjut ke Phase 7**: ☐ Ya / ☐ Tidak (alasan: _)
