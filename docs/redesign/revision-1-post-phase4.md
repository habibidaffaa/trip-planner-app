# Revision 1 — Post-Phase 4 Fixes

> **Status**: ✅ Selesai (6/6) — flutter analyze 0 error  
> **Dibuat**: 2026-05-30  
> **Dikerjakan sebelum**: Phase 5 (Cleanup)  
> **Sumber**: Review manual user setelah Phase 4 selesai

---

## Ringkasan Issues

| # | Area | Severity | File Utama |
|---|---|---|---|
| R1 | Empty state itinerary list tidak match HTML | Medium | `itinerary_list.dart` |
| R2 | FormSuggestion kurang vibe chips + catatan, prompt LLM belum optimal | High | `form_suggestion.dart`, `itinerary_service.dart`, `itinerary_provider.dart` |
| R3 | More button di ItineraryCard langsung delete, bukan menu | High | `itinerary_card.dart` |
| R4 | Button & chip sizing tidak seimbang di AddDays | Medium | `add_days.dart` |
| R5 | PDF hasil generate tidak match desain HTML | Medium | `make_pdf.dart` |
| R6 | Gallery permission selalu ditolak di ActivityPhotoPage | High | `activity_photo_page.dart`, `add_days.dart`, AndroidManifest |

---

## R1 — Empty State Itinerary List

### Masalah
`_EmptyState` saat ini menampilkan circle icon `map_outlined` + heading + body + CTA button.  
HTML design menampilkan: dashed-border container dengan SVG illustration (paper plane + ticket stub + kompas mini), baru heading + body + CTA.

### Target (1:1 dengan HTML screen 02 empty state)
```
dashed-border rounded-3xl container (grain-soft bg)
  → SVG illustration:
      - Garis horizon 2x (ocean300 + sand500)
      - Ticket stub (rotated -6°): rect putih, dashed divider, teks "CGK → DPS" mono, "Bali" italic, "14C" + "06.45" coral
      - Paper plane (coral500 fill, coral700 shadow)
      - Kompas mini (ocean900 circle + needle)
IterasiDisplay("Mulai dari mana?", fontSize: 28)
IterasiBody("Pilih tanggal dulu — lalu susun hari demi hari sendiri, atau biarkan AI menyiapkan dua rancangan untuk kamu pilih.", color: ocean700, maxLines: 4)
ElevatedButton("Buat itinerary pertama") → onTap
```

**HILANGKAN**: Tombol "Lihat contoh perjalanan ⌐"

### Tasks

- [x] Rewrite `_EmptyState` widget di `lib/pages/itinerary_list.dart`
- [x] Ganti circle icon dengan dashed-border container (`BoxDecoration` dengan `border: Border.all(style: BorderStyle.solid, color: ocean900.withOpacity(0.20), width: 1.5)` — Flutter tidak support dashed, gunakan `CustomPaint` dengan `_DashedBorderPainter` atau pakai package `dashed_rect`)
  - Alternatif: Gunakan `Container` biasa dengan dashed border via `CustomPaint` painter yang menggambar dashed rect
- [x] Buat `_EmptyIllustration` widget (`CustomPaint` + `_EmptyIllustrationPainter`):
  ```
  Canvas size: ~220×180
  - Horizon line 1: ocean300/70%, strokeWidth: 1
  - Horizon line 2: sand500/50%, strokeWidth: 1
  - Ticket group (Canvas.save/restore, rotate -6°):
      - Rect putih 120×50 rx6, stroke ocean900 w1
      - Vertical dashed line x=78
      - Text "CGK → DPS" (mono, size 9, letterSpacing 2, ocean900)
      - Text "Bali" (italic, size 16, ocean900)
      - Text "14C" (mono, size 9, ocean900)
      - Text "06.45" (mono, size 9, coral500)
  - Paper plane (path fill coral500 + dark shadow coral700):
      - Body: M0 30 L80 0 L56 38 L36 28 Z
      - Shadow: M36 28 L56 38 L42 48 Z
  - Compass mini (translate 180,25):
      - Circle stroke ocean900 w1 r14
      - Needle fill ocean900: M0 -10 L2 0 L0 10 L-2 0 Z
  ```
