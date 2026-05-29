import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:iterasi1/model/itinerary.dart';
import 'package:iterasi1/pages/add_activities/suggestion_page.dart';
import 'package:iterasi1/provider/itinerary_provider.dart';
import 'package:iterasi1/resource/theme.dart';
import 'package:iterasi1/utilities/app_env.dart';
import 'package:iterasi1/widget/iterasi_text.dart';
import 'package:provider/provider.dart';

import '../../widget/loading_overlay.dart';

class FormSuggestion extends StatefulWidget {
  final List<DateTime> selectedDays;

  const FormSuggestion({super.key, required this.selectedDays});

  @override
  FormSuggestionState createState() => FormSuggestionState();
}

class FormSuggestionState extends State<FormSuggestion> {
  final TextEditingController _departureController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  final String _googleMapsApiKey = AppEnv.gmapsApiKey;

  Future<List<Map<String, dynamic>>> _getSuggestions(String query) async {
    if (query.isEmpty) return [];
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$_googleMapsApiKey&components=country:id';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
          return [];
        }
        final predictions = data['predictions'] as List? ?? [];
        return predictions.map<Map<String, dynamic>>((p) {
          return {'description': p['description'], 'place_id': p['place_id']};
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  void dispose() {
    _departureController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  String get _dateLabel {
    final fmt = DateFormat('dd MMM', 'id_ID');
    return '${fmt.format(widget.selectedDays.first)} – ${fmt.format(widget.selectedDays.last)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        'step 2 of 3',
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
                  IterasiKicker(_dateLabel, color: CustomColor.coral700),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      style: displayStyle.copyWith(
                        fontSize: 32,
                        color: CustomColor.ocean900,
                      ),
                      children: [
                        const TextSpan(text: 'Ceritakan '),
                        TextSpan(
                          text: 'tripmu.',
                          style: displayStyle.copyWith(
                            fontSize: 32,
                            fontStyle: FontStyle.italic,
                            color: CustomColor.ocean900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  IterasiBody(
                    'Iterasi akan menyusun dua rancangan untuk kamu pilih.',
                    color: CustomColor.ocean700,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Fields
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  IterasiKicker('LOKASI BERANGKAT',
                      color: CustomColor.muted),
                  const SizedBox(height: 8),
                  _buildAutocompleteField(
                      _departureController, 'Masukkan kota asal',
                      icon: Icons.location_on_outlined),
                  const SizedBox(height: 20),
                  IterasiKicker('LOKASI TUJUAN', color: CustomColor.muted),
                  const SizedBox(height: 8),
                  _buildAutocompleteField(
                      _destinationController, 'Masukkan kota tujuan',
                      icon: Icons.flag_outlined),
                  const SizedBox(height: 32),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutocompleteField(
    TextEditingController controller,
    String hint, {
    required IconData icon,
  }) {
    return PhysicalModel(
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      shadowColor: CustomColor.shadowSoft,
      elevation: 2,
      child: TypeAheadField<Map<String, dynamic>>(
        controller: controller,
        suggestionsCallback: _getSuggestions,
        itemBuilder: (context, suggestion) {
          return ListTile(
            dense: true,
            title: Text(
              suggestion['description'],
              style: bodyStyle.copyWith(fontSize: 13),
            ),
          );
        },
        onSelected: (suggestion) {
          setState(() {
            controller.text = suggestion['description'];
          });
        },
        builder: (context, child, focusNode) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: (value) => setState(() {}),
            style: bodyStyle.copyWith(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: bodyStyle.copyWith(
                color: CustomColor.muted,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                child: Icon(icon,
                    size: 18, color: CustomColor.coral600),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: CustomColor.ocean900.withOpacity(0.15),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: CustomColor.ocean900,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      color: CustomColor.muted,
                      onPressed: () {
                        setState(() {
                          controller.clear();
                        });
                      },
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    final isFormValid = _departureController.text.isNotEmpty &&
        _destinationController.text.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isFormValid
            ? () async {
                LoadingOverlay.show(context, isDark: true);
                try {
                  List<Itinerary> results = await context
                      .read<ItineraryProvider>()
                      .generateItineraryByAi(
                        departure: _departureController.text,
                        destination: _destinationController.text,
                        dates: widget.selectedDays,
                      );
                  LoadingOverlay.hide();
                  if (mounted) {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            SuggestionPage(itineraries: results),
                      ),
                    );
                  }
                } catch (err) {
                  LoadingOverlay.hide();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err.toString())),
                  );
                }
              }
            : null,
        icon: const Icon(Icons.auto_awesome, size: 18, color: Colors.white),
        label: Text(
          'Generate dua itinerary',
          style: bodyStyle.copyWith(
            color: Colors.white,
            fontWeight: semibold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isFormValid ? CustomColor.ocean900 : CustomColor.muted,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
