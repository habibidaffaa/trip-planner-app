import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:iterasi1/model/itinerary.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

// PDF palette (mirrors the "Quiet Luxury Coastal" tokens).
const _pdfOcean900 = PdfColor.fromInt(0xFF0A2540);
const _pdfCoral500 = PdfColor.fromInt(0xFFD4684A);
const _pdfMuted = PdfColor.fromInt(0xFF6B7A8F);
const _pdfSand300 = PdfColor.fromInt(0xFFE8DAC2);

Future<Uint8List> makePdf(Itinerary itinerary) async {
  final pdf = Document();

  pdf.addPage(
    MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      theme: ThemeData.withFont(),
      build: (context) => [
        _buildHeader(itinerary),
        SizedBox(height: 16),
        _buildStatBar(itinerary),
        SizedBox(height: 8),
        Divider(color: _pdfOcean900, height: 1, thickness: 0.5),
        ..._buildDaySections(itinerary),
      ],
      footer: (context) => _buildFooter(context),
    ),
  );

  return pdf.save();
}

Widget _buildHeader(Itinerary itinerary) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'itinerary',
              style: const TextStyle(
                color: _pdfCoral500,
                fontSize: 10,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 4),
            Text(
              itinerary.title,
              style: TextStyle(
                color: _pdfOcean900,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: 12),
      _buildCompass(),
    ],
  );
}

Widget _buildCompass() {
  return Container(
    width: 34,
    height: 34,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: _pdfOcean900, width: 1),
    ),
    child: Container(
      width: 2,
      height: 16,
      color: _pdfCoral500,
    ),
  );
}

Widget _buildStatBar(Itinerary itinerary) {
  final nDays = itinerary.days.length;
  final nNights = nDays > 1 ? nDays - 1 : 0;
  final totalActivities = _totalActivities(itinerary);

  final segments = <String>[
    _formatDateRange(itinerary),
    '$nDays HARI · $nNights MALAM',
    '$totalActivities AKTIVITAS',
  ];

  final children = <Widget>[];
  for (var i = 0; i < segments.length; i++) {
    children.add(
      Text(
        segments[i],
        style: const TextStyle(
          color: _pdfMuted,
          fontSize: 9,
          letterSpacing: 1,
        ),
      ),
    );
    if (i < segments.length - 1) {
      children.add(
        Text(
          '  ·  ',
          style: const TextStyle(color: _pdfMuted, fontSize: 9),
        ),
      );
    }
  }

  return Row(children: children);
}

List<Widget> _buildDaySections(Itinerary itinerary) {
  final List<Widget> widgets = [];

  for (var i = 0; i < itinerary.days.length; i++) {
    final day = itinerary.days[i];

    widgets.add(SizedBox(height: 16));
    widgets.add(
      Text(
        'HARI ${i + 1} · ${_formatDayLabel(day.date)}',
        style: const TextStyle(
          color: _pdfCoral500,
          fontSize: 9,
          letterSpacing: 2,
        ),
      ),
    );
    widgets.add(SizedBox(height: 2));
    widgets.add(
      Text(
        'Hari ${i + 1}',
        style: TextStyle(
          color: _pdfOcean900,
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
    widgets.add(SizedBox(height: 8));

    if (day.activities.isEmpty) {
      widgets.add(
        Text(
          'Belum ada aktivitas.',
          style: const TextStyle(color: _pdfMuted, fontSize: 10),
        ),
      );
    }

    for (final activity in day.activities) {
      widgets.add(_buildActivityRow(
        startTime: activity.startActivityTime,
        title: activity.activityName,
        lokasi: activity.lokasi,
        keterangan: activity.keterangan,
      ));
      widgets.add(SizedBox(height: 6));
    }

    widgets.add(SizedBox(height: 4));
    widgets.add(Divider(color: _pdfSand300, height: 1, thickness: 0.3));
  }

  return widgets;
}

Widget _buildActivityRow({
  required String startTime,
  required String title,
  required String lokasi,
  required String keterangan,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 44,
        child: Text(
          startTime,
          style: const TextStyle(
            color: _pdfCoral500,
            fontSize: 10,
          ),
        ),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: _pdfOcean900,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
            if (lokasi.trim().isNotEmpty)
              Text(
                lokasi,
                style: const TextStyle(color: _pdfMuted, fontSize: 10),
              ),
            if (keterangan.trim().isNotEmpty)
              Text(
                keterangan,
                style: TextStyle(
                  color: _pdfMuted,
                  fontSize: 9,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

Widget _buildFooter(Context context) {
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Trip Planner · perjalanan dirancang dengan tangan',
          style: const TextStyle(color: _pdfMuted, fontSize: 8),
        ),
        Text(
          '${context.pageNumber} / ${context.pagesCount}',
          style: const TextStyle(color: _pdfMuted, fontSize: 8),
        ),
      ],
    ),
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────

int _totalActivities(Itinerary itinerary) =>
    itinerary.days.fold<int>(0, (sum, day) => sum + day.activities.length);

DateTime? _parseDmy(String dmy) {
  final parts = dmy.split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  return DateTime(year, month, day);
}

String _formatDateRange(Itinerary itinerary) {
  if (itinerary.days.isEmpty) return '';
  final first = _parseDmy(itinerary.days.first.date);
  final last = _parseDmy(itinerary.days.last.date);
  if (first == null) return itinerary.days.first.date;
  if (last == null || first == last) {
    return DateFormat('d MMM yyyy', 'id_ID').format(first);
  }
  // Compact range when within the same month & year: "12 — 16 Mar 2026".
  if (first.month == last.month && first.year == last.year) {
    return '${DateFormat('d', 'id_ID').format(first)} — '
        '${DateFormat('d MMM yyyy', 'id_ID').format(last)}';
  }
  return '${DateFormat('d MMM', 'id_ID').format(first)} — '
      '${DateFormat('d MMM yyyy', 'id_ID').format(last)}';
}

String _formatDayLabel(String dmy) {
  final date = _parseDmy(dmy);
  if (date == null) return dmy;
  return DateFormat('EEEE, d MMM', 'id_ID').format(date).toUpperCase();
}