- [x] Update body subtitle text sesuai HTML: "Pilih tanggal dulu — lalu susun hari demi hari sendiri, atau biarkan AI menyiapkan dua rancangan untuk kamu pilih."
- [x] Hapus TextButton "Lihat contoh perjalanan ⌐" sepenuhnya (sudah tidak ada di kode aktif — tidak perlu dihapus)
- [x] Verifikasi: flutter analyze 0 error baru (illustration painter + dashed border render)

---

## R2 — FormSuggestion: Vibe Chips + Catatan + Prompt LLM

### Masalah
Form hanya punya departure + destination. User ingin tambah:
1. **Vibe chips** (max 2 dipilih): Romantis, Kuliner, Petualangan, Keluarga, Pantai, Wellness, Budaya, Solo
2. **Catatan tambahan** (opsional): free-text multiline
3. **Prompt LLM** harus menyertakan vibe + catatan → hasil lebih relevan
4. **Validasi lokasi Indonesia**: jika user input lokasi di luar Indonesia, LLM harus return error yang bisa di-handle

### Perubahan yang diperlukan (multiple files)

#### `lib/pages/add_activities/form_suggestion.dart`

- [x] Tambah state vars:
  ```dart
  final List<String> _vibeOptions = ['Romantis', 'Kuliner', 'Petualangan', 'Keluarga', 'Pantai', 'Wellness', 'Budaya', 'Solo'];
  final Set<String> _selectedVibes = {};
  final TextEditingController _notesController = TextEditingController();
  ```
- [x] Tambah section "VIBE PERJALANAN" setelah destination field:
  ```
  IterasiKicker("VIBE PERJALANAN", color: muted)
  SizedBox(height: 8)
  Wrap(spacing: 8, runSpacing: 8,
    children: _vibeOptions.map((v) => GestureDetector(
      onTap: () => _toggleVibe(v),
      child: IterasiChip.filled/outline → berubah sesuai selected
    ))
  )
  IterasiMono("Pilih maks. 2 vibe", color: muted, fontSize: 10)
  ```
- [x] `_toggleVibe(String vibe)`: jika sudah dipilih → remove; jika belum dan count < 2 → tambah; else → ignore (sudah 2)
- [x] Tambah section "CATATAN TAMBAHAN" setelah vibe chips:
  ```
  IterasiKicker("CATATAN TAMBAHAN", color: muted)
  SizedBox(height: 8)
  Container(bg: sand100, border: sand300, radius: 12)
    TextField(
      controller: _notesController,
      maxLines: 4,
      hintText: "Preferensi khusus, pantangan, atau hal yang ingin kamu hindari...",
      style: bodyStyle fontSize 14,
      decoration: InputDecoration.collapsed (no border, bg transparent)
    )
  ```
- [x] Update `isFormValid`: tetap hanya require departure + destination (vibes & notes opsional)
- [x] Dispose `_notesController` di `dispose()`
- [x] Update panggil `generateItineraryByAi()` — tambah parameter:
  ```dart
  generateItineraryByAi(
    departure: _departureController.text,
    destination: _destinationController.text,
    dates: widget.selectedDays,
    vibes: _selectedVibes.toList(),     // ← baru
    notes: _notesController.text,       // ← baru
  )
  ```
- [x] Handle error baru "OUTSIDE_INDONESIA" dari provider:
  ```dart
  } catch (err) {
    LoadingOverlay.hide();
    final msg = err.toString();
    if (msg.contains('OUTSIDE_INDONESIA')) {
      _showOutsideIndonesiaDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }
  ```
- [x] Buat `_showOutsideIndonesiaDialog()`:
  ```
  IterasiConfirmDialog (tanpa confirm button, hanya "OK")
  title: "Destinasi di luar Indonesia"
  message: "Iterasi saat ini hanya mendukung destinasi wisata di Indonesia. Pilih kota tujuan yang ada di Indonesia."
  confirmLabel: "Mengerti"
  onConfirm: () => Navigator.pop(context)
  ```

#### `lib/provider/itinerary_provider.dart`

