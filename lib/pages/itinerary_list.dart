import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iterasi1/model/create_itinerary_result.dart';
import 'package:iterasi1/pages/datepicker/select_date.dart';
import 'package:iterasi1/provider/database_provider.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/utilities/date_time_formatter.dart';
import 'package:iterasi1/widget/custom_buttom_sheet.dart';
import 'package:iterasi1/widget/itinerary_card.dart';
import 'package:iterasi1/widget/iterasi_text.dart';
import 'package:provider/provider.dart';

import '../model/itinerary.dart';

class ItineraryList extends StatefulWidget {
  static const route = "/ItineraryListRoute";

  const ItineraryList({Key? key}) : super(key: key);

  @override
  State<ItineraryList> createState() => _ItineraryListState();
}

class _ItineraryListState extends State<ItineraryList> {
  late ScaffoldMessengerState snackbarHandler;
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _refreshData() {
    context
        .read<DatabaseProvider>()
        .refreshData(filterItineraryName: searchController.text);
  }

  void _unfocusTextField() {
    FocusScope.of(context).unfocus();
  }

  /// Greeting that follows Indonesian time-of-day conventions.
  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'selamat pagi';
    if (hour >= 11 && hour < 15) return 'selamat siang';
    if (hour >= 15 && hour < 18) return 'selamat sore';
    return 'selamat malam';
  }

  @override
  Widget build(BuildContext context) {
    final dbProvider = context.watch<DatabaseProvider>();
    snackbarHandler = ScaffoldMessenger.of(context);
    final statusBarH = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: CustomColor.paper,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inline header
            Padding(
              padding: EdgeInsets.fromLTRB(24, statusBarH + 8, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IterasiKicker(_greeting, color: CustomColor.coral700),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: displayStyle.copyWith(
                              fontSize: 32,
                              color: CustomColor.ocean900,
                            ),
                            children: [
                              const TextSpan(text: 'Trip '),
                              TextSpan(
                                text: 'Planner',
                                style: displayStyle.copyWith(
                                  fontSize: 32,
                                  fontStyle: FontStyle.italic,
                                  color: CustomColor.ocean900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 11),
                    ],
                  ),
                  const SizedBox(height: 4),
                  FutureBuilder<List<Itinerary>>(
                    future: dbProvider.itineraryDatas,
                    builder: (ctx, snap) {
                      final count = snap.data?.length ?? 0;
                      return Text(
                        '$count perjalanan tersimpan.',
                        style: displayStyle.copyWith(
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                          color: CustomColor.ocean700,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Search field pill
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  _refreshData();
                  log('Search input: $value');
                },
                style: bodyStyle.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Cari Bromo, Bali, Yogya…',
                  hintStyle: bodyStyle.copyWith(
                    color: CustomColor.muted,
                    fontSize: 14,
                  ),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Icon(
                      Icons.search,
                      color: CustomColor.ocean600,
                      size: 20,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: BorderSide(
                      color: CustomColor.ocean900.withOpacity(0.12),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(999),
                    borderSide: const BorderSide(
                      color: CustomColor.ocean900,
                    ),
                  ),
                ),
              ),
            ),

            // List
            Expanded(
              child: FutureBuilder<List<Itinerary>>(
                future: dbProvider.itineraryDatas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final itineraries = snapshot.data!;
                    if (itineraries.isEmpty) {
                      return _EmptyState(
                          onTap: () => getItineraryTitle(context));
                    }
                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      itemCount: itineraries.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final itinerary = itineraries[index];
                        return ItineraryCard(
                          parentContext: context,
                          snackbarHandler: snackbarHandler,
                          itinerary: itinerary,
                          dbProvider: dbProvider,
                          onDelete: _refreshData,
                        );
                      },
                    );
                  }
                  return const Center(child: Text('No itineraries found'));
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FutureBuilder<List<Itinerary>>(
          future: dbProvider.itineraryDatas,
          builder: (context, snapshot) {
            // Hide the FAB while the list is empty — the empty state already
            // surfaces a "Buat itinerary pertama" button.
            final hasItineraries = snapshot.data?.isNotEmpty ?? false;
            if (!hasItineraries) {
              return const SizedBox.shrink();
            }
            return FloatingActionButton.extended(
              onPressed: () => getItineraryTitle(context),
              backgroundColor: CustomColor.ocean900,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Trip baru',
                style: bodyStyle.copyWith(
                  color: Colors.white,
                  fontWeight: medium,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> getItineraryTitle(BuildContext context) async {
    _unfocusTextField();
    final result = await showModalBottomSheet<CreateItineraryResult>(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const CustomBottomSheet();
      },
    );

    if (result != null && context.mounted) {
      final today = DateTime.now();
      Provider.of<ItineraryProvider>(context, listen: false).initItinerary(
        Itinerary(
          title: result.title,
          thumbnailPath: result.thumbnailPath,
          dateModified: DateTimeFormatter.toDMY(today),
        ),
      );
      snackbarHandler.removeCurrentSnackBar();
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => SelectDate(isNewItinerary: true),
        ),
      );
      if (context.mounted) {
        _refreshData();
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dashed-border container holding the hand-drawn illustration.
            CustomPaint(
              painter: _DashedBorderPainter(
                color: CustomColor.ocean900.withOpacity(0.20),
                radius: 24,
                dashLength: 6,
                gapLength: 5,
                strokeWidth: 1.5,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: CustomColor.sand300.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 220,
                  height: 150,
                  child: _EmptyIllustration(),
                ),
              ),
            ),
            const SizedBox(height: 24),
            IterasiDisplay(
              'Mulai dari mana?',
              style: const TextStyle(fontSize: 28),
              color: CustomColor.ocean900,
            ),
            const SizedBox(height: 8),
            IterasiBody(
              'Pilih tanggal dulu — lalu susun hari demi hari sendiri, atau biarkan AI menyiapkan dua rancangan untuk kamu pilih.',
              color: CustomColor.ocean700,
              maxLines: 4,
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColor.ocean900,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Buat itinerary pertama',
                  style: bodyStyle.copyWith(
                    color: Colors.white,
                    fontWeight: medium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hand-drawn empty-state illustration: ocean horizon, a rotated ticket stub,
/// a coral paper plane, and a mini compass — mirrors HTML screen 02.
class _EmptyIllustration extends StatelessWidget {
  const _EmptyIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(220, 150),
      painter: _EmptyIllustrationPainter(),
    );
  }
}

class _EmptyIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    _drawHorizon(canvas, size);
    _drawTicket(canvas);
    _drawPaperPlane(canvas);
    _drawCompass(canvas);
  }

  void _drawHorizon(Canvas canvas, Size size) {
    final horizon1 = Paint()
      ..color = CustomColor.ocean300.withOpacity(0.70)
      ..strokeWidth = 1;
    final horizon2 = Paint()
      ..color = CustomColor.sand500.withOpacity(0.50)
      ..strokeWidth = 1;
    canvas.drawLine(const Offset(8, 96), Offset(size.width - 8, 96), horizon1);
    canvas.drawLine(
        const Offset(8, 104), Offset(size.width - 8, 104), horizon2);
  }

  void _drawTicket(Canvas canvas) {
    canvas.save();
    canvas.translate(46, 66);
    canvas.rotate(-6 * 3.1415926535 / 180);

    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 120, 50),
      const Radius.circular(6),
    );
    canvas.drawRRect(body, Paint()..color = Colors.white);
    canvas.drawRRect(
      body,
      Paint()
        ..color = CustomColor.ocean900
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Vertical dashed divider at x = 78.
    final dash = Paint()
      ..color = CustomColor.ocean900.withOpacity(0.4)
      ..strokeWidth = 1;
    for (double dy = 6; dy < 44; dy += 6) {
      canvas.drawLine(Offset(78, dy), Offset(78, dy + 3), dash);
    }

    _paintText(
        canvas,
        'CGK → DPS',
        const Offset(10, 8),
        monoStyle.copyWith(
            fontSize: 9, letterSpacing: 2, color: CustomColor.ocean900));
    _paintText(
        canvas,
        'Bali',
        const Offset(10, 22),
        displayStyle.copyWith(
            fontSize: 16,
            fontStyle: FontStyle.italic,
            color: CustomColor.ocean900));
    _paintText(canvas, '14C', const Offset(86, 10),
        monoStyle.copyWith(fontSize: 9, color: CustomColor.ocean900));
    _paintText(canvas, '06.45', const Offset(86, 28),
        monoStyle.copyWith(fontSize: 9, color: CustomColor.coral500));

    canvas.restore();
  }

  void _drawPaperPlane(Canvas canvas) {
    canvas.save();
    canvas.translate(26, 8);

    final body = Path()
      ..moveTo(0, 30)
      ..lineTo(80, 0)
      ..lineTo(56, 38)
      ..lineTo(36, 28)
      ..close();
    canvas.drawPath(body, Paint()..color = CustomColor.coral500);

    final shadow = Path()
      ..moveTo(36, 28)
      ..lineTo(56, 38)
      ..lineTo(42, 48)
      ..close();
    canvas.drawPath(shadow, Paint()..color = CustomColor.coral700);

    canvas.restore();
  }

  void _drawCompass(Canvas canvas) {
    canvas.save();
    canvas.translate(186, 26);

    canvas.drawCircle(
      Offset.zero,
      14,
      Paint()
        ..color = CustomColor.ocean900
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final needle = Path()
      ..moveTo(0, -10)
      ..lineTo(2, 0)
      ..lineTo(0, 10)
      ..lineTo(-2, 0)
      ..close();
    canvas.drawPath(needle, Paint()..color = CustomColor.ocean900);

    canvas.restore();
  }

  void _paintText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Paints a rounded-rectangle border with a dashed stroke.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashLength;
  final double gapLength;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.dashLength,
    required this.gapLength,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashLength;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.dashLength != dashLength ||
      oldDelegate.gapLength != gapLength ||
      oldDelegate.strokeWidth != strokeWidth;
}
