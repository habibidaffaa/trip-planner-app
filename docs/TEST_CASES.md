# TEST CASES — Trip Planner App

> Manual test case document untuk QA/testing.
> **Package:** `iterasi1` | **Versi:** 1.0.0+1
> **Dibuat:** 2026-06-18

---

## Daftar Isi

1. [Splash Screen & Navigasi Awal](#1-splash-screen--navigasi-awal)
2. [Flow A — Membuat Itinerary Manual](#2-flow-a--membuat-itinerary-manual)
3. [Flow B — Rekomendasi Itinerary via AI](#3-flow-b--rekomendasi-itinerary-via-ai)
4. [Flow C — Manajemen Foto Aktivitas](#4-flow-c--manajemen-foto-aktivitas)
5. [Flow D — Export PDF](#5-flow-d--export-pdf)
6. [Itinerary List — Search, Edit, Delete](#6-itinerary-list--search-edit-delete)
7. [Edge Cases & Boundary Testing](#7-edge-cases--boundary-testing)

---

## Konvensi Penulisan

| Kolom | Keterangan |
|---|---|
| **ID** | Format: `[Tipe]-[Flow]-[Nomor]`. Tipe: `P` (Positive), `N` (Negative), `E` (Edge). Flow: `SPLASH`, `A`, `B`, `C`, `D`, `LIST` |
| **Nama** | Judul singkat test case |
| **Precondition** | Kondisi yang harus terpenuhi sebelum eksekusi |
| **Steps** | Langkah-langkah detail dengan nama elemen UI eksplisit |
| **Expected Result** | Hasil yang diharapkan |
| **Priority** | High / Medium / Low |

---

## 1. Splash Screen & Navigasi Awal

### POSITIVE TESTING

| Item | Detail |
|---|---|
| **ID** | P-SPLASH-01 |
| **Nama** | Splash screen tampil dan redirect otomatis ke ItineraryList |
| **Precondition** | App baru di-launch, belum ada data itinerary |
| **Steps** | 1. Buka aplikasi dari launcher device |
| | 2. Perhatikan layar splash screen muncul dengan logo "Trip Planner" dan teks "est. 2024 · indonesia" |
| | 3. Tunggu ±1.5 detik tanpa interaksi apapun |
| **Expected Result** | Splash screen tampil dengan elemen visual (logo compass, teks "Trip Planner.", garis shoreline di bawah). Setelah 1.5 detik, otomatis navigasi ke halaman `ItineraryList`. Jika belum ada itinerary, tampil empty state "Mulai dari mana?" dengan tombol "Buat itinerary pertama" |
| **Priority** | High |

---

## 2. Flow A — Membuat Itinerary Manual

### POSITIVE TESTING

| Item | Detail |
|---|---|
| **ID** | P-A-01 |
| **Nama** | Buat itinerary baru dari empty state |
| **Precondition** | Halaman `ItineraryList` tampil dengan empty state (belum ada itinerary tersimpan) |
| **Steps** | 1. Tap tombol **"Buat itinerary pertama"** (button full-width di empty state) |
| | 2. Bottom sheet **"Buat Itinerary Baru"** muncul |
| | 3. Tap field text **"Masukan Nama Trip Anda"** |
| | 4. Ketik: **"Trip Bali"** (maks 25 karakter) |
| | 5. (Opsional) Tap area **"Tambah foto cover (opsional)"** untuk pilih gambar thumbnail dari galeri |
| | 6. Tap tombol **"Selanjutnya"** |
| **Expected Result** | Bottom sheet tertutup. Navigasi ke halaman `SelectDate` dengan header "step 1 of 3", kalender muncul, dan teks hero "Kapan kamu berangkat?". `ItineraryProvider.initItinerary()` terpanggil dengan judul "Trip Bali" |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-A-02 |
| **Nama** | Buat itinerary baru dari FAB "Trip baru" |
| **Precondition** | Sudah ada minimal 1 itinerary tersimpan di `ItineraryList` |
| **Steps** | 1. Di halaman `ItineraryList`, tap FAB **"Trip baru"** (button dengan ikon "+" di pojok kanan bawah) |
| | 2. Bottom sheet **"Buat Itinerary Baru"** muncul |
| | 3. Ketik judul **"Trip Yogya"** di field **"Masukan Nama Trip Anda"** |
| | 4. Tap tombol **"Selanjutnya"** |
| **Expected Result** | Navigasi ke `SelectDate`. FAB hanya muncul jika ada itinerary tersimpan (jika kosong, FAB tersembunyi dan empty state menampilkan tombol alternatif) |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-A-03 |
| **Nama** | Pilih 1 tanggal (single day) di SelectDate |
| **Precondition** | Berada di halaman `SelectDate`, itinerary baru |
| **Steps** | 1. Di kalender `SfDateRangePicker`, tap tanggal hari ini atau tanggal setelahnya (misal: 20 Jun 2026) |
| | 2. Perhatikan area "berangkat" dan "pulang" di bawah kalender terisi |
| | 3. Perhatikan teks "1 hari · 0 malam" muncul |
| | 4. Tap tombol **"Susun sendiri"** (button outlined di kiri bawah) |
| **Expected Result** | Navigasi ke halaman `AddDays` dengan 1 day tab (D1). Header menampilkan "Hari 1" dan tanggal yang dipilih. Area aktivitas menampilkan empty state "Belum ada aktivitas" |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-A-04 |
| **Nama** | Pilih rentang tanggal multi hari di SelectDate |
| **Precondition** | Berada di halaman `SelectDate` |
| **Steps** | 1. Di kalender, tap tanggal awal (misal: 20 Jun 2026) |
| | 2. Tap tanggal akhir (misal: 23 Jun 2026) |
| | 3. Perhatikan area "berangkat" menampilkan "20 Jun", "pulang" menampilkan "23 Jun" |
| | 4. Perhatikan teks "4 hari · 3 malam" |
| | 5. Tap tombol **"Susun sendiri"** |
| **Expected Result** | Navigasi ke `AddDays` dengan 4 day tab (D1–D4). Day chips bisa di-scroll horizontal. Day tab D1 aktif secara default. Setiap tab menampilkan label hari (misal "D1 Sen", "D2 Sel", dst) |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-A-05 |
| **Nama** | Tambah aktivitas baru dengan data lengkap |
| **Precondition** | Berada di `AddDays`, day tab D1 aktif, belum ada aktivitas |
| **Steps** | 1. Tap tombol **"Tambah aktivitas"** (button full-width di bottom bar) |
| | 2. Di halaman `AddActivities`, tap field **"Judul"** (hint: "Cth. Persiapan Berangkat") |
| | 3. Ketik: **"Kunjungi Pantai Kuta"** |
| | 4. Tap field lokasi (hint: autocomplete field) |
| | 5. Ketik: **"Pantai Kuta"** → tunggu suggestion muncul dari Google Places |
| | 6. Tap salah satu suggestion dari dropdown |
| | 7. Tap tombol waktu **"Mulai"** (format 24H) → time picker muncul → set **08.00** → tap OK |
| | 8. Tap tombol waktu **"Selesai"** → time picker muncul → set **10.00** → tap OK |
| | 9. Tap field **"Keterangan"** (hint: "Cth. Pastikan semua barang tidak ada yang tertinggal") |
| | 10. Ketik: **"Bawa sunblock dan handuk"** |
| | 11. Tap tombol **"Simpan"** (pill button di pojok kanan atas header) |
| **Expected Result** | Kembali ke `AddDays`. `ActivityCard` muncul di D1 dengan data: waktu "08.00", judul "Kunjungi Pantai Kuta", lokasi "Pantai Kuta, Bali", durasi "120 min · 10.00". Activities di-sort berdasarkan waktu mulai. Timeline dot pertama berwarna coral (isFirst) |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-A-06 |
| **Nama** | Tambah aktivitas menggunakan quick time chip |
| **Precondition** | Berada di `AddActivities` |
| **Steps** | 1. Tap chip waktu **"08.00"** (quick time chips di bawah time picker) |
| | 2. Perhatikan waktu "Mulai" berubah ke 08.00 |
| | 3. Tap tombol waktu **"Selesai"** → set **10.00** |
| | 4. Isi field **"Judul"**: **"Sarapan di hotel"** |
| | 5. Isi field lokasi: **"Hotel Kuta"** (pilih dari autocomplete) |
| | 6. Tap tombol **"Simpan"** |
| **Expected Result** | Aktivitas tersimpan dengan waktu mulai 08.00 dan selesai 10.00. Quick time chips tersedia: 06.00, 08.00, 12.00, 19.30 |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | P-A-07 |
| **Nama** | Edit aktivitas yang sudah ada |
| **Precondition** | Sudah ada minimal 1 aktivitas di `AddDays` |
| **Steps** | 1. Tap salah satu `ActivityCard` untuk membuka dialog detail |
| | 2. Di dialog **"DETAIL AKTIVITAS"**, tap tombol **"Edit Aktivitas"** (button coral di bawah dialog) |
| | 3. Di halaman `AddActivities`, ubah field **"Judul"** menjadi **"Pantai Seminyak"** |
| | 4. Ubah waktu **"Mulai"** menjadi **09.00** |
| | 5. Tap tombol **"Simpan"** |
| **Expected Result** | Kembali ke `AddDays`. `ActivityCard` menampilkan data yang sudah diubah: judul "Pantai Seminyak", waktu "09.00". Data lain (lokasi, keterangan) tetap sama |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-A-08 |
| **Nama** | Hapus aktivitas via ikon delete dan konfirmasi dialog |
| **Precondition** | Sudah ada minimal 1 aktivitas |
| **Steps** | 1. Tap ikon **delete** (ikon tempat sampah di pojok kanan atas `ActivityCard`) ATAU long-press `ActivityCard` |
| | 2. Dialog konfirmasi **"Hapus aktivitas?"** muncul dengan pesan "Aktivitas [nama] akan dihapus dari hari ini." |
| | 3. Tap tombol **"Hapus"** |
| **Expected Result** | `ActivityCard` dihapus dari list. Jika long-press, snackbar dengan tombol **"Undo"** muncul. Jika via dialog, aktivitas langsung dihapus |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-A-09 |
| **Nama** | Switch antar day tab |
| **Precondition** | Itinerary dengan 3 hari, masing-masing punya aktivitas berbeda |
| **Steps** | 1. Tap day chip **"D2"** di baris horizontal day chips |
| | 2. Perhatikan header berubah: "Hari 2" dengan tanggal sesuai |
| | 3. Tap day chip **"D3"** |
| | 4. Perhatikan aktivitas yang tampil sesuai D3 |
| | 5. Tap day chip **"D1"** |
| **Expected Result** | Day chip yang aktif di-highlight (background biru ocean900, teks putih). Header hari dan label tanggal berubah sesuai tab. Aktivitas yang tampil sesuai dengan hari yang dipilih. Tab yang tidak aktif: background transparan, border ocean900 opacity 0.15 |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-A-10 |
| **Nama** | Simpan itinerary dari AddDays |
| **Precondition** | Sudah ada aktivitas di salah satu hari |
| **Steps** | 1. Tap tombol **"Simpan"** (pill button biru di pojok kanan atas header `AddDays`) |
| **Expected Result** | Loading overlay muncul. Itinerary tersimpan ke SQLite via `DatabaseProvider.insertItinerary()`. Navigasi kembali ke `ItineraryList`. Card itinerary baru muncul di list dengan judul, tanggal, jumlah hari/malam, dan total aktivitas |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-A-11 |
| **Nama** | Back dari AddDays tanpa perubahan — langsung kembali |
| **Precondition** | Berada di `AddDays`, itinerary sudah disimpan atau baru dibuka tanpa perubahan |
| **Steps** | 1. Tap tombol **back** (lingkaran dengan ikon arrow di pojok kiri atas header) |
| **Expected Result** | Langsung kembali ke `ItineraryList` tanpa dialog konfirmasi. Snackbar di-clear |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | P-A-12 |
| **Nama** | Back dari AddDays dengan perubahan — dialog konfirmasi muncul |
| **Precondition** | Berada di `AddDays`, sudah ada perubahan aktivitas (isDataChanged = true) |
| **Steps** | 1. Tap tombol **back** (lingkaran arrow di pojok kiri atas) |
| **Expected Result** | Dialog **"Konfirmasi Perubahan"** muncul dengan ikon warning. Pesan: "Itinerary Anda telah diubah. Simpan sebelum keluar?". 2 tombol: **"Keluar Tanpa Simpan"** (outlined, merah) dan **"Simpan & Keluar"** (filled, biru) |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-A-13 |
| **Nama** | Dialog konfirmasi — pilih "Simpan & Keluar" |
| **Precondition** | Dialog **"Konfirmasi Perubahan"** terbuka |
| **Steps** | 1. Tap tombol **"Simpan & Keluar"** (button filled biru di kanan) |
| **Expected Result** | Itinerary tersimpan ke database. Loading overlay muncul. Navigasi kembali ke `ItineraryList` |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-A-14 |
| **Nama** | Dialog konfirmasi — pilih "Keluar Tanpa Simpan" |
| **Precondition** | Dialog **"Konfirmasi Perubahan"** terbuka |
| **Steps** | 1. Tap tombol **"Keluar Tanpa Simpan"** (button outlined merah di kiri) |
| **Expected Result** | Navigasi kembali ke `ItineraryList` tanpa menyimpan perubahan. Data yang sudah diubah hilang |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-A-15 |
| **Nama** | Edit judul itinerary di AddDays |
| **Precondition** | Berada di halaman `AddDays` |
| **Steps** | 1. Tap pada teks judul itinerary di header (di bawah label tanggal) |
| | 2. Field edit muncul (inline `SearchField`) |
| | 3. Hapus teks lama, ketik **"Trip Bali Updated"** |
| | 4. Tap tombol **"Simpan"** (pill button di header) |
| **Expected Result** | Judul berubah di header. Saat itinerary disimpan, judul baru tersimpan ke database. Jika judul dikosongkan, snackbar "Judul itinerary tidak boleh kosong" muncul |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | P-A-16 |
| **Nama** | Buka Google Maps dari ActivityCard |
| **Precondition** | Ada aktivitas dengan lokasi dari autocomplete (isCustomLocation = false) |
| **Steps** | 1. Tap label **"Lihat di peta"** (chip kecil di bawah nama lokasi pada `ActivityCard`) |
| **Expected Result** | Google Maps terbuka di browser/aplikasi eksternal dengan query nama lokasi. ATAU di dialog detail aktivitas, tap tombol **"Map"** |
| **Priority** | Low |

| Item | Detail |
|---|---|
| **ID** | P-A-17 |
| **Nama** | Buka halaman foto dari dialog detail aktivitas |
| **Precondition** | Ada aktivitas di `AddDays` |
| **Steps** | 1. Tap `ActivityCard` → dialog **"DETAIL AKTIVITAS"** muncul |
| | 2. Tap tombol **"Galeri"** di bagian bawah dialog |
| **Expected Result** | Jika izin galeri sudah diberikan: navigasi ke `ActivityPhotoPage`. Jika belum: dialog permintaan izin muncul |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | P-A-18 |
| **Nama** | Navigasi ke SelectDate dari AddDays (tambah hari) |
| **Precondition** | Berada di `AddDays` dengan itinerary existing |
| **Steps** | 1. Tap tombol **"+"** (lingkaran coral di pojok kanan day chips bar) |
| **Expected Result** | Navigasi ke `SelectDate` dengan mode edit (`isNewItinerary: false`). Kalender menampilkan range tanggal yang sudah ada. Hanya tombol **"Simpan"** yang tampil (bukan "Susun sendiri" / "Minta AI menyusun") |
| **Priority** | Medium |

### NEGATIVE TESTING

| Item | Detail |
|---|---|
| **ID** | N-A-01 |
| **Nama** | Judul itinerary kosong di bottom sheet |
| **Precondition** | Bottom sheet **"Buat Itinerary Baru"** terbuka |
| **Steps** | 1. Biarkan field **"Masukan Nama Trip Anda"** kosong |
| | 2. Perhatikan tombol **"Selanjutnya"** |
| **Expected Result** | Tombol **"Selanjutnya"** disabled (warna biru berubah ke muted/abu-abu). Tidak bisa di-tap. `isEnable` = false karena `value.isNotEmpty` = false |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | N-A-02 |
| **Nama** | Judul itinerary melebihi 25 karakter |
| **Precondition** | Bottom sheet **"Buat Itinerary Baru"** terbuka |
| **Steps** | 1. Ketik judul lebih dari 25 karakter (misal: "Trip Bali yang sangat menyenangkan sekali") |
| **Expected Result** | Input terbatas sampai 25 karakter (maxLength: 25). Karakter setelah 25 tidak ter-input. Teks bantuan "Maksimal 25 karakter" tampil di bawah field |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | N-A-03 |
| **Nama** | Tidak bisa pilih tanggal sebelum hari ini |
| **Precondition** | Berada di halaman `SelectDate` |
| **Steps** | 1. Coba tap tanggal kemarin atau tanggal yang sudah lewat di kalender |
| **Expected Result** | Tanggal yang sudah lewat tidak bisa dipilih (disabled/grayed out). Kalender memiliki `minDate: DateTime.now()` sehingga tanggal sebelum hari ini tidak selectable |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | N-A-04 |
| **Nama** | Lanjut tanpa pilih tanggal — "Susun sendiri" |
| **Precondition** | Berada di `SelectDate`, belum pilih tanggal apapun |
| **Steps** | 1. Tap tombol **"Susun sendiri"** tanpa memilih tanggal |
| **Expected Result** | Snackbar muncul: **"Pilih Tanggal setelah Hari Ini!"**. Tetap di halaman `SelectDate` |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | N-A-05 |
| **Nama** | Lanjut tanpa pilih tanggal — "Minta AI menyusun" |
| **Precondition** | Berada di `SelectDate`, belum pilih tanggal apapun |
| **Steps** | 1. Tap tombol **"Minta AI menyusun"** tanpa memilih tanggal |
| **Expected Result** | Snackbar muncul: **"Pilih Tanggal setelah Hari Ini!"**. Tetap di halaman `SelectDate` |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | N-A-06 |
| **Nama** | Submit aktivitas dengan judul kosong |
| **Precondition** | Berada di `AddActivities` |
| **Steps** | 1. Kosongkan field **"Judul"** |
| | 2. Isi field lain (lokasi, waktu, keterangan) dengan data valid |
| | 3. Perhatikan tombol **"Simpan"** di header |
| **Expected Result** | Tombol **"Simpan"** berubah ke warna muted (abu-abu) dan disabled. Teks validasi **"Judul tidak boleh kosong"** muncul di bawah field judul (warna merah/error). `_isTitleValid` = false |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | N-A-07 |
| **Nama** | Submit aktivitas dengan lokasi kosong |
| **Precondition** | Berada di `AddActivities` |
| **Steps** | 1. Isi field **"Judul"** dengan data valid |
| | 2. Kosongkan field lokasi |
| | 3. Perhatikan tombol **"Simpan"** |
| **Expected Result** | Tombol **"Simpan"** disabled (warna muted). `_isLokasiValid` = false. Form tidak bisa di-submit. Field lokasi menunjukkan border error (warna merah) |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | N-A-08 |
| **Nama** | Waktu selesai sebelum waktu mulai |
| **Precondition** | Berada di `AddActivities` |
| **Steps** | 1. Tap tombol waktu **"Mulai"** → set **14.00** → tap OK |
| | 2. Tap tombol waktu **"Selesai"** → set **10.00** → tap OK |
| **Expected Result** | Error text muncul: **"Waktu Selesai tidak boleh mendahului Waktu Mulai!"** (warna merah). Tombol "Selesai" berubah ke warna merah (danger). Tombol **"Simpan"** disabled. `_isEndTimeValid` = false |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | N-A-09 |
| **Nama** | Edit judul itinerary menjadi kosong di AddDays |
| **Precondition** | Berada di `AddDays`, mode edit judul aktif |
| **Steps** | 1. Tap judul itinerary di header |
| | 2. Hapus semua teks sehingga field kosong |
| | 3. Tap tombol **"Simpan"** (pill button) |
| **Expected Result** | Snackbar muncul: **"Judul itinerary tidak boleh kosong"**. Judul tidak berubah. Tetap di mode edit. `_commitPendingTitleIfAny()` return false |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | N-A-10 |
| **Nama** | Klik tombol Simpan di AddDays tanpa perubahan |
| **Precondition** | Baru buka itinerary dari list, belum ada perubahan |
| **Steps** | 1. Tap tombol **"Simpan"** di header `AddDays` |
| **Expected Result** | Itinerary tetap tersimpan (update dateModified). Tidak ada error. Kembali ke `ItineraryList` |
| **Priority** | Low |

### EDGE TESTING

| Item | Detail |
|---|---|
| **ID** | E-A-01 |
| **Nama** | Simpan itinerary tanpa aktivitas apapun |
| **Precondition** | Buat itinerary baru, pilih tanggal, tapi jangan tambah aktivitas |
| **Steps** | 1. Tap tombol **"Simpan"** di header `AddDays` |
| **Expected Result** | Itinerary tersimpan ke database. Di `ItineraryList`, card menampilkan **"0 aktivitas"**. Tidak crash |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | E-A-02 |
| **Nama** | Itinerary dengan 7+ hari — scroll horizontal day chips |
| **Precondition** | Buat itinerary dengan 7 hari atau lebih |
| **Steps** | 1. Buka `AddDays` |
| | 2. Scroll day chips bar ke kanan (swipe horizontal) |
| | 3. Tap day chip **"D7"** |
| **Expected Result** | Day chips bisa di-scroll horizontal (`BouncingScrollPhysics`). Semua tab (D1–D7) bisa diakses. Tombol "+" tetap visible di pojok kanan |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | E-A-03 |
| **Nama** | Dua aktivitas dengan waktu overlap |
| **Precondition** | Sudah ada aktivitas 08.00–10.00 di D1 |
| **Steps** | 1. Tap **"Tambah aktivitas"** |
| | 2. Isi judul: **"Makan pagi"** |
| | 3. Set waktu mulai: **09.00**, selesai: **11.00** |
| | 4. Isi lokasi dan tap **"Simpan"** |
| **Expected Result** | Aktivitas tetap bisa ditambahkan (tidak ada validasi overlap waktu). Keduanya muncul di list, di-sort berdasarkan waktu mulai. Aktivitas 08.00 tampil duluan, lalu 09.00 |
| **Priority** | Low |

| Item | Detail |
|---|---|
| **ID** | E-A-04 |
| **Nama** | Edit 1 aktivitas tidak mempengaruhi aktivitas lain |
| **Precondition** | Ada 3 aktivitas di D1: A (08.00), B (10.00), C (14.00) |
| **Steps** | 1. Tap `ActivityCard` B → dialog detail muncul |
| | 2. Tap **"Edit Aktivitas"** |
| | 3. Ubah judul B menjadi **"B Edited"** |
| | 4. Tap **"Simpan"** |
| **Expected Result** | Hanya aktivitas B yang berubah. Aktivitas A dan C tetap sama persis (judul, lokasi, waktu tidak berubah) |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | E-A-05 |
| **Nama** | Double tap tombol Simpan dengan cepat |
| **Precondition** | Berada di `AddDays` dengan perubahan |
| **Steps** | 1. Tap tombol **"Simpan"** beberapa kali dengan cepat (double/triple tap) |
| **Expected Result** | Tidak terjadi duplikasi data. Itinerary hanya tersimpan sekali. Tidak crash. Loading overlay mencegah interaksi ganda |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | E-A-06 |
| **Nama** | Tambah tanggal baru ke itinerary yang sudah disimpan |
| **Precondition** | Buka itinerary existing di `AddDays` |
| **Steps** | 1. Tap tombol **"+"** di day chips bar |
| | 2. Di `SelectDate`, tambahkan 1 tanggal baru di akhir range |
| | 3. Tap tombol **"Simpan"** |
| | 4. Kembali ke `AddDays` |
| **Expected Result** | Day tab baru ditambahkan. Data hari yang sudah ada (aktivitas, foto) tetap utuh. Hari baru kosong |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | E-A-07 |
| **Nama** | Hapus tanggal dari itinerary (kurangi range) |
| **Precondition** | Itinerary dengan 5 hari, D5 punya aktivitas |
| **Steps** | 1. Tap tombol **"+"** di day chips bar |
| | 2. Di `SelectDate`, pilih range yang lebih pendek (misal 4 hari, hapus hari ke-5) |
| | 3. Tap **"Simpan"** |
| **Expected Result** | Day tab D5 hilang beserta aktivitas di dalamnya. D1–D4 tetap utuh. `initializeDays()` menghapus hari yang tidak ada di range baru |
| **Priority** | Medium |

---

## 3. Flow B — Rekomendasi Itinerary via AI

### POSITIVE TESTING

| Item | Detail |
|---|---|
| **ID** | P-B-01 |
| **Nama** | Navigasi ke FormSuggestion dari SelectDate |
| **Precondition** | Berada di `SelectDate`, sudah pilih minimal 1 tanggal |
| **Steps** | 1. Tap tombol **"Minta AI menyusun"** (button filled biru di kanan bawah) |
| **Expected Result** | Navigasi ke halaman `FormSuggestion` dengan header "step 2 of 3", teks hero "Ceritakan tripmu.", dan form input kota asal/tujuan |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-B-02 |
| **Nama** | Autocomplete kota asal via Google Places |
| **Precondition** | Berada di `FormSuggestion` |
| **Steps** | 1. Tap field **"Masukkan kota asal"** (dengan ikon location_on_outlined) |
| | 2. Ketik: **"Surabaya"** |
| | 3. Tunggu ±1 detik, dropdown suggestion muncul |
| | 4. Tap salah satu suggestion (misal "Surabaya, Jawa Timur, Indonesia") |
| **Expected Result** | Field terisi dengan nama tempat lengkap dari Google Places. Suffix icon **clear (X)** muncul di field. Country filter: Indonesia (`components=country:id`) |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-B-03 |
| **Nama** | Autocomplete kota tujuan via Google Places |
| **Precondition** | Berada di `FormSuggestion` |
| **Steps** | 1. Tap field **"Masukkan kota tujuan"** (dengan ikon flag_outlined) |
| | 2. Ketik: **"Bali"** |
| | 3. Tunggu suggestion muncul |
| | 4. Tap suggestion **"Bali, Indonesia"** |
| **Expected Result** | Field terisi. Suffix icon clear muncul |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-B-04 |
| **Nama** | Pilih trip type (vibes) — maksimal 2 |
| **Precondition** | Berada di `FormSuggestion` |
| **Steps** | 1. Di section **"TRIP SEPERTI APA?"**, tap chip **"Healing 🌿"** |
| | 2. Perhatikan chip berubah ke style coral (filled) |
| | 3. Tap chip **"Kuliner 🍜"** |
| | 4. Perhatikan kedua chip berubah ke style coral |
| **Expected Result** | 2 chip terpilih dengan style coral (filled). Keterangan "Pilih maks. 2" tampil di bawah. Kedua vibe dikirim ke prompt AI |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | P-B-05 |
| **Nama** | Pilih gaya perjalanan (pace) |
| **Precondition** | Berada di `FormSuggestion` |
| **Steps** | 1. Di section **"GAYA PERJALANAN"**, tap chip **"Santai"** |
| **Expected Result** | Chip "Santai" berubah ke style coral (selected). Opsi lain: "Balanced", "Padat". Single-select: tap chip yang sama untuk deselect |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | P-B-06 |
| **Nama** | Pilih teman perjalanan (companions) |
| **Precondition** | Berada di `FormSuggestion` |
| **Steps** | 1. Di section **"PERGI DENGAN SIAPA"**, tap chip **"Keluarga"** |
| **Expected Result** | Chip "Keluarga" terpilih (coral). Opsi: "Solo", "Couple", "Teman", "Keluarga", "Anak kecil" |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | P-B-07 |
| **Nama** | Isi catatan tambahan |
| **Precondition** | Berada di `FormSuggestion` |
| **Steps** | 1. Di section **"CATATAN TAMBAHAN"**, tap field (hint: "Preferensi khusus, pantangan, atau hal yang ingin kamu hindari...") |
| | 2. Ketik: **"Saya vegetarian, hindari makanan laut"** |
| **Expected Result** | Teks terisi di field. Catatan dikirim ke prompt AI |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | P-B-08 |
| **Nama** | Generate itinerary AI — trip ≤3 hari (normal) |
| **Precondition** | `FormSuggestion` terisi: asal "Surabaya", tujuan "Bali", 3 tanggal dipilih |
| **Steps** | 1. Tap tombol **"Generate itinerary"** (button biru full-width dengan ikon auto_awesome di bawah) |
| | 2. Loading overlay muncul |
| | 3. Tunggu hingga selesai (bisa 10–30 detik) |
| **Expected Result** | Loading overlay hilang. Navigasi ke `SuggestionPage` dengan 2 tab: **"Rekomendasi A"** dan **"Rekomendasi B"**. Setiap tab menampilkan 3 hari dengan aktivitas lengkap (judul, lokasi, waktu, keterangan) |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-B-09 |
| **Nama** | Generate itinerary AI — trip >3 hari (partial) |
| **Precondition** | `FormSuggestion` terisi, 5 tanggal dipilih |
| **Steps** | 1. Tap **"Generate itinerary"** |
| | 2. Tunggu selesai |
| | 3. Di `SuggestionPage`, tap tombol **"Pilih"** pada salah satu rekomendasi |
| **Expected Result** | AI hanya generate 3 hari pertama. Setelah pilih, `AddDays` menampilkan: D1–D3 terisi aktivitas AI, D4–D5 kosong (empty state "Belum ada aktivitas"). Hari terakhir AI TIDAK ada aktivitas pulang ke kota asal |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-B-10 |
| **Nama** | Tab switching di SuggestionPage |
| **Precondition** | Berada di `SuggestionPage` dengan 2 rekomendasi |
| **Steps** | 1. Tap tab **"Rekomendasi B"** di TabBar |
| | 2. Perhatikan konten berubah |
| | 3. Tap tab **"Rekomendasi A"** |
| **Expected Result** | Konten berubah sesuai tab. Tab indicator berpindah. Header tetap menampilkan "step 2 of 3" |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | P-B-11 |
| **Nama** | Pilih rekomendasi dan lanjut ke AddDays |
| **Precondition** | Berada di `SuggestionPage` |
| **Steps** | 1. Review rekomendasi A (scroll untuk lihat semua aktivitas) |
| | 2. Tap tombol **"Pilih"** pada rekomendasi A |
| **Expected Result** | Navigasi ke `AddDays`. Aktivitas dari rekomendasi A ter-load ke itinerary. `ItineraryProvider.addDay()` dipanggil per hari |
| **Priority** | High |

### NEGATIVE TESTING

| Item | Detail |
|---|---|
| **ID** | N-B-01 |
| **Nama** | Generate tanpa isi kota asal |
| **Precondition** | Berada di `FormSuggestion`, field "Masukkan kota asal" kosong |
| **Steps** | 1. Isi field **"Masukkan kota tujuan"** dengan "Bali" |
| | 2. Perhatikan tombol **"Generate itinerary"** |
| **Expected Result** | Tombol **"Generate itinerary"** disabled (warna muted). `isFormValid` = false karena `_departureController.text.isEmpty` |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | N-B-02 |
| **Nama** | Generate tanpa isi kota tujuan |
| **Precondition** | Berada di `FormSuggestion`, field "Masukkan kota tujuan" kosong |
| **Steps** | 1. Isi field **"Masukkan kota asal"** dengan "Surabaya" |
| | 2. Perhatikan tombol **"Generate itinerary"** |
| **Expected Result** | Tombol disabled. Tidak bisa generate tanpa kota tujuan |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | N-B-03 |
| **Nama** | Destinasi di luar Indonesia |
| **Precondition** | Berada di `FormSuggestion` |
| **Steps** | 1. Isi kota asal: **"Surabaya"** |
| | 2. Isi kota tujuan: **"Tokyo, Japan"** (pilih dari autocomplete) |
| | 3. Pilih tanggal di `SelectDate` sebelumnya |
| | 4. Tap **"Generate itinerary"** |
| | 5. Tunggu response |
| **Expected Result** | Dialog muncul: **"Destinasi di luar Indonesia"** dengan pesan "Trip Planner saat ini hanya mendukung destinasi wisata di Indonesia. Pilih kota tujuan yang ada di Indonesia." dan tombol **"Mengerti"**. Tidak navigasi ke `SuggestionPage` |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | N-B-04 |
| **Nama** | API key tidak valid / network error |
| **Precondition** | `GPT_KEY` tidak valid di `.env` ATAU tidak ada koneksi internet |
| **Steps** | 1. Isi form dengan benar (asal, tujuan, tanggal) |
| | 2. Tap **"Generate itinerary"** |
| | 3. Tunggu response |
| **Expected Result** | Snackbar error muncul: **"Something went wrong, try again later"**. Loading overlay hilang. Tidak crash. Tetap di `FormSuggestion` |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | N-B-05 |
| **Nama** | Google Places autocomplete — query kosong |
| **Precondition** | Berada di `FormSuggestion` |
| **Steps** | 1. Tap field **"Masukkan kota asal"** |
| | 2. Kosongkan field (jangan ketik apapun) |
| **Expected Result** | Tidak ada suggestion yang muncul. `_getSuggestions("")` return empty list |
| **Priority** | Low |

| Item | Detail |
|---|---|
| **ID** | N-B-06 |
| **Nama** | Google Places autocomplete — query tidak valid |
| **Precondition** | Berada di `FormSuggestion` |
| **Steps** | 1. Tap field **"Masukkan kota asal"** |
| | 2. Ketik: **"asdfghjkl"** (random string) |
| **Expected Result** | Tidak ada suggestion muncul ATAU dropdown kosong. Tidak crash |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | N-B-07 |
| **Nama** | Pilih lebih dari 2 vibes — chip ke-3 ditolak |
| **Precondition** | Berada di `FormSuggestion`, sudah pilih 2 vibes |
| **Steps** | 1. Tap chip **"Healing 🌿"** (selected) |
| | 2. Tap chip **"Kuliner 🍜"** (selected) |
| | 3. Tap chip **"Adventure ⛰️"** (3rd selection) |
| **Expected Result** | Chip "Adventure" tidak ter-select. Hanya 2 chip yang aktif. `_selectedVibes.length < 2` check mencegah selection ke-3 |
| **Priority** | Medium |

### EDGE TESTING

| Item | Detail |
|---|---|
| **ID** | E-B-01 |
| **Nama** | Trip tepat 3 hari — AI generate semua hari, returnToOrigin = true |
| **Precondition** | `FormSuggestion` terisi, tepat 3 tanggal dipilih |
| **Steps** | 1. Tap **"Generate itinerary"** |
| | 2. Tunggu selesai |
| **Expected Result** | AI generate 3 hari lengkap. Hari terakhir ada aktivitas pulang ke kota asal (`returnToOrigin = true`). Tidak ada warning chip "AI hanya menyusun 3 hari pertama" |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | E-B-02 |
| **Nama** | Trip 4 hari — AI generate 3 hari pertama, D4 kosong |
| **Precondition** | `FormSuggestion` terisi, 4 tanggal dipilih |
| **Steps** | 1. Perhatikan warning chip di `SelectDate`: "AI hanya menyusun 3 hari pertama..." |
| | 2. Tap **"Generate itinerary"** |
| | 3. Pilih rekomendasi |
| **Expected Result** | `isPartialTrip = true`. AI hanya generate 3 hari. `SuggestionPage` menampilkan 3 hari. Setelah pilih, `AddDays` menampilkan D1–D3 terisi, D4 kosong. Hari ke-3 TIDAK ada aktivitas pulang (`returnToOrigin = false`) |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | E-B-03 |
| **Nama** | Deselect chip vibe yang sudah dipilih |
| **Precondition** | Berada di `FormSuggestion`, sudah pilih 1 vibe |
| **Steps** | 1. Tap chip **"Healing 🌿"** (selected) |
| | 2. Tap lagi chip **"Healing 🌿"** yang sama |
| **Expected Result** | Chip kembali ke style outline (deselected). `_selectedVibes` kosong |
| **Priority** | Low |

| Item | Detail |
|---|---|
| **ID** | E-B-04 |
| **Nama** | Deselect pace/companion yang sudah dipilih |
| **Precondition** | Berada di `FormSuggestion`, sudah pilih pace "Santai" |
| **Steps** | 1. Tap chip **"Santai"** yang sudah selected |
| **Expected Result** | Chip kembali ke style outline. `_selectedPace` = null. Pace tidak dikirim ke prompt AI |
| **Priority** | Low |

| Item | Detail |
|---|---|
| **ID** | E-B-05 |
| **Nama** | Clear field autocomplete dengan suffix icon X |
| **Precondition** | Berada di `FormSuggestion`, field kota asal sudah terisi |
| **Steps** | 1. Tap ikon **clear (X)** di suffix field "Masukkan kota asal" |
| **Expected Result** | Field ter-kosongkan. Suffix icon X hilang. Tombol "Generate itinerary" menjadi disabled (karena form tidak valid) |
| **Priority** | Low |

| Item | Detail |
|---|---|
| **ID** | E-B-06 |
| **Nama** | Back dari SuggestionPage ke FormSuggestion |
| **Precondition** | Berada di `SuggestionPage` |
| **Steps** | 1. Tap tombol **back** (lingkaran arrow di pojok kiri atas) |
| **Expected Result** | Kembali ke `FormSuggestion`. Data form (asal, tujuan, vibes, pace, companions, notes) tetap terisi. Bisa generate ulang tanpa input ulang |
| **Priority** | Medium |

---

## 4. Flow C — Manajemen Foto Aktivitas

### POSITIVE TESTING

| Item | Detail |
|---|---|
| **ID** | P-C-01 |
| **Nama** | Buka halaman foto aktivitas (izin sudah diberikan) |
| **Precondition** | Izin galeri sudah diberikan. Ada aktivitas di `AddDays` |
| **Steps** | 1. Tap `ActivityCard` → dialog **"DETAIL AKTIVITAS"** muncul |
| | 2. Tap tombol **"Galeri"** di bagian bawah dialog |
| **Expected Result** | Navigasi ke `ActivityPhotoPage`. Halaman menampilkan foto yang sudah ada (jika ada) dan grid foto kosong (jika belum ada foto) |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-C-02 |
| **Nama** | Ambil foto dari kamera |
| **Precondition** | Berada di `ActivityPhotoPage` |
| **Steps** | 1. Tap ikon **kamera** (camera_alt) |
| | 2. Kamera device terbuka |
| | 3. Ambil foto |
| | 4. Konfirmasi foto (tap OK/Use Photo) |
| **Expected Result** | Foto tersimpan ke album **"Trip Planner"** di `/storage/emulated/0/Pictures/Trip Planner/` dengan nama `TP_YYYYMMDD_HHmmss.ext`. Thumbnail foto muncul di grid `ActivityPhotoPage`. Path foto ditambahkan ke `Activity.images`. Media scanner dipanggil via platform channel `trip_planner/media_scanner` |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-C-03 |
| **Nama** | Pilih foto dari galeri manual |
| **Precondition** | Berada di `ActivityPhotoPage` |
| **Steps** | 1. Tap ikon **galeri** (perm_media/image) |
| | 2. Galeri device terbuka |
| | 3. Pilih 1 foto |
| **Expected Result** | Foto terpilih muncul di grid `ActivityPhotoPage`. Path foto ditambahkan ke `Activity.images` |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-C-04 |
| **Nama** | Multi-select foto untuk share |
| **Precondition** | Ada minimal 2 foto di `ActivityPhotoPage` |
| **Steps** | 1. Tap lama salah satu foto (long press) untuk masuk mode select |
| | 2. Tap foto lain untuk menambah seleksi |
| | 3. Tap ikon **share** di app bar |
| **Expected Result** | Foto terpilih di-highlight (checkmark). Share sheet OS muncul dengan opsi share ke WhatsApp, Email, dll |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | P-C-05 |
| **Nama** | Hapus foto dari ActivityPhotoPage |
| **Precondition** | Ada foto di `ActivityPhotoPage` |
| **Steps** | 1. Tap lama foto (long press) → mode select aktif |
| | 2. Tap ikon **hapus/delete** di app bar |
| **Expected Result** | Foto dipindahkan ke `removedImages`. Foto hilang dari grid utama. Path foto ditambahkan ke `Activity.removedImages` via `ItineraryProvider.removePhotoActivity()` |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-C-06 |
| **Nama** | Buka ActivityTrashPhotoPage |
| **Precondition** | Sudah menghapus minimal 1 foto |
| **Steps** | 1. Tap ikon **delete/trash** di app bar `ActivityPhotoPage` |
| **Expected Result** | Navigasi ke `ActivityTrashPhotoPage`. Foto yang dihapus tampil di halaman trash |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | P-C-07 |
| **Nama** | Pulihkan foto dari trash |
| **Precondition** | Berada di `ActivityTrashPhotoPage`, ada foto yang dihapus |
| **Steps** | 1. Tap foto yang ingin dipulihkan |
| | 2. Tap tombol **"Pulihkan"** (atau aksi serupa) |
| **Expected Result** | Foto kembali ke `ActivityPhotoPage`. Foto hilang dari trash. `Activity.removedImages` di-remove, `Activity.images` di-add kembali via `ItineraryProvider.returnPhotoActivity()` |
| **Priority** | Medium |

### NEGATIVE TESTING

| Item | Detail |
|---|---|
| **ID** | N-C-01 |
| **Nama** | Izin galeri ditolak — dialog perizinan muncul |
| **Precondition** | Izin galeri belum diberikan atau ditolak di system settings |
| **Steps** | 1. Tap `ActivityCard` → dialog detail muncul |
| | 2. Tap **"Galeri"** |
| | 3. Dialog permintaan izin sistem muncul → tap **"Tolak/Deny"** |
| **Expected Result** | Dialog **"Izin galeri diperlukan"** muncul dengan pesan "Trip Planner membutuhkan akses ke galeri untuk melampirkan foto aktivitas. Buka pengaturan untuk mengizinkan." Tombol: **"Batal"** dan **"Buka Pengaturan"** |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | N-C-02 |
| **Nama** | Izin galeri ditolak — tap "Buka Pengaturan" |
| **Precondition** | Dialog **"Izin galeri diperlukan"** terbuka |
| **Steps** | 1. Tap tombol **"Buka Pengaturan"** |
| **Expected Result** | System settings terbuka (`PhotoManager.openSetting()`). User bisa mengubah izin galeri. Dialog tertutup |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | N-C-03 |
| **Nama** | Izin galeri ditolak — tap "Batal" |
| **Precondition** | Dialog **"Izin galeri diperlukan"** terbuka |
| **Steps** | 1. Tap tombol **"Batal"** |
| **Expected Result** | Dialog tertutup. Tetap di `AddDays`. Tidak navigasi ke `ActivityPhotoPage` |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | N-C-04 |
| **Nama** | Batal ambil foto dari kamera |
| **Precondition** | Berada di `ActivityPhotoPage`, kamera terbuka |
| **Steps** | 1. Tap ikon kamera |
| | 2. Kamera terbuka |
| | 3. Tap **"Cancel/Back"** tanpa mengambil foto |
| **Expected Result** | Kembali ke `ActivityPhotoPage`. Tidak ada foto baru ditambahkan. Grid tetap sama |
| **Priority** | Low |

### EDGE TESTING

| Item | Detail |
|---|---|
| **ID** | E-C-01 |
| **Nama** | Tambah foto yang sudah ada (duplikat) |
| **Precondition** | Foto X sudah ada di `Activity.images` |
| **Steps** | 1. Coba tambahkan foto X lagi (dari galeri atau kamera dengan path sama) |
| **Expected Result** | Foto tidak ditambahkan duplikat. `addPhotoActivity()` check: `if (!(activity.images?.contains(pathImage) ?? false))` mencegah duplikasi |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | E-C-02 |
| **Nama** | Hapus semua foto dari aktivitas |
| **Precondition** | Aktivitas punya 3 foto |
| **Steps** | 1. Select semua foto (long press + tap each) |
| | 2. Tap ikon hapus |
| **Expected Result** | Semua foto dipindahkan ke `removedImages`. Grid kosong. Saat itinerary disimpan, `cleanPhotoActivity()` dijalankan dan file foto dihapus dari storage |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | E-C-03 |
| **Nama** | Auto-detect foto dari galeri berdasarkan waktu aktivitas |
| **Precondition** | Ada foto di galeri device yang diambil pada waktu & tanggal sesuai aktivitas |
| **Steps** | 1. Buka `ActivityPhotoPage` untuk aktivitas tertentu |
| | 2. Tunggu proses sync (`syncGalleryIncremental`) selesai |
| **Expected Result** | Foto dari galeri yang sesuai waktu aktivitas muncul otomatis. Foto auto-detected ditandai dengan prefix **"AUTO_"** di nama file. `lastGalleryScanEpochMs` di-update |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | E-C-04 |
| **Nama** | Izin galeri limited (iOS 14+) |
| **Precondition** | Izin galeri dalam mode "limited access" |
| **Steps** | 1. Tap **"Galeri"** dari dialog detail aktivitas |
| **Expected Result** | Tetap bisa akses `ActivityPhotoPage` karena check: `result.isAuth \|\| result == PermissionState.limited` |
| **Priority** | Low |

---

## 5. Flow D — Export PDF

### POSITIVE TESTING

| Item | Detail |
|---|---|
| **ID** | P-D-01 |
| **Nama** | Buka preview PDF dari AddDays |
| **Precondition** | Berada di `AddDays` dengan itinerary yang punya aktivitas |
| **Steps** | 1. Tap tombol **"Bagikan PDF"** (outlined button dengan ikon share di bottom bar `AddDays`) |
| **Expected Result** | Navigasi ke `PdfPreviewPage`. AppBar menampilkan "pratinjau pdf" dan label "A4". PDF itinerary di-render dalam format A4 oleh `PdfPreview` widget dari package `printing` |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-D-02 |
| **Nama** | Verifikasi konten PDF — judul dan aktivitas lengkap |
| **Precondition** | Berada di `PdfPreviewPage`, itinerary punya 3 hari dengan masing-masing 2 aktivitas |
| **Steps** | 1. Scroll preview PDF dari atas ke bawah |
| | 2. Periksa: judul itinerary di atas |
| | 3. Periksa: tabel per hari dengan kolom aktivitas |
| **Expected Result** | PDF menampilkan: judul itinerary, tabel per hari dengan kolom nama aktivitas, lokasi, waktu (mulai–selesai), dan keterangan. Semua 3 hari dan 6 aktivitas ter-include |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-D-03 |
| **Nama** | Back dari PdfPreviewPage |
| **Precondition** | Berada di `PdfPreviewPage` |
| **Steps** | 1. Tap tombol **back** (lingkaran arrow di pojok kiri AppBar) |
| **Expected Result** | Kembali ke `AddDays`. Data itinerary tidak berubah |
| **Priority** | Medium |

### NEGATIVE TESTING

| Item | Detail |
|---|---|
| **ID** | N-D-01 |
| **Nama** | Buka PDF untuk itinerary tanpa aktivitas |
| **Precondition** | Itinerary punya 1 hari tapi 0 aktivitas |
| **Steps** | 1. Tap tombol **"Bagikan PDF"** |
| **Expected Result** | PdfPreviewPage terbuka. PDF tetap ter-render (mungkin tabel kosong atau hanya header). Tidak crash |
| **Priority** | Medium |

### EDGE TESTING

| Item | Detail |
|---|---|
| **ID** | E-D-01 |
| **Nama** | PDF untuk itinerary dengan banyak hari (7+) |
| **Precondition** | Itinerary dengan 7 hari, masing-masing punya aktivitas |
| **Steps** | 1. Tap **"Bagikan PDF"** |
| | 2. Scroll preview PDF |
| **Expected Result** | Semua 7 hari dan aktivitas ter-render di PDF. Tidak terpotong. Format tetap A4 |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | E-D-02 |
| **Nama** | PDF untuk itinerary dengan aktivitas keterangan panjang |
| **Precondition** | Ada aktivitas dengan keterangan sangat panjang (200+ karakter) |
| **Steps** | 1. Buka preview PDF |
| | 2. Periksa aktivitas dengan keterangan panjang |
| **Expected Result** | Keterangan ter-render dengan benar (wrap text, tidak overflow). Layout PDF tidak rusak |
| **Priority** | Low |

---

## 6. Itinerary List — Search, Edit, Delete

### POSITIVE TESTING

| Item | Detail |
|---|---|
| **ID** | P-LIST-01 |
| **Nama** | Search itinerary berdasarkan judul |
| **Precondition** | Ada beberapa itinerary tersimpan: "Trip Bali", "Trip Yogya", "Trip Bali 2" |
| **Steps** | 1. Tap field search (hint: "Cari Bromo, Bali, Yogya…") di `ItineraryList` |
| | 2. Ketik: **"Bali"** |
| | 3. Tunggu list ter-filter (real-time, setiap karakter onChange trigger `_refreshData()`) |
| **Expected Result** | List menampilkan hanya itinerary yang judulnya mengandung "Bali" (case-insensitive via RegExp). Counter "X perjalanan tersimpan" berubah sesuai hasil filter |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-LIST-02 |
| **Nama** | Buka itinerary existing dari list |
| **Precondition** | Ada itinerary tersimpan |
| **Steps** | 1. Tap salah satu `ItineraryCard` di list |
| **Expected Result** | Navigasi ke `AddDays`. Semua data ter-load: judul, hari, aktivitas, foto. `ItineraryProvider.initItinerary(itinerary)` dipanggil. `snackbarHandler.removeCurrentSnackBar()` dijalankan |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-LIST-03 |
| **Nama** | Edit nama itinerary dari card |
| **Precondition** | Ada itinerary tersimpan |
| **Steps** | 1. Tap ikon **"⋮"** (more_vert) di pojok kanan atas `ItineraryCard` |
| | 2. Popup menu muncul dengan opsi **"Edit nama"** dan **"Hapus"** |
| | 3. Tap **"Edit nama"** |
| | 4. Dialog **"Edit trip"** muncul dengan field nama dan foto cover |
| | 5. Ubah nama menjadi **"Trip Bali Updated"** |
| | 6. Tap tombol **"Simpan"** |
| **Expected Result** | Dialog tertutup. Card di list menampilkan nama baru. Database ter-update via `dbProvider.insertItinerary(itinerary: updated)` |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | P-LIST-04 |
| **Nama** | Hapus itinerary dari card |
| **Precondition** | Ada itinerary tersimpan |
| **Steps** | 1. Tap ikon **"⋮"** (more_vert) di `ItineraryCard` |
| | 2. Tap **"Hapus"** (teks merah) |
| | 3. Dialog konfirmasi **"Hapus itinerary?"** muncul dengan pesan "Itinerary [nama] akan dihapus permanen. Tindakan ini tidak bisa dibatalkan." |
| | 4. Tap tombol **"Hapus"** |
| **Expected Result** | Itinerary dihapus dari database (`DatabaseService.deleteItinerary()`). List refresh otomatis. Counter perjalanan berkurang |
| **Priority** | High |

### NEGATIVE TESTING

| Item | Detail |
|---|---|
| **ID** | N-LIST-01 |
| **Nama** | Search dengan keyword yang tidak ada |
| **Precondition** | Ada itinerary tersimpan |
| **Steps** | 1. Ketik **"xyzabc123"** di field search |
| **Expected Result** | List kosong. Tidak ada itinerary yang ditampilkan. Counter "0 perjalanan tersimpan" |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | N-LIST-02 |
| **Nama** | Edit nama itinerary menjadi kosong |
| **Precondition** | Dialog **"Edit trip"** terbuka |
| **Steps** | 1. Hapus semua teks di field nama |
| | 2. Tap tombol **"Simpan"** |
| **Expected Result** | Dialog tertutup tanpa menyimpan (karena `_controller.text.trim().isEmpty` check). Nama tidak berubah |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | N-LIST-03 |
| **Nama** | Batal hapus itinerary |
| **Precondition** | Dialog konfirmasi **"Hapus itinerary?"** terbuka |
| **Steps** | 1. Tap di luar dialog ATAU tap area yang bukan tombol |
| **Expected Result** | Dialog tertutup. Itinerary tidak dihapus. List tetap sama |
| **Priority** | Medium |

### EDGE TESTING

| Item | Detail |
|---|---|
| **ID** | E-LIST-01 |
| **Nama** | Search case-insensitive |
| **Precondition** | Ada itinerary "Trip BALI" dan "trip bali" |
| **Steps** | 1. Ketik **"bali"** di search |
| **Expected Result** | Kedua itinerary muncul di hasil. RegExp filter case-insensitive: `caseSensitive: false` |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | E-LIST-02 |
| **Nama** | Itinerary card — informasi yang ditampilkan |
| **Precondition** | Itinerary dengan 3 hari, 5 total aktivitas, dan thumbnail |
| **Steps** | 1. Perhatikan `ItineraryCard` di list |
| **Expected Result** | Card menampilkan: thumbnail (atau gradient header jika tidak ada), judul itinerary, range tanggal (format: "20 Jun – 23 Jun"), teks "5 aktivitas", pill "3D2N", ikon "⋮" untuk edit/hapus |
| **Priority** | Medium |

| Item | Detail |
|---|---|
| **ID** | E-LIST-03 |
| **Nama** | List kosong setelah hapus semua itinerary |
| **Precondition** | Hanya ada 1 itinerary tersimpan |
| **Steps** | 1. Hapus itinerary tersebut (via popup menu → Hapus → konfirmasi) |
| **Expected Result** | List kosong. Empty state muncul: "Mulai dari mana?" dengan tombol "Buat itinerary pertama". FAB "Trip baru" menghilang (hidden karena `hasItineraries = false`) |
| **Priority** | Medium |

---

## 7. Edge Cases & Boundary Testing

### EDGE TESTING

| Item | Detail |
|---|---|
| **ID** | E-GEN-01 |
| **Nama** | Aktivitas dengan waktu mulai == waktu selesai |
| **Precondition** | Berada di `AddActivities` |
| **Steps** | 1. Set waktu **"Mulai"**: **10.00** |
| | 2. Set waktu **"Selesai"**: **10.00** |
| **Expected Result** | `_isEndTimeValid` = false. Error muncul: "Waktu Selesai tidak boleh mendahului Waktu Mulai!". Karena check: `_selectedEndTime.hour == _selectedStartTime.hour && _selectedEndTime.minute > _selectedStartTime.minute` — minute 10.00 == 10.00, jadi false |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | E-GEN-02 |
| **Nama** | Aktivitas dengan waktu 00.00 (tengah malam) |
| **Precondition** | Berada di `AddActivities` |
| **Steps** | 1. Set waktu **"Mulai"**: **00.00** |
| | 2. Set waktu **"Selesai"**: **01.00** |
| **Expected Result** | Waktu tersimpan dengan format "00.00" dan "01.00". `_isEndTimeValid` = true. Tidak error |
| **Priority** | Low |

| Item | Detail |
|---|---|
| **ID** | E-GEN-03 |
| **Nama** | Aktivitas dengan waktu 23.59 (hampir tengah malam) |
| **Precondition** | Berada di `AddActivities` |
| **Steps** | 1. Set waktu **"Mulai"**: **23.00** |
| | 2. Set waktu **"Selesai"**: **23.59** |
| **Expected Result** | `_isEndTimeValid` = true. Tersimpan dengan format "23.00" dan "23.59" |
| **Priority** | Low |

| Item | Detail |
|---|---|
| **ID** | E-GEN-04 |
| **Nama** | Itinerary dengan judul 1 karakter |
| **Precondition** | Bottom sheet **"Buat Itinerary Baru"** terbuka |
| **Steps** | 1. Ketik **"A"** di field judul |
| | 2. Tap **"Selanjutnya"** |
| **Expected Result** | Bisa lanjut. Judul "A" tersimpan. Tidak ada validasi minimum karakter |
| **Priority** | Low |

| Item | Detail |
|---|---|
| **ID** | E-GEN-05 |
| **Nama** | Itinerary dengan judul 25 karakter (maksimal) |
| **Precondition** | Bottom sheet **"Buat Itinerary Baru"** terbuka |
| **Steps** | 1. Ketik judul tepat 25 karakter (misal: "Trip Bali 2026 Summer Fun!") |
| | 2. Tap **"Selanjutnya"** |
| **Expected Result** | Bisa lanjut. Judul tersimpan lengkap. Tidak terpotong |
| **Priority** | Low |

| Item | Detail |
|---|---|
| **ID** | E-GEN-06 |
| **Nama** | Lokasi dengan karakter khusus |
| **Precondition** | Berada di `AddActivities` |
| **Steps** | 1. Ketik lokasi: **"Café & Resto 'Lestari' — Jakarta"** |
| | 2. Pilih dari autocomplete atau input manual |
| **Expected Result** | Lokasi tersimpan dengan karakter khusus. Tidak error saat simpan ke SQLite. Ditampilkan dengan benar di `ActivityCard` |
| **Priority** | Low |

| Item | Detail |
|---|---|
| **ID** | E-GEN-07 |
| **Nama** | Keterangan aktivitas sangat panjang (500+ karakter) |
| **Precondition** | Berada di `AddActivities` |
| **Steps** | 1. Isi field **"Keterangan"** dengan teks 500+ karakter |
| | 2. Tap **"Simpan"** |
| **Expected Result** | Tersimpan tanpa error. Di `ActivityCard`, keterangan terpotong (ellipsis). Di dialog detail, keterangan tampil lengkap (scrollable) |
| **Priority** | Low |

| Item | Detail |
|---|---|
| **ID** | E-GEN-08 |
| **Nama** | Edit itinerary dari list, lalu back tanpa simpan |
| **Precondition** | Buka itinerary existing dari list |
| **Steps** | 1. Tambah 1 aktivitas baru |
| | 2. Tap tombol **back** |
| | 3. Dialog konfirmasi muncul → tap **"Keluar Tanpa Simpan"** |
| | 4. Buka lagi itinerary yang sama dari list |
| **Expected Result** | Aktivitas yang ditambahkan tidak ada. Data tetap sama seperti sebelum diedit. `isDataChanged` = false karena `initialItinerary` di-restore |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | E-GEN-09 |
| **Nama** | Simpan itinerary, edit lagi, simpan lagi |
| **Precondition** | Itinerary sudah pernah disimpan |
| **Steps** | 1. Buka itinerary dari list |
| | 2. Tambah 1 aktivitas |
| | 3. Tap **"Simpan"** → kembali ke list |
| | 4. Buka lagi itinerary yang sama |
| | 5. Hapus 1 aktivitas |
| | 6. Tap **"Simpan"** lagi |
| **Expected Result** | Data konsisten. Aktivitas yang dihapus benar-benar hilang. Tidak ada duplikasi atau data phantom |
| **Priority** | High |

| Item | Detail |
|---|---|
| **ID** | E-GEN-10 |
| **Nama** | Orientasi device dikunci portrait |
| **Precondition** | App berjalan |
| **Steps** | 1. Rotasi device ke landscape |
| **Expected Result** | Layar tetap portrait. `SystemChrome.setPreferredOrientations` di `main()` mengunci orientasi |
| **Priority** | Low |

---

## Checklist Eksekusi

| # | Section | Positive | Negative | Edge | Total |
|---|---|---|---|---|---|
| 1 | Splash Screen | 1 | 0 | 0 | 1 |
| 2 | Flow A — Manual | 18 | 10 | 7 | 35 |
| 3 | Flow B — AI | 11 | 7 | 6 | 24 |
| 4 | Flow C — Foto | 7 | 4 | 4 | 15 |
| 5 | Flow D — PDF | 3 | 1 | 2 | 6 |
| 6 | Itinerary List | 4 | 3 | 3 | 10 |
| 7 | Edge Cases | 0 | 0 | 10 | 10 |
| **Total** | | **44** | **25** | **32** | **101** |

---

## Checklist Per Flow

| ID | Test Case | Pass | Fail | N/A | Notes |
|---|---|---|---|---|---|
| P-SPLASH-01 | Splash screen redirect | | | | |
| P-A-01 | Buat itinerary dari empty state | | | | |
| P-A-02 | Buat itinerary dari FAB | | | | |
| P-A-03 | Pilih single day | | | | |
| P-A-04 | Pilih multi day range | | | | |
| P-A-05 | Tambah aktivitas lengkap | | | | |
| P-A-06 | Quick time chip | | | | |
| P-A-07 | Edit aktivitas | | | | |
| P-A-08 | Hapus aktivitas | | | | |
| P-A-09 | Switch day tab | | | | |
| P-A-10 | Simpan itinerary | | | | |
| P-A-11 | Back tanpa perubahan | | | | |
| P-A-12 | Back dengan perubahan | | | | |
| P-A-13 | Simpan & Keluar | | | | |
| P-A-14 | Keluar Tanpa Simpan | | | | |
| P-A-15 | Edit judul di AddDays | | | | |
| P-A-16 | Buka Maps | | | | |
| P-A-17 | Buka foto dari dialog | | | | |
| P-A-18 | Tambah hari dari AddDays | | | | |
| N-A-01 | Judul kosong bottom sheet | | | | |
| N-A-02 | Judul >25 karakter | | | | |
| N-A-03 | Tanggal sebelum hari ini | | | | |
| N-A-04 | Tanpa tanggal — Susun sendiri | | | | |
| N-A-05 | Tanpa tanggal — Minta AI | | | | |
| N-A-06 | Judul kosong di AddActivities | | | | |
| N-A-07 | Lokasi kosong di AddActivities | | | | |
| N-A-08 | End time < start time | | | | |
| N-A-09 | Edit judul kosong AddDays | | | | |
| N-A-10 | Simpan tanpa perubahan | | | | |
| E-A-01 | Simpan tanpa aktivitas | | | | |
| E-A-02 | 7+ hari scroll | | | | |
| E-A-03 | Waktu overlap | | | | |
| E-A-04 | Edit 1 aktivitas, lain tetap | | | | |
| E-A-05 | Double tap simpan | | | | |
| E-A-06 | Tambah hari ke existing | | | | |
| E-A-07 | Hapus hari dari existing | | | | |
| P-B-01 | Navigasi ke FormSuggestion | | | | |
| P-B-02 | Autocomplete kota asal | | | | |
| P-B-03 | Autocomplete kota tujuan | | | | |
| P-B-04 | Pilih vibes (maks 2) | | | | |
| P-B-05 | Pilih pace | | | | |
| P-B-06 | Pilih companion | | | | |
| P-B-07 | Isi catatan | | | | |
| P-B-08 | Generate AI ≤3 hari | | | | |
| P-B-09 | Generate AI >3 hari | | | | |
| P-B-10 | Tab switching SuggestionPage | | | | |
| P-B-11 | Pilih rekomendasi | | | | |
| N-B-01 | Tanpa kota asal | | | | |
| N-B-02 | Tanpa kota tujuan | | | | |
| N-B-03 | Destinasi luar Indonesia | | | | |
| N-B-04 | API key invalid / network error | | | | |
| N-B-05 | Autocomplete query kosong | | | | |
| N-B-06 | Autocomplete query tidak valid | | | | |
| N-B-07 | >2 vibes ditolak | | | | |
| E-B-01 | Trip tepat 3 hari | | | | |
| E-B-02 | Trip 4 hari partial | | | | |
| E-B-03 | Deselect vibe | | | | |
| E-B-04 | Deselect pace/companion | | | | |
| E-B-05 | Clear field autocomplete | | | | |
| E-B-06 | Back dari SuggestionPage | | | | |
| P-C-01 | Buka foto (izin OK) | | | | |
| P-C-02 | Ambil foto kamera | | | | |
| P-C-03 | Pilih foto galeri | | | | |
| P-C-04 | Multi-select share | | | | |
| P-C-05 | Hapus foto | | | | |
| P-C-06 | Buka trash page | | | | |
| P-C-07 | Pulihkan foto | | | | |
| N-C-01 | Izin galeri ditolak | | | | |
| N-C-02 | Buka Pengaturan | | | | |
| N-C-03 | Batal izin | | | | |
| N-C-04 | Batal kamera | | | | |
| E-C-01 | Foto duplikat | | | | |
| E-C-02 | Hapus semua foto | | | | |
| E-C-03 | Auto-detect foto | | | | |
| E-C-04 | Izin limited | | | | |
| P-D-01 | Buka preview PDF | | | | |
| P-D-02 | Konten PDF lengkap | | | | |
| P-D-03 | Back dari PDF | | | | |
| N-D-01 | PDF tanpa aktivitas | | | | |
| E-D-01 | PDF banyak hari | | | | |
| E-D-02 | PDF keterangan panjang | | | | |
| P-LIST-01 | Search itinerary | | | | |
| P-LIST-02 | Buka itinerary existing | | | | |
| P-LIST-03 | Edit nama itinerary | | | | |
| P-LIST-04 | Hapus itinerary | | | | |
| N-LIST-01 | Search tidak ditemukan | | | | |
| N-LIST-02 | Edit nama kosong | | | | |
| N-LIST-03 | Batal hapus | | | | |
| E-LIST-01 | Search case-insensitive | | | | |
| E-LIST-02 | Info card itinerary | | | | |
| E-LIST-03 | List kosong setelah hapus semua | | | | |
| E-GEN-01 | Start == end time | | | | |
| E-GEN-02 | Waktu 00.00 | | | | |
| E-GEN-03 | Waktu 23.59 | | | | |
| E-GEN-04 | Judul 1 karakter | | | | |
| E-GEN-05 | Judul 25 karakter | | | | |
| E-GEN-06 | Lokasi karakter khusus | | | | |
| E-GEN-07 | Keterangan 500+ karakter | | | | |
| E-GEN-08 | Edit lalu back tanpa simpan | | | | |
| E-GEN-09 | Simpan-edit-simpan lagi | | | | |
| E-GEN-10 | Orientasi portrait lock | | | | |

---

## Catatan Penting untuk Tester

1. **Environment**: Pastikan `.env` sudah terisi `GPT_KEY` dan `GMAPS_API_KEY` sebelum testing Flow B
2. **Platform**: Aplikasi target Android (portrait only). Testing di iOS mungkin punya behavior berbeda
3. **Izin Aplikasi**: Flow C membutuhkan izin galeri dan kamera. Pastikan izin diberikan untuk testing lengkap
4. **Koneksi Internet**: Flow B (AI) dan autocomplete kota membutuhkan koneksi internet
5. **Data Test**: Gunakan destinasi dalam Indonesia (AI menolak destinasi luar Indonesia)
6. **Known Issues** (bukan bug, tapi perlu diketahui):
   - Ada `print()` di production code (`database_service.dart:76,85,88,92`, `database_provider.dart:18`, `itinerary_provider.dart:116`) — noise di log
   - Typo `longtitude` di model `Activity.dart:13` — load-bearing, jangan diubah
   - File CSV eksperimen (`kontol.csv`, `pepekk.csv`, `puqi.csv`) ada di `assets/` — sebaiknya dibersihkan sebelum release
   - `native_exif` diimport di `pubspec.yaml` tapi tidak digunakan aktif di kode — kandidat untuk dihapus

---

*Dibuat: 2026-06-18 | Base: SYSTEM_MAP.md + source code analysis | Total: 101 test cases*
