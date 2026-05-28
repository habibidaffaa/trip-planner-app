import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iterasi1/pages/datepicker/select_date.dart';
import 'package:iterasi1/provider/database_provider.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/utilities/date_time_formatter.dart';
import 'package:iterasi1/widget/custom_buttom_sheet.dart';
import 'package:iterasi1/widget/itinerary_card.dart';
import 'package:iterasi1/widget/text_field_wirdget.dart';
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
  void initState() {
    super.initState();
  }

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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: CustomColor.softOffWhite,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: CustomColor.softOffWhite,
        floatingActionButton: FloatingActionButton(
          elevation: 2,
          onPressed: () {
            getItineraryTitle(context);
          },
          child: const Icon(Icons.add),
        ),
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: CustomColor.whiteColor,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: CustomColor.lightCoolGray,
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Trip Planner',
                style: headingTextStyle.copyWith(
                  color: CustomColor.boardroomNavy,
                  fontWeight: bold,
                  fontSize: 20,
                  letterSpacing: -0.64,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                decoration: BoxDecoration(
                  color: CustomColor.lightCoolGray,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'TRIP SERU, PLANNING GAMPANG',
                  style: primaryTextStyle.copyWith(
                    color: CustomColor.brandElectric,
                    fontSize: 9,
                    fontWeight: semibold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: CustomColor.whiteColor,
              child: TextFieldWidget(
                controller: searchController,
                required: false,
                fillColor: CustomColor.softOffWhite,
                cursorColor: CustomColor.brandElectric,
                onChanged: (value) {
                  _refreshData();
                  log('Search input: $value');
                },
                hintText: 'Cari Trip Anda',
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 12.0, right: 8),
                  child: Icon(Icons.search, color: CustomColor.inputBorderGray),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide:
                      const BorderSide(color: CustomColor.inputBorderGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                  borderSide: const BorderSide(color: CustomColor.brandElectric),
                ),
              ),
            ),
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
                      return const _EmptyState();
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 0),
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
      ),
    );
  }

  Future<void> getItineraryTitle(BuildContext context) async {
    _unfocusTextField();
    final result = await showModalBottomSheet<String>(
      backgroundColor: CustomColor.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const CustomBottomSheet();
      },
    );

    if (result != null && context.mounted) {
      if (result.isNotEmpty) {
        final today = DateTime.now();

        Provider.of<ItineraryProvider>(context, listen: false).initItinerary(
            Itinerary(
                title: result, dateModified: DateTimeFormatter.toDMY(today)));

        snackbarHandler.removeCurrentSnackBar();

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return SelectDate(isNewItinerary: true);
            },
          ),
        );
        if (context.mounted) {
          _refreshData();
        }
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CustomColor.lightCoolGray,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.map_outlined,
              size: 48,
              color: CustomColor.brandElectric,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum ada trip',
            style: headingTextStyle.copyWith(
              fontSize: 20,
              fontWeight: semibold,
              color: CustomColor.boardroomNavy,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Buat itinerary pertama Anda\ndengan menekan tombol +',
            textAlign: TextAlign.center,
            style: primaryTextStyle.copyWith(
              fontSize: 14,
              color: CustomColor.subtitleTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