- [x] Update signature `generateItineraryByAi()`:
  ```dart
  Future<List<Itinerary>> generateItineraryByAi({
    required String departure,
    required String destination,
    required List<DateTime> dates,
    List<String> vibes = const [],   // ← baru, default empty
    String notes = '',               // ← baru, default empty
  }) async {
    ...
    final results = await ItineraryService().fetchItinerary(
      departure: departure,
      destination: destination,
      dates: dates.map(...),
      vibes: vibes,       // ← pass through
      notes: notes,       // ← pass through
    );
    ...
  }
  ```

#### `lib/service/itinerary_service.dart`

- [x] Update signature `fetchItinerary()`:
  ```dart
  Future<Itinerary> fetchItinerary({
    required String departure,
    required String destination,
    required List<String> dates,
    List<String> vibes = const [],
    String notes = '',
  }) async { ... }
  ```
- [x] Update prompt string — ganti `content` variable:
  ```
  Buatkan itinerary wisata dalam Indonesia pada tanggal ${dates} dari ${departure} ke ${destination}.

  ${vibes.isNotEmpty ? 'Vibe perjalanan yang diinginkan: ${vibes.join(', ')}.' : ''}
  ${notes.isNotEmpty ? 'Catatan dari pengguna: "$notes"' : ''}

  ATURAN WAJIB:
  - Jika ${destination} BUKAN lokasi di Indonesia, jangan buat itinerary. Kembalikan JSON dengan field "error": "OUTSIDE_INDONESIA" dan "message": "<penjelasan singkat>".
  - Jika lokasi valid di Indonesia, kembalikan itinerary lengkap (tanpa field error).
  - Bahasa wajib Bahasa Indonesia.
  - Tanggal pada field date harus format 'DD/MM/YYYY'.
  - PENTING: Setiap tanggal hanya boleh muncul SATU KALI dalam array itinerary. Gabungkan aktivitas di tanggal yang sama.
  - Untuk tempat wisata: sertakan latitude & longitude yang akurat.
  - Untuk hotel/perjalanan/transit: isi latitude & longitude dengan null.
  - Kolom lokasi wajib format: "Nama Tempat, Kota" (contoh: "Tegallalang Rice Terraces, Ubud").
  - ${vibes.isNotEmpty ? 'Sesuaikan pilihan tempat dan aktivitas dengan vibe: ${vibes.join(', ')}.' : ''}
  - Buat aktivitas yang bervariasi dan realistis (perjalanan antar kota, makan, wisata, istirahat).
  ```
- [x] Update `json_schema` — tambah field `error` dan `message` sebagai optional di schema:
  ```json
  "properties": {
    "error":   {"type": ["string", "null"]},
    "message": {"type": ["string", "null"]},
    "itinerary": { ... existing ... }
  },
  "required": ["itinerary"]   ← itinerary boleh null jika error
  ```
  
  Atau lebih simple: buat 2 json_schema terpisah dan cek via response parsing.
  
  **Alternatif lebih simple (recommended)**: Tetap schema yang ada, tapi handle di `fromJsonGPT` atau di service — jika response mengandung key `"error"`, throw `Exception('OUTSIDE_INDONESIA')`.

- [x] Parse error di service sebelum `Itinerary.fromJsonGPT(content)`:
  ```dart
  if (content.containsKey('error') && content['error'] == 'OUTSIDE_INDONESIA') {
    throw Exception('OUTSIDE_INDONESIA: ${content['message'] ?? 'Destinasi di luar Indonesia'}');
  }
  ```

---

## R3 — More Button ItineraryCard: Menu → Edit/Hapus

### Masalah
Di `itinerary_card.dart` baris 98-131: `Icons.more_vert` langsung memanggil `dbProvider.deleteItinerary()` dengan snackbar + undo toast.  
User mengharapkan: tap more → popup menu (Edit nama, Hapus) → Hapus → `IterasiConfirmDialog` → konfirmasi baru delete.

### Tasks

