import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iterasi1/pages/add_activities/form_suggestion.dart';
import 'package:iterasi1/pages/add_days/add_days.dart';
import 'package:iterasi1/provider/database_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/widget/iterasi_text.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../provider/itinerary_provider.dart';

// ignore: must_be_immutable
class SelectDate extends StatefulWidget {
  final bool isNewItinerary;
  List<DateTime> initialDates;
  SelectDate(
      {Key? key, this.initialDates = const [], required this.isNewItinerary})
      : super(key: key);

  @override
  State<SelectDate> createState() => _SelectDateState();
}

class _SelectDateState extends State<SelectDate> {
  late ItineraryProvider itineraryProvider;
  late DatabaseProvider databaseProvider;
  List<DateTime> selectedDates = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialDates.isNotEmpty && widget.initialDates.length >= 2) {
      final startDate = widget.initialDates.first;
      final endDate = widget.initialDates.last;
      if (startDate.isBefore(endDate) &&
          startDate.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
        for (DateTime d = startDate;
            d.isBefore(endDate.add(const Duration(days: 1)));
            d = d.add(const Duration(days: 1))) {
          selectedDates.add(d);
        }
        selectedDates = selectedDates
            .where((d) =>
                d.isAfter(DateTime.now().subtract(const Duration(days: 1))))
            .toList();
      }
    }
  }

  onSimpanDate() {
    if (selectedDates.isNotEmpty) {
      itineraryProvider.initializeDays(selectedDates);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddDays()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih Tanggal setelah Hari Ini!")),
      );
    }
  }

  String get _rangeLabel {
    if (selectedDates.isEmpty) return '—';
    final fmt = DateFormat('d MMM', 'id_ID');
    if (selectedDates.length == 1) return fmt.format(selectedDates.first);
    return '${fmt.format(selectedDates.first)} – ${fmt.format(selectedDates.last)}';
  }

  @override
  Widget build(BuildContext context) {
    itineraryProvider = Provider.of(context, listen: true);
    databaseProvider = Provider.of(context, listen: true);

    final nights = selectedDates.length > 1 ? selectedDates.length - 1 : 0;
    final isRangeOverThree = selectedDates.length > 3;

    return LoaderOverlay(
      child: Scaffold(
        backgroundColor: CustomColor.paper,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: CustomColor.ocean900.withOpacity(0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: CustomColor.ocean900,
                          size: 18,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: IterasiMono(
                          'step 1 of 3',
                          style: TextStyle(fontSize: 11),
                          color: CustomColor.muted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // Hero
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IterasiKicker('tanggal perjalanan',
                        color: CustomColor.coral700),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: displayStyle.copyWith(
                          fontSize: 34,
                          color: CustomColor.ocean900,
                        ),
                        children: [
                          const TextSpan(text: 'Kapan kamu '),
                          TextSpan(
                            text: 'berangkat',
                            style: displayStyle.copyWith(
                              fontSize: 34,
                              fontStyle: FontStyle.italic,
                              color: CustomColor.ocean900,
                            ),
                          ),
                          const TextSpan(text: '?'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    IterasiBody(
                      'Pilih hari pertama dan hari pulang.',
                      color: CustomColor.ocean700,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Calendar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: CustomColor.paper,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: CustomColor.ocean900.withOpacity(0.10),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: CustomColor.shadowSoft,
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(12),
                  child: SfDateRangePicker(
                    initialDisplayDate: widget.initialDates.isNotEmpty
                        ? widget.initialDates.first
                        : null,
                    initialSelectedRange: widget.initialDates.length >= 2 &&
                            widget.initialDates.first.isAfter(DateTime.now()
                                .subtract(const Duration(days: 1))) &&
                            widget.initialDates.first
                                .isBefore(widget.initialDates.last)
                        ? PickerDateRange(
                            widget.initialDates.first,
                            widget.initialDates.last,
                          )
                        : null,
                    selectionColor: CustomColor.ocean900,
                    startRangeSelectionColor: CustomColor.ocean900,
                    endRangeSelectionColor: CustomColor.ocean900,
                    rangeSelectionColor: CustomColor.sand300.withOpacity(0.4),
                    backgroundColor: CustomColor.paper,
                    todayHighlightColor: CustomColor.coral500,
                    selectionMode: DateRangePickerSelectionMode.range,
                    showNavigationArrow: true,
                    selectionRadius: 20,
                    minDate: DateTime.now(),
                    onSelectionChanged:
                        (DateRangePickerSelectionChangedArgs? args) {
                      if (args?.value is PickerDateRange) {
                        final range = args!.value as PickerDateRange;
                        final start = range.startDate;
                        final end = range.endDate;
                        if (start != null && end != null) {
                          final dates = <DateTime>[];
                          for (DateTime d = start;
                              d.isBefore(end.add(const Duration(days: 1)));
                              d = d.add(const Duration(days: 1))) {
                            dates.add(d);
                          }
                          setState(() {
                            selectedDates = dates
                                .where((d) => d.isAfter(DateTime.now()
                                    .subtract(const Duration(days: 1))))
                                .toList();
                            log(selectedDates.toString());
                          });
                        } else if (start != null) {
                          setState(() {
                            selectedDates = [start]
                                .where((d) => d.isAfter(DateTime.now()
                                    .subtract(const Duration(days: 1))))
                                .toList();
                            log(selectedDates.toString());
                          });
                        }
                      }
                    },
                    headerStyle: DateRangePickerHeaderStyle(
                      backgroundColor: CustomColor.paper,
                      textAlign: TextAlign.center,
                      textStyle: displayStyle.copyWith(fontSize: 20),
                    ),
                    monthCellStyle: DateRangePickerMonthCellStyle(
                      textStyle: bodyStyle.copyWith(fontSize: 13),
                      todayTextStyle:
                          bodyStyle.copyWith(color: CustomColor.coral500),
                    ),
                  ),
                ),
              ),

              // Range readout
              if (selectedDates.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IterasiKicker('berangkat', color: CustomColor.muted),
                          Text(
                            DateFormat('d MMM', 'id_ID')
                                .format(selectedDates.first),
                            style: displayStyle.copyWith(
                              fontSize: 18,
                              color: CustomColor.ocean900,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.arrow_forward,
                          color: CustomColor.coral500,
                          size: 20,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IterasiKicker('pulang', color: CustomColor.muted),
                          Text(
                            selectedDates.length > 1
                                ? DateFormat('d MMM', 'id_ID')
                                    .format(selectedDates.last)
                                : '—',
                            style: displayStyle.copyWith(
                              fontSize: 18,
                              color: CustomColor.ocean900,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      IterasiMono(
                        '${selectedDates.length} hari · $nights malam',
                        color: CustomColor.muted,
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Warning chip for AI path
              if (widget.isNewItinerary && isRangeOverThree)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: CustomColor.warnAmber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: CustomColor.warnAmber.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 16, color: CustomColor.warnAmber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: IterasiBody(
                            'AI hanya menyusun 3 hari pertama (${_rangeLabel}). Sisanya kamu isi sendiri.',
                            style: const TextStyle(fontSize: 12),
                            color: CustomColor.ocean700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Path picker row + CTA
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: widget.isNewItinerary
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: onSimpanDate,
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: CustomColor.ocean900
                                          .withOpacity(0.25),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                  child: Text(
                                    'Susun sendiri',
                                    style: bodyStyle.copyWith(
                                      color: CustomColor.ocean900,
                                      fontWeight: medium,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    if (selectedDates.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                "Pilih Tanggal setelah Hari Ini!")),
                                      );
                                      return;
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => FormSuggestion(
                                          selectedDays: selectedDates,
                                        ),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: CustomColor.ocean900,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Minta AI menyusun',
                                    style: bodyStyle.copyWith(
                                      color: Colors.white,
                                      fontWeight: medium,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onSimpanDate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CustomColor.ocean900,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Simpan',
                            style: bodyStyle.copyWith(
                              color: Colors.white,
                              fontWeight: semibold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
