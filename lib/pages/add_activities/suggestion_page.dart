import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iterasi1/model/activity.dart';
import 'package:iterasi1/model/day.dart';
import 'package:iterasi1/model/itinerary.dart';
import 'package:iterasi1/pages/add_days/add_days.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/utilities/app_helper.dart';
import 'package:iterasi1/widget/iterasi_text.dart';
import 'package:iterasi1/widget/recommendaation_activity_card.dart';
import 'package:provider/provider.dart';

class SuggestionPage extends StatefulWidget {
  final List<Itinerary> itineraries;
  final List<DateTime> selectedDays;
  const SuggestionPage({
    super.key,
    required this.itineraries,
    required this.selectedDays,
  });

  @override
  _SuggestionPageState createState() => _SuggestionPageState();
}

class _SuggestionPageState extends State<SuggestionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itineraries.length < 2) {
      return const Scaffold(
        body: Center(child: Text("Data itinerary tidak cukup")),
      );
    }

    return Scaffold(
      backgroundColor: CustomColor.paper,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        '2 rancangan · geser →',
                        style: TextStyle(fontSize: 11),
                        color: CustomColor.muted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Tab bar
            Container(
              color: CustomColor.paper,
              child: TabBar(
                controller: _tabController,
                indicatorColor: CustomColor.coral500,
                indicatorWeight: 2,
                labelColor: CustomColor.ocean900,
                unselectedLabelColor: CustomColor.muted,
                labelStyle: bodyStyle.copyWith(
                  fontWeight: semibold,
                  fontSize: 13,
                ),
                unselectedLabelStyle: bodyStyle.copyWith(fontSize: 13),
                tabs: const [
                  Tab(text: "Rekomendasi 1"),
                  Tab(text: "Rekomendasi 2"),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildItineraryContent(index: 0),
                  _buildItineraryContent(index: 1),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: CustomColor.paper,
          border: Border(
            top: BorderSide(
              color: CustomColor.ocean900.withOpacity(0.10),
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: CustomColor.coral500,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(100),
            ),
            minimumSize: const Size(double.infinity, 52),
            elevation: 0,
          ),
          onPressed: () {
            log('Itinerary terpilih: ${_tabController.index}');
            for (var i = 0;
                i < widget.itineraries[_tabController.index].days.length;
                i++) {
              Day newDay = widget.itineraries[_tabController.index].days[i];
              context.read<ItineraryProvider>().addDay(newDay);
            }
            // AI hanya menyusun 3 hari pertama. Untuk trip > 3 hari, tambahkan
            // hari ke-4 dst sebagai hari kosong agar bisa diisi manual di AddDays.
            final sortedDates = [...widget.selectedDays]..sort();
            if (sortedDates.length > 3) {
              for (final date in sortedDates.sublist(3)) {
                context.read<ItineraryProvider>().addDay(Day.from(date));
              }
            }
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddDays(),
              ),
            );
          },
          child: Text(
            "Pilih versi ini",
            style: bodyStyle.copyWith(
              fontSize: 16,
              fontWeight: semibold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItineraryContent({required int index}) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: widget.itineraries[index].days.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, indexDay) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CustomColor.sand300.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: IterasiKicker(
                  "Hari ke-${indexDay + 1} ${AppHelper.formatDate(widget.itineraries[index].days[indexDay].date)}",
                  color: CustomColor.coral700,
                ),
              ),
            ),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 8),
              itemCount: widget.itineraries[index]
                  .days[indexDay].activities.length,
              itemBuilder: (context, indexActivity) {
                List<Activity> activities =
                    widget.itineraries[index].days[indexDay].activities;
                return RecommendaationActivityCard(
                  data: activities[indexActivity],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