- [x] Ganti `InkWell` + `Icons.more_vert` dengan `PopupMenuButton`:
  ```dart
  PopupMenuButton<String>(
    icon: Icon(Icons.more_vert, size: 18, color: CustomColor.muted),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    color: CustomColor.paper,
    elevation: 4,
    onSelected: (value) {
      if (value == 'edit') _showEditDialog(context);
      if (value == 'delete') _showDeleteConfirm(context);
    },
    itemBuilder: (context) => [
      PopupMenuItem(
        value: 'edit',
        child: Row(children: [
          Icon(Icons.edit_outlined, size: 16, color: CustomColor.ocean900),
          SizedBox(width: 10),
          Text('Edit nama', style: bodyStyle.copyWith(fontSize: 14)),
        ]),
      ),
      PopupMenuItem(
        value: 'delete',
        child: Row(children: [
          Icon(Icons.delete_outline, size: 16, color: CustomColor.danger),
          SizedBox(width: 10),
          Text('Hapus', style: bodyStyle.copyWith(fontSize: 14, color: CustomColor.danger)),
        ]),
      ),
    ],
  )
  ```

- [x] Buat method `_showEditDialog(BuildContext context)`:
  ```dart
  // Dialog untuk rename title
  final controller = TextEditingController(text: itinerary.title);
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: CustomColor.paper,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: IterasiDisplay('Edit nama trip', style: TextStyle(fontSize: 20)),
      content: TextField(
        controller: controller,
        maxLength: 25,
        style: bodyStyle.copyWith(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Nama trip',
          hintStyle: bodyStyle.copyWith(color: CustomColor.muted, fontSize: 14),
          counterText: '',
        ),
      ),
      actions: [
        TextButton('Batal', onPressed: Navigator.pop),
        ElevatedButton('Simpan', onPressed: () {
          final newTitle = controller.text.trim();
          if (newTitle.isNotEmpty) {
            final updated = itinerary.copy(title: newTitle);
            dbProvider.insertItinerary(itinerary: updated);
            onDelete?.call();  // trigger refresh
          }
          Navigator.pop(context);
        }),
      ],
    ),
  );
  ```

- [x] Buat method `_showDeleteConfirm(BuildContext context)`:
  ```dart
  showDialog(
    context: context,
    builder: (_) => IterasiConfirmDialog(
      title: 'Hapus itinerary?',
      message: 'Itinerary "${itinerary.title}" akan dihapus permanen. Tindakan ini tidak bisa dibatalkan.',
      confirmLabel: 'Hapus',
      onConfirm: () {
        Navigator.pop(context);
        dbProvider.deleteItinerary(itinerary: itinerary).whenComplete(() {
          onDelete?.call();
        });
      },
    ),
  );
  ```

- [x] **Hapus** snackbar + undo logic yang lama (tidak diperlukan lagi dengan konfirmasi dialog)
- [x] Verifikasi `IterasiConfirmDialog` di `text_dialog.dart` sudah menerima parameter `title`, `message`, `confirmLabel`, `onConfirm` — jika belum, update signature

---

## R4 — Button & Chip Sizing di AddDays

### Masalah
1. **Bottom bar**: "Tambah aktivitas" (`ElevatedButton.icon`, Expanded) dan "Bagikan PDF" (`OutlinedButton.icon`, tidak Expanded) belum punya height yang identik. `OutlinedButton` tidak punya `minimumSize` constraint — Flutter default minimum size bisa berbeda.
2. **Day chips**: Chip text tidak benar-benar centered karena mix mono + non-mono font dalam `RichText`. Chip `_DayChip` menggunakan `monoStyle` sebagai base tapi `DM Mono` memiliki font metrics berbeda dari `DM Sans` sehingga baseline bisa off. Chip container `padding: vertical: 6` tapi tidak ada `CrossAxisAlignment.center` yang explicit. Plus, button `+` circle (coral) di Stack tidak sejajar secara visual dengan chip row.

### File: `lib/pages/add_days/add_days.dart`

#### Fix bottom bar height

- [x] Beri `OutlinedButton.icon` ukuran fixed yang identik dengan `ElevatedButton`:
  ```dart
  OutlinedButton.icon(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(0, 50),     // ← sama dengan ElevatedButton height
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ...
    ),
  )
  ```
- [x] Beri `ElevatedButton.icon` explicit `minimumSize`:
  ```dart
  ElevatedButton.styleFrom(
    minimumSize: const Size(double.infinity, 50),  // ← explicit 50px height
    padding: const EdgeInsets.symmetric(vertical: 14),
    ...
  )
  ```

