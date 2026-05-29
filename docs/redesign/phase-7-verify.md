# Phase 7 — Final Verification

> **Status**: 🔴 Belum dimulai  
> **Prasyarat**: Phase 6 selesai + review ditulis  
> **Prinsip**: Ini bukan coding phase. Hanya run, observe, dan document. Tidak ada perubahan kode kecuali bug fix kritis.

---

## Tasks

### 7a — Static analysis

- [ ] Jalankan `flutter analyze`
- [ ] Verifikasi **0 errors**
- [ ] Catat semua warnings/infos yang tersisa (expected dari file yang tidak disentuh)

```
Output flutter analyze:
(paste di sini)
```

### 7b — Build test

- [ ] `flutter pub get` → no error
- [ ] `flutter build apk --debug` → berhasil
- [ ] Verifikasi `.env` masih ada (requirement dari G2 SYSTEM_MAP)

### 7c — Smoke test 12 scenario (dari Phase 4)

Jalankan `flutter run` di Android device/emulator, test semua scenario:

- [ ] **S1** — Splash muncul 1.5s → redirect ke ItineraryList
- [ ] **S2** — List kosong → empty state SVG + "Buat itinerary pertama" button muncul
- [ ] **S3** — FAB "Trip baru" → bottom sheet muncul dengan thumbnail slot + title field → input title → "Selanjutnya" → push SelectDate
- [ ] **S4** — SelectDate → pilih range 5 hari → "Susun sendiri" → push AddDays (kosong, 5 day chips)
- [ ] **S5** — AddDays → day chips clickable (D1..D5) → tap "Tambah aktivitas" → push AddActivities
- [ ] **S6** — AddActivities → isi nama + waktu + lokasi (toggle peta/ketik) + deskripsi → Simpan → kembali ke AddDays → activity muncul di timeline
- [ ] **S7** — AddDays Simpan → pop ke list → card muncul dengan gradient placeholder (thumbnail tidak dipilih)
- [ ] **S8** — Buat itinerary ke-2 WITH thumbnail → card muncul dengan foto header
- [ ] **S9** — Delete card → IterasiConfirmDialog muncul → confirm → card dihapus
- [ ] **S10** — SelectDate 3 hari → "Minta AI" → FormSuggestion → submit → loading state ocean-deep → SuggestionPage TabBar → "Pilih versi ini" → AddDays dengan AI activities
- [ ] **S11** — AddDays activity card → photo icon → permission OK → PhotoPage grid → tambah foto dari galeri → kembali → foto tersimpan
- [ ] **S12** — AddDays "Bagikan PDF" → PdfPreviewPage muncul → OS share sheet muncul

### 7d — Thumbnail-specific tests

- [ ] **T1** — Buat itinerary tanpa thumbnail → gradient fallback muncul, konsisten (reload tidak berubah warna)
- [ ] **T2** — Buat itinerary dengan thumbnail → foto muncul di card header
- [ ] **T3** — Edit thumbnail di AddDays (kamera icon di header) → pilih foto baru → kembali ke list → card update dengan foto baru
- [ ] **T4** — Buat 5 itinerary berbeda-beda judul tanpa thumbnail → verifikasi 5 warna gradient berbeda (hashCode % 5)

### 7e — Backward compatibility test

- [ ] Test dengan itinerary yang dibuat SEBELUM Phase 2 (jika ada di device):
  - Load → tidak crash
  - thumbnailPath == null → gradient fallback aktif
  - Edit dan save → tidak kehilangan data existing

### 7f — Hot reload stability

- [ ] Hot reload di setiap screen → tidak ada "setState after dispose" atau rebuild crash
- [ ] Rotate (opsional — app dikunci portrait, tapi test tetap) → tidak crash

### 7g — Visual diff vs design reference

Buka `trip-planner-design.html` di browser, bandingkan side-by-side dengan app:

- [ ] **Screen 01 Splash** — palette ocean-deep ✓, wordmark ✓, tagline ✓
- [ ] **Screen 02 Itinerary List** — paper bg ✓, greeting ✓, card photo header ✓, gradient fallback ✓, FAB pill ✓
- [ ] **Screen 03 Select Date** — calendar ocean900 selection ✓, fork buttons ✓, warning chip (jika > 3 hari) ✓
- [ ] **Screen 04 Form Suggestion** — form restyled ✓, loading ocean-deep ✓
- [ ] **Screen 05 Suggestion Page** — TabBar coral indicator ✓, gradient header ✓, "Pilih versi ini" coral ✓
- [ ] **Screen 06 Add Days** — day chips ✓, big day header ✓, timeline ✓, bottom action bar ✓
- [ ] **Screen 07 Add Activities** — time picker restyled ✓, segmented toggle ✓, notes sand-bg ✓
- [ ] **Screen 08 Activity Photo** — header ✓, grid ✓, bottom action bar ✓
- [ ] **Screen 09 Map Picker** — N/A (ditunda scope)
- [ ] **Screen 10 PDF Preview** — AppBar restyled ✓
- [ ] **Screen 11 Delete Dialog** — IterasiConfirmDialog ✓

### 7h — Catat gap visual untuk polish berikutnya

Isi tabel ini dengan ketidakcocokan kecil yang ditemukan (tidak blocking — untuk iterasi selanjutnya):

| Screen | Gap | Prioritas |
|---|---|---|
| | | |
| | | |

---

## Final Checklist

- [ ] `flutter analyze` → 0 errors
- [ ] `flutter build apk --debug` → success
- [ ] Semua 12 smoke scenarios ✓
- [ ] Thumbnail T1–T4 ✓
- [ ] Backward compat ✓
- [ ] Visual diff documented
- [ ] `docs/SYSTEM_MAP.md` mencerminkan realita
- [ ] `CLAUDE.md` up to date
- [ ] `docs/redesign/README.md` progress table di-update ke semua ✅

---

## Post-Phase Review (Redesign Complete)

**Tanggal selesai**: _

**Total waktu implementasi**: _

**Screen yang paling dekat dengan design**: _

**Screen yang punya gap terbesar**: _

**Deferred items (untuk sprint berikutnya)**:
1. Full-screen map picker (Screen 09)
2. Multi-select foto
3. Filter status chips (Semua / Datang / Akan datang / Arsip)
4. Drum-roll time picker
5. Thumbnail orphan file cleanup saat deleteItinerary (R7)
6. Greeting personal (nama user / auth)

**Keputusan arsitektur yang dibuat selama redesign**:
- 

**Hal yang tidak terduga**:
- 

**Redesign selesai**: ☐ Ya
