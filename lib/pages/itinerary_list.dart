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
                  IterasiKicker('selamat pagi',
                      color: CustomColor.coral700),
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
                                text: 'kamu',
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
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 16),
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
                      return _EmptyState(onTap: () => getItineraryTitle(context));
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
        floatingActionButton: FloatingActionButton.extended(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: CustomColor.sand300.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.map_outlined,
                size: 36,
                color: CustomColor.coral500,
              ),
            ),
            const SizedBox(height: 20),
            IterasiDisplay(
              'Mulai dari mana?',
              style: const TextStyle(fontSize: 28),
              color: CustomColor.ocean900,
            ),
            const SizedBox(height: 8),
            IterasiBody(
              'Pilih tanggal dulu, lalu susun aktivitasmu hari per hari.',
              color: CustomColor.ocean700,
              maxLines: 3,
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