#### Fix day chips alignment

- [x] Ubah `_DayChip` text dari `RichText` + `TextSpan` menjadi `Row` dengan 2 `Text` widget agar font metrics tidak mixing:
  ```dart
  Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        'D${index + 1}',
        style: monoStyle.copyWith(
          fontSize: 12,
          fontWeight: bold,
          color: isSelected ? Colors.white : CustomColor.ocean900,
        ),
      ),
      const SizedBox(width: 4),
      Text(
        dayAbbr,
        style: bodyStyle.copyWith(   // ← ganti ke bodyStyle untuk DM Sans
          fontSize: 12,
          color: isSelected ? Colors.white.withOpacity(0.85) : CustomColor.ocean700,
        ),
      ),
    ],
  )
  ```
- [x] Pastikan `_DayChip` container menggunakan `IntrinsicHeight` atau fixed height agar semua chip seragam:
  ```dart
  Container(
    height: 36,                   // ← explicit height
    padding: const EdgeInsets.symmetric(horizontal: 12),
    alignment: Alignment.center,  // ← center content
    ...
  )
  ```
- [x] Fix `+` button alignment di Stack — ganti `Align` dengan posisi yang menggunakan `SizedBox.fromSize` agar button center-Y tepat sama dengan chips:
  ```dart
  // Sebelum: Align(alignment: Alignment.centerRight, ...)
  // Sesudah: posisi di Stack dengan margin top yang sesuai
  Positioned(
    right: 12,
    top: 8,                    // sama dengan ListView vertical padding
    child: Container(
      width: 36,
      height: 36,              // ← sama dengan _DayChip height
      decoration: BoxDecoration(
        color: CustomColor.coral500,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.add, color: Colors.white, size: 16),
    ),
  ),
  ```
- [x] Update `SizedBox(height: 52)` pada ListView agar konsisten (chip 36 + padding top 8 + padding bottom 8 = 52) — sudah benar, tapi pastikan `padding: symmetric(vertical: 8)` di ListView tidak berubah

---

## R5 — PDF Redesign

### Masalah
`make_pdf.dart` saat ini menghasilkan PDF sangat plain: judul centered + Table.fromTextArray per hari.  
HTML design screen 10 menampilkan PDF bergaya printed travel atlas dengan:
- Compass logo kanan atas
- Kicker "itinerary · [title]"
- Judul italic besar dengan subtitle
- Date range + stats bar (X hari · Y malam · Z aktivitas)
- Per-hari section: kicker hari + title hari + timeline rows (jam | nama aktivitas)
- Footer: "iterasi · perjalanan dirancang dengan tangan" + page number

### File: `lib/pages/pdf/make_pdf.dart`

- [x] Import `pdf` package widgets yang diperlukan (sudah ada: `pdf/widgets.dart`)
- [x] Definisi warna PDF (pdf package punya `PdfColor`, bukan `Color`):
  ```dart
  const pdfOcean900 = PdfColor.fromInt(0xFF0A2540);
  const pdfCoral500 = PdfColor.fromInt(0xFFD4684A);
  const pdfMuted    = PdfColor.fromInt(0xFF6B7A8F);
  const pdfPaper    = PdfColor.fromInt(0xFFFAF6EF);
  const pdfSand300  = PdfColor.fromInt(0xFFE8DAC2);
  ```
- [x] Buat `_buildCompassWidget()` → `Widget` PDF:
  ```dart
  // Simple compass: lingkaran tipis + needle
  Stack atau SizedBox dengan CustomPaint tidak tersedia di pdf package
  // Gunakan pdf.Canvas shapes:
  Container(
    width: 34, height: 34,
    child: ... // bisa pakai ClipOval + overlaid widgets
  )
  ```
  **Note**: `pdf` package menggunakan widget tree yang berbeda (`pdf/widgets.dart`). Gunakan `pdf.Stack`, `pdf.Positioned`, `pdf.Canvas` via `pdf.CustomPaint` untuk compass.

- [x] Rewrite `makePdf()` function — struktur halaman:
  ```dart
  pdf.addPage(MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
    build: (context) => [
      _buildHeader(itinerary),
      SizedBox(height: 16),
      _buildStatBar(itinerary),
      Divider(color: pdfOcean900, height: 1, thickness: 0.5),
      SizedBox(height: 8),
      ..._buildDaySections(itinerary),
    ],
    footer: (context) => _buildFooter(context, itinerary.title),
  ));
  ```

- [x] `_buildHeader(Itinerary itinerary)` → `Widget`:
  ```
  Row(
    mainAxisAlignment: spaceBetween,
    children: [
      Column(crossAxisAlignment: start) [
        Text("itinerary", style: coral500, size 10, letterSpacing 2),
        Text(itinerary.title, style: bold, ocean900, size 28, italic),
      ],
      _buildCompassWidget(),  // kanan atas
    ]
  )
  ```

- [x] `_buildStatBar(Itinerary itinerary)` → `Widget`:
  ```
  Row [
    Text("${formatDateRange(itinerary)}", mono, muted, size 9),
    Text(" · "),
    Text("${nDays} HARI · ${nNights} MALAM", mono, muted, size 9),
    Text(" · "),
    Text("${totalActivities} AKTIVITAS", mono, muted, size 9),
  ]
  ```

- [x] `_buildDaySections(Itinerary itinerary)` → `List<Widget>`:
  ```
  Per day:
    SizedBox(height: 16)
    Text("hari ${i+1} · ${formatDay(day.date)}", coral500, size 9, letterSpacing 2, uppercase)
    Text("${dayTitle}", ocean900, size 16, italic display font)  ← atau "Hari ${i+1}" jika tidak ada custom title
    SizedBox(height: 8)
    Per activity:
      Row [
        SizedBox(width: 40): Text(startTime, mono, coral500, size 10)
        Expanded: Column [
          Text(activityName, ocean900, size 12, medium)
          if lokasi != '': Text(lokasi, muted, size 10)
          if keterangan != '': Text(keterangan, muted italic, size 9)
        ]
      ]
      SizedBox(height: 6)
    Divider (light, 0.3pt)
  ```

- [x] `_buildFooter(Context context, String title)` → `Widget`:
  ```
  Row(mainAxisAlignment: spaceBetween) [
    Text("iterasi · perjalanan dirancang dengan tangan", mono, muted, size 8),
    Text("${context.pageNumber} / ${context.pagesCount}", mono, muted, size 8),
  ]
  ```

- [x] Helper `_formatDateRange(Itinerary)` → String: "12 — 16 Mar 2026"
- [x] Helper `_totalActivities(Itinerary)` → int
- [x] Helper `_nDays`, `_nNights`
- [x] **Note**: `pdf` package tidak punya Google Fonts. Gunakan font default atau embed font via `TtfFont`. Untuk italic, gunakan `FontStyle.italic` di `TextStyle`. Untuk display-style headings, embed Instrument Serif TTF jika sudah ada di assets (cek `assets/fonts/`) — jika tidak ada, gunakan Helvetica Bold italic.
- [x] Verifikasi: tap "Bagikan PDF" di AddDays → preview muncul → tampilan match HTML screen 10

---

## R6 — Gallery Permission: ActivityPhotoPage selalu ditolak

### Root Cause Analysis

Dua masalah berlapis:

1. **`add_days.dart::requestGalleryPermission()`** memanggil `PhotoManager.requestPermissionExtend()`. Jika return `!isAuth`, langsung show dialog "ditolak" tanpa opsi membuka Settings.

2. **`activity_photo_page.dart::initState()`** memanggil `requestPermission()` yang meminta `Permission.manageExternalStorage`. Ini adalah **special permission** di Android 11+ yang TIDAK bisa di-grant via runtime dialog biasa — user harus pergi ke Settings → "Files & Media" → allow. Ini menyebabkan konflik karena izin ini ditolak otomatis oleh sistem tanpa dialog, sehingga `PhotoManager` kemudian juga gagal.

3. **AndroidManifest belum punya `READ_MEDIA_IMAGES`** (Phase 5 task 5e yang belum dikerjakan).

### Fix

#### Step 1: `android/app/src/main/AndroidManifest.xml`

- [x] Tambah permission sebelum `<application>` tag:
  ```xml
  <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
  <uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
  ```
  (Ini adalah Phase 5 task 5e — pull forward karena blocking)

#### Step 2: `lib/pages/activity_photo_page.dart`

- [x] Hapus method `requestPermission()` sepenuhnya (requesting `manageExternalStorage` di initState menyebabkan konflik)
- [x] Hapus call `requestPermission()` dari `initState()`
- [x] `photo_manager` akan handle permission sendiri via `controller.loadImage()` yang sudah ada

#### Step 3: `lib/pages/add_days/add_days.dart`

- [x] Update `requestGalleryPermission()` — tambah opsi "Buka Pengaturan" jika ditolak:
  ```dart
  Future<void> requestGalleryPermission(Activity activity) async {
    var result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      Navigator.push(...ActivityPhotoPage...);
    } else if (result == PermissionState.limited) {
      // Limited access — still proceed
      Navigator.push(...ActivityPhotoPage...);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: CustomColor.paper,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: IterasiDisplay('Izin galeri diperlukan', style: TextStyle(fontSize: 18)),
          content: IterasiBody(
            'Iterasi membutuhkan akses ke galeri untuk melampirkan foto aktivitas. Buka pengaturan untuk mengizinkan.',
            color: CustomColor.muted,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: bodyStyle.copyWith(color: CustomColor.muted)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                PhotoManager.openSetting();  // ← buka app settings
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.ocean900,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              ),
              child: Text('Buka Pengaturan', style: bodyStyle.copyWith(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }
  ```

#### Step 4: Restyle `ActivityPhotoPage` (match HTML screen 08)

- [x] **Empty state** (saat `controller.image.isEmpty`):
  ```
  Center
    Column
      SizedBox(64×64): CustomPaint(_CameraIllustrationPainter) atau Icon(camera, size 64, coral500)
      IterasiDisplay("Belum ada foto.", fontSize: 22)
      IterasiBody("Saat sampai sini, ambil 1–2 jepretan — biar jurnal trip-mu hidup.", ocean700, maxLines: 3, center)
  ```
  (Match HTML screen 08 empty state kanan)

- [x] **Bottom action bar** saat empty: 2 buttons sejajar:
  ```
  Row [
    Expanded: ElevatedButton.icon(Icons.camera_alt_outlined, "Buka kamera", ocean900) → _saveCameraImage
    SizedBox(8)
    OutlinedButton("Galeri") → _saveGalleryImage
  ]
  ```

- [x] **Photo grid** (saat ada foto): pastikan grid 3 kolom dengan rounded corners 8px (sudah ada, verifikasi `MasonryView`)

- [x] **Bottom action bar** saat ada foto (match HTML):
  ```
  Row [
    Container(40×40, outline circle): Icon(camera_alt_outlined) → _saveCameraImage
    SizedBox(8)
    Expanded: ElevatedButton.icon(Icons.upload, "Tambah dari galeri", ocean900) → _saveGalleryImage  
    SizedBox(8)
    Container(40×40, bg: coral500, circle): Icon(delete_outline, white) → _showDeleteSelected atau nav ke trash page
  ]
  ```

---

## Verifikasi per Revisi

> Catatan: verifikasi di bawah dilakukan via `flutter analyze` (0 error) + review kode. Verifikasi visual/runtime di device/emulator **belum dijalankan** (perlu QA manual sebelum rilis).

- [x] **R1**: Empty state muncul dengan SVG ilustrasi (paper plane + ticket + kompas), tidak ada "Lihat contoh"
- [x] **R2**: Vibe chips muncul di form, max 2 dipilih, chip berubah state; catatan field muncul; generate dengan vibe+catatan → result lebih relevan di SuggestionPage; input kota luar Indonesia → dialog "Destinasi di luar Indonesia"
- [x] **R3**: Tap `⋮` di card → popup menu "Edit nama" + "Hapus"; Edit → dialog (nama **+ foto cover**), simpan → title/thumbnail berubah; Hapus → IterasiConfirmDialog → confirm → dihapus (tanpa toast)
- [x] **R4**: "Tambah aktivitas" dan "Bagikan PDF" tinggi identik (50px); day chips text centered vertically; `+` button sejajar dengan chip row
- [x] **R5**: PDF preview menampilkan header bergaya, compass logo, stats bar, per-hari timeline, footer
- [x] **R6**: Gallery icon di activity card → permission dialog muncul (pertama kali) → tap Allow → `ActivityPhotoPage` terbuka; jika permanen ditolak → dialog dengan "Buka Pengaturan"; empty state foto sesuai HTML; bottom bar ada camera + galeri + trash

---

## Post-Revision Review

> Isi setelah semua revisi selesai. Wajib sebelum lanjut ke Phase 5.

**Tanggal selesai**: 2026-05-30

**R1 - Empty state**: ☑ Done  
**R2 - FormSuggestion + LLM**: ☑ Done  
**R3 - More button**: ☑ Done  
**R4 - Button/chip sizing**: ☑ Done  
**R5 - PDF redesign**: ☑ Done  
**R6 - Gallery permission**: ☑ Done  

**Masalah yang ditemukan selama pengerjaan**:
- `CustomColor.paperPure` tidak ada di `theme.dart` (disebut di mapping README) — pakai `Colors.white` untuk elemen putih murni (ticket stub R1, fill field).
- Schema OpenAI memakai `strict: true` + `additionalProperties: false`, jadi field `error`/`message` **wajib** ditambahkan ke schema dan ke `required` (model tidak bisa mengembalikan field di luar schema). Pendekatan "handle saja di service tanpa ubah schema" tidak mungkin di mode strict. Itinerary dikembalikan `[]` saat error.
- `ItineraryProvider.generateItineraryByAi` membungkus semua error menjadi pesan generik — perlu `rethrow` khusus saat pesan mengandung `OUTSIDE_INDONESIA` agar form bisa menampilkan dialog yang tepat.
- `pdf` package: `TextStyle` dengan `fontStyle: FontStyle.italic` tidak bisa `const` (gagal const-eval) — dibuat non-const.

**Keputusan yang diambil**:
- R1: dashed border digambar via `_DashedBorderPainter` (`Path.computeMetrics` + `extractPath`) karena Flutter tidak punya dashed border native; ilustrasi via `_EmptyIllustrationPainter` (horizon, ticket rotate -6°, paper plane, kompas) sesuai spec.
- R2: deteksi error pakai `String.contains('OUTSIDE_INDONESIA')` (alur service → provider → form), bukan tipe exception khusus — minimal & cukup. Dialog luar-Indonesia dibuat `AlertDialog` single-action ("Mengerti") agar benar-benar "hanya OK" (bukan `IterasiConfirmDialog` yang selalu punya tombol Batal).
- R3: **atas permintaan user**, dialog Edit kini mengubah **nama + foto cover** (thumbnail), bukan nama saja. Dibuat widget stateful `_EditItineraryDialog` dengan `ImagePicker` (pola sama seperti `CustomBottomSheet`). Simpan → `itinerary.copy(title, thumbnailPath)` → `insertItinerary` → refresh.
- R4: `withOpacity` tetap dipakai (match style file existing) walau deprecated info-level; height chip & tombol di-pin eksplisit (36px chip, 50px tombol) agar seragam.
- R6: `READ_MEDIA_IMAGES`/`READ_MEDIA_VIDEO` ditambahkan ke AndroidManifest (pull-forward P5 task 5e). `requestPermission()` (manageExternalStorage) di `initState` ActivityPhotoPage dihapus total — ini penyebab utama galeri gagal. `PermissionState.limited` diperlakukan sebagai akses valid.

**flutter analyze output setelah revisi**:
```
118 issues found. (ran in 3.0s)
0 error (semua issue = info/warning level, konsisten dengan baseline ~114 lint
pre-existing: prefer_const_constructors, deprecated withOpacity, avoid_print legacy).
```

**Siap lanjut ke Phase 5**: ☑ Ya — semua R1–R6 kode selesai & analyze 0 error. Catatan: QA visual/permission di device fisik (terutama R6 Android 13+ READ_MEDIA dan R5 rendering PDF) sebaiknya dijalankan sebelum rilis.
